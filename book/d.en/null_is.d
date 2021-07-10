Ddoc

$(DERS_BOLUMU $(IX null) $(IX is, operator) $(IX !is) The $(CH4 null) Value and the $(CH4 is) Operator)

$(P
We saw in earlier chapters that a variable of a reference type needs not reference a particular object:
)

---
    MyClass referencesAnObject = new MyClass;

    MyClass variable;   // does not reference an object
---

$(P
Being a reference type, $(C variable) above does have an identity but it does not reference any object yet. Such an object can be imagined to have a place in memory as in the following picture:
)

$(MONO
      variable
   ───┬──────┬───
      │ null │
   ───┴──────┴───
)

$(P
A reference that does not reference any value is $(C null). We will expand on this below.
)

$(P
Such a variable is in an almost useless state. Since there is no $(C MyClass) object that it references, it cannot be used in a context where an actual $(C MyClass) object is needed:
)

---
import std.stdio;

class MyClass {
    int member;
}

void use(MyClass variable) {
    writeln(variable.member);    $(CODE_NOTE_WRONG BUG)
}

void main() {
    MyClass variable;
    use(variable);
}
---

$(P
As there is no object that is referenced by the parameter that $(C use()) receives, attempting to access a member of a non-existing object results in a program crash:
)

$(SHELL
$ ./deneme
$(SHELL_OBSERVED Segmentation fault)
)

$(P
$(IX segmentation fault) "Segmentation fault" is an indication that the program has been terminated by the operating system because of attempting to access an illegal memory address.
)

$(H5 The $(C null) value)

$(P
The special value $(C null) can be printed just like any other value.
)

---
    writeln(null);
---

$(P
The output:
)

$(SHELL
null
)

$(P
A $(C null) variable can be used only in two contexts:
)

$(OL
$(LI Assigning an object to it

---
    variable = new MyClass;  // now references an object
---

$(P
The assignment above makes $(C variable) provide access to the newly constructed object. From that point on, $(C variable) can be used for any valid operation of the $(C MyClass) type.
)

)

$(LI Determining whether it is $(C null)

$(P
However, because the $(C ==) operator needs actual objects to compare, the expression below cannot be compiled:
)

---
    if (variable == null)     $(DERLEME_HATASI)
---

$(P
For that reason, whether a variable is $(C null) must be determined by the $(C is) operator.
)

)

)

$(H5 The $(C is) operator)

$(P
This operator answers the question "does have the null value?":
)

---
    if (variable $(HILITE is) null) {
        // Does not reference any object
    }
---

$(P
$(C is) can be used with other types of variables as well. In the following use, it compares the $(C values) of two integers:
)

---
    if (speed is newSpeed) {
        // Their values are equal

    } else {
        // Their values are different
    }
---

$(P
When used with slices, it determines whether the two slices reference the same set of elements:
)

---
    if (slice is slice2) {
        // They provide access to the same elements
    }
---

$(H5 The $(C !is) operator)

$(P
$(C !is) is the opposite of $(C is). It produces $(C true) when the values are different:
)

---
    if (speed !is newSpeed) {
        // Their values are different
    }
---

$(H5 Assigning the $(C null) value)

$(P
Assigning the $(C null) value to a variable of a reference type makes that variable stop referencing its current object.
)

$(P
If that assignment happens to be terminating the very last reference to the actual object, then the actual object becomes a candidate for finalization by the garbage collector. After all, not being referenced by any variable means that the object is not being used in the program at all.
)

$(P
Let's look at the example from $(LINK2 value_vs_reference.html, an earlier chapter) where two variables were referencing the same object:
)

---
    auto variable = new MyClass;
    auto variable2 = variable;
---

$(P
The following is a representation of the state of the memory after executing that code:
)

$(MONO
  (anonymous MyClass object)    variable    variable2
 ───┬───────────────────┬───  ───┬───┬───  ───┬───┬───
    │        ...        │        │ o │        │ o │
 ───┴───────────────────┴───  ───┴─│─┴───  ───┴─│─┴───
              ▲                    │            │
              │                    │            │
              └────────────────────┴────────────┘
)

$(P
Assigning the $(C null) value to one of these variables breaks its relationship with the object:
)

---
    variable = null;
---

$(P
At this point there is only $(C variable2) that references the $(C MyClass) object:
)

$(MONO
  (anonymous MyClass object)    variable    variable2
 ───┬───────────────────┬───  ───┬────┬───  ───┬───┬───
    │        ...        │        │null│        │ o │
 ───┴───────────────────┴───  ───┴────┴───  ───┴─│─┴───
              ▲                                  │
              │                                  │
              └──────────────────────────────────┘
)

$(P
Assigning $(C null) to the last reference would make the $(C MyClass) object unreachable:
)

---
    variable2 = null;
---

$(P
Such unreachable objects are finalized by the garbage collector at some time in the future. From the point of view of the program, the object does not exist:
)

$(MONO
                                variable      variable2
 ───┬───────────────────┬───  ───┬────┬───  ───┬────┬───
    │                   │        │null│        │null│
 ───┴───────────────────┴───  ───┴────┴───  ───┴────┴──
)

$(P
We had discussed ways of emptying an associative array in the exercises section of the $(LINK2 aa.html, Associative Arrays chapter). We now know a fourth method: Assigning $(C null) to an associative array variable will break the relationship of that variable with the elements:
)

---
    string[int] names;
    // ...
    names = null;     // Not providing access to any element
---

$(P
Similar to the $(C MyClass) examples, if $(C names) has been the last reference to the elements of the associative array, those elements would be finalized by the garbage collector.
)

$(P
Slices can be assigned $(C null) as well:
)

---
    int[] slice = otherSlice[ 10 .. 20 ];
    // ...
    slice = null;     // Not providing access to any element
---

$(H5 Summary)

$(UL

$(LI $(C null) is the value indicating that a variable does not provide access to any value)

$(LI References that have the $(C null) value can only be used in two operations: assigning a value to them and determining whether they are $(C null) or not)

$(LI Since the $(C ==) operator may have to access an actual object, determining whether a variable is $(C null) must be performed by the $(C is) operator)

$(LI $(C !is) is the opposite of $(C is))

$(LI Assigning $(C null) to a variable makes that variable provide access to nothing)

$(LI Objects that are not referenced by any variable are finalized by the garbage collector)

)

Macros:
        TITLE=The null Value and the is Operator

        DESCRIPTION=The 'null' value of the D programming language and the operators 'is' and '!is' that determine whether variables are null or not.

        KEYWORDS=d programming language tutorial book object referencee null is !is
