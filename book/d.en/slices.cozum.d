Ddoc

$(COZUM_BOLUMU Slices and Other Array Features)

$(P
Iterating over elements by consuming a slice from the beginning is an interesting concept. This method is also the basis of Phobos ranges that we will see in a later chapter.
)

---
import std.stdio;

void main() {
    double[] array = [ 1, 20, 2, 30, 7, 11 ];

    double[] slice = array;    // Start with a slice that
                               // provides access to all of
                               // the elements of the array

    while (slice.length) {     // As long as there is at least
                               // one element in that slice

        if (slice[0] > 10) {   // Always use the first element
            slice[0] /= 2;     // in the expressions
        }

        slice = slice[1 .. $]; // Shorten the slice from the
                               // beginning
    }

    writeln(array);            // The actual elements are
                               // changed
}
---

Macros:
        TITLE=Slices and Other Array Features Solution

        DESCRIPTION=Programming in D exercise solutions: arrays

        KEYWORDS=programming in d tutorial arrays solution
