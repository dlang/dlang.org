Ddoc

$(DERS_BOLUMU Constructor and Other Special Functions)

$(P
Although this chapter focuses only on structs, the topics that are covered here apply mostly to classes as well. The differences will be explained in later chapters.
)

$(P
Four member functions of structs are special because they define the fundamental operations of that type:
)
$(UL
$(LI Constructor: $(C this()))
$(LI Destructor: $(C ~this()))
$(LI Postblit: $(C this(this)))
$(LI Assignment operator: $(C opAssign()))
)

$(P
Although these fundamental operations are handled automatically for structs, hence need not be defined by the programmer, they can be overridden to make the $(C struct) behave in special ways.
)

$(H5 $(IX constructor) $(IX this, constructor) Constructor)

$(P
The responsibility of the constructor is to prepare an object for use by assigning appropriate values to its members.
)

$(P
We have already used constructors in previous chapters. When the name of a type is used like a function, it is actually the constructor that gets called. We can see this on the right-hand side of the following line:
)

---
    auto busArrival = $(HILITE TimeOfDay)(8, 30);
---

$(P
Similarly, a $(I class) object is being constructed on the right hand side of the following line:
)

---
    auto variable = new $(HILITE SomeClass());
---

$(P
The arguments that are specified within parentheses correspond to the constructor parameters. For example, the values 8 and 30 above are passed to the $(C TimeOfDay) constructor as its parameters.
)

$(P
In addition to different object construction syntaxes that we have seen so far; $(C const), $(C immutable), and $(C shared) objects can be constructed with the $(I type constructor) syntax as well (e.g. as $(C immutable(S)(2))). (We will see the $(C shared) keyword in $(LINK2 concurrency_shared.html, a later chapter).)
)

$(P
For example, although all three variables below are $(C immutable), the construction of variable $(C a) is semantically different from the constructions of variables $(C b) and $(C c):
)

---
    /* More familiar syntax; immutable variable of a mutable
     * type: */
    $(HILITE immutable) a = S(1);

    /* Type constructor syntax; a variable of an immutable
     * type: */
    auto b = $(HILITE immutable(S))(2);

    /* Same meaning as 'b' */
    immutable c = $(HILITE immutable(S))(3);
---

$(H6 Constructor syntax)

$(P
Different from other functions, constructors do not have return values. The name of the constructor is always $(C this):
)

---
struct SomeStruct {
    // ...

    this(/* constructor parameters */) {
        // ... operations that prepare the object for use ...
    }
}
---

$(P
The constructor parameters include information that is needed to make a useful and consistent object.
)

$(H6 $(IX automatic constructor) $(IX default constructor) Compiler-generated automatic constructor)

$(P
All of the structs that we have seen so far have been taking advantage of a constructor that has been generated automatically by the compiler. The automatic constructor assigns the parameter values to the members in the order that they are specified.
)

$(P
As you will remember from $(LINK2 struct.html, the Structs chapter), the initial values for the trailing members need not be specified. The members that are not specified get initialized by the $(C .init) value of their respective types.  The $(C .init) values of a member could be provided during the definition of that member after the $(C =) operator:
)

---
struct Test {
    int member $(HILITE = 42);
}
---

$(P
Also considering the $(I default parameter values) feature from $(LINK2 parameter_flexibility.html, the Variable Number of Parameters chapter), we can imagine that the automatic constructor for the following $(C struct) would be the equivalent of the following $(C this()):
)

---
struct Test {
    char   c;
    int    i;
    double d;

    /* The equivalent of the compiler-generated automatic
     * constructor (Note: This is only for demonstration; the
     * following constructor would not actually be called
     * when default-constructing the object as Test().) */
    this(char   c_parameter = char.init,
         int    i_parameter = int.init,
         double d_parameter = double.init) {
        c = c_parameter;
        i = i_parameter;
        d = d_parameter;
    }
}
---

$(P
For most structs, the compiler-generated constructor is sufficient: Usually, providing appropriate values for each member is all that is needed for objects to be constructed.
)

$(H6 $(IX this, member access) Accessing the members by $(C this.))

