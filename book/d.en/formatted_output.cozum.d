Ddoc

$(COZUM_BOLUMU Formatted Output)

$(OL

$(LI We have already seen that this is trivial with format specifiers:

---
import std.stdio;

void main() {
    writeln("(Enter 0 to exit the program.)");

    while (true) {
        write("Please enter a number: ");
        long number;
        readf(" %s", &number);

        if (number == 0) {
            break;
        }

        writefln("%1$d <=> %1$#x", number);
    }
}
---

)

$(LI
Remembering that the $(C %) character must appear twice in the format string to be printed as itself:

---
import std.stdio;

void main() {
    write("Please enter the percentage value: ");
    double percentage;
    readf(" %s", &percentage);

    writefln("%%%.2f", percentage);
}
---

)

)


Macros:
        TITLE=Formatted Output Solutions

        DESCRIPTION=Programming in D exercise solutions: Formatted output

        KEYWORDS=programming in d tutorial formatted output solution
