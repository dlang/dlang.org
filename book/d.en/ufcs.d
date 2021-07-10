Ddoc

$(DERS_BOLUMU $(IX UFCS) $(IX universal function call syntax) Universal Function Call Syntax (UFCS))

$(P
UFCS is a feature that is applied by the compiler automatically. It enables the member function syntax even for regular functions. It can be explained simply by comparing two expressions:
)

---
    variable.foo($(I arguments))
---

$(P
When the compiler encounters an expression such as the one above, if there is no member function named $(C foo) that can be called on $(C variable) with the provided arguments, then the compiler also tries to compile the following expression:
)

---
    foo(variable, $(I arguments))
---

$(P
If this new expression can indeed be compiled, then the compiler simply accepts that one. As a result, although $(C foo()) evidently has been a regular function, it gets accepted to be used by the member function syntax.
)

$(P
$(I $(B Note:) UFCS considers only functions that are defined at module scope; for example, $(LINK2 nested.html, nested functions) cannot be called with the UFCS syntax.)
)

$(P
We know that functions that are closely related to a type are defined as member functions of that type. This is especially important for encapsulation as only the member functions of a type (and that type's module) can access its $(C private) members.
)

$(P
Let's consider a $(C Car) class which maintains the amount of fuel:
)

---
$(CODE_NAME Car)class Car {
    enum economy = 12.5;          // kilometers per liter (average)
    private double fuelAmount;    // liters

    this(double fuelAmount) {
        this.fuelAmount = fuelAmount;
    }

    double fuel() const {
        return fuelAmount;
    }

    // ...
}
---

$(P
Although member functions are very useful and sometimes necessary, not every function that operates on a type should be a member function. Some operations on a type are too specific to a certain application to be member functions. For example, a function that determines whether a car can travel a specific distance may more appropriately be defined as a regular function:
)

---
$(CODE_NAME canTravel)bool canTravel(Car car, double distance) {
    return (car.fuel() * car.economy) >= distance;
}
---

$(P
This naturally brings a discrepancy in calling functions that are related to a type: objects appear at different places in these two syntaxes:
)

---
$(CODE_XREF Car)$(CODE_XREF canTravel)void main() {
    auto car = new Car(5);

    auto remainingFuel = $(HILITE car).fuel();  // Member function syntax

    if (canTravel($(HILITE car), 100)) {        // Regular function syntax
        // ...
    }
}
---

$(P
UFCS removes this discrepancy by allowing regular functions to be called by the member function syntax:
)

---
    if ($(HILITE car).canTravel(100)) {  // Regular function, called by the
                               // member function syntax
        // ...
    }
---

$(P
This feature is available for fundamental types as well, including literals:
)

---
int half(int value) {
    return value / 2;
}

void main() {
    assert(42.half() == 21);
}
---

$(P
As we will see in the next chapter, when there are no arguments to pass to a function, that function can be called without parentheses. When that feature is used as well, the expression above gets even shorter. All three of the following statements are equivalent:
)

---
    result = half(value);
    result = value.half();
    result = value.half;
---

$(P
$(IX chaining, function call) $(IX function call chaining) UFCS is especially useful when function calls are $(I chained). Let's see this on a group of functions that operate on $(C int) slices:
)

---
$(CODE_NAME functions)// Returns the result of dividing all of the elements by
// 'divisor'
int[] divide(int[] slice, int divisor) {
    int[] result;
    result.reserve(slice.length);

    foreach (value; slice) {
        result ~= value / divisor;
    }

    return result;
}

// Returns the result of multiplying all of the elements by
// 'multiplier'
int[] multiply(int[] slice, int multiplier) {
    int[] result;
    result.reserve(slice.length);

    foreach (value; slice) {
        result ~= value * multiplier;
    }

    return result;
}

// Filters out elements that have odd values
int[] evens(int[] slice) {
    int[] result;
    result.reserve(slice.length);

    foreach (value; slice) {
        if (!(value % 2)) {
            result ~= value;
        }
    }

    return result;
}
---

$(P
When written by the regular syntax, without taking advantage of UFCS, an expression that chains three calls to these functions can be written as in the following program:
)

---
$(CODE_XREF functions)import std.stdio;

// ...

void main() {
    auto values = [ 1, 2, 3, 4, 5 ];
    writeln(evens(divide(multiply(values, 10), 3)));
}
---

$(P
The values are first multiplied by 10, then divided by 3, and finally only the even numbers are used:
)

$(SHELL
[6, 10, 16]
)

$(P
A problem with the expression above is that although the pair of $(C multiply) and $(C 10) are related and the pair of $(C divide) and $(C 3) are related, parts of each pair end up written away from each other. UFCS eliminates this issue and enables a more natural syntax that reflects the actual order of operations:
)

---
    writeln(values.multiply(10).divide(3).evens);
---

$(P
Some programmers take advantage of UFCS even for calls like $(C writeln()):
)

---
    values.multiply(10).divide(3).evens.writeln;
---

$(P
As an aside, the entire program above could have been written in a much simpler way by $(C map()) and $(C filter()):
)

---
import std.stdio;
import std.algorithm;

void main() {
    auto values = [ 1, 2, 3, 4, 5 ];

    writeln(values
            .map!(a => a * 10)
            .map!(a => a / 3)
            .filter!(a => !(a % 2)));
}
---

$(P
The program above takes advantage of $(LINK2 templates.html, templates), $(LINK2 ranges.html, ranges), and $(LINK2 lambda.html, lambda functions), all of which will be explained in later chapters.
)

Macros:
        TITLE=Universal Function Call Syntax (UFCS)

        DESCRIPTION=Universal function call syntax: The ability to call regular functions by the member function syntax.

        KEYWORDS=d programming lesson book tutorial encapsulation
