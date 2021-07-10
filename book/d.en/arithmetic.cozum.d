Ddoc

$(COZUM_BOLUMU Integers and Arithmetic Operations)

$(OL

$(LI
We can use the $(C /) operator for the division and the $(C %) operator for the remainder:

---
import std.stdio;

void main() {
    int first;
    write("Please enter the first number: ");
    readf(" %s", &first);

    int second;
    write("Please enter the second number: ");
    readf(" %s", &second);

    int quotient = first / second;
    int remainder = first % second;

    writeln(first, " = ",
            second, " * ", quotient, " + ", remainder);
}
---

)

$(LI
We can determine whether the remainder is 0 or not with an $(C if) statement:

---
import std.stdio;

void main() {
    int first;
    write("Please enter the first number: ");
    readf(" %s", &first);

    int second;
    write("Please enter the second number: ");
    readf(" %s", &second);

    int quotient = first / second;
    int remainder = first % second;

    // We cannot call writeln up front before determining
    // whether the remainder is 0 or not. We must terminate
    // the line later with a writeln.
    write(first, " = ", second, " * ", quotient);

    // The remainder must be printed only if nonzero.
    if (remainder != 0) {
        write(" + ", remainder);
    }

    // We are now ready to terminate the line.
    writeln();
}
---

)

$(LI

---
import std.stdio;

void main() {
    while (true) {
        write("0: Exit, 1: Add, 2: Subtract, 3: Multiply,",
              " 4: Divide - Please enter the operation: ");

        int operation;
        readf(" %s", &operation);

        // Let's first validate the operation
        if ((operation < 0) || (operation > 4)) {
            writeln("I don't know this operation");
            continue;
        }

        if (operation == 0){
            writeln("Goodbye!");
            break;
        }

        // If we are here, we know that we are dealing with
        // one of the four operations. Now is the time to read
        // two integers from the user:

        int first;
        int second;

        write(" First number: ");
        readf(" %s", &first);

        write("Second number: ");
        readf(" %s", &second);

        int result;

        if (operation == 1) {
            result = first + second;

        } else if (operation == 2) {
            result = first - second;

        } else if (operation == 3) {
            result = first * second;

        } else if (operation == 4) {
            result = first / second;

        }  else {
            writeln(
                "There is an error! ",
                "This condition should have never occurred.");
            break;
        }

        writeln("       Result: ", result);
    }
}
---

)

$(LI

---
import std.stdio;

void main() {
    int value = 1;

    while (value <= 10) {
        if (value != 7) {
            writeln(value);
        }

        ++value;
    }
}
---

)

)
$(Ergin)

Macros:
        TITLE=Integers and Arithmetic Operations Solutions

        DESCRIPTION=Programming in D exercise solutions: integers and arithmetic operations

        KEYWORDS=programming in d tutorial arithmetic operations
