Ddoc

$(DERS_BOLUMU $(IX function) Functions)

$(P
Similarly to how fundamental types are building blocks of program data, functions are building blocks of program behavior.
)

$(P
Functions are also closely related to the craft aspect of programming. The functions that are written by experienced programmers are succinct, simple, and clear. This goes both ways: The mere act of trying to identify and write smaller building blocks of a program makes for a better programmer.
)

$(P
We have covered basic statements and expressions in previous chapters. Although there will be many more that we will see in later chapters, what we have seen so far are commonly-used features of D. Still, they are not sufficient on their own to write large programs. The programs that we have written so far have all been very short, each demonstrating just a simple feature of the language. Trying to write a program with any level of complexity without functions would be very difficult and prone to bugs.
)

$(P
This chapter covers only the basic features of functions. We will see more about functions later in the following chapters:
)

$(UL
$(LI $(LINK2 function_parameters.html, Function Parameters))
$(LI $(LINK2 function_overloading.html, Function Overloading))
$(LI $(LINK2 lambda.html, Function Pointers, Delegates, and Lambdas))
$(LI $(LINK2 functions_more.html, More Functions))
)

$(P
Functions are features that put statements and expressions together as units of program execution. Such statements and expressions altogether are given a name that describes what they collectively achieve. They can then be $(I called) (or $(I executed)) by using that name.
)

$(P
The concept of $(I giving names to a group of steps) is common in our daily lives. For example, the act of cooking an omelet can be described in some level of detail by the following steps:
)

$(UL
$(LI get a pan)
$(LI get butter)
$(LI get an egg)
$(LI turn on the stove)
$(LI put the pan on the fire)
$(LI put butter into the pan when it is hot)
$(LI put the egg into butter when it is melted)
$(LI remove the pan from the fire when the egg is cooked)
$(LI turn off the stove)
)

$(P
Since that much detail is obviously excessive, steps that are related together would be combined under a single name:
)

$(UL
$(LI $(HILITE make preparations) (get the pan, butter, and the egg))
$(LI turn on the stove)
$(LI $(HILITE cook the egg) (put the pan on the fire, etc.))
$(LI turn off the stove)
)

$(P
Going further, there can be a single name for all of the steps:
)

$(UL
$(LI $(HILITE make a one-egg omelet) (all of the steps))
)

$(P
Functions are based on the same concept: steps that can collectively be named as a whole are put together to form a function. As an example, let's start with the following lines of code that achieve the task of printing a menu:
)

---
    writeln(" 0 Exit");
    writeln(" 1 Add");
    writeln(" 2 Subtract");
    writeln(" 3 Multiply");
    writeln(" 4 Divide");
---

$(P
Since it would make sense to name those combined lines as $(C printMenu), they can be put together to form a function by using the following syntax:
)

---
$(CODE_NAME printMenu)void printMenu() {
    writeln(" 0 Exit");
    writeln(" 1 Add");
    writeln(" 2 Subtract");
    writeln(" 3 Multiply");
    writeln(" 4 Divide");
}
---

$(P
The contents of that function can now be executed from within $(C main()) simply by using its name:
)

---
$(CODE_XREF printMenu)void main() {
    printMenu();

    // ...
}
---

$(P
It may be obvious from the similarities of the definitions of $(C printMenu()) and $(C main()) that $(C main()) is a function as well. The execution of a D program starts with the function named $(C main()) and branches out to other functions from there.
)

$(H5 $(IX parameter) Parameters)

$(P
Some of the powers of functions come from the fact that their behaviors are adjustable through parameters.
)

$(P
Let's continue with the omelet example by modifying it to make an omelet of five eggs instead of always one. The steps would exactly be the same, the only difference being the number of eggs to use. We can change the more general description above accordingly:
)

$(UL
$(LI make preparations (get the pan, butter, and $(HILITE five eggs)))
$(LI turn on the stove)
$(LI cook $(HILITE the eggs) (put the pan on the fire, etc.))
$(LI turn off the stove)
)

$(P
Likewise, the most general single step would become the following:
)

$(UL
$(LI make a $(HILITE five-egg) omelet (all of the steps))
)

$(P
This time there is an additional information that concerns some of the steps: "get five eggs", "cook the eggs", and "make a five-egg omelet".
)

$(P
$(IX , (comma), function parameter list) The behaviors of functions can be adjusted similarly to the omelet example. The information that functions use to adjust their behavior are called $(I parameters). Parameters are specified in a comma separated $(I function parameter list). The parameter list rests inside of the parentheses that comes after the name of the function.
)

