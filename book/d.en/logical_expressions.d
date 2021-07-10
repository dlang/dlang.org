Ddoc

$(DERS_BOLUMU $(IX logical expression) Logical Expressions)

$(P
$(IX expression) The actual work that a program performs is accomplished by $(I expressions). Any part of a program that produces a value or a side effect is called an expression. It has a very wide definition because even a constant value like $(C 42) and a string like $(STRING "hello") are expressions, since they produce the respective constant values 42 and "hello".
)

$(P
$(I $(B Note:) Don't confuse producing a value with defining a variable. Values need not be associated with variables.
)
)

$(P
Function calls like $(C writeln) are expressions as well because they have side effects. In the case of $(C writeln), the effect is on the output stream by the placement of characters on it. Another example from the programs that we have written so far would be the assignment operation, which affects the variable that is on its left-hand side.
)

$(P
Because of producing values, expressions can take part in other expressions. This allows us to form more complex expressions from simpler ones. For example, assuming that there is a function named $(C currentTemperature) that produces the value of the current air temperature, the value that it produces may directly be used in a $(C writeln) expression:
)

---
    writeln("It's ", currentTemperature(),
            " degrees at the moment.");
---

$(P
That line consists of four expressions:
)

$(OL
$(LI $(STRING "It's "))
$(LI $(C currentTemperature()))
$(LI $(STRING " degrees at the moment."))
$(LI The $(C writeln()) expression that makes use of the other three)
)

$(P
In this chapter we will cover the particular type of expression that is used in conditional statements.
)

$(P
Before going further though, I would like to repeat the assignment operator once more, this time emphasizing the two expressions that appear on its left and right sides: the assignment operator ($(C =)) assigns the value of the expression on its right-hand side to the expression on its left-hand side (e.g. to a variable).
)

---
    temperature $(HILITE =) 23      // temperature's value becomes 23
---

$(H5 Logical Expressions)

$(P
Logical expressions are the expressions that are used in Boolean arithmetic. Logical expressions are what makes computer programs make decisions like "if the answer is yes, I will save the file".
)

$(P
Logical expressions can have one of only two values: $(C false) that indicates falsity, and $(C true) that indicates truth.
)

$(P
I will use $(C writeln) expressions in the following examples. If a line has $(C true) printed at the end, it will mean that what is printed on the line is true. Similarly, $(C false) will mean that what is on the line is false. For example, if the output of a program is the following,
)

$(SHELL
There is coffee: true
)

$(P
then it will mean that "there is coffee". Similarly,
)

$(SHELL
There is coffee: false
)

$(P
will mean that "there is no coffee". I use the "...&nbsp;is&nbsp;...:&nbsp;false" construct to mean "is not" or "is false".
)

$(P
Logical expressions are used extensively in $(I conditional statements), $(I loops), $(I function parameters), etc. It is essential to understand how they work. Luckily, logical expressions are easy to explain and use.
)

$(P
The logical operators that are used in logical expressions are the following:
)

