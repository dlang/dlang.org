Ddoc

$(DERS_BOLUMU $(IX variable) Variables)

$(P
Concrete concepts that are represented in a program are called $(I variables). A value like $(I air temperature) and a more complicated object like $(I a car engine) can be variables of a program.
)

$(P
The main purpose of a variable is to represent a value in the program. The value of a variable is the last value that has been assigned to that variable. Since every value is of a certain type, every variable is of a certain type as well. Most variables have names as well, but some variables are anonymous.
)

$(P
As an example of a variable, we can think of the concept of $(I the number of students) at a school. Since the number of students is a whole number, $(C int) is a suitable type, and $(C studentCount) would be a sufficiently descriptive name.
)

$(P
According to D's syntax rules, a variable is introduced by its type followed by its name. The introduction of a variable to the program is called its $(I definition). Once a variable is defined, its name represents its value.
)

---
import std.stdio;

void main() {
    // The definition of the variable; this definition
    // specifies that the type of studentCount is int:
    int studentCount;

    // The name of the variable becomes its value:
    writeln("There are ", studentCount, " students.");
}
---

$(P
The output of this program is the following:
)

$(SHELL
There are 0 students.
)

$(P
As seen from that output, the value of $(C studentCount) is 0. This is according to the fundamental types table from the previous chapter: the initial value of $(C int) is 0.
)

$(P
Note that $(C studentCount) does not appear in the output as its name. In other words, the output of the program is not "There are studentCount students".
)

$(P
The values of variables are changed by the $(C =) operator. The $(C =) operator assigns new values to variables, and for that reason is called the $(I assignment operator):
)

---
import std.stdio;

void main() {
    int studentCount;
    writeln("There are ", studentCount, " students.");

    // Assigning the value 200 to the studentCount variable:
    studentCount $(HILITE =) 200;
    writeln("There are now ", studentCount, " students.");
}
---

$(SHELL
There are 0 students.
There are now 200 students.
)

$(P
When the value of a variable is known at the time of the variable's definition, the variable can be defined and assigned at the same time. This is an important guideline; it makes it impossible to use a variable before assigning its intended value:
)

---
import std.stdio;

void main() {
    // Definition and assignment at the same time:
    int studentCount = 100;

    writeln("There are ", studentCount, " students.");
}
---

$(SHELL
There are 100 students.
)

$(PROBLEM_TEK

$(P
Define two variables to print "I have exchanged 20 Euros at the rate of 2.11". You can use the floating point type $(C double) for the decimal value.
)

)


Macros:
        TITLE=Variables

        DESCRIPTION=The variables in the D programming language

        KEYWORDS=d programming language tutorial book variables

MINI_SOZLUK=
