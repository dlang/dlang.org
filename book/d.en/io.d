Ddoc

$(DERS_BOLUMU $(IX standard input) $(IX standard output) Standard Input and Output Streams)

$(P
So far, the printed output of our programs has been appearing on the $(I terminal window) (or $(I screen)). Although the terminal is often the ultimate target of output, this is not always the case. The objects that can accept output are called $(I standard output streams).
)

$(P
The standard output is character based; everything to be printed is first converted to the corresponding character representation and then sent to the output as characters. For example, the integer value 100 that we've printed in the last chapter is not sent to the output as the value 100, but as the three characters $(C 1), $(C 0), and $(C 0).
)

$(P
Similarly, what we normally perceive as the $(I keyboard) is actually the $(I standard input stream) of a program and is also character based. The information always comes as characters to be converted to data. For example, the integer value 42 actually comes through the standard input as the characters $(C 4) and $(C 2).
)

$(P
These conversions happen automatically.
)

$(P
This concept of consecutive characters is called a $(I character stream). As D's standard input and standard output fit this description, they are character streams.
)

$(P
$(IX stdin) $(IX stdout) The names of the standard input and output streams in D are $(C stdin) and $(C stdout), respectively.
)

$(P
Operations on these streams normally require the name of the stream, a dot, and the operation; as in $(C stream.operation()). Because $(C stdin)'s reading methods and $(C stdout)'s writing methods are used very commonly, those operations can be called without the need of the stream name and the dot.
)

$(P
$(C writeln) that we've been using in the previous chapters is actually short for $(C stdout.writeln). Similarly, $(C write) is short for $(C stdout.write). Accordingly, the $(I hello world) program can also be written as follows:
)

---
import std.stdio;

void main() {
    $(HILITE stdout.)writeln("Hello, World!");
}
---

$(PROBLEM_TEK

$(P
Observe that $(C stdout.write) works the same as $(C write).
)

)

Macros:
        TITLE=Standard Input and Output Streams

        DESCRIPTION=D's standard input and output streams stdin and stdout.

        KEYWORDS=d programming language tutorial book stdin stdout
