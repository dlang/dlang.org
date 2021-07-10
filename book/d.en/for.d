Ddoc

$(DERS_BOLUMU $(IX for) $(IX loop, for) $(CH4 for) Loop)

$(P
The $(C for) loop serves the same purpose as $(LINK2 while.html, the $(C while) loop). $(C for) makes it possible to put the definitions and expressions concerning the loop's iteration on the same line.
)

$(P
Although $(C for) is used much less than $(C foreach) in practice, it is important to understand the $(C for) loop first. We will see $(C foreach) in $(LINK2 foreach.html, a later chapter).
)

$(H5 The sections of the $(C while) loop)

$(P
The $(C while) loop evaluates the loop condition and continues executing the loop as long as that condition is $(C true). For example, a loop to print the numbers between 1 and 10 may check the condition $(I less than 11):
)

---
    while (number < 11)
---

$(P
$(I Iterating) the loop can be achieved by incrementing $(C number) at the end of the loop:
)

---
        ++number;
---

$(P
To be compilable as D code, $(C number) must have been defined before its first use:
)

---
    int number = 1;
---

$(P
Finally, there is the actual work within the loop body:
)

---
        writeln(number);
---

$(P
These four sections can be combined into the desired loop as follows:
)

---
    int number = 1;         // ← preparation

    while (number < 11) {   // ← condition check
        writeln(number);    // ← actual work
        ++number;           // ← iteration
    }
---

$(P
The sections of the $(C while) loop are executed in the following order during the iteration of the $(C while) loop:
)

$(MONO
preparation

condition check
actual work
iteration

condition check
actual work
iteration

...
)

$(P
A $(C break) statement or a thrown exception can terminate the loop as well.
)

$(H5 The sections of the $(C for) loop)

$(P
The $(C for) loop brings three of these sections onto a single line. They are written within the parentheses of the $(C for) loop, separated by semicolons. The loop body contains only the actual work:
)

---
for (/* preparation */; /* condition check */; /* iteration */) {
    /* actual work */
}
---

$(P
Here is the same code written as a $(C for) loop:
)

---
    for (int number = 1; number < 11; ++number) {
        writeln(number);
    }
---

$(P
The benefits of the $(C for) loop are more obvious when the loop body has a large number of statements. The expression that increments the loop variable is visible on the $(C for) line instead of being mixed with the other statements of the loop. It is also more clear that the declared variable is used only as part of the loop, and not by any other surrounding code.
)

$(P
The sections of the $(C for) loop are executed in the same order as in the $(C while) loop. The $(C break) and $(C continue) statements also work exactly the same way as they do in the $(C for) loop. The only difference between $(C while) and $(C for) loops is the name scope of the loop variable. This is explained below.
)

$(P
Although very common, the iteration variable need not be an integer, nor it is modified only by incrementing. For example, the following loop is used to print the halves of the previous floating point values:
)

---
    for (double value = 1; value > 0.001; value /= 2) {
        writeln(value);
    }
---

$(P
$(B Note:) The information above is technically incorrect but better captures the spirit of how the $(C for) loop is used in practice. In reality, D's $(C for) loop does not have $(I three sections that are separated by semicolons). It has two sections, the first of which consisting of the preparation and the loop condition.
)

$(P
Without getting into the details of this syntax, here is how to define two variables of different types in the preparation section:
)

---
    for ($(HILITE {) int i = 0; double d = 0.5; $(HILITE }) i < 10; ++i) {
        writeln("i: ", i, ", d: ", d);
        d /= 2;
    }
---

$(P
Note that the preparation section is the area within the highlighted curly brackets and that there is no semicolon between the preparation section and the condition section.
)

$(H5 The sections may be empty)

$(P
All three of the $(C for) loop sections may be left empty:
)

$(UL
$(LI Sometimes a special loop variable is not needed, possibly because an already-defined variable would be used.
)
$(LI Sometimes the loop would be exited by a $(C break) statement, instead of by relying on the loop condition.
)
$(LI Sometimes the iteration expressions depend on certain conditions that would be checked within the loop body.
)
)

$(P
When all of the sections are emtpy, the $(C for) loop means $(I forever):
)

---
    for ( ; ; ) {
        // ...
    }
---

$(P
Such a loop may be designed to never end or end with a $(C break) statement.
)

$(H5 The name scope of the loop variable)

$(P
The only difference between the $(C for) and $(C while) loops is the name scope of the variable defined during loop preparation: The variable is accessible only within the $(C for) loop, not outside of it:
)

---
    for (int i = 0; i < 5; ++i) {
        // ...
    }

    writeln(i);   $(DERLEME_HATASI)
                  //   i is not accessible here
---


$(P
In contrast, when using a $(C while) loop the variable is defined in the same name scope as that which contains the loop, and therefore the name is accessible even after the loop:
)

---
    int i = 0;

    while (i < 5) {
        // ...
        ++i;
    }

    writeln(i);   // ← 'i' is accessible here
---

$(P
We have seen the guideline of $(I defining names closest to their first use) in the previous chapter. Similar to the rationale for that guideline, the smaller the name scope of a variable the better. In this regard, when the loop variable is not needed outside the loop, a $(C for) loop is better than a $(C while) loop.
)

$(PROBLEM_COK

$(PROBLEM

Print the following 9x9 table by using two $(C for) loops, one inside the other:

$(SHELL
0,0 0,1 0,2 0,3 0,4 0,5 0,6 0,7 0,8 
1,0 1,1 1,2 1,3 1,4 1,5 1,6 1,7 1,8 
2,0 2,1 2,2 2,3 2,4 2,5 2,6 2,7 2,8 
3,0 3,1 3,2 3,3 3,4 3,5 3,6 3,7 3,8 
4,0 4,1 4,2 4,3 4,4 4,5 4,6 4,7 4,8 
5,0 5,1 5,2 5,3 5,4 5,5 5,6 5,7 5,8 
6,0 6,1 6,2 6,3 6,4 6,5 6,6 6,7 6,8 
7,0 7,1 7,2 7,3 7,4 7,5 7,6 7,7 7,8 
8,0 8,1 8,2 8,3 8,4 8,5 8,6 8,7 8,8 
)

)

$(PROBLEM

Use one or more $(C for) loops to print the $(C *) character as needed to produce geometrical patterns:


$(SHELL
*
**
***
****
*****
)

$(SHELL
********
 ********
  ********
   ********
    ********
)

etc.

)

)

Macros:
        TITLE=for Loop

        DESCRIPTION=The for loop of the D programming language and comparing it the while loop.

        KEYWORDS=d programming language tutorial book for loop
