Ddoc

$(DERS_BOLUMU $(IX input) Reading from the Standard Input)

$(P
Any data that is read by the program must first be stored in a variable. For example, a program that reads the number of students from the input must store this information in a variable. The type of this specific variable can be $(C int).
)

$(P
As we've seen in the previous chapter, we don't need to type $(C stdout) when printing to the output, because it is implied. Further, what is to be printed is specified as the argument. So, $(C write(studentCount)) is sufficient to print the value of $(C studentCount). To summarize:
)

$(MONO
stream:      stdout
operation:   write
data:        the value of the studentCount variable
target:      commonly the terminal window
)

$(P
$(IX readf) The reverse of $(C write) is $(C readf); it reads from the standard input. The "f" in its name comes from "formatted" as what it reads must always be presented in a certain format.
)

$(P
We've also seen in the previous chapter that the standard input stream is $(C stdin).
)

$(P
In the case of reading, one piece of the puzzle is still missing: where to store the data. To summarize:
)

$(MONO
stream:      stdin
operation:   readf
data:        some information
target:      ?
)

$(P
The location of where to store the data is specified by the address of a variable. The address of a variable is the exact location in the computer's memory where its value is stored.
)

$(P
$(IX &, address of) In D, the $(C &) character that is typed before a name is the address of what that name represents. For example, the address of $(C studentCount) is $(C &amp;studentCount). Here, $(C &amp;studentCount) can be read as "the address of $(C studentCount)" and is the missing piece to replace the question mark above:
)

$(MONO
stream:      stdin
operation:   readf
data:        some information
target:      the location of the studentCount variable
)

$(P
Typing a $(C &) in front of a name means $(I pointing) at what that name represents. This concept is the foundation of references and pointers that we will see in later chapters.
)

$(P
I will leave one peculiarity about the use of $(C readf) for later; for now, let's accept as a rule that the first argument to $(C readf) must be $(STRING "%s"):
)

---
    readf("%s", &studentCount);
---

$(P
Actually, $(C readf) can work without the $(C &) character as well:
)

---
    readf("%s", studentCount);    // same as above
---

$(P
Although the code is cleaner and safer without the $(C &) character, I will continue to use $(C readf) with pointers partly to prepare you to the concepts of $(LINK2 value_vs_reference.html, references) and $(LINK2 function_parameters.html, reference function parameters).
)

$(P
$(STRING "%s") indicates that the data should automatically be converted in a way that is suitable to the type of the variable. For example, when the '4' and '2' characters are read to a variable of type $(C int), they are converted to the integer value 42.
)

$(P
The program below asks the user to enter the number of students. You must press the Enter key after typing the input:
)

---
import std.stdio;

void main() {
    write("How many students are there? ");

    /* The definition of the variable that will be used to
     * store the information that is read from the input. */
    int studentCount;

    // Storing the input data to that variable
    readf("%s", &studentCount);

    writeln("Got it: There are ", studentCount, " students.");
}
---

$(H5 $(IX %s, with whitespace) $(IX whitespace) Skipping the whitespace characters)

$(P
Even the Enter key that we press after typing the data is stored as a special code and is placed into the $(C stdin) stream. This is useful to the programs to detect whether the information has been input on a single line or multiple lines.
)

$(P
Although sometimes useful, such special codes are mostly not important for the program and must be filtered out from the input. Otherwise they $(I block) the input and prevent reading other data.
)

$(P
To see this $(I problem) in a program, let's also read the number of teachers from the input:
)

---
import std.stdio;

void main() {
    write("How many students are there? ");
    int studentCount;
    readf("%s", &studentCount);

    write("How many teachers are there? ");
    int teacherCount;
    readf("%s", &teacherCount);

    writeln("Got it: There are ", studentCount, " students",
            " and ", teacherCount, " teachers.");
}
---

$(P
Unfortunately, the program cannot use that special code when expecting an $(C int) value:
)

$(SHELL
How many students are there? 100
How many teachers are there? 20
  $(SHELL_NOTE_WRONG An exception is thrown here)
)

$(P
Although the user enters the number of teachers as 20, the special code(s) that represents the Enter key that has been pressed when entering the previous 100 is still in the input stream and is blocking it. The characters that appeared in the input stream are similar to the following representation:
)

$(MONO
100$(HILITE [EnterCode])20[EnterCode]
)

$(P
I have highlighted the Enter code that is blocking the input.
)

$(P
The solution is to use a space character before $(STRING %s) to indicate that the Enter code that appears before reading the number of teachers is not important: $(STRING "&nbsp;%s"). Spaces that are in the format strings are used to read and ignore zero or more invisible characters that would otherwise appear in the input. Such characters include the actual space character, the code(s) that represent the Enter key, the Tab character, etc. and are called the $(I whitespace characters).
)

$(P
As a general rule, you can use $(STRING "&nbsp;%s") for every data that is read from the input. The program above works as expected with the following changes:
)

---
// ...
    readf(" %s", &studentCount);
// ...
    readf(" %s", &teacherCount);
// ...
---

$(P
The output:
)

$(SHELL
How many students are there? 100
How many teachers are there? 20
Got it: There are 100 students and 20 teachers.
)

$(H5 Additional information)

$(UL

$(LI
$(IX comment) $(IX /*) $(IX */) Lines that start with $(COMMENT //) are useful for single lines of comments. To write multiple lines as a single comment, enclose the lines within $(COMMENT /*) and $(COMMENT */) markers.


$(P
$(IX /+) $(IX +/) In order to be able to comment even other comments, use $(COMMENT /+) and $(COMMENT +/):

)

---
    /+
     // A single line of comment

     /*
       A comment that spans
       multiple lines
      */

      /+
        It can even include nested /+ comments +/
      +/

      A comment block that includes other comments
     +/
---

)

$(LI
Most of the whitespace in the source code is insignificant. It is good practice to write longer expressions as multiple lines or add extra whitespace to make the code more readable. Still, as long as the syntax rules of the language are observed, the programs can be written without any extra whitespace:

---
import std.stdio;void main(){writeln("Hard to read!");}
---

$(P
It can be hard to read source code with small amounts of whitespace.
)

)

)

$(PROBLEM_TEK

$(P
Enter non-numerical characters when the program is expecting integer values and observe that the program does not work correctly.
)

)


Macros:
        TITLE=Reading from the Standard Input

        DESCRIPTION=Getting information from the input in D

        KEYWORDS=d programming language tutorial book read stdin

MINI_SOZLUK=
