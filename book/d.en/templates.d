Ddoc

$(DERS_BOLUMU $(IX template) Templates)

$(P
Templates are the feature that allows describing the code as a pattern, for the compiler to generate program code automatically. Parts of the source code may be left to the compiler to be filled in until that part is actually used in the program.
)

$(P
Templates are very useful especially in libraries because they enable writing generic algorithms and data structures, instead of tying them to specific types.
)

$(P
Compared to the template supports in other languages, D's templates are very powerful and extensive. I will not get into all of the details of templates in this chapter. I will cover only function, struct, and class templates and only $(I type) template parameters. We will see more about templates in $(LINK2 templates_more.html, the More Templates chapter). For a complete reference on D templates, see $(LINK2 https://github.com/PhilippeSigaud/D-templates-tutorial, Philippe Sigaud's $(I D Templates: A Tutorial)).
)

$(P
To see the benefits of templates let's start with a function that prints values in parentheses:
)

---
void printInParens(int value) {
    writefln("(%s)", value);
}
---

$(P
Because the parameter is specified as $(C int), that function can only be used with values of type $(C int), or values that can automatically be converted to $(C int). For example, the compiler would not allow calling it with a floating point type.
)

$(P
Let's assume that the requirements of a program changes and that other types need to be printed in parentheses as well. One of the solutions for this would be to take advantage of function overloading and provide overloads of the function for all of the types that the function is used with:
)

---
// The function that already exists
void printInParens(int value) {
    writefln("(%s)", value);
}

// Overloading the function for 'double'
void printInParens($(HILITE double) value) {
    writefln("(%s)", value);
}
---

$(P
This solution does not scale well because this time the function cannot be used with e.g. $(C real) or any user-defined type. Although it is possible to overload the function for other types, the cost of doing this may be prohibitive.
)

$(P
An important observation here is that regardless of the type of the parameter, the contents of the overloads would all be $(I generically) the same: a single $(C writefln()) expression.
)

$(P
Such genericity is common in algorithms and data structures. For example, the binary search algorithm is independent of the type of the elements: It is about the specific steps and operations of the search. Similarly, the linked list data structure is independent of the type of the elements: Linked list is merely about $(I how) the elements are stored in the container, regardless of their type.
)

$(P
Templates are useful in such situations: Once a piece of code is described as a template, the compiler generates overloads of the same code automatically according to the actual uses of that code in the program.
)

$(P
As I have mentioned above, in this chapter I will cover only function, struct, and class templates, and $(I type) template parameters.
)

$(H5 $(IX function template) Function templates)

$(P
$(IX parameter, template) Defining a function as a template is leaving one or more of the types that it uses as unspecified, to be deduced later by the compiler.
)

$(P
The types that are being left unspecified are defined within the template parameter list, which comes between the name of the function and the function parameter list. For that reason, function templates have two parameter lists: the template parameter list and the function parameter list:
)

---
void printInParens$(HILITE (T))(T value) {
    writefln("(%s)", value);
}
---

$(P
The $(C T) within the template parameter list above means that $(C T) can be any type. Although $(C T) is an arbitrary name, it is an acronym for "type" and is very common in templates.
)

$(P
Since $(C T) represents any type, the templated definition of $(C printInParens()) above is sufficient to use it with almost every type, including the user-defined ones:
)

---
import std.stdio;

void printInParens(T)(T value) {
    writefln("(%s)", value);
}

void main() {
    printInParens(42);           // with int
    printInParens(1.2);          // with double

    auto myValue = MyStruct();
    printInParens(myValue);      // with MyStruct
}

struct MyStruct {
    string toString() const {
        return "hello";
    }
}
---

$(P
The compiler considers all of the uses of $(C printInParens()) in the program and generates code to support all those uses. The program is then compiled as if the function has been overloaded explicitly for $(C int), $(C double), and $(C MyStruct):
)

$(MONO
/* Note: These functions are not part of the source
 *       code. They are the equivalents of the functions that
 *       the compiler would automatically generate. */

void printInParens($(HILITE int) value) {
    writefln("(%s)", value);
}

void printInParens($(HILITE double) value) {
    writefln("(%s)", value);
}

void printInParens($(HILITE MyStruct) value) {
    writefln("(%s)", value);
}
)