$(P
To avoid mixing the parameters with the members, the parameter names above had $(C _parameter) appended to their names. There would be compilation errors without doing that:
)

---
struct Test {
    char   c;
    int    i;
    double d;

    this(char   c = char.init,
         int    i = int.init,
         double d = double.init) {
        // An attempt to assign an 'in' parameter to itself!
        c = c;    $(DERLEME_HATASI)
        i = i;
        d = d;
    }
}
---

$(P
The reason is; $(C c) alone would mean the parameter, not the member, and as the parameters above are defined as $(C in), they cannot be modified:
)

$(SHELL
Error: variable deneme.Test.this.c $(HILITE cannot modify const)
)

$(P
A solution is to prepend the member names with $(C this.). Inside member functions, $(C this) means "this object", making $(C this.c) mean "the c member of this object":
)

---
    this(char   c = char.init,
         int    i = int.init,
         double d = double.init) {
        $(HILITE this.)c = c;
        $(HILITE this.)i = i;
        $(HILITE this.)d = d;
    }
---

$(P
Now $(C c) alone means the parameter and $(C this.c) means the member, and the code compiles and works as expected: The member $(C c) gets initialized by the value of the parameter $(C c).
)

$(H6 $(IX user defined constructor) User-defined constructors)

$(P
I have described the behavior of the compiler-generated constructor. Since that constructor is suitable for most cases, there is no need to define a constructor by hand.
)

$(P
Still, there are cases where constructing an object involves more complicated operations than assigning values to each member in order. As an example, let's consider $(C Duration) from the earlier chapters:
)

---
struct Duration {
    int minute;
}
---

$(P
The compiler-generated constructor is sufficient for this single-member struct:
)

---
    time.decrement(Duration(12));
---

$(P
Since that constructor takes the duration in minutes, the programmers would sometimes need to make calculations:
)

---
    // 23 hours and 18 minutes earlier
    time.decrement(Duration(23 * 60 + 18));

    // 22 hours and 20 minutes later
    time.increment(Duration(22 * 60 + 20));
---

$(P
To eliminate the need for these calculations, we can design a $(C Duration) constructor that takes two parameters and makes the calculation automatically:
)

---
struct Duration {
    int minute;

    this(int hour, int minute) {
        this.minute = hour * 60 + minute;
    }
}
---

$(P
Since hour and minute are now separate parameters, the users simply provide their values without needing to make the calculation themselves:
)

---
    // 23 hours and 18 minutes earlier
    time.decrement(Duration($(HILITE 23, 18)));

    // 22 hours and 20 minutes later
    time.increment(Duration($(HILITE 22, 20)));
---

$(H6 First assignment to a member is construction)

$(P
When setting values of members in a constructor, the first assignment to each member is treated specially: Instead of assigning a new value over the $(C .init) value of that member, the first assignment actually constructs that member. Further assignments to that member are treated regularly as assignment operations.
)

$(P
This special behavior is necessary so that $(C immutable) and $(C const) members can in fact be constructed with values known only at run time. Otherwise, they could never be set to desired values as assignment is disallowed for $(C immutable) and $(C const) variables.
)

$(P
The following program demonstrates how assigment operation is allowed only once for an $(C immutable) member:
)

---
struct S {
    int m;
    immutable int i;

    this(int m, int i) {
        this.m = m;     $(CODE_NOTE construction)
        this.m = 42;    $(CODE_NOTE assignment (possible for mutable member))

        this.i = i;     $(CODE_NOTE construction)
        this.i = i;     $(DERLEME_HATASI)
    }
}

void main() {
    auto s = S(1, 2);
}
---

$(H6 User-defined constructor disables compiler-generated constructor)

$(P
A constructor that is defined by the programmer makes some uses of the compiler-generated constructor invalid: Objects cannot be constructed by $(I default parameter values) anymore. For example, trying to construct $(C Duration) by a single parameter is a compilation error:
)

---
    time.decrement(Duration(12));    $(DERLEME_HATASI)
---

$(P
Calling the constructor with a single parameter does not match the programmer's constructor and the compiler-generated constructor is disabled.
)

