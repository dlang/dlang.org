Ddoc

$(DERS_BOLUMU $(IX assert) $(IX enforce) $(CH4 assert) and $(CH4 enforce))

$(P
In the previous two chapters we have seen how exceptions and $(C scope) statements are used toward program correctness. $(C assert) is another powerful tool to achieve the same goal by ensuring that certain assumptions that the program is based on are valid.
)

$(P
It may sometimes be difficult to decide whether to throw an exception or to call $(C assert). I will use $(C assert) in all of the examples below without much justification. I will explain the differences later in the chapter.
)

$(P
Although not always obvious, programs are full of assumptions. For example, the following function is written under the assumption that both age parameters are greater than or equal to zero:
)

---
double averageAge(double first, double second) {
    return (first + second) / 2;
}
---

$(P
Although it may be invalid for the program to ever have an age value that is negative, the function would still produce an average, which may be used in the program unnoticed, resulting in the program's continuing with incorrect data.
)

$(P
As another example, the following function assumes that it will always be called with two commands: "sing" or "dance":
)

---
void applyCommand(string command) {
    if (command == "sing") {
        robotSing();

    } else {
        robotDance();
    }
}
---

$(P
Because of that assumption, the $(C robotDance()) function would be called for every command other than "sing", valid or invalid.
)

$(P
When such assumptions are kept only in the programmer's mind, the program may end up working incorrectly. $(C assert) statements check assumptions and terminate programs immediately when they are not valid.
)

$(H5 Syntax)

$(P
$(C assert) can be used in two ways:
)

---
    assert($(I logical_expression));
    assert($(I logical_expression), $(I message));
---

$(P
The logical expression represents an assumption about the program. $(C assert) evaluates that expression to validate that assumption. If the value of the logical expression is $(C true) then the assumption is considered to be valid. Otherwise the assumption is invalid and an $(C AssertError) is thrown.
)

$(P
As its name suggests, this exception is inherited from $(C Error), and as you may remember from the $(LINK2 exceptions.html, Exceptions chapter), exceptions that are inherited from $(C Error) must never be caught. It is important for the program to be terminated right away instead of continuing under invalid assumptions.
)

$(P
The two implicit assumptions of $(C averageAge()) above may be spelled out by two $(C assert) calls as in the following function:
)

---
double averageAge(double first, double second) {
    assert(first >= 0);
    assert(second >= 0);

    return (first + second) / 2;
}

void main() {
    auto result = averageAge($(HILITE -1), 10);
}
---

$(P
Those $(C assert) checks carry the meaning "assuming that both of the ages are greater than or equal to zero". It can also be thought of as meaning "this function can work correctly only if both of the ages are greater than or equal to zero".
)

$(P
Each $(C assert) checks its assumption and terminates the program with an $(C AssertError) when it is not valid:
)

$(SHELL
core.exception.$(HILITE AssertError)@deneme(2): Assertion failure
)

$(P
The part after the $(C @) character in the message indicates the source file and the line number of the $(C assert) check that failed. According to the output above, the $(C assert) that failed is on line 2 of file $(C deneme.d).
)

$(P
The other syntax of $(C assert) allows printing a custom message when the $(C assert) check fails:
)

---
    assert(first >= 0, "Age cannot be negative.");
---

$(P
The output:
)

$(SHELL
core.exception.AssertError@deneme.d(2): $(HILITE Age cannot be negative.)
)

$(P
Sometimes it is thought to be impossible for the program to ever enter a code path. In such cases it is common to use the literal $(C false) as the logical expression to fail an $(C assert) check. For example, to indicate that $(C applyCommand()) function is never expected to be called with a command other than "sing" and "dance", and to guard against such a possibility, an $(C assert(false)) can be inserted into the $(I impossible) branch:
)

---
void applyCommand(string command) {
    if (command == "sing") {
        robotSing();

    } else if (command == "dance") {
        robotDance();

    } else {
        $(HILITE assert(false));
    }
}
---

$(P
The function is guaranteed to work with the only two commands that it knows about. ($(I $(B Note:) An alternative choice here would be to use a $(LINK2 switch_case.html, $(C final switch) statement).))
)

$(H5 $(IX static assert) $(C static assert))

