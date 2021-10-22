Ddoc

$(COZUM_BOLUMU The if Statement)

$(OL

$(LI
The statement $(C writeln("Washing the plate")) is written indented as if to be within the $(C else) scope. However, because the scope of that $(C else) is not written with curly brackets, only the $(C writeln("Eating pie")) statement is actually inside the scope of that $(C else).

$(P
Since whitespaces are not important in D programs, the $(I plate statement) is actually an independent statement within $(C main()) and is executed unconditionally. It confuses the reader as well because of having been indented more than usual. If the $(I plate statement) must really be within the $(C else) scope, there must be curly brackets around that scope:
)

---
import std.stdio;

void main() {
    bool existsLemonade = true;

    if (existsLemonade) {
        writeln("Drinking lemonade");
        writeln("Washing the cup");

    } else $(HILITE {)
        writeln("Eating pie");
        writeln("Washing the plate");
    $(HILITE })
}
---

)

$(LI
We can come up with more than one design for the conditions of this game. I will show two examples. In the first one, we apply the information directly from the exercise:

---
import std.stdio;

void main() {
    write("What is the value of the die? ");
    int die;
    readf(" %s", &die);

    if (die == 1) {
        writeln("You won");

    } else if (die == 2) {
        writeln("You won");

    } else if (die == 3) {
        writeln("You won");

    } else if (die == 4) {
        writeln("I won");

    } else if (die == 5) {
        writeln("I won");

    } else if (die == 6) {
        writeln("I won");

    } else {
        writeln("ERROR: ", die, " is invalid");
    }
}
---

$(P
Unfortunately, that program has many repetitions. We can achieve the same result by other designs. Here is one:
)

---
import std.stdio;

void main() {
    write("What is the value of the die? ");
    int die;
    readf(" %s", &die);

    if ((die == 1) || (die == 2) || (die == 3)) {
        writeln("You won");

    } else if ((die == 4) || (die == 5) || (die == 6)) {
        writeln("I won");

    } else {
        writeln("ERROR: ", die, " is invalid");
    }
}
---

)

$(LI
The previous designs cannot be used in this case. It is not practical to type 1000 different values in a program and expect them all be correct or readable. For that reason, it is better to determine whether the value of the die is $(I within a range):

---
    if ((die >= 1) && (die <= 500))
---

)

)

Macros:
        TITLE=The if Statement Solutions

        DESCRIPTION=Programming in D exercise solutions: the 'if' statement and its optional 'else' clause

        KEYWORDS=programming in d tutorial if else solution
