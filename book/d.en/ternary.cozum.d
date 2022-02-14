Ddoc

$(COZUM_BOLUMU The Ternary Operator $(C ?:))

$(P
Although it may make more sense to use an $(C if-else) statement in this exercise, the following program uses two $(C ?:) operators:
)

---
import std.stdio;

void main() {
    write("Please enter the net amount: ");

    int amount;
    readf(" %s", &amount);

    writeln("$",
            amount < 0 ? -amount : amount,
            amount < 0 ? " lost" : " gained");
}
---

$(P
The program prints "gained" even when the value is zero. Modify the program to print a message more appropriate for zero.
)

Macros:
        TITLE=The Ternary Operator ?: Solution

        DESCRIPTION=The exercise solution of the ?: operator of the D programming language.

        KEYWORDS=programming in d tutorial ternary solution
