Ddoc

$(DERS_BOLUMU $(IX label) $(IX goto) Labels and $(CH4 goto))

$(P
$(IX :, label) Labels are names given to lines of code in order to direct program flow to those lines later on.
)

$(P
A label consists of a name and the $(C :) character:
)

---
end:   // ← a label
---

$(P
That label gives the name $(I end) to the line that it is defined on.
)

$(P
$(I $(B Note:) In reality, a label can appear between statements on the same line to name the exact spot that it appears at, but this is not a common practice:)
)

---
    anExpression(); $(HILITE end:) anotherExpression();
---

$(H5 $(C goto))

$(P
$(C goto) directs program flow to the specified label:
)

---
void foo(bool condition) {
    writeln("first");

    if (condition) {
        $(HILITE goto) end;
    }

    writeln("second");

end:

    writeln("third");
}
---

$(P
When $(C condition) is $(C true), the program flow $(I goes to) label $(C end), effectively skipping the line that prints "second":
)

$(SHELL_SMALL
first
third
)

$(P
$(C goto) works the same way as in the C and C++ programming languages. Being notorious for making it hard to understand the intent and flow of code, $(C goto) is discouraged even in those languages. Statements like $(C if), $(C while), $(C for) etc. should be used instead.
)

$(P
For example, the previous code can be written without $(C goto) in a more $(I structured) way:
)

---
void foo(bool condition) {
    writeln("first");

    if (!condition) {
        writeln("second");
    }

    writeln("third");
}
---

$(P
However, there are two acceptable uses of $(C goto) in C, none of which is necessary in D.
)

$(H6 Finalization area)

$(P
One of the valid uses of $(C goto) in C is going to the finalization area where the cleanup operations of a function are performed (e.g. giving resources back, undoing certain operations, etc.):
)

$(C_CODE
// --- C code ---

int foo() {
    // ...

    if (error) {
        goto finally;
    }

    // ...

finally:
    $(COMMENT // ... cleanup operations ...)

    return error;
}
)

$(P
This use of $(C goto) is not necessary in D because there are other ways of managing resources: the garbage collector, destructors, the $(C catch) and $(C finally) blocks, $(C scope()) statements, etc.
)

$(P $(I $(B Note:) This use of $(C goto) is not necessary in C++ either.)
)

$(H6 $(C continue) and $(C break) for outer loops)

$(P
The other valid use of $(C goto) in C is about outer loops.
)

$(P
Since $(C continue) and $(C break) affect only the inner loop, one way of continuing or breaking out of the outer loop is by $(C goto) statements:
)

$(C_CODE
// --- C code ---

    while (condition) {

        while (otherCondition) {

            $(COMMENT // affects the inner loop)
            continue;

            $(COMMENT // affects the inner loop)
            break;

            $(COMMENT // works like 'continue' for the outer loop)
            goto continueOuter;

            $(COMMENT // works like 'break' for the outer loop)
            goto breakOuter;
        }

    continueOuter:
        ;
    }
breakOuter:
)

$(P
The same technique can be used for outer $(C switch) statements as well.
)

$(P
This use of $(C goto) is not needed in D because D has loop labels, which we will see below.
)

$(P $(I $(B Note:) This use of $(C goto) can be encountered in C++ as well.)
)

$(H6 The problem of skipping constructors)

$(P
The constructor is called on an object exactly where that object is defined. This is mainly because the information that is needed to construct an object is usually not available until that point. Also, there is no need to construct an object if that object is not going to be used in the program at all.
)

$(P
When $(C goto) skips a line that an object is constructed on, the program can be using an object that has not been prepared yet:
)

---
    if (condition) {
        goto aLabel;    // skips the constructor
    }

    auto s = S(42);     // constructs the object properly

aLabel:

    s.bar();            // BUG: 's' may not be ready for use
---

$(P
The compiler prevents this bug:
)

$(SHELL
Error: goto skips declaration of variable deneme.main.s
)

$(H5 $(IX loop label) Loop labels)

$(P
Loops can have labels and $(C goto) statements can refer to those labels:
)

---
$(HILITE outerLoop:)
    while (condition) {

        while (otherCondition) {

            // affects the inner loop
            continue;

            // affects the inner loop
            break;

            // continues the outer loop
            continue $(HILITE outerLoop);

            // breaks the outer loop
            break $(HILITE outerLoop);
        }
    }
---

$(P
$(C switch) statements can have labels as well. An inner $(C break) statement can refer to an outer $(C switch) to break out of the outer $(C switch) statement.
)

$(H5 $(C goto) in $(C case) sections)

$(P
We have already seen the use of $(C goto) in $(C case) sections in $(LINK2 switch_case.html, the $(C switch) and $(C case) chapter):
)

$(UL

$(LI $(IX goto case) $(IX case, goto) $(C goto case) causes the execution to continue to the next $(C case).)

$(LI $(IX goto default) $(IX default, goto) $(C goto default) causes the execution to continue to the $(C default) section.)

$(LI $(C goto case $(I expression)) causes the execution to continue to the $(C case) that matches that expression.)

)

$(H5 Summary)

$(UL

$(LI
Some of the uses of $(C goto) are not necessary in D.
)

$(LI
$(C break) and $(C continue) can specify labels to affect outer loops and $(C switch) statements.
)

$(LI
$(C goto) inside $(C case) sections can make the program flow jump to other $(C case) and $(C default) sections.
)

)

Macros:
        TITLE=Labels and goto

        DESCRIPTION=Labels that are used for giving names to code lines, and goto that causes program flow to jump to those lines.

        KEYWORDS=d programming language tutorial book goto
