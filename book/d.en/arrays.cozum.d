Ddoc

$(COZUM_BOLUMU Arrays)

$(OL

$(LI

---
import std.stdio;
import std.algorithm;

void main() {
    write("How many values will be entered? ");
    int count;
    readf(" %s", &count);

    double[] values;
    values.length = count;

    // The counter is commonly named as 'i'
    int i;
    while (i < count) {
        write("Value ", i, ": ");
        readf(" %s", &values[i]);
        ++i;
    }

    writeln("In sorted order:");
    sort(values);

    i = 0;
    while (i < count) {
        write(values[i], " ");
        ++i;
    }
    writeln();

    writeln("In reverse order:");
    reverse(values);

    i = 0;
    while (i < count) {
        write(values[i], " ");
        ++i;
    }
    writeln();
}
---

)

$(LI
The explanations are included as code comments:

---
import std.stdio;
import std.algorithm;

void main() {
    // Using dynamic arrays because it is not known how many
    // values are going to be read from the input
    int[] odds;
    int[] evens;

    writeln("Please enter integers (-1 to terminate):");

    while (true) {

        // Reading the value
        int value;
        readf(" %s", &value);

        // The special value of -1 breaks the loop
        if (value == -1) {
            break;
        }

        // Adding to the corresponding array, depending on
        // whether the value is odd or even. It is an even
        // number if there is no remainder when divided by 2.
        if ((value % 2) == 0) {
            evens ~= value;

        } else {
            odds ~= value;
        }
    }

    // The odds and evens arrays are sorted separately
    sort(odds);
    sort(evens);

    // The two arrays are then appended to form a new array
    int[] result;
    result = odds ~ evens;

    writeln("First the odds then the evens, sorted:");

    // Printing the array elements in a loop
    int i;
    while (i < result.length) {
        write(result[i], " ");
        ++i;
    }

    writeln();
}
---

)

$(LI
There are three mistakes (bugs) in this program. The first two are with the $(C while) loops: Both of the loop conditions use the $(C <=) operator instead of the $(C <) operator. As a result, the program uses invalid indexes and attempts to access elements that are not parts of the arrays.

$(P
Since it is more beneficial for you to debug the third mistake yourself, I would like you to first run the program after fixing the previous two bugs. You will notice that the program will not print the results. Can you figure out the remaining problem before reading the following paragraph?
)

$(P
The value of $(C i) is 5 when the first $(C while) loop terminates, and that value is causing the logical expression of the second loop to be $(C false), which in turn is preventing the second loop to be entered. The solution is to reset $(C i) to 0 before the second $(C while) loop, for example with the statement $(C i = 0;)
)

)

)

Macros:
        TITLE=Arrays Solutions

        DESCRIPTION=Programming in D exercise solutions: arrays

        KEYWORDS=programming in d tutorial arrays solution
