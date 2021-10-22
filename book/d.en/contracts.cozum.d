Ddoc

$(COZUM_BOLUMU Contract Programming)

$(P
The $(C unittest) block can be implemented trivially by copying the checks that are already written in $(C main()). The only addition below is the test for the case when the second team wins:
)

---
int addPoints(int goals1, int goals2,
              ref int points1, ref int points2)
in {
    assert(goals1 >= 0);
    assert(goals2 >= 0);
    assert(points1 >= 0);
    assert(points2 >= 0);

} out (result) {
    assert((result >= 0) && (result <= 2));

} do {
    int winner;

    if (goals1 > goals2) {
        points1 += 3;
        winner = 1;

    } else if (goals1 < goals2) {
        points2 += 3;
        winner = 2;

    } else {
        ++points1;
        ++points2;
        winner = 0;
    }

    return winner;
}

unittest {
    int points1 = 10;
    int points2 = 7;
    int winner;

    // First team wins
    winner = addPoints(3, 1, points1, points2);
    assert(points1 == 13);
    assert(points2 == 7);
    assert(winner == 1);

    // Draw
    winner = addPoints(2, 2, points1, points2);
    assert(points1 == 14);
    assert(points2 == 8);
    assert(winner == 0);

    // Second team wins
    winner = addPoints(0, 1, points1, points2);
    assert(points1 == 14);
    assert(points2 == 11);
    assert(winner == 2);
}

void main() {
    // ...
}
---

$(P
Expression-based contracts can be useful for this function:
)

---
int addPoints(int goals1, int goals2,
              ref int points1, ref int points2)
in (goals1 >= 0)
in (goals2 >= 0)
in (points1 >= 0)
in (points2 >= 0)
out (result; (result >= 0) && (result <= 2)) {
    // ...
}
---

Macros:
        TITLE=Contract Programming

        DESCRIPTION=The exercise solutions for the Contract Programming chapter, explaining the features of D that help with program correctness.

        KEYWORDS=programming in d tutorial unit testing
