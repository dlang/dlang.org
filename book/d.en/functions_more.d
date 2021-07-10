Ddoc

$(DERS_BOLUMU More Functions)

$(P
Functions have been covered in the following chapters so far in the book:
)

$(UL
$(LI $(LINK2 functions.html, Functions))

$(LI $(LINK2 function_parameters.html, Function Parameters))

$(LI $(LINK2 function_overloading.html, Function Overloading))

$(LI $(LINK2 lambda.html, Function Pointers, Delegates, and Lambdas))

)

$(P
This chapter will cover more features of functions.
)

$(H5 Return type attributes)

$(P
Functions can be marked as $(C auto), $(C ref), $(C inout), and $(C auto ref). These attributes are about return types of functions.
)

$(H6 $(IX auto, return type) $(IX auto function) $(C auto) functions)

$(P
The return types of $(C auto) functions need not be specified:
)

---
$(HILITE auto) add(int first, double second) {
    double result = first + second;
    return result;
}
---

$(P
The return type is deduced by the compiler from the $(C return) expression. Since the type of $(C result) is $(C double), the return type of $(C add()) is $(C double).
)

$(P
If there are more than one $(C return) statement, then the return type of the function is their $(I common type). (We have seen common type in $(LINK2 ternary.html, the Ternary Operator ?: chapter).) For example, because the common type of $(C int) and $(C double) is $(C double), the return type of the following $(C auto) function is $(C double) as well:
)

---
auto func(int i) {
    if (i < 0) {
        return i;      // returns 'int' here
    }

    return i * 1.5;    // returns 'double' here
}

void main() {
    // The return type of the function is 'double'
    auto result = func(42);
    static assert(is (typeof(result) == $(HILITE double)));
}
---

$(H6 $(IX ref, return type) $(C ref) functions)

$(P
Normally, the expression that is returned from a function is copied to the caller's context. $(C ref) specifies that the expression should be returned by-reference instead.
)

$(P
For example, the following function returns the greater of its two parameters:
)

---
$(CODE_NAME greater)int greater(int first, int second) {
    return (first > second) ? first : second;
}
---

$(P
Normally, both the parameters and the return value of that function are copied:
)

---
$(CODE_XREF greater)import std.stdio;

void main() {
    int a = 1;
    int b = 2;
    int result = greater(a, b);
    result += 10;                // ← neither a nor b changes
    writefln("a: %s, b: %s, result: %s", a, b, result);
}
---

$(P
Because the return value of $(C greater()) is copied to $(C result), adding to $(C result) affects only that variable; neither $(C a) nor $(C b) changes:
)

$(SHELL_SMALL
a: 1, b: 2, result: 12
)

$(P
$(C ref) parameters are passed by references instead of being copied. The same keyword has the same effect on return values:
)

---
$(HILITE ref) int greater($(HILITE ref) int first, $(HILITE ref) int second) {
    return (first > second) ? first : second;
}
---

$(P
This time, the returned reference would be an alias to one of the arguments and mutating the returned reference would modify either $(C a) or $(C b):
)

---
    int a = 1;
    int b = 2;
    greater(a, b) += 10;         // ← either a or b changes
    writefln("a: %s, b: %s", a, b);
---

$(P
Note that the returned reference is incremented directly. As a result, the greater of the two arguments changes:
)

$(SHELL_SMALL
a: 1, b: $(HILITE 12)
)

$(P
$(IX pointer) $(IX local variable) $(IX variable, local) $(B Local reference requires a pointer:) An important point is that although the return type is marked as $(C ref), $(C a) and $(C b) would still not change if the return value were assigned to a local variable:
)

---
    int result = greater(a, b);
    result += 10;                // ← only result changes
---

$(P
Although $(C greater()) returns a reference to $(C a) or $(C b), that reference gets copied to the local variable $(C result), and again neither $(C a) nor $(C b) changes:
)

$(SHELL_SMALL
a: 1, b: 2, result: 12
)

