Ddoc

$(COZUM_BOLUMU Fundamental Types)


$(P
We can use other types instead of $(C int):
)

---
import std.stdio;

void main() {
    writeln("Type           : ", short.stringof);
    writeln("Length in bytes: ", short.sizeof);
    writeln("Minimum value  : ", short.min);
    writeln("Maximum value  : ", short.max);
    writeln("Initial value  : ", short.init);

    writeln();

    writeln("Type           : ", ulong.stringof);
    writeln("Length in bytes: ", ulong.sizeof);
    writeln("Minimum value  : ", ulong.min);
    writeln("Maximum value  : ", ulong.max);
    writeln("Initial value  : ", ulong.init);
}
---


Macros:
        TITLE=Fundamental Types Solutions

        DESCRIPTION=Programming in D exercise solutions: fundamental types

        KEYWORDS=programming in d tutorial solution
