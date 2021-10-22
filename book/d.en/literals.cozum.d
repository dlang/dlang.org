Ddoc

$(COZUM_BOLUMU Literals)

$(OL

$(LI
The problem here is that the value on the right-hand side is too large to fit in an $(C int). According to the rules about integer literals, its type is $(C long). For that reason it doesn't fit the type of the variable on the left-hand side. There are at least two solutions.

$(P
One solution is to leave the type of the variable to the compiler for example by the $(C auto) keyword:
)

---
    auto amount = 10_000_000_000;
---

$(P
The type of $(C amount) would be deduced to be $(C long) from its initial value from the right-hand side.
)

$(P
Another solution is to make the type of the variable $(C long) as well:
)

---
    long amount = 10_000_000_000;
---

)

$(LI
We can take advantage of the special $(C '\r') character that takes the printing to the beginning of the line.

---
import std.stdio;

void main() {
    for (int number = 0; ; ++number) {
        write("\rNumber: ", number);
    }
}
---

$(P
The output of that program may be erratic due to its interactions with the output buffer. The following program flushes the output buffer and waits for 10 millisecond after each write:
)

---
import std.stdio;
import core.thread;

void main() {
    for (int number = 0; ; ++number) {
        write("\rNumber: ", number);
        stdout.flush();
        Thread.sleep(10.msecs);
    }
}
---

$(P
Flushing the output is normally not necessary as it is flushed automatically before getting to the next line e.g. by $(C writeln), or before reading from $(C stdin).
)

)

)


Macros:
        TITLE=Literals Solutions

        DESCRIPTION=Programming in D exercise solutions: Literals

        KEYWORDS=programming in d tutorial literals solution
