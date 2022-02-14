Ddoc

$(DERS_BOLUMU $(IX parameter, variable number of) Variable Number of Parameters)

$(P
This chapter covers two D features that bring flexibility on parameters when calling functions:
)

$(UL
$(LI Default arguments)
$(LI Variadic functions)
)

$(H5 $(IX default argument) $(IX argument, default) Default arguments)

$(P
A convenience with function parameters is the ability to specify default values for them. This is similar to the default initial values of struct members.
)

$(P
Some of the parameters of some functions are called mostly by the same values. To see an example of this, let's consider a function that prints the elements of an associative array of type $(C string[string]). Let's assume that the function takes the separator characters as parameters as well:
)

---
$(CODE_NAME printAA)import std.algorithm;

// ...

void printAA(string title,
             string[string] aa,
             string keySeparator,
             string elementSeparator) {
    writeln("-- ", title, " --");

    auto keys = sort(aa.keys);

    // Don't print element separator before the first element
    if (keys.length != 0) {
        auto key = keys[0];
        write(key, keySeparator, aa[key]);
        keys = keys[1..$];    // Remove the first element
    }

    // Print element separator before the remaining elements
    foreach (key; keys) {
        write(elementSeparator);
        write(key, keySeparator, aa[key]);
    }

    writeln();
}
---

$(P
That function is being called below with $(STRING ":") as the key separator and $(STRING ", ") as the element separator:
)

---
$(CODE_XREF printAA)void main() {
    string[string] dictionary = [
        "blue":"mavi", "red":"kırmızı", "gray":"gri" ];

    printAA("Color Dictionary", dictionary, ":", ", ");
}
---

$(P
The output:
)

$(SHELL
-- Color Dictionary --
blue:mavi, gray:gri, red:kırmızı
)

$(P
If the separators are almost always going to be those two, they can be defined with default values:
)

---
void printAA(string title,
             string[string] aa,
             string keySeparator $(HILITE = ": "),
             string elementSeparator $(HILITE = ", ")) {
    // ...
}
---

$(P
Parameters with default values need not be specified when the function is called:
)

---
    printAA("Color Dictionary",
            dictionary);  /* ← No separator specified. Both
                           *   parameters will get their
                           *   default values. */
---

$(P
The parameter values can still be specified when needed, and not necessarily all of them:
)

---
    printAA("Color Dictionary", dictionary$(HILITE , "="));
---

$(P
The output:
)

$(SHELL
-- Color Dictionary --
blue=mavi, gray=gri, red=kırmızı
)

$(P
The following call specifies both of the parameters:
)

---
    printAA("Color Dictionary", dictionary$(HILITE , "=", "\n"));
---

$(P
The output:
)

$(SHELL
-- Color Dictionary --
blue=mavi
gray=gri
red=kırmızı
)

$(P
Default values can only be defined for the parameters that are at the end of the parameter list.
)

$(H6 Special keywords as default arguments)

$(P
$(IX special keyword) $(IX keyword, special) The following special keywords act like compile-time literals having values corresponding to where they appear in code:
)

$(UL

$(LI $(IX __MODULE__) $(C __MODULE__): Name of the module as $(C string))
$(LI $(IX __FILE__) $(C __FILE__): Name of the source file as $(C string))
$(LI $(IX __FILE_FULL_PATH__) $(C __FILE_FULL_PATH__): Name of the source file including its full path as $(C string))
$(LI $(IX __LINE__) $(C __LINE__): Line number as $(C int))
$(LI $(IX __FUNCTION__) $(C __FUNCTION__): Name of the function as $(C string))
$(LI $(IX __PRETTY_FUNCTION__) $(C __PRETTY_FUNCTION__): Full signature of the function as $(C string))

)

$(P
Although they can be useful anywhere in code, they work differently when used as default arguments. When they are used in regular code, their values refer to where they appear in code:
)

---
import std.stdio;

void func(int parameter) {
    writefln("Inside function %s at file %s, line %s.",
             __FUNCTION__, __FILE__, __LINE__);    $(CODE_NOTE $(HILITE line 5))
}

void main() {
    func(42);
}
---

$(P
The reported line 5 is inside the function:
)

$(SHELL
Inside function deneme.$(HILITE func) at file deneme.d, $(HILITE line 5).
)

$(P
However, sometimes it is more interesting to determine the line where a function is called from, not where the definition of the function is. When these special keywords are provided as default arguments, their values refer to where the function is called from:
)

---
import std.stdio;

void func(int parameter,
          string functionName = $(HILITE __FUNCTION__),
          string file = $(HILITE __FILE__),
          int line = $(HILITE __LINE__)) {
    writefln("Called from function %s at file %s, line %s.",
             functionName, file, line);
}