$(P
The output of the program is produced by those different $(I instantiations) of the function template:
)

$(SHELL
(42)
(1.2)
(hello)
)

$(P
Each template parameter can determine more than one function parameter. For example, both the two function parameters and the return type of the following function template are determined by its single template parameter:
)

---
/* Returns a copy of 'slice' except the elements that are
 * equal to 'value'. */
$(HILITE T)[] removed(T)(const($(HILITE T))[] slice, $(HILITE T) value) {
    T[] result;

    foreach (element; slice) {
        if (element != value) {
            result ~= element;
        }
    }

    return result;
}
---

$(H5 More than one template parameter)

$(P
Let's change the function template to take the parentheses characters as well:
)

---
void printInParens(T)(T value, char opening, char closing) {
    writeln(opening, value, closing);
}
---

$(P
Now we can call the same function with different sets of parentheses:
)

---
    printInParens(42, '<', '>');
---

$(P
Although being able to specify the parentheses makes the function more usable, specifying the type of the parentheses as $(C char) makes it less flexible because it is not possible to call the function with characters of type $(C wchar) or $(C dchar):
)

---
    printInParens(42, '→', '←');      $(DERLEME_HATASI)
---

$(SHELL_SMALL
Error: template deneme.printInParens(T) cannot deduce
template function from argument types !()(int,$(HILITE wchar),$(HILITE wchar))
)

$(P
One solution would be to specify the type of the parentheses as $(C dchar) but this would still be insufficient as this time the function could not be called e.g. with $(C string) or user-defined types.
)

$(P
$(IX , (comma), template parameter list) Another solution is to leave the type of the parentheses to the compiler as well. Defining an additional template parameter instead of the specific $(C char) is sufficient:
)

---
void printInParens(T$(HILITE , ParensType))(T value,
                                  $(HILITE ParensType) opening,
                                  $(HILITE ParensType) closing) {
    writeln(opening, value, closing);
}
---

$(P
The meaning of the new template parameter is similar to $(C T)'s: $(C ParensType) can be any type.
)

$(P
It is now possible to use many different types of parentheses. The following are with $(C wchar) and $(C string):
)

---
    printInParens(42, '→', '←');
    printInParens(1.2, "-=", "=-");
---

$(SHELL
→42←
-=1.2=-
)

$(P
The flexibility of $(C printInParens()) has been increased, as it now works correctly for any combination of $(C T) and $(C ParensType) as long as those types are printable with $(C writeln()).
)

$(H5 $(IX type deduction) $(IX deduction, type) Type deduction)

$(P
The compiler's deciding on what type to use for a template parameter is called $(I type deduction).
)

$(P
Continuing from the last example above, the compiler decides on the following types according to the two uses of the function template:
)

$(UL
$(LI $(C int) and $(C wchar) when 42 is printed)
$(LI $(C double) and $(C string) when 1.2 is printed)
)

$(P
The compiler can deduce types only from the types of the parameter values that are passed to function templates. Although the compiler can usually deduce the types without any ambiguity, there are times when the types must be specified explicitly by the programmer.
)

$(H5 Explicit type specification)

$(P
Sometimes it is not possible for the compiler to deduce the template parameters. A situation that this can happen is when the types do not appear in the function parameter list. When template parameters are not related to function parameters, the compiler cannot deduce the template parameter types.
)

$(P
To see an example of this, let's design a function that asks a question to the user, reads a value as a response, and returns that value. Additionally, let's make this a function template so that it can be used to read any type of response:
)

---
$(HILITE T) getResponse$(HILITE (T))(string question) {
    writef("%s (%s): ", question, T.stringof);

    $(HILITE T) response;
    readf(" %s", &response);

    return response;
}
---

$(P
That function template would be very useful in programs to read different types of values from the input. For example, to read some user information, we can imagine calling it as in the following line:
)

---
    getResponse("What is your age?");
---

$(P
Unfortunately, that call does not give the compiler any clue as to what the template parameter $(C T) should be. What is known is that the question is passed to the function as a $(C string), but the type of the return value cannot be deduced:
)

$(SHELL_SMALL
Error: template deneme.getResponse(T) $(HILITE cannot deduce) template
function from argument types !()(string)
)

