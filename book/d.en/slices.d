Ddoc

$(DERS_BOLUMU $(IX slice) $(IX array) Slices and Other Array Features)

$(P
We have seen in the $(LINK2 arrays.html, Arrays chapter) how elements are grouped as a collection in an array. That chapter was intentionally brief, leaving most of the features of arrays to this chapter.
)

$(P
Before going any further, here are a few brief definitions of some of the terms that happen to be close in meaning:
)

$(UL

$(LI $(B Array:) The general concept of a group of elements that are located side by side and are accessed by indexes.
)

$(LI
$(B Fixed-length array (static array):) An array with a fixed number of elements. This type of array owns its elements.
)

$(LI
$(B Dynamic array:) An array that can gain or lose elements. This type of array provides access to elements that are owned by the D runtime environment.
)

$(LI $(B Slice:) Another name for $(I dynamic array).
)

)

$(P
When I write $(I slice) I will specifically mean a slice; and when I write $(I array), I will mean either a slice or a fixed-length array, with no distinction.
)

$(H5 Slices)

$(P
Slices are the same feature as dynamic arrays. They are called $(I dynamic arrays) for being used like arrays, and are called $(I slices) for providing access to portions of other arrays. They allow using those portions as if they are separate arrays.
)

$(P
$(IX .., slice element range) Slices are defined by the $(I number range) syntax that correspond to the indexes that specify the beginning and the end of the range:
)

---
  $(I beginning_index) .. $(I one_beyond_the_end_index)
---

$(P
In the number range syntax, the beginning index is a part of the range but the end index is outside of the range:
)

---
/* ... */ = monthDays[0 .. 3];  // 0, 1, and 2 are included; but not 3
---

$(P
$(I $(B Note:) Number ranges are different from Phobos ranges. Phobos ranges are about struct and class interfaces. We will see these features in later chapters.
)
)

$(P
As an example, we can $(I slice) the $(C monthDays) array to be able to use its parts as four smaller arrays:
)

---
    int[12] monthDays =
        [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];

    int[] firstQuarter  = monthDays[0 .. 3];
    int[] secondQuarter = monthDays[3 .. 6];
    int[] thirdQuarter  = monthDays[6 .. 9];
    int[] fourthQuarter = monthDays[9 .. 12];
---

$(P
The four variables in the code above are slices; they provide access to four parts of an already existing array. An important point worth stressing here is that those slices do not have their own elements. They merely provide access to the elements of the actual array. Modifying an element of a slice modifies the element of the actual array. To see this, let's modify the first elements of each slice and then print the actual array:
)

---
    firstQuarter[0]  = 1;
    secondQuarter[0] = 2;
    thirdQuarter[0]  = 3;
    fourthQuarter[0] = 4;

    writeln(monthDays);
---

$(P
The output:
)

$(SHELL
[$(HILITE 1), 28, 31, $(HILITE 2), 31, 30, $(HILITE 3), 31, 30, $(HILITE 4), 30, 31]
)

$(P
Each slice modifies its first element, and the corresponding element of the actual array is affected.
)

$(P
We have seen earlier that valid array indexes are from 0 to one less than the length of the array. For example, the valid indexes of a 3-element array are 0, 1, and 2. Similarly, the end index in the slice syntax specifies one beyond the last element that the slice will be providing access to. For that reason, when the last element of an array needs to be included in a slice, the length of the array must be specified as the end index. For example, a slice of all elements of a 3-element array would be $(C array[0..3]).
)

$(P
An obvious limitation is that the beginning index cannot be greater than the end index:
)

---
    int[3] array = [ 0, 1, 2 ];
    int[] slice = array[2 .. 1];  // ← run-time ERROR
---

$(P
It is legal to have the beginning and the end indexes to be equal. In that case the slice is empty. Assuming that $(C index) is valid:
)

---
    int[] slice = anArray[index .. index];
    writeln("The length of the slice: ", slice.length);
---

$(P
The output:
)

$(SHELL
The length of the slice: 0
)

$(H5 $(IX $, slice length) Using $(C $), instead of $(C array.length))

$(P
When indexing, $(C $) is a shorthand for the length of the array:
)

---
    writeln(array[array.length - 1]);  // the last element
    writeln(array[$ - 1]);             // the same thing
---

$(H5 $(IX .dup) $(IX copy, array) Using $(C .dup) to copy)

