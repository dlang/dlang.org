Ddoc

$(DERS_BOLUMU $(IX Alias) $(CH4 alias) and $(CH4 with))

$(H5 $(C alias))

$(P
The $(C alias) keyword assigns aliases to existing names. $(C alias) is different from and unrelated to $(C alias this).
)

$(H6 Shortening a long name)

$(P
As we have encountered in the previous chapter, some names may become too long to be convenient. Let's consider the following function from that chapter:
)

---
Stack!(Point!double) randomPoints(size_t count) {
    auto points = new Stack!(Point!double);
    // ...
}
---

$(P
Having to type $(C Stack!(Point!double)) explicitly in multiple places in the program has a number of drawbacks:
)

$(UL
$(LI
Longer names can make the code harder to read.
)

$(LI
It is unnecessary to be reminded at every point that the type is the $(C Stack) data structure that contains objects of the $(C double) instantiations of the $(C Point) struct template.
)

$(LI
If the requirements of the program change and e.g. $(C double) needs to be changed to $(C real), this change must be carried out in multiple places.
)

)

$(P
These drawbacks can be eliminated by giving a new name to $(C Stack!(Point!double)):
)

---
alias $(HILITE Points) = Stack!(Point!double);

// ...

$(HILITE Points) randomPoints(size_t count) {
    auto points = new $(HILITE Points);
    // ...
}
---

$(P
It may make sense to go further and define two aliases, one taking advantage of the other:
)

---
alias PrecisePoint = Point!double;
alias Points = Stack!PrecisePoint;
---

$(P
The syntax of $(C alias) is the following:
)

---
    alias $(I new_name) = $(I existing_name);
---

$(P
After that definition, the new name and the existing name become synonymous: They mean the same thing in the program.
)

$(P
You may encounter the older syntax of this feature in some programs:
)

$(MONO
    // Use of old syntax is discouraged:
    alias $(I existing_name) $(I new_name);
)

$(P
$(C alias) is also useful when shortening names which otherwise need to be spelled out along with their module names. Let's assume that the name $(C Queen) appears in two separate modules: $(C chess) and $(C palace). When both modules are imported, typing merely $(C Queen) would cause a compilation error:
)

---
import chess;
import palace;

// ...

    Queen person;             $(DERLEME_HATASI)
---

$(P
The compiler cannot decide which $(C Queen) has been meant:
)

$(SHELL_SMALL
Error: $(HILITE chess.Queen) at chess.d(1) conflicts with
$(HILITE palace.Queen) at palace.d(1)
)

$(P
A convenient way of resolving this conflict is to assign aliases to one or more of the names:
)

---
import palace;

alias $(HILITE PalaceQueen) = palace.Queen;

void main() {
    $(HILITE PalaceQueen) person;
    // ...
    $(HILITE PalaceQueen) anotherPerson;
}
---

$(P
$(C alias) works with other names as well. The following code gives a new name to a variable:
)

---
    int variableWithALongName = 42;

    alias var = variableWithALongName;
    var = 43;

    assert(variableWithALongName == 43);
---

$(H6 Design flexibility)

$(P
For flexibility, even fundamental types like $(C int) can have aliases:
)

---
alias CustomerNumber = int;
alias CompanyName = string;
// ...

struct Customer {
    CustomerNumber number;
    CompanyName company;
    // ...
}
---

$(P
If the users of this struct always type $(C CustomerNumber) and $(C CompanyName) instead of $(C int) and $(C string), then the design can be changed in the future to some extent, without affecting user code.
)

$(P
This helps with the readability of code as well. Having the type of a variable as $(C CustomerNumber) conveys more information about the meaning of that variable than $(C int).
)

$(P
Sometimes such type aliases are defined inside structs and classes and become parts of the interfaces of those types. The following class has a $(C weight) property:
)

---
class Box {
private:

    double weight_;

public:

    double weight() const {
        return weight_;
    }
    // ...
}
---

$(P
Because the member variable and the property of that class is defined as $(C double), the users would have to use $(C double) as well:
)

---
    $(HILITE double) totalWeight = 0;

    foreach (box; boxes) {
        totalWeight += box.weight;
    }
---

$(P
Let's compare it to another design where the type of $(C weight) is defined as an $(C alias):
)

---
class Box {
private:

    $(HILITE Weight) weight_;

public:

    alias $(HILITE Weight) = double;

    $(HILITE Weight) weight() const {
        return weight_;
    }
    // ...
}
---

$(P
Now the user code would normally use $(C Weight) as well:
)

---
    $(HILITE Box.Weight) totalWeight = 0;

    foreach (box; boxes) {
        totalWeight += box.weight;
    }
---

$(P
With this design, changing the actual type of $(C Weight) in the future would not affect user code. (That is, if the new type supports the $(C +=) operator as well.)
)

