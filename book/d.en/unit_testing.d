Ddoc

$(DERS_BOLUMU $(IX unit testing) $(IX test) Unit Testing)

$(P
As it should be known by most people, any device that runs some piece of computer program contains software bugs. Software bugs plague computer devices from the simplest to the most complex. Debugging and fixing software bugs is among the less favorable daily activities of a programmer.
)

$(H5 $(IX bug, causes of) Causes of bugs)

$(P
There are many reasons why software bugs occur. The following is an incomplete list roughly from the design stage of a program through the actual coding of it:
)

$(UL

$(LI
The requirements and the specifications of the program may not be clear. What the program should actually do may not be known at the design stage.
)

$(LI
The programmer may misunderstand some of the requirements of the program.
)

$(LI
The programming language may not be expressive enough. Considering that there are confusions even between native speakers of human languages, the unnatural syntax and rules of a programming language may be cause of mistakes.
)

$(LI
Certain assumptions of the programmer may be incorrect. For example, the programmer may be assuming that 3.14 would be precise enough to represent π.
)

$(LI
The programmer may have incorrect information on a topic or none at all. For example, the programmer may not know that using a floating point variable in a particular logical expression would not be reliable.
)

$(LI
The program may encounter an unforeseen situation. For example, one of the files of a directory may be deleted or renamed while the program is using the files of that directory in a $(C foreach) loop.
)

$(LI
The programmer may make silly mistakes. For example, the name of a variable may be mistyped and accidentally matched the name of another variable.
)

$(LI etc.)

)

$(P
Unfortunately, there is still no software development methodology that ensures that a program will always work correctly. This is still a hot software engineering topic where promising solutions emerge every decade or so.
)

$(H5 Discovering the bugs)

$(P
Software bugs are discovered at various stages of the lifetime of the program by various types of tools and people. The following is a partial list of when a bug may be discovered, from the earliest to the latest:
)

$(UL
$(LI When writing the program

$(UL
$(LI By the programmer
)

$(LI By another programmer during $(I pair programming)
)

$(LI By the compiler through compiler messages
)

$(LI By $(HILITE unit tests) as a part of building the program
)

)

)

$(LI When reviewing the code

$(UL
$(LI By tools that analyze the code at compile time
)

$(LI By other programmers during $(I code reviews)
)
)

)

$(LI When running the program

$(UL
$(LI By tools that analyze the execution of the program at run time (e.g. by valgrind)
)

$(LI During QA testing, either by the failure of $(C assert) checks or by the observed behavior of the program
)

$(LI By the $(I beta) users before the release of the program
)

$(LI By the end users after the release of the program)

)

)

)

$(P
Detecting bugs as early as possible reduces loss of money, time, and in some cases human lives. Additionally, identifying the causes of bugs that have been discovered by the end users are harder than identifying the causes of bugs that are discovered early, during development.
)

$(H5 Unit testing for catching bugs)

$(P
Since programs are written by programmers and D is a compiled language, the programmers and the compiler will always be there to discover bugs. Those two aside, the earliest and partly for that reason the most effective way of catching bugs is unit testing.
)

$(P
Unit testing is an indispensable part of modern programming. It is the most effective method of reducing coding errors. According to some development methodologies, code that is not guarded by unit tests is buggy code.
)

$(P
Unfortunately, the opposite is not true: Unit tests do not guarantee that the code is free of bugs. Although they are very effective, they can only reduce the risk of bugs.
)

$(P
Unit testing also enables refactoring the code (i.e. making improvements to it) with ease and confidence. Otherwise, it is common to accidentally break some of the existing functionality of a program when adding new features to it. Bugs of this type are called $(I regressions). Without unit testing, regressions are sometimes discovered as late as during the QA testing of future releases, or worse, by the end users.
)

$(P
Risk of regressions discourage programmers from refactoring the code, sometimes preventing them from performing the simplest of improvements like correcting the name of a variable. This in turn causes $(I code rot), a condition where the code becomes more and more unmaintainable. For example, although some lines of code would better be moved to a newly defined function in order to be called from more than one place, fear of regressions make programmers copy and paste the existing lines to other places instead, leading to the problem of $(I code duplication).
)

$(P
Phrases like "if it isn't broken, don't fix it" are related to fear of regressions. Although they seem to be conveying wisdom, such guidelines cause the code to rot slowly and become an untouchable mess.
)

$(P
Modern programming rejects such "wisdom". To the contrary, to prevent it from becoming a source of bugs, the code is supposed to be "refactored mercilessly". The most powerful tool of this modern approach is unit testing.
)

$(P
Unit testing involves testing the smallest units of code independently. When units of code are tested independently, it is less likely that there are bugs in higher-level code that use those units. When the parts work correctly, it is more likely that the whole will work correctly as well.
)

$(P
Unit tests are provided as library solutions in other languages (e.g. JUnit, CppUnit, Unittest++, etc.) In D, unit testing is a core feature of the language. It is debatable whether a library solution or a language feature is better for unit testing. Because D does not provide some of the features that are commonly found in unit testing libraries, it may be worthwhile to consider library solutions as well.
)

