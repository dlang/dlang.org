Ddoc

$(COZUM_BOLUMU The $(C for) Loop)

$(OL

$(LI

---
import std.stdio;

void main() {
    for (int line = 0; line != 9; ++line) {
        for (int column = 0; column != 9; ++column) {
            write(line, ',', column, ' ');
        }

        writeln();
    }
}
---

)

$(LI
Triangle:

---
import std.stdio;

void main() {
    for (int line = 0; line != 5; ++line) {
        int length = line + 1;

        for (int i = 0; i != length; ++i) {
            write('*');
        }

        writeln();
    }
}
---

$(P
Parallellogram:
)

---
import std.stdio;

void main() {
    for (int line = 0; line != 5; ++line) {
        for (int i = 0; i != line; ++i) {
            write(' ');
        }

        writeln("********");
    }
}
---

$(P
Can you produce the diamond pattern?
)

$(SHELL
   *
  ***
 *****
*******
 *****
  ***
   *
)

)

)


Macros:
        TITLE=The for Loop Solutions

        DESCRIPTION=Programming in D exercise solutions: the for loop

        KEYWORDS=programming in d tutorial for loop solution
