Ddoc

$(DERS_BOLUMU $(IX pointer) Pointers)

$(P
Pointers are variables that provide access to other variables. The value of a pointer is the address of the variable that it provides access to.
)

$(P
Pointers can point at any type of variable, object, and even other pointers. In this chapter, I will refer to all of these simply as $(I variables).
)

$(P
Pointers are low level features of microprocessors. They are an important part of system programming.
)

$(P
The syntax and semantics of pointers in D are inherited directly from C. Although pointers are notoriously the most difficult feature of C to comprehend, they should not be as difficult in D. This is because other features of D that are semantically close to pointers are more useful in situations where pointers would have to be used in other languages. When the ideas behind pointers are already understood from those other features of D, pointers should be easier to grasp.
)

$(P
The short examples throughout the most of this chapter are decidedly simple. The programs at the end of the chapter will be more realistic.
)

$(P
The names like $(C ptr) (short for "pointer") that I have used in these examples should not be considered as useful names in general. As always, names must be chosen to be more meaningful and explanatory in actual programs.
)

$(H5 $(IX reference, concept) The concept of a reference)

$(P
Although we have encountered references many times in the previous chapters, let's summarize this concept one more time.
)

$(H6 The $(C ref) variables in $(C foreach) loops)

$(P
As we have seen in $(LINK2 foreach.html, the $(C foreach) Loop chapter), normally the loop variables are $(I copies) of elements:
)

---
import std.stdio;

void main() {
    int[] numbers = [ 1, 11, 111 ];

    foreach (number; numbers) {
        number = 0;     // ← the copy changes, not the element
    }

    writeln("After the loop: ", numbers);
}
---

$(P
The $(C number) that gets assigned 0 each time is a copy of one of the elements of the array. Modifying that copy does not modify the element:
)

$(SHELL
After the loop: [1, 11, 111]
)

$(P
When the actual elements need to be modified, the $(C foreach) variable must be defined as $(C ref):
)

---
    foreach ($(HILITE ref) number; numbers) {
        number = 0;     // ← the actual element changes
    }
---

$(P
This time $(C number) is a reference to an actual element in the array:
)

$(SHELL_SMALL
After the loop: [0, 0, 0]
)

$(H6 $(C ref) function parameters)

$(P
As we have seen in $(LINK2 function_parameters.html, the Function Parameters chapter), the parameters of $(I value types) are normally copies of the arguments:
)

---
import std.stdio;

void addHalf(double value) {
    value += 0.5;        // ← Does not affect 'value' in main
}

void main() {
    double value = 1.5;

    addHalf(value);

    writeln("The value after calling the function: ", value);
}
---

$(P
Because the function parameter is not defined as $(C ref), the assignment inside the function affects only the local variable there. The variable in $(C main()) is not affected:
)

$(SHELL_SMALL
The value after calling the function: 1.5
)

$(P
The $(C ref) keyword would make the function parameter a reference to the argument:
)

---
void addHalf($(HILITE ref) double value) {
    value += 0.5;
}
---

$(P
This time the variable in $(C main()) gets modified:
)

$(SHELL_SMALL
The value after calling the function: 2
)

$(H6 Reference types)

$(P
Some types are reference types. Variables of such types provide access to separate variables:
)

$(UL
$(LI Class variables)
$(LI Slices)
$(LI Associative arrays)
)

$(P
We have seen this distinction in $(LINK2 value_vs_reference.html, the Value Types and Reference Types chapter). The following example demonstrates reference types by two $(C class) variables:
)

---
import std.stdio;

class Pen {
    double ink;

    this() {
        ink = 15;
    }

    void use(double amount) {
        ink -= amount;
    }
}

void main() {
    auto pen = new Pen;
    auto otherPen = pen;  // ← Now both variables provide
                          //   access to the same object

    writefln("Before: %s %s", pen.ink, otherPen.ink);

    pen.use(1);          // ← the same object is used
    otherPen.use(2);     // ← the same object is used

    writefln("After : %s %s", pen.ink, otherPen.ink);
}
---

$(P
Because classes are reference types, the class variables $(C pen) and $(C otherPen) provide access to the same $(C Pen) object. As a result, using either of those class variables affects the same object:
)

$(SHELL_SMALL
Before: 15 15
After : 12 12
)

$(P
That single object and the two class variables would be laid out in memory similar to the following figure:
)

$(MONO
      (The Pen object)            pen        otherPen
 ───┬───────────────────┬───  ───┬───┬───  ───┬───┬───
    │        ink        │        │ o │        │ o │
 ───┴───────────────────┴───  ───┴─│─┴───  ───┴─│─┴───
              ▲                    │            │
              │                    │            │
              └────────────────────┴────────────┘
)

$(P
References $(I point at) actual variables as $(C pen) and $(C otherPen) do above.
)

$(P
Programming languages implement the reference and pointer concepts by special registers of the microprocessor, which are specifically for $(I pointing at) memory locations.
)

$(P
Behind the scenes, D's higher-level concepts (class variables, slices, associative arrays, etc.) are all implemented by pointers. As these higher-level features are already efficient and convenient, pointers are rarely needed in D programming. Still, it is important for D programmers to understand pointers well.
)

$(H5 $(IX *, pointer definition) Syntax)

$(P
The pointer syntax of D is mostly the same as in C. Although this can be seen as an advantage, the peculiarities of C's pointer syntax are necessarily inherited by D as well. For example, the different meanings of the $(C *) character may be confusing.
)