$(P
$(IX !, template instance) In such cases, the template parameters must be specified explicitly by the programmer. Template parameters are specified in parentheses after an exclamation mark:
)

---
    getResponse$(HILITE !(int))("What is your age?");
---

$(P
The code above can now be accepted by the compiler and the function template is compiled as $(C T) being an alias of $(C int) within the definition of the template.
)

$(P
When there is only one template parameter specified, the parentheses around it are optional:
)

---
    getResponse$(HILITE !int)("What is your age?");    // same as above
---

$(P
You may recognize that syntax from $(C to!string), which we have been using in earlier programs. $(C to()) is a function template, which takes the target type of the conversion as a template parameter. Since it has only one template parameter that needs to be specified, it is commonly written as $(C to!string) instead of $(C to!(string)).
)

$(H5 $(IX instantiation, template) Template instantiation)

$(P
Automatic generation of code for a specific set of template parameter values is called an $(I instantiation) of that template for that specific set of parameter values. For example, $(C to!string) and $(C to!int) are two different instantiations of the $(C to) function template.
)

$(P
As I will mention again in a separate section below, distinct instantiations of templates produce distinct and incompatible types.
)

$(H5 $(IX specialization, template) Template specializations)

$(P
Although the $(C getResponse()) function template can in theory be used for any template type, the code that the compiler generates may not be suitable for every type. Let's assume that we have the following type that represents points on a two dimensional space:
)

---
struct Point {
    int x;
    int y;
}
---

$(P
Although the instantiation of $(C getResponse()) for the $(C Point) type itself would be fine, the generated $(C readf()) call for $(C Point) cannot be compiled. This is because the standard library function $(C readf()) does not know how to read a $(C Point) object. The two lines that actually read the response would look like the following in the $(C Point) instantiation of the $(C getResponse()) function template:
)

---
    Point response;
    readf(" %s", &response);    $(DERLEME_HATASI)
---

$(P
One way of reading a $(C Point) object would be to read the values of the $(C x) and $(C y) members separately and then to $(I construct) a $(C Point) object from those values.
)

$(P
Providing a special definition of a template for a specific template parameter value is called a $(I template specialization). The specialization is defined by the type name after a $(C :) character in the template parameter list. A $(C Point) specialization of the $(C getResponse()) function template can be defined as in the following code:
)

---
// The general definition of the function template (same as before)
T getResponse(T)(string question) {
    writef("%s (%s): ", question, T.stringof);

    T response;
    readf(" %s", &response);

    return response;
}

// The specialization of the function template for Point
T getResponse(T $(HILITE : Point))(string question) {
    writefln("%s (Point)", question);

    auto x = getResponse!int("  x");
    auto y = getResponse!int("  y");

    return Point(x, y);
}
---

$(P
Note that the specialization takes advantage of the general definition of $(C getResponse()) to read two $(C int) values to be used as the values of the $(C x) and $(C y) members.
)

$(P
Instead of instantiating the template itself, now the compiler uses the specialization above whenever $(C getResponse()) is called for the $(C Point) type:
)

---
    auto center = getResponse!Point("Where is the center?");
---

$(P
Assuming that the user enters 11 and 22:
)

$(SHELL_SMALL
Where is the center? (Point)
  x (int): 11
  y (int): 22
)

$(P
The $(C getResponse!int()) calls are directed to the general definition of the template and the $(C getResponse!Point()) calls are directed to the $(C Point) specialization of it.
)

$(P
As another example, let's consider using the same template with $(C string). As you would remember from the $(LINK2 strings.html, Strings chapter), $(C readf()) would read all of the characters from the input as part of a single $(C string) until the end of the input. For that reason, the default definition of $(C getResponse()) would not be useful when reading $(C string) responses:
)

---
    // Reads the entire input, not only the name!
    auto name = getResponse!string("What is your name?");
---

$(P
We can provide a template specialization for $(C string) as well. The following specialization reads just the $(I line) instead:
)

---
T getResponse(T $(HILITE : string))(string question) {
    writef("%s (string): ", question);

    // Read and ignore whitespace characters which have
    // presumably been left over from the previous user input
    string response;
    do {
        response = strip(readln());
    } while (response.length == 0);

    return response;
}
---

$(H5 $(IX struct template) $(IX class template) Struct and class templates)