$(P
For $(C result) be a reference to $(C a) or $(C b), it has to be defined as a pointer:
)

---
    int $(HILITE *) result = $(HILITE &)greater(a, b);
    $(HILITE *)result += 10;
    writefln("a: %s, b: %s, result: %s", a, b, $(HILITE *)result);
---

$(P
This time $(C result) would be a reference to either $(C a) or $(C b) and the mutation through it would affect the actual variable:
)

$(SHELL_SMALL
a: 1, b: $(HILITE 12), result: 12
)

$(P
$(B It is not possible to return a reference to a local variable:) The $(C ref) return value is an alias to one of the arguments that start their lives even before the function is called. That means, regardless of whether a reference to $(C a) or $(C b) is returned, the returned reference refers to a variable that is still alive.
)

$(P
Conversely, it is not possible to return a reference to a variable that is not going to be alive upon leaving the function:
)

---
$(HILITE ref) string parenthesized(string phrase) {
    string result = '(' ~ phrase ~ ')';
    return result;    $(DERLEME_HATASI)
} // ← the lifetime of result ends here
---

$(P
The lifetime of local $(C result) ends upon leaving the function. For that reason, it is not possible to return a reference to that variable:
)

$(SHELL_SMALL
Error: escaping $(HILITE reference to local variable) result
)

$(H6 $(IX auto ref, return type) $(C auto ref) functions)

$(P
$(C auto ref) helps with functions like $(C parenthesized()) above. Similar to $(C auto), the return type of an $(C auto ref) function is deduced by the compiler. Additionally, if the returned expression can be a reference, that variable is returned by reference as opposed to being copied.
)

$(P
$(C parenthesized()) can be compiled if the return type is $(C auto ref):
)

---
$(HILITE auto ref) string parenthesized(string phrase) {
    string result = '(' ~ phrase ~ ')';
    return result;                  // ← compiles
}
---

$(P
The very first $(C return) statement of the function determines whether the function returns a copy or a reference.
)

$(P
$(C auto ref) is more useful in function templates where template parameters may be references or copies depending on context.
)

$(H6 $(IX inout, return type) $(C inout) functions)

$(P
The $(C inout) keyword appears for parameter and return types of functions. It works like a template for $(C const), $(C immutable), and $(I mutable).
)

$(P
Let's rewrite the previous function as taking $(C string) (i.e. $(C immutable(char)[])) and returning $(C string):
)

---
string parenthesized(string phrase) {
    return '(' ~ phrase ~ ')';
}

// ...

    writeln(parenthesized("hello"));
---

$(P
As expected, the code works with that $(C string) argument:
)

$(SHELL_SMALL
(hello)
)

$(P
However, as it works only with $(C immutable) strings, the function can be seen as being less useful than it could have been:
)

---
    char[] m;    // has mutable elements
    m ~= "hello";
    writeln(parenthesized(m));    $(DERLEME_HATASI)
---

$(SHELL_SMALL
Error: function deneme.parenthesized ($(HILITE string) phrase)
is not callable using argument types ($(HILITE char[]))
)

$(P
The same limitation applies to $(C const(char)[]) strings as well.
)

$(P
One solution for this usability issue is to overload the function for $(C const) and $(I mutable) strings:
)

---
char[] parenthesized(char[] phrase) {
    return '(' ~ phrase ~ ')';
}

const(char)[] parenthesized(const(char)[] phrase) {
    return '(' ~ phrase ~ ')';
}
---

$(P
That design would be less than ideal due to the obvious code duplications. Another solution would be to define the function as a template:
)

---
T parenthesized(T)(T phrase) {
    return '(' ~ phrase ~ ')';
}
---

$(P
Although that would work, this time it may be seen as being too flexible and potentially requiring template constraints.
)

$(P
$(C inout) is very similar to the template solution. The difference is that not the entire type but just the mutability attribute is deduced from the parameter:
)