$(P
The $(C printMenu()) function above was defined with an empty parameter list because that function always printed the same menu. Let's assume that sometimes the menu will need to be printed differently in different contexts. For example, it may make more sense to print the first entry as "Return" instead of "Exit" depending on the part of the program that is being executed at that time.
)

$(P
In such a case, the first entry of the menu can be $(I parameterized) by having been defined in the parameter list. The function then uses the value of that parameter instead of the literal $(STRING "Exit"):
)

---
void printMenu($(HILITE string firstEntry)) {
    writeln(" 0 ", firstEntry);
    writeln(" 1 Add");
    writeln(" 2 Subtract");
    writeln(" 3 Multiply");
    writeln(" 4 Divide");
}
---

$(P
Notice that since the information that the $(C firstEntry) parameter conveys is a piece of text, its type has been specified as $(C string) in the parameter list. This function can now be $(I called) with different parameter values to print menus having different first entries. All that needs to be done is to use the appropriate $(C string) values depending on where the function is being called from:
)

---
    // At some place in the program:
    printMenu("Exit");
    // ...
    // At some other place in the program:
    printMenu("Return");
---

$(P
$(B Note:) When you write and use your own functions with parameters of type $(C string) you may encounter compilation errors. As written, $(C printMenu()) above cannot be called with parameter values of type $(C char[]). For example, the following code would cause a compilation error:
)

---
    char[] anEntry;
    anEntry ~= "Take square root";
    printMenu(anEntry);  $(DERLEME_HATASI)
---

$(P
On the other hand, if $(C printMenu()) were defined to take its parameter as $(C char[]), then it could not be called with $(C string)s like $(STRING "Exit"). This is related to the concept of immutability and the $(C immutable) keyword, both of which will be covered in the next chapter.
)

$(P
Let's continue with the menu function and assume that it is not appropriate to always start the menu selection numbers with zero. In that case the starting number can also be passed to the function as its second parameter. The parameters of the function must be separated by commas:
)

---
void printMenu(string firstEntry$(HILITE , int firstNumber)) {
    writeln(' ', firstNumber + 0, ' ', firstEntry);
    writeln(' ', firstNumber + 1, " Add");
    writeln(' ', firstNumber + 2, " Subtract");
    writeln(' ', firstNumber + 3, " Multiply");
    writeln(' ', firstNumber + 4, " Divide");
}
---

$(P
It is now possible to tell the function what number to start from:
)

---
    printMenu("Return"$(HILITE , 1));
---

$(H5 Calling a function)

$(P
Starting a function so that it achieves its task is called $(I calling a function). The function call syntax is the following:
)

---
    $(I function_name)($(I parameter_values))
---


$(P
$(IX argument) The actual parameter values that are passed to functions are called $(I function arguments). Although the terms $(I parameter) and $(I argument) are sometimes used interchangeably in the literature, they signify different concepts.
)

$(P
The arguments are matched to the parameters one by one in the order that the parameters are defined. For example, the last call of $(C printMenu()) above uses the $(I arguments) $(STRING "Return") and $(C 1), which correspond to the $(I parameters) $(C firstEntry) and $(C firstNumber), respectively.
)

$(P
The type of each argument must match the type of the corresponding parameter.
)

$(H5 Doing work)

$(P
In previous chapters, we have defined expressions as entities that do work. Function calls are expressions as well: they do some work. Doing work means producing a value or having a side effect:
)

$(UL

$(LI
$(B Producing a value): Some operations only produce values. For example, a function that adds numbers would be producing the result of that addition. As another example, a function that makes a $(C Student) object by using the student's name and address would be producing a $(C Student) object.
)

$(LI
$(IX side effect)
$(B Having side effects): Side effects are any change in the state of the program or its environment. Some operations have only side effects. An example is how the $(C printMenu()) function above changes $(C stdout) by printing to it. As another example, a function that adds a $(C Student) object to a student container would also have a side effect: it would be causing the container to grow.

$(P
In summary, operations that cause a change in the state of the program have side effects.
)

)

$(LI
$(B Having side effects and producing a value:) Some operations do both. For example, a function that reads two values from $(C stdin) and returns their sum would be having side effects due to changing the state of $(C stdin) and also producing the sum of the two values.
)

$(LI
$(B No operation:) Although every function is designed as one of the three categories above, depending on certain conditions at compile time or at run time, some functions end up doing no work at all.
)

)

$(H5 $(IX return value) The return value)

