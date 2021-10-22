Ddoc

$(DERS_BOLUMU $(IX const) $(IX immutable) Immutability)

$(P
We have seen that variables represent concepts in programs. The interactions of these concepts are achieved by expressions that change the values of those variables:
)

---
    // Pay the bill
    totalPrice = calculateAmount(itemPrices);
    moneyInWallet $(HILITE -=) totalPrice;
    moneyAtMerchant $(HILITE +=) totalPrice;
---

$(P
Modifying a variable is called $(I mutating) that variable. The concept of mutability is essential for most tasks. However, there are some cases where mutability is not desirable:
)

$(UL

$(LI
Some concepts are immutable by definition. For example, there are always seven days in a week, the math constant $(I pi) (π) never changes, the list of natural languages supported by a program may be fixed and small (e.g. only English and Turkish), etc.
)

$(LI
If every variable were modifiable, as we have seen so far, then every piece of code that used a variable could potentially modify it. Even if there was no reason to modify a variable in an operation there would be no guarantee that this would not happen by accident. Programs are difficult to read and maintain when there are no immutability guarantees.

$(P
For example, consider a function call $(C retire(office, worker)) that retires a worker of an office. If both of those variables were mutable it would not be clear (just by looking at that function call) which of them would be modified by the function. It may be expected that the number of active employees of $(C office) would be decreased, but would the function call also modify $(C worker) in some way?
)

)

)

$(P
The concept of immutability helps with understanding parts of programs by guaranteeing that certain operations do not change certain variables. It also reduces the risk of some types of programming errors.
)

$(P
The $(I immutability) concept is expressed in D by the $(C const) and $(C immutable) keywords. Although the two words themselves are close in meaning, their responsibilities in programs are different and they are sometimes incompatible.
)

$(P
$(IX type qualifier) $(IX qualifier, type) $(C const), $(C immutable), $(C inout), and $(C shared) are $(I type qualifiers). (We will see $(LINK2 function_parameters.html, $(C inout)) and $(LINK2 concurrency_shared.html, $(C shared)) in later chapters.)
)

$(H5 Immutable variables)

$(P
Both of the terms "immutable variable" and "constant variable" are nonsensical when the word "variable" is taken literally to mean $(I something that changes). In a broader sense, the word "variable" is often understood to mean any concept of a program which may be mutable or immutable.
)

$(P
There are three ways of defining variables that can never be mutated.
)

$(H6 $(IX enum) $(C enum) constants)

$(P
We have seen earlier in the $(LINK2 enum.html, $(C enum) chapter) that $(C enum) defines named constant values:
)

---
    enum fileName = "list.txt";
---

$(P
As long as their values can be determined at compile time, $(C enum) variables can be initialized with return values of functions as well:
)

---
int totalLines() {
    return 42;
}

int totalColumns() {
    return 7;
}

string name() {
    return "list";
}

void main() {
    enum fileName = name() ~ ".txt";
    enum totalSquares = totalLines() * totalColumns();
}
---

$(P
The D feature that enables such initialization is $(I compile time function execution) (CTFE), which we will see in $(LINK2 functions_more.html, a later chapter).
)


$(P
As expected, the values of $(C enum) constants cannot be modified:
)

---
    ++totalSquares;    $(DERLEME_HATASI)
---

$(P
Although it is a very effective way of representing immutable values, $(C enum) can only be used for compile-time values.
)

$(P
An $(C enum) constant is $(I a manifest constant), meaning that the program is compiled as if every mention of that constant had been replaced by its value. As an example, let's consider the following $(C enum) definition and the two expressions that make use of it:
)

---
    enum i = 42;
    writeln(i);
    foo(i);
---

$(P
The code above is completely equivalent to the one below, where we replace every use of $(C i) with its value of $(C 42):
)

---
    writeln(42);
    foo(42);
---

$(P
Although that replacement makes sense for simple types like $(C int) and makes no difference to the resulting program, $(C enum) constants can bring a hidden cost when they are used for arrays or associative arrays:
)

---
    enum a = [ 42, 100 ];
    writeln(a);
    foo(a);
---

$(P
After replacing $(C a) with its value, the equivalent code that the compiler would be compiling is the following:
)

---
    writeln([ 42, 100 ]); // an array is created at run time
    foo([ 42, 100 ]);     // another array is created at run time
---

$(P
The hidden cost here is that there would be two separate arrays created for the two expressions above. For that reason, it may make more sense to define arrays and associative arrays as $(C immutable) variables if they are going to be used more than once in the program.
)

$(H6 $(IX variable, immutable) $(C immutable) variables)

