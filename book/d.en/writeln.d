Ddoc

$(DERS_BOLUMU $(IX writeln) $(IX write) $(CH4 writeln) and $(CH4 write))

$(P
In the previous chapter we have seen that $(C writeln) takes a string within parentheses and prints the string.
)

$(P
The parts of programs that actually do work are called $(I functions) and the information that they need to complete their work are called $(I parameters). The act of giving such information to functions is called $(I passing parameter values) to them. Parameters are passed to functions within parentheses, separated by commas.
)

$(P
$(I $(B Note:) The word ) parameter $(I describes the information that is passed to a function at the conceptual level. The concrete information that is actually passed during the execution of the program is called an) argument. $(I Although not technically the same, these terms are sometimes used interchangably in the software industry.)
)

$(P
$(C writeln) can take more than one argument. It prints them one after the other on the same line:
)

---
import std.stdio;

void main() {
    writeln("Hello, World!", "Hello, fish!");
}
---

$(P
Sometimes, not all of the information that is to be printed on the same line may be readily available to be passed to $(C writeln). In such cases, the first parts of the line may be printed by $(C write) and the last part of the line may be printed by $(C writeln).
)

$(P
$(C writeln) advances to the next line, $(C write) stays on the same line:
)

---
import std.stdio;

void main() {
    // Let's first print what we have available:
    write("Hello,");

    // ... let's assume more operations at this point ...

    write("World!");

    // ... and finally:
    writeln();
}
---

$(P
Calling $(C writeln) without any parameter merely completes the current line, or if nothing has been written, outputs a blank line.
)

$(P
$(IX //) $(IX comment) Lines that start with $(COMMENT //) are called $(I comment lines) or briefly $(I comments). A comment is not a part of the program code in the sense that it doesn't affect the behavior of the program. Its only purpose is to explain what the code does in that particular section of the program. The audience of a comment is anybody who may be reading the program code later, including the programmer who wrote the comment in the first place.
)

$(PROBLEM_COK

$(PROBLEM

Both of the programs in this chapter print the strings without any spaces between them. Change the programs so that there is space between the arguments as in "Hello, World!".

)

$(PROBLEM
Try calling $(C write) with more than one parameter as well.
)

)


Macros:
        TITLE=writeln and write

        DESCRIPTION=Two functions of the D standard library: writeln and write.

        KEYWORDS=d programming language tutorial book if conditional statement

MINI_SOZLUK=
