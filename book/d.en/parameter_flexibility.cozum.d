Ddoc

$(COZUM_BOLUMU Variable Number of Parameters)

$(P
For the $(C calculate()) function to be able to take variable number of parameters, its parameter list must include a slice of $(C Calculation) followed by $(C ...):
)

---
double[] calculate(Calculation[] calculations...) {
    double[] results;

    foreach (calculation; calculations) {
        final switch (calculation.op) {

        case Operation.add:
            results ~= calculation.first + calculation.second;
            break;

        case Operation.subtract:
            results ~= calculation.first - calculation.second;
            break;

        case Operation.multiply:
            results ~= calculation.first * calculation.second;
            break;

        case Operation.divide:
            results ~= calculation.first / calculation.second;
            break;
        }
    }

    return results;
}
---

$(P
Each calculation is evaluated inside a loop and their results are appended to a slice of type $(C double[]).
)

$(P
Here is the entire program:
)

---
import std.stdio;

enum Operation { add, subtract, multiply, divide }

struct Calculation {
    Operation op;
    double first;
    double second;
}

double[] calculate(Calculation[] calculations...) {
    double[] results;

    foreach (calculation; calculations) {
        final switch (calculation.op) {

        case Operation.add:
            results ~= calculation.first + calculation.second;
            break;

        case Operation.subtract:
            results ~= calculation.first - calculation.second;
            break;

        case Operation.multiply:
            results ~= calculation.first * calculation.second;
            break;

        case Operation.divide:
            results ~= calculation.first / calculation.second;
            break;
        }
    }

    return results;
}

void main() {
    writeln(calculate(Calculation(Operation.add, 1.1, 2.2),
                      Calculation(Operation.subtract, 3.3, 4.4),
                      Calculation(Operation.multiply, 5.5, 6.6),
                      Calculation(Operation.divide, 7.7, 8.8)));
}
---

$(P
The output:
)

$(SHELL
[3.3, -1.1, 36.3, 0.875]
)

Macros:
        TITLE=Variable Number of Parameters

        DESCRIPTION=Exercise solutions of the 'Variable Number of Parameters' chapter of the tutorial book 'Programming in D'.

        KEYWORDS=d programming book tutorial variadic functions exercise solutions
