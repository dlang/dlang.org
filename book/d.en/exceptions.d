Ddoc

$(DERS_BOLUMU $(IX exception) Exceptions)

$(P
Unexpected situations are parts of programs: user mistakes, programming errors, changes in the program environment, etc. Programs must be written in ways to avoid producing incorrect results when faced with such $(I exceptional) conditions.
)

$(P
Some of these conditions may be severe enough to stop the execution of the program. For example, a required piece of information may be missing or invalid, or a device may not be functioning correctly. The exception handling mechanism of D helps with stopping program execution when necessary, and to recover from the unexpected situations when possible.
)

$(P
As an example of a severe condition, we can think of passing an unknown operator to a function that knows only the four arithmetic operators, as we have seen in the exercises of the previous chapter:
)

---
    switch (operator) {

    case "+":
        writeln(first + second);
        break;

    case "-":
        writeln(first - second);
        break;

    case "x":
        writeln(first * second);
        break;

    case "/":
        writeln(first / second);
        break;

    default:
        throw new Exception(format("Invalid operator: %s", operator));
    }
---

$(P
The $(C switch) statement above does not know what to do with operators that are not listed on the $(C case) statements; so throws an exception.
)

$(P
There are many examples of thrown exceptions in Phobos. For example, $(C to!int), which can be used to convert a string representation of an integer to an $(C int) value throws an exception when that representation is not valid:
)

---
import std.conv;

void main() {
    const int value = to!int("hello");
}
---

$(P
The program terminates with an exception that is thrown by $(C to!int):
)

