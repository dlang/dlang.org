Ddoc

$(DERS_BOLUMU $(IX conditional compilation) Conditional Compilation)

$(P
Conditional compilation is for compiling parts of programs in special ways depending on certain compile time conditions. Sometimes, entire sections of a program may need to be taken out and not compiled at all.
)

$(P
Conditional compilation involves condition checks that are evaluable at compile time. Runtime conditional statements like $(C if), $(C for), $(C while) are not conditional compilation features.
)

$(P
We have already encountered some features in the previous chapters, which can be seen as conditional compilation:
)

$(UL

$(LI
$(C unittest) blocks are compiled and run only if the $(C -unittest) compiler switch is enabled.
)

$(LI
The contract programming blocks $(C in), $(C out), and $(C invariant) are activated only if the $(C -release) compiler switch is $(I not) enabled.
)

)

$(P
Unit tests and contracts are about program correctness; whether they are included in the program should not change the behavior of the program.
)

$(P
The following are the features of D that are specifically for conditional compilation:
)

$(UL
$(LI $(C debug))
$(LI $(C version))
$(LI $(C static if))
$(LI $(C is) expression)
$(LI $(C __traits))
)

$(P
We will see the $(C is) expression in the next chapter.
)

$(H5 $(IX debug) debug)

$(P
$(IX -debug, compiler switch) $(C debug) is useful during program development. The expressions and statements that are marked as $(C debug) are compiled into the program only when the $(C -debug) compiler switch is enabled:
)

---
debug $(I a_conditionally_compiled_expression);

debug {
    // ... conditionally compiled code ...

} else {
    // ... code that is compiled otherwise ...
}
---

$(P
The $(C else) clause is optional.
)

$(P
Both the single expression and the code block above are compiled only when the $(C -debug) compiler switch is enabled.
)

$(P
We have been adding statements into the programs, which printed messages like "adding", "subtracting", etc. to the output. Such messages (aka $(I logs) and $(I log) messages) are helpful in finding errors by visualizing the steps that are taken by the program.
)

$(P
Remember the $(C binarySearch()) function from $(LINK2 templates.html, the Templates chapter). The following version of the function is intentionally incorrect:
)

---
import std.stdio;

// WARNING! This algorithm is wrong
size_t binarySearch(const int[] values, int value) {
    if (values.length == 0) {
        return size_t.max;
    }

    immutable midPoint = values.length / 2;

    if (value == values[midPoint]) {
        return midPoint;

    } else if (value < values[midPoint]) {
        return binarySearch(values[0 .. midPoint], value);

    } else {
        return binarySearch(values[midPoint + 1 .. $], value);
    }
}

void main() {
    auto numbers = [ -100, 0, 1, 2, 7, 10, 42, 365, 1000 ];

    auto index = binarySearch(numbers, 42);
    writeln("Index: ", index);
}
---

$(P
Although the index of 42 is 6, the program incorrectly reports 1:
)

$(SHELL_SMALL
Index: 1
)

$(P
One way of locating the bug in the program is to insert lines that would print messages to the output:
)

---
size_t binarySearch(const int[] values, int value) {
    $(HILITE writefln)("searching %s among %s", value, values);

    if (values.length == 0) {
        $(HILITE writefln)("%s not found", value);
        return size_t.max;
    }

    immutable midPoint = values.length / 2;

    $(HILITE writefln)("considering index %s", midPoint);

    if (value == values[midPoint]) {
        $(HILITE writefln)("found %s at index %s", value, midPoint);
        return midPoint;

    } else if (value < values[midPoint]) {
        $(HILITE writefln)("must be in the first half");
        return binarySearch(values[0 .. midPoint], value);

    } else {
        $(HILITE writefln)("must be in the second half");
        return binarySearch(values[midPoint + 1 .. $], value);
    }
}
---

$(P
The output of the program now includes steps that the program takes:
)

$(SHELL_SMALL
searching 42 among [-100, 0, 1, 2, 7, 10, 42, 365, 1000]
considering index 4
must be in the second half
searching 42 among [10, 42, 365, 1000]
considering index 2
must be in the first half
searching 42 among [10, 42]
considering index 1
found 42 at index 1
Index: 1
)

$(P
Let's assume that the previous output does indeed help the programmer locate the bug. It is obvious that the $(C writefln()) expressions are not needed anymore once the bug has been located and fixed. However, removing those lines can also be seen as wasteful, because they might be useful again in the future.
)

