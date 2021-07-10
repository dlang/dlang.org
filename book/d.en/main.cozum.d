Ddoc

$(COZUM_BOLUMU Program Environment)

$(OL

$(LI

---
import std.stdio;
import std.conv;

int main(string[] args) {
    if (args.length != 4) {
        stderr.writeln(
            "ERROR! Usage: \n    ", args[0],
            " a_number operator another_number");
        return 1;
    }

    immutable first = to!double(args[1]);
    string op = args[2];
    immutable second = to!double(args[3]);

    switch (op) {

    case "+":
        writeln(first + second);
        break;

    case "-":
        writeln(first - second);
        break;

    case "x":
        writeln(first * second);
        break;

    case "/":
        writeln(first / second);
        break;

    default:
        throw new Exception("Invalid operator: " ~ op);
    }

    return 0;
}
---

)

$(LI

---
import std.stdio;
import std.process;

void main() {
    write("Please enter the command line to execute: ");
    string commandLine = readln();

    writeln("The output: ", executeShell(commandLine));
}
---

)

)

Macros:
        TITLE=Program Environment Solutions

        DESCRIPTION=The exercise solutions for the Program Environment chapter.

        KEYWORDS=programming in d tutorial main environment
