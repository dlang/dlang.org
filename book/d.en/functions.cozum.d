Ddoc

$(COZUM_BOLUMU Functions)

$(OL

$(LI

---
import std.stdio;

void printMenu(string[] items, int firstNumber) {
    foreach (i, item; items) {
        writeln(' ', i + firstNumber, ' ', item);
    }
}

void main() {
    string[] items =
        [ "Black", "Red", "Green", "Blue", "White" ];
    printMenu(items, 1);
}
---

)

$(LI
Here are some ideas:

$(UL

$(LI Write a function named $(C drawHorizontalLine()) to draw horizontal lines.)

$(LI Write a function named $(C drawSquare()) to draw squares. This function could take advantage of $(C drawVerticalLine()) and $(C drawHorizontalLine()) when drawing the square.)

$(LI Improve the functions to also take the character that is used when "drawing". This would allow drawing each shape with a different character:

---
void putDot(Canvas canvas, int line, int column$(HILITE , dchar dot)) {
    canvas[line][column] = $(HILITE dot);
}
---

)

)

)

)

Macros:
        TITLE=Functions Solutions

        DESCRIPTION=Programming in D exercise solutions: functions

        KEYWORDS=programming in d tutorial functions