void main() {
    func(42);    $(CODE_NOTE $(HILITE line 12))
}
---

$(P
This time the special keywords refer to $(C main()), the caller of the function:
)

$(SHELL
Called from function deneme.$(HILITE main) at file deneme.d, $(HILITE line 12).
)

$(P
$(IX special token) $(IX token, special) In addition to the above, there are also the following $(I special tokens) that take values depending on the compiler and the time of day:
)

$(UL

$(LI $(IX __DATE__) $(C __DATE__): Date of compilation as $(C string))

$(LI $(IX __TIME__) $(C __TIME__): Time of compilation as $(C string))

$(LI $(IX __TIMESTAMP__) $(C __TIMESTAMP__): Date and time of compilation as $(C string))

$(LI $(IX __VENDOR__) $(C __VENDOR__): Compiler vendor as $(C string) (e.g. $(STRING "Digital Mars D")))

$(LI $(IX __VERSION__) $(C __VERSION__): Compiler version as $(C long) (e.g. the value $(C 2081L) for version 2.081))

)

$(H5 $(IX variadic function)  Variadic functions)

$(P
Despite appearances, default parameter values do not change the number of parameters that a function receives. For example, even though some parameters may be assigned their default values, $(C printAA()) always takes four parameters and uses them according to its implementation.
)

$(P
On the other hand, variadic functions can be called with unspecified number of arguments. We have already been taking advantage of this feature with functions like $(C writeln()). $(C writeln()) can be called with any number of arguments:
)

---
    writeln(
        "hello", 7, "world", 9.8 /*, and any number of other
                                  *  arguments as needed */);
---

$(P
There are four ways of defining variadic functions in D:
)

$(UL

$(LI $(IX _argptr) The feature that works only for functions that are marked as $(C extern(C)). This feature defines the hidden $(C _argptr) variable that is used for accessing the parameters. This book does not cover this feature partly because it is unsafe.)

$(LI $(IX _arguments) The feature that works with regular D functions, which also uses the hidden $(C _argptr) variable, as well as the $(C _arguments) variable, the latter being of type $(C TypeInfo[]). This book does not cover this feature as well both because it relies on $(I pointers), which have not been covered yet, and because this feature can be used in unsafe ways as well.)

$(LI A safe feature with the limitation that the unspecified number of parameters must all be of the same type. This is the feature that is covered in this section.)

$(LI Unspecified number of template parameters. This feature will be explained later in the templates chapters.)

)

$(P
$(IX ..., function parameter) The parameters of variadic functions are passed to the function as a slice. Variadic functions are defined with a single parameter of a specific type of slice followed immediately by the $(C ...) characters:
)

---
double sum(double[] numbers$(HILITE ...)) {
    double result = 0.0;

    foreach (number; numbers) {
        result += number;
    }

    return result;
}
---

$(P
That definition makes $(C sum()) a variadic function, meaning that it is able to receive any number of arguments as long as they are $(C double) or any other type that can implicitly be convertible to $(C double):
)

---
    writeln(sum($(HILITE 1.1, 2.2, 3.3)));
---

$(P
The single slice parameter and the $(C ...) characters represent all of the arguments. For example, the slice would have five elements if the function were called with five $(C double) values.
)

$(P
In fact, the variable number of parameters can also be passed as a single slice:
)

---
    writeln(sum($(HILITE [) 1.1, 2.2, 3.3 $(HILITE ])));    // same as above
---

$(P
Variadic functions can also have required parameters, which must be defined first in the parameter list. For example, the following function prints an unspecified number of parameters within parentheses. Although the function leaves the number of the elements flexible, it requires that the parentheses are always specified:
)

---
char[] parenthesize(
    string opening,  // ← The first two parameters must be
    string closing,  //   specified when the function is called
    string[] words...) {  // ← Need not be specified
    char[] result;

    foreach (word; words) {
        result ~= opening;
        result ~= word;
        result ~= closing;
    }

    return result;
}
---

$(P
The first two parameters are mandatory:
)

---
    parenthesize("{");     $(DERLEME_HATASI)
---

$(P
As long as the mandatory parameters are specified, the rest are optional:
)

---
    writeln(parenthesize("{", "}", "apple", "pear", "banana"));
---

$(P
The output:
)

$(SHELL
{apple}{pear}{banana}
)

$(H6 Variadic function arguments have a short lifetime)

$(P
The slice argument that is automatically generated for a variadic parameter points at a temporary array that has a short lifetime. This fact does not matter if the function uses the arguments only during its execution. However, it would be a bug if the function kept a slice to those elements for later use:
)