$(H6 $(IX name hiding) $(IX hiding, name) Revealing hidden names of superclasses)

$(P
When the same name appears both in the superclass and in the subclass, the matching names that are in the superclass are hidden. Even a single name in the subclass is sufficient to hide all of the names of the superclass that match that name:
)

---
class Super {
    void foo(int x) {
        // ...
    }
}

class Sub : Super {
    void foo() {
        // ...
    }
}

void main() {
    auto object = new Sub;
    object.foo(42);            $(DERLEME_HATASI)
}
---

$(P
Since the argument is 42, an $(C int) value, one might expect that the $(C Super.foo) function that takes an $(C int) would be called for that use. However, even though their parameter lists are different, $(C Sub.foo) $(I hides) $(C Super.foo) and causes a compilation error. The compiler disregards $(C Super.foo) altogether and reports that $(C Sub.foo) cannot be called by an $(C int):
)

$(SHELL_SMALL
Error: function $(HILITE deneme.Sub.foo ()) is not callable
using argument types $(HILITE (int))
)

$(P
 Note that this is not the same as overriding a function of the superclass. For that, the function signatures would be the same and the function would be overridden by the $(C override) keyword. (The $(C override) keyword has been explained in $(LINK2 inheritance.html, the Inheritance chapter).)
)

$(P
Here, not overriding, but a language feature called $(I name hiding) is in effect. If there were not name hiding, functions that happen to have the same name $(C foo) that are added to or removed from these classes might silently change the function that would get called. Name hiding prevents such surprises. It is a feature of other OOP languages as well.
)

$(P
$(C alias) can reveal the hidden names when desired:
)

---
class Super {
    void foo(int x) {
        // ...
    }
}

class Sub : Super {
    void foo() {
        // ...
    }

    alias $(HILITE foo) = Super.foo;
}
---

$(P
The $(C alias) above brings the $(C foo) names from the superclass into the subclass interface. As a result, the code now compiles and $(C Super.foo) gets called.
)

$(P
When it is more appropriate, it is possible to bring the names under a different name as well:
)

---
class Super {
    void foo(int x) {
        // ...
    }
}

class Sub : Super {
    void foo() {
        // ...
    }

    alias $(HILITE generalFoo) = Super.foo;
}

// ...

void main() {
    auto object = new Sub;
    object.$(HILITE generalFoo)(42);
}
---

$(P
Name hiding affects member variables as well. $(C alias) can bring those names to the subclass interface as well:
)

---
class Super {
    int city;
}

class Sub : Super {
    string city() const {
        return "Kayseri";
    }
}
---

$(P
Regardless of one being a member variable and the other a member function, the name $(C city) of the subclass hides the name $(C city) of the superclass:
)

---
void main() {
    auto object = new Sub;
    object.city = 42;        $(DERLEME_HATASI)
}
---

$(P
Similarly, the names of the member variables of the superclass can be brought to the subclass interface by $(C alias), possibly under a different name:
)

---
class Super {
    int city;
}

class Sub : Super {
    string city() const {
        return "Kayseri";
    }

    alias $(HILITE cityCode) = Super.city;
}

void main() {
    auto object = new Sub;
    object.$(HILITE cityCode) = 42;
}
---

$(H5 $(IX with) $(C with))

$(P
$(C with) is for removing repeated references to an object or symbol. It takes an expression or a symbol in parentheses and uses that expression or symbol when looking up other symbols that are used inside the scope of $(C with):
)

---
struct S {
    int i;
    int j;
}

void main() {
    auto s = S();

    with ($(HILITE s)) {
        $(HILITE i) = 1;    // means s.i
        $(HILITE j) = 2;    // means s.j
    }
}
---

$(P
It is possible to create a temporary object inside the parentheses. In that case, the temporary object becomes $(LINK2 lvalue_rvalue.html, an lvalue), lifetime of which ends upon leaving the scope:
)

---
    with (S()) {
        i = 1;    // the i member of the temporary object
        j = 2;    // the j member of the temporary object
    }
---

$(P
As we will see later in $(LINK2 pointers.html, the Pointers chapter), it is possible to construct the temporary object with the $(C new) keyword, in which case its lifetime can be extended beyond the scope.
)

$(P
$(C with) is especially useful with $(C case) sections for removing repeated references to e.g. an $(C enum) type:
)

---
enum Color { red, orange }

// ...

    final switch (c) $(HILITE with (Color)) {

    case red:       // means Color.red
        // ...

    case orange:    // means Color.orange
        // ...
    }
---

$(H5 Summary)

$(UL

$(LI $(C alias) assigns aliases to existing names.)

$(LI $(C with) removes repeated references to the same object or symbol.)

)

Macros:
        SUBTITLE=alias

        DESCRIPTION=The alias keyword that enables giving new names to existing names.

        KEYWORDS=d programming lesson book tutorial encapsulation
