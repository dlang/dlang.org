Ddoc

$(DERS_BOLUMU $(IX value type) $(IX reference type) Value Types and Reference Types)

$(P
This chapter introduces the concepts of value types and reference types. These concepts are particularly important to understand the differences between structs and classes.
)

$(P
This chapter also gets into more detail with the $(C &) operator.
)

$(P
The chapter ends with a table that contains the outcomes of the following two concepts for different types of variables:
)

$(UL
$(LI Value comparison)
$(LI Address comparison)
)

$(H5 Value types)

$(P
Value types are easy to describe: Variables of value types carry values. For example, all of the integer and floating point types are values types. Although not immediately obvious, fixed-length arrays are value types as well.
)

$(P
For example, a variable of type $(C int) has an integer value:
)

---
    int speed = 123;
---

$(P
The number of bytes that the variable $(C speed) occupies is the size of an $(C int). If we visualize the memory as a ribbon going from left to right, we can imagine the variable living on some part of it:
)

$(MONO
       speed
   ───┬─────┬───
      │ 123 │
   ───┴─────┴───
)

$(P
When variables of value types are copied, they get their own values:
)

---
    int newSpeed = speed;
---

$(P
The new variable would have a place and a value of its own:
)

$(MONO
       speed          newSpeed
   ───┬─────┬───   ───┬─────┬───
      │ 123 │         │ 123 │
   ───┴─────┴───   ───┴─────┴───
)

$(P
Naturally, modifications that are made to these variables are independent:
)

---
    speed = 200;
---

$(P
The value of the other variable does not change:
)

$(MONO
       speed          newSpeed
   ───┬─────┬───   ───┬─────┬───
      │ 200 │         │ 123 │
   ───┴─────┴───   ───┴─────┴───
)

$(H6 The use of $(C assert) checks below)

$(P
The following examples contain $(C assert) checks to indicate that their conditions are true. In other words, they are not checks in the normal sense, rather my way of telling to the reader that "this is true".
)

$(P
For example, the check $(C assert(speed == newSpeed)) below means "speed is equal to newSpeed".
)

$(H6 Value identity)

$(P
As the memory representations above indicate, there are two types of equality that concern variables:
)

$(UL

$(LI $(B Value equality): The $(C ==) operator that appears in many examples throughout the book compares variables by their values. When two variables are said to be $(I equal) in that sense, their values are equal.
)
$(LI $(B Value identity): In the sense of owning separate values, $(C speed) and $(C newSpeed) have separate identities. Even when their values are equal, they are different variables.
)

)

---
    int speed = 123;
    int newSpeed = speed;
    assert(speed == newSpeed);
    speed = 200;
    assert(speed != newSpeed);
---

$(H6 Address-of operator, $(C &))

$(P
We have been using the $(C &) operator so far with $(C readf()). The $(C &) operator tells $(C readf()) where to put the input data.
)

$(P $(I $(B Note:) As we have seen in $(LINK2 input.html, the Reading from the Standard Input chapter), $(C readf()) can be used without explicit pointers as well.
))

$(P
The addresses of variables can be used for other purposes as well. The following code simply prints the addresses of two variables:
)

---
    int speed = 123;
    int newSpeed = speed;

    writeln("speed   : ", speed,    " address: ", $(HILITE &)speed);
    writeln("newSpeed: ", newSpeed, " address: ", $(HILITE &)newSpeed);
---

$(P
$(C speed) and $(C newSpeed) have the same value but their addresses are different:
)

$(SHELL
speed   : 123 address: 7FFF4B39C738
newSpeed: 123 address: 7FFF4B39C73C
)

$(P $(I $(B Note:) It is normal for the addresses to have different values every time the program is run. Variables live at parts of memory that happen to be available during that particular execution of the program.)
)

$(P
Addresses are normally printed in hexadecimal format.
)

$(P
Additionally, the fact that the two addresses are 4 apart indicates that those two integers are placed next to each other in memory. (Note that the value of hexadecimal C is 12, so the difference between 8 and 12 is 4.)
)

$(H5 $(IX variable, reference) Reference variables)

$(P
Before getting to reference types let's first define reference variables.
)

$(P
$(B Terminology:) We have been using the phrase $(I to provide access to) so far in several contexts throughout the book. For example, slices and associative arrays do not own any elements but provide access to elements that are owned by the D runtime. Another phrase that is identical in meaning is $(I being a reference of) as in "slices are references of zero or more elements", which is sometimes used even shorter as $(I to reference) as in "this slice references two elements". Finally, the act of accessing a value through a reference is called $(I dereferencing).
)

