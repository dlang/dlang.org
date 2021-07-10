Ddoc

$(DERS_BOLUMU $(IX switch) $(IX case) $(CH4 switch) and $(CH4 case))

$(P
$(C switch) is a statement that allows comparing the value of an expression against multiple values. It is similar to but not the same as an "if, else if, else" chain. $(C case) is used for specifying the values that are to be compared with $(C switch)'s expression. $(C case) is a part of the $(C switch) statement, not a statement itself.
)

$(P
$(C switch) takes an expression within parentheses, compares the value of that expression to the $(C case) values, and executes the operations of the $(C case) that is equal to the value of the expression. Its syntax consists of a $(C switch) block that contains one or more $(C case) sections and a $(C default) section:
)

---
    switch ($(I expression)) {

    case $(I value_1):
        // operations to execute if the expression is equal to value_1
        // ...
        break;

    case $(I value_2):
        // operations to execute if the expression is equal to value_2
        // ...
        break;

    // ... other cases ...

    default:
        // operations to execute if the expression is not equal to any case
        // ...
        break;
    }
---

$(P
The expression that $(C switch) takes is not used directly as a logical expression. It is not evaluated as "if this condition is true", as it would be in an $(C if) statement. The $(I value) of the $(C switch) expression is used in equality comparisons with the $(C case) values. It is similar to an "if, else if, else" chain that has only equality comparisons:
)

---
    auto value = $(I expression);

    if (value == $(I value_1)) {
        // operations for value_1
        // ...

    } else if (value == $(I value_2)) {
        // operations for value_2
        // ...
    }

    // ... other 'else if's ...

    } else {
        // operations for other values
        // ...
    }
---

$(P
However, the "if, else if, else" above is not an exact equivalent of the $(C switch) statement. The reasons why will be explained in the following sections.
)

$(P
If a $(C case) value matches the value of the $(C switch) expression, then the operations that are under the $(C case) are executed. If no value matches, then the operations that are under the $(C default) are executed.
)

$(H5 $(IX goto case) $(IX goto default) The $(C goto) statement)

$(P
The use of $(C goto) is generally advised against in most programming languages. However, $(C goto) is useful in $(C switch) statements in some situations, without being as problematic as in other uses. The $(C goto) statement will be covered in more detail in $(LINK2 goto.html, a later chapter).
)

$(P
$(C case) does not introduce a $(I scope) as the $(C if) statement does. Once the operations within an $(C if) or $(C else) scope are finished the evaluation of the entire $(C if) statement is also finished. That does not happen with the $(C case) sections; once a matching $(C case) is found, the execution of the program jumps to that $(C case) and executes the operations under it. When needed in rare situations, $(C goto case) makes the program execution jump to the next $(C case):
)

---
    switch (value) {

    case 5:
        writeln("five");
        $(HILITE goto case);    // continues to the next case

    case 4:
        writeln("four");
        break;

    default:
        writeln("unknown");
        break;
    }
---

$(P
If $(C value) is 5, the execution continues under the $(C case 5) line and the program prints "five". Then the $(C goto case) statement causes the execution to continue to the next $(C case), and as a result "four" is also printed:
)

$(SHELL
five
four
)

$(P
$(C goto) can appear in three ways under $(C case) sections:
)

$(UL

$(LI $(IX fallthrough, case) $(C goto case) causes the execution to continue (fallthrough) to the next $(C case).)

$(LI $(C goto default) causes the execution to continue to the $(C default) section.)

$(LI $(C goto case $(I expression)) causes the execution to continue to the $(C case) that matches that expression.)

)

$(P
The following program demonstrates these three uses by taking advantage of a $(C foreach) loop:
)

---
import std.stdio;

void main() {
    foreach (value; [ 1, 2, 3, 10, 20 ]) {
        writefln("--- value: %s ---", value);

        switch (value) {

        case 1:
            writeln("case 1");
            $(HILITE goto case);

        case 2:
            writeln("case 2");
            $(HILITE goto case 10);

        case 3:
            writeln("case 3");
            $(HILITE goto default);

        case 10:
            writeln("case 10");
            break;

        default:
            writeln("default");
            break;
        }
    }
}
---

$(P
The output:
)

