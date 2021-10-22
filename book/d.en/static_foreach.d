Ddoc

$(DERS_BOLUMU $(IX foreach, static) $(IX static foreach) $(CH4 static foreach))

$(P
We saw compile-time $(C foreach) earlier in the $(LINK2 tuples.html, Tuples chapter). Compile-time $(C foreach) iterates the loop at compile time and unrolls each iteration as separate pieces of code. For example, given the following $(C foreach) loop over a tuple:
)

---
    auto t = tuple(42, "hello", 1.5);

    foreach (i, member; $(HILITE t)) {
        writefln("%s: %s", i, member);
    }
---

$(P
The compiler $(I unrolls) the loop similar to the following equivalent code:
)

---
    {
        enum size_t i = 0;
        int member = t[i];
        writefln("%s: %s", i, member);
    }
    {
        enum size_t i = 1;
        string member = t[i];
        writefln("%s: %s", i, member);
    }
    {
        enum size_t i = 2;
        double member = t[i];
        writefln("%s: %s", i, member);
    }
---

$(P
Although being very powerful, some properties of compile-time $(C foreach) may not be suitable in some cases:
)

$(UL

$(LI
With compile-time $(C foreach), each unrolling of the loop introduces a scope. As seen with the $(C i) and $(C member) variables above, this allows the use of a symbol in more than one scope without causing a multiple definition error. Although this can be desirable in some cases, it makes it impossible for code unrolled for one iteration to use code from other iterations.
)

$(LI
Compile-time $(C foreach) works only with tuples (including template arguments in the form of $(C AliasSeq)). For example, despite the elements of the following array literal being known at compile time, the loop will always be executed at run time (this may very well be the desired behavior):
)

)

---
void main() {
    $(HILITE enum) arr = [1, 2];
    // Executed at run time, not unrolled at compile time:
    foreach (i; arr) {
        // ...
    }
}
---

$(UL

$(LI
Like regular $(C foreach), compile-time $(C foreach) can only be used inside functions. For example, it cannot be used at module scope or inside a user-defined type definition.
)

)

---
import std.meta;

// Attempting to define function overloads at module scope:
foreach (T; AliasSeq!(int, double)) {    $(DERLEME_HATASI)
    T twoTimes(T arg) {
        return arg * 2;
    }
}

void main() {
}
---

$(SHELL
Error: declaration expected, not `foreach`
)

$(UL

$(LI
With compile-time $(C foreach), it may not be clear whether $(C break) and $(C continue) statements inside the loop body should affect the compile-time loop iteration itself or whether they should be parts of the unrolled code.
)

)

$(P
$(C static foreach) is a more powerful compile-time feature that provides more control:
)

$(UL

$(LI
$(C static foreach) can work with any range of elements that can be computed at compile time (including number ranges like $(C 1..10)). For example, given the $(C FibonacciSeries) range from $(LINK2 ranges.html, the Ranges chapter) and a function that determines whether a number is even:
)

)

---
    $(HILITE static foreach) (n; FibonacciSeries().take(10).filter!isEven) {
        writeln(n);
    }
---

$(P
The loop above would be unrolled as the following equivalent:
)

---
    writeln(0);
    writeln(2);
    writeln(8);
    writeln(34);
---

$(UL

$(LI $(C static foreach) can be used at module scope.)

$(LI
$(C static foreach) does not introduce a separate scope for each iteration. For example, the following loop defines two overloads of a function at module scope:
)

)

---
import std.meta;

static foreach (T; AliasSeq!(int, double)) {
    T twoTimes(T arg) {
        return arg * 2;
    }
}

void main() {
}
---

$(P
The loop above would be unrolled as its following equivalent:
)

---
    int twoTimes(int arg) {
        return arg * 2;
    }

    double twoTimes(double arg) {
        return arg * 2;
    }
---

$(UL

$(LI
$(C break) and $(C continue) statements inside a $(C static foreach) loop require labels for clarity. For example, the following code unrolls (generates) $(C case) clauses inside a $(C switch) statement. The $(C break) statements that are under each $(C case) clause must mention the associated $(C switch) statements by labels:
)

)

---
import std.stdio;

void main(string[] args) {

$(HILITE theSwitchStatement:)
    switch (args.length) {
        static foreach (i; 1..3) {
            case i:
                writeln(i);
                break $(HILITE theSwitchStatement);
        }

    default:
        writeln("default case");
        break;
    }
}
---

$(P
After the loop above is unrolled, the $(C switch) statement would be the equivalent of the following code:
)

---
    switch (args.length) {
    case 1:
        writeln(1);
        break;

    case 2:
        writeln(2);
        break;

    default:
        writeln("default case");
        break;
    }
---

macros:
        TITLE=static foreach

        DESCRIPTION=static foreach, one of D's compile-time feature that can generate code by iterating ranges.

        KEYWORDS=d programming language tutorial book static foreach

MINI_SOZLUK=