$(P
Like $(C enum), this keyword specifies that the value of a variable will never change. Unlike $(C enum), an $(C immutable) variable is an actual variable with a memory address, which means that we can set its value during the execution of the program and that we can refer to its memory location.
)

$(P
The following program compares the uses of $(C enum) and $(C immutable). The program asks for the user to guess a number that has been picked randomly. Since the random number cannot be determined at compile time, it cannot be defined as an $(C enum). Still, since the randomly picked value must never be changed after having been decided, it is suitable to specify that variable as $(C immutable).
)

$(P
The program takes advantage of the $(C readInt()) function that was defined in the previous chapter:
)

---
import std.stdio;
import std.random;

int readInt(string message) {
    int result;
    write(message, "? ");
    readf(" %s", &result);
    return result;
}

void main() {
    enum min = 1;
    enum max = 10;

    $(HILITE immutable) number = uniform(min, max + 1);

    writefln("I am thinking of a number between %s and %s.",
             min, max);

    auto isCorrect = false;
    while (!isCorrect) {
        $(HILITE immutable) guess = readInt("What is your guess");
        isCorrect = (guess == number);
    }

    writeln("Correct!");
}
---

$(P
Observations:
)

$(UL

$(LI $(C min) and $(C max) are integral parts of the behavior of this program and their values are known at compile time. For that reason they are defined as $(C enum) constants.
)

$(LI $(C number) is specified as $(C immutable) because it would not be appropriate to modify it after its initialization at run time. Likewise for each user guess: once read, the guess should not be modified.
)

$(LI Observe that the types of those variables are not specified explicitly. As with $(C auto) and $(C enum), the type of an $(C immutable) variable can be inferred from the expression on the right hand side.
)

)

$(P
Although it is not necessary to write the type fully, $(C immutable) normally takes the actual type within parentheses, e.g. $(C immutable(int)). The output of the following program demonstrates that the full names of the types of the three variables are in fact the same:
)

---
import std.stdio;

void main() {
    immutable      inferredType = 0;
    immutable int  explicitType = 1;
    immutable(int) wholeType    = 2;

    writeln(typeof(inferredType).stringof);
    writeln(typeof(explicitType).stringof);
    writeln(typeof(wholeType).stringof);
}
---

$(P
The actual name of the type includes $(C immutable):
)

$(SHELL
immutable(int)
immutable(int)
immutable(int)
)

$(P
The use of parentheses has significance, and specifies which parts of the type are immutable. We will see this below when discussing the immutability of the whole slice vs. its elements.
)

$(H6 $(IX variable, const) $(C const) variables)

$(P
When defining variables the $(C const) keyword has the same effect as $(C immutable). $(C const) variables cannot be modified:
)

---
    $(HILITE const) half = total / 2;
    half = 10;    $(DERLEME_HATASI)
---

$(P
I recommend that you prefer $(C immutable) over $(C const) for defining variables. The reason is that $(C immutable) variables can be passed to functions that have $(C immutable) parameters. We will see this below.
)

$(H5 Immutable parameters)

$(P
It is possible for functions to promise that they do not modify certain parameters that they take, and the compiler will enforce this promise. Before seeing how this is achieved, let's first see that functions can indeed modify the elements of slices that are passed as arguments to those functions.
)

$(P
As you would remember from the $(LINK2 slices.html, Slices and Other Array Features chapter), slices do not own elements but provide access to them. There may be more than one slice at a given time that provides access to the same elements.
)

$(P
Although the examples in this section focus only on slices, this topic is applicable to associative arrays and classes as well because they too are $(I reference types).
)

$(P
A slice that is passed as a function argument is not the slice that the function is called with. The argument is a copy of the actual slice:
)

---
import std.stdio;

void main() {
    int[] slice = [ 10, 20, 30, 40 ];  // 1
    halve(slice);
    writeln(slice);
}

void halve(int[] numbers) {            // 2
    foreach (ref number; numbers) {
        number /= 2;
    }
}
---

$(P
When program execution enters the $(C halve()) function, there are two slices that provide access to the same four elements:
)

$(OL

$(LI The slice named $(C slice) that is defined in $(C main()), which is passed to $(C halve()) as its argument
)

$(LI The slice named $(C numbers) that $(C halve()) receives as its argument, which provides access to the same elements as $(C slice)
)

)

$(P
Since both slides refer to the same elements and given that we use the $(C ref) keyword in the $(C foreach) loop, the values of the elements get halved:
)

$(SHELL
[5, 10, 15, 20]
)

$(P
It is useful for functions to be able to modify the elements of the slices that are passed as arguments. Some functions exist just for that purpose, as has been seen in this example.
)