$(P
One solution is to $(I overload) the constructor by providing another constructor that takes just one parameter:
)

---
struct Duration {
    int minute;

    this(int hour, int minute) {
        this.minute = hour * 60 + minute;
    }

    this(int minute) {
        this.minute = minute;
    }
}
---

$(P
A user-defined constructor disables constructing objects by the $(C {&nbsp;}) syntax as well:
)

---
    Duration duration = { 5 };    $(DERLEME_HATASI)
---

$(P
Initializing without providing any parameter is still valid:
)

---
    auto d = Duration();    // compiles
---

$(P
The reason is, in D, the $(C .init) value of every type must be known at compile time. The value of $(C d) above is equal to the initial value of $(C Duration):
)

---
    assert(d == Duration.init);
---

$(H6 $(IX static opCall) $(IX opCall, static) $(C static opCall) instead of the default constructor)

$(P
Because the initial value of every type must be known at compile time, it is impossible to define the default constructor explicitly.
)

$(P
Let's consider the following constructor that tries to print some information every time an object of that type is constructed:
)

---
struct Test {
    this() {    $(DERLEME_HATASI)
        writeln("A Test object is being constructed.");
    }
}
---

$(P
The compiler output:
)

$(SHELL
Error: constructor deneme.Deneme.this default constructor for
structs only allowed with @disable and no body
)

$(P $(I $(B Note:) We will see in later chapters that it is possible to define the default constructor for classes.
))

$(P
As a workaround, a no-parameter $(C static opCall()) can be used for constructing objects without providing any parameters. Note that this has no effect on the $(C .init) value of the type.
)

$(P
For this to work, $(C static opCall()) must construct and return an object of that struct type:
)

---
import std.stdio;

struct Test {
    $(HILITE static) Test $(HILITE opCall)() {
        writeln("A Test object is being constructed.");
        Test test;
        return test;
    }
}

void main() {
    auto test = $(HILITE Test());
}
---

$(P
The $(C Test()) call in $(C main()) executes $(C static opCall()):
)

$(SHELL
A Test object is being constructed.
)

$(P
Note that it is not possible to type $(C Test()) inside $(C static opCall()). That syntax would execute $(C static opCall()) as well and cause an infinite recursion:
)

---
    static Test opCall() {
        writeln("A Test object is being constructed.");
        return $(HILITE Test());    // ← Calls 'static opCall()' again
    }
---

$(P
The output:
)

$(SHELL
A Test object is being constructed.
A Test object is being constructed.
A Test object is being constructed.
...    $(SHELL_NOTE repeats the same message)
)

$(H6 Calling other constructors)

$(P
Constructors can call other constructors to avoid code duplication. Although $(C Duration) is too simple to demonstrate how useful this feature is, the following single-parameter constructor takes advantage of the two-parameter constructor:
)

---
    this(int hour, int minute) {
        this.minute = hour * 60 + minute;
    }

    this(int minute) {
        this(0, minute);    // calls the other constructor
    }
---

$(P
The constructor that only takes the minute value calls the other constructor by passing 0 as the value of hour.
)

$(P
$(I $(B Warning:) There is a design flaw in the $(C Duration) constructors above because the intention is not clear when the objects are constructed by a single parameter):
)

---
    // 10 hours or 10 minutes?
    auto travelDuration = Duration(10);
---

$(P
Although it is possible to determine by reading the documentation or the code of the struct that the parameter actually means "10 minutes," it is an inconsistency as the first parameter of the two-parameter constructor is $(I hours).
)

$(P
Such design mistakes are causes of bugs and must be avoided.
)

$(H6 $(IX constructor qualifier) $(IX qualifier, constructor) Constructor qualifiers)

$(P
Normally, the same constructor is used for $(I mutable), $(C const), $(C immutable), and $(C shared) objects:
)

---
import std.stdio;

struct S {
    this(int i) {
        writeln("Constructing an object");
    }
}

void main() {
    auto m = S(1);
    const c = S(2);
    immutable i = S(3);
    shared s = S(4);
}
---

