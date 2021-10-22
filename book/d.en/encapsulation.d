Ddoc

$(DERS_BOLUMU Encapsulation and Protection Attributes)

$(P
All of the structs and classes that we have defined so far have all been accessible from the $(I outside).
)

$(P
Let's consider the following struct:
)

---
enum Gender { female, male }

struct Student {
    string name;
    Gender gender;
}
---

$(P
The members of that struct is freely accessible to the rest of the program:
)

---
    auto student = Student("Tim", Gender.male);
    writefln("%s is a %s student.", student$(HILITE .name), student$(HILITE .gender));
---

$(P
Such freedom is a convenience in programs. For example, the previous line has been useful to produce the following output:
)

$(SHELL_SMALL
Tim is a male student.
)

$(P
However, this freedom is also a liability. As an example, let's assume that perhaps by mistake, the name of a student object gets modified in the program:
)

---
    student.name = "Anna";
---

$(P
That assignment may put the object in an invalid state:
)

$(SHELL_SMALL
$(HILITE Anna) is a $(HILITE male) student.
)

$(P
As another example, let's consider a $(C School) class. Let's assume that this class has two member variables that store the numbers of the male and female students separately:
)

---
class School {
    Student[] students;
    size_t femaleCount;
    size_t maleCount;

    void add(Student student) {
        students ~= student;

        final switch (student.gender) {

        case Gender.female:
            $(HILITE ++femaleCount);
            break;

        case Gender.male:
            $(HILITE ++maleCount);
            break;
        }
    }

    override string toString() const {
        return format("%s female, %s male; total %s students",
                      femaleCount, maleCount, students.length);
    }
}
---

$(P
The $(C add()) member function adds students while ensuring that the counts are always correct:
)

---
    auto school = new School;
    school.add(Student("Lindsey", Gender.female));
    school.add(Student("Mark", Gender.male));
    writeln(school);
---

$(P
The program produces the following consistent output:
)

$(SHELL_SMALL
1 female, 1 male; total 2 students
)

$(P
However, being able to access the members of $(C School) freely would not guarantee that this consistency would always be maintained. Let's consider adding a new element to the $(C students) member, this time directly:
)

---
    school$(HILITE .students) ~= Student("Nancy", Gender.female);
---

$(P
Because the new student has been added to the array directly, without going through the $(C add()) member function, the $(C School) object is now in an inconsistent state:
)

$(SHELL_SMALL
$(HILITE 1) female, $(HILITE 1) male; total $(HILITE 3) students
)

$(H5 $(IX encapsulation) Encapsulation)

$(P
Encapsulation is a programming concept of restricting access to members to avoid problems similar to the one above.
)

$(P
Another benefit of encapsulation is to eliminate the need to know the implementation details of types. In a sense, encapsulation allows presenting a type as a black box that is used only through its interface.
)

$(P
Additionally, preventing users from accessing the members directly allows changing the members of a class freely in the future. As long as the functions that define the interface of a class is kept the same, its implementation can be changed freely.
)

$(P
Encapsulation is not for restricting access to sensitive data like a credit card number or a password, and it cannot be used for that purpose. Encapsulation is a development tool: It allows using and coding types easily and safely.
)

$(H5 $(IX protection) $(IX access protection) Protection attributes)

$(P
Protection attributes limit access to members of structs, classes, and modules. There are two ways of specifying protection attributes:
)

$(UL

$(LI
At struct or class level to specify the protection of every struct or class member individually.
)

$(LI
At module level to specify the protection of every feature of a module individually: class, struct, function, enum, etc.
)

)

$(P
Protection attributes can be specified by the following keywords. The default attribute is $(C public).
)

$(UL

$(LI
$(IX public)
$(C public): Specifies accessibility by any part of the program without any restriction.

$(P
An example of this is $(C stdout). Merely importing $(C std.stdio) makes $(C stdout) available to every module that imported it.
)

)

$(LI
$(IX private)
$(C private): Specifies restricted accessibility.

$(P
$(C private) class members and module members can only be accessed by the module that defines that member.
)

$(P
Additionally, $(C private) member functions cannot be overridden by subclasses.
)

)

$(LI
$(IX package, protection)
$(C package): Specifies package-level accessibility.

$(P
A feature that is marked as $(C package) can be accessed by all of the code that is a part of the same package. The $(C package) attribute involves only the inner-most package.
)

$(P
For example, a $(C package) definition that is inside the $(C animal.vertebrate.cat) module can be accessed by any other module of the $(C vertebrate) package.
)

$(P
Similar to the $(C private) attribute, $(C package) member functions cannot be overridden by subclasses.
)

)

$(LI
$(IX protected)
$(C protected): Specifies accessibility by derived classes.

$(P
This attribute extends the $(C private) attribute: A $(C protected) member can be accessed not only by the module that defines it, but also by the classes that inherit from the class that defines that $(C protected) member.
)

)

)

$(P
$(IX export) Additionally, the $(C export) attribute specifies accessibility from the outside of the program.
)

$(H5 Definition)

$(P
Protection attributes can be specified in three ways.
)

$(P
When written in front of a single definition, it specifies the protection attribute of that definition only. This is similar to the Java programming language:
)

---
private int foo;

private void bar() {
    // ...
}
---

$(P
When specified by a colon, it specifies the protection attributes of all of the following definitions until the next specification of a protection attribute. This is similar to the C++ programming language:
)

---
private:
    // ...
    // ... all of the definitions here are private ...
    // ...

protected:
    // ...
    // ... all of the definitions here are protected ...
    // ...
---

$(P
When specified for a block, the protection attribute is for all of the definitions that are inside that block:
)