$(P
The $(C Point) struct may be seen as having a limitation: Because its two members are defined specifically as $(C int), it cannot represent fractional coordinate values. This limitation can be removed if the $(C Point) struct is defined as a template.
)

$(P
Let's first add a member function that returns the distance to another $(C Point) object:
)

---
import std.math;

// ...

struct Point {
    int x;
    int y;

    int distanceTo(Point that) const {
        immutable real xDistance = x - that.x;
        immutable real yDistance = y - that.y;

        immutable distance = sqrt((xDistance * xDistance) +
                                  (yDistance * yDistance));

        return cast(int)distance;
    }
}
---

$(P
That definition of $(C Point) is suitable when the required precision is relatively low: It can calculate the distance between two points at kilometer precision, e.g. between the center and branch offices of an organization:
)

---
    auto center = getResponse!Point("Where is the center?");
    auto branch = getResponse!Point("Where is the branch?");

    writeln("Distance: ", center.distanceTo(branch));
---

$(P
Unfortunately, $(C Point) is inadequate at higher precisions than $(C int) can provide.
)

$(P
Structs and classes can be defined as templates as well, by specifying a template parameter list after their names. For example, $(C Point) can be defined as a struct template by providing a template parameter and replacing the $(C int)s by that parameter:
)

---
struct Point$(HILITE (T)) {
    $(HILITE T) x;
    $(HILITE T) y;

    $(HILITE T) distanceTo(Point that) const {
        immutable real xDistance = x - that.x;
        immutable real yDistance = y - that.y;

        immutable distance = sqrt((xDistance * xDistance) +
                                  (yDistance * yDistance));

        return cast($(HILITE T))distance;
    }
}
---

$(P
Since structs and classes are not functions, they cannot be called with parameters. This makes it impossible for the compiler to deduce their template parameters. The template parameter list must always be specified for struct and class templates:
)

---
    auto center = Point$(HILITE !int)(0, 0);
    auto branch = Point$(HILITE !int)(100, 100);

    writeln("Distance: ", center.distanceTo(branch));
---

$(P
The definitions above make the compiler generate code for the $(C int) instantiation of the $(C Point) template, which is the equivalent of its earlier non-template definition. However, now it can be used with any type. For example, when more precision is needed, with $(C double):
)

---
    auto point1 = Point$(HILITE !double)(1.2, 3.4);
    auto point2 = Point$(HILITE !double)(5.6, 7.8);

    writeln(point1.distanceTo(point2));
---

$(P
Although the template itself has been defined independently of any specific type, its single definition makes it possible to represent points of various precisions.
)

$(P
Simply converting $(C Point) to a template would cause compilation errors in code that has already been written according to its non-template definition. For example, now the $(C Point) specialization of $(C getResponse()) cannot be compiled:
)

---
T getResponse(T : Point)(string question) {  $(DERLEME_HATASI)
    writefln("%s (Point)", question);

    auto x = getResponse!int("  x");
    auto y = getResponse!int("  y");

    return Point(x, y);
}
---

$(P
The reason for the compilation error is that $(C Point) itself is not a type anymore: $(C Point) is now a $(I struct template). Only instantiations of that template would be considered as types. The following changes are required to correctly specialize $(C getResponse()) for any instantiation of $(C Point):
)

---
Point!T getResponse(T : Point!T)(string question) {  // 2, 1
    writefln("%s (Point!%s)", question, T.stringof); // 5

    auto x = getResponse!T("  x");                   // 3a
    auto y = getResponse!T("  y");                   // 3b

    return Point!T(x, y);                            // 4
}
---

$(OL

$(LI
In order for this template specialization to support all instantiations of $(C Point), the template parameter list must mention $(C Point!T). This simply means that the $(C getResponse()) specialization is for $(C Point!T), regardless of $(C T). This specialization would match $(C Point!int), $(C Point!double), etc.
)

$(LI
Similarly, to return the correct type as the response, the return type must be specified as $(C Point!T) as well.
)

$(LI
Since the types of $(C x) and $(C y) members of $(C Point!T) are now $(C T), as opposed to $(C int), the members must be read by calling $(C getResponse!T()), not $(C getResponse!int()), as the latter would be correct only for $(C Point!int).
)

$(LI
Similar to items 1 and 2, the type of the return value is $(C Point!T).
)

$(LI
To print the name of the type accurately for every type, as in $(C Point!int), $(C Point!double), etc., $(C T.stringof) is used.
)

)

