Ddoc

$(DERS_BOLUMU $(CH4 auto) and $(CH4 typeof))

$(H5 $(IX auto, variable) $(C auto))

$(P
When defining $(C File) variables in the previous chapter, we have repeated the name of the type on both sides of the $(C =) operator:
)

---
    $(HILITE File) file = $(HILITE File)("student_records", "w");
---

$(P
It feels redundant. It would also be cumbersome and especially error-prone if the type name were longer:
)

---
    VeryLongTypeName var = VeryLongTypeName(/* ... */);
---

$(P
Fortunately, the type name on the left-hand side is not necessary because the compiler can infer the type of the left-hand side from the expression on the right-hand side. For the compiler to infer the type, the $(C auto) keyword can be used:
)

---
    $(HILITE auto) var = VeryLongTypeName(/* ... */);
---

$(P
$(C auto) can be used with any type even when the type is not spelled out on the right-hand side:
)

---
    auto duration = 42;
    auto distance = 1.2;
    auto greeting = "Hello";
    auto vehicle = BeautifulBicycle("blue");
---

$(P
Although "auto" is the abbreviation of $(I automatic), it does not come from $(I automatic type inference). It comes from $(I automatic storage class), which is a concept about the life times of variables. $(C auto) is used when no other specifier is appropriate. For example, the following definition does not use $(C auto):
)

---
    immutable i = 42;
---

$(P
The compiler infers the type of $(C i) as $(C immutable int) above. (We will see $(C immutable) in a later chapter.)
)

$(H5 $(IX typeof) $(C typeof))

$(P
$(C typeof) provides the type of an expression (including single variables, objects, literals, etc.) without actually evaluating that expression.
)

$(P
The following is an example of how $(C typeof) can be used to specify a type without explicitly spelling it out:
)

---
    int value = 100;      // already defined as 'int'

    typeof(value) value2; // means "type of value"
    typeof(100) value3;   // means "type of literal 100"
---

$(P
The last two variable definitions above are equivalent to the following:
)

---
    int value2;
    int value3;
---

$(P
It is obvious that $(C typeof) is not needed in situations like above when the actual types are known. Instead, you would typically use it in more elaborate scenarios, where you want the type of your variables to be consistent with some other piece of code whose type can vary. This keyword is especially useful in $(LINK2 templates.html, templates) and $(LINK2 mixin.html, mixins), both of which will be covered in later chapters.
)

$(PROBLEM_TEK

$(P
As we have seen above, the type of literals like 100 is $(C int) (as opposed to $(C short), $(C long), or any other type). Write a program to determine the type of floating point literals like 1.2. $(C typeof) and $(C .stringof) would be useful in this program.
)

)

Macros:
        TITLE=auto and typeof keywords

        DESCRIPTION=The 'auto' keyword which is commonly used for D's implicit type inference feature, and 'typeof' which yields type of expressions.

        KEYWORDS=d programming language tutorial book auto typeof
