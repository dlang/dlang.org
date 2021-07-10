Ddoc

$(DERS_BOLUMU $(IX array) Arrays)

$(P
We have defined five variables in one of the exercises of the last chapter, and used them in certain calculations. The definitions of those variables were the following:
)

---
    double value_1;
    double value_2;
    double value_3;
    double value_4;
    double value_5;
---

$(P
This method of defining variables individually does not scale to cases where even more variables are needed. Imagine needing a thousand values; it is almost impossible to define a thousand variables from $(C value_1) to $(C value_1000).
)

$(P
Arrays are useful in such cases: the array feature allows us to define a single variable that stores multiple values together. Although simple, arrays are the most common data structure used to store a collection of values.
)

$(P
This chapter covers only some of the features of arrays. More features will be introduced later in $(LINK2 slices.html, the Slices and Other Array Features chapter).
)

$(H5 Definition)

$(P
The definition of array variables is very similar to the definition of normal variables. The only difference is that the number of values associated with the variable is specified in square brackets. We can contrast the two definitions as follows:
)

---
    int     singleValue;
    int[10] arrayOfTenValues;
---

$(P
The first line above is the definition of a variable which stores a single value, just like the variables that we have defined so far. The second line is the definition of a variable which stores ten consecutive values. In other words, it stores an array of ten integer values. You can also think of it as defining ten variables of the same type, or as defining an array, for short.
)

$(P
Accordingly, the equivalent of the five separate variables above can be defined as an array of five values using the following syntax:
)

---
    double[5] values;
---

$(P
$(IX scalar) That definition can be read as $(I 5 double values). Note that I have chosen the name of the array variable as plural to avoid confusing it with a single-valued variable. Variables which only store a single value are called scalar variables.
)

$(P
In summary, the definition of an array variable consists of the type of the values, the number of values, and the name of the variable that refers to the array of values:
)

---
    $(I type_name)[$(I value_count)] $(I variable_name);
---

$(P
The type of the values can also be a user-defined type. (We will see user-defined types later.) For example:
)

---
    // An array that holds the weather information of all
    // cities. Here, the bool values may mean
    //   false: overcast
    //   true : sunny
    bool[cityCount] weatherConditions;

    // An array that holds the weights of a hundred boxes
    double[100] boxWeights;

    // Information about the students of a school
    StudentInformation[studentCount] studentInformation;
---

$(H5 $(IX container) $(IX element) Containers and elements)

$(P
Data structures that bring elements of a certain type together are called $(I containers). According to this definition, arrays are containers. For example, an array that holds the air temperatures of the days in July can bring 31 $(C double) values together and form $(I a container of elements of type $(C double)).
)

$(P
The variables of a container are called $(I elements). The number of elements of an array is called the $(I length) of the array.
)

$(H5 $(IX []) Accessing the elements)

$(P
In order to differentiate the variables in the exercise of the previous chapter, we appended an underscore and a number to their names as in $(C value_1). This is not possible nor necessary when a single array stores all the values under a single name. Instead, the elements are accessed by specifying the $(I element number) within square brackets:
)

---
    values[0]
---

$(P
That expression can be read as $(I the element with the number 0 of the array named values). In other words, instead of typing $(C value_1) one must type $(C values[0]) with arrays.
)

$(P
There are two important points worth stressing here:
)

$(UL

$(LI $(B The numbers start with zero:) Although humans assign numbers to items starting with 1, the numbers in arrays start at 0. The values that we have numbered as 1, 2, 3, 4, and 5 before are numbered as 0, 1, 2, 3, and 4 in the array. This variation can confuse new programmers.
)

$(LI $(B Two different uses of the $(C[]) characters:) Don't confuse the two separate uses of the $(C []) characters. When defining arrays, the $(C []) characters are written after the type of the elements and specify the number of elements. When accessing elements, the $(C []) characters are written after the name of the array and specify the number of the element that is being accessed:

---
    // This is a definition. It defines an array that consists
    // of 12 elements. This array is used to hold the number
    // of days in each month.
    int[12] monthDays;

    // This is an access. It accesses the element that
    // corresponds to December and sets its value to 31.
    monthDays[11] = 31;

    // This is another access. It accesses the element that
    // corresponds to January, the value of which is passed to
    // writeln.
    writeln("January has ", monthDays[0], " days.");
---

$(P
$(B Reminder:) The element numbers of January and December are 0 and 11 respectively; not 1 and 12.
)

)

)

