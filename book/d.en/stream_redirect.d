Ddoc

$(DERS_BOLUMU $(IX redirect, stream) Redirecting the Standard Input and Output Streams)

$(P
All of the programs that we have seen so far have interacted through $(C stdin) and $(C stdout), the standard input and output streams. Input and output functions like $(C readf) and $(C writeln) operate on these streams by default.
)

$(P
While using these streams, we assumed that the standard input comes from the keyboard and that the standard output goes to the screen.
)

$(P
We will start writing programs that deal with files in later chapters. We will see that, just like the standard input and output streams, files are character streams as well; so they are used in almost the same way as $(C stdin) and $(C stdout).
)

$(P
But before seeing how files are accessed from within programs, I would like to show how the standard inputs and outputs of programs can be redirected to files or piped to other programs. Existing programs can, without their source code being changed, be made to print to files instead of the screen, and read from files instead of the keyboard. Although these features are not directly related to programming languages, they are useful tools that are available in nearly all modern shells.
)

$(H5 $(IX >, output redirect) Redirecting the standard output to a file with operator $(C >))

$(P
When starting the program from the terminal, typing a $(C >) character and a file name at the end of the command line redirects the standard output of that program to the specified file. Everything that the program prints to its standard output will be written to that file instead.
)

$(P
Let's test this with a program that reads a floating point number from its input, multiplies that number by two, and prints the result to its standard output:
)

---
import std.stdio;

void main() {
    double number;
    readf(" %s", &number);

    writeln(number * 2);
}
---

$(P
If the name of the program is $(C by_two), its output will be written to a file named $(C by_two_result.txt) when the program is started on the command line as in the following line:
)

$(SHELL
./by_two > by_two_result.txt
)

$(P
For example, if we enter $(C 1.2) at the terminal, the result $(C 2.4) will appear in $(C by_two_result.txt). ($(I $(B Note:) Although the program does not display a prompt like "Please enter a number", it still expects a number to be entered.))
)

$(H5 $(IX <, input redirect) Redirecting the standard input from a file with operator $(C <))

$(P
Similarly to redirecting the standard output by using the $(C >) operator, the standard input can be redirected from a file by using the $(C <) operator. In this case, the program reads from the specified file instead of from the keyboard.
)

$(P
To test this, let's use a program that calculates one tenth of a number:
)

---
import std.stdio;

void main() {
    double number;
    readf(" %s", &number);

    writeln(number / 10);
}
---

$(P
Assuming that the file $(C by_two_result.txt) still exists and contains $(C 2.4) from the previous output, and that the name of the new program is $(C one_tenth), we can redirect the new program's standard input from that file as in the following line:
)

$(SHELL
./one_tenth < by_two_result.txt
)

$(P
This time the program will read from $(C by_two_result.txt) and print the result to the terminal as $(C 0.24).
)

$(H5 Redirecting both standard streams)

$(P
The operators $(C >) and $(C <) can be used at the same time:
)

$(SHELL
./one_tenth < by_two_result.txt > one_tenth_result.txt
)

$(P
This time the standard input will be read from $(C by_two_result.txt) and the standard output will be written to $(C one_tenth_result.txt).
)

$(H5 $(IX |, stream pipe) Piping programs with operator $(C |))

$(P
Note that $(C by_two_result.txt) is an intermediary between the two programs; $(C by_two) writes to it and $(C one_tenth) reads from it.
)

$(P
The $(C |) operator pipes the standard output of the program that is on its left-hand side to the standard input of the program that is on its right-hand side without the need for an intermediary file. For example, when the two programs above are piped together as in the following line, they collectively calculate $(I one fifth) of the input:
)

$(SHELL
./by_two | ./one_tenth
)

$(P
First $(C by_two) reads a number from its input. (Remember that although it does not prompt for one, it still waits for a number.) Then $(C by_two) writes the result to its standard output. This result of $(C by_two) will appear on the standard input of $(C one_tenth), which in turn will calculate and print one tenth of that result.
)

$(PROBLEM_TEK

$(P
Pipe more than one program:
)

$(SHELL
./one | ./two | ./three
)

)

Macros:
        TITLE=Redirecting the Standard Input and Output Streams

        DESCRIPTION=Reading from files and other programs instead of from the keyboard, and printing to files and other programs instead of the terminal.

        KEYWORDS=d programming language tutorial book redirect standard input output