---
$(HILITE inout)(char)[] parenthesized($(HILITE inout)(char)[] phrase) {
    return '(' ~ phrase ~ ')';
}
---

$(P
$(C inout) transfers the deduced mutability attribute to the return type.
)

$(P
When the function is called with  $(C char[]), it gets compiled as if $(C inout) is not specified at all. On the other hand, when called with $(C immutable(char)[]) or $(C const(char)[]), $(C inout) means $(C immutable) or $(C const), respectively.
)

$(P
The following code demonstrates this by printing the type of the returned expression:
)

---
    char[] m;
    writeln(typeof(parenthesized(m)).stringof);

    const(char)[] c;
    writeln(typeof(parenthesized(c)).stringof);

    immutable(char)[] i;
    writeln(typeof(parenthesized(i)).stringof);
---

$(P
The output:
)

$(SHELL_SMALL
char[]
const(char)[]
string
)

$(H5 Behavioral attributes)

$(P
$(C pure), $(C nothrow), and $(C @nogc) are about function behaviors.
)

$(H6 $(IX pure) $(C pure) functions)

$(P
As we have seen in $(LINK2 functions.html, the Functions chapter), functions can produce return values and side effects. When possible, return values should be preferred over side effects because functions that do not have side effects are easier to make sense of, which in turn helps with program correctness and maintainability.
)

$(P
A similar concept is the purity of a function. Purity is defined differently in D from most other programming languages: In D, a function that does not access $(I mutable) global or $(C static) state is pure. (Since input and output streams are considered as mutable global state, pure functions cannot perform input or output operations either.)
)

$(P
In other words, a function is pure if it produces its return value and side effects only by accessing its parameters, local variables, and $(I immutable) global state.
)

$(P
An important aspect of purity in D is that pure functions can mutate their parameters.
)

$(P
Additionally, the following operations that mutate the global state of the program are explicitly allowed in pure functions:
)

$(UL
$(LI Allocate memory with the $(C new) expression)
$(LI Terminate the program)
$(LI Access the floating point processing flags)
$(LI Throw exceptions)
)

$(P
The $(C pure) keyword specifies that a function should behave according to those conditions and the compiler guarantees that it does so.
)

$(P
Naturally, since impure functions do not provide the same guarantees, a pure function cannot call impure functions.
)

$(P
The following program demonstrates some of the operations that a pure function can and cannot perform:
)

---
import std.stdio;
import std.exception;

int mutableGlobal;
const int constGlobal;
immutable int immutableGlobal;

void impureFunction() {
}

int pureFunction(ref int i, int[] slice) $(HILITE pure) {
    // Can throw exceptions:
    enforce(slice.length >= 1);

    // Can mutate its parameters:
    i = 42;
    slice[0] = 43;

    // Can access immutable global state:
    i = constGlobal;
    i = immutableGlobal;

    // Can use the new expression:
    auto p = new int;

    // Cannot access mutable global state:
    i = mutableGlobal;    $(DERLEME_HATASI)

    // Cannot perform input and output operations:
    writeln(i);           $(DERLEME_HATASI)

    static int mutableStatic;

    // Cannot access mutable static state:
    i = mutableStatic;    $(DERLEME_HATASI)

    // Cannot call impure functions:
    impureFunction();     $(DERLEME_HATASI)

    return 0;
}

void main() {
    int i;
    int[] slice = [ 1 ];
    pureFunction(i, slice);
}
---

$(P
Although they are allowed to, some pure functions do not mutate their parameters. Following from the rules of purity, the only observable effect of such a function would be its return value. Further, since the function cannot access any mutable global state, the return value would be the same for a given set of arguments, regardless of when and how many times the function is called during the execution of the program. This fact gives both the compiler and the programmer optimization opportunities. For example, instead of calling the function a second time for a given set of arguments, its return value from the first call can be cached and used instead of actually calling the function again.
)

