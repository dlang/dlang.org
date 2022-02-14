Ddoc

$(DERS_BOLUMU $(IX lazy evaluation) Lazy Operators)

$(P
Lazy evaluation is the delaying of the execution of expressions until the results of those expressions are needed. Lazy evaluation is among the fundamental features of some programming languages.
)

$(P
Naturally, this delaying may make programs run faster if the results end up not being needed.
)

$(P
$(IX short-circuit evaluation) A concept that is similar to lazy evaluation is the short-circuit behavior of the following operators:
)

$(UL

$(LI $(IX ||, short-circuit) $(IX logical or operator) $(C ||) ($(I or)) operator: The second expression is evaluated only if the first expression is $(C false).

---
    if (anExpression() || mayNotBeEvaluated()) {
        // ...
    }
---

$(P
If the result of $(C anExpression()) is $(C true) then the result of the $(C ||) expression is necessarily $(C true). Since we no longer need to evaluate the second expression to determine the result of the $(C ||) expression the second expression is not evaluated.
)

)

$(LI $(IX &&, short-circuit) $(IX logical and operator) $(C &&) ($(I and)) operator: The second expression is evaluated only if the first expression is $(C true).

---
    if (anExpression() && mayNotBeEvaluated()) {
        // ...
    }
---

$(P
If the result of $(C anExpression()) is $(C false) then the result of the $(C &&) expression is necessarily $(C false), so the second expression is not evaluated.
)

)

$(LI $(IX ?:, short-circuit) $(IX ternary operator) $(IX conditional operator) $(C ?:) ($(I ternary)) operator: Either the first or the second expression is evaluated, depending on whether the condition is $(C true) or $(C false), respectively.

---
    int i = condition() ? eitherThis() : orThis();
---

)

)

$(P
The laziness of these operators matters not only to performance. Sometimes, evaluating one of the expressions can be an error.
)

$(P
For example, the $(I is the first letter an A) condition check below would be an error when the string is empty:
)

---
    dstring s;
    // ...
    if (s[0] == 'A') {
        // ...
    }
---

$(P
In order to access the first element of $(C s), we must first ensure that the string does have such an element. For that reason, the following condition check moves that potentially erroneous logical expression to the right-hand side of the $(C &&) operator, to ensure that it will be evaluated only when it is safe to do so:
)

---
    if ((s.length >= 1) && (s[0] == 'A')) {
        // ...
    }
---

$(P
Lazy evaluations can be achieved by using $(LINK2 lambda.html, function pointers, delegates), and $(LINK2 ranges.html, ranges) as well. We will see these in later chapters.
)

Macros:
        TITLE=Lazy Operators

        DESCRIPTION=The lazy (short-circuit) operators of the D programming language.

        KEYWORDS=d programming language tutorial book lazy
