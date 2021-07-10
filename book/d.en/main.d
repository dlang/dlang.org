Ddoc

$(DERS_BOLUMU $(IX program environment) Program Environment)

$(P
$(IX main) We have seen that $(C main()) is a function. Program execution starts with $(C main()) and branches off to other functions from there. The definition of $(C main()) that we have used so far has been the following:
)

---
void main() {
    // ...
}
---

$(P
According to that definition $(C main()) does not take any parameters and does not return a value. In reality, in most systems every program necessarily returns a value to its environment when it ends, which is called an exit status or return code. Because of this, although it is possible to specify the return type of $(C main()) as $(C void), it will actually return a value to the operating system or launch environment.
)

$(H5 The return value of $(C main()))

$(P
Programs are always started by an entity in a particular environment. The entity that starts the program may be the shell where the user types the name of the program and presses the Enter key, a development environment where the programmer clicks the [Run] button, and so on.
)

$(P
In D and several other programming languages, the program communicates its exit status to its environment by the return value of $(C main()).
)

$(P
The exact meaning of return codes depend on the application and the system. In almost all systems a return value of zero means a successful completion, while other values generally mean some type of failure. There are exceptions to this, though. For instance, in OpenVMS even values indicate failure, while odd values indicate success. Still, in most systems the values in the range [0, 125] can be used safely, with values 1 to 125 having a meaning specific to that program.
)

$(P
For example, the common Unix program $(C ls), which is used for listing contents of directories, returns 0 for success, 1 for minor errors and 2 for serious ones.
)

$(P
In many environments, the return value of the program that has been executed most recently in the terminal can be seen through the $(C $?) environment variable. For example, when we ask $(C ls) to list a file that does not exist, its nonzero return value can be observed with $(C $?) as seen below.
)

$(P
$(I $(B Note:) In the command line interactions below, the lines that start with $(C #) indicate the lines that the user types. If you want to try the same commands, you must enter the contents of those lines except for the $(C #) character. Also, the commands below start a program named $(C deneme); replace that name with the name of your test program.)
)

$(P
$(I Additionally, although the following examples show interactions in a Linux terminal, they would be similar but not exactly the same in terminals of other operating systems.)
)

$(SHELL
# ls a_file_that_does_not_exist
$(SHELL_OBSERVED ls: cannot access a_file_that_does_not_exist: No such file
or directory)
# $(HILITE echo $?)
$(SHELL_OBSERVED 2)      $(SHELL_NOTE the return value of ls)
)

$(H6 $(C main()) always returns a value)

$(P
Some of the programs that we have written so far threw exceptions when they could not continue with their tasks. As much as we have seen so far, when an exception is thrown, the program ends with an $(C object.Exception) error message.
)

$(P
When that happens, even if $(C main()) has been defined as returning $(C void), a nonzero status code is automatically returned to the program's environment. Let's see this in action in the following simple program that terminates with an exception:
)

---
void main() {
    throw new Exception("There has been an error.");
}
---

$(P
Although the return type is specified as $(C void), the return value is nonzero:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED object.Exception: There has been an error.
...)
# echo $?
$(SHELL_OBSERVED $(HILITE 1))
)

$(P
Similarly, $(C void main()) functions that terminate successfully also automatically return zero as their return values. Let's see this with the following program that terminates $(I successfully):
)

---
import std.stdio;

void main() {
    writeln("Done!");
}
---

$(P
The program returns zero:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED Done!)
# echo $?
$(SHELL_OBSERVED $(HILITE 0))
)

$(H6 Specifying the return value)

$(P
To choose a specific return code we return a value from $(C main()) in the same way as we would from any other function. The return type must be specified as $(C int) and the value must be returned by the $(C return) statement:
)

---
import std.stdio;

$(HILITE int) main() {
    int number;
    write("Please enter a number between 3 and 6: ");
    readf(" %s", &number);

    if ((number < 3) || (number > 6)) {
        $(HILITE stderr).writefln("ERROR: %s is not valid!", number);
        $(HILITE return 111);
    }

    writefln("Thank you for %s.", number);

    $(HILITE return 0);
}
---

$(P
When the entered number is within the valid range, the return value of the program is zero:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED Please enter a number between 3 and 6: 5
Thank you for 5.)
# echo $?
$(SHELL_OBSERVED $(HILITE 0))
)

$(P
When the number is outside of the valid range, the return value of the program is 111:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED Please enter a number between 3 and 6: 10
ERROR: 10 is not valid!)
# echo $?
$(SHELL_OBSERVED $(HILITE 111))
)

$(P
The value of 111 in the above program is arbitrary; normally 1 is suitable as the failure code.
)

$(H5 $(IX stderr) Standard error stream $(C stderr))

