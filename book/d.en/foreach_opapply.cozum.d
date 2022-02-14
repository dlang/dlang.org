Ddoc

$(COZUM_BOLUMU $(CH4 foreach) with Structs and Classes)

$(OL

$(LI The step size must be stored alongside $(C begin) and $(C end), and the element value must be increased by that step size:

---
struct NumberRange {
    int begin;
    int end;
    $(HILITE int stepSize;)

    int opApply(int delegate(ref int) dg) const {
        int result;

        for (int number = begin; number != end; $(HILITE number += stepSize)) {
            result = dg(number);

            if (result) {
                break;
            }
        }

        return result;
    }
}

import std.stdio;

void main() {
    foreach (element; NumberRange(0, 10, 2)) {
        write(element, ' ');
    }
}
---

)

$(LI

---
import std.stdio;
import std.string;

class Student {
    string name;
    int id;

    this(string name, int id) {
        this.name = name;
        this.id = id;
    }

    override string toString() {
        return format("%s(%s)", name, id);
    }
}

class Teacher {
    string name;
    string subject;

    this(string name, string subject) {
        this.name = name;
        this.subject = subject;
    }

    override string toString() {
        return format("%s teacher %s", subject, name);
    }
}

class School {
private:

    Student[] students;
    Teacher[] teachers;

public:

    this(Student[] students, Teacher[] teachers) {
        this.students = students;
        this.teachers = teachers;
    }

    /* This opApply override will be called when the foreach
     * variable is a Student. */
    int opApply(int delegate(ref $(HILITE Student)) dg) {
        int result;

        foreach (student; students) {
            result = dg(student);

            if (result) {
                break;
            }
        }

        return result;
    }

    /* Similarly, this opApply will be called when the foreach
     * variable is a Teacher. */
    int opApply(int delegate(ref $(HILITE Teacher)) dg) {
        int result;

        foreach (teacher; teachers) {
            result = dg(teacher);

            if (result) {
                break;
            }
        }

        return result;
    }
}

void printIndented(T)(T value) {
    writeln("  ", value);
}

void main() {
    auto school = new School(
        [ new Student("Can", 1),
          new Student("Canan", 10),
          new Student("Cem", 42),
          new Student("Cemile", 100) ],

        [ new Teacher("Nazmiye", "Math"),
          new Teacher("Makbule", "Literature") ]);

    writeln("Student loop");
    foreach ($(HILITE Student) student; school) {
        printIndented(student);
    }

    writeln("Teacher loop");
    foreach ($(HILITE Teacher) teacher; school) {
        printIndented(teacher);
    }
}
---

$(P
The output:
)

$(SHELL
Student loop
  Can(1)
  Canan(10)
  Cem(42)
  Cemile(100)
Teacher loop
  Math teacher Nazmiye
  Literature teacher Makbule
)

$(P
As you can see, the implementations of both of the $(C opApply()) overrides are exactly the same, except the slice that they iterate on. To reduce code duplication, the common functionality can be moved to an implementation function template, which then gets called by the two $(C opApply()) overrides:
)

---
class School {
// ...

    int opApplyImpl$(HILITE (T))(T[] slice, int delegate(ref T) dg) {
        int result;

        foreach (element; slice) {
            result = dg(element);

            if (result) {
                break;
            }
        }

        return result;
    }

    int opApply(int delegate(ref Student) dg) {
        return opApplyImpl(students, dg);
    }

    int opApply(int delegate(ref Teacher) dg) {
        return opApplyImpl(teachers, dg);
    }
}
---

)

)

Macros:
        TITLE=foreach with Structs and Classes Solutions

        DESCRIPTION=Programming in D exercise solutions: foreach with structs and classes.

        KEYWORDS=programming in d tutorial foreach opApply