$(P
$(IX inference, pure attribute) $(IX attribute inference, pure) Since the exact code that gets generated for a template instantiation depends on the actual template arguments, whether the generated code is pure depends on the arguments as well. For that reason, the purity of a template is inferred by the compiler from the generated code. (The $(C pure) keyword can still be specified by the programmer.) Similarly, the purity of an $(C auto) function is inferred.
)

$(P
As a simple example, since the following function template would be impure when $(C N) is zero, it would not be possible to call $(C templ!0()) from a pure function:
)

---
import std.stdio;

// This template is impure when N is zero
void templ(size_t N)() {
    static if (N == 0) {
        // Prints when N is zero:
        writeln("zero");
    }
}

void foo() $(HILITE pure) {
    templ!0();    $(DERLEME_HATASI)
}

void main() {
    foo();
}
---

$(P
The compiler infers that the $(C 0) instantiation of the template is impure and rejects calling it from the pure function $(C foo()):
)

$(SHELL_SMALL
Error: pure function 'deneme.foo' $(HILITE cannot call impure function)
'deneme.templ!0.templ'
)

$(P
However, since the instantiation of the template for values other than zero is pure, the program can be compiled for such values:
)

---
void foo() $(HILITE pure) {
    templ!1();    // ← compiles
}
---

$(P
We have seen earlier above that input and output functions like $(C writeln()) cannot be used in pure functions because they access global state. Sometimes such limitations are too restrictive e.g. when needing to print a message temporarily during debugging. For that reason, the purity rules are relaxed for code that is marked as $(C debug):
)

---
import std.stdio;

debug size_t fooCounter;

void foo(int i) $(HILITE pure) {
    $(HILITE debug) ++fooCounter;

    if (i == 0) {
        $(HILITE debug) writeln("i is zero");
        i = 42;
    }

    // ...
}

void main() {
    foreach (i; 0..100) {
        if ((i % 10) == 0) {
            foo(i);
        }
    }

    debug writefln("foo is called %s times", fooCounter);
}
---

$(P
The pure function above mutates the global state of the program by modifying a global variable and printing a message. Despite those impure operations, it still can be compiled because those operations are marked as $(C debug).
)

$(P
$(I $(B Note:) Remember that those statements are included in the program only if the program is compiled with the $(C -debug) command line switch.)
)

$(P
Member functions can be marked as $(C pure) as well. Subclasses can override impure functions as $(C pure) but the reverse is not allowed:
)

---
interface Iface {
    void foo() pure;    // Subclasses must define foo as pure.

    void bar();         // Subclasses may define bar as pure.
}

class Class : Iface {
    void foo() pure {   // Required to be pure
        // ...
    }

    void bar() pure {   // pure although not required
        // ...
    }
}
---

$(P
Delegates and anonymous functions can be pure as well. Similar to templates, whether a function or delegate literal, or $(C auto) function is pure is inferred by the compiler:
)

---
import std.stdio;

void foo(int delegate(double) $(HILITE pure) dg) {
    int i = dg(1.5);
}

void main() {
    foo(a => 42);                // ← compiles

    foo((a) {                    $(DERLEME_HATASI)
            writeln("hello");
            return 42;
        });
}
---

$(P
$(C foo()) above requires that its parameter be a pure delegate. The compiler infers that the lambda $(C a&nbsp;=>&nbsp;42) is pure and allows it as an argument for $(C foo()). However, since the other delegate is impure it cannot be passed to $(C foo()):
)

$(SHELL_SMALL
Error: function deneme.foo (int delegate(double) $(HILITE pure) dg)
is $(HILITE not callable) using argument types (void)
)

$(P
One benefit of $(C pure) functions is that their return values can be used to initialize $(C immutable) variables. Although the array produced by $(C makeNumbers()) below is mutable, it is not possible for its elements to be changed by any code outside of that function. For that reason, the initialization works.
)

---
int[] makeNumbers() pure {
    int[] result;
    result ~= 42;
    return result;
}

