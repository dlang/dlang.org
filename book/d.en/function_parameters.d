Ddoc

$(DERS_BOLUMU $(IX parameter) $(IX function parameter) Function Parameters)

$(P
This chapter covers various kinds of function parameters.
)

$(P
Some of the concepts of this chapter have already appeared earlier in the book. For example, the $(C ref) keyword that we saw in the $(LINK2 foreach.html, $(C foreach) Loop chapter) was making $(I actual elements) available in $(C foreach) loops as opposed to $(I copies) of those elements.
)

$(P
Additionally, we covered the $(C const) and $(C immutable) keywords and the differences between value types and reference types in previous chapters.
)

$(P
We have written functions that produced results by making use of their parameters. For example, the following function uses its parameters in a calculation:
)

---
double weightedAverage(double quizGrade, double finalGrade) {
    return quizGrade * 0.4 + finalGrade * 0.6;
}
---

$(P
That function calculates the average grade by taking 40% of the quiz grade and 60% of the final grade. Here is how it may be used:
)

---
    int quizGrade = 76;
    int finalGrade = 80;

    writefln("Weighted average: %2.0f",
             weightedAverage(quizGrade, finalGrade));
---

$(H5 $(IX pass-by copy) $(IX copy, parameter) Parameters are always copied)

$(P
In the code above, the two variables are passed as arguments to $(C weightedAverage()). The function $(I uses) its parameters. This fact may give the false impression that the function uses the actual variables that have been passed as arguments. In reality, what the function uses are $(I copies) of those variables.
)

$(P
This distinction is important because modifying a parameter changes only the copy. This can be seen in the following function that is trying to modify its parameter (i.e. making a side effect). Let's assume that the following function is written for reducing the energy of a game character:
)

---
void reduceEnergy(double energy) {
    energy /= 4;
}
---

$(P
Here is a program that tests $(C reduceEnergy()):
)

---
import std.stdio;

void reduceEnergy(double energy) {
    energy /= 4;
}

void main() {
    double energy = 100;

    reduceEnergy(energy);
    writeln("New energy: ", energy);
}
---

$(P
The output:
)

$(SHELL
New energy: 100     $(SHELL_NOTE_WRONG Not changed)
)

$(P
Although $(C reduceEnergy()) drops the value of its parameter to a quarter of its original value, the variable $(C energy) in $(C main()) does not change. The reason for this is that the $(C energy) variable in $(C main()) and the $(C energy) parameter of $(C reduceEnergy()) are separate; the parameter is a copy of the variable in $(C main()).
)

$(P
To observe this more closely, let's insert some $(C writeln()) expressions:
)

---
import std.stdio;

void reduceEnergy(double energy) {
    writeln("Entered the function      : ", energy);
    energy /= 4;
    writeln("Leaving the function      : ", energy);
}

void main() {
    double energy = 100;

    writeln("Calling the function      : ", energy);
    reduceEnergy(energy);
    writeln("Returned from the function: ", energy);
}
---

$(P
The output:
)

$(SHELL
Calling the function      : 100
Entered the function      : 100
Leaving the function      : 25   $(SHELL_NOTE the parameter changes,)
Returned from the function: 100  $(SHELL_NOTE the variable remains the same)
)

$(H5 $(IX pass-by reference) Referenced variables are not copied)

$(P
Even parameters of reference types like slices, associative arrays, and class variables are copied to functions. However, the original variables that are referenced (i.e. elements of slices and associative arrays, and class objects) are not copied. Effectively, such variables are passed to functions as $(I references): the parameter becomes another reference to the original object. It means that a modification made through the reference modifies the original object as well.
)

$(P
Being slices of characters, this applies to strings as well:
)

---
import std.stdio;

void makeFirstLetterDot(dchar[] str) {
    str[0] = '.';
}

void main() {
    dchar[] str = "abc"d.dup;
    makeFirstLetterDot(str);
    writeln(str);
}
---

$(P
The change made to the first element of the parameter affects the actual element in $(C main()):
)

$(SHELL
.bc
)

$(P
However, the original slice and associative array variables are still passed by copy. This may have surprising and seemingly unpredictable results unless the parameters are qualified as $(C ref) themselves.
)

$(H6 Surprising reference semantics of slices)

$(P
As we saw in the $(LINK2 slices.html, Slices and Other Array Features chapter), adding elements to a slice $(I may) terminate element sharing. Obviously, once sharing ends, a slice parameter like $(C str) above would not be a reference to the elements of the passed-in original variable anymore.
)