$(P
Semantically, the objects that are constructed on the right-hand sides of those expressions are all mutable but the variables have different type qualifiers. The same constructor is used for all of them:
)

$(SHELL
Constructing an object
Constructing an object
Constructing an object
Constructing an object
)

$(P
Depending on the qualifier of the resulting object, sometimes some members may need to be initialized differently or need not be initialized at all. For example, since no member of an $(C immutable) object can be mutated throughout the lifetime of that object, leaving its mutable members uninitialized can improve program performance.
)

$(P
$(I Qualified constructors) can be defined differently for objects with different qualifiers:
)

---
import std.stdio;

struct S {
    this(int i) {
        writeln("Constructing an object");
    }

    this(int i) $(HILITE const) {
        writeln("Constructing a const object");
    }

    this(int i) $(HILITE immutable) {
        writeln("Constructing an immutable object");
    }

    // We will see the 'shared' keyword in a later chapter.
    this(int i) $(HILITE shared) {
        writeln("Constructing a shared object");
    }
}

void main() {
    auto m = S(1);
    const c = S(2);
    immutable i = S(3);
    shared s = S(4);
}
---

$(P
However, as indicated above, as the right-hand side expressions are all semantically mutable, those objects are still constructed with the $(I mutable) object contructor:
)

$(SHELL
Constructing an object
Constructing an object    $(SHELL_NOTE_WRONG NOT the const constructor)
Constructing an object    $(SHELL_NOTE_WRONG NOT the immutable constructor)
Constructing an object    $(SHELL_NOTE_WRONG NOT the shared constructor)
)

$(P
$(IX type constructor) To take advantage of qualified constructors, one must use the $(I type constructor) syntax. (The term $(I type constructor) should not be confused with object constructors; type constructor is related to types, not objects.) This syntax $(I makes) a different type by combining a qualifier with an existing type. For example, $(C immutable(S)) is a qualified type made from $(C immutable) and $(C S):
)

---
    auto m = S(1);
    auto c = $(HILITE const(S))(2);
    auto i = $(HILITE immutable(S))(3);
    auto s = $(HILITE shared(S))(4);
---

$(P
This time, the objects that are in the right-hand expressions are different: $(I mutable), $(C const), $(C immutable), and $(C shared), respectively. As a result, each object is constructed with its matching constructor:
)

$(SHELL
Constructing an object
Constructing a $(HILITE const) object
Constructing an $(HILITE immutable) object
Constructing a $(HILITE shared) object
)

$(P
Note that, since all of the variables above are defined with the $(C auto) keyword, they are correctly inferred to be $(I mutable), $(C const), $(C immutable), and $(C shared), respectively.
)

$(H6 Immutability of constructor parameters)

$(P
In the $(LINK2 const_and_immutable.html, Immutability chapter) we have seen that it is not easy to decide whether parameters of reference types should be defined as $(C const) or $(C immutable). Although the same considerations apply for constructor parameters as well, $(C immutable) is usually a better choice for constructor parameters.
)

$(P
The reason is, it is common to assign the parameters to members to be used at a later time. When a parameter is not $(C immutable), there is no guarantee that the original variable will not change by the time the member gets used.
)

$(P
Let's consider a constructor that takes a file name as a parameter. The file name will be used later on when writing student grades. According to the guidelines in the $(LINK2 const_and_immutable.html, Immutability chapter), to be more useful, let's assume that the constructor parameter is defined as $(C const&nbsp;char[]):
)

---
import std.stdio;

struct Student {
    $(HILITE const char[]) fileName;
    int[] grades;

    this($(HILITE const char[]) fileName) {
        this.fileName = fileName;
    }

    void save() {
        auto file = File(fileName.idup, "w");
        file.writeln("The grades of the student:");
        file.writeln(grades);
    }

    // ...
}

void main() {
    char[] fileName;
    fileName ~= "student_grades";

    auto student = Student(fileName);

    // ...

    /* Assume the fileName variable is modified later on
     * perhaps unintentionally (all of its characters are
     * being set to 'A' here): */
    $(HILITE fileName[] = 'A');

    // ...

    /* The grades would be written to the wrong file: */
    student.save();
}
---