void main() {
    $(HILITE immutable) array = makeNumbers();
}
---

$(H6 $(IX nothrow) $(IX throw) $(C nothrow) functions)

$(P
We saw the exception mechanism in $(LINK2 exceptions.html, the Exceptions chapter.)
)

$(P
It would be good practice for functions to document the types of exceptions that they may throw under specific error conditions. However, as a general rule, callers should assume that any function can throw any exception.
)

$(P
Sometimes it is more important to know that a function does not emit any exception at all. For example, some algorithms can take advantage of the fact that certain of their steps cannot be interrupted by an exception.
)

$(P
$(C nothrow) guarantees that a function does not emit any exception:
)

---
int add(int lhs, int rhs) $(HILITE nothrow) {
    // ...
}
---

$(P
$(I $(B Note:) Remember that it is not recommended to catch $(C Error) nor its base class $(C Throwable). What is meant here by "any exception" is "any exception that is defined under the $(C Exception) hierarchy." A $(C nothrow) function can still emit exceptions that are under the $(C Error) hierarchy, which represents irrecoverable error conditions that should preclude the program from continuing its execution.)
)

$(P
Such a function can neither throw an exception itself nor can call a function that may throw an exception:
)

---
int add(int lhs, int rhs) nothrow {
    writeln("adding");    $(DERLEME_HATASI)
    return lhs + rhs;
}
---

$(P
The compiler rejects the code because $(C add()) violates the no-throw guarantee:
)

$(SHELL_SMALL
Error: function 'deneme.add' is nothrow yet $(HILITE may throw)
)

$(P
This is because $(C writeln) is not (and cannot be) a $(C nothrow) function.
)

$(P
$(IX inference, nothrow attribute) $(IX attribute inference, nothrow) The compiler can infer that a function can never emit an exception. The following implementation of $(C add()) is $(C nothrow) because it is obvious to the compiler that the $(C try-catch) block prevents any exception from escaping the function:
)

---
int add(int lhs, int rhs) nothrow {
    int result;

    try {
        writeln("adding");    // ← compiles
        result = lhs + rhs;

    } catch (Exception error) {   // catches all exceptions
        // ...
    }

    return result;
}
---

$(P
As mentioned above, $(C nothrow) does not include exceptions that are under the $(C Error) hierarchy. For example, although accessing an element of an array with $(C []) can throw $(C RangeError), the following function can still be defined as $(C nothrow):
)

---
int foo(int[] arr, size_t i) $(HILITE nothrow) {
    return 10 * arr$(HILITE [i]);
}
---

$(P
As with purity, the compiler automatically deduces whether a template, delegate, or anonymous function is $(C nothrow).
)

$(H6 $(IX @nogc) $(C @nogc) functions)

$(P
D is a garbage collected language. Many data structures and algorithms in most D programs take advantage of dynamic memory blocks that are managed by the garbage collector (GC). Such memory blocks are reclaimed again by the GC by an algorithm called $(I garbage collection).
)

$(P
Some commonly used D operations take advantage of the GC as well. For example, elements of arrays live on dynamic memory blocks:
)

---
// A function that takes advantage of the GC indirectly
int[] append(int[] slice) {
    slice $(HILITE ~=) 42;
    return slice;
}
---

$(P
If the slice does not have sufficient capacity, the $(C ~=) operator above allocates a new memory block from the GC.
)

$(P
Although the GC is a significant convenience for data structures and algorithms, memory allocation and garbage collection are costly operations that make the execution of some programs noticeably slow.
)

$(P
$(C @nogc) means that a function cannot use the GC directly or indirectly:
)

---
void foo() $(HILITE @nogc) {
    // ...
}
---

$(P
The compiler guarantees that a $(C @nogc) function does not involve GC operations. For example, the following function cannot call $(C append()) above, which does not provide the $(C @nogc) guarantee:
)

---
void foo() $(HILITE @nogc) {
    int[] slice;
    // ...
    append(slice);    $(DERLEME_HATASI)
}
---

