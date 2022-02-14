Ddoc

$(DERS_BOLUMU $(IX lvalue) $(IX rvalue) Lvalues and Rvalues)

$(P
$(IX expression, lvalue vs rvalue) The value of every expression is classified as either an lvalue or an rvalue. A simple way of differentiating the two is thinking of lvalues as actual variables (including elements of arrays and associative arrays), and rvalues as temporary results of expressions (including literals).
)

$(P
As a demonstration, the first $(C writeln()) expression below uses only lvalues and the other one uses only rvalues:
)

---
import std.stdio;

void main() {
    int i;
    immutable(int) imm;
    auto arr = [ 1 ];
    auto aa = [ 10 : "ten" ];

    /* All of the following arguments are lvalues. */

    writeln(i,          // mutable variable
            imm,        // immutable variable
            arr,        // array
            arr[0],     // array element
            aa[10]);    // associative array element
                        // etc.

    enum message = "hello";

    /* All of the following arguments are rvalues. */

    writeln(42,               // a literal
            message,          // a manifest constant
            i + 1,            // a temporary value
            calculate(i));    // return value of a function
                              // etc.
}

int calculate(int i) {
    return i * 2;
}
---

$(H5 Limitations of rvalues)

$(P
Compared to lvalues, rvalues have the following three limitations.
)

$(H6 Rvalues don't have memory addresses)

$(P
An lvalue has a memory location to which we can refer, while an rvalue does not.
)

$(P
For example, it is not possible to take the address of the rvalue expression $(C a&nbsp;+&nbsp;b) in the following program:
)

---
import std.stdio;

void main() {
    int a;
    int b;

    readf(" %s", &a);          $(CODE_NOTE compiles)
    readf(" %s", &(a + b));    $(DERLEME_HATASI)
}
---

$(SHELL
Error: a + b $(HILITE is not an lvalue)
)

$(H6 Rvalues cannot be assigned new values)

$(P
If mutable, an lvalue can be assigned a new value, while an rvalue cannot be:
)

---
    a = 1;          $(CODE_NOTE compiles)
    (a + b) = 2;    $(DERLEME_HATASI)
---

$(SHELL
Error: a + b $(HILITE is not an lvalue)
)

$(H6 Rvalues cannot be passed to functions by reference)

$(P
An lvalue can be passed to a function that takes a parameter by reference, while an rvalue cannot be:
)

---
void incrementByTen($(HILITE ref int) value) {
    value += 10;
}

// ...

    incrementByTen(a);        $(CODE_NOTE compiles)
    incrementByTen(a + b);    $(DERLEME_HATASI)
---

$(SHELL
Error: function deneme.incrementByTen (ref int value)
$(HILITE is not callable) using argument types (int)
)

$(P
The main reason for this limitation is the fact that a function taking a $(C ref) parameter can hold on to that reference for later use, at a time when the rvalue would not be available.
)

$(P
Different from languages like C++, in D an rvalue cannot be passed to a function even if that function does $(I not) modify the argument:
)

---
void print($(HILITE ref const(int)) value) {
    writeln(value);
}

// ...

    print(a);        $(CODE_NOTE compiles)
    print(a + b);    $(DERLEME_HATASI)
---

$(SHELL
Error: function deneme.print (ref const(int) value)
$(HILITE is not callable) using argument types (int)
)

$(H5 $(IX auto ref, parameter) $(IX parameter, auto ref) Using $(C auto ref) parameters to accept both lvalues and rvalues)

$(P
As it was mentioned in the previous chapter, $(C auto ref) parameters of $(LINK2 templates.html, function templates) can take both lvalues and rvalues.
)

$(P
When the argument is an lvalue, $(C auto ref) means $(I by reference). On the other hand, since rvalues cannot be passed to functions by reference, when the argument is an rvalue, it means $(I by copy). For the compiler to generate code differently for these two distinct cases, the function must be a template.
)

$(P
We will see templates in a later chapter. For now, please accept that the highlighted empty parentheses below make the following definition a $(I function template).
)

---
void incrementByTen$(HILITE ())($(HILITE auto ref) int value) {
    /* WARNING: The parameter may be a copy if the argument is
     * an rvalue. This means that the following modification
     * may not be observable by the caller. */

    value += 10;
}

void main() {
    int a;
    int b;

    incrementByTen(a);        $(CODE_NOTE lvalue; passed by reference)
    incrementByTen(a + b);    $(CODE_NOTE rvalue; copied)
}
---

$(P
$(IX isRef) It is possible to determine whether the parameter is an lvalue or an rvalue by using $(C __traits(isRef)) with $(C static if) :
)

---
void incrementByTen()(auto ref int value) {
    $(HILITE static if) (__traits($(HILITE isRef), value)) {
        // 'value' is passed by reference
    } else {
        // 'value' is copied
    }
}
---

$(P
We will see $(C static if) and $(C __traits) later in $(LINK2 cond_comp.html, the Conditional Compilation chapter).
)

$(H5 Terminology)

$(P
The names "lvalue" and "rvalue" do not represent the characteristics of these two kinds of values accurately. The initial letters $(I l) and $(I r) come from $(I left) and $(I right), referring to the left- and the right-hand side expressions of the assignment operator:
)

$(UL

$(LI Assuming that it is mutable, an lvalue can be the left-hand expression of an assignment operation.)

$(LI An rvalue cannot be the left-hand expression of an assignment operation.)

)

$(P
The terms "left value" and "right value" are confusing because in general both lvalues and rvalues can be on either side of an assignment operation:
)

---
    // rvalue 'a + b' on the left, lvalue 'a' on the right:
    array[a + b] = a;
---

Macros:
        TITLE=Lvalues and Rvalues

        DESCRIPTION=Left-values and right-values and their differences.

        KEYWORDS=d programming language tutorial book lvalue rvalue