$(P
The program above saves the grades of the student under a file name that consists of A characters, not to $(STRING "student_grades"). For that reason, sometimes it is more suitable to define constructor parameters and members of reference types as $(C immutable). We know that this is easy for strings by using aliases like $(C string). The following code shows the parts of the struct that would need to be modified:
)

---
struct Student {
    $(HILITE string) fileName;
    // ...
    this($(HILITE string) fileName) {
        // ...
    }
    // ...
}
---

$(P
Now the users of the struct must provide $(C immutable) strings and as a result the confusion about the name of the file would be prevented.
)

$(H6 $(IX type conversion, constructor) Type conversions through single-parameter constructors)

$(P
Single-parameter constructors can be thought of as providing a sort of type conversion: They produce an object of the particular struct type starting from a constructor parameter. For example, the following constructor produces a $(C Student) object from a $(C string):
)

---
struct Student {
    string name;

    this(string name) {
        this.name = name;
    }
}
---

$(P
$(C to()) and $(C cast) observe this behavior as a $(I conversion) as well. To see examples of this, let's consider the following $(C salute()) function. Sending a $(C string) parameter when it expects a $(C Student) would naturally cause a compilation error:
)

---
void salute(Student student) {
    writeln("Hello ", student.name);
}
// ...
    salute("Jane");    $(DERLEME_HATASI)
---

$(P
On the other hand, all of the following lines ensure that a $(C Student) object is constructed before calling the function:
)

---
import std.conv;
// ...
    salute(Student("Jane"));
    salute(to!Student("Jean"));
    salute(cast(Student)"Jim");
---

$(P
$(C to) and $(C cast) take advantage of the single-parameter constructor by constructing a temporary $(C Student) object and calling $(C salute()) with that object.
)

$(H6 $(IX @disable, constructor) Disabling the default constructor)

$(P
Functions that are declared as $(C @disable) cannot be called.
)

$(P
Sometimes there are no sensible default values for the members of a type. For example, it may be illegal for the following type to have an empty file name:
)

---
struct Archive {
    string fileName;
}
---

$(P
Unfortunately, the compiler-generated default constructor would initialize $(C fileName) as empty:
)

---
    auto archive = Archive();    // ← fileName member is empty
---

$(P
The default constructor can explicitly be disabled by declaring it as $(C @disable) so that objects must be constructed by one of the other constructors. There is no need to provide a body for a disabled function:
)

---
struct Archive {
    string fileName;

    $(HILITE @disable this();)             $(CODE_NOTE cannot be called)

    this(string fileName) {      $(CODE_NOTE can be called)
        // ...
    }
}

// ...

    auto archive = Archive();    $(DERLEME_HATASI)
---

$(P
This time the compiler does not allow calling $(C this()):
)

$(SHELL
Error: constructor deneme.Archive.this is $(HILITE not callable) because
it is annotated with @disable
)

$(P
Objects of $(C Archive) must be constructed either with one of the other constructors or explicitly with its $(C .init) value:
)

---
    auto a = Archive("records");    $(CODE_NOTE compiles)
    auto b = Archive.init;          $(CODE_NOTE compiles)
---

$(H5 $(IX destructor) $(IX ~this) Destructor)

$(P
The destructor includes the operations that must be executed when the lifetime of an object ends.
)

$(P
The compiler-generated automatic destructor executes the destructors of all of the members in order. For that reason, as it is with the constructor, there is no need to define a destructor for most structs.
)

$(P
However, sometimes some special operations may need to be executed when an object's lifetime ends. For example, an operating system resource that the object owns may need to be returned to the system; a member function of another object may need to be called; a server running somewhere on the network may need to be notified that a connection to it is about to be terminated; etc.
)

$(P
The name of the destructor is $(C ~this) and just like constructors, it has no return type.
)

$(H6 Destructor is executed automatically)

$(P
The destructor is executed as soon as the lifetime of the struct object ends. (This is not the case for objects that are constructed with the $(C new) keyword.)
)