$(SHELL
std.conv.ConvException@std/conv.d(38): std.conv(1157): $(HILITE Can't
convert value) `hello' of type const(char)[] to type int
)

$(P
$(C std.conv.ConvException) at the beginning of the message is the type of the thrown exception object. We can tell from the name that the type is $(C ConvException) that is defined in the $(C std.conv) module.
)

$(H5 $(IX throw) The $(C throw) statement to throw exceptions)

$(P
We've seen the $(C throw) statement both in the examples above and in the previous chapters.
)

$(P
$(C throw) throws an $(I exception object) and this terminates the current operation of the program. The expressions and statements that are written after the $(C throw) statement are not executed. This behavior is according to the nature of exceptions: they must be thrown when the program cannot continue with its current task.
)

$(P
Conversely, if the program could continue then the situation would not warrant throwing an exception. In such cases the function would find a way and continue.
)

$(H6 $(IX Exception) $(IX Error) $(IX Throwable) The exception types $(C Exception) and $(C Error))

$(P
Only the types that are inherited from the $(C Throwable) class can be thrown. $(C Throwable) is almost never used directly in programs. The types that are actually thrown are types that are inherited from $(C Exception) or $(C Error), which themselves are the types that are inherited from $(C Throwable). For example, all of the exceptions that Phobos throws are inherited from either $(C Exception) or $(C Error).
)

$(P
$(C Error) represents unrecoverable conditions and is not recommended to be $(I caught). For that reason, most of the exceptions that a program throws are the types that are inherited from $(C Exception). ($(I $(B Note:) Inheritance is a topic related to classes. We will see classes in a later chapter.))
)

$(P
$(C Exception) objects are constructed with a $(C string) value that represents an error message. You may find it easy to create this message with the $(C format()) function from the $(C std.string) module:
)

---
import std.stdio;
import std.random;
import std.string;

int[] randomDiceValues(int count) {
    if (count < 0) {
        $(HILITE throw new Exception)(
            format("Invalid dice count: %s", count));
    }

    int[] values;

    foreach (i; 0 .. count) {
        values ~= uniform(1, 7);
    }

    return values;
}

void main() {
    writeln(randomDiceValues(-5));
}
---

$(SHELL
object.Exception...: Invalid dice count: -5
)

$(P
In most cases, instead of creating an exception object explicitly by $(C new) and throwing it explicitly by $(C throw), the $(C enforce()) function is called. For example, the equivalent of the error check above is the following $(C enforce()) call:
)

---
    enforce(count >= 0, format("Invalid dice count: %s", count));
---

$(P
We will see the differences between $(C enforce()) and $(C assert()) in a later chapter.
)

$(H6 Thrown exception terminates all scopes)

$(P
We have seen that the program execution starts from the $(C main) function and branches into other functions from there. This layered execution of going deeper into functions and eventually returning from them can be seen as the branches of a tree.
)

$(P
For example, $(C main()) may call a function named $(C makeOmelet), which in turn may call another function named $(C prepareAll), which in turn may call another function named $(C prepareEggs), etc. Assuming that the arrows indicate function calls, the branching of such a program can be shown as in the following function call tree:
)

$(MONO
main
  │
  ├──▶ makeOmelet
  │      │
  │      ├──▶ prepareAll
  │      │          │
  │      │          ├─▶ prepareEggs
  │      │          ├─▶ prepareButter
  │      │          └─▶ preparePan
  │      │
  │      ├──▶ cookEggs
  │      └──▶ cleanAll
  │
  └──▶ eatOmelet
)

$(P
The following program demonstrates the branching above by using different levels of indentation in its output. The program doesn't do anything useful other than producing an output suitable to our purposes:
)

---
$(CODE_NAME all_functions)import std.stdio;

void indent(int level) {
    foreach (i; 0 .. level * 2) {
        write(' ');
    }
}

void entering(string functionName, int level) {
    indent(level);
    writeln("▶ ", functionName, "'s first line");
}

void exiting(string functionName, int level) {
    indent(level);
    writeln("◁ ", functionName, "'s last line");
}

void main() {
    entering("main", 0);
    makeOmelet();
    eatOmelet();
    exiting("main", 0);
}

void makeOmelet() {
    entering("makeOmelet", 1);
    prepareAll();
    cookEggs();
    cleanAll();
    exiting("makeOmelet", 1);
}

void eatOmelet() {
    entering("eatOmelet", 1);
    exiting("eatOmelet", 1);
}

void prepareAll() {
    entering("prepareAll", 2);
    prepareEggs();
    prepareButter();
    preparePan();
    exiting("prepareAll", 2);
}

void cookEggs() {
    entering("cookEggs", 2);
    exiting("cookEggs", 2);
}

void cleanAll() {
    entering("cleanAll", 2);
    exiting("cleanAll", 2);
}

void prepareEggs() {
    entering("prepareEggs", 3);
    exiting("prepareEggs", 3);
}

void prepareButter() {
    entering("prepareButter", 3);
    exiting("prepareButter", 3);
}

void preparePan() {
    entering("preparePan", 3);
    exiting("preparePan", 3);
}
---

$(P
The program produces the following output:
)

$(SHELL
▶ main, first line
  ▶ makeOmelet, first line
    ▶ prepareAll, first line
      ▶ prepareEggs, first line
      ◁ prepareEggs, last line
      ▶ prepareButter, first line
      ◁ prepareButter, last line
      ▶ preparePan, first line
      ◁ preparePan, last line
    ◁ prepareAll, last line
    ▶ cookEggs, first line
    ◁ cookEggs, last line
    ▶ cleanAll, first line
    ◁ cleanAll, last line
  ◁ makeOmelet, last line
  ▶ eatOmelet, first line
  ◁ eatOmelet, last line
◁ main, last line
)

$(P
The functions $(C entering) and $(C exiting) are used to indicate the first and last lines of functions with the help of the $(C ▶) and $(C ◁) characters. The program starts with the first line of $(C main()), branches down to other functions, and finally ends with the last line of $(C main).
)

$(P
Let's modify the $(C prepareEggs) function to take the number of eggs as a parameter. Since certain values of this parameter would be an error, let's have this function throw an exception when the number of eggs is less than one:
)

---
$(CODE_NAME prepareEggs_int)import std.string;

// ...

void prepareEggs($(HILITE int count)) {
    entering("prepareEggs", 3);

    if (count < 1) {
        throw new Exception(
            format("Cannot take %s eggs from the fridge", count));
    }

    exiting("prepareEggs", 3);
}
---

$(P
In order to be able to compile the program, we must modify other lines of the program to be compatible with this change. The number of eggs to take out of the fridge can be handed down from function to function, starting with $(C main()). The parts of the program that need to change are the following. The invalid value of -8 is intentional to show how the output of the program will be different from the previous output when an exception is thrown:
)

---
$(CODE_NAME makeOmelet_int_etc)$(CODE_XREF all_functions)$(CODE_XREF prepareEggs_int)// ...

void main() {
    entering("main", 0);
    makeOmelet($(HILITE -8));
    eatOmelet();
    exiting("main", 0);
}

void makeOmelet($(HILITE int eggCount)) {
    entering("makeOmelet", 1);
    prepareAll($(HILITE eggCount));
    cookEggs();
    cleanAll();
    exiting("makeOmelet", 1);
}

// ...

void prepareAll($(HILITE int eggCount)) {
    entering("prepareAll", 2);
    prepareEggs($(HILITE eggCount));
    prepareButter();
    preparePan();
    exiting("prepareAll", 2);
}

// ...
---

$(P
When we start the program now, we see that the lines that used to be printed after the point where the exception is thrown are missing:
)

$(SHELL
▶ main, first line
  ▶ makeOmelet, first line
    ▶ prepareAll, first line
      ▶ prepareEggs, first line
object.Exception: Cannot take -8 eggs from the fridge
)

$(P
When the exception is thrown, the program execution exits the $(C prepareEggs), $(C prepareAll), $(C makeOmelet) and $(C main()) functions in that order, from the bottom level to the top level. No additional steps are executed as the program exits these functions.
)

$(P
The rationale for such a drastic termination is that a failure in a lower level function would mean that the higher level functions that needed its successful completion should also be considered as failed.
)

$(P
The exception object that is thrown from a lower level function is transferred to the higher level functions one level at a time and causes the program to finally exit the $(C main()) function. The path that the exception takes can be shown as the highlighted path in the following tree:
)

$(MONO
     $(HILITE ▲)
     $(HILITE │)
     $(HILITE │)
main $(HILITE &nbsp;◀───────────┐)
  │               $(HILITE │)
  │               $(HILITE │)
  ├──▶ makeOmelet $(HILITE &nbsp;◀─────┐)
  │      │               $(HILITE │)
  │      │               $(HILITE │)
  │      ├──▶ prepareAll $(HILITE &nbsp;◀──────────┐)
  │      │          │                $(HILITE │)
  │      │          │                $(HILITE │)
  │      │          ├─▶ prepareEggs  $(HILITE X) $(I thrown exception)
  │      │          ├─▶ prepareButter
  │      │          └─▶ preparePan
  │      │
  │      ├──▶ cookEggs
  │      └──▶ cleanAll
  │
  └──▶ eatOmelet
)

$(P
The point of the exception mechanism is precisely this behavior of exiting all of the layers of function calls right away.
)

$(P
Sometimes it makes sense to $(I catch) the thrown exception to find a way to continue the execution of the program. I will introduce the $(C catch) keyword below.
)

$(H6 When to use $(C throw))

$(P
Use $(C throw) in situations when it is not possible to continue. For example, a function that reads the number of students from a file may throw an exception if this information is not available or incorrect.
)

$(P
On the other hand, if the problem is caused by some user action like entering invalid data, it may make more sense to validate the data instead of throwing an exception. Displaying an error message and asking the user to re-enter the data is more appropriate in many cases.
)

$(H5 $(IX try) $(IX catch) The $(C try-catch) statement to catch exceptions)

$(P
As we've seen above, a thrown exception causes the program execution to exit all functions and this finally terminates the whole program.
)

$(P
The exception object can be caught by a $(C try-catch) statement at any point on its path as it exits the functions. The $(C try-catch) statement models the phrase "$(I try) to do something, and $(I catch) exceptions that may be thrown." Here is the syntax of $(C try-catch):
)

---
    try {
        // the code block that is being executed, where an
        // exception may be thrown

    } catch ($(I an_exception_type)) {
        // expressions to execute if an exception of this
        // type is caught

    } catch ($(I another_exception_type)) {
        // expressions to execute if an exception of this
        // other type is caught

    // ... more catch blocks as appropriate ...

    } finally {
        // expressions to execute regardless of whether an
        // exception is thrown
    }
---

$(P
Let's start with the following program that does not use a $(C try-catch) statement at this state. The program reads the value of a die from a file and prints it to the standard output:
)

---
import std.stdio;

int readDieFromFile() {
    auto file = File("the_file_that_contains_the_value", "r");

    int die;
    file.readf(" %s", &die);

    return die;
}

void main() {
    const int die = readDieFromFile();

    writeln("Die value: ", die);
}
---

$(P
Note that the $(C readDieFromFile) function is written in a way that ignores error conditions, expecting that the file and the value that it contains are available. In other words, the function is dealing only with its own task instead of paying attention to error conditions. This is a benefit of exceptions: many functions can be written in ways that focus on their actual tasks, rather than focusing on error conditions.
)

$(P
Let's start the program when $(C the_file_that_contains_the_value) is missing:
)

$(SHELL
std.exception.ErrnoException@std/stdio.d(286): Cannot open
file $(BACK_TICK)the_file_that_contains_the_value' in mode $(BACK_TICK)r' (No such
file or directory)
)

$(P
An exception of type $(C ErrnoException) is thrown and the program terminates without printing "Die&nbsp;value:&nbsp;".
)

$(P
Let's add an intermediate function to the program that calls $(C readDieFromFile) from within a $(C try) block and let's have $(C main()) call this new function:
)

---
import std.stdio;

int readDieFromFile() {
    auto file = File("the_file_that_contains_the_value", "r");

    int die;
    file.readf(" %s", &die);

    return die;
}

int $(HILITE tryReadingFromFile)() {
    int die;

    $(HILITE try) {
        die = readDieFromFile();

    } $(HILITE catch) (std.exception.ErrnoException exc) {
        writeln("(Could not read from file; assuming 1)");
        die = 1;
    }

    return die;
}

void main() {
    const int die = $(HILITE tryReadingFromFile)();

    writeln("Die value: ", die);
}
---

$(P
When we start the program again when $(C the_file_that_contains_the_value) is still missing, this time the program does not terminate with an exception:
)

$(SHELL
(Could not read from file; assuming 1)
Die value: 1
)

$(P
The new program $(I tries) executing $(C readDieFromFile) in a $(C try) block. If that block executes successfully, the function ends normally with the $(C return die;) statement. If the execution of the $(C try) block ends with the specified $(C std.exception.ErrnoException), then the program execution enters the $(C catch) block.
)

$(P
The following is a summary of events when the program is started when the file is missing:
)

$(UL
$(LI like in the previous program, a $(C std.exception.ErrnoException) object is thrown (by $(C File()), not by our code),)
$(LI this exception is caught by $(C catch),)
$(LI the value of 1 is assumed during the normal execution of the $(C catch) block,)
$(LI and the program continues its normal operations.)
)

$(P
$(C catch) is to catch thrown exceptions to find a way to continue executing the program.
)

$(P
As another example, let's go back to the omelet program and add a $(C try-catch) statement to its $(C main()) function:
)

---
$(CODE_XREF makeOmelet_int_etc)void main() {
    entering("main", 0);

    try {
        makeOmelet(-8);
        eatOmelet();

    } catch (Exception exc) {
        write("Failed to eat omelet: ");
        writeln('"', exc.msg, '"');
        writeln("Will eat at neighbor's...");
    }

    exiting("main", 0);
}
---

$(P
($(I $(B Note:) The $(C .msg) property will be explained below.))
)

$(P
That $(C try) block contains two lines of code. Any exception thrown from either of those lines would be caught by the $(C catch) block.
)

$(SHELL
▶ main, first line
  ▶ makeOmelet, first line
    ▶ prepareAll, first line
      ▶ prepareEggs, first line
Failed to eat omelet: "Cannot take -8 eggs from the fridge"
Will eat at neighbor's...
◁ main, last line
)

$(P
As can be seen from the output, the program doesn't terminate because of the thrown exception anymore. It recovers from the error condition and continues executing normally till the end of the $(C main()) function.
)

$(H6 $(C catch) blocks are considered sequentially)

$(P
The type $(C Exception), which we have used so far in the examples is a general exception type. This type merely specifies that an error occurred in the program. It also contains a message that can explain the error further, but it does not contain information about the $(I type) of the error.
)

$(P
$(C ConvException) and $(C ErrnoException) that we have seen earlier in this chapter are more specific exception types: the former is about a conversion error, and the latter is about a system error. Like many other exception types in Phobos and as their names suggest, $(C ConvException) and $(C ErrnoException) are both inherited from the $(C Exception) class.
)

$(P
$(C Exception) and its sibling $(C Error) are further inherited from $(C Throwable), the most general exception type.
)

$(P
Although possible, it is not recommended to catch objects of type $(C Error) and objects of types that are inherited from $(C Error). Since it is more general than $(C Error), it is not recommended to catch $(C Throwable) either. What should normally be caught are the types that are under the $(C Exception) hierarchy, including $(C Exception) itself.
)

$(MONO
           Throwable $(I (not recommended to catch))
             ↗   ↖
    Exception     Error $(I (not recommended to catch))
     ↗    ↖        ↗    ↖
   ...    ...    ...    ...
)

$(P $(I $(B Note:) I will explain the hierarchy representations later in $(LINK2 inheritance.html, the Inheritance chapter). The tree above indicates that $(C Throwable) is the most general and $(C Exception) and $(C Error) are more specific.)
)

$(P
It is possible to catch exception objects of a particular type. For example, it is possible to catch an $(C ErrnoException) object specifically to detect and handle a system error.
)

$(P
Exceptions are caught only if they match a type that is specified in a $(C catch) block. For example, a catch block that is trying to catch a $(C SpecialExceptionType) would not catch an $(C ErrnoException).
)

$(P
The type of the exception object that is thrown during the execution of a $(C try) block is matched to the types that are specified by the $(C catch) blocks, in the order in which the $(C catch) blocks are written. If the type of the object matches the type of the $(C catch) block, then the exception is considered to be caught by that $(C catch) block, and the code that is within that block is executed. Once a match is found, the remaining $(C catch) blocks are ignored.
)

$(P
Because the $(C catch) blocks are matched in order from the first to the last, the $(C catch) blocks must be ordered from the most specific exception types to the most general exception types. Accordingly, and if it makes sense to catch that type of exceptions, the $(C Exception) type must be specified at the last $(C catch) block.
)

$(P
For example, a $(C try-catch) statement that is trying to catch several specific types of exceptions about student records must order the $(C catch) blocks from the most specific to the most general as in the following code:
)

---
    try {
        // operations about student records that may throw ...

    } catch (StudentIdDigitException exc) {

        // an exception that is specifically about errors with
        // the digits of student ids

    } catch (StudentIdException exc) {

        // a more general exception about student ids but not
        // necessarily about their digits

    } catch (StudentRecordException exc) {

        // even more general exception about student records

    } catch (Exception exc) {

        // the most general exception that may not be related
        // to student records

    }
---

$(H6 $(IX finally) The $(C finally) block)

$(P
$(C finally) is an optional block of the $(C try-catch) statement. It includes expressions that should be executed regardless of whether an exception is thrown or not.
)

$(P
To see how $(C finally) works, let's look at a program that throws an exception 50% of the time:
)

---
import std.stdio;
import std.random;

void throwsHalfTheTime() {
    if (uniform(0, 2) == 1) {
        throw new Exception("the error message");
    }
}

void foo() {
    writeln("the first line of foo()");

    try {
        writeln("the first line of the try block");
        throwsHalfTheTime();
        writeln("the last line of the try block");

    // ... there may be one or more catch blocks here ...

    } $(HILITE finally) {
        writeln("the body of the finally block");
    }

    writeln("the last line of foo()");
}

void main() {
    foo();
}
---

$(P
The output of the program is the following when the function does not throw:
)

$(SHELL
the first line of foo()
the first line of the try block
the last line of the try block
$(HILITE the body of the finally block)
the last line of foo()
)

$(P
The output of the program is the following when the function does throw:
)

$(SHELL
the first line of foo()
the first line of the try block
$(HILITE the body of the finally block)
object.Exception@deneme.d: the error message
)

$(P
As can be seen, although "the last line of the try block" and "the last line of foo()" are not printed, the content of the $(C finally) block is still executed when an exception is thrown.
)

$(H6 When to use the $(C try-catch) statement)

$(P
The $(C try-catch) statement is useful to catch exceptions to do something special about them.
)

$(P
For that reason, the $(C try-catch) statement should be used only when there is something special to be done. Do not catch exceptions otherwise and leave them to higher level functions that may want to catch them.
)

$(H5 Exception properties)

$(P
The information that is automatically printed on the output when the program terminates due to an exception is available as properties of exception objects as well. These properties are provided by the $(C Throwable) interface:
)

$(UL

$(LI $(IX .file) $(C .file): The source file where the exception was thrown from)

$(LI $(IX .line) $(C .line): The line number where the exception was thrown from)

$(LI $(IX .msg) $(C .msg): The error message)

$(LI $(IX .info) $(C .info): The state of the program stack when the exception was thrown)

$(LI $(IX .next) $(C .next): The next collateral exception)

)

$(P
We saw that $(C finally) blocks are executed when leaving scopes due to exceptions as well. (As we will see in later chapters, the same is true for $(C scope) statements and $(I destructors) as well.)
)

$(P
$(IX collateral exception) Naturally, such code blocks can throw exceptions as well. Exceptions that are thrown when leaving scopes due to an already thrown exception are called $(I collateral exceptions). Both the main exception and the collateral exceptions are elements of a $(I linked list) data structure, where every exception object is accessible through the $(C .next) property of the previous exception object. The value of the $(C .next) property of the last exception is $(C null). (We will see $(C null) in a later chapter.)
)

$(P
There are three exceptions that are thrown in the example below: The main exception that is thrown in $(C foo()) and the two collateral exceptions that are thrown in the $(C finally) blocks of $(C foo()) and $(C bar()). The program accesses the collateral exceptions through the $(C .next) properties.
)

$(P
Some of the concepts that are used in this program will be explained in later chapters. For example, the continuation condition of the $(C for) loop that consists solely of $(C exc) means $(I as long as $(C exc) is not $(C null)).
)

---
import std.stdio;

void foo() {
    try {
        throw new Exception("Exception thrown in foo");

    } finally {
        throw new Exception(
            "Exception thrown in foo's finally block");
    }
}

void bar() {
    try {
        foo();

    } finally {
        throw new Exception(
            "Exception thrown in bar's finally block");
    }
}

void main() {
    try {
        bar();

    } catch (Exception caughtException) {

        for (Throwable exc = caughtException;
             exc;    // ← Meaning: as long as exc is not 'null'
             exc = exc$(HILITE .next)) {

            writefln("error message: %s", exc$(HILITE .msg));
            writefln("source file  : %s", exc$(HILITE .file));
            writefln("source line  : %s", exc$(HILITE .line));
            writeln();
        }
    }
}
---

$(P
The output:
)

$(SHELL
error message: Exception thrown in foo
source file  : deneme.d
source line  : 6

error message: Exception thrown in foo's finally block
source file  : deneme.d
source line  : 9

error message: Exception thrown in bar's finally block
source file  : deneme.d
source line  : 20
)

$(H5 $(IX error, kinds of) Kinds of errors)

$(P
We have seen how useful the exception mechanism is. It enables both the lower and higher level operations to be aborted right away, instead of the program continuing with incorrect or missing data, or behaving in any other incorrect way.
)

$(P
This does not mean that every error condition warrants throwing an exception. There may be better things to do depending on the kinds of errors.
)

$(H6 User errors)

$(P
Some of the errors are caused by the user. As we have seen above, the user may have entered a string like "hello" even though the program has been expecting a number. It may be more appropriate to display an error message and ask the user to enter appropriate data again.
)

$(P
Even so, it may be fine to accept and use the data directly without validating the data up front; as long as the code that uses the data would throw anyway. What is important is to be able to notify the user why the data is not suitable.
)

$(P
For example, let's look at a program that takes a file name from the user. There are at least two ways of dealing with potentially invalid file names:
)

$(UL
$(LI $(B Validating the data before use): We can determine whether the file with the given name exists by calling $(C exists()) of the $(C std.file) module:

---
    if (exists(fileName)) {
        // yes, the file exists

    } else {
        // no, the file doesn't exist
    }
---

$(P
This gives us the chance to be able to open the data only if it exists. Unfortunately, it is still possible that the file cannot be opened even if $(C exists()) returns $(C true), if for example another process on the system deletes or renames the file before this program actually opens it.
)

$(P
For that reason, the following method may be more useful.
)

)

$(LI $(B Using the data without first validating it): We can assume that the data is valid and start using it right away, because $(C File) would throw an exception if the file cannot be opened anyway.

---
import std.stdio;
import std.string;

void useTheFile(string fileName) {
    auto file = File(fileName, "r");
    // ...
}

string read_string(string prompt) {
    write(prompt, ": ");
    return strip(readln());
}

void main() {
    bool is_fileUsed = false;

    while (!is_fileUsed) {
        try {
            useTheFile(
                read_string("Please enter a file name"));

            /* If we are at this line, it means that
             * useTheFile() function has been completed
             * successfully. This indicates that the file
             * name was valid.
             *
             * We can now set the value of the loop flag to
             * terminate the while loop. */
            is_fileUsed = true;
            writeln("The file has been used successfully");

        } catch (std.exception.ErrnoException exc) {
            stderr.writeln("This file could not be opened");
        }
    }
}
---

)

)

$(H6 Programmer errors)

$(P
Some errors are caused by programmer mistakes. For example, the programmer may think that a function that has just been written will always be called with a value greater than or equal to zero, and this may be true according to the design of the program. The function having still been called with a value less than zero would indicate either a mistake in the design of the program or in the implementation of that design. Both of these can be thought of as programming errors.
)

$(P
It is more appropriate to use $(C assert) instead of the exception mechanism for errors that are caused by programmer mistakes. ($(I $(B Note:) We will cover $(C assert) in $(LINK2 assert.html, a later chapter).))
)

---
void processMenuSelection(int selection) {
    assert(selection >= 0);
    // ...
}

void main() {
    processMenuSelection(-1);
}
---

$(P
The program terminates with an $(C assert) failure:
)

$(SHELL_SMALL
core.exception.AssertError@$(HILITE deneme.d(2)): Assertion failure
)

$(P
$(C assert) validates program state and prints the file name and line number of the validation if it fails. The message above indicates that the assertion at line 2 of $(C deneme.d) has failed.
)

$(H6 Unexpected situations)

$(P
For unexpected situations that are outside of the two general cases above, it is still appropriate to throw exceptions. If the program cannot continue its execution, there is nothing else to do but to throw.
)

$(P
It is up to the higher layer functions that call this function to decide what to do with thrown exceptions. They may catch the exceptions that we throw to remedy the situation.
)

$(H5 Summary)

$(UL

$(LI
When faced with a user error either warn the user right away or ensure that an exception is thrown; the exception may be thrown anyway by another function when using incorrect data, or you may throw directly.
)

$(LI
Use $(C assert) to validate program logic and implementation. ($(I $(B Note:) $(C assert) will be explained in a later chapter.))
)

$(LI
When in doubt, throw an exception with $(C throw) or $(C enforce()). ($(I $(B Note:) $(C enforce()) will be explained in a later chapter.))
)

$(LI
Catch exceptions if and only if you can do something useful about that exception. Otherwise, do not encapsulate code with a $(C try-catch) statement; instead, leave the exceptions to higher layers of the code that may do something about them.
)

$(LI
Order the $(C catch) blocks from the most specific to the most general.
)

$(LI
Put the expressions that must always be executed when leaving a scope, in $(C finally) blocks.
)

)

Macros:
        TITLE=Exceptions

        DESCRIPTION=The exception mechanism of D, which is used in unexpected situations.

        KEYWORDS=d programming language tutorial book exception try catch finally exit failure success

MINI_SOZLUK=