$(P
For example, the element that is appended by the following function will not be seen by the caller:
)

---
import std.stdio;

void appendZero(int[] arr) {
    arr $(HILITE ~= 0);
    writefln("Inside appendZero()       : %s", arr);
}

void main() {
    auto arr = [ 1, 2 ];
    appendZero(arr);
    writefln("After appendZero() returns: %s", arr);
}
---

$(P
The element is appended only to the function parameter, not to the original slice:
)

$(SHELL
Inside appendZero()       : [1, 2, 0]
After appendZero() returns: [1, 2]    $(SHELL_NOTE_WRONG No 0)
)

$(P
If the new elements need to be appended to the original slice, then the slice must be passed as $(C ref):
)

---
void appendZero($(HILITE ref) int[] arr) {
    // ...
}
---

$(P
The $(C ref) qualifier will be explained below.
)

$(H6 Surprising reference semantics of associative arrays)

$(P
Associative arrays that are passed as function parameters may cause surprises as well because associative arrays start their lives as $(C null), not empty.
)

$(P
In this context, $(C null) means an uninitialized associative array. Associative arrays are initialized automatically when their first key-value pair is added. As a consequence, if a function adds an element to a $(C null) associative array, then that element cannot be seen in the original variable because although the parameter is initialized, the original variable remains $(C null):
)

---
import std.stdio;

void appendElement(int[string] aa) {
    aa$(HILITE ["red"] = 100);
    writefln("Inside appendElement()       : %s", aa);
}

void main() {
    int[string] aa;    // ← null to begin with
    appendElement(aa);
    writefln("After appendElement() returns: %s", aa);
}
---

$(P
The original variable does not have the added element:
)

$(SHELL
Inside appendElement()       : ["red":100]
After appendElement() returns: []    $(SHELL_NOTE_WRONG Still null)
)

$(P
On the other hand, if the associative array were not $(C null) to begin with, then the added element would be seen by the caller as well:
)

---
    int[string] aa;
    aa["blue"] = 10;  // ← Not null before the call
    appendElement(aa);
---

$(P
This time the added element is seen by the caller:
)

$(SHELL
Inside appendElement()       : ["red":100, "blue":10]
After appendElement() returns: [$(HILITE "red":100), "blue":10]
)

$(P
For that reason, it may be better to pass the associative array as a $(C ref) parameter, which will be explained below.
)

$(H5 Parameter qualifiers)

$(P
Parameters are passed to functions according to the general rules described above:
)

$(UL

$(LI Value types are copied, after which the original variable and the copy are independent.)

$(LI Reference types are copied as well but both the original reference and the parameter provide access to the same variable.)

)

$(P
Those are the default rules that are applied when parameter definitions have no qualifiers. The following qualifiers change the way parameters are passed and what operations are allowed on them.
)

$(H6 $(IX in, parameter) $(C in))

$(P
We have seen that functions can produce values and can have side effects. The $(C in) keyword specifies that the parameter is going be used only as input:
)

---
import std.stdio;

double weightedTotal($(HILITE in) double currentTotal,
                     $(HILITE in) double weight,
                     $(HILITE in) double addend) {
    return currentTotal + (weight * addend);
}

void main() {
    writeln(weightedTotal(1.23, 4.56, 7.89));
}
---

$(P
Like $(C const), $(C in) parameters cannot be modified:
)

---
void foo(in int value) {
    value = 1;    $(DERLEME_HATASI)
}
---

$(H6 $(IX out, parameter) $(C out))

$(P
We know that functions return what they produce as their return values. The fact that there is only one return value is sometimes limiting as some functions may need to produce more than one result. ($(I $(B Note:) It is possible to return more than one result by defining the return type as a $(C Tuple) or a $(C struct). We will see these features in later chapters.))
)

$(P
The $(C out) keyword makes it possible for functions to return results through their parameters. When $(C out) parameters are modified within the function, those modifications affect the original variable that has been passed to the function. In a sense, the assigned value goes $(I out) of the function through the $(C out) parameter.
)

$(P
Let's have a look at a function that divides two numbers and produces both the quotient and the remainder. The return value is used for the quotient and the remainder is $(I returned) through the $(C out) parameter:
)

---
import std.stdio;

int divide(int dividend, int divisor, $(HILITE out) int remainder) {
    $(HILITE remainder = dividend % divisor);
    return dividend / divisor;
}

