Ddoc

$(DERS_BOLUMU $(IX if) $(CH4 if) Statement)

$(P
We've learned that the actual work in a program is performed by expressions. All of the expressions of all of the programs that we've seen so far have started with the $(C main()) function and were executed until the end of $(C main).
)

$(P
$(IX statement) $(I Statements), on the other hand, are features that affect the execution of expressions. Statements don't produce values and don't have side effects themselves. They determine whether and in what order the expressions are executed. Statements sometimes use logical expressions when making such decisions.
)

$(P $(I $(B Note:) Other programming languages may have different definitions for expression and statement, while some others may not have a distinction at all.
)
)

$(H5 The $(C if) block and its scope)

$(P
The $(C if) statement determines whether one or more expressions would be executed. It makes this decision by evaluating a logical expression. It has the same meaning as the English word "if", as in the phrase "if there is coffee then I will drink coffee".
)

$(P
$(C if) takes a logical expression in parentheses. If the value of that logical expression is $(C true), then it executes the expressions that are within the following curly brackets. Conversely, if the logical expression is $(C false), it does not execute the expressions within the curly brackets.
)

$(P
The area within the curly brackets is called a $(I scope) and all of the code that is in that scope is called a $(I block of code).
)

$(P
Here is the syntax of the $(C if) statement:
)

---
    if (a_logical_expression) {
        // ... expression(s) to execute if true
    }
---

$(P
For example, the program construct that represents "if there is coffee then drink coffee and wash the cup" can be written as in the following program:
)

---
import std.stdio;

void main() {
    bool existsCoffee = true;

    if (existsCoffee) {
        writeln("Drink coffee");
        writeln("Wash the cup");
    }
}
---

$(P
If the value of $(C existsCoffee) is $(C false), then the expressions that are within the block would be skipped and the program would not print anything.
)

$(H5 $(IX else) The $(C else) block and its scope)

$(P
Sometimes there are operations to execute for when the logical expression of the $(C if) statement is $(C false). For example, there is always an operation to execute in a decision like "if there is coffee I will drink coffee, else I will drink tea".
)

$(P
The operations to execute in the $(C false) case are placed in a scope after the $(C else) keyword:
)

---
    if (a_logical_expression) {
        // ... expression(s) to execute if true

    } else {
        // ... expression(s) to execute if false
    }
---

$(P
For example, under the assumption that there is always tea:
)

---
    if (existsCoffee) {
        writeln("Drink coffee");

    } else {
        writeln("Drink tea");
    }
---

$(P
In that example, either the first or the second string would be printed depending on the value of $(C existsCoffee).
)

$(P
$(C else) itself is not a statement but an optional $(I clause) of the $(C if) statement; it cannot be used alone.
)