$(P
Instead of being removed altogether, the lines can be marked as $(C debug) instead:
)

---
        $(HILITE debug) writefln("%s not found", value);
---

$(P
Such lines are included in the program only when the $(C -debug) compiler switch is enabled:
)

$(SHELL_SMALL
$ dmd deneme.d -ofdeneme -w $(HILITE -debug)
)

$(H6 $(C debug($(I tag))))

$(P
If there are many $(C debug) keywords in the program, possibly in unrelated parts, the output may become too crowded. To avoid that, the $(C debug) statements can be given names (tags) to be included in the program selectively:
)

---
        $(HILITE debug(binarySearch)) writefln("%s not found", value);
---

$(P
The tagged $(C debug) statements are enabled by the $(C -debug=$(I tag)) compiler switch:
)

$(SHELL_SMALL
$ dmd deneme.d -ofdeneme -w $(HILITE -debug=binarySearch)
)

$(P
$(C debug) blocks can have tags as well:
)

---
    debug(binarySearch) {
        // ...
    }
---

$(P
It is possible to enable more than one $(C debug) tag at a time:
)

$(SHELL_SMALL
$ dmd deneme.d -w $(HILITE -debug=binarySearch) $(HILITE -debug=stackContainer)
)

$(P
In that case both the $(C binarySearch) and the $(C stackContainer) debug statements and blocks would be included.
)

$(H6 $(C debug($(I level))))

$(P
Sometimes it is more useful to associate $(C debug) statements by numerical levels. Increasing levels can provide more detailed information:
)

---
$(HILITE debug) import std.stdio;

void myFunction(string fileName, int[] values) {
    $(HILITE debug(1)) writeln("entered myFunction");

    $(HILITE debug(2)) {
        writeln("the arguments:");
        writeln("  file name: ", fileName);

        foreach (i, value; values) {
            writefln("  %4s: %s", i, value);
        }
    }

    // ... the implementation of the function ...
}

void main() {
    myFunction("deneme.txt", [ 10, 4, 100 ]);
}
---

$(P
The $(C debug) expressions and blocks that are lower than or equal to the specified level would be compiled:
)

$(SHELL_SMALL
$ dmd deneme.d -w $(HILITE -debug=1)
$ ./deneme 
$(SHELL_OBSERVED entered myFunction)
)

$(P
The following compilation would provide more information:
)

$(SHELL_SMALL
$ dmd deneme.d -w $(HILITE -debug=2)
$ ./deneme 
$(SHELL_OBSERVED entered myFunction
the arguments:
  file name: deneme.txt
     0: 10
     1: 4
     2: 100)
)

$(H5 $(IX version) $(C version($(I tag))) and $(C version($(I level))))

$(P
$(C version) is similar to $(C debug) and is used in the same way:
)

---
    version(testRelease) /* ... an expression ... */;

    version(schoolRelease) {
        /* ... expressions that are related to the version of
         *     this program that is presumably shipped to schools ... */

    } else {
        // ... code compiled otherwise ...
    }

    version(1) aVariable = 5;

    version(2) {
        // ... a feature of version 2 ...
    }
---

$(P
The $(C else) clause is optional.
)

$(P
Although $(C version) works essentially the same as $(C debug), having separate keywords helps distinguish their unrelated uses.
)

$(P
$(IX -version, compiler switch) As with $(C debug), more than one $(C version) can be enabled:
)

$(SHELL_SMALL
$ dmd deneme.d -w $(HILITE -version=record) $(HILITE -version=precise_calculation)
)