$(P
As we have seen in the $(LINK2 lifetimes.html, Lifetimes and Fundamental Operations chapter,) the lifetime of an object ends when leaving the scope that it is defined in. The following are times when the lifetime of a struct ends:
)

$(UL
$(LI When leaving the scope of the object either normally or due to a thrown exception:

---
    if (aCondition) {
        auto duration = Duration(7);
        // ...

    } // ← The destructor is executed for 'duration'
      //   at this point
---

)

$(LI Anonymous objects are destroyed at the end of the whole expression that they are constructed in:

---
    time.increment(Duration(5)); // ← The Duration(5) object
                                 //   gets destroyed at the end
                                 //   of the whole expression.
---

)

$(LI All of the struct members of a struct object get destroyed when the outer object is destroyed.

)

)

$(H6 Destructor example)

$(P
Let's design a type for generating simple XML documents. XML elements are defined by angle brackets. They contain data and other XML elements. XML elements can have attributes as well; we will ignore them here.
)

$(P
Our aim will be to ensure that an element that has been $(I opened) by a $(C &lt;name&gt;) tag will always be $(I closed) by a matching $(C &lt;/name&gt;) tag:
)

$(MONO
  &lt;class1&gt;    ← opening the outer XML element
    &lt;grade&gt;   ← opening the inner XML element
      57      ← the data
    &lt;/grade&gt;  ← closing the inner element
  &lt;/class1&gt;   ← closing the outer element
)

$(P
A struct that can produce the output above can be designed by two members that store the tag for the XML element and the indentation to use when printing it:
)

---
struct XmlElement {
    string name;
    string indentation;
}
---

$(P
If the responsibilities of opening and closing the XML element are given to the constructor and the destructor, respectively, the desired output can be produced by managing the lifetimes of XmlElement objects. For example, the constructor can print $(C &lt;tag&gt;) and the destructor can print $(C &lt;/tag&gt;).
)

$(P
The following definition of the constructor produces the opening tag:
)

---
    this(string name, int level) {
        this.name = name;
        this.indentation = indentationString(level);

        writeln(indentation, '<', name, '>');
    }
---

$(P
$(C indentationString()) is the following function:
)

---
import std.array;
// ...
string indentationString(int level) {
    return replicate(" ", level * 2);
}
---

$(P
The function calls $(C replicate()) from the $(C std.array) module, which makes and returns a new string made up of the specified value repeated the specified number of times.
)

$(P
The destructor can be defined similar to the constructor to produce the closing tag:
)

---
    ~this() {
        writeln(indentation, "</", name, '>');
    }
---

$(P
Here is a test code to demonstrate the effects of the automatic constructor and destructor calls:
)

---
import std.conv;
import std.random;
import std.array;

string indentationString(int level) {
    return replicate(" ", level * 2);
}

struct XmlElement {
    string name;
    string indentation;

    this(string name, int level) {
        this.name = name;
        this.indentation = indentationString(level);

        writeln(indentation, '<', name, '>');
    }

    ~this() {
        writeln(indentation, "</", name, '>');
    }
}

void main() {
    immutable classes = XmlElement("classes", 0);

    foreach (classId; 0 .. 2) {
        immutable classTag = "class" ~ to!string(classId);
        immutable classElement = XmlElement(classTag, 1);

        foreach (i; 0 .. 3) {
            immutable gradeElement = XmlElement("grade", 2);
            immutable randomGrade = uniform(50, 101);

            writeln(indentationString(3), randomGrade);
        }
    }
}
---

$(P
Note that the $(C XmlElement) objects are created in three separate scopes in the program above. The opening and closing tags of the XML elements in the output are produced solely by the constructor and the destructor of $(C XmlElement).
)

$(SHELL
&lt;classes&gt;
  &lt;class0&gt;
    &lt;grade&gt;
      72
    &lt;/grade&gt;
    &lt;grade&gt;
      97
    &lt;/grade&gt;
    &lt;grade&gt;
      90
    &lt;/grade&gt;
  &lt;/class0&gt;
  &lt;class1&gt;
    &lt;grade&gt;
      77
    &lt;/grade&gt;
    &lt;grade&gt;
      87
    &lt;/grade&gt;
    &lt;grade&gt;
      56
    &lt;/grade&gt;
  &lt;/class1&gt;
&lt;/classes&gt;
)

