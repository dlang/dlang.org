Ddoc

$(COZUM_BOLUMU Formatted Input)

$(P
Using a format string where the parts of the date are replaced with $(C %s) would be sufficient:
)

---
import std.stdio;

void main() {
    int year;
    int month;
    int day;

    readf("%s.%s.%s", &year, &month, &day);

    writeln("Month: ", month);
}
---

Macros:
        TITLE=Formatted Input Solutions

        DESCRIPTION=Programming in D exercise solutions: Formatted input

        KEYWORDS=programming in d tutorial formatted input solution