void main() {
    int remainder;
    int result = divide(7, 3, remainder);

    writeln("result: ", result, ", remainder: ", remainder);
}
---

$(P
Modifying the $(C remainder) parameter of the function modifies the $(C remainder) variable in $(C main()) (their names need not be the same):
)

$(SHELL
result: 2, remainder: 1
)

$(P
Regardless of their values at the call site, $(C out) parameters are first assigned to the $(C .init) value of their types automatically:
)

---
import std.stdio;

void foo(out int parameter) {
    writeln("After entering the function      : ", parameter);
}

void main() {
    int variable = 100;

    writeln("Before calling the function      : ", variable);
    foo(variable);
    writeln("After returning from the function: ", variable);
}
---

$(P
Even though there is no explicit assignment to the parameter in the function, the value of the parameter automatically becomes the initial value of $(C int), affecting the variable in $(C main()):
)

$(SHELL
Before calling the function      : 100
After entering the function      : 0  $(SHELL_NOTE the value of int.init)
After returning from the function: 0
)

$(P
As this demonstrates, $(C out) parameters cannot pass values into functions; they are strictly for passing values out of functions.
)

$(P
We will see in later chapters that returning $(C Tuple) or $(C struct) types are better alternatives to $(C out) parameters.
)

$(H6 $(IX const, parameter) $(C const))

$(P
As we saw earlier, $(C const) guarantees that the parameter will not be modified inside the function. It is helpful for the programmers to know that certain variables will not be changed by a function. $(C const) also makes functions more useful by allowing $(C const), $(C immutable), and $(I mutable) variables to be passed through that parameter:
)

---
import std.stdio;

dchar lastLetter($(HILITE const) dchar[] str) {
    return str[$ - 1];
}

void main() {
    writeln(lastLetter("constant"));
}
---

$(H6 $(IX immutable, parameter) $(C immutable))

$(P
As we saw earlier, $(C immutable) makes functions require that certain variables must be immutable. Because of such a requirement, the following function can only be called with strings with $(C immutable) elements (e.g. string literals):
)

---
import std.stdio;

dchar[] mix($(HILITE immutable) dchar[] first,
            $(HILITE immutable) dchar[] second) {
    dchar[] result;
    int i;

    for (i = 0; (i < first.length) && (i < second.length); ++i) {
        result ~= first[i];
        result ~= second[i];
    }

    result ~= first[i..$];
    result ~= second[i..$];

    return result;
}

void main() {
    writeln(mix("HELLO", "world"));
}
---

$(P
Since it forces a requirement on the parameter, $(C immutable) parameters should be used only when immutability is required. Otherwise, in general $(C const) is more useful because it accepts $(C immutable), $(C const), and $(I mutable) variables.
)

$(H6 $(IX ref, parameter) $(C ref))

$(P
This keyword allows passing a variable by reference even though it would normally be passed as a copy (i.e. by value).
)

$(P
For the $(C reduceEnergy()) function that we saw earlier to modify the original variable, it must take its parameter as $(C ref):
)

---
import std.stdio;

void reduceEnergy($(HILITE ref) double energy) {
    energy /= 4;
}

void main() {
    double energy = 100;

    reduceEnergy(energy);
    writeln("New energy: ", energy);
}
---

$(P
This time, the modification that is made to the parameter changes the original variable in $(C main()):
)

$(SHELL
New energy: 25
)

$(P
As can be seen, $(C ref) parameters can be used both as input and output. $(C ref) parameters can also be thought of as aliases of the original variables. The function parameter $(C energy) above is an alias of the variable $(C energy) in $(C main()).
)

$(P
Similar to $(C out) parameters, $(C ref) parameters allow functions to have side effects as well. In fact, $(C reduceEnergy()) does not return a value; it only causes a side effect through its single parameter.
)

$(P
The programming style called $(I functional programming) favors return values over side effects, so much so that some functional programming languages do not allow side effects at all. This is because functions that produce results $(I purely) through their return values are easier to understand, implement, and maintain.
)

$(P
The same function can be written in a functional programming style by returning the result, instead of causing a side effect. The parts of the program that changed are highlighted:
)

---
import std.stdio;

$(HILITE double reducedEnergy)(double energy) {
    $(HILITE return energy / 4);
}

void main() {
    double energy = 100;

    $(HILITE energy = reducedEnergy(energy));
    writeln("New energy: ", energy);
}
---

$(P
Note the change in the name of the function as well. Now it is a noun as opposed to a verb.
)

$(H6 $(C auto ref))

