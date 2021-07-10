Ddoc

$(COZUM_BOLUMU The $(CH4 while) Loop)

$(OL

$(LI
Because the initial value of $(C number) is 0, the logical expression of the $(C while) loop is $(C false) since the very beginning, and this is preventing from entering the loop body. A solution is to use an initial value that will allow the $(C while) condition to be $(C true) at the beginning:

---
    int number = 3;
---

)

$(LI
All of the variables in the following program are default initialized to 0. This allows entering both of the loops at least once:

---
import std.stdio;

void main() {
    int secretNumber;

    while ((secretNumber < 1) || (secretNumber > 10)) {
        write("Please enter a number between 1 and 10: ");
        readf(" %s", &secretNumber);
    }

    int guess;

    while (guess != secretNumber) {
        write("Guess the secret number: ");
        readf(" %s", &guess);
    }

    writeln("That is correct!");
}
---

)

)

Macros:
        TITLE=The while Loop Solutions

        DESCRIPTION=Programming in D exercise solutions: the 'while' loop

        KEYWORDS=programming in d tutorial while solution