---
int[] numbersForLaterUse;

void foo(int[] numbers...) {
    numbersForLaterUse = numbers;    $(CODE_NOTE_WRONG BUG)
}

struct S {
    string[] namesForLaterUse;

    void foo(string[] names...) {
        namesForLaterUse = names;    $(CODE_NOTE_WRONG BUG)
    }
}

void bar() {
    foo(1, 10, 100);  /* The temporary array [ 1, 10, 100 ] is
                       * not valid beyond this point. */

    auto s = S();
    s.foo("hello", "world");  /* The temporary array
                               * [ "hello", "world" ] is not
                               * valid beyond this point. */

    // ...
}

void main() {
    bar();
}
---

$(P
Both the free-standing function $(C foo()) and the member function $(C S.foo()) are in error because they store slices to automatically-generated temporary arrays that live on the program stack. Those arrays are valid only during the execution of the variadic functions.
)

$(P
For that reason, if a function needs to store a slice to the elements of a variadic parameter, it must first take a copy of those elements:
)

---
void foo(int[] numbers...) {
    numbersForLaterUse = numbers$(HILITE .dup);    $(CODE_NOTE correct)
}

// ...

    void foo(string[] names...) {
        namesForLaterUse = names$(HILITE .dup);    $(CODE_NOTE correct)
    }
---

$(P
However, since variadic functions can also be called with slices of proper arrays, copying the elements would be unnecessary in those cases.
)

$(P
A solution that is both correct and efficient is to define two functions having the same name, one taking a variadic parameter and the other taking a proper slice. If the caller passes variable number of arguments, then the variadic version of the function is called; and if the caller passes a proper slice, then the version that takes a proper slice is called:
)

---
int[] numbersForLaterUse;

void foo(int[] numbers$(HILITE ...)) {
    /* Since this is the variadic version of foo(), we must
     * first take a copy of the elements before storing a
     * slice to them. */
    numbersForLaterUse = numbers$(HILITE .dup);
}

void foo(int[] numbers) {
    /* Since this is the non-variadic version of foo(), we can
     * store the slice as is. */
    numbersForLaterUse = numbers;
}

struct S {
    string[] namesForLaterUse;

    void foo(string[] names$(HILITE ...)) {
        /* Since this is the variadic version of S.foo(), we
         * must first take a copy of the elements before
         * storing a slice to them. */
        namesForLaterUse = names$(HILITE .dup);
    }

    void foo(string[] names) {
        /* Since this is the non-variadic version of S.foo(),
         * we can store the slice as is. */
        namesForLaterUse = names;
    }
}

void bar() {
    // This call is dispatched to the variadic function.
    foo(1, 10, 100);

    // This call is dispatched to the proper slice function.
    foo($(HILITE [) 2, 20, 200 $(HILITE ]));

    auto s = S();

    // This call is dispatched to the variadic function.
    s.foo("hello", "world");

    // This call is dispatched to the proper slice function.
    s.foo($(HILITE [) "hi", "moon" $(HILITE ]));

    // ...
}

void main() {
    bar();
}
---

$(P
Defining multiple functions with the same name but with different parameters is called $(I function overloading), which is the subject of the next chapter.
)

$(PROBLEM_TEK

$(P
Assume that the following $(C enum) is already defined:
)

---
enum Operation { add, subtract, multiply, divide }
---

$(P
Also assume that there is a $(C struct) that represents the calculation of an operation and its two operands:
)

---
struct Calculation {
    Operation op;
    double first;
    double second;
}
---

$(P
For example, the object $(C Calculation(Operation.divide, 7.7, 8.8)) would represent the division of 7.7 by 8.8.
)

$(P
Design a function that receives an unspecified number of these $(C struct) objects, calculates the result of each $(C Calculation), and then returns all of the results as a slice of type $(C double[]).
)

$(P
For example, it should be possible to call the function as in the following code:
)

---
void $(CODE_DONT_TEST)main() {
    writeln(
        calculate(Calculation(Operation.add, 1.1, 2.2),
                  Calculation(Operation.subtract, 3.3, 4.4),
                  Calculation(Operation.multiply, 5.5, 6.6),
                  Calculation(Operation.divide, 7.7, 8.8)));
}
---

$(P
The output of the code should be similar to the following:
)

$(SHELL
[3.3, -1.1, 36.3, 0.875]
)

)


Macros:
        TITLE=Variable Number of Parameters

        DESCRIPTION=Default values for function parameters; and the 'variadic function' feature that allows passing variable number of arguments to functions.

        KEYWORDS=d programming book tutorial struct
