Ddoc

$(DERS_BOLUMU $(IX contract programming) Contract Programming)

$(P
Contract programming is a software design approach that treats parts of software as individual entities that provide services to each other. This approach realizes that software can work according to its specification as long as the provider and the consumer of the service both obey a $(I contract).
)

$(P
D's contract programming features involve functions as the units of software services. Like in unit testing, contract programming is also based on $(C assert) checks.
)

$(P
Contract programming in D is implemented by three types of code blocks:
)

$(UL
$(LI Function $(C in) blocks)
$(LI Function $(C out) blocks)
$(LI Struct and class $(C invariant) blocks)
)

$(P
We will see $(C invariant) blocks and $(I contract inheritance) in $(LINK2 invariant.html, a later chapter) after covering structs and classes.
)

$(H5 $(IX in, contract) $(IX precondition) $(C in) blocks for preconditions)

$(P
Correct execution of functions usually depend on whether the values of their parameters are valid. For example, a square root function may require that its parameter cannot be negative. A function that deals with dates may require that the number of the month must be between 1 and 12. Such requirements of a function are called its $(I preconditions).
)

$(P
We have already seen such condition checks in the $(LINK2 assert.html, $(C assert) and $(C enforce) chapter). Conditions on parameter values can be enforced by $(C assert) checks within function definitions:
)

---
string timeToString(int hour, int minute) {
    assert((hour >= 0) && (hour <= 23));
    assert((minute >= 0) && (minute <= 59));

    return format("%02s:%02s", hour, minute);
}
---

$(P
$(IX do, contract programming) In contract programming, the same checks are written inside the $(C in) blocks of functions. When an $(C in) or $(C out) block is used, the actual body of the function must be specified as a $(C do) block:
)

---
import std.stdio;
import std.string;

string timeToString(int hour, int minute)
$(HILITE in) {
    assert((hour >= 0) && (hour <= 23));
    assert((minute >= 0) && (minute <= 59));

} $(HILITE do) {
    return format("%02s:%02s", hour, minute);
}

void main() {
    writeln(timeToString(12, 34));
}
---

$(P
$(IX body) $(I $(B Note:) In earlier versions of D, the $(C body) keyword was used for this purpose instead of $(C do).)
)

$(P
A benefit of an $(C in) block is that all of the preconditions can be kept together and separate from the actual body of the function. This way, the function body would be free of $(C assert) checks about the preconditions. As needed, it is still possible and advisable to have other $(C assert) checks inside the function body as unrelated checks that guard against potential programming errors in the function body.
)

$(P
The code that is inside the $(C in) block is executed automatically every time the function is called. The actual execution of the function starts only if all of the $(C assert) checks inside the $(C in) block pass. This prevents executing the function with invalid preconditions and as a consequence, avoids producing incorrect results.
)

$(P
An $(C assert) check that fails inside the $(C in) block indicates that the contract has been violated by the caller.
)

$(H5 $(IX out, contract) $(IX postcondition) $(C out) blocks for postconditions)

$(P
The other side of the contract involves guarantees that the function provides. Such guarantees are called the function's $(I postconditions). An example of a function with a postcondition would be a function that returns the number of days in February: The function can guarantee that the returned value would always be either 28 or 29.
)

$(P
The postconditions are checked inside the $(C out) blocks of functions.
)

$(P
Because the value that a function returns by the $(C return) statement need not be defined as a variable inside the function, there is usually no name to refer to the return value. This can be seen as a problem because the $(C assert) checks inside the $(C out) block cannot refer to the returned variable by name.
)

$(P
D solves this problem by providing a way of naming the return value right after the $(C out) keyword. That name represents the very value that the function is in the process of returning:
)

---
int daysInFebruary(int year)
$(HILITE out (result)) {
    assert((result == 28) || (result == 29));

} do {
    return isLeapYear(year) ? 29 : 28;
}
---

$(P
Although $(C result) is a reasonable name for the returned value, other valid names may also be used.
)

$(P
Some functions do not have return values or the return value need not be checked. In that case the $(C out) block does not specify a name:
)

---
out {
    // ...
}
---

$(P
Similar to $(C in) blocks, the $(C out) blocks are executed automatically after the body of the function is executed.
)

$(P
An $(C assert) check that fails inside the $(C out) block indicates that the contract has been violated by the function.
)

