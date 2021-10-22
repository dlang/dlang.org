Ddoc

$(DERS_BOLUMU $(IX name scope) Name Scope)

$(P
Any name is accessible from the point where it has been defined at to the point where its scope ends, as well as in all of the scopes that its scope includes. In this regard, every scope defines a $(I name scope).
)

$(P
Names are not available beyond the end of their scope:
)

---
void main() {
    int outer;

    if (aCondition) $(HILITE {)  // ← curly bracket starts a new scope
        int inner = 1;
        outer = 2;     // ← 'outer' is available here

    $(HILITE }) // ← 'inner' is not available beyond this point

    inner = 3;  $(DERLEME_HATASI)
                //   'inner' is not available in the outer scope
}
---

$(P
Because $(C inner) is defined within the scope of the $(C if) condition it is available only in that scope. On the other hand, $(C outer) is available in both the outer scope and the inner scope.
)

$(P
It is not legal to define the same name in an inner scope:
)

---
    size_t $(HILITE length) = oddNumbers.length;

    if (aCondition) {
        size_t $(HILITE length) = primeNumbers.length; $(DERLEME_HATASI)
    }
---

$(H5 Defining names closest to their first use)

$(P
As we have been doing in all of the programs so far, variables must be defined before their first use:
)

---
    writeln(number);     $(DERLEME_HATASI)
                         //   number is not known yet
    int number = 42;
---

$(P
For that code to be acceptable by the compiler, $(C number) must be defined before it is used with $(C writeln). Although there is no restriction on how many lines earlier it should be defined, it is accepted as good programming practice that variables be defined closest to where they are first used.
)

$(P
Let's see this in a program that prints the average of the numbers that it takes from the user. Programmers who are experienced in some other programming languages may be used to defining variables at tops of scopes:
)

---
    int count;                                 // ← HERE
    int[] numbers;                             // ← HERE
    double averageValue;                       // ← HERE

    write("How many numbers are there? ");

    readf(" %s", &count);

    if (count >= 1) {
        numbers.length = count;

        // ... assume the calculation is here ...

    } else {
        writeln("ERROR: You must enter at least one number!");
    }
---

$(P
Contrast the code above to the one below that defines the variables later, as each variable actually starts taking part in the program:
)

---
    write("How many numbers are there? ");

    int count;                                 // ← HERE
    readf(" %s", &count);

    if (count >= 1) {
        int[] numbers;                         // ← HERE
        numbers.length = count;

        double averageValue;                   // ← HERE

        // ... assume that the calculation is here ...

    } else {
        writeln("ERROR: You must enter at least one number!");
    }
---

$(P
Although defining all of the variables at the top may look better structurally, there are several benefits of defining them as late as possible:
)

$(UL
$(LI $(B Speed:) Every variable definition tends to add a small speed cost to the program. As every variable is initialized in D, defining variables at the top will result in them always being initialized, even if they are only sometimes used later, wasting resources.
)

$(LI $(B Risk of mistakes:) Every line between the definition and use of a variable carries a higher risk of programming mistakes. As an example of this, consider a variable using the common name $(C length). It is possible to confuse that variable with some other length and use it inadvertently before reaching the line of its first intended use. When that line is finally reached the variable may no longer have the desired value.
)

$(LI $(B Readability:) As the number of lines in a scope increase, it becomes more likely that the definition of a variable is too far up in the source code, forcing the programmer to scroll back in order to look at its definition.
)

$(LI $(B Code maintenance:) Source code is in constant modification and improvement: new features are added, old features are removed, bugs are fixed, etc. These changes sometimes make it necessary to extract a group of lines altogether into a new function.

$(P
When that happens, having all of the variables defined close to the lines that use them makes it easier to move them as a coherent bunch.
)

$(P
For example, in the latter code above that followed this guideline, all of the lines within the $(C if) statement can be moved to a new function in the program.
)

$(P
On the other hand, when the variables are always defined at the top, if some lines ever need to be moved, the variables that are used in those lines must be identified one by one.
)

)

)

Macros:
        TITLE=Name Scope

        DESCRIPTION=The scopes in the program where names are valid and accessible, and the benefits of defining variables closest to their first use in the program.

        KEYWORDS=d programming language tutorial book name scopes