$(UL

$(LI $(IX ==) $(IX equals, logical operator) The $(C ==) operator answers the question "is equal to?". It compares the expression on its left side to the one on its right side and produces $(C true) if they are equal and $(C false) if they are not. By definition, the value that $(C ==) produces is a logical expression.

$(P
As an example, let's assume that we have the following two variables:
)

---
    int daysInWeek = 7;
    int monthsInYear = 12;
---

$(P
The following are two logical expressions that use those values:
)

---
    daysInWeek == 7           // true
    monthsInYear == 11        // false
---

)

$(LI $(IX !=) $(IX not equals, logical operator) The $(C !=) operator answers the question "is not equal to?". It compares the two expressions on its sides and produces the opposite of $(C ==).


---
    daysInWeek != 7           // false
    monthsInYear != 11        // true
---

)

$(LI $(IX ||) $(IX or, logical operator) The $(C ||) operator means "or", and produces $(C true) if any one of the logical expressions is true.

$(P
If the value of the left-hand expression is $(C true), it produces $(C true) without even looking at the expression that is on the right-hand side. If the left-hand side is $(C false), then it produces the value of the right-hand side. This operator is similar to the "or" in English: if the left one, the right one, or both are $(C true), then it produces $(C true).
)

$(P
The following table presents all of the possible values for both sides of this operator and its result:
)

<table class="wide centered" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">Left expression</th><th scope="col">Operator</th><th scope="col">Right expression</th><th scope="col">Result</th></tr>
<tr><td>false</td><td>||</td><td>false</td><td>false</td></tr>
<tr><td>false</td><td>||</td><td>true</td><td>true</td></tr>
<tr><td>true</td><td>||</td><td>false (not evaluated)</td><td>true</td></tr>
<tr><td>true</td><td>||</td><td>true (not evaluated)</td><td>true</td></tr>
</table>

---
import std.stdio;

void main() {
    // false means "no", true means "yes"

    bool existsCoffee = false;
    bool existsTea = true;

    writeln("There is warm drink: ",
            existsCoffee $(HILITE ||) existsTea);
}
---

$(P
Because at least one of the two expressions is $(C true), the logical expression above produces $(C true).
)

)

$(LI $(IX &&) $(IX and, logical operator) The $(C &&) operator means "and", and produces $(C true) if both of the expressions are true.

$(P
If the value of the left-hand expression is $(C false), it produces $(C false) without even looking at the expression that is on the right-hand side. If the left-hand side is $(C true), then it produces the value of the right-hand side. This operator is similar to the "and" in English: if the left value and the right value are $(C true), then it produces $(C true).
)

<table class="wide centered" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">Left expression</th><th scope="col">Operator</th><th scope="col">Right expression</th><th scope="col">Result</th></tr>
<tr><td>false</td><td>&&</td><td>false (not evaluated)</td><td>false</td></tr>
<tr><td>false</td><td>&&</td><td>true (not evaluated)</td><td>false</td></tr>
<tr><td>true</td><td>&&</td><td>false</td><td>false</td></tr>
<tr><td>true</td><td>&&</td><td>true</td><td>true</td></tr>
</table>

---
    writeln("I will drink coffee: ",
            wantToDrinkCoffee $(HILITE &&) existsCoffee);
---

$(P $(I
$(B Note:) The fact that the $(C ||) and $(C &&) operators may not evaluate the right-hand expression is called their) short-circuit behavior $(I. The ternary operator $(C ?:), which we will see in a later chapter, is similar in that it never evaluates one of its three expressions. All of the other operators always evaluate and use all of their expressions.
))

)

$(LI $(IX ^, logical exclusive or) $(IX xor, logical operator) The $(C ^) operator answers the question "is one or the other but not both?". This operator produces $(C true) if only one expression is $(C true), but not both.

$(P
$(B Warning:) In reality, this operator is not a logical operator but an arithmetic one. It behaves like a logical operator only if both of the expressions are $(C bool).
)

<table class="wide centered" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">Left expression</th><th scope="col">Operator</th><th scope="col">Right expression</th><th scope="col">Result</th></tr>
<tr><td>false</td><td>^</td><td>false</td><td>false</td></tr>
<tr><td>false</td><td>^</td><td>true</td><td>true</td></tr>
<tr><td>true</td><td>^</td><td>false</td><td>true</td></tr>
<tr><td>true</td><td>^</td><td>true</td><td>false</td></tr>
</table>

$(P
For example, the logic that represents my playing chess if $(I only one) of my two friends shows up can be coded like this:
)

---
    writeln("I will play chess: ", jimShowedUp $(HILITE ^) bobShowedUp);
---

)

$(LI $(IX <, less than) $(IX less than, logical operator) The $(C <) operator answers the question "is less than?" (or "does come before in sort order?").

---
    writeln("We beat: ", theirScore $(HILITE <) ourScore);
---

)

$(LI $(IX >, greater than) $(IX greater than, logical operator) The $(C >) operator answers the question "is greater than?" (or "does come after in sort order?").

---
    writeln("They beat: ", theirScore $(HILITE >) ourScore);
---

)

$(LI $(IX <=) $(IX less than or equal to, logical operator) The $(C <=) operator answers the question "is less than or equal to?" (or "does come before or the same in sort order?"). This operator is the opposite of the $(C >) operator.

---
    writeln("We were not beaten: ", theirScore $(HILITE <=) ourScore);
---

)

$(LI $(IX >=) $(IX greater than or equal to, logical operator) The $(C >=) operator answers the question "is greater than or equal to?" (or "does come after or the same in sort order?"). This operator is the opposite of the $(C <) operator.

---
    writeln("We did not beat: ", theirScore $(HILITE >=) ourScore);
---

)

$(LI $(IX !, logical not) $(IX not, logical operator) The $(C !) operator means "the opposite of". Different from the other logical operators, it takes just one expression and produces $(C true) if that expression is $(C false), and $(C false) if that expression is $(C true).

---
    writeln("I will walk: ", $(HILITE !)existsBicycle);
---

)

)

$(H5 Grouping expressions)

$(P
The order in which the expressions are evaluated can be specified by using parentheses to group them. When parenthesized expressions appear in more complex expressions, the parenthesized expressions are evaluated before they can be used in the expressions that they appear in. For example, the expression "if there is coffee or tea, and also cookie or scone; then I am happy" can be coded as follows:
)

---
writeln("I am happy: ",
(existsCoffee || existsTea) && (existsCookie || existsScone));
---

$(P
If the sub expressions were not parenthesized, the expressions would be evaluated according to $(I operator precedence) rules of D (which have been inherited from the C language). Since in these rules $(C &&) has a higher precedence than $(C ||), writing the expression without parentheses would not be evaluated as intended:
)

