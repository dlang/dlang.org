Ddoc

$(DERS_BOLUMU $(IX class) Classes)

$(P
$(IX OOP) $(IX object oriented programming) $(IX user defined type) Similar to structs, $(C class) is a feature for defining new types. By this definition, classes are $(I user defined types). Different from structs, classes provide the $(I object oriented programming) (OOP) paradigm in D. The major aspects of OOP are the following:
)

$(UL

$(LI
$(B Encapsulation:) Controlling access to members ($(I Encapsulation is available for structs as well but it has not been mentioned until this chapter.))
)

$(LI
$(B Inheritance:) Acquiring members of another type
)

$(LI
$(B Polymorphism:) Being able to use a more special type in place of a more general type
)

)

$(P
Encapsulation is achieved by $(I protection attributes), which we will see in $(LINK2 encapsulation.html, a later chapter). Inheritance is for acquiring $(I implementations) of other types. $(LINK2 inheritance.html, Polymorphism) is for abstracting parts of programs from each other and is achieved by class $(I interfaces).
)

$(P
This chapter will introduce classes at a high level, underlining the fact that they are reference types. Classes will be explained in more detail in later chapters.
)

$(H5 Comparing with structs)

$(P
In general, classes are very similar to structs. Most of the features that we have seen for structs in the following chapters apply to classes as well:
)

$(UL
$(LI $(LINK2 struct.html, Structs))
$(LI $(LINK2 member_functions.html, Member Functions))
$(LI $(LINK2 const_member_functions.html, $(CH4 const ref) Parameters and $(CH4 const) Member Functions))
$(LI $(LINK2 special_functions.html, Constructor and Other Special Functions))
$(LI $(LINK2 operator_overloading.html, Operator Overloading))
)

$(P
However, there are important differences between classes and structs.
)

$(H6 Classes are reference types)

$(P
The biggest difference from structs is that structs are $(I value types) and classes are $(I reference types). The other differences outlined below are mostly due to this fact.
)

$(H6 $(IX null, class) $(new, class) Class variables may be $(C null))

$(P
As it has been mentioned briefly in $(LINK2 null_is.html, The $(CH4 null) Value and the $(CH4 is) Operator chapter), class variables can be $(C null). In other words, class variables may not be providing access to any object. Class variables do not have values themselves; the actual class objects must be constructed by the $(C new) keyword.
)

$(P
As you would also remember, comparing a reference to $(C null) by the $(C ==) or the $(C !=) operator is an error. Instead, the comparison must be done by the $(C is) or the $(C !is) operator, accordingly:
)

---
    MyClass referencesAnObject = new MyClass;
    assert(referencesAnObject $(HILITE !is) null);

    MyClass variable;   // does not reference an object
    assert(variable $(HILITE is) null);
---

$(P
The reason is that, the $(C ==) operator may need to consult the values of the members of the objects and that attempting to access the members through a potentially $(C null) variable would cause a memory access error. For that reason, class variables must always be compared by the $(C is) and $(C !is) operators.
)

$(H6 $(IX variable, class) $(IX object, class) Class variables versus class objects)

$(P
Class variable and class object are separate concepts.
)

$(P
Class objects are constructed by the $(C new) keyword; they do not have names. The actual concept that a class type represents in a program is provided by a class object. For example, assuming that a $(C Student) class represents students by their names and grades, such information would be stored by the members of $(C Student) $(I objects). Partly because they are anonymous, it is not possible to access class objects directly.
)

$(P
A class variable on the other hand is a language feature for accessing class objects. Although it may seem syntactically that operations are being performed on a class $(I variable), the operations are actually dispatched to a class $(I object).
)

$(P
Let's consider the following code that we saw previously in the $(LINK2 value_vs_reference.html, Value Types and Reference Types chapter):
)

---
    auto variable1 = new MyClass;
    auto variable2 = variable1;
---

$(P
The $(C new) keyword constructs an anonymous class object. $(C variable1) and $(C variable2) above merely provide access to that anonymous object:
)

$(MONO
 (anonymous MyClass object)    variable1    variable2
 ───┬───────────────────┬───  ───┬───┬───  ───┬───┬───
    │        ...        │        │ o │        │ o │
 ───┴───────────────────┴───  ───┴─│─┴───  ───┴─│─┴───
              ▲                    │            │
              │                    │            │
              └────────────────────┴────────────┘
)

$(H6 $(IX copy, class) Copying)