---
private {
    // ...
    // ... all of the definitions here are private ...
    // ...
}
---

$(H5 Module imports are private by default)

$(P
A module that is imported by $(C import) is private to the module that imports it. It would not be visible to other modules that import it indirectly. For example, if a $(C school) module imports $(C std.stdio), modules that import $(C school) cannot automatically use the $(C std.stdio) module.
)

$(P
Let's assume that the $(C school) module starts by the following lines:
)

---
module school.school;

import std.stdio;    // imported for this module's own use...

// ...
---

$(P
The following program cannot be compiled because $(C writeln) is not visible to it:
)

---
import school.school;

void main() {
    writeln("hello");    $(DERLEME_HATASI)
}
---

$(P
$(C std.stdio) must be imported by that module as well:
)

---
import school.school;
$(HILITE import std.stdio;)

void main() {
    writeln("hello");   // now compiles
}
---

$(P
$(IX public import) $(IX import, public) Sometimes it is desired that a module presents other modules indirectly. For example, it would make sense for a $(C school) module to automatically import a $(C student) module for its users. This is achieved by marking the $(C import) as $(C public):
)

---
module school.school;

$(HILITE public import) school.student;

// ...
---

$(P
With that definition, modules that import $(C school) can use the definitions that are inside the $(C student) module without needing to import it:
)

---
import school.school;

void main() {
    auto student = Student("Tim", Gender.male);

    // ...
}
---

$(P
Although the program above imports only the $(C school) module, the $(C student.Student) struct is also available to it.
)

$(H5 When to use encapsulation)

$(P
Encapsulation avoids problems similar to the one we have seen in the introduction section of this chapter. It is an invaluable tool to ensure that objects are always in consistent states. Encapsulation helps preserve struct and class $(I invariants) by protecting members from direct modifications by the users of the type.
)

$(P
Encapsulation provides freedom of implementation by abstracting implementations away from user code. Otherwise, if users had direct access to for example $(C School.students), it would be hard to modify the design of the class by changing that array e.g. to an associative array, because this would affect all user code that has been accessing that member.
)

$(P
Encapsulation is one of the most powerful benefits of object oriented programming.
)

$(H5 Example)

$(P
Let's define the $(C Student) struct and the $(C School) class by taking advantage of encapsulation and let's use them in a short test program.
)

$(P
This example program will consist of three files. As you remember from the previous chapter, being parts of the $(C school) package, two of these files will be under the "school" directory:
)

$(UL
$(LI "school/student.d": The $(C student) module that defines the $(C Student) struct)
$(LI "school/school.d": The $(C school) module that defines the $(C School) class)
$(LI "deneme.d": A short test program)
)

$(P
Here is the "school/student.d" file:
)

---
module school.student;

import std.string;
import std.conv;

enum Gender { female, male }

struct Student {
    $(HILITE package) string name;
    $(HILITE package) Gender gender;

    string toString() const {
        return format("%s is a %s student.",
                      name, to!string(gender));
    }
}
---

$(P
The members of this struct are marked as $(C package) to enable access only to modules of the same package. We will soon see that $(C School) will be accessing these members directly. (Note that even this should be considered as violating the principle of encapsulation. Still, let's stick with the $(C package) attribute in this example program.)
)

$(P
The following is the "school/school.d" module that makes use of the previous one:
)

---
module school.school;

$(HILITE public import) school.student;                  // 1

import std.string;

class School {
$(HILITE private:)                                       // 2

    Student[] students;
    size_t femaleCount;
    size_t maleCount;

$(HILITE public:)                                        // 3

    void add(Student student) {
        students ~= student;

        final switch (student$(HILITE .gender)) {        // 4a

        case Gender.female:
            ++femaleCount;
            break;

        case Gender.male:
            ++maleCount;
            break;
        }
    }

    override string toString() const {
        string result = format(
            "%s female, %s male; total %s students",
            femaleCount, maleCount, students.length);

        foreach (i, student; students) {
            result ~= (i == 0) ? ": " : ", ";
            result ~= student$(HILITE .name);            // 4b
        }

        return result;
    }
}
---

$(OL

$(LI
$(C school.student) is being imported publicly so that the users of $(C school.school) will not need to import that module explicitly. In a sense, the $(C student) module is made available by the $(C school) module.
)

$(LI
All of the member variables of $(C School) are marked as private. This is important to help protect the consistency of the member variables of this class.
)

$(LI
For this class to be useful, it must present some member functions. $(C add()) and $(C toString()) are made available to the users of this class.
)

$(LI
As the two member variables of $(C Student) have been marked as $(C package), being a part of the same package, $(C School) can access those variables.
)

)

$(P
Finally, the following is a test program that uses those types:
)

---
import std.stdio;
import school.school;

void main() {
    auto student = Student("Tim", Gender.male);
    writeln(student);

    auto school = new School;

    school.add(Student("Lindsey", Gender.female));
    school.add(Student("Mark", Gender.male));
    school.add(Student("Nancy", Gender.female));

    writeln(school);
}
---

$(P
This program can use $(C Student) and $(C School) only through their public interfaces. It cannot access the member variables of those types. As a result, the objects would always be consistent:
)

$(SHELL_SMALL
Tim is a male student.
2 female, 1 male; total 3 students: Lindsey, Mark, Nancy
)

$(P
Note that the program interacts with $(C School) only by its $(C add()) and $(C toString()) functions. As long as the interfaces of these functions are kept the same, changes in their implementations would not affect the program above.
)

Macros:
        TITLE=Encapsulation and Protection Attributes

        DESCRIPTION=Encapsulating data by the protection attributes of D.

        KEYWORDS=d programming lesson book tutorial encapsulation
