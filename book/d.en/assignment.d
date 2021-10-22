Ddoc

$(DERS_BOLUMU Assignment and Order of Evaluation)

$(P
The first two difficulties that most students face when learning to program involve the assignment operation and the order of evaluation.
)

$(H5 The assignment operation)

$(P
You will see lines similar to the following in almost every program in almost every programming language:
)

---
    a = 10;
---

$(P
The meaning of that line is "make $(C a)'s value become 10". Similarly, the following line means "make $(C b)'s value become 20":
)

---
    b = 20;
---

$(P
Based on that information, what can be said about the following line?
)

---
    a = b;
---

$(P
Unfortunately, that line is not about the equality concept of mathematics that we all know. The expression above $(B does not) mean "a is equal to b"! When we apply the same logic from the earlier two lines, the expression above must mean "make $(C a)'s value become the same as $(C b)'s value".
)

$(P
The well-known $(C =) symbol of mathematics has a completely different meaning in programming: make the left side's value the same as the right side's value.
)

$(H5 Order of evaluation)

$(P
In general, the operations of a program are applied step by step in the order that they appear in the program. (There are exceptions to this rule, which we will see in later chapters.) We may see the previous three expressions in a program in the following order:
)

---
    a = 10;
    b = 20;
    a = b;
---

$(P
The meaning of those three lines altogether is this: "make $(C a)'s value become 10, $(I then) make $(C b)'s value become 20, $(I then) make $(C a)'s value become the same as $(C b)'s value". Accordingly, after those three operations are performed, the value of both $(C a) and $(C b) would be 20.
)

$(PROBLEM_TEK

$(P
Observe that the following three operations swap the values of $(C a) and $(C b). If at the beginning their values are 1 and 2 respectively, after the operations the values become 2 and 1:
)

---
    c = a;
    a = b;
    b = c;
---

)

$(Ergin)

Macros:
        TITLE=Assignment and Order of Evaluation

        DESCRIPTION=The very first two hurdles that a student faces when learning to program

        KEYWORDS=d programming language tutorial book

MINI_SOZLUK=
