Ddoc

$(COZUM_BOLUMU $(C auto) and $(C typeof))

$(P
We can use $(C typeof) to determine the type of the literal and $(C .stringof) to get the name of that type as $(C string):
)

---
import std.stdio;

void main() {
    writeln(typeof(1.2).stringof);
}
---

$(P
The output:
)

$(SHELL
double
)

Macros:
        TITLE=auto and typeof Solutions

        DESCRIPTION=auto and typeof chapter solutions

        KEYWORDS=programming in d tutorial files
