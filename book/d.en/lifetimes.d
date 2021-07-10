Ddoc

$(DERS_BOLUMU $(IX lifetime) Lifetimes and Fundamental Operations)

$(P
We will soon cover structs, the basic feature that allows the programmer to define application-specific types. Structs are for combining fundamental types and other structs together to define higher-level types that behave according to special needs of programs. After structs, we will learn about classes, which are the basis of the object oriented programming features of D.
)

$(P
Before getting to structs and classes, it will be better to talk about some important concepts first. These concepts will help understand structs and classes and some of their differences.
)

$(P
We have been calling any piece of data that represented a concept in a program a $(I variable). In a few places we have referred to struct and class variables specifically as $(I objects). I will continue calling both of these concepts variables in this chapter.
)

$(P
Although this chapter includes only fundamental types, slices, and associative arrays; these concepts apply to user-defined types as well.
)

$(H5 $(IX variable, lifetime) Lifetime of a variable)

$(P
The time between when a variable is defined and when it is $(I finalized) is the lifetime of that variable. Although it is the case for many types, $(I becoming unavailable) and $(I being finalized) need not be at the same time.
)

$(P
You would remember from the $(LINK2 name_space.html, Name Scope chapter) how variables become unavailable. In simple cases, exiting the scope where a variable was defined would render that variable unavailable.
)

$(P
Let's consider the following example as a reminder:
)

---
void speedTest() {
    int speed;               // Single variable ...

    foreach (i; 0 .. 10) {
        speed = 100 + i;     // ... takes 10 different values.
        // ...
    }
} // ← 'speed' is unavailable beyond this point.
---

$(P
The lifetime of the $(C speed) variable in that code ends upon exiting the $(C speedTest()) function. There is a single variable in the code above, which takes ten different values from 100 to 109.
)

$(P
When it comes to variable lifetimes, the following code is very different compared to the previous one:
)

---
void speedTest() {
    foreach (i; 0 .. 10) {
        int speed = 100 + i; // Ten separate variables.
        // ...
    } // ← Lifetime of each variable ends here.
}
---

$(P
There are ten separate variables in that code, each taking a single value. Upon every iteration of the loop, a new variable starts its life, which eventually ends at the end of each iteration.
)

$(H5 $(IX parameter, lifetime) Lifetime of a parameter)

$(P
The lifetime of a parameter depends on its qualifiers:
)

$(P
$(IX ref, parameter lifetime) $(C ref): The parameter is just an alias of the actual variable that is specified when calling the function. $(C ref) parameters do not affect the lifetimes of actual variables.
)

$(P
$(IX in, parameter lifetime) $(C in): For $(I value types), the lifetime of the parameter starts upon entering the function and ends upon exiting it. For $(I reference types), the lifetime of the parameter is the same as with $(C ref).
)

$(P
$(IX out, parameter lifetime) $(C out): Same with $(C ref), the parameter is just an alias of the actual variable that is specified when calling the function. The only difference is that the variable is set to its $(C .init) value automatically upon entering the function.
)

$(P
$(IX lazy, parameter lifetime) $(C lazy): The life of the parameter starts when the parameter is actually used and ends right then.
)

$(P
The following example uses these four types of parameters and explains their lifetimes in program comments:
)

---
void main() {
    int main_in;      /* The value of main_in is copied to the
                       * parameter. */

    int main_ref;     /* main_ref is passed to the function as
                       * itself. */

    int main_out;     /* main_out is passed to the function as
                       * itself. Its value is set to int.init
                       * upon entering the function. */

    foo(main_in, main_ref, main_out, aCalculation());
}

void foo(
    in int p_in,       /* The lifetime of p_in starts upon
                        * entering the function and ends upon
                        * exiting the function. */

    ref int p_ref,     /* p_ref is an alias of main_ref. */

    out int p_out,     /* p_out is an alias of main_out. Its
                        * value is set to int.init upon
                        * entering the function. */

    lazy int p_lazy) { /* The lifetime of p_lazy starts when
                        * it is used and ends when its use
                        * ends. Its value is calculated by
                        * calling aCalculation() every time
                        * p_lazy is used in the function. */
    // ...
}

int aCalculation() {
    int result;
    // ...
    return result;
}
---

$(H5 Fundamental operations)

$(P
Regardless of its type, there are three fundamental operations throughout the lifetime of a variable:
)

$(UL
$(LI $(B Initialization): The start of its life.)
$(LI $(B Finalization): The end of its life.)
$(LI $(B Assignment): Changing its value as a whole.)
)

$(P
To be considered an object, it must first be initialized. There may be final operations for some types. The value of a variable may change during its lifetime.
)

$(H6 $(IX initialization) Initialization)

$(P
Every variable must be initialized before being used. Initialization involves two steps:
)

$(OL

$(LI $(B Reserving space for the variable): This space is where the value of the variable is stored in memory.)

$(LI $(B Construction): Setting the first value of the variable on that space (or the first values of the members of structs and classes).)

)

$(P
Every variable lives in a place in memory that is reserved for it. Some of the code that the compiler generates is about reserving space for each variable.
)

$(P
Let's consider the following variable:
)

---
    int speed = 123;
---