$(P
Reference variables are variables that act like aliases of other variables. Although they look and are used like variables, they do not have values themselves. Modifications made on a reference variable change the value of the actual variable.
)

$(P
We have already used reference variables so far in two contexts:
)

$(UL

$(LI $(B $(C ref) in $(C foreach) loops): The $(C ref) keyword makes the loop variable the $(I actual) element that corresponds to that iteration. When the $(C ref) keyword is not used, the loop variable is a $(I copy) of the actual element.

$(P
This can be demonstrated by the $(C &) operator as well. If their addresses are the same, two variables would be referencing the same value (or the $(I same element) in this case):
)

---
    int[] slice = [ 0, 1, 2, 3, 4 ];

    foreach (i, $(HILITE ref) element; slice) {
        assert(&element == &slice[i]);
    }
---

$(P
Although they are separate variables, the fact that the addresses of $(C element) and $(C slice[i]) are the same proves that they have the same value identity.
)

$(P
In other words, $(C element) and $(C slice[i]) are references of the same value. Modifying either of those affects the actual value. The following memory layout indicates a snapshot of the iteration when $(C i) is 3:
)

$(MONO
   slice[0] slice[1] slice[2] slice[3] slice[4]
       ⇢        ⇢        ⇢   (element)
──┬────────┬────────┬────────┬────────┬─────────┬──
  │    0   │    1   │    2   │    3   │    4    │
──┴────────┴────────┴────────┴────────┴─────────┴──
)

)

$(LI $(B $(C ref) and $(C out) function parameters): Function parameters that are specified as $(C ref) or $(C out) are aliases of the actual variable the function is called with.

$(P
The following example demonstrates this case by passing the same variable to separate $(C ref) and $(C out) parameters of a function. Again, the $(C &) operator indicates that both parameters have the same value identity:
)

---
import std.stdio;

void main() {
    int originalVariable;
    writeln("address of originalVariable: ", &originalVariable);
    foo(originalVariable, originalVariable);
}

void foo($(HILITE ref) int refParameter, $(HILITE out) int outParameter) {
    writeln("address of refParameter    : ", &refParameter);
    writeln("address of outParameter    : ", &outParameter);
    assert($(HILITE &)refParameter == $(HILITE &)outParameter);
}
---

$(P
Although they are defined as separate parameters, $(C refParameter) and $(C outParameter) are aliases of $(C originalVariable):
)

$(SHELL
address of originalVariable: 7FFF24172958
address of refParameter    : 7FFF24172958
address of outParameter    : 7FFF24172958
)

)

)

$(H5 $(IX type, reference) Reference types)

$(P
Variables of reference types have individual identities but they do not have individual values. They $(I provide access to) existing variables.
)

$(P
We have already seen this concept with slices. Slices do not own elements, they provide access to existing elements:
)

---
void main() {
    // Although it is named as 'array' here, this variable is
    // a slice as well. It provides access to all of the
    // initial elements:
    int[] array = [ 0, 1, 2, 3, 4 ];

    // A slice that provides access to elements other than the
    // first and the last:
    int[] slice = array[1 .. $ - 1];

    // At this point slice[0] and array[1] provide access to
    // the same value:
    assert($(HILITE &)slice[0] == $(HILITE &)array[1]);

    // Changing slice[0] changes array[1]:
    slice[0] = 42;
    assert(array[1] == 42);
}
---

$(P
Contrary to reference variables, reference types are not simply aliases. To see this distinction, let's define another slice as a copy of one of the existing slices:
)

---
    int[] slice2 = slice;
---

$(P
The two slices have their own adresses. In other words, they have separate identities:
)

---
    assert(&slice != &slice2);
---

$(P
The following list is a summary of the differences between reference variables and reference types:
)

$(UL

$(LI Reference variables do not have identities, they are aliases of existing variables.)

$(LI Variables of reference types have identities but they do not own values; rather, they provide access to existing values.)

)

$(P
The way $(C slice) and $(C slice2) live in memory can be illustrated as in the following figure:
)

$(MONO
                                 slice        slice2
 ───┬───┬───┬───┬───┬───┬───  ───┬───┬───  ───┬───┬───
    │ 0 │$(HILITE &nbsp;1&nbsp;)│$(HILITE &nbsp;2&nbsp;)│$(HILITE &nbsp;3&nbsp;)│ 4 │        │ o │        │ o │
 ───┴───┴───┴───┴───┴───┴───  ───┴─│─┴───  ───┴─│─┴───
              ▲                    │            │
              │                    │            │
              └────────────────────┴────────────┘
)

$(P
The three elements that the two slices both reference are highlighted.
)

$(P
One of the differences between C++ and D is that classes are reference types in D. Although we will cover classes in later chapters in detail, the following is a short example to demonstrate this fact:
)