$(P
This qualifier can only be used with $(LINK2 templates.html, templates). As we will see in the next chapter, an $(C auto ref) parameter takes $(I lvalues) by reference and $(I rvalues) by copy.
)

$(H6 $(IX inout, parameter) $(C inout))

$(P
Despite its name consisting of $(C in) and $(C out), this keyword does not mean $(I input and output); we have already seen that input and output is achieved by the $(C ref) keyword.
)

$(P
$(C inout) carries the $(I mutability) of the parameter to the return type. If the parameter is $(C const), $(C immutable), or $(I mutable); then the return value is also $(C const), $(C immutable), or $(I mutable); respectively.
)

$(P
To see how $(C inout) helps in programs, let's look at a function that returns a slice to the $(I inner) elements of its parameter:
)

---
import std.stdio;

int[] inner(int[] slice) {
    if (slice.length) {
        --slice.length;               // trim from the end

        if (slice.length) {
            slice = slice[1 .. $];    // trim from the beginning
        }
    }

    return slice;
}

void main() {
    int[] numbers = [ 5, 6, 7, 8, 9 ];
    writeln(inner(numbers));
}
---

$(P
The output:
)

$(SHELL
[6, 7, 8]
)

$(P
According to what we have established so far in the book, in order for the function to be more useful, its parameter should be $(C const(int)[]) because the elements are not being modified inside the function. (Note that there is no harm in modifying the parameter slice itself, as it is a copy of the original variable.)
)

$(P
However, defining the function that way would cause a compilation error:
)

---
int[] inner($(HILITE const(int)[]) slice) {
    // ...
    return slice;    $(DERLEME_HATASI)
}
---

$(P
The compilation error indicates that a slice of $(C const(int)) cannot be returned as a slice of $(I mutable) $(C int):
)

$(SHELL
Error: cannot implicitly convert expression (slice) of type
const(int)[] to int[]
)

$(P
One may think that specifying the return type as $(C const(int)[]) would be the solution:
)

---
$(HILITE const(int)[]) inner(const(int)[] slice) {
    // ...
    return slice;    // now compiles
}
---

$(P
Although the code now compiles, it brings a limitation: even when the function is called with a slice of $(I mutable) elements, this time the returned slice ends up consisting of $(C const) elements. To see how limiting this would be, let's look at the following code, which tries to modify the inner elements of a slice:
)

---
    int[] numbers = [ 5, 6, 7, 8, 9 ];
    int[] middle = inner(numbers);    $(DERLEME_HATASI)
    middle[] *= 10;
---

$(P
The returned slice of type $(C const(int)[]) cannot be assigned to a slice of type $(C int[]), resulting in an error:
)

$(SHELL
Error: cannot implicitly convert expression (inner(numbers))
of type const(int)[] to int[]
)

$(P
However, since we started with a slice of mutable elements, this limitation is artificial and unfortunate. $(C inout) solves this mutability problem between parameters and return values. It is specified on both the parameter and the return type and carries the mutability of the former to the latter:
)

---
$(HILITE inout)(int)[] inner($(HILITE inout)(int)[] slice) {
    // ...
    return slice;
}
---

$(P
With that change, the same function can now be called with $(C const), $(C immutable), and $(I mutable) slices:
)

---
    {
        $(HILITE int[]) numbers = [ 5, 6, 7, 8, 9 ];
        // The return type is a slice of mutable elements
        $(HILITE int[]) middle = inner(numbers);
        middle[] *= 10;
        writeln(middle);
    }
    {
        $(HILITE immutable int[]) numbers = [ 10, 11, 12 ];
        // The return type is a slice of immutable elements
        $(HILITE immutable int[]) middle = inner(numbers);
        writeln(middle);
    }
    {
        $(HILITE const int[]) numbers = [ 13, 14, 15, 16 ];
        // The return type is a slice of const elements
        $(HILITE const int[]) middle = inner(numbers);
        writeln(middle);
    }
---

$(H6 $(IX lazy) $(C lazy))

$(P
It is natural to expect that arguments are evaluated $(I before) entering functions that use those arguments. For example, the function $(C add()) below is called with the return values of two other functions:
)

---
    result = add(anAmount(), anotherAmount());
---

$(P
In order for $(C add()) to be called, first $(C anAmount()) and $(C anotherAmount()) must be called. Otherwise, the values that $(C add()) needs would not be available.
)

$(P
Evaluating arguments before calling a function is called $(I eager evaluation).
)

