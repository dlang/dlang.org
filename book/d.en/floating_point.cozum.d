Ddoc

$(COZUM_BOLUMU Floating Point Types)

$(OL

$(LI
Replacing $(C float) with $(C double) produces an outcome that is surprising in a different way:

---
// ...

    $(HILITE double) result = 0;

// ...

    if ($(HILITE result == 1)) {
        writeln("As expected: 1");

    } else {
        writeln("DIFFERENT: ", result);
    }
---

$(P
Although the value fails the $(C result == 1) comparison, it is still printed as 1:
)

$(SHELL
DIFFERENT: 1
)

$(P
That surprising outcome is related to the way floating point values are formatted for printing. A more accurate approximation of the value can be seen when the value is printed with more digits after the decimal point. (We will see formatted output in $(LINK2 formatted_output.html, a later chapter).):
)

---
        write$(HILITE f)ln("DIFFERENT: %.20f", result);
---

$(SHELL
DIFFERENT: 1.00000000000000066613
)

)

$(LI
Replacing the three $(C int)s with three $(C double)s is sufficient:

---
        double first;
        double second;

        // ...

        double result;
---

)

$(LI
The following program demonstrates how much more complicated it would become if more than five variables were needed:

---
import std.stdio;

void main() {
    double value_1;
    double value_2;
    double value_3;
    double value_4;
    double value_5;

    write("Value 1: ");
    readf(" %s", &value_1);
    write("Value 2: ");
    readf(" %s", &value_2);
    write("Value 3: ");
    readf(" %s", &value_3);
    write("Value 4: ");
    readf(" %s", &value_4);
    write("Value 5: ");
    readf(" %s", &value_5);

    writeln("Twice the values:");
    writeln(value_1 * 2);
    writeln(value_2 * 2);
    writeln(value_3 * 2);
    writeln(value_4 * 2);
    writeln(value_5 * 2);

    writeln("One fifth the values:");
    writeln(value_1 / 5);
    writeln(value_2 / 5);
    writeln(value_3 / 5);
    writeln(value_4 / 5);
    writeln(value_5 / 5);
}
---

)

)

Macros:
        TITLE=Floating Point Types Solutions

        DESCRIPTION=The exercise solutions for the floating point types chapter

        KEYWORDS=programming in d tutorial floating point types exercise solution