$(P
The compiler does not allow passing $(C immutable) variables as arguments to such functions because we cannot modify an immutable variable:
)

---
    $(HILITE immutable) int[] slice = [ 10, 20, 30, 40 ];
    halve(slice);    $(DERLEME_HATASI)
---

$(P
The compilation error indicates that a variable of type $(C immutable(int[])) cannot be used as an argument of type $(C int[]):
)

$(SHELL
Error: function deneme.halve ($(HILITE int[]) numbers) is not callable
using argument types ($(HILITE immutable(int[])))
)

$(H6 $(IX parameter, const) $(C const) parameters)

$(P
It is important and natural that $(C immutable) variables be prevented from being passed to functions like $(C halve()), which modify their arguments. However, it would be a limitation if they could not be passed to functions that do not modify their arguments in any way:
)

---
import std.stdio;

void main() {
    immutable int[] slice = [ 10, 20, 30, 40 ];
    print(slice);    $(DERLEME_HATASI)
}

void print(int[] slice) {
    writefln("%s elements: ", slice.length);

    foreach (i, element; slice) {
        writefln("%s: %s", i, element);
    }
}
---

$(P
It does not make sense above that a slice is prevented from being printed just because it is $(C immutable). The proper way of dealing with this situation is by using $(C const) parameters.
)

$(P
The $(C const) keyword specifies that a variable is not modified through $(I that particular reference) (e.g. a slice) of that variable. Specifying a parameter as $(C const) guarantees that the elements of the slice are not modified inside the function. Once $(C print()) provides this guarantee, the program can now be compiled:
)

---
    print(slice);    // now compiles
// ...
void print($(HILITE const) int[] slice)
---

$(P
This guarantee allows passing both mutable and $(C immutable) variables as arguments:
)

---
    immutable int[] slice = [ 10, 20, 30, 40 ];
    print(slice);           // compiles

    int[] mutableSlice = [ 7, 8 ];
    print(mutableSlice);    // compiles
---

$(P
A parameter that is not modified in a function but is not specified as $(C const) reduces the applicability of that function. Additionally, $(C const) parameters provide useful information to the programmer. Knowing that a variable will not be modified when passed to a function makes the code easier to understand. It also prevents potential errors because the compiler detects modifications to $(C const) parameters:
)