$(H5 $(IX default template parameter) Default template parameters)

$(P
Sometimes it is cumbersome to provide template parameter types every time a template is used, especially when that type is almost always a particular type. For example, $(C getResponse()) may almost always be called for the $(C int) type in the program, and only in a few places for the $(C double) type.
)

$(P
It is possible to specify default types for template parameters, which are assumed when the types are not explicitly provided. Default parameter types are specified after the $(C =) character:
)

---
T getResponse(T $(HILITE = int))(string question) {
    // ...
}

// ...

    auto age = getResponse("What is your age?");
---

$(P
As no type has been specified when calling $(C getResponse()) above, $(C T) becomes the default type $(C int) and the call ends up being the equivalent of $(C getResponse!int()).
)

$(P
Default template parameters can be specified for struct and class templates as well, but in their case the template parameter list must always be written even when empty:
)

---
struct Point(T = int) {
    // ...
}

// ...

    Point!$(HILITE ()) center;
---


$(P
Similar to default function parameter values as we have seen in the $(LINK2 parameter_flexibility.html, Variable Number of Parameters chapter), default template parameters can be specified for all of the template parameters or for the $(I last) ones:
)

---
void myTemplate(T0, T1 $(HILITE = int), T2 $(HILITE = char))() {
    // ...
}
---

$(P
The last two template parameters of that function may be left unspecified but the first one is required:
)

---
    myTemplate!string();
---

$(P
In that usage, the second and third parameters are $(C int) and $(C char), respectively.
)

$(H5 Every template instantiation yields a distinct type)

$(P
Every instantiation of a template for a given set of types is considered to be a distinct type. For example, $(C Point!int) and $(C Point!double) are separate types:
)

---
Point!int point3 = Point!double(0.25, 0.75); $(DERLEME_HATASI)
---

$(P
Those different types cannot be used in the assignment operation above:
)

$(SHELL_SMALL
Error: cannot implicitly convert expression (Point(0.25,0.75))
of type $(HILITE Point!(double)) to $(HILITE Point!(int))
)

$(H5 A compile-time feature)

$(P
Templates are entirely a compile-time feature. The instances of templates are generated by the compiler at compile time.
)

$(H5 Class template example: stack data structure)

$(P
Struct and class templates are commonly used in the implementations of data structures. Let's design a stack container that will be able to contain any type.
)

$(P
Stack is one of the simplest data structures. It represents a container where elements are placed conceptually on top of each other as would be in a stack of papers. New elements go on top, and only the topmost element is accessed. When an element is removed, it is always the topmost one.
)

$(P
If we also define a property that returns the total number of elements in the stack, all of the operations of this data structure would be the following:
)

$(UL
$(LI Add element ($(C push())))
$(LI Remove element ($(C pop())))
$(LI Access the topmost element ($(C .top)))
$(LI Report the number of elements ($(C .length)))
)

$(P
An array can be used to store the elements such that the last element of the array would be representing the topmost element of the stack. Finally, it can be defined as a class template to be able to contain elements of any type:
)

---
$(CODE_NAME Stack)class Stack$(HILITE (T)) {
private:

    $(HILITE T)[] elements;

public:

    void push($(HILITE T) element) {
        elements ~= element;
    }

    void pop() {
        --elements.length;
    }

    $(HILITE T) top() const {
        return elements[$ - 1];
    }

    size_t length() const {
        return elements.length;
    }
}
---

$(P
Here is a $(C unittest) block for this class that uses its $(C int) instantiation:
)

---
unittest {
    auto stack = new Stack$(HILITE !int);

    // The newly added element must appear on top
    stack.push(42);
    assert(stack.top == 42);
    assert(stack.length == 1);

    // .top and .length should not affect the elements
    assert(stack.top == 42);
    assert(stack.length == 1);

    // The newly added element must appear on top
    stack.push(100);
    assert(stack.top == 100);
    assert(stack.length == 2);

    // Removing the last element must expose the previous one
    stack.pop();
    assert(stack.top == 42);
    assert(stack.length == 1);

    // The stack must become empty when the last element is
    // removed
    stack.pop();
    assert(stack.length == 0);
}
---