$(P
The $(C &lt;classes&gt;) element is produced by the $(C classesElement) variable. Because that variable is constructed first in $(C main()), the output contains the output of its construction first. Since it is also the variable that is destroyed last, upon leaving $(C main()), the output contains the output of the destructor call for its destruction last.
)

$(H5 $(IX postblit) $(IX this(this)) Postblit)

$(P
$(I Copying) is constructing a new object from an existing one. Copying involves two steps:
)

$(OL

$(LI Copying the members of the existing object to the new object bit-by-bit. This step is called $(I blit), short for $(I block transfer).
)

$(LI Making further adjustments to the new object. This step is called $(I postblit).
)

)

$(P
The first step is handled automatically by the compiler: It copies the members of the existing object to the members of the new object:
)

---
    auto returnTripDuration = tripDuration;   // copying
---

$(P
Do not confuse copying with $(I assignment). The $(C auto) keyword above is an indication that a new object is being defined. (The actual type name could have been spelled out instead of $(C auto).)
)

$(P
For an operation to be assignment, the object on the left-hand side must be an existing object. For example, assuming that $(C returnTripDuration) has already been defined:
)

---
    returnTripDuration = tripDuration;  // assignment (see below)
---

$(P
Sometimes it is necessary to make adjustments to the members of the new object after the automatic blit. These operations are defined in the postblit function of the struct.
)

$(P
Since it is about object construction, the name of the postblit is $(C this) as well. To separate it from the other constructors, its parameter list contains the keyword $(C this):

)

---
    this(this) {
        // ...
    }
---

$(P
We have defined a $(C Student) type in the $(LINK2 struct.html, Structs chapter), which had a problem about copying objects of that type:
)

---
struct Student {
    int number;
    int[] grades;
}
---

$(P
Being a slice, the $(C grades) member of that $(C struct) is a reference type. The consequence of copying a $(C Student) object is that the $(C grades) members of both the original and the copy provide access to the same actual array elements of type $(C int). As a result, the effect of modifying a grade through one of these objects is seen through the other object as well:
)

---
    auto student1 = Student(1, [ 70, 90, 85 ]);

    auto student2 = student1;    // copying
    student2.number = 2;

    student1.grades[0] += 5; // this changes the grade of the
                             // second student as well:
    assert($(HILITE student2).grades[0] == $(HILITE 75));
---

$(P
To avoid such a confusion, the elements of the $(C grades) member of the second object must be separate and belong only to that object. Such $(I adjustments) are done in the postblit:
)

---
struct Student {
    int number;
    int[] grades;

    this(this) {
        grades = grades.dup;
    }
}
---

$(P
Remember that all of the members have already been copied automatically before $(C this(this)) started executing. The single line in the postblit above makes a copy of the $(I elements) of the original array and assigns a slice of it back to $(C grades). As a result, the new object gets its own copy of the grades.
)

$(P
Making modifications through the first object does not affect the second object anymore:
)

---
    student1.grades[0] += 5;
    assert($(HILITE student2).grades[0] == $(HILITE 70));
---

$(H6 $(IX @disable, postblit) Disabling postblit)

$(P
The postblit function can be disabled by $(C @disable) as well. Objects of such a type cannot be copied:
)

---
struct Archive {
// ...

    $(HILITE @disable this(this);)
}

// ...

    auto a = Archive("records");
    auto b = a;                     $(DERLEME_HATASI)
---

$(P
The compiler does not allow calling the disabled postblit function:
)

$(SHELL
Error: struct deneme.Archive is $(HILITE not copyable) because it is
annotated with @disable
)

$(H5 $(IX assignment operator) $(IX =) $(IX opAssign) Assignment operator)

$(P
Assigment is giving a new value to an existing object:
)

---
    returnTripDuration = tripDuration;  // assignment
---

$(P
Assignment is more complicated from the other special operations because it is actually a combination of two operations:
)

