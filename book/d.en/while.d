Ddoc

$(DERS_BOLUMU $(IX while) $(IX loop, while) $(CH4 while) Loop)

$(P
The $(C while) loop is similar to the $(C if) statement and essentially works as a repeated $(C if) statement. Just like $(C if), $(C while) also takes a logical expression and evaluates the block when the logical expression is $(C true). The difference is that the $(C while) statement evaluates the logical expression and executes the expressions in the block repeatedly, as long as the logical expression is $(C true), not just once. Repeating a block of code this way is called $(I looping).
)

$(P
Here is the syntax of the $(C while) statement:
)

---
    while (a_logical_expression) {
        // ... expression(s) to execute while true
    }
---

$(P
For example, the code that represents $(I eat cookies as long as there is cookie) can be coded like this:
)

---
import std.stdio;

void main() {
    bool existsCookie = true;

    while (existsCookie) {
        writeln("Take cookie");
        writeln("Eat cookie");
    }
}
---

$(P
That program would continue repeating the loop because the value of $(C existsCookie) never changes from $(C true).
)

$(P
$(C while) is useful when the value of the logical expression changes during the execution of the program. To see this, let's write a program that takes a number from the user as long as that number is zero or greater. Remember that the initial value of $(C int) variables is 0:
)

---
import std.stdio;

void main() {
    int number;

    while (number >= 0) {
        write("Please enter a number: ");
        readf(" %s", &number);

        writeln("Thank you for ", number);
    }

    writeln("Exited the loop");
}
---

$(P
The program thanks for the provided number and exits the loop only when the number is less than zero.
)

$(H5 $(IX continue) The $(C continue) statement)

$(P
The continue statement starts the next iteration of the loop right away, instead of executing the rest of the expressions of the block.
)

$(P
Let's modify the program above to be a little picky: instead of thanking for any number, let's not accept 13. The following program does not thank for 13 because in that case the $(C continue) statement makes the program go to the beginning of the loop to evaluate the logical expression again:
)

---
import std.stdio;

void main() {
    int number;

    while (number >= 0) {
        write("Please enter a number: ");
        readf(" %s", &number);

        if (number == 13) {
            writeln("Sorry, not accepting that one...");
            $(HILITE continue);
        }

        writeln("Thank you for ", number);
    }

    writeln("Exited the loop");
}
---

$(P
We can define the behavior of that program as $(I take numbers as long as they are greater than or equal to 0 but skip 13).
)

$(P
$(C continue) works with $(C do-while), $(C for), and $(C foreach) statements as well. We will see these features in later chapters.
)

$(H5 $(IX break) The $(C break) statement)

$(P
Sometimes it becomes obvious that there is no need to stay in the $(C while) loop any longer. $(C break) allows the program to exit the loop right away. The following program exits the loop as soon as it finds a special number:
)

---
import std.stdio;

void main() {
    int number;

    while (number >= 0) {
        write("Please enter a number: ");
        readf(" %s", &number);

        if (number == 42) {
            writeln("FOUND IT!");
            $(HILITE break);
        }

        writeln("Thank you for ", number);
    }

    writeln("Exited the loop");
}
---

$(P
We can summarize this behavior as $(I take numbers as long as they are greater than or equal to 0 or until a number is 42).
)

$(P
$(C break) works with $(C do-while), $(C for), $(C foreach), and $(C switch) statements as well. We will see these features in later chapters.
)

$(H5 $(IX loop, infinite) $(IX loop, unconditional) $(IX infinite loop) $(IX unconditional loop) Unconditional loop)

$(P
Sometimes the logical expression is intentionally made a constant $(C true). The $(C break) statement is a common way of exiting such $(I unconditional loops). ($(I Infinite loop) is an alternative but not completely accurate term that means unconditional loop.)
)

$(P
The following program prints a menu in an unconditional loop; the only way of exiting the loop is a $(C break) statement:
)

---
import std.stdio;

void main() {
    /* Unconditional loop, because the logical expression is always
     * true */
    while ($(HILITE true)) {
        write("0:Exit, 1:Turkish, 2:English - Your choice? ");

        int choice;
        readf(" %s", &choice);

        if (choice == 0) {
            writeln("See you later...");
            $(HILITE break);   // The only exit of this loop

        } else if (choice == 1) {
            writeln("Merhaba!");

        } else if (choice == 2) {
            writeln("Hello!");

        } else {
            writeln("Sorry, I don't know that language. :/");
        }
    }
}
---

$(P
$(I $(B Note:)) Exceptions $(I can terminate an unconditional loop as well. We will see exceptions in a later chapter.)
)

$(PROBLEM_COK

$(PROBLEM
The following program is designed to stay in the loop as long as the input is 3, but there is a bug: it doesn't ask for any input:

---
import std.stdio;

void main() {
    int number;

    while (number == 3) {
        write("Number? ");
        readf(" %s", &number);
    }
}
---

$(P
Fix the bug. The program should stay in the loop as long as the input is 3.
)

)

$(PROBLEM
Make the computer help Anna and Bill play a game. First, the computer should take a number from Anna in the range from 1 to 10. The program should not accept any other number; it should ask again.

$(P
Once the program takes a valid number from Anna, it should start taking numbers from Bill until he guesses Anna's number correctly.
)

$(P
$(I $(B Note:) The numbers that Anna enters obviously stay on the terminal and can be seen by Bill. Let's ignore this fact and write the program as an exercise of the $(C while) statement.)
)

)

)

Macros:
        TITLE=while Loop

        DESCRIPTION=The while loop and the related statements break and continue

        KEYWORDS=d programming language tutorial book while loop statement break continue

MINI_SOZLUK=
