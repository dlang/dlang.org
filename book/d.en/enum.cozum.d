Ddoc

$(COZUM_BOLUMU $(C enum))

---
import std.stdio;
import std.conv;

enum Operation { exit, add, subtract, multiply, divide }

void main() {
    // Print the supported operations
    write("Operations - ");
    for (Operation operation;
         operation <= Operation.max;
         ++operation) {

        writef("%d:%s ", operation, operation);
    }
    writeln();

    // Unconditional loop until the user wants to exit
    while (true) {
        write("Operation? ");

        // The input must be read in the actual type (int) of
        // the enum
        int operationCode;
        readf(" %s", &operationCode);

        /* We will start using enum values instead of magic
         * constants from this point on. So, the operation code
         * that has been read in int must be converted to its
         * corresponding enum value.
         *
         * (Type conversions will be covered in more detail in
         * a later chapter.) */
        Operation operation = cast(Operation)operationCode;

        if ((operation < Operation.min) ||
            (operation > Operation.max)) {
            writeln("ERROR: Invalid operation");
            continue;
        }

        if (operation == Operation.exit) {
            writeln("Goodbye!");
            break;
        }

        double first;
        double second;
        double result;

        write(" First operand? ");
        readf(" %s", &first);

        write("Second operand? ");
        readf(" %s", &second);

        switch (operation) {

        case Operation.add:
            result = first + second;
            break;

        case Operation.subtract:
            result = first - second;
            break;

        case Operation.multiply:
            result = first * second;
            break;

        case Operation.divide:
            result = first / second;
            break;

        default:
            throw new Exception(
                "ERROR: This line should have never been reached.");
        }

        writeln("        Result: ", result);
    }
}
---

Macros:
        TITLE=enum Solutions

        DESCRIPTION=Programming in D exercise solutions: enum

        KEYWORDS=programming in d tutorial enum