$(UL
$(LI Destroying the left-hand side object)
$(LI Copying the right-hand side object to the left-hand side object)
)

$(P
However, applying those two steps in that order is risky because the original object would be destroyed before knowing that copying will succeed. Otherwise, an exception that is thrown during the copy operation can leave the left-hand side object in an inconsistent state: fully destroyed but not completely copied.
)

$(P
For that reason, the compiler-generated assignment operator acts safely by applying the following steps:
)

$(OL

$(LI Copy the right-hand side object to a temporary object

$(P
This is the actual copying half of the assignment operation. Since there is no change to the left-hand side object yet, it will remain intact if an exception is thrown during this copy operation.
)

)

$(LI Destroy the left-hand side object

$(P
This is the other half of the assignment operation.
)

)

$(LI Transfer the temporary object to the left-hand side object

$(P
No postblit nor a destructor is executed during or after this step. As a result, the left-hand side object becomes the equivalent of the temporary object.
)

)

)

$(P
After the steps above, the temporary object disappears and only the right-hand side object and its copy (i.e. the left-hand side object) remain.
)

$(P
Although the compiler-generated assignment operator is suitable in most cases, it can be defined by the programmer. When you do that, consider potential exceptions and write the assignment operator in a way that works even at the presence of thrown exceptions.
)

$(P
The syntax of the assignment operator is the following:
)

$(UL
$(LI The name of the function is $(C opAssign).)
$(LI The type of the parameter is the same as the $(C struct) type. This parameter is often named as $(C rhs), short for $(I right-hand side).)
$(LI The return type is the same as the $(C struct) type.)
$(LI The function is exited by $(C return this).)
)

$(P
As an example, let's consider a simple $(C Duration) struct where the assignment operator prints a message:
)

---
struct Duration {
    int minute;

    $(HILITE Duration) opAssign($(HILITE Duration) rhs) {
        writefln("minute is being changed from %s to %s",
                 this.minute, rhs.minute);

        this.minute = rhs.minute;

        $(HILITE return this;)
    }
}
// ...
    auto duration = Duration(100);
    duration = Duration(200);          // assignment
---

$(P
The output:
)

$(SHELL
minute is being changed from 100 to 200
)

$(H6 Assigning from other types)

$(P
Sometimes it is convenient to assign values of types that are different from the type of the $(C struct). For example, instead of requiring a $(C Duration) object on the right-hand side, it may be useful to assign from an integer:
)

---
    duration = 300;
---

$(P
This is possible by defining another assignment operator that takes an $(C int) parameter:
)

---
struct Duration {
    int minute;

    Duration opAssign(Duration rhs) {
        writefln("minute is being changed from %s to %s",
                 this.minute, rhs.minute);

        this.minute = rhs.minute;

        return this;
    }

    Duration opAssign($(HILITE int minute)) {
        writefln("minute is being replaced by an int");

        this.minute = minute;

        return this;
    }
}
// ...
    duration = Duration(200);
    duration = $(HILITE 300);
---

$(P
The output:
)

$(SHELL
minute is being changed from 100 to 200
minute is being replaced by an int
)

$(P
$(B Note:) Although convenient, assigning different types to each other may cause confusions and errors.
)

$(H5 Summary)

$(UL

$(LI Constructor ($(C this)) is for preparing objects for use. The compiler-generated default constructor is sufficient in most cases.)

$(LI The behavior of the default constructor may not be changed in structs; $(C static opCall) can be used instead.)

$(LI Single-parameter constructors can be used during type conversions by $(C to) and $(C cast).)

$(LI Destructor ($(C ~this)) is for the operations that must be executed when the lifetimes of objects end.)

$(LI Postblit ($(C this(this))) is for adjustments to the object after the automatic member copies.)

$(LI Assigment operator ($(C opAssign)) is for changing values of existing objects.)

)

Macros:
        TITLE=Constructor and Other Special Functions

        DESCRIPTION=Four special functions of structs and classes: constructor, destructor, postblit, and assignment operator.

        KEYWORDS=d programming lesson book tutorial constructor destructor postblit assignment
