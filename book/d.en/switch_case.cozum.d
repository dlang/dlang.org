Ddoc

$(COZUM_BOLUMU $(C switch) and $(C case))

$(OL

$(LI

---
import std.stdio;
import std.string;

void main() {
    string op;
    double first;
    double second;

    write("Please enter the operation: ");
    op = strip(readln());

    write("Please enter two values separated by a space: ");
    readf(" %s %s", &first, &second);

    double result;

    final switch (op) {

    case "add":
        result = first + second;
        break;

    case "subtract":
        result = first - second;
        break;

    case "multiply":
        result = first * second;
        break;

    case "divide":
        result = first / second;
        break;
    }

    writeln(result);
}
---

)

$(LI
By taking advantage of distinct $(C case) values:

---
    final switch (op) {

    case "add"$(HILITE , "+"):
        result = first + second;
        break;

    case "subtract"$(HILITE, "-"):
        result = first - second;
        break;

    case "multiply"$(HILITE, "*"):
        result = first * second;
        break;

    case "divide"$(HILITE, "/"):
        result = first / second;
        break;
    }
---

)

$(LI Since the $(C default) section is needed to throw the exception from, it cannot be a $(C final switch) statement anymore. Here are the parts of the program that are modified:

---
// ...

    switch (op) {

    // ...

    default:
        throw new Exception("Invalid operation: " ~ op);
    }

// ...
---

)

)

Macros:
        TITLE=switch and case Solutions

        DESCRIPTION=Programming in D exercise solutions: the switch statement

        KEYWORDS=programming in d tutorial switch case