---
void print($(HILITE const) int[] slice) {
    slice[0] = 42;    $(DERLEME_HATASI)
---

$(P
The programmer would either realize the mistake in the function or would rethink the design and perhaps remove the $(C const) specifier.
)

$(P
The fact that $(C const) parameters can accept both mutable and $(C immutable) variables has an interesting consequence. This is explained in the "Should a parameter be $(C const) or $(C immutable)?" section below.
)

$(H6 $(IX parameter, immutable) $(C immutable) parameters)

$(P
As we saw above, both mutable and $(C immutable) variables can be passed to functions as their $(C const) parameters. In a way, $(C const) parameters are welcoming.
)

$(P
In contrast, $(C immutable) parameters bring a strong requirement: only $(C immutable) variables can be passed to functions as their $(C immutable) parameters:
)

---
void func($(HILITE immutable) int[] slice) {
    // ...
}

void main() {
    immutable int[] immSlice = [ 1, 2 ];
              int[]    slice = [ 8, 9 ];

    func(immSlice);      // compiles
    func(slice);         $(DERLEME_HATASI)
}
---

$(P
For that reason, the $(C immutable) specifier should be used only when this requirement is actually necessary. We have indeed been using the $(C immutable) specifier indirectly through certain string types. This will be covered below.
)

$(P
We have seen that the parameters that are specified as $(C const) or $(C immutable) promise not to modify $(I the actual variable) that is passed as an argument. This is relevant only for reference types because only then there is $(I the actual variable) to talk about the immutability of.
)

$(P
$(I Reference types) and $(I value types) will be covered in the next chapter. Among the types that we have seen so far, only slices and associative arrays are reference types; the others are value types.
)

$(H6 $(IX parameter, const vs. immutable) Should a parameter be $(C const) or $(C immutable)?)

$(P
The two sections above may give the impression that, being more flexible, $(C const) parameters should be preferred over $(C immutable) parameters. This is not always true.
)

$(P
$(C const) $(I erases) the information about whether the original variable was mutable or $(C immutable). This information is hidden even from the compiler.
)

$(P
A consequence of this fact is that $(C const) parameters cannot be passed as arguments to functions that take $(C immutable) parameters. For example, $(C foo()) below cannot pass its $(C const) parameter to $(C bar()):
)

---
void main() {
    /* The original variable is immutable */
    immutable int[] slice = [ 10, 20, 30, 40 ];
    foo(slice);
}

/* A function that takes its parameter as const, in order to
 * be more useful. */
void foo(const int[] slice) {
    bar(slice);    $(DERLEME_HATASI)
}

/* A function that takes its parameter as immutable, for a
 * plausible reason. */
void bar(immutable int[] slice) {
    // ...
}
---

$(P
$(C bar()) requires the parameter to be $(C immutable). However, it is not known (in general) whether the original variable that $(C foo())'s $(C const) parameter references was $(C immutable) or not.
)

$(P
$(I $(B Note:) It is clear in the code above that the original variable in $(C main()) is $(C immutable). However, the compiler compiles functions individually, without regard to all of the places that function is called from. To the compiler, the $(C slice) parameter of $(C foo()) may refer to a mutable variable or an $(C immutable) one.
)
)

$(P
A solution would be to call $(C bar()) with an immutable copy of the parameter:
)

---
void foo(const int[] slice) {
    bar(slice$(HILITE .idup));
}
---

$(P
Although that is a sensible solution, it does incur into the cost of copying the slice and its contents, which would be wasteful in the case where the original variable was $(C immutable) to begin with.
)

$(P
After this analysis, it should be clear that always declaring parameters as $(C const) is not the best approach in every situation. After all, if $(C foo())'s parameter had been defined as $(C immutable) there would be no need to copy it before calling $(C bar()):
)

---
void foo(immutable int[] slice) {  // This time immutable
    bar(slice);    // Copying is not needed anymore
}
---

$(P
Although the code compiles, defining the parameter as $(C immutable) has a similar cost: this time an immutable copy of the original variable is needed when calling $(C foo()), if that variable was not immutable to begin with:
)

---
    foo(mutableSlice$(HILITE .idup));
---

$(P
Templates can help. (We will see templates in later chapters.) Although I don't expect you to fully understand the following function at this point in the book, I will present it as a solution to this problem. The following function template $(C foo()) can be called both with mutable and $(C immutable) variables. The parameter would be copied only if the original variable was mutable; no copying would take place if it were $(C immutable):
)

---
import std.conv;
// ...

/* Because it is a template, foo() can be called with both mutable
 * and immutable variables. */
void foo(T)(T[] slice) {
    /* 'to()' does not make a copy if the original variable is
     * already immutable. */
    bar(to!(immutable T[])(slice));
}
---

$(H5 Immutability of the slice versus the elements)

$(P
We have seen above that the type of an $(C immutable) slice has been printed as $(C immutable(int[])). As the parentheses after $(C immutable) indicate, it is the entire slice that is $(C immutable). Such a slice cannot be modified in any way: elements may not be added or removed, their values may not be modified, and the slice may not start providing access to a different set of elements:
)

---
    immutable int[] immSlice = [ 1, 2 ];
    immSlice ~= 3;               $(DERLEME_HATASI)
    immSlice[0] = 3;             $(DERLEME_HATASI)
    immSlice.length = 1;         $(DERLEME_HATASI)

    immutable int[] immOtherSlice = [ 10, 11 ];
    immSlice = immOtherSlice;    $(DERLEME_HATASI)
---

$(P
Taking immutability to that extreme may not be suitable in every case. In most cases, what is important is the immutability of the elements themselves. Since a slice is just a tool to access the elements, it should not matter if we make changes to the slice itself as long as the elements are not modified. This is especially true in the cases we have seen so far, where the function receives a copy of the slice itself.
)

$(P
To specify that only the elements are immutable we use the $(C immutable) keyword with parentheses that enclose just the element type. Modifying the code accordingly, now only the elements are immutable, not the slice itself:
)

---
    immutable$(HILITE (int))[] immSlice = [ 1, 2 ];
    immSlice ~= 3;               // can add elements
    immSlice[0] = 3;             $(DERLEME_HATASI)
    immSlice.length = 1;         // can drop elements

    immutable int[] immOtherSlice = [ 10, 11 ];
    immSlice = immOtherSlice;    /* can provide access to
                                  * other elements */
---

$(P
Although the two syntaxes are very similar, they have different meanings. To summarize:
)

---
    immutable int[]  a = [1]; /* Neither the elements nor the
                               * slice can be modified */

    immutable(int[]) b = [1]; /* The same meaning as above */

    immutable(int)[] c = [1]; /* The elements cannot be
                               * modified but the slice can be */
---

$(P
This distinction has been in effect in some of the programs that we have written so far. As you may remember, the three string aliases involve immutability:
)

$(UL
$(LI $(C string) is an alias for $(C immutable(char)[]))
$(LI $(C wstring) is an alias for $(C immutable(wchar)[]))
$(LI $(C dstring) is an alias for $(C immutable(dchar)[]))
)

$(P
Likewise, string literals are immutable as well:
)

$(UL
$(LI The type of literal $(STRING "hello"c) is $(C string))
$(LI The type of literal $(STRING "hello"w) is $(C wstring))
$(LI The type of literal $(STRING "hello"d) is $(C dstring))
)

$(P
According to these definitions, D strings are normally arrays of $(I immutable characters).
)

$(H6 $(IX transitive, immutability) $(C const) and $(C immutable) are transitive)

$(P
As mentioned in the code comments of slices $(C a) and $(C b) above, both those slices and their elements are $(C immutable).
)

$(P
This is true for $(LINK2 struct.html, structs) and $(LINK2 class.html, classes) as well, both of which will be covered in later chapters. For example, all members of a $(C const) $(C struct) variable are $(C const) and all members of an $(C immutable) $(C struct) variable are $(C immutable). (Likewise for classes.)
)

$(H6 $(IX .dup) $(IX .idup) $(C .dup) and $(C .idup))

$(P
There may be mismatches in immutability when strings are passed to functions as parameters. The $(C .dup) and $(C .idup) properties make copies of arrays with the desired mutability:
)

$(UL
$(LI $(C .dup) makes a mutable copy of the array; its name comes from "duplicate")
$(LI $(C .idup) makes an immutable copy of the array)
)

$(P
For example, a function that insists on the immutability of a parameter may have to be called with an immutable copy of a mutable string:
)

---
void foo($(HILITE string) s) {
    // ...
}

void main() {
    char[] salutation;
    foo(salutation);                $(DERLEME_HATASI)
    foo(salutation$(HILITE .idup));           // ← this compiles
}
---

$(H5 How to use)

$(UL

$(LI
As a general rule, prefer immutable variables over mutable ones.
)

$(LI
Define constant values as $(C enum) if their values can be calculated at compile time. For example, the constant value of $(I seconds per minute) can be an $(C enum):

---
    enum int secondsPerMinute = 60;
---

$(P
There is no need to specify the type explicitly if it can be inferred from the right hand side:
)

---
    enum secondsPerMinute = 60;
---

)

$(LI
Consider the hidden cost of $(C enum) arrays and $(C enum) associative arrays. Define them as $(C immutable) variables if the arrays are large and they are used more than once in the program.
)

$(LI
Specify variables as $(C immutable) if their values will never change but cannot be known at compile time. Again, the type can be inferred:

---
    immutable guess = readInt("What is your guess");
---

)

$(LI
If a function does not modify a parameter, specify that parameter as $(C const). This would allow both mutable and $(C immutable) variables to be passed as arguments:

---
void foo(const char[] s) {
    // ...
}

void main() {
    char[] mutableString;
    string immutableString;

    foo(mutableString);      // ← compiles
    foo(immutableString);    // ← compiles
}
---

)

$(LI
Following from the previous guideline, consider that $(C const) parameters cannot be passed to functions taking $(C immutable). See the section titled "Should a parameter be $(C const) or $(C immutable)?" above.
)

$(LI
If the function modifies a parameter, leave that parameter as mutable ($(C const) or $(C immutable) would not allow modifications anyway):

---
import std.stdio;

void reverse(dchar[] s) {
    foreach (i; 0 .. s.length / 2) {
        immutable temp = s[i];
        s[i] = s[$ - 1 - i];
        s[$ - 1 - i] = temp;
    }
}

void main() {
    dchar[] salutation = "hello"d.dup;
    reverse(salutation);
    writeln(salutation);
}
---

$(P
The output:
)

$(SHELL
olleh
)

)

)

$(H5 Summary)

$(UL

$(LI $(C enum) variables represent immutable concepts that are known at compile time.)

$(LI $(C immutable) variables represent immutable concepts that must be calculated at run time, or that must have some memory location that we can refer to.)

$(LI $(C const) parameters are the ones that functions do not modify. Both mutable and $(C immutable) variables can be passed as arguments of $(C const) parameters.)

$(LI $(C immutable) parameters are the ones that functions specifically require them to be so. Only $(C immutable) variables can be passed as arguments of $(C immutable) parameters.)

$(LI $(C immutable(int[])) specifies that neither the slice nor its elements can be modified.)

$(LI $(C immutable(int)[]) specifies that only the elements cannot be modified.)

)

Macros:
        TITLE=Immutability

        DESCRIPTION=The const and immutable keywords of D, which support the concept of immutability.

        KEYWORDS=d programming language tutorial book immutable const
