Ddoc

$(COZUM_BOLUMU The $(C foreach) Loop)

$(P
To have an associative array that works the opposite of $(C names), the types of the key and the value must be swapped. The new associative array must be defined as of type $(C int[string]).
)

$(P
Iterating over the keys and the values of the original associative array while using keys as values and values as keys would populate the $(C values) table:
)

---
import std.stdio;

void main() {
    string[int] names = [ 1:"one", 7:"seven", 20:"twenty" ];

    int[string] values;

    foreach (key, value; names) {
        values[value] = key;
    }

    writeln(values["twenty"]);
}
---

Macros:
        TITLE=The foreach Loop Solutions

        DESCRIPTION=Programming in D exercise solutions: The foreach Loop

        KEYWORDS=programming in d tutorial foreach