$(P
As we have seen in $(LINK2 value_vs_reference.html, the Value Types and Reference Types chapter), we can imagine this variable living on some part of the memory:
)

$(MONO
   ──┬─────┬─────┬─────┬──
     │     │ 123 │     │
   ──┴─────┴─────┴─────┴──
)

$(P
The memory location that a variable is placed at is called its address. In a sense, the variable lives at that address. When the value of a variable is changed, the new value is stored at the same place:
)

---
    ++speed;
---

$(P
The new value would be at the same place where the old value has been:
)

$(MONO
   ──┬─────┬─────┬─────┬──
     │     │ 124 │     │
   ──┴─────┴─────┴─────┴──
)

$(P
Construction is necessary to prepare variables for use. Since a variable cannot be used reliably before being constructed, it is performed by the compiler automatically.
)

$(P
Variables can be constructed in three ways:
)

$(UL
$(LI $(B By their default value): when the programmer does not specify a value explicitly)
$(LI $(B By copying): when the variable is constructed as a copy of another variable of the same type)
$(LI $(B By a specific value): when the programmer specifies a value explicitly)
)

$(P
When a value is not specified, the value of the variable would be the $(I default) value of its type, i.e. its $(C .init) value.
)

---
    int speed;
---

$(P
The value of $(C speed) above is $(C int.init), which happens to be zero. Naturally, a variable that is constructed by its default value may have other values during its lifetime (unless it is $(C immutable)).
)

---
    File file;
---

$(P
With the definition above, the variable $(C file) is a $(C File) object that is not yet associated with an actual file on the file system. It is not usable until it is modified to be associated with a file.
)

$(P
Variables are sometimes constructed as a copy of another variable:
)

---
    int speed = otherSpeed;
---

$(P
$(C speed) above is constructed by the value of $(C otherSpeed).
)

$(P
As we will see in later chapters, this operation has a different meaning for class variables:
)

---
    auto classVariable = otherClassVariable;
---

$(P
Although $(C classVariable) starts its life as a copy of $(C otherClassVariable), there is a fundamental difference with classes: Although $(C speed) and $(C otherSpeed) are distinct values, $(C classVariable) and $(C otherClassVariable) both provide access to the same value. This is the fundamental difference between value types and reference types.
)

$(P
Finally, variables can be constructed by the value of an expression of a compatible type:
)

---
   int speed = someCalculation();
---

$(P
$(C speed) above would be constructed by the return value of $(C someCalculation()).
)

$(H6 $(IX finalization) $(IX destruction) Finalization)

$(P
Finalizing is the final operations that are executed for a variable and reclaiming its memory:
)

$(OL
$(LI $(B Destruction): The final operations that must be executed for the variable.)
$(LI $(B Reclaiming the variable's memory): Reclaiming the piece of memory that the variable has been living on.)
)

$(P
For simple fundamental types, there are no final operations to execute. For example, the value of a variable of type $(C int) is not set back to zero. For such variables there is only reclaiming their memory, so that it will be used for other variables later.
)

$(P
On the other hand, some types of variables require special operations during finalization. For example, a $(C File) object would need to write the characters that are still in its output buffer to disk and notify the file system that it no longer uses the file. These operations are the destruction of a $(C File) object.
)

$(P
Final operations of arrays are at a little higher-level: Before finalizing the array, first its elements are destructed. If the elements are of a simple fundamental type like $(C int), then there are no special final operations for them. If the elements are of a struct or a class type that needs finalization, then those operations are executed for each element.
)

$(P
Associative arrays are similar to arrays. Additionally, the keys may also be finalized if they are of a type that needs destruction.
)

$(P $(B The garbage collector:) D is a $(I garbage-collected) language. In such languages finalizing an object need not be initiated explicitly by the programmer. When a variable's lifetime ends, its finalization is automatically handled by the garbage collector. We will cover the garbage collector and special memory management in $(LINK2 memory.html, a later chapter).
)

$(P
Variables can be finalized in two ways:
)

$(UL
$(LI $(B When the lifetime ends): Finalization happens at the end of the variable's life.)
$(LI $(B Some time in the future): Finalization happens at an indeterminate time in the future by the garbage collector.)
)

$(P
Which of the two ways a variable will be finalized depends primarily on its type. Some types like arrays, associative arrays and classes are normally destructed by the garbage collector some time in the future.
)

$(H6 $(IX assignment) Assignment)

$(P
The other fundamental operation that a variable experiences during its lifetime is assignment.
)

$(P
For simple fundamental types assignment is merely changing the value of the variable. As we have seen above on the memory representation, an $(C int) variable would start having the value 124 instead of 123. However, more generally, assignment consists of two steps, which are not necessarily executed in the following order:
)

$(UL
$(LI $(B Destructing the old value))
$(LI $(B Constructing the new value))
)

$(P
These two steps are not important for simple fundamental types that don't need destruction. For types that need destruction, it is important to remember that assignment is a combination of the two steps above.
)

Macros:
        TITLE=Lifetimes and Fundamental Operations

        DESCRIPTION=Introducing the concepts of initialization, finalization, construction, destruction, and assignment and defining the lifetimes of variables.

        KEYWORDS=d programming lesson book tutorial constructor destructor