$(P
However, depending on certain conditions, some parameters may not get a chance to be used in the function at all. In such cases, evaluating the arguments eagerly would be wasteful.
)

$(P
A classic example of this situation is a $(I logging) function that outputs a message only if the importance of the message is above a certain configuration setting:
)

---
enum Level { low, medium, high }

void log(Level level, string message) {
    if (level >= interestedLevel) {
        writeln(message);
    }
}
---

$(P
For example, if the user is interested only in the messages that are $(C Level.high), a message with $(C Level.medium) would not be printed. However, the argument would still be evaluated before calling the function. For example, the entire $(C format()) expression below including the $(C getConnectionState()) call that it makes would be wasted if the message is never printed:
)

---
    if (failedToConnect) {
        log(Level.medium,
            format("Failure. The connection state is '%s'.",
                   getConnectionState()));
    }
---

$(P
The $(C lazy) keyword specifies that an expression that is passed as a parameter will be evaluated only if and when needed:
)

---
void log(Level level, $(HILITE lazy) string message) {
   // ... the body of the function is the same as before ...
}
---

$(P
This time, the expression would be evaluated only if the $(C message) parameter is used.
)

$(P
One thing to be careful about is that a $(C lazy) parameter is evaluated $(I every time) that parameter is used in the function.
)

$(P
For example, because the $(C lazy) parameter of the following function is used three times in the function, the expression that provides its value is evaluated three times:
)

---
import std.stdio;

int valueOfArgument() {
    writeln("Calculating...");
    return 1;
}

void functionWithLazyParameter(lazy int value) {
    int result = $(HILITE value + value + value);
    writeln(result);
}

void main() {
    functionWithLazyParameter(valueOfArgument());
}
---

$(P
The output:
)

$(SHELL
Calculating
Calculating
Calculating
3
)

$(H6 $(IX scope) $(C scope))

$(P
$(IX DIP) $(IX -dip1000) This keyword specifies that a parameter will not be used beyond the scope of the function. As of this writing, $(C scope) is effective only if the function is defined as $(LINK2 functions_more.html, $(C @safe)) and if $(C -dip1000) compiler switch is used. DIP is short for $(I D Improvement Proposal). DIP 1000 is experimental as of this writing; so it may not work as expected in all cases.
)

$(SHELL
$(SHELL_OBSERVED $) dmd -dip1000 deneme.d
)

---
int[] globalSlice;

$(HILITE @safe) int[] foo($(HILITE scope) int[] parameter) {
    globalSlice = parameter;    $(DERLEME_HATASI)
    return parameter;           $(DERLEME_HATASI)
}

void main() {
    int[] slice = [ 10, 20 ];
    int[] result = foo(slice);
}
---

$(P
The function above violates the promise of $(C scope) in two places: It assigns the parameter to a global variable, and it returns it. Both those actions would make it possible for the parameter to be accessed after the function finishes.
)

$(H6 $(IX shared, parameter) $(C shared))

$(P
This keyword requires that the parameter is shareable between threads of execution:
)

---
void foo($(HILITE shared) int[] i) {
    // ...
}

void main() {
    int[] numbers = [ 10, 20 ];
    foo(numbers);    $(DERLEME_HATASI)
}
---

$(P
The program above cannot be compiled because the argument is not $(C shared). The following is the necessary change to make it compile:
)

---
    $(HILITE shared) int[] numbers = [ 10, 20 ];
    foo(numbers);    // now compiles
---

$(P
We will see the $(C shared) keyword later in the $(LINK2 concurrency_shared.html, Data Sharing Concurrency chapter).
)

$(H6 $(IX return, parameter) $(C return))

$(P
Sometimes it is useful for a function to return one of its $(C ref) parameters directly. For example, the following $(C pick()) function picks and returns one of its parameters randomly so that the caller can mutate the lucky one directly:
)

---
import std.stdio;
import std.random;

$(HILITE ref) int pick($(HILITE ref) int lhs, $(HILITE ref) int rhs) {
    return uniform(0, 2) ? lhs : rhs;    $(DERLEME_HATASI)
}

void main() {
    int a;
    int b;

    pick(a, b) $(HILITE = 42);

    writefln("a: %s, b: %s", a, b);
}
---

$(P
As a result, either $(C a) or $(C b) inside $(C main()) is assigned the value $(C 42):
)

$(SHELL
a: 42, b: 0
)

$(SHELL
a: 0, b: 42
)