$(P
With the exception of $(C void) pointers, every pointer is associated with a certain type and can point at only variables of that specific type. For example, an $(C int) pointer can only point at variables of type $(C int).
)

$(P
The pointer definition syntax consists of the associated type and a $(C *) character:
)

---
    $(I $(D_KEYWORD type_to_point_at)) * $(I name_of_the_pointer_variable);
---

$(P
Accordingly, a pointer variable that would be pointing at $(C int) variables would be defined like this:
)

---
    int * myPointer;
---

$(P
The $(C *) character in that syntax may be pronounced as "pointer". So, the type of $(C myPointer) above is an "int pointer". The spaces before and after the $(C *) character are optional. The following syntaxes are common as well:
)

---
    int* myPointer;
    int *myPointer;
---

$(P
When it is specifically a pointer type that is being mentioned as in "int pointer", it is common to write the type without any spaces as in $(C int*).
)

$(H5 $(IX &, address of) Pointer value and the address-of operator&nbsp;$(C &))

$(P
Being variables themselves pointers have values as well. The default value of a pointer is the special value $(C null), which means that the pointer is not $(I pointing at) any variable yet (i.e. does not provide access to any variable).
)

$(P
To make a pointer provide access to a variable, the value of the pointer must be set to the address of that variable. The pointer starts pointing at the variable that is at that specific address. From now on, I will call that variable $(I the pointee).
)

$(P
The $(C &) operator which we have used many times before with $(C readf) has also been briefly mentioned in $(LINK2 value_vs_reference.html, the Value Types and Reference Types chapter). This operator produces the address of the variable that is written after it. Its value can be used when initializing a pointer:
)

---
    int myVariable = 180;
    int * myPointer = $(HILITE &)myVariable;
---

$(P
Initializing $(C myPointer) by the address of $(C myVariable) makes $(C myPointer) point at $(C myVariable).
)

$(P
The value of the pointer is the same as the address of $(C myVariable):
)

---
    writeln("The address of myVariable: ", &myVariable);
    writeln("The value of myPointer   : ", myPointer);
---

$(SHELL_SMALL
The address of myVariable: 7FFF2CE73F10
The value of myPointer   : 7FFF2CE73F10
)

$(P $(I $(B Note:) The address value is likely to be different every time the program is started.)
)

$(P
The following figure is a representation of these two variables in memory:
)

$(MONO
      myVariable at                myPointer at
  address 7FFF2CE73F10          some other address
───┬────────────────┬───     ───┬────────────────┬───
   │      180       │           │  7FFF2CE73F10  │
───┴────────────────┴───     ───┴────────│───────┴───
           ▲                             │
           │                             │
           └─────────────────────────────┘
)

$(P
The value of $(C myPointer) is the address of $(C myVariable), conceptually $(I pointing at) the variable that is at that location.
)

$(P
Since pointers are variables as well, the $(C &) operator can produce the address of the  pointer as well:
)

---
    writeln("The address of myPointer : ", &myPointer);
---

$(SHELL_SMALL
The address of myPointer : 7FFF2CE73F18
)

$(P
Since the difference between the two addresses above is 8, remembering that an $(C int) takes up 4 bytes, we can deduce that $(C myVariable) and $(C myPointer) are 4 bytes apart in memory.
)

$(P
After removing the arrow that represented the concept of $(I pointing at), we can picture the contents of memory around these addresses like this:
)

$(MONO
    7FFF2CE73F10     7FFF2CE73F14     7FFF2CE73F18
    :                :                :                :
 ───┬────────────────┬────────────────┬────────────────┬───
    │      180       │    (unused)    │  7FFF2CE73F10  │
 ───┴────────────────┴────────────────┴────────────────┴───
)

$(P
The names of variables, functions, classes, etc. and keywords are not parts of programs of compiled languages like D. The variables that have been defined by the programmer in the source code are converted to bytes that occupy memory or registers of the microprocessor.
)

$(P
$(I $(B Note:) The names (a.k.a. symbols) may actually be included in programs to help with debugging but those names do not affect the operation of the program.)
)

$(H5 $(IX *, pointee access) The access operator&nbsp;$(C *))

$(P
We have seen above that the $(C *) character which normally represents multiplication is also used when defining pointers. A difficulty with the syntax of pointers is that the same character has a third meaning: It is also used when accessing the pointee through the pointer.
)

$(P
When it is written before the name of a pointer, it means $(I the variable that the pointer is pointing at) (i.e. the pointee):
)

---
    writeln("The value that it is pointing at: ", $(HILITE *)myPointer);
---

$(SHELL_SMALL
The value that it is pointing at: 180
)

$(H5 $(IX ., pointer) The $(C .) (dot) operator to access a member of the pointee)

$(P
If you know pointers from C, this operator is the same as the $(C ->) operator in that language.
)

$(P
We have seen above that the $(C *) operator is used for accessing the pointee. That is sufficiently useful for pointers of fundamental types like $(C int*): The value of a fundamental type is accessed simply by writing $(C *myPointer).
)

$(P
However, when the pointee is a struct or a class object, the same syntax becomes inconvenient. To see why, let's consider the following struct:
)

---
struct Coordinate {
    int x;
    int y;

    string toString() const {
        return format("(%s,%s)", x, y);
    }
}
---

$(P
The following code defines an object and a pointer of that type:
)

---
    auto center = Coordinate(0, 0);
    Coordinate * ptr = $(HILITE &)center;    // pointer definition
    writeln($(HILITE *)ptr);                 // object access
---

$(P
That syntax is convenient when accessing the value of the entire $(C Coordinate) object:
)