$(P
Since $(C assert) checks are for correct execution of programs, they are applied when the program is actually running. There can be other checks that are about the structure of the program, which can be applied even at compile time.
)

$(P
$(C static assert) is the counterpart of $(C assert) that is applied at compile time. The advantage is that it does not allow even compiling a program that would have otherwise run incorrectly. A natural requirement is that it must be possible to evaluate the logical expression at compile time.
)

$(P
For example, assuming that the title of a menu will be printed on an output device that has limited width, the following $(C static assert) ensures that it will never be wider than that limit:
)

---
    enum dstring menuTitle = "Command Menu";
    static assert(menuTitle.length <= 16);
---

$(P
Note that the string is defined as $(C enum) so that its length can be evaluated at compile time.
)

$(P
Let's assume that a programmer changes that title to make it more descriptive:
)

---
    enum dstring menuTitle = "Directional Commands Menu";
    static assert(menuTitle.length <= 16);
---

$(P
The $(C static assert) check prevents compiling the program:
)

$(SHELL
Error: static assert  (25u <= 16u) is false
)

$(P
This would remind the programmer of the limitation of the output device.
)

$(P
$(C static assert) is even more useful when used in templates. We will see templates in later chapters.
)

$(H5 $(C assert) even if $(I absolutely true))

$(P
I emphasize "absolutely true" because assumptions about the program are never expected to be false anyway. A large set of program errors are caused by assumptions that are thought to be absolutely true.
)

$(P
For that reason, take advantage of $(C assert) checks even if they feel unnecessary. Let's look at the following function that returns the days of months in a given year:
)

---
int[] monthDays(int year) {
    int[] days = [
        31, februaryDays(year),
        31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ];

    assert((sum(days) == 365) ||
           (sum(days) == 366));

    return days;
}
---

$(P
That $(C assert) check may be seen as unnecessary because the function would naturally return either 365 or 366. However, those checks are guarding against potential mistakes even in the $(C februaryDays()) function. For example, the program would be terminated if $(C februaryDays()) returned 30.
)

$(P
Another seemingly unnecessary check can ensure that the length of the slice would always be 12:
)

---
    assert(days.length == 12);
---

$(P
That way, deleting or adding elements to the slice unintentionally would also be caught. Such checks are important tools toward program correctness.
)

$(P
$(C assert) is also the fundamental tool that is used in $(I unit testing) and $(I contract programming), both of which will be covered in later chapters.
)

$(H5 No value nor side effect)

$(P
We have seen that expressions produce values or make side effects. $(C assert) checks do not have values nor $(I should) they have any side effects.
)

$(P
The D language requires that the evaluation of the logical expression must not have any side effect. $(C assert) must remain as a passive observer of program state.
)

$(H5 $(IX -release, compiler switch) Disabling $(C assert) checks)

$(P
Since $(C assert) is about program correctness, they can be seen as unnecessary once the program has been tested sufficiently. Further, since $(C assert) checks produce no values nor they have side effects, removing them from the program should not make any difference.
)

$(P
The compiler switch $(C -release) causes the $(C assert) checks to be ignored as if they have never been included in the program:
)

$(SHELL
$ dmd deneme.d -release
)

$(P
This would allow programs to run faster by not evaluating potentially slow logical expressions of the $(C assert) checks.
)