$(P
The program above uses the stream $(C stderr). That stream is the third of the standard streams. It is used for writing error messages:
)

$(UL
$(LI $(C stdin): standard input stream)
$(LI $(C stdout): standard output stream)
$(LI $(C stderr): standard error stream)
)

$(P
When a program is started in a terminal, normally the messages that are written to $(C stdout) and $(C stderr) both appear on the terminal window. When needed, it is possible to redirect these outputs individually. This subject is outside of the focus of this chapter and the details may vary for each shell program.
)

$(H5 Parameters of $(C main()))

$(P
It is common for programs to take parameters from the environment that started them. For example, we have already passed a file name as a command line option to $(C ls) above. There are two command line options in the following line:
)

$(SHELL
# ls $(HILITE -l deneme)
$(SHELL_OBSERVED -rwxr-xr-x 1 acehreli users 460668 Nov  6 20:38 deneme)
)

$(P
The set of command line parameters and their meanings are defined entirely by the program. Every program documents its usage, including what every parameter means.
)

$(P
The arguments that are used when starting a D program are passed to that program's $(C main()) as a slice of $(C string)s. Defining $(C main()) as taking a parameter of type $(C string[]) is sufficient to have access to program arguments. The name of this parameter is commonly abbreviated as $(C args). The following program prints all of the arguments with which it is started:
)

---
import std.stdio;

void main($(HILITE string[] args)) {
    foreach (i, arg; args) {
        writefln("Argument %-3s: %s", i, arg);
    }
}
---

$(P
Let's start the program with arbitrary arguments:
)

$(SHELL
# ./deneme some arguments on the command line 42 --an-option
$(SHELL_OBSERVED Argument 0  : ./deneme
Argument 1  : some
Argument 2  : arguments
Argument 3  : on
Argument 4  : the
Argument 5  : command
Argument 6  : line
Argument 7  : 42
Argument 8  : --an-option)
)

$(P
In almost all systems, the first argument is the name of the program, in the way it has been entered by the user. The other arguments appear in the order they were entered.
)

$(P
It is completely up to the program how it makes use of the arguments. The following program prints its two arguments in reverse order:
)

---
import std.stdio;

int main(string[] args) {
    if (args.length != 3) {
        stderr.writefln("ERROR! Correct usage:\n" ~
                        "  %s word1 word2", args[0]);
        return 1;
    }

    writeln(args[2], ' ', args[1]);

    return 0;
}
---

$(P
The program also shows its correct usage if you don't enter exactly two words:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED ERROR! Correct usage:
  ./deneme word1 word2)
# ./deneme world hello
$(SHELL_OBSERVED hello world)
)

$(H5 $(IX command line options) $(IX getopt, std.getopt) Command line options and the $(C std.getopt) module)

$(P
That is all there is to know about the parameters and the return value of $(C main()). However, parsing the arguments is a repetitive task. The $(C std.getopt) module is designed to help with parsing the command line options of programs.
)

$(P
Some parameters like "world" and "hello" above are purely data for the program to use. Other kinds of parameters are called $(I command line options), and are used to change the behaviors of programs. An example of a command line option is the $(C -l) option that has been passed to $(C ls) above.
)

$(P
Command line options make programs more useful by removing the need for a human user to interact with the program to have it behave in a certain way. With command line options, programs can be started from script programs and their behaviors can be specified through command line options.
)

$(P
Although the syntax and meanings of command line arguments of every program is specific to that program, their format is somewhat standard. For example, in POSIX, command line options start with $(C --) followed  by the name of the option, and values come after $(C =) characters:
)

$(SHELL
# ./deneme --an-option=17
)

$(P
The $(C std.getopt) module simplifies parsing such options. It has more capabilities than what is covered in this section.
)

$(P
Let's design a program that prints random numbers. Let's take the minimum, maximum, and total number of these numbers as program arguments. Let's require the following syntax to get these values from the command line:
)

$(SHELL
# ./deneme --count=7 --minimum=10 --maximum=15
)

$(P
The $(C getopt()) function parses and assigns those values to variables. Similarly to $(C readf()), the addresses of variables must be specified by the $(C &) operator:
)

---
import std.stdio;
$(HILITE import std.getopt;)
import std.random;

void main(string[] args) {
    int count;
    int minimum;
    int maximum;

    $(HILITE getopt)(args,
           "count", $(HILITE &)count,
           "minimum", $(HILITE &)minimum,
           "maximum", $(HILITE &)maximum);

    foreach (i; 0 .. count) {
        write(uniform(minimum, maximum + 1), ' ');
    }

    writeln();
}
---

$(SHELL
# ./deneme --count=7 --minimum=10 --maximum=15
$(SHELL_OBSERVED 11 11 13 11 14 15 10)
)