$(H5 $(IX index) Index)

$(P
The number of an element is called its $(I index) and the act of accessing an element is called $(I indexing).
)

$(P
An index need not be a constant value; the value of a variable can also be used as an index, making arrays even more useful. For example, the month can be determined by the value of the $(C monthIndex) variable below:
)

---
    writeln("This month has ", monthDays[monthIndex], " days.");
---

$(P
When the value of $(C monthIndex) is 2, the expression above would print the value of $(C monthDays[2]), the number of days in March.
)

$(P
Only the index values between zero and one less than the length of the array are valid. For example, the valid indexes of a three-element array are 0, 1, and 2. Accessing an array with an invalid index causes the program to be terminated with an error.
)

$(P
Arrays are containers where the elements are placed side by side in the computer's memory. For example, the elements of the array holding the number of days in each month can be shown as follows (assuming a year when February has 28 days):
)

$(MONO
  indexes →     0    1    2    3    4    5    6    7    8    9   10   11
 elements →  | 31 | 28 | 31 | 30 | 31 | 30 | 31 | 31 | 30 | 31 | 30 | 31 |
)

$(P
$(I $(B Note:) The indexes above are for demonstration purposes only; they are not stored in the computer's memory.)
)

$(P
The element at index 0 has the value 31 (number of days in January); the element at index 1 has the value of 28 (number of days in February), etc.
)

$(H5 $(IX fixed-length array) $(IX dynamic array) $(IX static array) Fixed-length arrays vs. dynamic arrays)

$(P
When the length of an array is specified when the program is written, that array is a $(I fixed-length array). When the length can change during the execution of the program, that array is a $(I dynamic array).
)

$(P
Both of the arrays that we have defined above are fixed-length arrays because their element counts are specified as 5 and 12 at the time when the program is written. The lengths of those arrays cannot be changed during the execution of the program. To change their lengths, the source code must be modified and the program must be recompiled.
)

$(P
Defining dynamic arrays is simpler than defining fixed-length arrays because omitting the length makes a dynamic array:
)

---
    int[] dynamicArray;
---

$(P
The length of such an array can increase or decrease during the execution of the program.
)

$(P
Fixed-length arrays are also known as static arrays.
)

$(H5 $(IX .length) Using $(C .length) to get or set the number of elements)

$(P
Arrays have properties as well, of which we will see only $(C .length) here. $(C .length) returns the number of elements of the array:
)

---
    writeln("The array has ", array.length, " elements.");
---

$(P
Additionally, the length of dynamic arrays can be changed by assigning a value to this property:
)

---
    int[] array;            // initially empty
    array.length = 5;       // now has 5 elements
---

$(H5 An array example)

$(P
Let's now revisit the exercise with the five values and write it again by using an array:
)

---
import std.stdio;

void main() {
    // This variable is used as a loop counter
    int counter;

    // The definition of a fixed-length array of five
    // elements of type double
    double[5] values;

    // Reading the values in a loop
    while (counter < values.length) {
        write("Value ", counter + 1, ": ");
        readf(" %s", &values[counter]);
        ++counter;
    }

    writeln("Twice the values:");
    counter = 0;
    while (counter < values.length) {
        writeln(values[counter] * 2);
        ++counter;
    }

    // The loop that calculates the fifths of the values would
    // be written similarly
}
---

$(P $(B Observations:) The value of $(C counter) determines how many times the loops are repeated (iterated). Iterating the loop while its value is less than $(C values.length) ensures that the loops are executed once per element. As the value of that variable is incremented at the end of each iteration, the $(C values[counter]) expression refers to the elements of the array one by one: $(C values[0]), $(C values[1]), etc.
)

$(P
To see how this program is better than the previous one, imagine needing to read 20 values. The program above would require a single change: replacing 5 with 20. On the other hand, a program that did not use an array would have to have 20 variable definitions. Furthermore, since you would be unable to use a loop to iterate the 20 values, you would also have to repeat several lines 20 times, one time for each single-valued variable.
)

$(H5 $(IX initialization, array) Initializing the elements)

$(P
Like every variable in D, the elements of arrays are automatically initialized. The initial value of the elements depends on the type of the elements: 0 for $(C int), $(C double.nan) for $(C double), etc.
)

$(P
All of the elements of the $(C values) array above are initialized to $(C double.nan):
)

---
    double[5] values;     // elements are all double.nan
---

$(P
Obviously, the values of the elements can be changed later during the execution of the program. We have already seen this above when assigning to an element of an array:
)

---
    monthDays[11] = 31;
---

$(P
That also happened when reading a value from the input:
)

---
    readf(" %s", &values[counter]);
---

$(P
Sometimes the desired values of the elements are known at the time when the array is defined. In such cases, the initial values of the elements can be specified on the right-hand side of the assignment operator, within square brackets. Let's see this in a program that reads the number of the month from the user, and prints the number of days in that month:
)

---
import std.stdio;

void main() {
    // Assuming that February has 28 days
    int[12] monthDays =
        [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];

    write("Please enter the number of the month: ");
    int monthNumber;
    readf(" %s", &monthNumber);

    int index = monthNumber - 1;
    writeln("Month ", monthNumber, " has ",
            monthDays[index], " days.");
}
---

$(P
As you can see, the $(C monthDays) array is defined and initialized at the same time. Also note that the number of the month, which is in the range <span style="white-space: nowrap">1-12</span>, is converted to a valid array index in the range <span style="white-space: nowrap">0-11</span>. Any value that is entered outside of the <span style="white-space: nowrap">1-12</span> range would cause the program to be terminated with an error.
)

$(P
When initializing arrays, it is possible to use a single value on the right-hand side. In that case all of the elements of the array are initialized to that value:
)

---
    int[10] allOnes = 1;    // All of the elements are set to 1
---

$(H5 Basic array operations)

$(P
Arrays provide convenience operations that apply to all of their elements.
)

$(H6 $(IX copy, array) Copying fixed-length arrays)

$(P
The assignment operator copies all of the elements from the right-hand side to the left-hand side:
)
---
    int[5] source = [ 10, 20, 30, 40, 50 ];
    int[5] destination;

    destination $(HILITE =) source;
---

$(P
$(I $(B Note:) The meaning of the assignment operation is completely different for dynamic arrays. We will see this in a later chapter.)
)

$(H6 $(IX ~=) $(IX append, array) $(IX add element, array) Adding elements to dynamic arrays)

$(P
The $(C ~=) operator adds new elements to the end of a dynamic array:
)

---
    int[] array;                // empty
    array ~= 7;                 // array is now equal to [7]
    array ~= 360;               // array is now equal to [7, 360]
    array ~= [ 30, 40 ];        // array is now equal to [7, 360, 30, 40]
---

$(P
It is not possible to add elements to fixed-length arrays:
)

---
    int[$(HILITE 10)] array;
    array ~= 7;                 $(DERLEME_HATASI)
---

$(H6 $(IX remove, array) Removing elements from dynamic arrays)

$(P
Array elements can be removed with the $(C remove()) function from the $(C std.algorithm) module. Because there may be more than one $(I slice) to the same elements, $(C remove()) cannot actually change the number of element of the array. Rather, it has to move some of the elements of the array one or more positions to the left. For that reason, the result of the remove operation must be assigned back to the same array variable.
)

$(P
There are two different ways of using $(C remove()):
)

$(OL
$(LI
Providing the index of the element to remove. For example, the following code removes the element at index 1.

---
import std.stdio;
import std.algorithm;

void main() {
    int[] array = [ 10, 20, 30, 40 ];
    $(HILITE array =) array.remove($(HILITE 1));                // Assigned back to array
    writeln(array);
}
---

$(SHELL
[10, 30, 40]
)
)

$(LI
Specifying the elements to remove with a $(I lambda function), which we will cover in $(LINK2 lambda.html, a later chapter). For example, the following code removes the elements of the array that are equal to 42.

---
import std.stdio;
import std.algorithm;

void main() {
    int[] array = [ 10, 42, 20, 30, 42, 40 ];
    $(HILITE array =) array.remove!(a => $(HILITE a == 42));    // Assigned back to array
    writeln(array);
}
---

$(SHELL
[10, 20, 30, 40]
)
)

)

$(H6 $(IX ~, concatenation) $(IX concatenation, array) Combining arrays)

$(P
The $(C ~) operator creates a new array by combining two arrays. Its $(C ~=) counterpart combines the two arrays and assigns the result back to the left-hand side array:
)

---
import std.stdio;

void main() {
    int[10] first = 1;
    int[10] second = 2;
    int[] result;

    result = first ~ second;
    writeln(result.length);     // prints 20

    result ~= first;
    writeln(result.length);     // prints 30
}
---

$(P
The $(C ~=) operator cannot be used when the left-hand side array is a fixed-length array:
)

---
    int[20] result;
    // ...
    result $(HILITE ~=) first;          $(DERLEME_HATASI)
---

$(P
If the array sizes are not equal, the program is terminated with an error during assignment:
)

---
    int[10] first = 1;
    int[10] second = 2;
    int[$(HILITE 21)] result;

    result = first ~ second;
---

$(SHELL
object.Error@(0): Array lengths don't match for copy: $(HILITE 20 != 21)
)

$(H6 $(IX sort) Sorting the elements)

$(P
$(C std.algorithm.sort) can sort the elements of many types of collections. In the case of integers, the elements get sorted from the smallest value to the greatest value. In order to use the $(C sort()) function, one must import the $(C std.algorithm) module first. (We will see functions in a later chapter.)
)

---
import std.stdio;
import std.algorithm;

void main() {
    int[] array = [ 4, 3, 1, 5, 2 ];
    $(HILITE sort)(array);
    writeln(array);
}
---

$(P
The output:
)

$(SHELL
[1, 2, 3, 4, 5]
)

$(H6 $(IX reverse) Reversing the elements)

$(P
$(C std.algorithm.reverse) reverses the elements in place (the first element becomes the last element, etc.):
)

---
import std.stdio;
import std.algorithm;

void main() {
    int[] array = [ 4, 3, 1, 5, 2 ];
    $(HILITE reverse)(array);
    writeln(array);
}
---

$(P
The output:
)

$(SHELL
[2, 5, 1, 3, 4]
)

$(PROBLEM_COK

$(PROBLEM
Write a program that asks the user how many values will be entered and then reads all of them. Have the program sort the elements using $(C sort()) and then reverse the sorted elements using $(C reverse()).
)

$(PROBLEM
Write a program that reads numbers from the input, and prints the odd and even ones separately but in order. Treat the value <span style="white-space: nowrap">-1</span> specially to determine the end of the numbers; do not process that value.

$(P
For example, when the following numbers are entered,
)

$(SHELL
1 4 7 2 3 8 11 -1
)

$(P
have the program print the following:
)

$(SHELL
1 3 7 11 2 4 8
)

$(P
$(B Hint:) You may want to put the elements in separate arrays. You can determine whether a number is odd or even using the $(C %) (remainder) operator.
)

)

$(PROBLEM
The following is a program that does not work as expected. The program is written to read five numbers from the input and to place the squares of those numbers into an array. The program then attempts to print the squares to the output. Instead, the program terminates with an error.

$(P
Fix the bugs of this program and make it work as expected:
)

---
import std.stdio;

void main() {
    int[5] squares;

    writeln("Please enter 5 numbers");

    int i = 0;
    while (i <= 5) {
        int number;
        write("Number ", i + 1, ": ");
        readf(" %s", &number);

        squares[i] = number * number;
        ++i;
    }

    writeln("=== The squares of the numbers ===");
    while (i <= squares.length) {
        write(squares[i], " ");
        ++i;
    }

    writeln();
}
---

)

)

Macros:
        TITLE=Arrays

        DESCRIPTION=Basic array operations of the D programming language

        KEYWORDS=d programming language tutorial book arrays fixed-length dynamic