$(P
As it has been obvious, $(C in) and $(C out) blocks are optional. Considering the $(C unittest) blocks as well, which are also optional, D functions may consist of up to four blocks of code:
)

$(UL
$(LI $(C in): Optional)

$(LI $(C out): Optional)

$(LI $(C do): Mandatory but the $(C do) keyword may be skipped if no $(C in) or $(C out) block is defined.)

$(LI $(C unittest): Optional and technically not a part of a function's definition but commonly defined right after the function.)
)

$(P
Here is an example that uses all of these blocks:
)

---
import std.stdio;

/* Distributes the sum between two variables.
 *
 * Distributes to the first variable first, but never gives
 * more than 7 to it. The rest of the sum is distributed to
 * the second variable. */
void distribute(int sum, out int first, out int second)
in {
    assert(sum >= 0, "sum cannot be negative");

} out {
    assert(sum == (first + second));

} do {
    first = (sum >= 7) ? 7 : sum;
    second = sum - first;
}

unittest {
    int first;
    int second;

    // Both must be 0 if the sum is 0
    distribute(0, first, second);
    assert(first == 0);
    assert(second == 0);

    // If the sum is less than 7, then all of it must be given
    // to first
    distribute(3, first, second);
    assert(first == 3);
    assert(second == 0);

    // Testing a boundary condition
    distribute(7, first, second);
    assert(first == 7);
    assert(second == 0);

    // If the sum is more than 7, then the first must get 7
    // and the rest must be given to second
    distribute(8, first, second);
    assert(first == 7);
    assert(second == 1);

    // A random large value
    distribute(1_000_007, first, second);
    assert(first == 7);
    assert(second == 1_000_000);
}

void main() {
    int first;
    int second;

    distribute(123, first, second);
    writeln("first: ", first, " second: ", second);
}
---

$(P
The program can be compiled and run on the terminal by the following commands:
)

$(SHELL
$ dmd deneme.d -w -unittest
$ ./deneme
$(SHELL_OBSERVED first: 7 second: 116)
)

$(P
Although the actual work of the function consists of only two lines, there are a total of 19 nontrivial lines that support its functionality. It may be argued that so much extra code is too much for such a short function. However, bugs are never intentional. The programmer always writes code that is $(I expected to work correctly), which commonly ends up containing various types of bugs.
)

$(P
When expectations are laid out explicitly by unit tests and contracts, functions that are initially correct have a greater chance of staying correct. I recommend that you take full advantage of any feature that improves program correctness. Both unit tests and contracts are effective tools toward that goal. They help reduce time spent for debugging, effectively increasing time spent for actually writing code.
)

$(H5 $(IX expression-based contracts) Expression-based contracts)

$(P
Although $(C in) and $(C out) blocks are useful for allowing any D code, precondition and postcondition checks are usually not more than simple $(C assert) expressions. As a convenience in such cases, there is a shorter expression-based contract syntax. Let's consider the following function:
)

---
int func(int a, int b)
in {
    assert(a >= 7, "a cannot be less than 7");
    assert(b < 10);

} out (result) {
    assert(result > 1000);

} do {
    // ...
}
---

$(P
The expression-based contract obviates curly brackets, explicit $(C assert) calls, and the $(C do) keyword:
)

---
int func(int a, int b)
in (a >= 7, "a cannot be less than 7")
in (b < 10)
out ($(HILITE result;) result > 1000) {
    // ...
}
---

$(P
Note how the return value of the function is named before a semicolon in the $(C out) contract. When there is no return value or when the $(C out) contract does not refer to the return value, the semicolon must still be present:
)

---
out ($(HILITE ;) /* ... */)
---

$(H5 $(IX -release, compiler switch) Disabling contract programming)

$(P
Contrary to unit testing, contract programming features are enabled by default. The $(C &#8209;release) compiler switch disables contract programming:
)

$(SHELL
$ dmd deneme.d -w -release
)

$(P
When the program is compiled with the $(C &#8209;release) switch, the contents of $(C in), $(C out), and $(C invariant) blocks are ignored.
)

$(H5 $(IX in vs. enforce) $(IX enforce vs. in) $(IX assert vs. enforce) $(IX enforce vs. assert) $(C in) blocks versus $(C enforce) checks)

$(P
We have seen in the $(LINK2 assert.html, $(C assert) and $(C enforce) chapter) that sometimes it is difficult to decide whether to use $(C assert) or $(C enforce) checks. Similarly, sometimes it is difficult to decide whether to use $(C assert) checks within $(C in) blocks versus $(C enforce) checks within function bodies.
)

$(P
The fact that it is possible to disable contract programming is an indication that contract programming is for protecting against programmer errors. For that reason, the decision here should be based on the same guidelines that we saw in the $(LINK2 assert.html, $(C assert) and $(C enforce) chapter):
)

$(UL

$(LI
If the check is guarding against a coding error, then it should be in the $(C in) block. For example, if the function is called only from other parts of the program, likely to help with achieving a functionality of it, then the parameter values are entirely the responsibility of the programmer. For that reason, the preconditions of such a function should be checked in its $(C in) block.
)

$(LI
If the function cannot achieve some task for any other reason, including invalid parameter values, then it must throw an exception, conveniently by $(C enforce).

$(P
To see an example of this, let's define a function that returns a slice of the middle of another slice. Let's assume that this function is for the consumption of the users of the module, as opposed to being an internal function used by the module itself. Since the users of this module can call this function by various and potentially invalid parameter values, it would be appropriate to check the parameter values every time the function is called. It would be insufficient to only check them at program development time, after which contracts can be disabled by $(C &#8209;release).
)

$(P
For that reason, the following function validates its parameters by calling $(C enforce) in the function body instead of an $(C assert) check in the $(C in) block:
)

---
import std.exception;

inout(int)[] middle(inout(int)[] originalSlice, size_t width)
out (result) {
    assert(result.length == width);

} do {
    $(HILITE enforce)(originalSlice.length >= width);

    immutable start = (originalSlice.length - width) / 2;
    immutable end = start + width;

    return originalSlice[start .. end];
}

unittest {
    auto slice = [1, 2, 3, 4, 5];

    assert(middle(slice, 3) == [2, 3, 4]);
    assert(middle(slice, 2) == [2, 3]);
    assert(middle(slice, 5) == slice);
}

void main() {
}
---

$(P
There isn't a similar problem with the $(C out) blocks. Since the return value of every function is the responsibility of the programmer, postconditions must always be checked in the $(C out) blocks. The function above follows this guideline.
)

)

$(LI
Another criterion to consider when deciding between $(C in) blocks versus $(C enforce) is to consider whether the condition is recoverable. If it is recoverable by the higher layers of code, then it may be more appropriate to throw an exception, conveniently by $(C enforce).
)

)

$(PROBLEM_TEK

$(P
Write a program that increases the total points of two football (soccer) teams according to the result of a game.
)

$(P
The first two parameters of this function are the goals that each team has scored. The other two parameters are the points of each team before the game. This function should adjust the points of the teams according to the goals that they have scored. As a reminder, the winner takes 3 points and the loser takes no point. In the event of a draw, both teams get 1 point each.
)

$(P
Additionally, the function should indicate which team has been the winner: 1 if the first team has won, 2 if the second team has won, and 0 if the game has ended in a draw.
)

$(P
Start with the following program and fill in the four blocks of the function appropriately. Do not remove the $(C assert) checks in $(C main()); they demonstrate how this function is expected to work.
)

---
int addPoints(int goals1, int goals2,
              ref int points1, ref int points2)
in {
    // ...

} out (result) {
    // ...

} do {
    int winner;

    // ...

    return winner;
}

unittest {
    // ...
}

void main() {
    int points1 = 10;
    int points2 = 7;
    int winner;

    winner = addPoints(3, 1, points1, points2);
    assert(points1 == 13);
    assert(points2 == 7);
    assert(winner == 1);

    winner = addPoints(2, 2, points1, points2);
    assert(points1 == 14);
    assert(points2 == 8);
    assert(winner == 0);
}
---

$(P
Although I chose to return an $(C int), it would be better to return an $(C enum) value from this function:
)

---
enum GameResult {
    draw, firstWon, secondWon
}

$(HILITE GameResult) addPoints(int goals1, int goals2,
                     ref int points1, ref int points2)
// ...
---

)

Macros:
        TITLE=Contract Programming

        DESCRIPTION=The contract programming features of D that help with program correctness.

        KEYWORDS=d programming language tutorial book in out dbc
