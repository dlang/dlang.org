Ddoc

$(COZUM_BOLUMU Logical Expressions)

$(OL

$(LI

Because the compiler recognizes $(C 10 < value) already as an expression, it expects a comma after it to accept it as a legal argument to $(C writeln). Using parentheses around the whole expression would not work either, because this time a closing parenthesis would be expected after the same expression.
)

$(LI
Grouping the expression as $(C (10 < value) < 20) removes the compilation error, because in this case first $(C 10 < value) is evaluated and then its result is used with $(C <&nbsp;20).

$(P
We know that the value of a logical expression like $(C 10 < value) is either $(C false) or $(C true). $(C false) and $(C true) take part in integer expressions as 0 and 1, respectively. (We will see automatic type conversions in a later chapter.) As a result, the whole expression is the equivalent of either $(C 0 < 20) or $(C 1 < 20), both of which evaluate to $(C true).
)

)

$(LI
The expression "greater than the lower value and less than the upper value" can be coded as follows:

---
    writeln("Is between: ", (value > 10) && (value < 20));
---

)

$(LI
"There is a bicycle for everyone" can be coded as $(C personCount <= bicycleCount) or $(C bicycleCount >= personCount). The rest of the logical expression can directly be translated to D from the exercise:

---
    writeln("We are going to the beach: ",
            ((distance < 10) && (bicycleCount >= personCount))
            ||
            ((personCount <= 5) && existsCar && existsLicense)
            );
---

$(P
Note the placement of the $(C ||) operator to help with readability by separating the two main conditions.
)

)

)

Macros:
        TITLE=Logical Expressions Solutions

        DESCRIPTION=Logical Expressions chapter exercise solutions

        KEYWORDS=programming in d tutorial logical expressions exercise solution
