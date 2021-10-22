Ddoc

$(DERS_BOLUMU $(IX ternary operator) $(IX ?:) $(IX conditional operator) Ternary Operator $(CH4 ?:))

$(P
The $(C ?:) operator works very similarly to an $(C if-else) statement:
)

---
    if (/* condition check */) {
        /* ... expression(s) to execute if true */

    } else {
        /* ... expression(s) to execute if false */
    }
---

$(P
The $(C if) statement executes either the block for the case of $(C true) or the block for the case of $(C false). As you remember, being a statement, it does not have a value; $(C if) merely affects the execution of code blocks.
)

$(P
On the other hand, the $(C ?:) operator is an expression. In addition to working similary to the $(C if-else) statement, it produces a value. The equivalent of the above code is the following:
)

---
/* condition */ ? /* truth expression */ : /* falsity expression */
---

$(P
Because it uses three expressions, the $(C ?:) operator is called the ternary operator.
)

$(P
The value that is produced by this operator is either the value of the truth expression or the value of the falsity expression. Because it is an expression, it can be used anywhere that expressions can be used.
)

$(P
The following examples contrast the $(C ?:) operator to the $(C if-else) statement. The ternary operator is more concise for the cases that are similar to these examples.
)

$(UL

$(LI $(B Initialization)

$(P
To initialize a variable with 366 if it is leap year, 365 otherwise:
)

---
    int days = isLeapYear ? 366 : 365;
---

$(P
With an $(C if) statement, one way to do this is to define the variable without an explicit initial value and then assign the intended value:
)

---
    int days;

    if (isLeapYear) {
        days = 366;

    } else {
        days = 365;
    }
---

$(P
An alternative also using an $(C if) is to initialize the variable with the non-leap year value and then increment it if it is a leap year:
)

---
    int days = 365;

    if (isLeapYear) {
        ++days;
    }
---

)

$(LI $(B Printing)

$(P
Printing part of a message differently depending on a condition:
)
---
    writeln("The glass is half ",
            isOptimistic ? "full." : "empty.");
---

$(P
With an $(C if), the first and last parts of the message may be printed separately:
)

---
    write("The glass is half ");

    if (isOptimistic) {
        writeln("full.");

    } else {
        writeln("empty.");
    }
---

$(P
Alternatively, the entire message can be printed separately:
)

---
    if (isOptimistic) {
        writeln("The glass is half full.");

    } else {
        writeln("The glass is half empty.");
    }
---

)

$(LI $(B Calculation)

$(P
Increasing the score of the winner in a backgammon game 2 points or 1 point depending on whether the game has ended with gammon:
)

---
    score += isGammon ? 2 : 1;
---

$(P
A straightforward equivalent using an $(C if):
)

---
    if (isGammon) {
        score += 2;

    } else {
        score += 1;
    }
---

$(P
An alternative also using an $(C if) is to first increment by one and then increment again if gammon:
)

---
    ++score;

    if (isGammon) {
        ++score;
    }
---

)

)

$(P
As can be seen from the examples above, the code is more concise and clearer with the ternary operator in certain situations.
)

$(H5 The type of the ternary expression)

$(P
The value of the $(C ?:) operator is either the value of the truth expression or the value of the falsity expression. The types of these two expressions need not be the same but they must have a $(I common type).
)

$(P
$(IX common type) The common type of two expressions is decided by a relatively complicated algorithm, involving $(LINK2 cast.html, type conversions) and $(LINK2 inheritance.html, inheritance). Additionally, depending on the expressions, the $(I kind) of the result is either $(LINK2 lvalue_rvalue.html, an lvalue or an rvalue). We will see these concepts in later chapters.
)

$(P
For now, accept common type as a type that can represent both of the values without requiring an explicit cast. For example, the integer types $(C int) and $(C long) have a common type because they can both be represented as $(C long). On the other hand, $(C int) and $(C string) do not have a common type because neither $(C int) nor $(C string) can automatically be converted to the other type.
)

$(P
Remember that a simple way of determining the type of an expression is using $(C typeof) and then printing its $(C .stringof) property:
)

---
    int i;
    double d;

    auto result = someCondition ? i : d;
    writeln(typeof(result)$(HILITE .stringof));
---

$(P
Because $(C double) can represent $(C int) but not the other way around, the common type of the ternary expression above is $(C double):
)

$(SHELL
double
)

$(P
To see an example of two expressions that do not have a common type, let's look at composing a message that reports the number of items to be shipped. Let's print "A dozen" when the value equals 12: "A $(B dozen) items will be shipped." Otherwise, let's have the message include the exact number: "$(B 3) items will be shipped."
)

$(P
One might think that the varying part of the message can be selected with the $(C ?:) operator:
)

---
    writeln(
        (count == 12) ? "A dozen" : count, $(DERLEME_HATASI)
        " items will be shipped.");
---

$(P
Unfortunately, the expressions do not have a common type because the type of $(STRING "A dozen") is $(C string) and the type of $(C count) is $(C int).
)

$(P
A solution is to first convert $(C count) to $(C string). The function $(C to!string) from the $(C std.conv) module produces a $(C string) value from the specified parameter:
)

---
import std.conv;
// ...
    writeln((count == 12) ? "A dozen" : to!string(count),
            " items will be shipped.");
---

$(P
Now, as both of the selection expressions of the $(C ?:) operator are of $(C string) type, the code compiles and prints the expected message.
)

$(PROBLEM_TEK

$(P
Have the program read a single $(C int) value as $(I the net amount) where a positive value represents a gain and a negative value represents a loss.
)

$(P
The program should print a message that contains "gained" or "lost" depending on whether the amount is positive or negative. For example, "&#36;100 lost" or "&#36;70 gained". Even though it may be more suitable, do not use the $(C if) statement in this exercise.
)

)


Macros:
        TITLE=Ternary Operator ?:

        DESCRIPTION=The ?: operator of the D programming language and comparing it to the if-else statement.

        KEYWORDS=d programming language tutorial book ternary operator
