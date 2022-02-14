Ddoc

$(COZUM_BOLUMU The Hello World Program)

$(OL

$(LI

---
import std.stdio;

void main() {
    writeln("Something else... :p");
}
---

)

$(LI

---
import std.stdio;

void main() {
    writeln("A line...");
    writeln("Another line...");
}
---

)

$(LI

The following program cannot be compiled because the semicolon at the end of the $(C writeln) line is missing:

---
import std.stdio;

void main() {
    writeln("Hello, World!")    $(DERLEME_HATASI)
}
---
)

)

Macros:
        TITLE=The Hello World Program Solutions

        DESCRIPTION=The exercise solutions for the first D program: Hello World!

        KEYWORDS=programming in d tutorial hello world program exercise solution