$(P
There are many predefined $(C version) tags, the complete list of which is available at the $(LINK2 http://dlang.org/version.html, Conditional Compilation specification). The following short list is just a sampling:
)

<table class="full" border="1" cellpadding="4" cellspacing="0"><caption>Predefined $(C version) tags</caption>

<tr><td>The compiler</td> <td>$(B DigitalMars GNU LDC SDC)</td></tr>

<tr><td>The operating system</td> <td>$(B Windows Win32 Win64 linux OSX Posix FreeBSD
OpenBSD
NetBSD
DragonFlyBSD
BSD
Solaris
AIX
Haiku
SkyOS
SysV3
SysV4
Hurd)</td></tr>

<tr><td>CPU endianness</td><td>$(B LittleEndian BigEndian)</td></tr>
<tr><td>Enabled compiler switches</td> <td> $(B D_Coverage D_Ddoc D_InlineAsm_X86 D_InlineAsm_X86_64 D_LP64 D_PIC D_X32
D_HardFloat
D_SoftFloat
D_SIMD
D_Version2
D_NoBoundsChecks
unittest
assert
)</td></tr>

<tr><td>CPU architecture</td> <td>$(B X86 X86_64)</td></tr>
<tr><td>Platform</td> <td>$(B Android
Cygwin
MinGW
ARM
ARM_Thumb
ARM_Soft
ARM_SoftFP
ARM_HardFP
ARM64
PPC
PPC_SoftFP
PPC_HardFP
PPC64
IA64
MIPS
MIPS32
MIPS64
MIPS_O32
MIPS_N32
MIPS_O64
MIPS_N64
MIPS_EABI
MIPS_NoFloat
MIPS_SoftFloat
MIPS_HardFloat
SPARC
SPARC_V8Plus
SPARC_SoftFP
SPARC_HardFP
SPARC64
S390
S390X
HPPA
HPPA64
SH
SH64
Alpha
Alpha_SoftFP
Alpha_HardFP
)</td></tr>
<tr><td>...</td> <td>...</td></tr>
</table>

$(P
In addition, there are the following two special $(C version) tags:
)

$(UL
$(LI $(IX none, version) $(C none): This tag is never defined; it is useful for disabling code blocks.)
$(LI $(IX all, version) $(C all): This tag is always defined; it is useful for enabling code blocks.)
)

$(P
As an example of how predefined $(C version) tags are used, the following is an excerpt (formatted differently here) from the $(C std.ascii) module, which is for determining the newline character sequence for the system ($(C static assert) will be explained later below):
)

---
version(Windows) {
    immutable newline = "\r\n";

} else version(Posix) {
    immutable newline = "\n";

} else {
    static assert(0, "Unsupported OS");
}
---

$(H5 Assigning identifiers to $(C debug) and $(C version))

$(P
Similar to variables, $(C debug) and $(C version) can be assigned identifiers. Unlike variables, this assignment does not change any value, it activates the specified identifier $(I as well).
)

---
import std.stdio;

debug(everything) {
    debug $(HILITE =) binarySearch;
    debug $(HILITE =) stackContainer;
    version $(HILITE =) testRelease;
    version $(HILITE =) schoolRelease;
}

void main() {
    debug(binarySearch) writeln("binarySearch is active");
    debug(stackContainer) writeln("stackContainer is active");

    version(testRelease) writeln("testRelease is active");
    version(schoolRelease) writeln("schoolRelease is active");
}
---

$(P
The assignments inside the $(C debug(everything)) block above activates all of the specified identifiers:
)

$(SHELL_SMALL
$ dmd deneme.d -w -debug=everything
$ ./deneme 
$(SHELL_OBSERVED binarySearch is active
stackContainer is active
testRelease is active
schoolRelease is active)
)

$(H5 $(IX static if) $(IX if, static) $(C static if))

$(P
$(C static if) is the compile time equivalent of the $(C if) statement.
)

$(P
Just like the $(C if) statement, $(C static if) takes a logical expression and evaluates it. Unlike the $(C if) statement, $(C static if) is not about execution flow; rather, it determines whether a piece of code should be included in the program or not.
)

$(P
The logical expression must be evaluable at compile time. If the logical expression evaluates to $(C true), the code inside the $(C static if) gets compiled. If the condition is $(C false), the code is not included in the program as if it has never been written. The logical expressions commonly take advantage of the $(C is) expression and $(C __traits).
)

$(P
$(C static if) can appear at module scope or inside definitions of $(C struct), $(C class), template, etc. Optionally, there may be $(C else) clauses as well.
)

$(P
Let's use $(C static if) with a simple template, making use of the $(C is) expression. We will see other examples of $(C static if) in the next chapter:
)

---
import std.stdio;

struct MyType(T) {
    static if (is (T == float)) {
        alias ResultType = double;

    } $(HILITE else static if) (is (T == double)) {
        alias ResultType = real;

    } else {
        static assert(false, T.stringof ~ " is not supported");
    }

    ResultType doWork() {
        writefln("The return type for %s is %s.",
                 T.stringof, ResultType.stringof);
        ResultType result;
        // ...
        return result;
    }
}

void main() {
    auto f = MyType!float();
    f.doWork();

    auto d = MyType!double();
    d.doWork();
}
---

$(P
According to the code, $(C MyType) can be used only with two types: $(C float) or $(C double). The return type of $(C doWork()) is chosen depending on whether the template is instantiated for $(C float) or $(C double):
)

$(SHELL
The return type for float is double.
The return type for double is real.
)

$(P
Note that one must write $(C else static if) when chaining $(C static if) clauses. Otherwise, writing $(C else if) would result in inserting that $(C if) conditional into the code, which would naturally be executed at run time.
)

$(H5 $(IX static assert) $(C static assert))

$(P
Although it is not a conditional compilation feature, I have decided to introduce $(C static assert) here.
)

$(P
$(C static assert) is the compile time equivalent of $(C assert). If the conditional expression is $(C false), the compilation gets aborted due to that assertion failure.
)

$(P
Similar to $(C static if), $(C static assert) can appear in any scope in the program.
)

$(P
We have seen an example of $(C static assert) in the program above: There, compilation gets aborted if $(C T) is any type other than $(C float) or $(C double):
)

---
    auto i = MyType!$(HILITE int)();
---

$(P
The compilation is aborted with the message that was given to $(C static assert):
)

$(SHELL
Error: static assert  "int is not supported"
)

$(P
As another example, let's assume that a specific algorithm can work only with types that are a multiple of a certain size. Such a condition can be ensured at compile time by a $(C static assert):
)

---
T myAlgorithm(T)(T value) {
    /* This algorithm requires that the size of type T is a
     * multiple of 4. */
    static assert((T.sizeof % 4) == 0);

    // ...
}
---

$(P
If the function was called with a $(C char), the compilation would be aborted with the following error message:
)

$(SHELL_SMALL
Error: static assert  (1LU == 0LU) is false
)

$(P
Such a test prevents the function from working with an incompatible type, potentially producing incorrect results.
)

$(P
$(C static assert) can be used with any logical expression that is evaluable at compile time.
)

$(H5 $(IX type trait) $(IX traits) Type traits)

$(P
$(IX __traits) $(IX std.traits) The $(C __traits) keyword and the $(C std.traits) module provide information about types and expressions at compile time.
)

$(P
Some information that is collected by the compiler is made available to the program by $(C __traits). Its syntax includes a traits $(I keyword) and $(I parameters) that are relevant to that keyword:
)

---
    __traits($(I keyword), $(I parameters))
---

$(P
$(I keyword) specifies the information that is being queried. The $(I parameters) are either types or expressions, meanings of which are determined by each particular keyword.
)

$(P
The information that can be gathered by $(C __traits) is especially useful in templates. For example, the $(C isArithmetic) keyword can determine whether a particular template parameter $(C T) is an arithmetic type:
)

---
    static if (__traits($(HILITE isArithmetic), T)) {
        // ... an arithmetic type ...

    } else {
        // ... not an arithmetic type ...
    }
---

$(P
Similarly, the $(C std.traits) module provides information at compile time through its templates. For example, $(C std.traits.isSomeChar) returns $(C true) if its template parameter is a character type:
)

---
import std.traits;

// ...

    static if ($(HILITE isSomeChar)!T) {
        // ... char, wchar, or dchar ...

    } else {
        // ... not a character type ...
    }
---

$(P
Please refer to $(LINK2 http://dlang.org/traits.html, the $(C __traits) documentation) and $(LINK2 http://dlang.org/phobos/std_traits.html, the $(C std.traits) documentation) for more information.
)

$(H5 Summary)

$(UL

$(LI
Code that is defined as $(C debug) is included to the program only if the $(C -debug) compiler switch is used.
)

$(LI
Code that is defined as $(C version) is included to the program only if a corresponding $(C -version) compiler switch is used.
)

$(LI
$(C static if) is similar to an $(C if) statement that is executed at compile time. It introduces code to the program depending on certain compile-time conditions.
)

$(LI
$(C static assert) validates assumptions about code at compile time.
)

$(LI $(C __traits) and $(C std.traits) provide information about types at compile time.)

)

Macros:
        TITLE=Conditional Compilation

        DESCRIPTION=Specifying parts of a program conditionally depending on logical expressions that are evaluated at compile time.

        KEYWORDS=d programming language tutorial book conditional compilation
