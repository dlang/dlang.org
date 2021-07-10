Ddoc

$(DERS_BOLUMU $(IX pragma) Pragmas)

$(P
Pragmas are a way of interacting with the compiler. They can be for providing special information to the compiler as well as getting information from it. Although they are useful in non-templated code as well, $(C pragma(msg)) can be helpful when debugging templates.
)

$(P
Every compiler vendor is free to introduce their special $(C pragma) directives in addition to the following mandatory ones:
)

$(H5 $(C pragma(msg)))

$(P
Prints a message to $(C stderr) during compilation. No message is printed during the execution of the compiled program.
)

$(P
For example, the following $(C pragma(msg)) is being used for exposing the types of template parameters, presumably during debugging:
)

---
import std.string;

void func(A, B)(A a, B b) {
    pragma($(HILITE msg), format("Called with types '%s' and '%s'",
                       A.stringof, B.stringof));
    // ...
}

void main() {
    func(42, 1.5);
    func("hello", 'a');
}
---

$(SHELL
Called with types 'int' and 'double'
Called with types 'string' and 'char'
)

$(H5 $(C pragma(lib)))

$(P
Instructs the compiler to link the program with a particular library. This is the easiest way of linking the program with a library that is already installed on the system.
)

$(P
For example, the following program would be linked with the $(C curl) library without needing to mention the library on the command line:
)

---
import std.stdio;
import std.net.curl;

pragma($(HILITE lib), "curl");

void main() {
    // Get this chapter
    writeln(get("ddili.org/pragma.html"));
}
---

$(H5 $(IX inline) $(IX function inlining) $(IX optimization, compiler) $(C pragma(inline)))

$(P
Specifies whether a function should be $(I inlined) or not.
)

$(P
Every function call has some performance cost. Function calls involve passing arguments to the function, returning its return value to the caller, and handling some bookkeeping information to remember where the function was called from so that the execution can continue after the function returns.
)

$(P
This cost is usually insignificant compared to the cost of actual work that the caller and the callee perform. However, in some cases just the act of calling a certain function can have a measurable effect on the program's performance. This can happen especially when the function body is relatively fast and when it is called from a short loop that repeats many times.
)

$(P
The following program calls a small function from a loop and increments a counter when the returned value satisfies a condition:
)

---
import std.stdio;
import std.datetime.stopwatch;

// A function with a fast body:
ubyte compute(ubyte i) {
    return cast(ubyte)(i * 42);
}

void main() {
    size_t counter = 0;

    StopWatch sw;
    sw.start();

    // A short loop that repeats many times:
    foreach (i; 0 .. 100_000_000) {
        const number = cast(ubyte)i;

        if ($(HILITE compute(number)) == number) {
            ++counter;
        }
    }

    sw.stop();

    writefln("%s milliseconds", sw.peek.total!"msecs");
}
---

$(P
$(IX StopWatch, std.datetime.stopwatch) The code takes advantage of $(C std.datetime.stopwatch.StopWatch) to measure the time it takes executing the entire loop:
)

$(SHELL
$(HILITE 674) milliseconds
)

$(P
$(IX -inline, compiler switch) The $(C -inline) compiler switch instructs the compiler to perform a compiler optimization called $(I function inlining):
)

$(SHELL
$ dmd deneme.d -w $(HILITE -inline)
)

$(P
When a function is inlined, its body is injected into code right where it is called from; no actual function call happens. The following is the equivalent code that the compiler would compile after inlining:
)

---
    // An equivalent of the loop when compute() is inlined:
    foreach (i; 0 .. 100_000_000) {
        const number = cast(ubyte)i;

        const result = $(HILITE cast(ubyte)(number * 42));
        if (result == number) {
            ++counter;
        }
    }
---

$(P
On the platform that I tested that program, eliminating the function call reduced the execution time by about 40%:
)

$(SHELL
$(HILITE 407) milliseconds
)

$(P
Although function inlining looks like a big gain, it cannot be applied for every function call because otherwise inlined bodies of functions would make code too large to fit in the CPU's $(I instruction cache). Unfortunately, this can make the code even slower. For that reason, the decision of which function calls to inline is usually left to the compiler.
)

$(P
However, there may be cases where it is beneficial to help the compiler with this decision. The $(C inline) pragma instructs the compiler in its inlining decisions:
)

$(UL

$(LI $(C pragma(inline, false)): Instructs the compiler to never inline certain functions even when the $(C -inline) compiler switch is specified.)

$(LI $(C pragma(inline, true)): Instructs the compiler to definitely inline certain functions when the $(C -inline) compiler switch is specified. This causes a compilation error if the compiler cannot inline such a function. (The exact behavior of this pragma may be different on your compiler.))

$(LI $(C pragma(inline)): Sets the inlining behavior back to the setting on the compiler command line: whether $(C -inline) is specified or not.)

)

$(P
These pragmas can affect the function that they appear in, as well as they can be used with a scope or colon to affect more than one function:
)

---
pragma(inline, false) $(HILITE {)
    // Functions defined in this scope should not be inlined
    // ...
$(HILITE })

int foo() {
    pragma(inline, true);  // This function should be inlined
    // ...
}

pragma(inline, true)$(HILITE :)
// Functions defined in this section should be inlined
// ...

pragma(inline)$(HILITE :)
// Functions defined in this section should be inlined or not
// depending on the -inline compiler switch
// ...
---

$(P
$(IX -O, compiler switch) Another compiler switch that can make programs run faster is $(C -O), which instructs the compiler to perform more optimization algorithms. However, faster program speeds come at the expense of slower compilation speeds because these algorithms take significant amounts of time.
)

$(H5 $(IX startaddress) $(C pragma(startaddress)))

$(P
Specifies the start address of the program. Since the start address is normally assigned by the D runtime environment, it is very unlikely that you will ever use this pragma.
)

$(H5 $(IX mangle, pragma) $(IX name mangling) $(C pragma(mangle)))

$(P
Specifies that a symbol should be $(I name mangled) differently from the default name mangling method. Name mangling is about how the linker identifies functions and their callers. This pragma is useful when D code needs to call a library function that happens to be a D keyword.
)

$(P
For example, if a C library had a function named $(C override), because $(C override) happens to be a keyword in D, the only way of calling it from D would be through a different name. However, that different name must still be mangled as the actual function name in the library for the linker to be able to identify it:
)

---
/* If a C library had a function named 'override', it could
 * only be called from D through a name like 'c_override',
 * mangled as the actual function name: */
pragma($(HILITE mangle), "override")
extern(C) string c_override(string);

void main() {
    /* D code calls the function as c_override() but the
     * linker would find it by its correct C library name
     * 'override': */
    auto s = $(HILITE c_override)("hello");
}
---

Macros:
        TITLE=Pragmas

        DESCRIPTION=Introduction of pragmas, which are a way of interacting with the compiler.

        KEYWORDS=d programming language tutorial book pragma inline
