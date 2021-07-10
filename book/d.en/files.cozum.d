Ddoc

$(COZUM_BOLUMU Files)

---
import std.stdio;
import std.string;

void main() {
    write("Please enter the name of the file to read from: ");
    string inFileName = strip(readln());
    File inFile = File(inFileName, "r");

    string outFileName = inFileName ~ ".out";
    File outFile = File(outFileName, "w");

    while (!inFile.eof()) {
        string line = strip(inFile.readln());

        if (line.length != 0) {
            outFile.writeln(line);
        }
    }

    writeln(outFileName, " has been created.");
}
---

Macros:
        TITLE=Files Solutions

        DESCRIPTION=Programming in D exercise solutions: basic file operations

        KEYWORDS=programming in d tutorial files
