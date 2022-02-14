Ddoc

$(DERS_BOLUMU $(IX function, nested) $(IX struct, nested) $(IX class, nested in function) $(IX nested definition) Nested Functions, Structs, and Classes)

$(P
Up to this point, we have been defining functions, structs, and classes in the outermost scopes (i.e. the module scope). They can be defined in inner scopes as well. Defining them in inner scopes helps with encapsulation by narrowing the visibility of their symbols, as well as creating $(I closures) that we saw in $(LINK2 lambda.html, the Function Pointers, Delegates, and Lambdas chapter).
)

$(P
As an example, the following $(C outerFunc()) function contains definitions of a nested function, a nested $(C struct), and a nested $(C class):
)

---
void outerFunc(int parameter) {
    int local;

    $(HILITE void nestedFunc()) {
        local = parameter * 2;
    }

    $(HILITE struct NestedStruct) {
        void memberFunc() {
            local /= parameter;
        }
    }

    $(HILITE class NestedClass) {
        void memberFunc() {
            local += parameter;
        }
    }

    // Using the nested definitions inside this scope:

    nestedFunc();

    auto s = NestedStruct();
    s.memberFunc();

    auto c = new NestedClass();
    c.memberFunc();
}

void main() {
    outerFunc(42);
}
---

$(P
Like any other variable, nested definitions can access symbols that are defined in their outer scopes. For example, all three of the nested definitions above are able to use the variables named $(C parameter) and $(C local).
)

$(P
As usual, the names of the nested definitions are valid only in the scopes that they are defined in. For example, $(C nestedFunc()), $(C NestedStruct), and $(C NestedClass) are not accessible from $(C main()):
)

---
void main() {
    auto a = NestedStruct();              $(DERLEME_HATASI)
    auto b = outerFunc.NestedStruct();    $(DERLEME_HATASI)
}
---

$(P
Although their names cannot be accessed, nested definitions can still be used in other scopes. For example, many Phobos algorithms handle their tasks by nested structs that are defined inside Phobos functions.
)

$(P
To see an example of this, let's design a function that consumes a slice from both ends in alternating order:
)

---
import std.stdio;
import std.array;

auto alternatingEnds(T)(T[] slice) {
    bool isFromFront = true;

    $(HILITE struct EndAlternatingRange) {
        bool empty() const {
            return slice.empty;
        }

        T front() const {
            return isFromFront ? slice.front : slice.back;
        }

        void popFront() {
            if (isFromFront) {
                slice.popFront();
                isFromFront = false;

            } else {
                slice.popBack();
                isFromFront = true;
            }
        }
    }

    return EndAlternatingRange();
}

void main() {
    auto a = alternatingEnds([ 1, 2, 3, 4, 5 ]);
    writeln(a);
}
---

$(P
Even though the nested $(C struct) cannot be named inside $(C main()), it is still usable:
)

$(SHELL
[1, 5, 2, 4, 3]
)

$(P
$(IX Voldemort) $(I $(B Note:) Because their names cannot be mentioned outside of their scopes, such types are called $(I Voldemort types) due to analogy to a Harry Potter character.)
)

$(P
$(IX closure) $(IX context) Note that the nested $(C struct) that $(C alternatingEnds()) returns does not have any member variables. That $(C struct) handles its task using merely the function parameter $(C slice) and the local function variable $(C isFromFront). The fact that the returned object can safely use those variables even after leaving the context that it was created in is due to a $(I closure) that has been created automatically. We have seen closures in $(LINK2 lambda.html, the Function Pointers, Delegates, and Lambdas chapter).
)

$(H6 $(C static) when a closure is not needed)

$(P
$(IX static, nested definition) Since they keep their contexts alive, nested definitions are more expensive than their regular counterparts. Additionally, as they must include a $(I context pointer) to determine the context that they are associated with, objects of nested definitions occupy more space as well. For example, although the following two structs have exactly the same member variables, their sizes are different:
)

---
import std.stdio;

