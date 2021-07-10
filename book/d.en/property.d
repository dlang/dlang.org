Ddoc

$(DERS_BOLUMU $(IX property) Properties)

$(P
Properties allow using member functions like member variables.
)

$(P
We are familiar with this feature from slices. The $(C length) property of a slice returns the number of elements of that slice:
)

---
    int[] slice = [ 7, 8, 9 ];
    assert(slice$(HILITE .length) == 3);
---

$(P
Looking merely at that usage, one might think that $(C .length) is implemented as a member variable:
)

---
struct SliceImplementation {
    int length;

    // ...
}
---

$(P
However, the other functionality of this property proves that it cannot be a member variable: Assigning a new value to the $(C .length) property actually changes the length of the slice, sometimes by adding new elements to the underlying array:
)

---
    slice$(HILITE .length = 5);    // The slice now has 5 elements
    assert(slice.length == 5);
---

$(P $(I $(B Note:) The $(C .length) property of fixed-length arrays cannot be modified.)
)

$(P
The assignment to $(C .length) above involves more complicated operations than a simple value change: Determining whether the array has capacity for the new length, allocating more memory if not, and moving the existing elements to the new place; and finally initializing each additional element by $(C .init).
)

$(P
Evidently, the assignment to $(C .length) operates like a function.
)

$(P
Properties are member functions that are used like member variables.
)

$(H5 $(IX ()) Calling functions without parentheses)

$(P
As has been mentioned in the previous chapter, when there is no argument to pass, functions can be called without parentheses:
)

---
    writeln();
    writeln;      // Same as the previous line
---

$(P
This feature is closely related to properties because properties are used almost always without parentheses.
)

$(H5 Property functions that return values)

$(P
As a simple example, let's consider a rectangle struct that consists of two members:
)

---
struct Rectangle {
    double width;
    double height;
}
---

$(P
Let's assume that a third property of this type becomes a requirement, which should provide the area of the rectangle:
)

---
    auto garden = Rectangle(10, 20);
    writeln(garden$(HILITE .area));
---

$(P
One way of achieving that requirement is to define a third member:
)

---
struct Rectangle {
    double width;
    double height;
    double area;
}
---

$(P
A flaw in that design is that the object may easily become inconsistent: Although rectangles must always have the invariant of "width * height == area", this consistency may be broken if the members are allowed to be modified freely and independently.
)

$(P
As an extreme example, objects may even begin their lives in inconsistent states:
)

---
    // Inconsistent object: The area is not 10 * 20 == 200.
    auto garden = Rectangle(10, 20, $(HILITE 1111));
---

$(P
A better way would be to represent the concept of area as a property. Instead of defining an additional member, the value of that member is calculated by a function named $(C area), the same as the concept that it represents:
)

---
struct Rectangle {
    double width;
    double height;

    double area() const {
        return width * height;
    }
}
---

$(P $(I $(B Note:) As you would remember from $(LINK2 const_member_functions.html, the $(CH4 const ref) Parameters and $(CH4 const) Member Functions chapter), the $(C const) specifier on the function declaration ensures that the object is not modified by this function.)
)

$(P
That property function enables the struct to be used as if it has a third member variable:
)

---
    auto garden = Rectangle(10, 20);
    writeln("The area of the garden: ", garden$(HILITE .area));
---

$(P
As the value of the $(C area) property is calculated by multiplying the width and the height of the rectangle, this time it would always be consistent:
)

$(SHELL
The area of the garden: 200
)

$(H5 Property functions that are used in assignment)

$(P
Similar to the $(C length) property of slices, the properties of user-defined types can be used in assignment operations as well:
)

---
    garden.area = 50;
---

$(P
For that assignment to actually change the area of the rectangle, the two members of the struct must be modified accordingly. To enable this functionality, we can assume that the rectangle is $(I flexible) so that to maintain the invariant of "width * height == area", the sides of the rectangle can be changed.
)

$(P
The function that enables such an assignment syntax is also named as $(C area). The value that is used on the right-hand side of the assignment becomes the only parameter of this function.
)

$(P
The following additional definition of $(C area()) enables using that property in assignment operations and effectively modifying the area of $(C Rectangle) objects:
)

---
import std.stdio;
import std.math;

struct Rectangle {
    double width;
    double height;

    double area() const {
        return width * height;
    }

    $(HILITE void area(double newArea)) {
        auto scale = sqrt(newArea / area);

        width *= scale;
        height *= scale;
    }
}