$(P
The value that a function produces as a result of its work is called its $(I return value). This term comes from the observation that once the program execution branches into a function, it eventually $(I returns) back to where the function has been called. Functions get $(I called) and they $(I return) values.
)

$(P
Just like any other value, return values have types. The type of the return value is specified right before the name of the function, at the point where the function is defined. For example, a function that adds two values of type $(C int) and returns their sum also as an $(C int) would be defined as follows:
)

---
$(HILITE int) add(int first, int second) {
    // ...  the actual work of the function ...
}
---

$(P
The value that a function returns takes the place of the function call itself. For example, assuming that the function call $(C add(5, 7)) produces the value $(C 12), then the following two lines would be equivalent:
)

---
    writeln("Result: ", add(5, 7));
    writeln("Result: ", 12);
---

$(P
In the first line above, the $(C add()) function is called with the arguments $(C 5) and $(C 7) $(I before) $(C writeln()) gets called. The value $(C 12) that the function returns is in turn passed to $(C writeln()) as its second argument.
)

$(P
This allows passing the return values of functions to other functions to form complex expressions:
)

---
    writeln("Result: ", add(5, divide(100, studentCount())));
---

$(P
In the line above, the return value of $(C studentCount()) is passed to $(C divide()) as its second argument, the return value of $(C divide()) is passed to $(C add()) as its second argument, and eventually the return value of $(C add()) is passed to $(C writeln()) as its second argument.
)

$(H5 $(IX return, statement) The $(C return) statement)

$(P
The return value of a function is specified by the $(C return) keyword:
)

---
int add(int first, int second) {
    int result = first + second;
    $(HILITE return) result;
}
---

$(P
A function produces its return value by taking advantage of statements, expressions, and potentially by calling other functions. The function would then return that value by the $(C return) keyword, at which point the execution of the function ends.
)

$(P
It is possible to have more than one $(C return) statement in a function. The value of the first $(C return) statement that gets executed determines the return value of the function for a particular call:
)

---
int complexCalculation(int aParameter, int anotherParameter) {
    if (aParameter == anotherParameter) {
        return 0;
    }

    return aParameter * anotherParameter;
}
---

$(P
The function above returns $(C 0) when the two parameters are equal, and the product of their values when they are different.
)

$(H5 $(IX void, function) $(C void) functions)

$(P
The return types of functions that do not produce values are specified as $(C void). We have seen this many times with the $(C main()) function so far, as well as the $(C printMenu()) function above. Since they do not return any value to the caller, their return types have been defined as $(C void). ($(I $(B Note:) $(C main()) can also be defined as returning $(C int). We will see this in $(LINK2 main.html, a later chapter).))
)

$(H5 The name of the function)

$(P
The name of a function must be chosen to communicate the purpose of the function clearly. For example, the names $(C add) and $(C printMenu) were appropriate because their purposes were to add two values, and to print a menu, respectively.
)

$(P
A common guideline for function names is that they contain a verb like $(I add) or $(I print). According to this guideline names like $(C addition()) and $(C menu()) would be less than ideal.
)

$(P
However, it is acceptable to name functions simply as nouns if those functions do not have any side effects. For example, a function that returns the current temperature can be named as $(C currentTemperature()) instead of $(C getCurrentTemperature()).
)

$(P
Coming up with names that are clear, short, and consistent is part of the subtle art of programming.
)

$(H5 Code quality through functions)

$(P
Functions can improve the quality of code. Smaller functions with fewer responsibilities lead to programs that are easier to maintain.
)

$(H6 $(IX code duplication) Code duplication is harmful)

$(P
One of the aspects that is highly detrimental to program quality is code duplication. Code duplication occurs when there is more than one piece of code in the program that performs the same task.
)

$(P
Although this sometimes happens by copying lines of code around, it may also happen incidentally when writing separate pieces of code.
)

$(P
One of the problems with pieces of code that duplicate essentially the same functionality is that they present multiple chances for bugs to crop up. When such bugs do occur and we need to fix them, it can be hard to make sure that we have fixed all places where we introduced the problem, as they may be spread around. Conversely, when the code appears in only one place in the program, then we only need to fix it at that one place to get rid of the bug once and for all.
)

$(P
As I mentioned above, functions are closely related to the craft aspect of programming. Experienced programmers are always on the lookout for code duplication. They continually try to identify commonalities in code and move common pieces of code to separate functions (or to common structs, classes, templates, etc., as we will see in later chapters).
)

$(P
$(IX refactor) Let's start with a program that contains some code duplication. Let's see how that duplication can be removed by moving code into functions (i.e. by $(I refactoring) the code). The following program reads numbers from the input and prints them first in the order that they have arrived and then in numerical order:
)