---
class MyClass {
    int member;
}
---

$(P
Class objects are constructed by the $(C new) keyword:
)

---
    auto variable = new MyClass;
---

$(P
$(C variable) is a reference to an anonymous $(C MyClass) object that has been constructed by $(C new):
)

$(MONO
  (anonymous MyClass object)    variable
 ───┬───────────────────┬───  ───┬───┬───
    │        ...        │        │ o │
 ───┴───────────────────┴───  ───┴─│─┴───
              ▲                    │
              │                    │
              └────────────────────┘
)

$(P
Just like with slices, when $(C variable) is copied, the copy becomes another reference to the same object. The copy has its own address:
)

---
    auto variable = new MyClass;
    auto variable2 = variable;
    assert(variable == variable2);
    assert(&variable != &variable2);
---

$(P
They are equal from the point of view of referencing the same object, but they are separate variables:
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
This can also be shown by modifying the member of the object:
)

---
    auto variable = new MyClass;
    variable.member = 1;

    auto variable2 = variable;   // They share the same object
    variable2.member = 2;

    assert(variable.member == 2); // The object that variable
                                  // provides access to has
                                  // changed.
---

$(P
Another reference type is associative arrays. Like slices and classes, when an associative array is copied or assigned to another variable, both give access to the same set of elements:
)

---
    string[int] byName =
    [
        1   : "one",
        10  : "ten",
        100 : "hundred",
    ];

    // The two associative arrays will be sharing the same
    // set of elements
    string[int] byName2 = byName;

    // The mapping added through the second ...
    byName2[4] = "four";

    // ... is visible through the first.
    assert(byName[4] == "four");
---

$(P
As it will be explained in the next chapter, there is no element sharing if the original associative array were $(C null) to begin with.
)

$(H6 The difference in the assignment operation)

$(P
With value types and reference variables, the assignment operation changes $(I the actual value):
)

---
void main() {
    int number = 8;

    halve(number);      // The actual value changes
    assert(number == 4);
}

void halve($(HILITE ref) int dividend) {
    dividend /= 2;
}
---

$(P
On the other hand, with reference types, the assignment operation changes $(I which value is being accessed). For example, the assignment of the $(C slice3) variable below does not change the value of any element; rather, it changes what elements $(C slice3) is now a reference of:
)

---
    int[] slice1 = [ 10, 11, 12, 13, 14 ];
    int[] slice2 = [ 20, 21, 22 ];

    int[] slice3 = slice1[1 .. 3]; // Access to element 1 and
                                   // element 2 of slice1

    slice3[0] = 777;
    assert(slice1 == [ 10, 777, 12, 13, 14 ]);

    // This assignment does not modify the elements that
    // slice3 is providing access to. It makes slice3 provide
    // access to other elements.
    $(HILITE slice3 =) slice2[$ - 1 .. $]; // Access to the last element

    slice3[0] = 888;
    assert(slice2 == [ 20, 21, 888 ]);
---

$(P
Let's demonstrate the same effect this time with two objects of the $(C MyClass) type:
)

---
    auto variable1 = new MyClass;
    variable1.member = 1;

    auto variable2 = new MyClass;
    variable2.member = 2;

    auto $(HILITE aCopy = variable1);
    aCopy.member = 3;

    $(HILITE aCopy = variable2);
    aCopy.member = 4;

    assert(variable1.member == 3);
    assert(variable2.member == 4);
---

$(P
The $(C aCopy) variable above first references the same object as $(C variable1), and then the same object as $(C variable2). As a consequence, the $(C .member) that is modified through $(C aCopy) is first $(C variable1)'s and then $(C variable2)'s.
)

$(H6 Variables of reference types may not be referencing any object)

$(P
With a reference variable, there is always an actual variable that it is an alias of; it can not start its life without a variable. On the other hand, variables of reference types can start their lives without referencing any object.
)

$(P
For example, a $(C MyClass) variable can be defined without an actual object having been created by $(C new):
)

---
    MyClass variable;
---

$(P
Such variables have the special value of $(C null). We will cover $(C null) and the $(C is) keyword in $(LINK2 null_is.html, a later chapter).
)

$(H5 Fixed-length arrays are value types, slices are reference types)

$(P
D's arrays and slices diverge when it comes to value type versus reference type.
)

$(P
As we have already seen above, slices are reference types. On the other hand, fixed-length arrays are value types. They own their elements and behave as individual values:
)

---
    int[3] array1 = [ 10, 20, 30 ];

    auto array2 = array1; // array2's elements are different
                          // from array1's
    array2[0] = 11;

    // First array is not affected:
    assert(array1[0] == 10);