$(P
As an exception, the $(C assert) checks that have the literal $(C false) (or 0) as the logical expression are not disabled even when the program is compiled with $(C &#8209;release). This is because $(C assert(false)) is for ensuring that a block of code is never reached, and that should be prevented even for the $(C &#8209;release) compilations.
)

$(H5 $(C enforce) for throwing exceptions)

$(P
Not every unexpected situation is an indication of a program error. Programs may also experience unexpected inputs and unexpected environmental state. For example, the data that is entered by the user should not be validated by an $(C assert) check because invalid data has nothing to do with the correctness of the program itself. In such cases it is appropriate to throw exceptions like we have been doing in previous programs.
)

$(P
$(C std.exception.enforce) is a convenient way of throwing exceptions. For example, let's assume that an exception must be thrown when a specific condition is not met:
)

---
    if (count < 3) {
        throw new Exception("Must be at least 3.");
    }
---

$(P
$(C enforce()) is a wrapper around the condition check and the $(C throw) statement. The following is the equivalent of the previous code:
)

---
import std.exception;
// ...
    enforce(count >= 3, "Must be at least 3.");
---

$(P
Note how the logical expression is negated compared to the $(C if) statement. It now spells out what is being $(I enforced).
)

$(H5 How to use)

$(P
$(C assert) is for catching programmer errors. The conditions that $(C assert) guards against in the $(C monthDays()) function and the $(C menuTitle) variable above are all about programmer mistakes.
)

$(P
Sometimes it is difficult to decide whether to rely on an $(C assert) check or to throw an exception. The decision should be based on whether the unexpected situation is due to a problem with how the program has been coded.
)

$(P
Otherwise, the program must throw an exception when it is not possible to accomplish a task. $(C enforce()) is expressive and convenient when throwing exceptions.
)

$(P
Another point to consider is whether the unexpected situation can be remedied in some way. If the program can not do anything special, even by simply printing an error message about the problem with some input data, then it is appropriate to throw an exception. That way, callers of the code that threw the exception can catch it to do something special to recover from the error condition.
)

$(PROBLEM_COK

$(PROBLEM
The following program includes a number of $(C assert) checks. Compile and run the program to discover its bugs that are revealed by those $(C assert) checks.

$(P
The program takes a start time and a duration from the user and calculates the end time by adding the duration to the start time:
)

$(SHELL
10 hours and 8 minutes after 06:09 is 16:17.
)

$(P
Note that this problem can be written in a much cleaner way by defining $(C struct) types. We will refer to this program in later chapters.
)

---
import std.stdio;
import std.string;
import std.exception;

/* Reads the time as hour and minute after printing a
 * message. */
void readTime(string message,
              out int hour,
              out int minute) {
    write(message, "? (HH:MM) ");

    readf(" %s:%s", &hour, &minute);

    enforce((hour >= 0) && (hour <= 23) &&
            (minute >= 0) && (minute <= 59),
            "Invalid time!");
}

/* Returns the time in string format. */
string timeToString(int hour, int minute) {
    assert((hour >= 0) && (hour <= 23));
    assert((minute >= 0) && (minute <= 59));

    return format("%02s:%02s", hour, minute);
}

/* Adds duration to start time and returns the result as the
 * third pair of parameters. */
void addDuration(int startHour, int startMinute,
                 int durationHour, int durationMinute,
                 out int resultHour, out int resultMinute) {
    resultHour = startHour + durationHour;
    resultMinute = startMinute + durationMinute;

    if (resultMinute > 59) {
        ++resultHour;
    }
}

void main() {
    int startHour;
    int startMinute;
    readTime("Start time", startMinute, startHour);

    int durationHour;
    int durationMinute;
    readTime("Duration", durationHour, durationMinute);

    int endHour;
    int endMinute;
    addDuration(startHour, startMinute,
                durationHour, durationMinute,
                endHour, endMinute);

    writefln("%s hours and %s minutes after %s is %s.",
             durationHour, durationMinute,
             timeToString(startHour, startMinute),
             timeToString(endHour, endMinute));
}
---

$(P
Run the program and enter $(C 06:09) as the start time and $(C 1:2) as the duration. Observe that the program terminates normally.
)

$(P $(I $(B Note:) You may notice a problem with the output. Ignore that problem for now as you will discover it by the help of $(C assert) checks soon.)
)

)

$(PROBLEM
This time enter $(C 06:09) and $(C 15:2). Observe that the program is terminated by an $(C AssertError). Go to the line of the program that is indicated in the assert message and see which one of the $(C assert) checks have failed. It may take a while to discover the cause of this particular failure.
)

$(PROBLEM
Enter $(C 06:09) and $(C 20:0) and observe that the same $(C assert) check still fails and fix that bug as well.
)

$(PROBLEM
Modify the program to print the times in 12-hour format with an "am" or "pm" indicator.
)

)

Macros:
        TITLE=assert and enforce

        DESCRIPTION=assert checks for program correctness, enforce() for throwing exception conveniently, and their differences.

        KEYWORDS=d programming language tutorial book assert enforce