$(SHELL_SMALL
Error: @nogc function 'deneme.foo' $(HILITE cannot call non-@nogc function)
'deneme.append'
)

$(H5 Code safety attributes)

$(P
$(IX inference, @safe attribute) $(IX attribute inference, @safe) $(C @safe), $(C @trusted), and $(C @system) are about the code safety that a function provides. As with purity, the compiler infers the safety level of templates, delegates, anonymous functions, and $(C auto) functions.
)

$(H6 $(IX @safe) $(C @safe) functions)

$(P
A class of programming errors involve $(I corrupting) data at unrelated locations in memory by writing at those locations unintentionally. Such errors are mostly due to mistakes made in using pointers and applying type casts.
)

$(P
$(C @safe) functions guarantee that they do not contain any operation that may corrupt memory. The compiler does not allow the following operations in $(C @safe) functions:
)

$(UL

$(LI Pointers cannot be converted to other pointer types other than $(C void*).)

$(LI A non-pointer expression cannot be converted to a pointer value.)

$(LI Pointer values cannot be changed (no pointer $(I arithmetic); however, assigning a pointer to another pointer of the same type is safe).)

$(LI Unions that have pointer or reference members cannot be used.)

$(LI Functions marked as $(C @system) cannot be called.)

$(LI Exceptions that are not descended from $(C Exception) cannot be caught.)

$(LI $(I Inline assembler) cannot be used.)

$(LI $(I Mutable) variables cannot be cast to $(C immutable).)

$(LI $(C immutable) variables cannot be cast to $(I mutable).)

$(LI Thread-local variables cannot be cast to $(C shared).)

$(LI $(C shared) variables cannot be cast to thread-local.)

$(LI Addresses of function-local variables cannot be taken.)

$(LI $(C __gshared) variables cannot be accessed.)

)

$(H6 $(IX @trusted) $(C @trusted) functions)

$(P
Some functions may actually be safe but cannot be marked as $(C @safe) for various reasons. For example, a function may have to call a library written in C, where no language support exists for safety in that language.
)

$(P
Some other functions may actually perform operations that are not allowed in $(C @safe) code, but may be well tested and $(I trusted) to be correct.
)

$(P
$(C @trusted) is an attribute that communicates to the compiler that $(I although the function cannot be marked as $(C @safe), consider it safe). The compiler trusts the programmer and treats $(C @trusted) code as if it is safe. For example, it allows $(C @safe) code to call $(C @trusted) code.
)

$(H6 $(IX @system) $(C @system) functions)

$(P
Any function that is not marked as $(C @safe) or $(C @trusted) is considered $(C @system), which is the default safety attribute.
)

$(H5 $(IX CTFE) $(IX compile time function execution) Compile time function execution (CTFE))

$(P
In many programming languages, computations that are performed at compile time are very limited. Such computations are usually as simple as calculating the length of a fixed-length array or simple arithmetic operations:
)

---
    writeln(1 + 2);
---

$(P
The $(C 1&nbsp;+&nbsp;2) expression above is compiled as if it has been written as $(C 3); there is no computation at runtime.
)

$(P
D has CTFE, which allows any function to be executed at compile time as long as it is possible to do so.
)

$(P
Let's consider the following program that prints a menu to the output:
)

---
import std.stdio;
import std.string;
import std.range;

string menuLines(string[] choices) {
    string result;

    foreach (i, choice; choices) {
        result ~= format(" %s. %s\n", i + 1, choice);
    }

    return result;
}

string menu(string title,
            string[] choices,
            size_t width) {
    return format("%s\n%s\n%s",
                  title.center(width),
                  '='.repeat(width),    // horizontal line
                  menuLines(choices));
}

void main() {
    $(HILITE enum) drinks =
        menu("Drinks",
             [ "Coffee", "Tea", "Hot chocolate" ], 20);

    writeln(drinks);
}
---

