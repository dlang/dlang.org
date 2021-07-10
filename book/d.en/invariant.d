Ddoc

$(DERS_BOLUMU $(IX contract programming) Contract Programming for Structs and Classes)

$(P
Contract programming is very effective in reducing coding errors. We have seen two of the contract programming features earlier in $(LINK2 contracts.html, the Contract Programming chapter): The $(C in) and $(C out) blocks ensure input and output contracts of functions.
)

$(P
$(I $(B Note:) It is very important that you consider the guidelines under the "$(C in) blocks versus $(C enforce) checks" section of that chapter. The examples in this chapter are based on the assumption that problems with object and parameter consistencies are due to programmer errors. Otherwise, you should use $(C enforce) checks inside function bodies.)
)

$(P
As a reminder, let's write a function that calculates the area of a triangle by Heron's formula. We will soon move the $(C in) and $(C out) blocks of this function to the constructor of a struct.
)

$(P
For this calculation to work correctly, the length of every side of the triangle must be greater than zero. Additionally, since it is impossible to have a triangle where one of the sides is greater than the sum of the other two, that condition must also be checked.
)

$(P
Once these input conditions are satisfied, the area of the triangle would be greater than zero. The following function ensures that all of these requirements are satisfied:
)

---
private import std.math;

double triangleArea(double a, double b, double c)
in {
    // Every side must be greated than zero
    assert(a > 0);
    assert(b > 0);
    assert(c > 0);

    // Every side must be less than the sum of the other two
    assert(a < (b + c));
    assert(b < (a + c));
    assert(c < (a + b));

} out (result) {
    assert(result > 0);

} do {
    immutable halfPerimeter = (a + b + c) / 2;

    return sqrt(halfPerimeter
                * (halfPerimeter - a)
                * (halfPerimeter - b)
                * (halfPerimeter - c));
}
---

$(H5 $(IX in, contract) $(IX out, contract) $(IX precondition) $(IX postcondition) Preconditions and postconditions for member functions)

$(P
The $(C in) and $(C out) blocks can be used with member functions as well.
)

$(P
Let's convert the function above to a member function of a $(C Triangle) struct:
)

---
import std.stdio;
import std.math;

struct Triangle {
private:

    double a;
    double b;
    double c;

public:

    double area() const
    $(HILITE out (result)) {
        assert(result > 0);

    } do {
        immutable halfPerimeter = (a + b + c) / 2;

        return sqrt(halfPerimeter
                    * (halfPerimeter - a)
                    * (halfPerimeter - b)
                    * (halfPerimeter - c));
    }
}

void main() {
    auto threeFourFive = Triangle(3, 4, 5);
    writeln(threeFourFive.area);
}
---

$(P
As the sides of the triangle are now member variables, the function does not take parameters anymore. That is why this function does not have an $(C in) block. Instead, it assumes that the members already have consistent values.
)

$(P
The consistency of objects can be ensured by the following features.
)

$(H5 Preconditions and postconditions for object consistency)

$(P
The member function above is written under the assumption that the members of the object already have consistent values. One way of ensuring that assumption is to define an $(C in) block for the constructor so that the objects are guaranteed to start their lives in consistent states:
)

---
struct Triangle {
// ...

    this(double a, double b, double c)
    $(HILITE in) {
        // Every side must be greated than zero
        assert(a > 0);
        assert(b > 0);
        assert(c > 0);

        // Every side must be less than the sum of the other two
        assert(a < (b + c));
        assert(b < (a + c));
        assert(c < (a + b));

    } do {
        this.a = a;
        this.b = b;
        this.c = c;
    }

// ...
}
---

$(P
This prevents creating invalid $(C Triangle) objects at run time:
)

---
    auto negativeSide = Triangle(-1, 1, 1);
    auto sideTooLong = Triangle(1, 1, 10);
---

$(P
The $(C in) block of the constructor would prevent such invalid objects:
)

$(SHELL
core.exception.AssertError@deneme.d: Assertion failure
)