void main() {
    auto garden = Rectangle(10, 20);
    writeln("The area of the garden: ", garden.area);

    $(HILITE garden.area = 50);

    writefln("New state: %s x %s = %s",
             garden.width, garden.height, garden.area);
}
---

$(P
The new function takes advantage of the $(C sqrt) function from the $(C std.math) module, which returns the square root of the specified value. When both of the width and the height of the rectangle are scaled by the square root of the ratio, then the area would equal the desired value.
)

$(P
As a result, assigning the quarter of its current value to $(C area) ends up halving both sides of the rectangle:
)

$(SHELL
The area of the garden: 200
New state: 5 x 10 = 50
)

$(H5 Properties are not absolutely necessary)

$(P
We have seen above how $(C Rectangle) can be used as if it has a third member variable. However, regular member functions could also be used instead of properties:
)

---
import std.stdio;
import std.math;

struct Rectangle {
    double width;
    double height;

    double $(HILITE area()) const {
        return width * height;
    }

    void $(HILITE setArea(double newArea)) {
        auto scale = sqrt(newArea / area);

        width *= scale;
        height *= scale;
    }
}

void main() {
    auto garden = Rectangle(10, 20);
    writeln("The area of the garden: ", garden$(HILITE .area()));

    garden$(HILITE .setArea(50));

    writefln("New state: %s x %s = %s",
             garden.width, garden.height, garden$(HILITE .area()));
}
---

$(P
Further, as we have seen in $(LINK2 function_overloading.html, the Function Overloading chapter), these two functions could even have the same names:
)

---
    double area() const {
        // ...
    }

    void area(double newArea) {
        // ...
    }
---

$(H5 When to use)

$(P
It may not be easy to chose between regular member functions and properties. Sometimes regular member functions feel more natural and sometimes properties.
)

$(P
However, as we have seen in $(LINK2 encapsulation.html, the Encapsulation and Protection Attributes chapter), it is important to restrict direct access to member variables. Allowing user code to freely modify member variables always ends up causing issues with code maintenance. For that reason, member variables better be encapsulated either by regular member functions or by property functions.
)

$(P
Leaving members like $(C width) and $(C height) open to $(C public) access is acceptable only for very simple types. Almost always a better design is to use property functions:
)

---
struct Rectangle {
$(HILITE private:)

    double width_;
    double height_;

public:

    double area() const {
        return width * height;
    }

    void area(double newArea) {
        auto scale = sqrt(newArea / area);

        width_ *= scale;
        height_ *= scale;
    }

    double $(HILITE width()) const {
        return width_;
    }

    double $(HILITE height()) const {
        return height_;
    }
}
---

$(P
Note how the members are made $(C private) so that they can only be accessed by corresponding property functions.
)

$(P
Also note that to avoid confusing their names with the member functions, the names of the member variables are appended by the $(C _) character. $(I Decorating) the names of member variables is a common practice in object oriented programming.
)

$(P
That definition of $(C Rectangle) still presents $(C width) and $(C height) as if they are member variable:
)

---
    auto garden = Rectangle(10, 20);
    writefln("width: %s, height: %s",
             garden$(HILITE .width), garden$(HILITE .height));
---

$(P
When there is no property function that modifies a member variable, then that member is effectively read-only from the outside:
)

---
    garden.width = 100;    $(DERLEME_HATASI)
---

$(P
This is important for controlled modifications of members. The member variables can only be modified by the $(C Rectangle) type itself to ensure the consistency of its objects.
)

$(P
When it later makes sense that a member variable should be allowed to be modified from the outside, then it is simply a matter of defining another property function for that member.
)

$(H6 $(IX @property) $(C @property))

$(P
Property functions may be defined with the $(C @property) attribute as well. However, as a best practice, the use of this attribute is discouraged.
)

---
import std.stdio;

struct Foo {
    $(HILITE @property) int a() const {
        return 42;
    }

    int b() const {    $(CODE_NOTE Defined without @property)
        return 42;
    }
}

void main() {
    auto f = Foo();

    writeln(typeof(f.a).stringof);
    writeln(typeof(f.b).stringof);
}
---

$(P
The only effect of the $(C @property) attribute is when determining the type of an expression that could syntactically be a property function call. As seen in the output below, the types of the expressions $(C f.a) and $(C f.b) are different:
)

$(SHELL
int            $(SHELL_NOTE The type of the expression f.a (the return type))
const int()    $(SHELL_NOTE The type of the member function Foo.b)
)

Macros:
        TITLE=Properties

        DESCRIPTION=Enabling using member functions like member variables.

        KEYWORDS=d programming lesson book tutorial property