$(P
Unfortunately, one of the arguments of $(C pick()) may have a shorter lifetime than the returned reference. For example, the following $(C foo()) function calls $(C pick()) with two local variables, effectively itself returning a reference to one of them:
)

---
import std.random;

ref int pick(ref int lhs, ref int rhs) {
    return uniform(0, 2) ? lhs : rhs;    $(DERLEME_HATASI)
}

ref int foo() {
    int a;
    int b;

    return pick(a, b);    $(CODE_NOTE_WRONG BUG: returning invalid reference)
}

void main() {
    foo() = 42;           $(CODE_NOTE_WRONG BUG: writing to invalid memory)
}
---

$(P
Since the lifetimes of both $(C a) and $(C b) end upon leaving $(C foo()), the assignment in $(C main()) cannot be made to a valid variable. This results in $(I undefined behavior).
)

$(P
$(IX undefined behavior) The term $(I undefined behavior) describes situations where the behavior of the program is not defined by the programming language specification. Nothing can be said about the behavior of a program that contains undefined behavior. (In practice though, for the program above, the value $(C 42) would most likely be written to a memory location that used to be occupied by either $(C a) or $(C b), potentially currently a part of an unrelated variable, effectively corrupting the value of that unrelated variable.)
)

$(P
The $(C return) keyword can be applied to a parameter to prevent such bugs. It specifies that a parameter must be a reference to a variable with a longer lifetime than the returned reference:
)

---
import std.random;

ref int pick($(HILITE return) ref int lhs, $(HILITE return) ref int rhs) {
    return uniform(0, 2) ? lhs : rhs;
}

ref int foo() {
    int a;
    int b;

    return pick(a, b);    $(DERLEME_HATASI)
}

void main() {
    foo() = 42;
}
---

$(P
This time the compiler sees that the arguments to $(C pick()) have a shorter lifetime than the reference that $(C foo()) is attempting to return:
)

$(SHELL
Error: escaping reference to local variable a
Error: escaping reference to local variable b
)

$(P
$(IX sealed reference) $(IX reference, sealed) This feature is called $(I sealed references).
)

$(P
$(I $(B Note:) Although it is conceivable that the compiler could inspect $(C pick()) and detect the bug even without the $(C return) keyword, it cannot do so in general because the bodies of some functions may not be available to the compiler during every compilation.)
)

$(H5 Summary)

$(UL

$(LI A $(I parameter) is what the function takes from its caller to accomplish its task.)

$(LI An $(I argument) is an expression (e.g. a variable) that is passed to a function as a parameter.)

$(LI
Every argument is passed by copy. However, for reference types, it is the reference that is copied, not the original variable.
)

$(LI $(C in) specifies that the parameter is used only for data input.)

$(LI $(C out) specifies that the parameter is used only for data output.)

$(LI $(C ref) specifies that the parameter is used for data input and data output.)

$(LI $(C auto ref) is used in templates only. It specifies that if the argument is an lvalue, then a reference to it is passed; if the argument is an rvalue, then it is passed by copy.)

$(LI $(C const) guarantees that the parameter is not modified inside the function. (Remember that $(C const) is transitive: any data reached through a $(C const) variable is $(C const) as well.))

$(LI $(C immutable) requires the argument to be $(C immutable).)

$(LI $(C inout) appears both at the parameter and the return type, and transfers the $(I mutability) of the parameter to the return type.)

$(LI $(C lazy) is used to make a parameter be evaluated when (and every time) it is actually used.)

$(LI $(C scope) guarantees that no reference to the parameter will be leaked from the function.)

$(LI $(C shared) requires the parameter to be $(C shared).)

$(LI $(C return) on a parameter requires the parameter to live longer than the returned reference.)

)

$(PROBLEM_TEK

$(P
The following program is trying to swap the values of two arguments:
)

---
import std.stdio;

void swap(int first, int second) {
    int temp = first;
    first = second;
    second = temp;
}

void main() {
    int a = 1;
    int b = 2;

    swap(a, b);

    writeln(a, ' ', b);
}
---

$(P
However, the program does not have any effect on $(C a) or $(C b):
)

$(SHELL
1 2          $(SHELL_NOTE_WRONG not swapped)
)

$(P
Fix the function so that the values of $(C a) and $(C b) are swapped.
)

)

Macros:
        TITLE=Function Parameters

        DESCRIPTION=Kinds of function parameters in the D programmning language.

        KEYWORDS=d programming language tutorial book in out inout ref lazy const immutable scope shared