$(P
Although an $(C out) block has not been defined for the constructor above, it is possible to define one to ensure the consistency of members right after construction.
)

$(H5 $(IX invariant) $(C invariant()) blocks for object consistency)

$(P
The $(C in) and $(C out) blocks of constructors guarantee that the objects start their lives in consistent states and the $(C in) and $(C out) blocks of member functions guarantee that those functions themselves work correctly.
)

$(P
However, these checks are not suitable for guaranteeing that the objects are always in consistent states. Repeating the $(C out) blocks for every member function would be excessive and error-prone.
)

$(P
The conditions that define the consistency and validity of an object are called the $(I invariants) of that object. For example, if there is a one-to-one correspondence between the orders and the invoices of a customer class, then an invariant of that class would be that the lengths of the order and invoice arrays would be equal. When that condition is not satisfied for any object, then the object would be in an inconsistent state.
)

$(P
As an example of an invariant, let's consider the $(C School) class from $(LINK2 encapsulation.html, the Encapsulation and Protection Attributes chapter):
)

---
class School {
private:

    Student[] students;
    size_t femaleCount;
    size_t maleCount;

// ...
}
---

$(P
The objects of that class are consistent only if an invariant that involves its three members are satisfied. The length of the student array must be equal to the sum of the female and male students:
)

---
    assert(students.length == (femaleCount + maleCount));
---

$(P
If that condition is ever false, then there must be a bug in the implementation of this class.
)

$(P
$(C invariant()) blocks are for guaranteeing the invariants of user-defined types. $(C invariant()) blocks are defined inside the body of a $(C struct) or a $(C class). They contain $(C assert) checks similar to $(C in) and $(C out) blocks:
)

---
class School {
private:

    Student[] students;
    size_t femaleCount;
    size_t maleCount;

    $(HILITE invariant()) {
        assert(students.length == (femaleCount + maleCount));
    }

// ...
}
---

$(P
As needed, there can be more than one $(C invariant()) block in a user-defined type.
)

$(P
The $(C invariant()) blocks are executed automatically at the following times:
)

$(UL

$(LI After the execution of the constructor: This guarantees that every object starts its life in a consistent state.)

$(LI Before the execution of the destructor: This guarantees that the destructor will be executed on a consistent object.)

$(LI Before and after the execution of a $(C public) member function: This guarantees that the member functions do not invalidate the consistency of objects.

$(P
$(IX export) $(I $(B Note:) $(C export) functions are the same as $(C public) functions in this regard. (Very briefly, $(C export) functions are functions that are exported on dynamic library interfaces.))
)

)

)

$(P
If an $(C assert) check inside an $(C invariant()) block fails, an $(C AssertError) is thrown. This ensures that the program does not continue executing with invalid objects.
)

$(P
$(IX -release, compiler switch) As with $(C in) and $(C out) blocks, the checks inside $(C invariant()) blocks can be disabled by the $(C -release) command line option:
)

$(SHELL
$ dmd deneme.d -w -release
)

$(H5 $(IX contract inheritance) $(IX inheritance, contract) $(IX precondition, inherited) $(IX postcondition, inherited) $(IX in, inherited) $(IX out, inherited) Contract inheritance)

$(P
Interface and class member functions can have $(C in) and $(C out) blocks as well. This allows an $(C interface) or a $(C class) to define preconditions for its derived types to depend on, as well as to define postconditions for its users to depend on. Derived types can define further $(C in) and $(C out) blocks for the overrides of those member functions. Overridden $(C in) blocks can loosen preconditions and overridden $(C out) blocks can offer more guarantees.
)

$(P
User code is commonly $(I abstracted away) from the derived types, written in a way to satisfy the preconditions of the topmost type in a hierarchy. The user code does not even know about the derived types. Since user code would be written for the contracts of an interface, it would not be acceptable for a derived type to put stricter preconditions on an overridden member function. However, the preconditions of a derived type can be more permissive than the preconditions of its superclass.
)

