Ddoc

$(DERS_BOLUMU $(IX do-while) $(IX loop, do-while) $(CH4 do-while) Loop)

$(P
In the $(LINK2 for.html, $(C for) Loop chapter) we saw the steps in which the $(LINK2 while.html, $(C while) loop) is executed:
)

$(MONO
preparation

condition check
actual work
iteration

condition check
actual work
iteration

...
)

$(P
The $(C do-while) loop is very similar to the $(C while) loop. The difference is that the $(I condition check) is performed at the end of each iteration of the $(C do-while) loop, so that the $(I actual work) is performed at least once:
)

$(MONO
preparation

actual work
iteration
condition check    $(SHELL_NOTE at the end of the iteration)

actual work
iteration
condition check    $(SHELL_NOTE at the end of the iteration)

...
)

$(P
For example, $(C do-while) may be more natural in the following program where the user guesses a number, as the user must guess at least once so that the number can be compared:
)

---
import std.stdio;
import std.random;

void main() {
    int number = uniform(1, 101);

    writeln("I am thinking of a number between 1 and 100.");

    int guess;

    do {
        write("What is your guess? ");

        readf(" %s", &guess);

        if (number < guess) {
            write("My number is less than that. ");

        } else if (number > guess) {
            write("My number is greater than that. ");
        }

    } while (guess != number);

    writeln("Correct!");
}
---

$(P
The function $(C uniform()) that is used in the program is a part of the $(C std.random) module. It returns a random number in the specified range. The way it is used above, the second number is considered to be outside of the range. In other words, $(C uniform()) would not return 101 for that call.
)

$(PROBLEM_TEK

$(P
Write a program that plays the same game but have the program do the guessing. If the program is written correctly, it should be able to guess the user's number in at most 7 tries.
)

)

Macros:
        TITLE=do-while Loop

        DESCRIPTION=The do-while loop of the D programming languageh and comparing it to the while loop

        KEYWORDS=d programming language tutorial book do while loop