$(SHELL_SMALL
(0,0)
)

$(P
However, the code becomes complicated when accessing a member of an object through a pointer and the $(C *) operator:
)

---
    // Adjust the x coordinate
    (*ptr).x += 10;
---

$(P
That expression modifies the value of the $(C x) member of the $(C center) object. The left-hand side of that expression can be explained by the following steps:
)

$(UL
$(LI $(C ptr): The pointer that points at $(C center))

$(LI $(C $(HILITE *)ptr): Accessing the object (i.e. $(C center) itself))

$(LI $(C $(HILITE &#40;)*ptr$(HILITE &#41;)): Parentheses so that the $(C .) (dot) operator is applied to the object, not to the pointer)

$(LI $(C (*ptr)$(HILITE .x)): The $(C x) member of the object that $(C ptr) is pointing at)

)

$(P
To reduce the complexity of pointer syntax in D, the $(C .) (dot) operator is transferred to the pointee and provides access to the member of the object. (The exceptions to this rule are at the end of this section.)
)

$(P
So, the previous expression is normally written as:
)

---
    $(HILITE ptr.x) += 10;
---

$(P
Since the pointer itself does not have a member named $(C x), $(C .x) is applied to the pointee and the $(C x) member of $(C center) gets modified:
)

$(SHELL_SMALL
(10,0)
)

$(P
Note that this is the same as the use of the $(C .) (dot) operator with classes. When the $(C .) (dot) operator is applied to a class $(I variable), it provides access to a member of the class $(I object):
)

---
class ClassType {
    int member;
}

// ...

    // Variable on the left, object on the right
    ClassType variable = new ClassType;

    // Applied to the variable but accesses the member of
    // the object
    variable.member = 42;
---

$(P
As you remember from $(LINK2 class.html, the Classes chapter), the class object is constructed by the $(C new) keyword on the right-hand side. $(C variable) is a class variable that provides access to it.
)

$(P
Realizing that it is the same with pointers is an indication that class variables and pointers are implemented similarly by the compiler.
)

$(P
There is an exception to this rule both for class variables and for pointers. Type properties like $(C .sizeof) are applied to the type of the pointer, not to the type of the pointee:
)

---
    char c;
    char * p = &c;

    writeln(p.sizeof);  // size of the pointer, not the pointee
---

$(P
$(C .sizeof) produces the size of $(C p), which is a $(C char*), not the size of $(C c), which is a $(C char). On a 64-bit system pointers are 8-byte long:
)

$(SHELL_SMALL
8
)

$(H5 $(IX arithmetic, pointer) Modifying the value of a pointer)

$(P
The values of pointers can be incremented or decremented and they can be used in addition and subtraction:
)

---
    ++ptr;
    --ptr;
    ptr += 2;
    ptr -= 2;
    writeln(ptr + 3);
    writeln(ptr - 3);
---

$(P
Different from their arithmetic counterparts, these operations do not modify the actual value by the specified amount. Rather, the value of the pointer gets modified so that it now points at the variable that is a certain number of variables beyond the current one. The amount of the increment or the decrement specifies $(I how many variables away) should the pointer now point at.
)

$(P
For example, incrementing the value of a pointer makes it point at the next variable:
)

---
    ++ptr;  // Starts pointing at a variable that is next in
            // memory from the old variable
---

$(P
For that to work correctly, the actual value of the pointer must be incremented by the size of the variable. For example, because the size of $(C int) is 4, incrementing a pointer of type $(C int*) changes its value by 4. The programmer need not pay attention to this detail; the pointer value is modified by the correct amount automatically.
)

$(P $(B Warning): It is undefined behavior to point at a location that is not a valid byte that belongs to the program. Even if it is not actually used to access any variable there, it is invalid for a pointer to point at a nonexistent variable. (The only exception to this rule is that it is valid to point at the imaginary element one past the end of an array. This will be explained later below.)
)

$(P
For example, it is invalid to increment a pointer that points at $(C myVariable), because $(C myVariable) is defined as a single $(C int):
)

---
    ++myPointer;       $(CODE_NOTE_WRONG undefined behavior)
---

$(P
Undefined behavior means that it cannot be known what the behavior of the program will be after that operation. There may be systems where the program crashes after incrementing that pointer. However, on most modern systems the pointer is likely to point at the unused memory location that has been shown as being between $(C myVariable) and $(C myPointer) in the previous figure.
)

$(P
For that reason, the value of a pointer must be incremented or decremented only if there is a valid object at the new location. (As we will see below, pointing at the element one past the end of an array is valid as well). Arrays (and slices) have that property: The elements of an array are side by side in memory.
)

$(P
A pointer that is pointing at an element of a slice can be incremented safely as long as it is not used to access an element beyond the end of the slice. Incrementing such a pointer by the $(C ++) operator makes it point at the next element:
)

---
import std.stdio;
import std.string;
import std.conv;

enum Color { red, yellow, blue }

struct Crayon {
    Color color;
    double length;

    string toString() const {
        return format("%scm %s crayon", length, color);
    }
}

void main() {
    writefln("Crayon objects are %s bytes each.", Crayon.sizeof);

    Crayon[] crayons = [ Crayon(Color.red, 11),
                         Crayon(Color.yellow, 12),
                         Crayon(Color.blue, 13) ];

    $(HILITE Crayon * ptr) = $(HILITE &)crayons[0];                   // (1)

    for (int i = 0; i != crayons.length; ++i) {
        writeln("Pointer value: ", $(HILITE ptr));          // (2)

        writeln("Crayon: ", $(HILITE *ptr));                // (3)
        $(HILITE ++ptr);                                    // (4)
    }
}
---

$(OL
$(LI Definition: The pointer is initialized by the address of the first element.)
$(LI Using its value: The value of the pointer is the address of the element that it is pointing at.)
$(LI Accessing the element that is being pointed at.)
$(LI Pointing at the next element.)
)

$(P
The output:
)

$(SHELL
Crayon objects are 16 bytes each.
Pointer value: 7F37AC9E6FC0
Crayon: 11cm red crayon
Pointer value: 7F37AC9E6FD0
Crayon: 12cm yellow crayon
Pointer value: 7F37AC9E6FE0
Crayon: 13cm blue crayon
)

$(P
Note that the loop above is iterated a total of $(C crayons.length) times so that the pointer is always used for accessing a valid element.
)

$(H5 Pointers are risky)

$(P
The compiler and the D runtime environment cannot guarantee that the pointers are always used correctly. It is the programmer's responsibility to ensure that a pointer is either $(C null) or points at a valid memory location (at a variable, at an element of an array, etc.).
)

$(P
For that reason, it is always better to consider higher-level features of D before thinking about using pointers.
)

$(H5 $(IX element one past the end) The element one past the end of an array)

$(P
It is valid to point at the imaginary element one past the end of an array.
)

$(P
This is a useful idiom that is similar to number ranges. When defining a slice with a number range, the second index is one past the elements of the slice:
)

---
    int[] values = [ 0, 1, 2, 3 ];
    writeln(values[1 .. 3]);   // 1 and 2 included, 3 excluded
---

$(P
This idiom can be used with pointers as well. It is a common function design in C and C++ where a function parameter points at the first element and another one points at the element after the last element:
)

---
import std.stdio;

void tenTimes(int * begin, int * end) {
    while (begin != end) {
        *begin *= 10;
        ++begin;
    }
}

void main() {
    int[] values = [ 0, 1, 2, 3 ];

    // The address of the second element:
    int * begin = &values[1];

    // The address of two elements beyond that one
    tenTimes(begin, begin + 2);

    writeln(values);
}
---

$(P
The value $(C begin + 2) means two elements after the one that $(C begin) is pointing at (i.e. the element at index 3).
)

$(P
The $(C tenTimes()) function takes two pointer parameters. It uses the element that the first one is pointing at but it never accesses the element that the second one is pointing at. As a result, only the elements at indexes 1 and 2 get modified:
)

$(SHELL_SMALL
[0, 10, 20, 3]
)

$(P
Such functions can be implemented by a $(C for) loop as well:
)

---
    for ( ; begin != end; ++begin) {
        *begin *= 10;
    }
---

$(P
Two pointers that define a range can also be used with $(C foreach) loops:
)

---
    foreach (ptr; begin .. end) {
        *ptr *= 10;
    }
---

$(P
For these methods to be applicable to $(I all of the elements) of a slice, the second pointer must necessarily point after the last element:
)

---
    // The second pointer is pointing at the imaginary element
    // past the end of the array:
    tenTimes(begin, begin + values.length);
---

$(P
That is the reason why it is legal to point at the imaginary element one beyond the last element of an array.
)

$(H5 $(IX []) Using pointers with the array indexing operator $(C []))

$(P
Although it is not absolutely necessary in D, pointers can directly be used for accessing the elements of an array by an index value:
)

---
    double[] floats = [ 0.0, 1.1, 2.2, 3.3, 4.4 ];

    double * ptr = &floats[2];

    *ptr = -100;      // direct access to what it points at
    ptr$(HILITE [1]) = -200;    // access by indexing

    writeln(floats);
---

$(P
The output:
)

$(SHELL_SMALL
[0, 1.1, -100, -200, 4.4]
)

$(P
In that syntax, the element that the pointer is pointing at is thought of being the first element of an imaginary slice. The $(C []) operator provides access to the specified element of that slice. The $(C ptr) above initially points at the element at index 2 of the original $(C floats) slice. $(C ptr[1]) is a reference to the element 1 of the imaginary slice that starts at $(C ptr) (i.e. index 3 of the original slice).
)

$(P
Although this behavior may seem complicated, there is a very simple conversion behind that syntax. Behind the scenes, the compiler converts the $(C pointer[index]) syntax to the $(C *(pointer&nbsp;+&nbsp;index)) expression:
)

---
    ptr[1] = -200;      // slice syntax
    *(ptr + 1) = -200;  // the equivalent of the previous line
---

$(P
As I have mentioned earlier, the compiler may not guarantee that this expression refers to a valid element. D's slices provide a much safer alternative and should be considered instead:
)

---
    double[] slice = floats[2 .. 4];
    slice[0] = -100;
    slice[1] = -200;
---

$(P
Normally, index values are checked for slices at run time:
)

---
    slice[2] = -300;  // Runtime error: accessing outside of the slice
---

$(P
Because the slice above does not have an element at index 2, an exception would be thrown at run time (unless the program has been compiled with the $(C -release) compiler switch):
)

$(SHELL_SMALL
core.exception.RangeError@deneme(8391): Range violation
)

$(H5 $(IX slice from pointer) Producing a slice from a pointer)

$(P
Pointers are not as safe or as useful as slices because although they can be used with the slice indexing operator, they are not aware of the valid range of elements.
)

$(P
However, when the number of valid elements is known, a pointer can be used to construct a slice.
)

$(P
Let's assume that the $(C makeObjects()) function below is inside a C library. Let's assume that $(C makeObjects) makes specified number of $(C Struct) objects and returns a pointer to the first one of those objects:
)

---
    Struct * ptr = makeObjects(10);
---

$(P
The syntax that produces a slice from a pointer is the following:
)

---
    /* ... */ slice = pointer[0 .. count];
---

$(P
Accordingly, a slice to the 10 objects that are returned by $(C makeObjects()) can be constructed by the following code:
)

---
    Struct[] slice = ptr[0 .. 10];
---

$(P
After that definition, $(C slice) is ready to be used safely in the program just like any other slice:
)

---
    writeln(slice[1]);    // prints the second element
---

$(H5 $(IX void*) $(C void*) can point at any type)

$(P
Although it is almost never needed in D, C's special pointer type $(C void*) is available in D as well. $(C void*) can point at any type:
)

---
    int number = 42;
    double otherNumber = 1.25;
    void * canPointAtAnything;

    canPointAtAnything = &number;
    canPointAtAnything = &otherNumber;
---

$(P
The $(C void*) above is able to point at variables of two different types: $(C int) and $(C double).
)

$(P
$(C void*) pointers are limited in functionality. As a consequence of their flexibility, they cannot provide access to the pointee. When the actual type is unknown, its size is not known either:
)

---
    *canPointAtAnything = 43;     $(DERLEME_HATASI)
---

$(P
Instead, its value must first be converted to a pointer of the correct type:
)

---
    int number = 42;                                  // (1)
    void * canPointAtAnything = &number;              // (2)

    // ...

    int * intPointer = cast(int*)canPointAtAnything;  // (3)
    *intPointer = 43;                                 // (4)
---

$(OL
$(LI The actual variable)
$(LI Storing the address of the variable in a $(C void*))
$(LI Assigning that address to a pointer of the correct type)
$(LI Modifying the variable through the new pointer)
)

$(P
It is possible to increment or decrement values of $(C void*) pointers, in which case their values are modified as if they are pointers of 1-byte types like $(C ubyte):
)

---
    ++canPointAtAnything;    // incremented by 1
---

$(P
$(C void*) is sometimes needed when interacting with libraries that are written in C. Since C does not have higher level features like interfaces, classes, templates, etc. C libraries must rely on the $(C void*) type.
)

$(H5 Using pointers in logical expressions)

$(P
Pointers can automatically be converted to $(C bool). Pointers that have the value $(C null) produce $(C false) and the others produce $(C true). In other words, pointers that do not point at any variable are $(C false).
)

$(P
Let's consider a function that prints objects to the standard output. Let's design this function so that it also provides the number of bytes that it has just output. However, let's have it produce this information only when specifically requested.
)

$(P
It is possible to make this behavior optional by checking whether the value of a pointer is $(C null) or not:
)

---
void print(Crayon crayon, size_t * numberOfBytes) {
    immutable info = format("Crayon: %s", crayon);
    writeln(info);

    $(HILITE if (numberOfBytes)) {
        *numberOfBytes = info.length;
    }
}
---

$(P
When the caller does not need this special information, they can pass $(C null) as the argument:
)

---
    print(Crayon(Color.yellow, 7), $(HILITE null));
---

$(P
When the number of bytes is indeed important, then a non-$(C null) pointer value must be passed:
)

---
    size_t numberOfBytes;
    print(Crayon(Color.blue, 8), $(HILITE &numberOfBytes));
    writefln("%s bytes written to the output", numberOfBytes);
---

$(P
Note that this is just an example. Otherwise, it would be better for a function like $(C print()) to return the number of bytes unconditionally:
)

---
size_t print(Crayon crayon) {
    immutable info = format("Crayon: %s", crayon);
    writeln(info);

    return info.length;
}
---

$(H5 $(IX new) $(C new) returns a pointer for some types)

$(P
$(C new), which we have been using only for constructing class objects can be used with other types as well: structs, arrays, and fundamental types. The variables that are constructed by $(C new) are called dynamic variables.
)

$(P
$(C new) first allocates space from the memory for the variable and then constructs the variable in that space. The variable itself does not have a symbolic name in the compiled program; it would be accessed through the reference that is returned by $(C new).
)

$(P
The reference that $(C new) returns is a different kind depending on the type of the variable:
)

$(UL

$(LI For class objects, it is a $(I class variable):

---
    Class classVariable = new Class;
---

)

$(LI For struct objects and variables of fundamental types, it is a $(I pointer):

---
    Struct $(HILITE *) structPointer = new Struct;
    int $(HILITE *) intPointer = new int;
---

)

$(LI For arrays, it is a $(I slice):

---
    int[] slice = new int[100];
---

)

)

$(P
This distinction is usually not obvious when the type is not spelled-out on the left-hand side:
)

---
    auto classVariable = new Class;
    auto structPointer = new Struct;
    auto intPointer = new int;
    auto slice = new int[100];
---

$(P
The following program prints the return type of $(C new) for different kinds of variables:
)

---
import std.stdio;

struct Struct {
}

class Class {
}

void main() {
    writeln(typeof(new int   ).stringof);
    writeln(typeof(new int[5]).stringof);
    writeln(typeof(new Struct).stringof);
    writeln(typeof(new Class ).stringof);
}
---

$(P
$(C new) returns pointers for structs and fundamental types:
)

$(SHELL_SMALL
int*
int[]
Struct*
Class
)

$(P
When $(C new) is used for constructing a dynamic variable of a $(LINK2 value_vs_reference.html, value type), then the lifetime of that variable is extended as long as there is still a reference (e.g. a pointer) to that object in the program. (This is the default situation for reference types.)
)

$(H5 $(IX .ptr, array element) $(IX pointer, array element) The $(C .ptr) property of arrays)

$(P
The $(C .ptr) property of arrays and slices is the address of the first element. The type of this value is a pointer to the type of the elements:
)

---
    int[] numbers = [ 7, 12 ];

    int * addressOfFirstElement = numbers$(HILITE .ptr);
    writeln("First element: ", *addressOfFirstElement);
---

$(P
This property is useful especially when interacting with C libraries. Some C functions take the address of the first of a number of consecutive elements in memory.
)

$(P
Remembering that strings are also arrays, the $(C .ptr) property can be used with strings as well. However, note that the first element of a string need not be the first $(I letter) of the string; rather, the first Unicode code unit of that letter. As an example, the letter é is stored as two code units in a $(C char) string.
)

$(P
When accessed through the $(C .ptr) property, the code units of strings can be accessed individually. We will see this in the examples section below.
)

$(H5 $(IX in, operator) The $(C in) operator of associative arrays)

$(P
Actually, we have used pointers earlier in $(LINK2 aa.html, the Associative Arrays chapter). In that chapter, I had intentionally not mentioned the exact type of the $(C in) operator and had used it only in logical expressions:
)

---
    if ("purple" in colorCodes) {
        // there is an element for key "purple"

    } else {
        // no element for key "purple"
    }
---

$(P
In fact, the $(C in) operator returns the address of the element if there is an element for the specified key; otherwise, it returns $(C null). The $(C if) statement above actually relies on the automatic conversion of the pointer value to $(C bool).
)

$(P
When the return value of $(C in) is stored in a pointer, the element can be accessed efficiently through that pointer:
)

---
import std.stdio;

void main() {
    string[int] numbers =
        [ 0 : "zero", 1 : "one", 2 : "two", 3 : "three" ];

    int number = 2;
    auto $(HILITE element) = number in numbers;             // (1)

    if ($(HILITE element)) {                                // (2)
        writefln("I know: %s.", $(HILITE *element));        // (3)

    } else {
        writefln("I don't know the spelling of %s.", number);
    }
}
---

$(P
The pointer variable $(C element) is initialized by the value of the $(C in) operator (1) and its value is used in a logical expression (2). The value of the element is accessed through that pointer (3) only if the pointer is not $(C null).
)

$(P
The actual type of $(C element) above is a pointer to the same type of the elements (i.e. values) of the associative array. Since the elements of $(C numbers) above are of type $(C string), $(C in) returns a $(C string*). Accordingly, the type could have been spelled out explicitly:
)

---
    $(HILITE string *) element = number in numbers;
---

$(H5 When to use pointers)

$(P
Pointers are rare in D. As we have seen in $(LINK2 input.html, the Reading from the Standard Input chapter), $(C readf) can in fact be used without explicit pointers.
)

$(H6 When required by libraries)

$(P
Pointers can appear on C and C++ library bindings. For example, the following function from the GtkD library takes a pointer:
)

---
    GdkGeometry geometry;
    // ... set the members of 'geometry' ...

    window.setGeometryHints(/* ... */, $(HILITE &)geometry, /* ... */);
---

$(H6 When referencing variables of value types)

$(P
Pointers can be used for referring to local variables. The following program counts the outcomes of flipping a coin. It takes advantage of a pointer when referring to one of two local variables:
)

---
import std.stdio;
import std.random;

void main() {
    size_t headsCount = 0;
    size_t tailsCount = 0;

    foreach (i; 0 .. 100) {
        size_t * theCounter = (uniform(0, 2) == 1)
                               ? &headsCount
                               : &tailsCount;
        ++(*theCounter);
    }

    writefln("heads: %s  tails: %s", headsCount, tailsCount);
}
---

$(P
Obviously, there are other ways of achieving the same goal. For example, using the ternary operator in a different way:
)

---
        uniform(0, 2) ? ++headsCount : ++tailsCount;
---

$(P
By using an $(C if) statement:
)

---
        if (uniform(0, 2)) {
            ++headsCount;

        } else {
            ++tailsCount;
        }
---

$(H6 As member variables of data structures)

$(P
Pointers are essential when implementing many data structures.
)

$(P
Unlike the elements of an array being next to each other in memory, elements of many other data structures are apart. Such data structures are based on the concept of their elements $(I pointing at) other elements.
)

$(P
For example, each node of a linked list $(I points at) the next node. Similarly, each node of a binary tree $(I points at) the left and right branches under that node. Pointers are encountered in most other data structures as well.
)

$(P
Although it is possible to take advantage of D's reference types, pointers may be more natural and efficient in some cases.
)

$(P
We will see examples of pointer members below.
)

$(H6 When accessing memory directly)

$(P
Being low-level microprocessor features, pointers provide byte-level access to memory locations. Note that such locations must still belong to valid variables. It is undefined behavior to attempt to access a random memory location.
)

$(H5 Examples)

$(H6 A simple linked list)

$(P
The elements of linked lists are stored in $(I nodes). The concept of a linked list is based on each node pointing at the node that comes after it. The last node has no other node to point at, so it is set to $(C null):
)

$(MONO
   first node           next node                 last node
 ┌─────────┬───┐     ┌─────────┬───┐          ┌─────────┬──────┐
 │ element │ o────▶  │ element │ o────▶  ...  │ element │ null │
 └─────────┴───┘     └─────────┴───┘          └─────────┴──────┘
)

$(P
The figure above may be misleading: In reality, the nodes are not side-by-side in memory. Each node does point to the next node but the next node may be at a completely different location.
)

$(P
The following $(C struct) can be used for representing the nodes of such a linked list of $(C int)s:
)

---
struct Node {
    int element;
    Node * next;

    // ...
}
---

$(P $(I $(B Note:) Because it contains a reference to the same type as itself, $(C Node) is a $(IX recursive type) recursive type.)
)

$(P
The entire list can be represented by a single pointer that points at the first node, which is commonly called $(I the head):
)

---
struct List {
    Node * head;

    // ...
}
---

$(P
To keep the example short, let's define just one function that adds an element to the head of the list:
)

---
struct List {
    Node * head;

    void insertAtHead(int element) {
        head = new Node(element, head);
    }

    // ...
}
---

$(P
The line inside $(C insertAtHead()) keeps the nodes $(I linked) by adding a new node to the head of the list. (A function that adds to the end of the list would be more natural and more useful. We will see that function later in one of the problems.)
)

$(P
The right-hand side expression of that line constructs a $(C Node) object. When this new object is constructed, its $(C next) member is initialized by the current head of the list. When the $(C head) member of the list is assigned to this newly linked node, the new element ends up being the first element.
)

$(P
The following program tests these two structs:
)

---
import std.stdio;
import std.conv;
import std.string;

struct Node {
    int element;
    Node * next;

    string toString() const {
        string result = to!string(element);

        if (next) {
            result ~= " -> " ~ to!string(*next);
        }

        return result;
    }
}

struct List {
    Node * head;

    void insertAtHead(int element) {
        head = new Node(element, head);
    }

    string toString() const {
        return format("(%s)", head ? to!string(*head) : "");
    }
}

void main() {
    List numbers;

    writeln("before: ", numbers);

    foreach (number; 0 .. 10) {
        numbers.insertAtHead(number);
    }

    writeln("after : ", numbers);
}
---

$(P
The output:
)

$(SHELL_SMALL
before: ()
after : (9 -> 8 -> 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> 0)
)

$(H6 $(IX memory access, pointer) Observing the contents of memory by $(C ubyte*))

$(P
The data stored at each memory address is a byte. Every variable is constructed on a piece of memory that consists of as many bytes as the size of the type of that variable.
)

$(P
A suitable pointer type to observe the content of a memory location is $(C ubyte*). Once the address of a variable is assigned to a $(C ubyte) pointer, then all of the bytes of that variable can be observed by incrementing the pointer.
)

$(P
Let's consider the following integer that is initialized by the hexadecimal notation so that it will be easy to understand how its bytes are placed in memory:
)

---
    int variable = 0x01_02_03_04;
---

$(P
A pointer that points at that variable can be defined like this:
)

---
    int * address = &variable;
---

$(P
The value of that pointer can be assigned to a $(C ubyte) pointer by the $(C cast) operator:
)

---
    ubyte * bytePointer = cast(ubyte*)address;
---

$(P
Such a pointer allows accessing the four bytes of the $(C int) variable individually:
)

---
    writeln(bytePointer[0]);
    writeln(bytePointer[1]);
    writeln(bytePointer[2]);
    writeln(bytePointer[3]);
---

$(P
If your microprocessor is $(I little-endian) like mine, you should see the bytes of the value $(C 0x01_02_03_04) in reverse:
)

$(SHELL_SMALL
4
3
2
1
)

$(P
Let's use that idea in a function that will be useful when observing the bytes of all types of variables:
)

---
$(CODE_NAME printBytes)import std.stdio;

void printBytes(T)(ref T variable) {
    const ubyte * begin = cast(ubyte*)&variable;    // (1)

    writefln("type   : %s", T.stringof);
    writefln("value  : %s", variable);
    writefln("address: %s", begin);                 // (2)
    writef  ("bytes  : ");

    writefln("%(%02x %)", begin[0 .. T.sizeof]);    // (3)

    writeln();
}
---

$(OL
$(LI Assigning the address of the variable to a $(C ubyte) pointer.)
$(LI Printing the value of the pointer.)
$(LI Obtaining the size of the type by $(C .sizeof) and printing the bytes of the variable. (Note how a slice is produced from the $(C begin) pointer and then that slice is printed directly by $(C writefln()).))
)

$(P
Another way of printing the bytes would be to apply the $(C *) operator individually:
)

---
    foreach (bytePointer; begin .. begin + T.sizeof) {
        writef("%02x ", *bytePointer);
    }
---

$(P
The value of $(C bytePointer) would change from $(C begin) to $(C begin&nbsp;+&nbsp;T.sizeof) to visit all of the bytes of the variable. Note that the value $(C begin&nbsp;+&nbsp;T.sizeof) is outside of the range and is never accessed.
)

$(P
The following program calls $(C printBytes()) with various types of variables:
)

---
$(CODE_XREF printBytes)struct Struct {
    int first;
    int second;
}

class Class {
    int i;
    int j;
    int k;

    this(int i, int j, int k) {
        this.i = i;
        this.j = j;
        this.k = k;
    }
}

void main() {
    int integerVariable = 0x11223344;
    printBytes(integerVariable);

    double doubleVariable = double.nan;
    printBytes(doubleVariable);

    string slice = "a bright and charming façade";
    printBytes(slice);

    int[3] array = [ 1, 2, 3 ];
    printBytes(array);

    auto structObject = Struct(0xaa, 0xbb);
    printBytes(structObject);

    auto classVariable = new Class(1, 2, 3);
    printBytes(classVariable);
}
---

$(P
The output of the program is informative:
)

$(SHELL_SMALL
type   : int
value  : 287454020
address: 7FFF19A83FB0
bytes  : 44 33 22 11                             $(SHELL_NOTE (1))

type   : double
value  : nan
address: 7FFF19A83FB8
bytes  : 00 00 00 00 00 00 f8 7f                 $(SHELL_NOTE (2))

type   : string
value  : a bright and charming façade
address: 7FFF19A83FC0
bytes  : 1d 00 00 00 00 00 00 00 e0 68 48 00 00 00 00 00
                                                 $(SHELL_NOTE (3))
type   : int[3LU]
value  : [1, 2, 3]
address: 7FFF19A83FD0
bytes  : 01 00 00 00 02 00 00 00 03 00 00 00     $(SHELL_NOTE (1))

type   : Struct
value  : Struct(170, 187)
address: 7FFF19A83FE8
bytes  : aa 00 00 00 bb 00 00 00                 $(SHELL_NOTE (1))

type   : Class
value  : deneme.Class
address: 7FFF19A83FF0
bytes  : 80 df 79 d5 97 7f 00 00                 $(SHELL_NOTE (4))
)

$(P $(B Observations:)
)

$(OL

$(LI Although in reverse order on little-endian systems, the bytes of some of the types are as one would expect: The bytes are laid out in memory side by side for $(C int)s, fixed-length arrays ($(C int[3])), and struct objects.)

$(LI Considering that the bytes of the special value of $(C double.nan) are also in reverse order in memory, we can see that it is represented by the special bit pattern 0x7ff8000000000000.)

$(LI $(C string) is reported to be consisting of 16 bytes but it is impossible to fit the letters $(STRING "a bright and charming façade") into so few bytes. This is due to the fact that behind the scenes $(C string) is actually implemented as a struct. Prefixing its name by $(C __) to stress the fact that it is an internal type used by the compiler, that struct is similar to the following one:

---
struct __string {
    size_t length;
    char * ptr;    // the actual characters
}
---

$(P
The evidence of this fact is hidden in the bytes that are printed for $(C string) above. Note that because ç is made up of two UTF-8 code units, the 28 letters of the string $(STRING "a bright and charming façade") consists of a total of 29 bytes. The value 0x000000000000001d, the first 8 of the bytes of the string in the output above, is also 29. This is a strong indicator that strings are indeed laid out in memory as in the struct above.
)

)

$(LI Similarly, it is not possible to fit the three $(C int) members of the class object in 8 bytes. The output above hints at the possibility that behind the scenes a class variable is implemented as a single pointer that points at the actual class object:

---
struct __Class_VariableType {
    __Class_ActualObjecType * object;
}
---

)

)

$(P
Let's now consider a more flexible function. Instead of printing the bytes of a variable, let's define a function that prints specified number of bytes at a specified location:
)

---
$(CODE_NAME printMemory)import std.stdio;
import std.ascii;

void printMemory(T)(T * location, size_t length) {
    const ubyte * begin = cast(ubyte*)location;

    foreach (address; begin .. begin + length) {
        char c = (isPrintable(*address) ? *address : '.');

        writefln("%s:  %02x  %s", address, *address, c);
    }
}
---

$(P
Since some of the UTF-8 code units may correspond to control characters of the terminal and disrupt its output, we print only the printable characters by first checking them individually by $(C std.ascii.isPrintable()). The non-printable characters are printed as a dot.
)

$(P
We can use that function to print the UTF-8 code units of a $(C string) through its $(C .ptr) property:
)

---
$(CODE_XREF printMemory)import std.stdio;

void main() {
    string s = "a bright and charming façade";
    printMemory(s.ptr, s.length);
}
---

$(P
As seen in the output, the letter ç consists of two bytes:
)

$(SHELL_SMALL
47B4F0:  61  a
47B4F1:  20   
47B4F2:  62  b
47B4F3:  72  r
47B4F4:  69  i
47B4F5:  67  g
47B4F6:  68  h
47B4F7:  74  t
47B4F8:  20   
47B4F9:  61  a
47B4FA:  6e  n
47B4FB:  64  d
47B4FC:  20   
47B4FD:  63  c
47B4FE:  68  h
47B4FF:  61  a
47B500:  72  r
47B501:  6d  m
47B502:  69  i
47B503:  6e  n
47B504:  67  g
47B505:  20   
47B506:  66  f
47B507:  61  a
47B508:  c3  .
47B509:  a7  .
47B50A:  61  a
47B50B:  64  d
47B50C:  65  e
)

$(PROBLEM_COK

$(PROBLEM
Fix the following function so that the values of the arguments that are passed to it are swapped. For this exercise, do not specify the parameters as $(C ref) but take them as pointers:

---
void swap(int lhs, int rhs) {
    int temp = lhs;
    lhs = rhs;
    rhs = temp;
}

void main() {
    int i = 1;
    int j = 2;

    swap(i, j);

    // Their values should be swapped
    assert(i == 2);
    assert(j == 1);
}
---

$(P
When you start the program you will notice that the $(C assert) checks currently fail.
)

)

$(PROBLEM
Convert the linked list that we have defined above to a template so that it can be used for storing elements of any type.
)

$(PROBLEM
It is more natural to add elements to the end of a linked list. Modify $(C List) so that it is possible to add elements to the end as well.

$(P
For this exercise, an additional pointer member variable that points at the last element will be useful.
)

)

)

Macros:
        TITLE=Pointers

        DESCRIPTION=Pointers, variables that point at other variables to provide access to them.

        KEYWORDS=d programming language tutorial book pointers