$(P
The unit testing features of D are as simple as inserting $(C assert) checks into $(C unittest) blocks.
)

$(H5 $(IX -unittest, compiler switch) Activating the unit tests)

$(P
Unit tests are not a part of the actual execution of the program. They should be activated only during program development when explicitly requested.
)

$(P
The $(C dmd) compiler switch that activates unit tests is $(C &#8209;unittest).
)

$(P
Assuming that the program is written in a single source file named $(C deneme.d), its unit tests can be activated by the following command:
)

$(SHELL
$ dmd deneme.d -w $(HILITE -unittest)
)

$(P
When a program that is built by the $(C &#8209;unittest) switch is started, its unit test blocks are executed first. Only if all of the unit tests pass then the program execution continues with $(C main()).
)

$(H5 $(IX unittest) $(C unittest) blocks)

$(P
The lines of code that involve unit tests are written inside $(C unittest) blocks. These blocks do not have any significance for the program other than containing the unit tests:
)

---
unittest {
    /* ... the tests and the code that support them ... */
}
---

$(P
Although $(C unittest) blocks can appear anywhere, it is convenient to define them right after the code that they test.
)

$(P
As an example, let's test a function that returns the ordinal form of the specified number as in "1st", "2nd", etc. A $(C unittest) block of this function can simply contain $(C assert) statements that compare the return values of the function to the expected values. The following function is being tested with the four distinct expected outcomes of the function:
)

---
string ordinal(size_t number) {
    // ...
}

$(HILITE unittest) {
    assert(ordinal(1) == "1st");
    assert(ordinal(2) == "2nd");
    assert(ordinal(3) == "3rd");
    assert(ordinal(10) == "10th");
}
---

$(P
The four tests above test that the function works correctly at least for the values of 1, 2, 3, and 10 by making four separate calls to the function and comparing the returned values to the expected ones.
)

$(P
Although unit tests are based on $(C assert) checks, $(C unittest) blocks can contain any D code. This allows for preparations before actually starting the tests or any other supporting code that the tests may need. For example, the following block first defines a variable to reduce code duplication:
)

---
dstring toFront(dstring str, dchar letter) {
    // ...
}

unittest {
    immutable str = "hello"d;

    assert(toFront(str, 'h') == "hello");
    assert(toFront(str, 'o') == "ohell");
    assert(toFront(str, 'l') == "llheo");
}
---

$(P
The three $(C assert) checks above test that $(C toFront()) works according to its specification.
)

$(P
As these examples show, unit tests are also useful as examples of how particular functions should be called. Usually it is easy to get an idea on what a function does just by reading its unit tests.
)

$(H5 $(IX assertThrown, std.exception) $(IX assertNotThrown, std.exception) Testing for exceptions)

$(P
It is common to test some code for exception types that it should or should not throw under certain conditions. The $(C std.exception) module contains two functions that help with testing for exceptions:
)

$(UL

$(LI $(C assertThrown): Ensures that a specific exception type is thrown from an expression)

$(LI $(C assertNotThrown): Ensures that a specific exception type is $(I not) thrown from an expression)

)

$(P
For example, a function that requires that both of its slice parameters have equal lengths and that it works with empty slices can be tested as in the following tests:
)

---
import std.exception;

int[] average(int[] a, int[] b) {
    // ...
}

unittest {
    /* Must throw for uneven slices */
    assertThrown(average([1], [1, 2]));

    /* Must not throw for empty slices */
    assertNotThrown(average([], []));
}
---

$(P
Normally, $(C assertThrown) ensures that some type of exception is thrown without regard to the actual type of that exception. When needed, it can test against a specific exception type as well. Likewise, $(C assertNotThrown) ensures that no exception is thrown whatsoever but it can be instructed to test that a specific exception type is not thrown. The specific exception types are specified as template parameters to these functions:
)

---
    /* Must throw UnequalLengths for uneven slices */
    assertThrown$(HILITE !UnequalLengths)(average([1], [1, 2]));

    /* Must not throw RangeError for empty slices (it may
     * throw other types of exceptions) */
    assertNotThrown$(HILITE !RangeError)(average([], []));
---

$(P
We will see templates in a $(LINK2 templates.html, later chapter).
)

$(P
The main purpose of these functions is to make code more succinct and more readable. For example, the following $(C assertThrown) line is the equivalent of the lengthy code below it:
)

---
    assertThrown(average([1], [1, 2]));

// ...

    /* The equivalent of the line above */
    {
        auto isThrown = false;

        try {
            average([1], [1, 2]);

        } catch (Exception exc) {
            isThrown = true;
        }

        assert(isThrown);
    }
---

$(H5 $(IX TDD) $(IX test driven development) Test driven development)

$(P
Test driven development (TDD) is a software development methodology that prescribes writing unit tests before implementing functionality. In TDD, the focus is on unit testing. Coding is a secondary activity that makes the tests pass.
)

$(P
In accordance to TDD, the $(C ordinal()) function above can first be implemented intentionally incorrectly:
)

---
import std.string;

string ordinal(size_t number) {
    return "";    // ← intentionally wrong
}

unittest {
    assert(ordinal(1) == "1st");
    assert(ordinal(2) == "2nd");
    assert(ordinal(3) == "3rd");
    assert(ordinal(10) == "10th");
}

void main() {
}
---

$(P
Although the function is obviously wrong, the next step would be to run the unit tests to see that the tests do indeed catch problems with the function:
)

$(SHELL
$ dmd deneme.d -w -unittest
$ ./deneme 
$(SHELL_OBSERVED core.exception.AssertError@deneme(10): $(HILITE unittest failure))
)

$(P
The function should be implemented only $(I after) seeing the failure, and only to make the tests pass. Here is just one implementation that passes the tests:
)

---
import std.string;

string ordinal(size_t number) {
    string suffix;

    switch (number) {
    case  1: suffix = "st"; break;
    case  2: suffix = "nd"; break;
    case  3: suffix = "rd"; break;
    default: suffix = "th"; break;
    }

    return format("%s%s", number, suffix);
}

unittest {
    assert(ordinal(1) == "1st");
    assert(ordinal(2) == "2nd");
    assert(ordinal(3) == "3rd");
    assert(ordinal(10) == "10th");
}

void main() {
}
---

$(P
Since the implementation above does pass the unit tests, there is reason to trust that the $(C ordinal()) function is correct. Under the assurance that the tests bring, the implementation of the function can be changed in many ways with confidence.
)

$(H6 Unit tests before bug fixes)

$(P
Unit tests are not a panacea; there will always be bugs. If a bug is discovered when actually running the program, it can be seen as an indication that the unit tests have been incomplete. For that reason, it is better to $(I first) write a unit test that reproduces the bug and only $(I then) to fix the bug to pass the new test.
)

$(P
Let's have a look at the following function that returns the spelling of the ordinal form of a number specified as a $(C dstring):
)

---
$(CODE_NAME ordinalSpelled)import std.exception;
import std.string;

dstring ordinalSpelled(dstring number) {
    enforce(number.length, "number cannot be empty");

    dstring[dstring] exceptions = [
        "one": "first", "two" : "second", "three" : "third",
        "five" : "fifth", "eight": "eighth", "nine" : "ninth",
        "twelve" : "twelfth"
    ];

    dstring result;

    if (number in exceptions) {
        result = exceptions[number];

    } else {
        result = number ~ "th";
    }

    return result;
}

unittest {
    assert(ordinalSpelled("one") == "first");
    assert(ordinalSpelled("two") == "second");
    assert(ordinalSpelled("three") == "third");
    assert(ordinalSpelled("ten") == "tenth");
}

void main() {
}
---

$(P
The function takes care of exceptional spellings and even includes a unit test for that. Still, the function has a bug yet to be discovered:
)

---
$(CODE_XREF ordinalSpelled)import std.stdio;

void main() {
    writefln("He came the %s in the race.",
             ordinalSpelled("twenty"));
}
---

$(P
The spelling error in the output of the program is due to a bug in $(C ordinalSpelled()), which its unit tests fail to catch:
)

$(SHELL
He came the $(HILITE twentyth) in the race.
)

$(P
Although it is easy to see that the function does not produce the correct spelling for numbers that end with the letter y, TDD prescribes that first a unit test must be written to reproduce the bug before actually fixing it:
)

---
unittest {
// ...
    assert(ordinalSpelled("twenty") == "twentieth");
}
---

$(P
With that improvement to the tests, now the bug in the function is being caught during development:
)

$(SHELL
core.exception.AssertError@deneme(3274338): unittest failure
)

$(P
The function should be fixed only then:
)

---
dstring ordinalSpelled(dstring number) {
// ...
    if (number in exceptions) {
        result = exceptions[number];

    } else {
        if ($(HILITE number[$-1] == 'y')) {
            result = number[0..$-1] ~ "ieth";

        } else {
            result = number ~ "th";
        }
    }

    return result;
}
---

$(PROBLEM_TEK

$(P
Implement $(C toFront()) according to TDD. Start with the intentionally incomplete implementation below. Observe that the unit tests fail and provide an implementation that passes the tests.
)

---
dstring toFront(dstring str, dchar letter) {
    dstring result;
    return result;
}

unittest {
    immutable str = "hello"d;

    assert(toFront(str, 'h') == "hello");
    assert(toFront(str, 'o') == "ohell");
    assert(toFront(str, 'l') == "llheo");
}

void main() {
}
---

)

Macros:
        TITLE=Unit Testing

        DESCRIPTION=The unittest feature of the D programming language, which is one of the most effective tools for program correctness.

        KEYWORDS=d programming language tutorial book unittest