---
writeln("I am happy: ",
existsCoffee || existsTea && existsCookie || existsScone);
---

$(P
The $(C &&) operator would be evaluated first and the whole expression would be the semantic equivalent of the following expression:
)

---
writeln("I am happy: ",
existsCoffee || (existsTea && existsCookie) || existsScone);
---

$(P
That has a totally different meaning: "if there is coffee, or tea and cookie, or scone; then I am happy".
)

$(P1
Almost nobody can memorize all of the operator precedence rules. For that reason, for code correctness and clarity, it would be helpful to use parentheses even when not necessary.
)

$(P
The operator precedence table will be presented $(LINK2 operator_precedence.html, later in the book).
)

$(H5 $(IX input, bool) $(IX read, bool) Reading $(C bool) input)

$(P
All of the $(C  bool) values above are automatically printed as $(STRING "false") or $(STRING "true"). It is the same in the opposite direction: $(C readf()) automatically converts strings $(STRING "false") and $(STRING "true") to $(C bool) values $(C false) and $(C true), respectively. It accepts any combination of lower and uppercase letters as well. For example, $(STRING "False") and $(STRING "FALSE") are converted to $(C false) and $(STRING "True") and $(STRING "TRUE") are converted to $(C true).
)

$(P
Note that this is the case only when reading into $(C bool) variables. Otherwise, the input would be read as-is without conversion when reading into a $(C string) variable. (As we will see later in the $(LINK2 strings.html, strings chapter), one must use $(C readln()) when reading strings.)
)

$(PROBLEM_COK

$(PROBLEM
We've seen above that the $(C <) and the $(C >) operators are used to determine whether a value is less than or greater than another value; but there is no operator that answers the question "is between?" to determine whether a value is between two other values.

$(P
Let's assume that a programmer has written the following code to determine whether $(C value) is between 10 and 20. Observe that the program cannot be compiled as written:
)

---
import std.stdio;

void main() {
    int value = 15;

    writeln("Is between: ",
            10 < value < 20);        $(DERLEME_HATASI)
}
---

$(P
Try using parentheses around the whole expression:
)

---
    writeln("Is between: ",
            (10 < value < 20));      $(DERLEME_HATASI)
---

$(P
Observe that it still cannot be compiled.
)

)

$(PROBLEM

While searching for a solution to this problem, the same programmer discovers that the following use of parentheses now enables the code to be compiled:

---
    writeln("Is between: ",
            (10 < value) < 20);      // ← compiles but WRONG
---
$(P
Observe that the program now works as expected and prints "true". Unfortunately, that output is misleading because the program has a bug. To see the effect of that bug, replace 15 with a value greater than 20:
)

---
    int value = 21;
---

$(P
Observe that the program still prints "true" even though 21 is not less than 20.
)

$(P
$(B Hint:) Remember that the type of a logical expression is $(C bool). It shouldn't make sense whether a $(C bool) value is less than 20. The reason it compiles is due to the compiler converting the boolean expression to a 1 or 0, and then evaluating that against 20 to see if it is less.
)

)

$(PROBLEM
The logical expression that answers the question "is between?" must instead be coded like this: "is greater than the lower value and less than the upper value?".

$(P
Change the expression in the program according to that logic and observe that it now prints "true" as expected. Additionally, test that the logical expression works correctly for other values as well: for example, when $(C value) is 50 or 1, the program should print "false"; and when it is 12, the program should print "true".
)

)

$(PROBLEM
Let's assume that we can go to the beach when one of the following conditions is true:

$(UL

$(LI If the distance to the beach is less than 10 miles and there is a bicycle for everyone)

$(LI If there is fewer than 6 of us, and we have a car, and at least one of us has a driver license)

)

$(P
As written, the following program always prints "true". Construct a logical expression that will print "true" when one of the conditions above is true. (When trying the program, enter "false" or "true" for questions that start with "Is there a".).
)

---
import std.stdio;

void main() {
    write("How many are we? ");
    int personCount;
    readf(" %s", &personCount);

    write("How many bicycles are there? ");
    int bicycleCount;
    readf(" %s", &bicycleCount);

    write("What is the distance to the beach? ");
    int distance;
    readf(" %s", &distance);

    write("Is there a car? ");
    bool existsCar;
    readf(" %s", &existsCar);

    write("Is there a driver license? ");
    bool existsLicense;
    readf(" %s", &existsLicense);

    /* Replace the 'true' below with a logical expression that
     * produces the value 'true' when one of the conditions
     * listed in the question is satisfied: */
    writeln("We are going to the beach: ", true);
}
---

$(P
Enter various values and test that the logical expression that you wrote works correctly.
)

)

)

Macros:
        TITLE=Logical Expressions

        DESCRIPTION=The logical expressions and the logical operators of the D programming language

        KEYWORDS=d programming language tutorial book logical expression bool false true

MINI_SOZLUK=