$(P
Copying affects only the variables, not the object.
)

$(P
Because classes are reference types, defining a new class variable as a copy of another makes two variables that provide access to the same object. The actual object is not copied.
)

$(P
Since no object gets copied, the postblit function $(C this(this)) is not available for classes.
)

---
    auto variable2 = variable1;
---

$(P
In the code above, $(C variable2) is being initialized by $(C variable1). The two variables start providing access to the same object.
)

$(P
When the actual object needs to be copied, the class must have a member function for that purpose. To be compatible with arrays, this function may be named $(C dup()). This function must create and return a new class object. Let's see this on a class that has various types of members:
)

---
class Foo {
    S      o;  // assume S is a struct type
    char[] s;
    int    i;

// ...

    this(S o, const char[] s, int i) {
        this.o = o;
        this.s = s.dup;
        this.i = i;
    }

    Foo dup() const {
        return new Foo(o, s, i);
    }
}
---

$(P
The $(C dup()) member function makes a new object by taking advantage of the constructor of $(C Foo) and returns the new object. Note that the constructor copies the $(C s) member explicitly by the $(C .dup) property of arrays. Being value types, $(C o) and $(C i) are copied automatically.
)

$(P
The following code makes use of $(C dup()) to create a new object:
)

---
    auto var1 = new Foo(S(1.5), "hello", 42);
    auto var2 = var1.dup();
---

$(P
As a result, the objects that are associated with $(C var1) and $(C var2) are different.
)

$(P
Similarly, an $(C immutable) copy of an object can be provided by a member function appropriately named $(C idup()). In this case, the constructor must be defined as $(C pure) as well. We will cover the $(C pure) keyword in $(LINK2 functions_more.html, a later chapter).
)

---
class Foo {
// ...
    this(S o, const char[] s, int i) $(HILITE pure) {
        // ...

    }
    immutable(Foo) idup() const {
        return new immutable(Foo)(o, s, i);
    }
}

// ...

    immutable(Foo) imm = var1.idup();
---

$(H6 $(IX assignment, class) Assignment)

$(P
Just like copying, assignment affects only the variables.
)

$(P
Assigning to a class variable disassociates that variable from its current object and associates it with a new object.
)

$(P
If there is no other class variable that still provides access to the object that has been disassociated from, then that object is going to be destroyed some time in the future by the garbage collector.
)

---
    auto variable1 = new MyClass();
    auto variable2 = new MyClass();
    variable1 $(HILITE =) variable2;
---

$(P
The assignment above makes $(C variable1) leave its object and start providing access to $(C variable2)'s object. Since there is no other variable for $(C variable1)'s original object, that object will be destroyed by the garbage collector.
)

$(P
The behavior of assignment cannot be changed for classes. In other words, $(C opAssign) cannot be overloaded for them.
)

$(H6 Definition)

$(P
Classes are defined by the $(C class) keyword instead of the $(C struct) keyword:
)

---
$(HILITE class) ChessPiece {
    // ...
}
---

$(H6 Construction)

$(P
As with structs, the name of the constructor is $(C this). Unlike structs, class objects cannot be constructed by the $(C {&nbsp;}) syntax.
)

---
class ChessPiece {
    dchar shape;

    this(dchar shape) {
        this.shape = shape;
    }
}
---

$(P
Unlike structs, there is no automatic object construction where the constructor parameters are assigned to members sequentially:
)

---
class ChessPiece {
    dchar shape;
    size_t value;
}

void main() {
    auto king = new ChessPiece('♔', 100);  $(DERLEME_HATASI)
}
---

$(SHELL
Error: no constructor for ChessPiece
)

$(P
For that syntax to work, a constructor must be defined explicitly by the programmer.
)

$(H6 Destruction)

$(P
As with structs, the name of the destructor is $(C ~this):
)

---
    ~this() {
        // ...
    }
---

$(P
$(IX finalizer versus destructor) However, different from structs, class destructors are not executed at the time when the lifetime of a class object ends. As we have seen above, the destructor is executed some time in the future during a garbage collection cycle. (By this distinction, class destructors should have more accurately been called $(I finalizers)).
)

$(P
As we will see later in $(LINK2 memory.html, the Memory Management chapter), class destructors must observe the following rules:
)

$(UL

$(LI A class destructor must not access a member that is managed by the garbage collector. This is because garbage collectors are not required to guarantee that the object and its members are finalized in any specific order. All members may have already been finalized when the destructor is executing.)

$(LI A class destructor must not allocate new memory that is managed by the garbage collector. This is because garbage collectors are not required to guarantee that they can allocate new objects during a garbage collection cycle.)

)