$(P
To take advantage of this class template, let's try using it this time with a user-defined type. As an example, here is a modified version of $(C Point):
)

---
struct Point(T) {
    T x;
    T y;

    string toString() const {
        return format("(%s,%s)", x, y);
    }
}
---

$(P
A $(C Stack) that contains elements of type $(C Point!double) can be defined as follows:
)

---
    auto points = new Stack!(Point!double);
---

$(P
Here is a test program that first adds ten elements to this stack and then removes them one by one:
)

---
$(CODE_XREF Stack)import std.string;
import std.stdio;
import std.random;

struct Point(T) {
    T x;
    T y;

    string toString() const {
        return format("(%s,%s)", x, y);
    }
}

// Returns a random value between -0.50 and 0.50.
double random_double()
out (result) {
    assert((result >= -0.50) && (result < 0.50));

} do {
    return (double(uniform(0, 100)) - 50) / 100;
}

// Returns a Stack that contains 'count' number of random
// Point!double elements.
Stack!(Point!double) randomPoints(size_t count)
out (result) {
    assert(result.length == count);

} do {
    auto points = new Stack!(Point!double);

    foreach (i; 0 .. count) {
        immutable point = Point!double(random_double(),
                                       random_double());
        writeln("adding  : ", point);
        points.push(point);
    }

    return points;
}

void main() {
    auto stackedPoints = randomPoints(10);

    while (stackedPoints.length) {
        writeln("removing: ", stackedPoints.top);
        stackedPoints.pop();
    }
}
---

$(P
As the output of the program shows, the elements are removed in the reverse order as they have been added:
)

$(SHELL_SMALL
adding  : (-0.02,-0.01)
adding  : (0.17,-0.5)
adding  : (0.12,0.23)
adding  : (-0.05,-0.47)
adding  : (-0.19,-0.11)
adding  : (0.42,-0.32)
adding  : (0.48,-0.49)
adding  : (0.35,0.38)
adding  : (-0.2,-0.32)
adding  : (0.34,0.27)
removing: (0.34,0.27)
removing: (-0.2,-0.32)
removing: (0.35,0.38)
removing: (0.48,-0.49)
removing: (0.42,-0.32)
removing: (-0.19,-0.11)
removing: (-0.05,-0.47)
removing: (0.12,0.23)
removing: (0.17,-0.5)
removing: (-0.02,-0.01)
)

$(H5 Function template example: binary search algorithm)

$(P
Binary search is the fastest algorithm to search for an element among the elements of an already sorted array. It is a very simple algorithm: The element in the middle is considered; if that element is the one that has been sought, then the search is over. If not, then the algorithm is repeated on the elements that are either on the left-hand side or on the right-hand side of the middle element, depending on whether the sought element is greater or less than the middle element.
)

$(P
Algorithms that repeat themselves on a smaller range of the initial elements are recursive. Let's write the binary search algorithm recursively by calling itself.
)

$(P
Before converting it to a template, let's first write this function to support only arrays of $(C int). We can easily convert it to a template later, by adding a template parameter list and replacing appropriate $(C int)s in its definition by $(C T)s. Here is a binary search algorithm that works on arrays of $(C int):
)

---
/* This function returns the index of the value if it exists
 * in the array, size_t.max otherwise. */
size_t binarySearch(const int[] values, int value) {
    // The value is not in the array if the array is empty.
    if (values.length == 0) {
        return size_t.max;
    }

    immutable midPoint = values.length / 2;

    if (value == values[midPoint]) {
        // Found.
        return midPoint;

    } else if (value < values[midPoint]) {
        // The value can only be in the left-hand side; let's
        // search in a slice that represents that half.
        return binarySearch(values[0 .. midPoint], value);

    } else {
        // The value can only be in the right-hand side; let's
        // search in the right-hand side.
        auto index =
            binarySearch(values[midPoint + 1 .. $], value);

        if (index != size_t.max) {
            // Adjust the index; it is 0-based in the
            // right-hand side slice.
            index += midPoint + 1;
        }

        return index;
    }

    assert(false, "We should have never gotten to this line");
}
---

$(P
The function above implements this simple algorithm in four steps:
)