$(P
Many command line options of most programs have a shorter syntax as well. For example, $(C -c) may have the same meaning as $(C --count). Such alternative syntax for each option is specified in $(C getopt()) after a $(C |) character. There may be more than one shortcut for each option:
)

---
    getopt(args,
           "count|c", &count,
           "minimum|n", &minimum,
           "maximum|x", &maximum);
---

$(P
It is common to use a single dash for the short versions and the $(C =) character is usually either omitted or substituted by a space:
)

$(SHELL
# ./deneme -c7 -n10 -x15
$(SHELL_OBSERVED 11 13 10 15 14 15 14)
# ./deneme -c 7 -n 10 -x 15  
$(SHELL_OBSERVED 11 13 10 15 14 15 14)
)

$(P
$(C getopt()) converts the arguments from $(C string) to the type of each variable. For example, since $(C count) above is an $(C int), $(C getopt()) converts the value specified for the $(C --count) argument to an $(C int). When needed, such conversions may also be performed explicitly by $(C to).
)

$(P
So far we have used $(C std.conv.to) only when converting to $(C string). $(C to) can, in fact, convert from any type to any type, as long as that conversion is possible. For example, the following program takes advantage of $(C to) when converting its argument to $(C size_t):
)

---
import std.stdio;
$(HILITE import std.conv);

void main(string[] args) {
    // The default count is 10
    size_t count = 10;

    if (args.length > 1) {
        // There is an argument
        count = $(HILITE to!size_t)(args[1]);
    }

    foreach (i; 0 .. count) {
        write(i * 2, ' ');
    }

    writeln();
}
---


$(P
The program produces 10 numbers when no argument is specified:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED 0 2 4 6 8 10 12 14 16 18)
# ./deneme 3
$(SHELL_OBSERVED 0 2 4)
)

$(H5 $(IX environment variable) Environment variables)

$(P
The environment that a program is started in generally provides some variables that the program can make use of. The environment variables can be accessed through the associative array interface of $(C std.process.environment). For example, the following program prints the $(C PATH) environment variable:
)

---
import std.stdio;
$(HILITE import std.process;)

void main() {
    writeln($(HILITE environment["PATH"]));
}
---

$(P
The output:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED /usr/local/bin:/usr/bin)
)

$(P
$(C std.process.environment) provides access to the environment variables through the associative array syntax. However, $(C environment) itself is not an associative array. When needed, the environment variables can be converted to an associative array by using $(C toAA()):
)

---
    string[string] envVars = environment.toAA();
---

$(H5 $(IX executeShell, std.process) Starting other programs)

$(P
Programs may start other programs and become the $(I environment) for those programs. A function that enables this is $(C executeShell), from the $(C std.process) module.
)

$(P
$(C executeShell) executes its parameter as if the command was typed at the terminal. It then returns both the return code and the output of that command as a $(I tuple). Tuples are array-like structures, which we will see later in $(LINK2 tuples.html, the Tuples chapter):
)

---
import std.stdio;
import std.process;

void main() {
    const result = $(HILITE executeShell)("ls -l deneme");
    const returnCode = result[0];
    const output = result[1];

    writefln("ls returned %s.", returnCode);
    writefln("Its output:\n%s", output);
}
---

$(P
The output:
)

$(SHELL
# ./deneme
$(SHELL_OBSERVED
ls returned 0.
Its output:
-rwxrwxr-x. 1 acehreli acehreli 1359178 Apr 21 15:01 deneme
)
)

$(H5 Summary)

$(UL

$(LI Even when it is defined with a return type of $(C void), $(C main()) automatically returns zero for success and nonzero for failure.)

$(LI $(C stderr) is suitable to print error messages.)

$(LI $(C main) can take parameters as $(C string[]).)

$(LI $(C std.getopt) helps with parsing command line options.)

$(LI $(C std.process) helps with accessing environment variables and starting other programs.)

)

$(PROBLEM_COK

$(PROBLEM
Write a calculator program that takes an operator and two operands as command line arguments. Have the program support the following usage:

$(SHELL
# ./deneme 3.4 x 7.8
$(SHELL_OBSERVED 26.52)
)

$(P
$(I $(B Note:) Because the $(C *) character has a special meaning on most terminals (more accurately, on most $(I shells)), I have used $(C x) instead. You may still use $(C *) as long as it is $(I escaped) as $(C \*).)
)

)

$(PROBLEM
Write a program that asks the user which program to start, starts that program, and prints its output.
)

)

Macros:
        TITLE=Program Environment

        DESCRIPTION=The return value and parameters of main(), environment variables, and starting other programs from D programs.

        KEYWORDS=d programming language tutorial book environment