$(P
Although the same result can be achieved in different ways, the program above performs non-trivial operations to produce the following $(C string):
)

$(SHELL_SMALL
       Drinks       
====================
 1. Coffee
 2. Tea
 3. Hot chocolate
)

$(P
Remember that the initial value of $(C enum) constants like $(C drinks) must be known at compile time. That fact is sufficient for $(C menu()) to be executed at compile time. The value that it returns at compile time is used as the initial value of $(C drinks). As a result, the program is compiled as if that value is written explicitly in the program:
)

---
    // The equivalent of the code above:
    enum drinks = "       Drinks       \n"
                  "====================\n"
                  " 1. Coffee\n"
                  " 2. Tea\n"
                  " 3. Hot chocolate\n";
---

$(P
For a function to be executed at compile time, it must appear in an expression that in fact is needed at compile time:
)

$(UL
$(LI Initializing a $(C static) variable)
$(LI Initializing an $(C enum) variable)
$(LI Calculating the length of a fixed-length array)
$(LI Calculating a template $(I value) argument)
)

$(P
Clearly, it would not be possible to execute every function at compile time. For example, a function that accesses a global variable cannot be executed at compile time because the global variable does not start its life until run time. Similarly, since $(C stdout) is available only at run time, functions that print cannot be executed at compile time.
)

$(H6 $(IX __ctfe) The $(C __ctfe) variable)

$(P
It is a powerful aspect of CTFE that the same function is used for both compile time and run time depending on when its result is needed. Although the function need not be written in any special way for CTFE, some operations in the function may make sense only at compile time or run time. The special variable $(C __ctfe) can be used to differentiate the code that are only for compile time or only for run time. The value of this variable is $(C true) when the function is being executed for CTFE, $(C false) otherwise:
)

---
import std.stdio;

size_t counter;

int foo() {
    if (!$(HILITE __ctfe)) {
        // This code is for execution at run time
        ++counter;
    }

    return 42;
}

void main() {
    enum i = foo();
    auto j = foo();
    writefln("foo is called %s times.", counter);
}
---

$(P
As $(C counter) lives only at run time, it cannot be incremented at compile time. For that reason, the code above attempts to increment it only for run-time execution. Since the value of $(C i) is determined at compile time and the value of $(C j) is determined at run time, $(C foo()) is reported to have been called just once during the execution of the program:
)

$(SHELL_SMALL
foo is called 1 times.
)

$(H5 Summary)

$(UL

$(LI The return type of an $(C auto) function is deduced automatically.)

$(LI The return value of a $(C ref) function is a reference to an existing variable.)

$(LI The return value of an $(C auto ref) function is a reference if possible, a copy otherwise.)

$(LI $(C inout) carries the $(C const), $(C immutable), or $(I mutable) attribute of the parameter to the return type.)

$(LI A $(C pure) function cannot access $(I mutable) global or static state. The compiler infers the purity of templates, delegates, anonymous functions, and $(C auto) functions.)

$(LI $(C nothrow) functions cannot emit exceptions. The compiler infers whether a template, delegate, anonymous function, or $(C auto) function is no-throw.)

$(LI $(C @nogc) functions cannot involve GC operations.)

$(LI $(C @safe) functions cannot corrupt memory. The compiler infers the safety attributes of templates, delegates, anonymous functions, and $(C auto) functions.)

$(LI $(C @trusted) functions are indeed safe but cannot be specified as such; they are considered $(C @safe) both by the programmer and the compiler.)

$(LI $(C @system) functions can use every D feature. $(C @system) is the default safety attribute.)

$(LI Functions can be executed at compile time as well (CTFE). This can be differentiated by the value of the special variable $(C __ctfe).)

)

Macros:
        TITLE=More Functions

        DESCRIPTION=Additional features of D functions that have not been mentioned up to this point: Automatic return type deduction, purity, not throwing exceptions, memory safety, and CTFE.

        KEYWORDS=d programming language tutorial book auto ref pure ctfe