$(P
Violating these rules is undefined behavior. It is easy to see an example of such a problem simply by trying to allocate an object in a class destructor:
)

---
class C {
    ~this() {
        auto c = new C();    // ← WRONG: Allocates explicitly
                             //          in a class destructor
    }
}

void main() {
    auto c = new C();
}
---

$(P
The program is terminated with an exception:
)

$(SHELL
core.exception.$(HILITE InvalidMemoryOperationError)@(0)
)

$(P
It is equally wrong to allocate new memory $(I indirectly) from the garbage collector in a destructor. For example, memory used for the elements of a dynamic array is allocated by the garbage collector as well. Using an array in a way that would require allocating a new memory block for the elements is undefined behavior as well:
)

---
    ~this() {
        auto arr = [ 1 ];    // ← WRONG: Allocates indirectly
                             //          in a class destructor
    }
---

$(SHELL
core.exception.$(HILITE InvalidMemoryOperationError)@(0)
)

$(H6 Member access)

$(P
Same as structs, the members are accessed by the $(I dot) operator:
)

---
    auto king = new ChessPiece('♔');
    writeln(king$(HILITE .shape));
---

$(P
Although the syntax makes it look as if a member of the $(I variable) is being accessed, it is actually the member of the $(I object). Class variables do not have members, the class objects do. The $(C king) variable does not have a $(C shape) member, the anonymous object does.
)

$(P
$(I $(B Note:) It is usually not proper to access members directly as in the code above. When that exact syntax is desired, properties should be preferred, which will be explained in $(LINK2 property.html, a later chapter).)
)

$(H6 Operator overloading)

$(P
Other than the fact that $(C opAssign) cannot be overloaded for classes, operator overloading is the same as structs. For classes, the meaning of $(C opAssign) is always $(I associating a class variable with a class object).
)

$(H6 Member functions)

$(P
Although member functions are defined and used the same way as structs, there is an important difference: Class member functions can be and by-default are $(I overridable). We will see this concept later in $(LINK2 inheritance.html, the Inheritance chapter).
)

$(P
$(IX final) As overridable member functions have a runtime performance cost, without going into more detail, I recommend that you define all $(C class) functions that do not need to be overridden with the $(C final) keyword. You can apply this guideline blindly unless there are compilation errors:
)

---
class C {
    $(HILITE final) int func() {    $(CODE_NOTE Recommended)
        // ...
    }
}
---

$(P
Another difference from structs is that some member functions are automatically inherited from the $(C Object) class. We will see in $(LINK2 inheritance.html, the next chapter) how the definition of $(C toString) can be changed by the $(C override) keyword.
)

$(H6 $(IX is, operator) $(IX !is) The $(C is) and $(C !is) operators)

$(P
These operators operate on class variables.
)

$(P
$(C is) specifies whether two class variables provide access to the same class object. It returns $(C true) if the object is the same and $(C false) otherwise. $(C !is) is the opposite of $(C is).
)

---
    auto myKing = new ChessPiece('♔');
    auto yourKing = new ChessPiece('♔');
    assert(myKing !is yourKing);
---

$(P
Since the objects of $(C myKing) and $(C yourKing) variables are different, the $(C !is) operator returns $(C true). Even though the two objects are constructed by the same character $(C'♔'), they are still two separate objects.
)

$(P
When the variables provide access to the same object, $(C is) returns $(C true):
)

---
    auto myKing2 = myKing;
    assert(myKing2 is myKing);
---

$(P
Both of the variables above provide access to the same object.
)

$(H5 Summary)

$(UL

$(LI Classes and structs share common features but have big differences.
)

$(LI Classes are reference types. The $(C new) keyword constructs an anonymous $(I class object) and returns a $(I class variable).
)

$(LI Class variables that are not associated with any object are $(C null). Checking against $(C null) must be done by $(C is) or $(C !is), not by $(C ==) or $(C !=).
)

$(LI The act of copying associates an additional variable with an object. In order to copy class objects, the type must have a special function likely named $(C dup()).
)

$(LI Assignment associates a variable with an object. This behavior cannot be changed.
)

)

Macros:
        TITLE=Classes

        DESCRIPTION=The basic object oriented programming (OOP) feature of the D programming language.

        KEYWORDS=d programming lesson book tutorial class