$(HILITE struct ModuleStruct) {
    int i;

    void memberFunc() {
    }
}

void moduleFunc() {
    $(HILITE struct NestedStruct) {
        int i;

        void memberFunc() {
        }
    }

    writefln("OuterStruct: %s bytes, NestedStruct: %s bytes.",
             ModuleStruct.sizeof, NestedStruct.sizeof);
}

void main() {
    moduleFunc();
}
---

$(P
The sizes of the two structs may be different on other environments:
)

$(SHELL
OuterStruct: $(HILITE 4) bytes, NestedStruct: $(HILITE 16) bytes.
)

$(P
$(IX static class) $(IX static struct) However, some nested definitions are merely for keeping them as local as possible, with no need to access variables from the outer contexts. In such cases, the associated cost would be unnecessary. The $(C static) keyword removes the context pointer from nested definitions, making them equivalents of their module counterparts. As a result, $(C static) nested definitions cannot access their outer contexts:
)

---
void outerFunc(int parameter) {
    $(HILITE static) class NestedClass {
        int i;

        this() {
            i = parameter;    $(DERLEME_HATASI)
        }
    }
}
---

$(P
$(IX .outer, void*) The context pointer of a nested $(C class) object is available as a $(C void*) through its $(C .outer) property. For example, because they are defined in the same scope, the context pointers of the following two objects are equal:
)

---
void foo() {
    class C {
    }

    auto a = new C();
    auto b = new C();

    assert(a$(HILITE .outer) is b$(HILITE .outer));
}
---

$(P
As we will see below, for $(I classes nested inside classes), the type of the context pointer is the type of the outer class, not $(C void*).
)

$(H6 Classes nested inside classes)

$(P
$(IX class, nested in class) When a $(C class) is nested inside another one, the context that the nested object is associated with is the outer object itself.
)

$(P
$(IX .new) $(IX .outer, class type) Such nested classes are constructed by the $(C this.new) syntax. When necessary, the outer object of a nested object can be accessed by $(C this.outer):
)

---
class OuterClass {
    int outerMember;

    $(HILITE class NestedClass) {
        int func() {
            /* A nested class can access members of the outer
             * class. */
            return outerMember * 2;
        }

        OuterClass context() {
            /* A nested class can access its outer object
             * (i.e. its context) by '.outer'. */
            return $(HILITE this.outer);
        }
    }

    NestedClass algorithm() {
        /* An outer class can construct a nested object by
         * '.new'. */
        return $(HILITE this.new) NestedClass();
    }
}

void main() {
    auto outerObject = new OuterClass();

    /* A member function of an outer class is returning a
     * nested object: */
    auto nestedObject = outerObject.algorithm();

    /* The nested object gets used in the program: */
    nestedObject.func();

    /* Naturally, the context of nestedObject is the same as
     * outerObject: */
    assert(nestedObject.context() is outerObject);
}
---

$(P
Instead of $(C this.new) and $(C this.outer), $(C .new) and $(C .outer) can be used on existing objects as well:
)

---
    auto var = new OuterClass();
    auto nestedObject = $(HILITE var.new) OuterClass.NestedClass();
    auto var2 = $(HILITE nestedObject.outer);
---

$(H5 Summary)

$(UL

$(LI Functions, structs, and classes that are defined in inner scopes can access those scopes as their contexts.)

$(LI Nested definitions keep their contexts alive to form closures.)

$(LI Nested definitions are more costly than their module counterparts. When a nested definition does not need to access its context, this cost can be avoided by the $(C static) keyword.)

$(LI Classes can be nested inside other classes. The context of such a nested object is the outer object itself. Nested class objects are constructed by $(C this.new) or $(C variable.new) and their contexts are available by $(C this.outer) or $(C variable.outer).)

)

Macros:
        TITLE=Nested functions, structs, and classes

        DESCRIPTION=Defining functions, structs, and classes in nested scopes.

        KEYWORDS=d programming language tutorial book nested outer