$(P
Short for "duplicate", the $(C .dup) property makes a new array from the copies of the elements of an existing array:
)

---
    double[] array = [ 1.25, 3.75 ];
    double[] theCopy = array.dup;
---

$(P
As an example, let's define an array that contains the number of days of the months of a leap year. A method is to take a copy of the non-leap-year array and then to increment the element that corresponds to February:
)

---
import std.stdio;

void main() {
    int[12] monthDays =
        [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];

    int[] leapYear = monthDays$(HILITE .dup);

    ++leapYear[1];   // increments the days in February

    writeln("Non-leap year: ", monthDays);
    writeln("Leap year    : ", leapYear);
}
---

$(P
The output:
)

$(SHELL_SMALL
Non-leap year: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Leap year    : [31, $(HILITE 29), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
)

$(H5 $(IX assignment, array) Assignment)

$(P
We have seen so far that the assignment operator $(I modifies) values of variables. It is the same with fixed-length arrays:
)

---
    int[3] a = [ 1, 1, 1 ];
    int[3] b = [ 2, 2, 2 ];

    a = b;        // the elements of 'a' become 2
    writeln(a);
---

$(P
The output:
)

$(SHELL
[2, 2, 2]
)

$(P
The assignment operation has a completely different meaning for slices: It makes the slice start providing access to new elements:
)

---
    int[] odds = [ 1, 3, 5, 7, 9, 11 ];
    int[] evens = [ 2, 4, 6, 8, 10 ];

    int[] slice;   // not providing access to any elements yet

    $(HILITE slice =) odds[2 .. $ - 2];
    writeln(slice);

    $(HILITE slice =) evens[1 .. $ - 1];
    writeln(slice);
---

$(P
Above, $(C slice) does not provide access to any elements when it is defined. It is then used to provide access to some of the elements of $(C odds), and later to some of the elements of $(C evens):
)

$(SHELL
[5, 7]
[4, 6, 8]
)

$(H5 Making a slice longer may terminate sharing)

$(P
Since the length of a fixed-length array cannot be changed, the concept of $(I termination of sharing) is only about slices.
)

$(P
It is possible to access the same elements by more than one slice. For example, the first two of the eight elements below are being accessed through three slices:
)

---
import std.stdio;

void main() {
    int[] slice = [ 1, 3, 5, 7, 9, 11, 13, 15 ];
    int[] half = slice[0 .. $ / 2];
    int[] quarter = slice[0 .. $ / 4];

    quarter[1] = 0;     // modify through one slice

    writeln(quarter);
    writeln(half);
    writeln(slice);
}
---

$(P
The effect of the modification to the second element of $(C quarter) is seen through all slices:
)

$(SHELL
[1, $(HILITE 0)]
[1, $(HILITE 0), 5, 7]
[1, $(HILITE 0), 5, 7, 9, 11, 13, 15]
)

$(P
$(IX stomping) When viewed this way, slices provide $(I shared) access to elements. This sharing opens the question of what happens when a new element is added to one of the slices. Since multiple slices can provide access to same elements, there may not be room to add elements to a slice without $(I stomping) on the elements of others.
)

$(P
D disallows element stomping and answers this question by terminating the sharing relationship if there is no room for the new element: The slice that has no room to grow leaves the sharing. When this happens, all of the existing elements of that slice are copied to a new place automatically and the slice starts providing access to these new elements.
)

$(P
To see this in action, let's add an element to $(C quarter) before modifying its second element:
)

---
    quarter ~= 42;    // this slice leaves the sharing because
                      // there is no room for the new element

    quarter[1] = 0;   // for that reason this modification
                      // does not affect the other slices
---

$(P
The output of the program shows that the modification to the $(C quarter) slice does not affect the others:
)

$(SHELL
[1, $(HILITE 0), 42]
[1, 3, 5, 7]
[1, 3, 5, 7, 9, 11, 13, 15]
)

$(P
Explicitly increasing the length of a slice makes it leave the sharing as well:
)

---
    ++quarter.length;       // leaves the sharing
---

$(P
or
)

---
    quarter.length += 5;    // leaves the sharing
---

$(P
On the other hand, shortening a slice does not affect sharing. Shortening the slice merely means that the slice now provides access to fewer elements:
)

---
    int[] a = [ 1, 11, 111 ];
    int[] d = a;

    d = d[1 .. $];  // shortening from the beginning
    d[0] = 42;      // modifying the element through the slice

    writeln(a);     // printing the other slice
---

$(P
As can be seen from the output, the modification through $(C d) is seen through $(C a); the sharing is still in effect:
)

$(SHELL
[1, $(HILITE 42), 111]
)

$(P
Reducing the length in different ways does not terminate the sharing either:
)

---
    d = d[0 .. $ - 1];         // shortening from the end
    --d.length;                // same thing
    d.length = d.length - 1;   // same thing
---

$(P
Sharing of elements is still in effect.
)

$(H6 $(IX .capacity) Using $(C capacity) to determine whether sharing will be terminated)

$(P
There are cases when slices continue sharing elements even after an element is added to one of them. This happens when the element is added to the longest slice and there is room at the end of it:
)

---
import std.stdio;

void main() {
    int[] slice = [ 1, 3, 5, 7, 9, 11, 13, 15 ];
    int[] half = slice[0 .. $ / 2];
    int[] quarter = slice[0 .. $ / 4];

    slice ~= 42;      // adding to the longest slice ...
    $(HILITE slice[1] = 0);     // ... and then modifying an element

    writeln(quarter);
    writeln(half);
    writeln(slice);
}
---

$(P
As seen in the output, although the added element increases the length of a slice, the sharing has not been terminated, and the modification is seen through all slices:
)

$(SHELL
[1, $(HILITE 0)]
[1, $(HILITE 0), 5, 7]
[1, $(HILITE 0), 5, 7, 9, 11, 13, 15, 42]
)

$(P
The $(C capacity) property of slices determines whether the sharing will be terminated if an element is added to a particular slice. ($(C capacity) is actually a function but this distinction does not have any significance in this discussion.)
)

$(P
The value of $(C capacity) has the following meanings:
)

$(UL

$(LI
When its value is 0, it means that this is not the longest original slice. In this case, adding a new element would definitely relocate the elements of the slice and the sharing would terminate.
)

$(LI
When its value is nonzero, it means that this is the longest original slice. In this case $(C capacity) denotes the total number of elements that this slice can hold without needing to be copied. The number of $(I new elements) that can be added can be calculated by subtracting the actual length of the slice from the capacity value. If the length of the slice equals its capacity, then the slice will be copied to a new location if one more element is added.)

)

$(P
Accordingly, a program that needs to determine whether the sharing will terminate should use a logic similar to the following:
)

---
    if (slice.capacity == 0) {
        /* Its elements would be relocated if one more element
         * is added to this slice. */

        // ...

    } else {
        /* This slice may have room for new elements before
         * needing to be relocated. Let's calculate how
         * many: */
        auto howManyNewElements = slice.capacity - slice.length;

        // ...
    }
---

$(P
An interesting corner case is when there are more than one slice to $(I all elements). In such a case all slices report to have capacity:
)

---
import std.stdio;

void main() {
    // Three slices to all elements
    int[] s0 = [ 1, 2, 3, 4 ];
    int[] s1 = s0;
    int[] s2 = s0;

    writeln(s0.capacity);
    writeln(s1.capacity);
    writeln(s2.capacity);
}
---

$(P
All three have capacity:
)

$(SHELL
7
7
7
)

$(P
However, as soon as an element is added to one of the slices, the capacity of the others drop to 0:
)

---
    $(HILITE s1 ~= 42);    $(CODE_NOTE s1 becomes the longest)

    writeln(s0.capacity);
    writeln(s1.capacity);
    writeln(s2.capacity);
---

$(P
Since the slice with the added element is now the longest, it is the only one with capacity:
)

$(SHELL
0
7        $(SHELL_NOTE now only s1 has capacity)
0
)

$(H6 $(IX .reserve) Reserving room for elements)

$(P
Both copying elements and allocating new memory to increase capacity have some cost. For that reason, appending an element can be an expensive operation. When the number of elements to append is known beforehand, it is possible to reserve capacity for the elements:
)

---
import std.stdio;

void main() {
    int[] slice;

    slice$(HILITE .reserve(20));
    writeln(slice.capacity);

    foreach (element; 0 .. $(HILITE 17)) {
        slice ~= element;  $(CODE_NOTE these elements will not be moved)
    }
}
---

$(SHELL
31        $(SHELL_NOTE Capacity for at least 20 elements)
)

$(P
The elements of $(C slice) would be moved only after there are more than 31 elements.
)

$(H5 $(IX array-wise operation) $(IX elements, operation on all) Operations on all elements)

$(P
This feature is for both fixed-length arrays and slices.
)

$(P
The $(C []) characters written after the name of an array means $(I all elements). This feature simplifies the program when certain operations need to be applied to all of the elements of an array.
)

---
import std.stdio;

void main() {
    double[3] a = [ 10, 20, 30 ];
    double[3] b = [  2,  3,  4 ];

    double[3] result = $(HILITE a[] + b[]);

    writeln(result);
}
---

$(P
The output:
)

$(SHELL
[12, 23, 34]
)

$(P
The addition operation in that program is applied to the corresponding elements of both of the arrays in order: First the first elements are added, then the second elements are added, etc. A natural requirement is that the lengths of the two arrays must be equal.
)

$(P
The operator can be one of the arithmetic operators $(C +), $(C -), $(C *), $(C /), $(C %), and $(C ^^); one of the binary operators $(C ^), $(C &), and $(C |); as well as the unary operators $(C -) and $(C ~) that are typed in front of an array. We will see some of these operators in later chapters.
)

$(P
The assignment versions of these operators can also be used: $(C =), $(C +=), $(C -=), $(C *=), $(C /=), $(C %=), $(C ^^=), $(C ^=), $(C &=), and $(C |=).
)

$(P
This feature works not only using two arrays; it can also be used with an array and a compatible expression. For example, the following operation divides all elements of an array by four:
)

---
    double[3] a = [ 10, 20, 30 ];
    $(HILITE a[]) /= 4;

    writeln(a);
---

$(P
The output:
)

$(SHELL
[2.5, 5, 7.5]
)

$(P
To assign a specific value to all elements:
)

---
    $(HILITE a[]) = 42;
    writeln(a);
---

$(P
The output:
)

$(SHELL
[42, 42, 42]
)

$(P
This feature requires great attention when used with slices. Although there is no apparent difference in element values, the following two expressions have very different meanings:
)

---
    slice2 = slice1;      // ← slice2 starts providing access
                          //   to the same elements that
                          //   slice1 provides access to

    slice3[] = slice1;    // ← the values of the elements of
                          //   slice3 change
---

$(P
The assignment of $(C slice2) makes it share the same elements as $(C slice1). On the other hand, since $(C slice3[]) means $(I all elements of $(C slice3)), the values of its elements become the same as the values of the elements of $(C slice1). The effect of the presence or absence of the $(C []) characters cannot be ignored.
)

$(P
We can see an example of this difference in the following program:
)

---
import std.stdio;

void main() {
    double[] slice1 = [ 1, 1, 1 ];
    double[] slice2 = [ 2, 2, 2 ];
    double[] slice3 = [ 3, 3, 3 ];

    slice2 = slice1;      // ← slice2 starts providing access
                          //   to the same elements that
                          //   slice1 provides access to

    slice3[] = slice1;    // ← the values of the elements of
                          //   slice3 change

    writeln("slice1 before: ", slice1);
    writeln("slice2 before: ", slice2);
    writeln("slice3 before: ", slice3);

    $(HILITE slice2[0] = 42);       // ← the value of an element that
                          //   it shares with slice1 changes

    slice3[0] = 43;       // ← the value of an element that
                          //   only it provides access to
                          //   changes

    writeln("slice1 after : ", slice1);
    writeln("slice2 after : ", slice2);
    writeln("slice3 after : ", slice3);
}
---

$(P
The modification through $(C slice2) affects $(C slice1) too:
)

$(SHELL
slice1 before: [1, 1, 1]
slice2 before: [1, 1, 1]
slice3 before: [1, 1, 1]
slice1 after : [$(HILITE 42), 1, 1]
slice2 after : [$(HILITE 42), 1, 1]
slice3 after : [43, 1, 1]
)

$(P
The danger here is that the potential bug may not be noticed until after the value of a shared element is changed.
)

$(H5 $(IX multi-dimensional array) Multi-dimensional arrays)

$(P
So far we have used arrays with only fundamental types like $(C int) and $(C double). The element type can actually be any other type, including other arrays. This enables the programmer to define complex containers like $(I array of arrays). Arrays of arrays are called $(I multi-dimensional arrays).
)

$(P
The elements of all of the arrays that we have defined so far have been written in the source code from left to right. To help us understand the concept of a two-dimensional array, let's define an array from top to bottom this time:
)

---
    int[] array = [
                    10,
                    20,
                    30,
                    40
                  ];
---

$(P
As you remember, most spaces in the source code are used to help with readability and do not change the meaning of the code. The array above could have been defined on a single line and would have the same meaning.
)

$(P
Let's now replace every element of that array with another array:
)

---
  /* ... */ array = [
                      [ 10, 11, 12 ],
                      [ 20, 21, 22 ],
                      [ 30, 31, 32 ],
                      [ 40, 41, 42 ]
                    ];
---

$(P
We have replaced elements of type $(C int) with elements of type $(C int[]). To make the code conform to the array definition syntax, we must now specify the type of the elements as $(C int[]) instead of $(C int):
)

---
    $(HILITE int[])[] array = [
                      [ 10, 11, 12 ],
                      [ 20, 21, 22 ],
                      [ 30, 31, 32 ],
                      [ 40, 41, 42 ]
                    ];
---

$(P
Such arrays are called $(I two-dimensional arrays) because they can be seen as having rows and columns.
)

$(P
Two-dimensional arrays are used the same way as any other array as long as we remember that each element is an array itself and is used in array operations:
)

---
    array ~= [ 50, 51 ]; // adds a new element (i.e. a slice)
    array[0] ~= 13;      // adds to the first element
---

$(P
The new state of the array:
)

$(SHELL_SMALL
[[10, 11, 12, $(HILITE 13)], [20, 21, 22], [30, 31, 32], [40, 41, 42], $(HILITE [50, 51])]
)

$(P
Arrays and elements can be fixed-length as well. The following is a three-dimensional array where all dimensions are fixed-length:
)

---
    int[2][3][4] array;  // 2 columns, 3 rows, 4 pages
---

$(P
The definition above can be seen as $(I four pages of three rows of two columns of integers). As an example, such an array can be used to represent a 4-story building in an adventure game, each story consisting of 2x3=6 rooms.
)

$(P
For example, the number of items in the first room of the second floor can be incremented as follows:
)

---
    // The index of the second floor is 1, and the first room
    // of that floor is accessed by [0][0]
    ++itemCounts[1][0][0];
---

$(P
In addition to the syntax above, the $(C new) expression can also be used to create a $(I slice of slices). The following example uses only two dimensions:
)

---
import std.stdio;

void main() {
    int[][] s = new int[][](2, 3);
    writeln(s);
}
---

$(P
The $(C new) expression above creates 2 slices containing 3 elements each and returns a slice that provides access to those slices and elements. The output:
)

$(SHELL
[[0, 0, 0], [0, 0, 0]]
)

$(H5 Summary)

$(UL

$(LI
Fixed-length arrays own their elements; slices provide access to elements that don't belong exclusively to them.
)

$(LI
Within the $(C []) operator, $(C $) is the equivalent of $(C $(I array_name).length).
)

$(LI
$(C .dup) makes a new array that consists of the copies of the elements of an existing array.
)

$(LI
With fixed-length arrays, the assignment operation changes the values of elements; with slices, it makes the slices start providing access to other elements.
)

$(LI
Slices that get longer $(I may) stop sharing elements and start providing access to newly copied elements. $(C capacity) determines whether this will be the case.
)

$(LI
The syntax $(C array[]) means $(I all elements of the array); the operation that is applied to it is applied to each element individually.
)

$(LI
Arrays of arrays are called multi-dimensional arrays.
)

)

$(PROBLEM_TEK

$(P
Iterate over the elements of an array of $(C double)s and halve the ones that are greater than 10. For example, given the following array:
)

---
    double[] array = [ 1, 20, 2, 30, 7, 11 ];
---

$(P
Modify it as the following:
)

$(SHELL
[1, $(HILITE 10), 2, $(HILITE 15), 7, $(HILITE 5.5)]
)

$(P
Although there are many solutions of this problem, try to use only the features of slices. You can start with a slice that provides access to all elements. Then you can shorten the slice from the beginning and always use the first element.
)

$(P
The following expression shortens the slice from the beginning:
)

---
        slice = slice[1 .. $];
---

)

Macros:
        TITLE=Slices and Other Array Features

        DESCRIPTION=More features of D slices and arrays

        KEYWORDS=d programming language tutorial book arrays slices fixed-length dynamic