---

$(P
$(C array1) is a fixed-length array because its length is specified when it has been defined. Since $(C auto) makes the compiler infer the type of $(C array2), it is a fixed-length array as well. The values of $(C array2)'s elements are copied from the values of the elements of $(C array1). Each array has its own elements. Modifying an element through one does not affect the other.
)


$(H5 Experiment)

$(P
The following program is an experiment of applying the $(C ==) operator to different types. It applies the operator to both variables of a certain type and to the addresses of those variables. The program produces the following output:
)

$(MONO
                     Type of variable                      a == b  &amp;a == &amp;b
===========================================================================
               variables with equal values (value type)     true    false
           variables with different values (value type)    false    false
                            foreach with 'ref' variable     true     true
                         foreach without 'ref' variable     true    false
                          function with 'out' parameter     true     true
                          function with 'ref' parameter     true     true
                           function with 'in' parameter     true    false
               slices providing access to same elements     true    false
          slices providing access to different elements    false    false
      MyClass variables to same object (reference type)     true    false
MyClass variables to different objects (reference type)    false    false
)

$(P
The table above has been generated by the following program:
)

---
import std.stdio;
import std.array;

int moduleVariable = 9;

class MyClass {
    int member;
}

void printHeader() {
    immutable dchar[] header =
        "                     Type of variable" ~
        "                      a == b  &a == &b";

    writeln();
    writeln(header);
    writeln(replicate("=", header.length));
}

void printInfo(const dchar[] label,
               bool valueEquality,
               bool addressEquality) {
    writefln("%55s%9s%9s",
             label, valueEquality, addressEquality);
}

void main() {
    printHeader();

    int number1 = 12;
    int number2 = 12;
    printInfo("variables with equal values (value type)",
              number1 == number2,
              &number1 == &number2);

    int number3 = 3;
    printInfo("variables with different values (value type)",
              number1 == number3,
              &number1 == &number3);

    int[] slice = [ 4 ];
    foreach (i, ref element; slice) {
        printInfo("foreach with 'ref' variable",
                  element == slice[i],
                  &element == &slice[i]);
    }

    foreach (i, element; slice) {
        printInfo("foreach without 'ref' variable",
                  element == slice[i],
                  &element == &slice[i]);
    }

    outParameter(moduleVariable);
    refParameter(moduleVariable);
    inParameter(moduleVariable);

    int[] longSlice = [ 5, 6, 7 ];
    int[] slice1 = longSlice;
    int[] slice2 = slice1;
    printInfo("slices providing access to same elements",
              slice1 == slice2,
              &slice1 == &slice2);

    int[] slice3 = slice1[0 .. $ - 1];
    printInfo("slices providing access to different elements",
              slice1 == slice3,
              &slice1 == &slice3);

    auto variable1 = new MyClass;
    auto variable2 = variable1;
    printInfo(
        "MyClass variables to same object (reference type)",
        variable1 == variable2,
        &variable1 == &variable2);

    auto variable3 = new MyClass;
    printInfo(
        "MyClass variables to different objects (reference type)",
        variable1 == variable3,
        &variable1 == &variable3);
}

void outParameter(out int parameter) {
    printInfo("function with 'out' parameter",
              parameter == moduleVariable,
              &parameter == &moduleVariable);
}

void refParameter(ref int parameter) {
    printInfo("function with 'ref' parameter",
              parameter == moduleVariable,
              &parameter == &moduleVariable);
}

void inParameter(in int parameter) {
    printInfo("function with 'in' parameter",
              parameter == moduleVariable,
              &parameter == &moduleVariable);
}
---

$(P
Notes:
)

$(UL

$(LI
$(IX module variable) $(IX variable, module) The program makes use of a module variable when comparing different types of function parameters. Module variables are defined at module level, outside of all of the functions. They are globally accessible to all of the code in the module.
)

$(LI
$(IX replicate, std.array) The $(C replicate()) function of the $(C std.array) module takes an array (the $(STRING "=") string above) and repeats it the specified number of times.
)

)

$(H5 Summary)

$(UL

$(LI Variables of value types have their own values and adresses.)

$(LI Reference variables do not have their own values nor addresses. They are aliases of existing variables.)

$(LI Variables of reference types have their own addresses but the values that they reference do not belong to them.)

$(LI With reference types, assignment does not change value, it changes which value is being accessed.)

$(LI Variables of reference types may be $(C null).)

)

Macros:
        TITLE=Value Types and Reference Types

        DESCRIPTION=A comparison of value types and reference types in the D programming language, and the 'address of' operator.

        KEYWORDS=d programming book tutorial value reference