---
import std.stdio;
import std.algorithm;

void main() {
    int[] numbers;

    int count;
    write("How many numbers are you going to enter? ");
    readf(" %s", &count);

    // Read the numbers
    foreach (i; 0 .. count) {
        int number;
        write("Number ", i, "? ");
        readf(" %s", &number);

        numbers ~= number;
    }

    // Print the numbers
    writeln("Before sorting:");
    foreach (i, number; numbers) {
        writefln("%3d:%5d", i, number);
    }

    sort(numbers);

    // Print the numbers
    writeln("After sorting:");
    foreach (i, number; numbers) {
        writefln("%3d:%5d", i, number);
    }
}
---

$(P
Some of the duplicated lines of code are obvious in that program. The last two $(C foreach) loops that are used for printing the numbers are exactly the same. Defining a function that might appropriately be named as $(C print()) would remove that duplication. The function could take a slice as a parameter and print it:
)

---
void print(int[] slice) {
    foreach (i, element; slice) {
        writefln("%3s:%5s", i, element);
    }
}
---

$(P
Notice that the parameter is now referred to using the more general name $(C slice) instead of original and more specific name $(C numbers). The reason for that is the fact that the function would not know what the elements of the slice would specifically represent. That can only be known at the place where the function has been called from. The elements may be student IDs, parts of a password, etc. Since that cannot be known in the $(C print()) function, general names like $(C slice) and $(C element) are used in its implementation.
)

$(P
The new function can be called from the two places where the slice needs to be printed:
)

---
import std.stdio;
import std.algorithm;

void print(int[] slice) {
    foreach (i, element; slice) {
        writefln("%3s:%5s", i, element);
    }
}

void main() {
    int[] numbers;

    int count;
    write("How many numbers are you going to enter? ");
    readf(" %s", &count);

    // Read the numbers
    foreach (i; 0 .. count) {
        int number;
        write("Number ", i, "? ");
        readf(" %s", &number);

        numbers ~= number;
    }

    // Print the numbers
    writeln("Before sorting:");
    $(HILITE print(numbers));

    sort(numbers);

    // Print the numbers
    writeln("After sorting:");
    $(HILITE print(numbers));
}
---

$(P
There is more to do. Notice that there is always a title line printed right before printing the elements of the slice. Although the title is different, the task is the same. If printing the title can be seen as a part of printing the slice, the title too can be passed as a parameter. Here are the new changes:
)

---
void print($(HILITE string title,) int[] slice) {
    $(HILITE writeln(title, ":");)

    foreach (i, element; slice) {
        writefln("%3s:%5s", i, element);
    }
}

// ...

    // Print the numbers
    print($(HILITE "Before sorting"), numbers);

// ...

    // Print the numbers
    print($(HILITE "After sorting"), numbers);
---

$(P
This step has the added benefit of obviating the comments that appear right before the two $(C print()) calls. Since the name of the function already clearly communicates what it does, those comments are unnecessary:
)

---
    print("Before sorting", numbers);
    sort(numbers);
    print("After sorting", numbers);
---

$(P
Although subtle, there is more code duplication in this program: The values of $(C count) and $(C number) are read in exactly the same way. The only difference is the message that is printed to the user and the name of the variable:
)

---
    int count;
    write("How many numbers are you going to enter? ");
    readf(" %s", &count);

// ...

        int number;
        write("Number ", i, "? ");
        readf(" %s", &number);
---

$(P
The code would become even better if it took advantage of a new function that might be named appropriately as $(C readInt()). The new function can take the message as a parameter, print that message, read an $(C int) from the input, and return that $(C int):
)

---
int readInt(string message) {
    int result;
    write(message, "? ");
    readf(" %s", &result);
    return result;
}
---

$(P
$(C count) can now be initialized directly by the return value of a call to this new function:
)

---
    int count =
        readInt("How many numbers are you going to enter");
---

$(P
$(C number) cannot be initialized in as straightforward a way because the loop counter $(C i) happens to be a part of the message that is displayed when reading $(C number). This can be overcome by taking advantage of $(C format):
)

---
import std.string;
// ...
        int number = readInt(format("Number %s", i));
---

$(P
Further, since $(C number) is used in only one place in the $(C foreach) loop, its definition can be eliminated altogether and the return value of $(C readInt()) can directly be used in its place:
)

---
    foreach (i; 0 .. count) {
        numbers ~= $(HILITE readInt)(format("Number %s", i));
    }