$(P
Upon entering a function, the $(C in) blocks are executed automatically from the topmost type to the bottom-most type in the hierarchy . If $(I any) $(C in) block succeeds without any $(C assert) failure, then the preconditions are considered to be fulfilled.
)

$(P
Similarly, derived types can define $(C out) blocks as well. Since postconditions are about guarantees that a function provides, the member functions of the derived type must observe the postconditions of its ancestors as well. On the other hand, it can provide additional guarantees.
)

$(P
Upon exiting a function, the $(C out) blocks are executed automatically from the topmost type to the bottom-most type. The function is considered to have fullfilled its postconditions only if $(I all) of the $(C out) blocks succeed.
)

$(P
The following artificial program demonstrates these features on an $(C interface) and a $(C class). The $(C class) requires less from its callers while providing more guarantees:
)

---
interface Iface {
    int[] func(int[] a, int[] b)
    $(HILITE in) {
        writeln("Iface.func.in");

        /* This interface member function requires that the
         * lengths of the two parameters are equal. */
        assert(a.length == b.length);

    } $(HILITE out) (result) {
        writeln("Iface.func.out");

        /* This interface member function guarantees that the
         * result will have even number of elements.
         * (Note that an empty slice is considered to have
         * even number of elements.) */
        assert((result.length % 2) == 0);
    }
}

class Class : Iface {
    int[] func(int[] a, int[] b)
    $(HILITE in) {
        writeln("Class.func.in");

        /* This class member function loosens the ancestor's
         * preconditions by allowing parameters with unequal
         * lengths as long as at least one of them is empty. */
        assert((a.length == b.length) ||
               (a.length == 0) ||
               (b.length == 0));

    } $(HILITE out) (result) {
        writeln("Class.func.out");

        /* This class member function provides additional
         * guarantees: The result will not be empty and that
         * the first and the last elements will be equal. */
        assert((result.length != 0) &&
               (result[0] == result[$ - 1]));

    } do {
        writeln("Class.func.do");

        /* This is just an artificial implementation to
         * demonstrate how the 'in' and 'out' blocks are
         * executed. */

        int[] result;

        if (a.length == 0) {
            a = b;
        }

        if (b.length == 0) {
            b = a;
        }

        foreach (i; 0 .. a.length) {
            result ~= a[i];
            result ~= b[i];
        }

        result[0] = result[$ - 1] = 42;

        return result;
    }
}

import std.stdio;

void main() {
    auto c = new Class();

    /* Although the following call fails Iface's precondition,
     * it is accepted because it fulfills Class' precondition. */
    writeln(c.func([1, 2, 3], $(HILITE [])));
}
---

$(P
The $(C in) block of $(C Class) is executed only because the parameters fail to satisfy the preconditions of $(C Iface):
)

$(SHELL
Iface.func.in
Class.func.in  $(SHELL_NOTE would not be executed if Iface.func.in succeeded)
Class.func.do
Iface.func.out
Class.func.out
[42, 1, 2, 2, 3, 42]
)

$(H5 Summary)

$(UL

$(LI $(C in) and $(C out) blocks are useful in constructors as well. They ensure that objects are constructed in valid states.
)

$(LI
$(C invariant()) blocks ensure that objects remain in valid states throughout their lifetimes.
)

$(LI
Derived types can define $(C in) blocks for overridden member functions. Preconditions of a derived type should not be stricter than the preconditions of its superclasses. ($(I Note that not defining an $(C in) block means "no precondition at all", which may not be the intent of the programmer.))
)

$(LI
Derived types can define $(C out) blocks for overridden member functions. In addition to its own, a derived member function must observe the postconditions of its superclasses as well.
)

)

Macros:
        TITLE=Contract Programming for Structs and Classes

        DESCRIPTION=The invariant keyword that ensures that struct and class objects are always in consistent states.

        KEYWORDS=d programming lesson book tutorial invariant