$(P
Note the placement of curly brackets of the $(C if) and $(C else) blocks above. Although it is $(LINK2 http://dlang.org/dstyle.html, official D style) to place curly brackets on separate lines, this book uses a common style of inline curly brackets throughout.
)

$(H5 Always use the scope curly brackets)

$(P
It is not recommended but is actually possible to omit the curly brackets if there is only one statement within a scope. As both the $(C if) and the $(C else) scopes have just one statement above, that code can also be written as the following:
)

---
    if (existsCoffee)
        writeln("Drink coffee");

    else
        writeln("Drink tea");
---

$(P
Most experienced programmers use curly brackets even for single statements. (One of the exercises of this chapter is about omitting them.) Having said that, I will now show the only case where omitting the curly brackets is actually better.
)

$(H5 $(IX else if) The "if, else if, else" chain)

$(P
One of the powers of statements and expressions is the ability to use them in more complex ways. In addition to expressions, scopes can contain other statements. For example, an $(C else) scope can contain an $(C if) statement. Connecting statements and expressions in different ways allows us to make programs behave intelligently according to their purposes.
)

$(P
The following is a more complex example written under the agreement that riding to a good coffee shop is preferred over walking to a bad one:
)

---
    if (existsCoffee) {
        writeln("Drink coffee at home");

    } else {

        if (existsBicycle) {
            writeln("Ride to the good place");

        } else {
            writeln("Walk to the bad place");
        }
    }
---

$(P
The code above represents the sentences "If there is coffee, drink at home. Else, if there is a bicycle, ride to the good place. Otherwise, walk to the bad place."
)

$(P
Let's complicate this decision process further: instead of having to walk to the bad place, let's first try the neighbor:
)

---
    if (existsCoffee) {
        writeln("Drink coffee at home");

    } else {

        if (existsBicycle) {
            writeln("Ride to the good place");

        } else {

            if (neighborIsHome) {
                writeln("Have coffee at neighbor's");

            } else {
                writeln("Walk to the bad place");
            }
        }
    }
---

$(P
Such decisions like "if this case, else if that other case, else if that even other case, etc." are common in programs. Unfortunately, when the guideline of always using curly brackets is followed obstinately, the code ends up having too much horizontal and vertical space: ignoring the empty lines, the 3 $(C if) statements and the 4 $(C writeln) expressions above occupy a total of 13 lines.
)

$(P
In order to write such constructs in a more compact way, when an $(C else) scope contains only one $(C if) statement, then the curly brackets of that $(C else) scope are omitted as an exception to this guideline.
)

$(P
I am leaving the following code untidy as an intermediate step before showing the better form of it. No code should be written in such an untidy way.
)

$(P
The following is what the code looks like after removing the curly brackets of the two $(C else) scopes that contain just a single $(C if) statement:
)

---
    if (existsCoffee) {
        writeln("Drink coffee at home");

    } else

        if (existsBicycle) {
            writeln("Ride to the good place");

        } else

            if (neighborIsHome) {
                writeln("Have coffee at neighbor's");

            } else {
                writeln("Walk to the bad place");
            }
---

$(P
If we now move those $(C if) statements up to the same lines as their enclosing $(C else) clauses and tidy up the code, we end up with the following more readable format:
)

---
    if (existsCoffee) {
        writeln("Drink coffee at home");

    } else if (existsBicycle) {
        writeln("Ride to the good place");

    } else if (neighborIsHome) {
        writeln("Have coffee at neighbor's");

    } else {
        writeln("Walk to the bad place");
    }
---

$(P
Removing the curly brackets allows the code to be more compact and lines up all of the expressions for easier readability. The logical expressions, the order that they are evaluated, and the operations that are executed when they are true are now easier to see at a glance.
)

$(P
This common programming construct is called the "if, else if, else" chain.
)


$(PROBLEM_COK

$(PROBLEM

Since the logical expression below is $(C true), we would expect this program to $(I drink lemonade and wash the cup):

---
import std.stdio;

void main() {
    bool existsLemonade = true;

    if (existsLemonade) {
        writeln("Drinking lemonade");
        writeln("Washing the cup");

    } else
        writeln("Eating pie");
        writeln("Washing the plate");
}
---

But when you run that program you will see that it $(I washes the plate) as well:

$(SHELL
Drinking lemonade
Washing the cup
Washing the plate
)

Why? Correct the program to wash the plate only when the logical expression is $(C false).
)

$(PROBLEM
Write a program that plays a game with the user (obviously with trust). The user throws a die and enters its value. Either the user or the program wins according to the value of the die:

$(MONO
$(B Value of the die         Output of the program)
        1                      You won
        2                      You won
        3                      You won
        4                      I won
        5                      I won
        6                      I won
 Any other value               ERROR: Invalid value
)

Bonus: Have the program also mention the value when the value is invalid. For example:

$(SHELL
ERROR: 7 is invalid
)

)

$(PROBLEM
Let's change the game by having the user enter a value from 1 to 1000. Now the user wins when the value is in the range 1-500 and the computer wins when the value is in the range 501-1000. Can the previous program be easily modified to work in this way?
)

)

Macros:
        TITLE=if Statement

        DESCRIPTION=The if statement, one of the conditional statements of the D programming language

        KEYWORDS=d programming language tutorial book if conditional statement

MINI_SOZLUK=