---

$(P
Let's make a final modification to this program by moving the lines that read the numbers to a separate function. This would also eliminate the need for the "Read the numbers" comment because the name of the new function would already carry that information.
)

$(P
The new $(C readNumbers()) function does not need any parameter to complete its task. It reads some numbers and returns them as a slice. The following is the final version of the program:
)

---
import std.stdio;
import std.string;
import std.algorithm;

void print(string title, int[] slice) {
    writeln(title, ":");

    foreach (i, element; slice) {
        writefln("%3s:%5s", i, element);
    }
}

int readInt(string message) {
    int result;
    write(message, "? ");
    readf(" %s", &result);
    return result;
}

int[] $(HILITE readNumbers)() {
    int[] result;

    int count =
        readInt("How many numbers are you going to enter");

    foreach (i; 0 .. count) {
        result ~= readInt(format("Number %s", i));
    }

    return result;
}

void main() {
    int[] numbers = readNumbers();
    print("Before sorting", numbers);
    sort(numbers);
    print("After sorting", numbers);
}
---

$(P
Compare this version of the program to the first one. The major steps of the program are very clear in the $(C main()) function of the new program. In contrast, the $(C main()) function of the first program had to be carefully examined to understand the purpose of that program.
)

$(P
Although the total numbers of nontrivial lines of the two versions of the program ended up being equal in this example, functions make programs shorter in general. This effect is not apparent in this simple program. For example, before the $(C readInt()) function has been defined, reading an $(C int) from the input involved three lines of code. After the definition of $(C readInt()), the same goal is achieved by a single line of code. Further, the definition of $(C readInt()) allowed removing the definition of the variable $(C number) altogether.
)

$(H6 Commented lines of code as functions)

$(P
Sometimes the need to write a comment to describe the purpose of a group of lines of code is an indication that those lines could better be moved to a newly defined function. If the name of the function is descriptive enough then there will be no need for the comment either.
)

$(P
The three commented groups of lines of the first version of the program have been used for defining new functions that achieved the same tasks.
)

$(P
Another important benefit of removing comment lines is that comments tend to become outdated as the code gets modified over time. When updating code, programmers sometimes forget to update associated comments thus these comments become either useless or, even worse, misleading. For that reason, it is beneficial to try to write programs without the need for comments.
)

$(PROBLEM_COK

$(PROBLEM Modify the $(C printMenu()) function to take the entire set of menu items as a parameter. For example, the menu items can be passed to the function as in the following code:

---
    string[] items =
        [ "Black", "Red", "Green", "Blue", "White" ];
    printMenu(items, 1);
---

$(P
Have the program produce the following output:
)

$(SHELL
 1 Black
 2 Red
 3 Green
 4 Blue
 5 White
)

)

$(PROBLEM
The following program uses a two dimensional array as a canvas. Start with that program and improve it by adding more functionality to it:

---
import std.stdio;

enum totalLines = 20;
enum totalColumns = 60;

/* The 'alias' in the next line makes 'Line' an alias of
 * dchar[totalColumns]. Every 'Line' that is used in the rest
 * of the program will mean dchar[totalColumns] from this
 * point on.
 *
 * Also note that 'Line' is a fixed-length array.  */
alias Line = dchar[totalColumns];

/* A dynamic array of Lines is being aliased as 'Canvas'. */
alias Canvas = Line[];

/* Prints the canvas line by line. */
void print(Canvas canvas) {
    foreach (line; canvas) {
        writeln(line);
    }
}

/* Places a dot at the specified location on the canvas. In a
 * sense, "paints" the canvas. */
void putDot(Canvas canvas, int line, int column) {
    canvas[line][column] = '#';
}

/* Draws a vertical line of the specified length from the
 * specified position. */
void drawVerticalLine(Canvas canvas,
                      int line,
                      int column,
                      int length) {
    foreach (lineToPaint; line .. line + length) {
        putDot(canvas, lineToPaint, column);
    }
}

void main() {
    Line emptyLine = '.';

    /* An empty canvas */
    Canvas canvas;

    /* Constructing the canvas by adding empty lines */
    foreach (i; 0 .. totalLines) {
        canvas ~= emptyLine;
    }

    /* Using the canvas */
    putDot(canvas, 7, 30);
    drawVerticalLine(canvas, 5, 10, 4);

    print(canvas);
}
---

)

)

Macros:
        TITLE=Functions

        DESCRIPTION=The function definitions in the D programming language

        KEYWORDS=d programming language tutorial book functions