$(SHELL
--- value: 1 ---
case 1
case 2
case 10
--- value: 2 ---
case 2
case 10
--- value: 3 ---
case 3
default
--- value: 10 ---
case 10
--- value: 20 ---
default
)

$(H5 The expression must be an integer, string, or $(C bool) type)

$(P
Any type can be used in equality comparisons in $(C if) statements. On the other hand, the type of the $(C switch) expression is limited to all integer types, all string types, and $(C bool).
)

---
    string op = /* ... */;
    // ...
    switch (op) {

    case "add":
        result = first + second;
        break;

    case "subtract":
        result = first - second;
        break;

    case "multiply":
        result = first * second;
        break;

    case "divide":
        result = first / second;
        break;

    default:
        throw new Exception(format("Unknown operation: %s", op));
    }
---

$(P
$(I $(B Note:) The code above throws an exception when the operation is not recognized by the program. We will see exceptions in $(LINK2 exceptions.html, a later chapter).)
)

$(P
Although it is possible to use $(C bool) expressions as well, because $(C bool) has only two values it may be more suitable to use an $(C if) statement or the ternary operator ($(C ?:)) with that type.
)

$(H5 $(IX .., case value range) $(IX range, case) Value ranges)

$(P
Ranges of values can be specified by $(C ..) between $(C case)s:
)

---
    switch (dieValue) {

    case 1:
        writeln("You won");
        break;

    case 2: $(HILITE ..) case 5:
        writeln("It's a draw");
        break;

    case 6:
        writeln("I won");
        break;

    default:
        /* The program should never get here because the cases
         * above cover the entire range of valid die values.
         * (See 'final switch' below.) */
        break;
    }
---

$(P
The code above determines that the game ends in a draw when the die value is 2, 3, 4, or 5.
)

$(H5 Distinct values)

$(P
$(IX , (comma), case value list) Let's assume that it is a draw for the values 2 and 4, rather than for the values that are in the range [2, 5]. Distinct values of a $(C case) are separated by commas:
)

---
    case 2$(HILITE ,) 4:
        writeln("It's a draw");
        break;
---

$(H5 $(IX final switch) The $(C final switch) statement)

$(P
The $(C final switch) statement works similarly to the regular $(C switch) statement, with the following differences:
)

$(UL
$(LI It cannot have a $(C default) section. Note that this section is meaningless when the $(C case) sections cover the entire range of values anyway, as has been with the six values of the die above.
)

$(LI Value ranges cannot be used with $(C case)s (distinct values can be).
)

$(LI If the expression is of an $(C enum) type, all of the values of the type must be covered by the $(C case)s (we will see $(C enum) types in the next chapter).
)

)

---
    int dieValue = 1;

    final switch (dieValue) {

    case 1:
        writeln("You won");
        break;

    case 2, 3, 4, 5:
        writeln("It's a draw");
        break;

    case 6:
        writeln("I won");
        break;
    }
---

$(H5 When to use)

$(P
$(C switch) is suitable for comparing the value of an expression against a set of values that are known at compile time.
)

$(P
When there are only two values to compare, an $(C if) statement may make more sense. For example, to check whether it is heads or tails:
)

```d
    if (headsTailsResult == heads) {
        // ...

    } else {
        // ...
    }
```

$(P
As a general rule, $(C switch) is more suitable when there are three or more values to compare.
)

$(P
When all of the values need to be handled, then prefer $(C final switch). This is especially the case for $(C enum) types.
)

$(PROBLEM_COK

$(PROBLEM
Write a calculator program that supports arithmetic operations. Have the program first read the operation as a $(C string), then two values of type $(C double) from the input. The calculator should print the result of the operation. For example, when the operation and values are "add" and "5&nbsp;7", respectively, the program should print 12.

$(P
The input can be read as in the following code:
)

```d
    string op;
    double first;
    double second;

    // ...

    op = strip(readln());
    readf(" %s %s", &first, &second);
```

)

$(PROBLEM
Improve the calculator to support operators like "+" in addition to words like "add".
)

$(PROBLEM
Have the program throw an exception for unknown operators. We will cover exceptions in $(LINK2 exceptions.html, a later chapter). For now, adapt the $(C throw) statement used above to your program.
)

)

Macros:
        TITLE=switch and case

        DESCRIPTION=The switch-case statement that is used for comparing the value of an expression against multiple values.

        KEYWORDS=d programming language tutorial book switch case