$(UL
$(LI If the array is empty, return $(C size_t.max) to indicate that the value has not been found.)
$(LI If the element at the mid-point is equal to the sought value, then return the index of that element.)
$(LI If the value is less than the element at the mid-point, then repeat the same algorithm on the left-hand side.)
$(LI Else, repeat the same algorithm on the right-hand side.)
)

$(P
Here is a unittest block that tests the function:
)

---
unittest {
    auto array = [ 1, 2, 3, 5 ];
    assert(binarySearch(array, 0) == size_t.max);
    assert(binarySearch(array, 1) == 0);
    assert(binarySearch(array, 4) == size_t.max);
    assert(binarySearch(array, 5) == 3);
    assert(binarySearch(array, 6) == size_t.max);
}
---

$(P
Now that the function has been implemented and tested for $(C int), we can convert it to a template. $(C int) appears only in two places in the definition of the template:
)

---
size_t binarySearch(const int[] values, int value) {
    // ... int does not appear here ...
}
---

$(P
The $(C int)s that appear in the parameter list are the types of the elements and the value. Specifying those as template parameters is sufficient to make this algorithm a template and to be usable with other types as well:
)

---
size_t binarySearch$(HILITE (T))(const $(HILITE T)[] values, $(HILITE T) value) {
    // ...
}
---

$(P
That function template can be used with any type that matches the operations that are applied to that type in the template. In $(C binarySearch()), the elements are used only with comparison operators $(C ==) and $(C <):
)

---
    if (value $(HILITE ==) values[midPoint]) {
        // ...

    } else if (value $(HILITE <) values[midPoint]) {

        // ...
---

$(P
For that reason, $(C Point) is not ready to be used with $(C binarySearch()) yet:
)

---
import std.string;

struct Point(T) {
    T x;
    T y;

    string toString() const {
        return format("(%s,%s)", x, y);
    }
}

void $(CODE_DONT_TEST)main() {
    Point!int[] points;

    foreach (i; 0 .. 15) {
        points ~= Point!int(i, i);
    }

    assert(binarySearch(points, Point!int(10, 10)) == 10);
}
---

$(P
The program above would cause a compilation error:
)

$(SHELL_SMALL
Error: need member function $(HILITE opCmp()) for struct
const(Point!(int)) to compare
)

$(P
According to the error message, $(C opCmp()) needs to be defined for $(C Point). $(C opCmp()) has been covered in $(LINK2 operator_overloading.html, the Operator Overloading chapter):
)

---
struct Point(T) {
// ...

    int opCmp(const ref Point that) const {
        return (x == that.x
                ? y - that.y
                : x - that.x);
    }
}
---

$(H5 Summary)

$(P
We will see other features of templates in $(LINK2 templates_more.html, a later chapter). The following are what we have covered in this chapter:
)

$(UL

$(LI Templates define the code as a pattern, for the compiler to generate instances of it according to the actual uses in the program.)

$(LI Templates are a compile-time feature.)

$(LI Specifying template parameter lists is sufficient to make function, struct, and class definitions templates.

---
void functionTemplate$(HILITE (T))(T functionParameter) {
    // ...
}

class ClassTemplate$(HILITE (T)) {
    // ...
}
---

)

$(LI Template arguments can be specified explicitly after an exclamation mark. The parentheses are not necessary when there is only one token inside the parentheses.

---
    auto object1 = new ClassTemplate!(double);
    auto object2 = new ClassTemplate!double;    // same thing
---

)

$(LI Every template instantiation yields a distinct type.

---
    assert(typeid(ClassTemplate!$(HILITE int)) !=
           typeid(ClassTemplate!$(HILITE uint)));
---

)

$(LI Template arguments can only be deduced for function templates.

---
    functionTemplate(42);  // functionTemplate!int is deduced
---

)

$(LI Templates can be specialized for the type that is after the $(C :) character.

---
class ClassTemplate(T $(HILITE : dchar)) {
    // ...
}
---

)

$(LI Default template arguments are specified after the $(C =) character.

---
void functionTemplate(T $(HILITE = long))(T functionParameter) {
    // ...
}
---

)

)

Macros:
        TITLE=Templates

        DESCRIPTION=Introduction to D's generic programming features. Templates allow defining code as a pattern and have the compiler generate actual code according to how the template is used in the program.

        KEYWORDS=d programming language tutorial book templates
