Ddoc

$(COZUM_BOLUMU Associative Arrays)

$(OL

$(LI

$(UL

$(LI
The $(C .keys) property returns a slice (i.e. dynamic array) that includes all of the keys of the associative array. Iterating over this slice and removing the element for each key by calling $(C .remove) would result in an empty associative array:

---
import std.stdio;

void main() {
    string[int] names =
    [
        1   : "one",
        10  : "ten",
        100 : "hundred",
    ];

    writeln("Initial length: ", names.length);

    int[] keys = names.keys;

    /* 'foreach' is similar but superior to 'for'. We will
     * see the 'foreach' loop in the next chapter. */
    foreach (key; keys) {
        writefln("Removing the element %s", key);
        names.remove(key);
    }

    writeln("Final length: ", names.length);
}
---

$(P
That solution may be slow especially for large arrays. The following methods would empty the array in a single step.
)

)

$(LI
Another solution is to assign an empty array:

---
    string[int] emptyAA;
    names = emptyAA;
---

)

$(LI
Since the initial value of an array is an empty array anyway, the following technique would achieve the same result:

---
    names = names.init;
---

)

)

)

$(LI
The goal is to store multiple grades per student. Since multiple grades can be stored in a dynamic array, an associative array that maps from $(C string) to $(C int[]) would work here. The grades can be appended to the dynamic arrays that are stored in the associative array:

---
import std.stdio;

void main() {
    /* The key type of this associative array is string and
     * the value type is int[], i.e. an array of ints. The
     * associative array is being defined with an extra
     * space in between to help distinguish the value type: */
    int[] [string] grades;

    /* The array of ints that correspond to "emre" is being
     * used for appending the new grade to that array: */
    grades["emre"] ~= 90;
    grades["emre"] ~= 85;

    /* Printing the grades of "emre": */
    writeln(grades["emre"]);
}
---

$(P
The grades can also be assigned in one go with an array literal:
)

---
import std.stdio;

void main() {
    int[][string] grades;

    grades["emre"] = [ 90, 85, 95 ];

    writeln(grades["emre"]);
}
---

)

)

Macros:
        TITLE=Associative Arrays Solutions

        DESCRIPTION=Programming in D exercise solutions: Associative Arrays

        KEYWORDS=programming in d tutorial associative arrays
