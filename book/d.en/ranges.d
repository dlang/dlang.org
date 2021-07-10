Ddoc

$(DERS_BOLUMU $(IX range) Ranges)

$(P
Ranges are an abstraction of element access. This abstraction enables the use of great number of algorithms over great number of container types. Ranges emphasize how container elements are accessed, as opposed to how the containers are implemented.
)

$(P
Ranges are a very simple concept that is based on whether a type defines certain sets of member functions. We have already seen this concept in the $(LINK2 foreach_opapply.html, $(C foreach) with Structs and Classes chapter): any type that provides the member functions $(C empty), $(C front), and $(C popFront()) can be used with the $(C foreach) loop. The set of those three member functions is the requirement of the range type $(C InputRange).
)

$(P
I will start introducing ranges with $(C InputRange), the simplest of all the range types. The other ranges require more member functions over $(C InputRange).
)

$(P
Before going further, I would like to provide the definitions of containers and algorithms.
)

$(P
$(IX container) $(IX data structure) $(B Container (data structure):) Container is a very useful concept that appears in almost every program. Variables are put together for a purpose and are used together as elements of a container. D's containers are its core features arrays and associative arrays, and special container types that are defined in the $(C std.container) module. Every container is implemented as a specific data structure. For example, associative arrays are a $(I hash table) implementation.
)

$(P
Every data structure stores its elements and provides access to them in ways that are special to that data structure. For example, in the array data structure the elements are stored side by side and accessed by an element index; in the linked list data structure the elements are stored in nodes and are accessed by going through those nodes one by one; in a sorted binary tree data structure, the nodes provide access to the preceding and successive elements through separate branches; etc.
)

$(P
In this chapter, I will use the terms $(I container) and $(I data structure) interchangeably.
)

$(P
$(IX algorithm) $(B Algorithm (function):) Processing of data structures for specific purposes in specific ways is called an $(I algorithm). For example, $(I linear search) is an algorithm that searches by iterating over a container from the beginning to the end; $(I binary search) is an algorithm that searches for an element by eliminating half of the candidates at every step; etc.
)

$(P
In this chapter, I will use the terms $(I algorithm) and $(I function) interchangeably.
)

$(P
For most of the samples below, I will use $(C int) as the element type and $(C int[]) as the container type. In reality, ranges are more powerful when used with templated containers and algorithms. In fact, most of the containers and algorithms that ranges tie together are all templates. I will leave examples of templated ranges to $(LINK2 ranges_more.html, the next chapter).
)

$(H5 History)

$(P
A very successful library that abstracts algorithms and data structures from each other is the Standard Template Library (STL), which also appears as a part of the C++ standard library. STL provides this abstraction with the $(I iterator) concept, which is implemented by C++'s templates.
)

$(P
Although they are a very useful abstraction, iterators do have some weaknesses. D's ranges were designed to overcome these weaknesses.
)

$(P
Andrei Alexandrescu introduces ranges in his paper $(LINK2 http://www.informit.com/articles/printerfriendly.aspx?p=1407357, On Iteration) and demonstrates how they can be superior to iterators.
)

$(H5 Ranges are an integral part of D)

$(P
D's slices happen to be implementations of the most powerful range $(C RandomAccessRange), and there are many range features in Phobos. It is essential to understand how ranges are used in Phobos.
)

$(P
Many Phobos algorithms return temporary range objects. For example, $(C filter()), which chooses elements that are greater than 10 in the following code, actually returns a range object, not an array:
)

---
import std.stdio;
import std.algorithm;

void main() {
    int[] values = [ 1, 20, 7, 11 ];
    writeln(values.filter!(value => value > 10));
}
---

$(P
$(C writeln) uses that range object lazily and accesses the elements as it needs them:
)

$(SHELL
[20, 11]
)

$(P
That output may suggest that $(C filter()) returns an $(C int[]) but this is not the case. We can see this from the fact that the following assignment produces a compilation error:
)

---
    int[] chosen = values.filter!(value => value > 10); $(DERLEME_HATASI)
---

$(P
The error message contains the type of the range object:
)

$(SHELL
Error: cannot implicitly convert expression (filter(values))
of type $(HILITE FilterResult!(__lambda2, int[])) to int[]
)

$(P
$(I $(B Note:) The type may be different in the version of Phobos that you are using.)
)

$(P
It is possible to convert that temporary object to an actual array, as we will see later in the chapter.
)

$(H5 Traditional implementations of algorithms)

$(P
In traditional implementations of algorithms, the algorithms know how the data structures that they operate on are implemented. For example, the following function that prints the elements of a linked list must know that the nodes of the linked list have members named $(C element) and $(C next):
)

---
struct Node {
    int element;
    Node * next;
}

void print(const(Node) * list) {
    for ( ; list; list = list.$(HILITE next)) {
        write(' ', list.$(HILITE element));
    }
}
---

$(P
Similarly, a function that prints the elements of an array must know that arrays have a $(C length) property and their elements are accessed by the $(C []) operator:
)

---
void print(const int[] array) {
    for (int i = 0; i != array.$(HILITE length); ++i) {
        write(' ', array$(HILITE [i]));
    }
}
---

$(P
$(I $(B Note:) We know that $(C foreach) is more useful when iterating over arrays. As a demonstration of how traditional algorithms are tied to data structures, let's assume that the use of $(C for) is justified.)
)

$(P
Having algorithms tied to data structures makes it necessary to write them specially for each type. For example, the functions find(), sort(), swap(), etc. must be written separately for array, linked list, associative array, binary tree, heap, etc. As a result, N algorithms that support M data structures must be written NxM times. (Note: In reality, the count is less than NxM because not every algorithm can be applied to every data structure; for example, associative arrays cannot be sorted.)
)

$(P
Conversely, because ranges abstract algorithms away from data structures, implementing just N algorithms and M data structures would be sufficient. A newly implemented data structure can work with all of the existing algorithms that support the type of range that the new data structure provides, and a newly implemented algorithm can work with all of the existing data structures that support the range type that the new algorithm requires.
)

$(H5 Phobos ranges)

$(P
The ranges in this chapter are different from number ranges that are written in the form $(C begin..end). We have seen how number ranges are used with the $(C foreach) loop and with slices:
)

---
    foreach (value; $(HILITE 3..7)) {       // number range,
                                  // NOT a Phobos range

    int[] slice = array[$(HILITE 5..10)];   // number range,
                                  // NOT a Phobos range
---

$(P
When I write $(I range) in this chapter, I mean a Phobos range .
)

$(P
Ranges form a $(I range hierarchy). At the bottom of this hierarchy is the simplest range $(C InputRange). The other ranges bring more requirements on top of the range on which they are based. The following are all of the ranges with their requirements, sorted from the simplest to the more capable:
)

$(UL

$(LI $(C InputRange): requires the $(C empty), $(C front) and $(C popFront()) member functions)

$(LI $(C ForwardRange): additionally requires the $(C save) member function)

$(LI $(C BidirectionalRange): additionally requires the $(C back) and $(C popBack()) member functions)

$(LI $(C RandomAccessRange): additionally requires the $(C []) operator (and another property depending on whether the range is finite or infinite))

)

$(P
This hierarchy can be shown as in the following graph. $(C RandomAccessRange) has finite and infinite versions:
)

$(MONO
                    InputRange
                        ↑
                   ForwardRange
                   ↗         ↖
     BidirectionalRange    RandomAccessRange (infinite)
             ↑
  RandomAccessRange (finite)
)

$(P
The graph above is in the style of class hierarchies where the lowest level type is at the top.
)

$(P
Those ranges are about providing element access. There is one more range, which is about element $(I output):
)

$(UL
$(LI $(C OutputRange): requires support for the $(C put(range,&nbsp;element)) operation)
)

$(P
These five range types are sufficient to abstract algorithms from data structures.
)

$(H6 Iterating by shortening the range)

$(P
Normally, iterating over the elements of a container does not change the container itself. For example, iterating over a slice with $(C foreach) or $(C for) does not affect the slice:
)

---
    int[] slice = [ 10, 11, 12 ];

    for (int i = 0; i != slice.length; ++i) {
        write(' ', slice[i]);
    }

    assert(slice.length == 3);  // ← the length doesn't change
---

$(P
Another way of iteration requires a different way of thinking: iteration can be achieved by shortening the range from the beginning. In this method, it is always the first element that is used for element access and the first element is $(I popped) from the beginning in order to get to the next element:
)

---
    for ( ; slice.length; slice = slice[1..$]) {
        write(' ', $(HILITE slice[0]));   // ← always the first element
    }
---

$(P
$(I Iteration) is achieved by removing the first element by the $(C slice&nbsp;=&nbsp;slice[1..$]) expression. The slice above is completely consumed by going through the following stages:
)

$(MONO
[ 10, 11, 12 ]
    [ 11, 12 ]
        [ 12 ]
           [ ]
)

$(P
The iteration concept of Phobos ranges is based on this new thinking of shortening the range from the beginning. ($(C BidirectionalRange) and finite $(C RandomAccessRange) types can be shortened from the end as well.)
)

$(P
Please note that the code above is just to demonstrate this type of iteration; it should not be considered normal to iterate as in that example.
)

$(P
Since losing elements just to iterate over a range would not be desired in most cases, a surrogate range may be consumed instead. The following code uses a separate slice to preserve the elements of the original one:
)

---
    int[] slice = [ 10, 11, 12 ];
    int[] surrogate = slice;

    for ( ; surrogate.length; $(HILITE surrogate = surrogate[1..$])) {
        write(' ', surrogate[0]);
    }

    assert(surrogate.length == 0); // ← surrogate is consumed
    assert(slice.length == 3);     // ← slice remains the same
---

$(P
This is the method employed by most of the Phobos range functions: they return special range objects to be consumed in order to preserve the original containers.
)

$(H5 $(IX InputRange) $(C InputRange))

$(P
This type of range models the type of iteration where elements are accessed in sequence as we have seen in the $(C print()) functions above. Most algorithms only require that elements are iterated in the forward direction without needing to look at elements that have already been iterated over. $(C InputRange) models the standard input streams of programs as well, where elements are removed from the stream as they are read.
)

$(P
For completeness, here are the three functions that $(C InputRange) requires:
)

$(UL

$(LI $(IX empty) $(C empty): specifies whether the range is empty; it must return $(C true) when the range is considered to be empty, and $(C false) otherwise)

$(LI $(IX front) $(C front): provides access to the element at the beginning of the range)

$(LI $(IX popFront) $(C popFront()): shortens the range from the beginning by removing the first element)

)

$(P
$(I $(B Note:) I write $(C empty) and $(C front) without parentheses, as they can be seen as properties of the range; and $(C popFront()) with parentheses as it is a function with side effects.)
)

$(P
Here is how $(C print()) can be implemented by using these range functions:
)

---
void print(T)(T range) {
    for ( ; !range$(HILITE .empty); range$(HILITE .popFront())) {
        write(' ', range$(HILITE .front));
    }

    writeln();
}
---

$(P
Please also note that $(C print()) is now a function template to avoid limiting the range type arbitrarily. $(C print()) can now work with any type that provides the three $(C InputRange) functions.
)

$(H6 $(C InputRange) example)

$(P
Let's redesign the $(C School) type that we have seen before, this time as an $(C InputRange). We can imagine $(C School) as a $(C Student) container so when designed as a range, it can be seen as a range of $(C Student)s.
)

$(P
In order to keep the example short, let's disregard some important design aspects. Let's
)

$(UL

$(LI implement only the members that are related to this section)

$(LI design all types as structs)

$(LI ignore specifiers and qualifiers like $(C private), $(C public), and $(C const))

$(LI not take advantage of contract programming and unit testing)

)

---
import std.string;

struct Student {
    string name;
    int number;

    string toString() const {
        return format("%s(%s)", name, number);
    }
}

struct School {
    Student[] students;
}

void main() {
    auto school = School( [ Student("Ebru", 1),
                            Student("Derya", 2) ,
                            Student("Damla", 3) ] );
}
---

$(P
To make $(C School) be accepted as an $(C InputRange), we must define the three $(C InputRange) member functions.
)

$(P
For $(C empty) to return $(C true) when the range is empty, we can use the length of the $(C students) array. When the length of that array is 0, the range is considered empty:
)

---
struct School {
    // ...

    bool empty() const {
        return students.length == 0;
    }
}
---

$(P
For $(C front) to return the first element of the range, we can return the first element of the array:
)

---
struct School {
    // ...

    ref Student front() {
        return students[0];
    }
}
---

$(P
$(I $(B Note:) I have used the $(C ref) keyword to be able to provide access to the actual element instead of a copy of it. Otherwise the elements would be copied because $(C Student) is a struct.)
)

$(P
For $(C popFront()) to shorten the range from the beginning, we can shorten the $(C students) array from the beginning:
)

---
struct School {
    // ...

    void popFront() {
        students = students[1 .. $];
    }
}
---

$(P
$(I $(B Note:) As I have mentioned above, it is not normal to lose the original elements from the container just to iterate over them. We will address this issue below by introducing a special range type.)
)

$(P
These three functions are sufficient to make $(C School) to be used as an $(C InputRange). As an example, let's add the following line at the end of $(C main()) above to have our new $(C print()) function template to use $(C school) as a range:
)

---
    print(school);
---

$(P
$(C print()) uses that object as an $(C InputRange) and prints its elements to the output:
)

$(SHELL
 Ebru(1) Derya(2) Damla(3)
)

$(P
We have achieved our goal of defining a user type as an $(C InputRange); we have sent it to an algorithm that operates on $(C InputRange) types. $(C School) is actually ready to be used with algorithms of Phobos or any other library that work with $(C InputRange) types. We will see examples of this below.
)

$(H6 $(IX slice, as InputRange) The $(C std.array) module to use slices as ranges)

$(P
Merely importing the $(C std.array) module makes the most common container type conform to the most capable range type: slices can seamlessly be used as $(C RandomAccessRange) objects.
)

$(P
The $(C std.array) module provides the functions $(C empty), $(C front), $(C popFront()) and other range functions for slices. As a result, slices are ready to be used with any range function, for example with $(C print()):
)

---
import $(HILITE std.array);

// ...

    print([ 1, 2, 3, 4 ]);
---

$(P
It is not necessary to import $(C std.array) if the $(C std.range) module has already been imported.
)

$(P
Since it is not possible to remove elements from fixed-length arrays, $(C popFront()) cannot be defined for them. For that reason, fixed-length arrays cannot be used as ranges themselves:
)

---
void print(T)(T range) {
    for ( ; !range.empty; range.popFront()) {  $(DERLEME_HATASI)
        write(' ', range.front);
    }

    writeln();
}

void main() {
    int[$(HILITE 4)] array = [ 1, 2, 3, 4 ];
    print(array);
}
---

$(P
It would be better if the compilation error appeared on the line where $(C print()) is called. This is possible by adding a template constraint to $(C print()). The following template constraint takes advantage of $(C isInputRange), which we will see in the next chapter. By the help of the template constraint, now the compilation error is for the line where $(C print()) is called, not for a line where $(C print()) is defined:
)

---
void print(T)(T range)
        if (isInputRange!T) {    // template constraint
    // ...
}
// ...
    print(array);    $(DERLEME_HATASI)
---

$(P
The elements of a fixed-length array can still be accessed by range functions. What needs to be done is to use a slice of the whole array, not the array itself:
)

---
    print(array$(HILITE []));    // now compiles
---

$(P
Even though slices can be used as ranges, not every range type can be used as an array. When necessary, all of the elements can be copied one by one into an array. $(C std.array.array) is a helper function to simplify this task; $(C array()) iterates over $(C InputRange) ranges, copies the elements, and returns a new array:
)

---
import std.array;

// ...

    // Note: Also taking advantage of UFCS
    auto copiesOfStudents = school.$(HILITE array);
    writeln(copiesOfStudents);
---

$(P
The output:
)

$(SHELL
[Ebru(1), Derya(2), Damla(3)]
)

$(P
Also note the use of $(LINK2 ufcs.html, UFCS) in the code above. UFCS goes very well with range algorithms by making code naturally match the execution order of expressions.
)

$(H6 $(IX string, as range) $(IX dchar, string range) $(IX decoding, automatic) Automatic decoding of strings as ranges of $(C dchar))

$(P
Being character arrays by definition, strings can also be used as ranges just by importing $(C std.array). However, $(C char) and $(C wchar) strings cannot be used as $(C RandomAccessRange).
)

$(P
$(C std.array) provides a special functionality with all types of strings: Iterating over strings becomes iterating over Unicode code points, not over UTF code units. As a result, strings appear as ranges of Unicode characters.
)

$(P
The following strings contain ç and é, which cannot be represented by a single $(C char), and 𝔸 (mathematical double-struck capital A), which cannot be represented by a single $(C wchar) (note that these characters may not be displayed correctly in the environment that you are reading this chapter):
)

---
import std.array;

// ...

    print("abcçdeé𝔸"c);
    print("abcçdeé𝔸"w);
    print("abcçdeé𝔸"d);
---

$(P
The output of the program is what we would normally expect from a $(I range of letters):
)

$(XXX We use MONO_NOBOLD instead of SHELL to ensure that 𝔸 is displayed correctly.)
$(MONO_NOBOLD
 a b c ç d e é 𝔸
 a b c ç d e é 𝔸
 a b c ç d e é 𝔸
)

$(P
As you can see, that output does not match what we saw in the $(LINK2 characters.html, Characters) and $(LINK2 strings.html, Strings) chapters. We have seen in those chapters that $(C string) is an alias to an array of $(C immutable(char)) and $(C wstring) is an alias to an array of $(C immutable(wchar)). Accordingly, one might expect to see UTF code units in the previous output instead of the properly decoded Unicode characters.
)

$(P
The reason why the characters are displayed correctly is because when used as ranges, string elements are automatically decoded. As we will see below, the decoded $(C dchar) values are not actual elements of the strings but $(LINK2 lvalue_rvalue.html, rvalues).
)

$(P
As a reminder, let's consider the following function that treats the strings as arrays of code units:
)

---
void $(HILITE printElements)(T)(T str) {
    for (int i = 0; i != str.length; ++i) {
        write(' ', str$(HILITE [i]));
    }

    writeln();
}

// ...

    printElements("abcçdeé𝔸"c);
    printElements("abcçdeé𝔸"w);
    printElements("abcçdeé𝔸"d);
---

$(P
When the characters are accessed directly by indexing, the elements of the arrays are not decoded:
)

$(XXX We use MONO_NOBOLD instead of SHELL to ensure that 𝔸 is displayed correctly.)
$(MONO_NOBOLD
 a b c � � d e � � � � � �
 a b c ç d e é ��� ���
 a b c ç d e é 𝔸
)

$(P
$(IX representation, std.string) Automatic decoding is not always the desired behavior. For example, the following program that is trying to assign to the first element of a string cannot be compiled because the return value of $(C .front) is an rvalue:
)

---
import std.array;

void main() {
    char[] s = "hello".dup;
    s.front = 'H';                   $(DERLEME_HATASI)
}
---

$(SHELL
Error: front(s) is $(HILITE not an lvalue)
)

$(P
When a range algorithm needs to modify the actual code units of a string (and when doing so does not invalidate the UTF encoding), then the string can be used as a range of $(C ubyte) elements by $(C std.string.represention):
)

---
import std.array;
import std.string;

void main() {
    char[] s = "hello".dup;
    s$(HILITE .representation).front = 'H';    // compiles
    assert(s == "Hello");
}
---

$(P
$(C representation) presents the actual elements of $(C char), $(C wchar), and $(C dchar) strings as ranges of $(C ubyte), $(C ushort), and $(C uint), respectively.
)

$(H6 Ranges without actual elements)

$(P
The elements of the $(C School) objects were actually stored in the $(C students) member slices. So, $(C School.front) returned a reference to an existing $(C Student) object.
)

$(P
One of the powers of ranges is the flexibility of not actually owning elements. $(C front) need not return an actual element of an actual container. The returned $(I element) can be calculated each time when $(C popFront()) is called, and can be used as the value that is returned by $(C front).
)

$(P
We have already seen a range without actual elements above: Since $(C char) and $(C wchar) cannot represent all Unicode characters, the Unicode characters that appear as range elements cannot be actual elements of any $(C char) or $(C wchar) array. In the case of strings, $(C front) returns a $(C dchar) that is $(I constructed) from the corresponding UTF code units of arrays:
)

---
import std.array;

void main() {
    dchar letter = "é".front; // The dchar that is returned by
                              // front is constructed from the
                              // two chars that represent é
}
---

$(P
Although the element type of the array is $(C char), the return type of $(C front) above is $(C dchar). That $(C dchar) is not an element of the array but is an $(LINK2 lvalue_rvalue.html, rvalue) decoded as a Unicode character from the elements of the array.
)

$(P
Similarly, some ranges do not own any elements but are used for providing access to elements of other ranges. This is a solution to the problem of losing elements while iterating over $(C School) objects above. In order to preserve the elements of the actual $(C School) objects, a special $(C InputRange) can be used.
)

$(P
To see how this is done, let's define a new struct named $(C StudentRange) and move all of the range member functions from $(C School) to this new struct. Note that $(C School) itself is not a range anymore:
)

---
struct School {
    Student[] students;
}

struct StudentRange {
    Student[] students;

    this(School school) {
        $(HILITE this.students = school.students);
    }

    bool empty() const {
        return students.length == 0;
    }

    ref Student front() {
        return students[0];
    }

    void popFront() {
        students = students[1 .. $];
    }
}
---

$(P
The new range starts with a member slice that provides access to the students of $(C School) and consumes that member slice in $(C popFront()). As a result, the actual slice in $(C School) is preserved:
)

---
    auto school = School( [ Student("Ebru", 1),
                            Student("Derya", 2) ,
                            Student("Damla", 3) ] );

    print($(HILITE StudentRange)(school));

    // The actual array is now preserved:
    assert(school.students.length == 3);
---

$(P
$(I $(B Note:) Since all its work is dispatched to its member slice, $(C StudentRange) may not be seen as a good example of a range. In fact, assuming that $(C students) is an accessible member of $(C School), the user code could have created a slice of $(C School.students) directly and could have used that slice as a range.)
)

$(H6 $(IX infinite range) Infinite ranges)

$(P
Another benefit of not storing elements as actual members is the ability to create infinite ranges.
)

$(P
Making an infinite range is as simple as having $(C empty) always return $(C false). Since it is constant, $(C empty) need not even be a function and can be defined as an $(C enum) value:
)

---
    enum empty = false;                   // ← infinite range
---

$(P
Another option is to use an immutable $(C static) member:
)

---
    static immutable empty = false;       // same as above
---

$(P
As an example of this, let's design a range that represents the Fibonacci series. Despite having only two $(C int) members, the following range can be used as the infinite Fibonacci series:
)

---
$(CODE_NAME FibonacciSeries_InputRange)$(CODE_COMMENT_OUT)struct FibonacciSeries
$(CODE_COMMENT_OUT){
    int current = 0;
    int next = 1;

    enum empty = false;   // ← infinite range

    int front() const {
        return current;
    }

    void popFront() {
        const nextNext = current + next;
        current = next;
        next = nextNext;
    }
$(CODE_COMMENT_OUT)}
---

$(P
$(I $(B Note:) Although it is infinite, because the members are of type $(C int), the elements of this Fibonacci series would be wrong beyond $(C int.max).)
)

$(P
Since $(C empty) is always $(C false) for $(C FibonacciSeries) objects, the $(C for) loop in $(C print()) never terminates for them:
)

---
    print(FibonacciSeries());    // never terminates
---

$(P
An infinite range is useful when the range need not be consumed completely right away. We will see how to use only some of the elements of a $(C FibonacciSeries) below.
)

$(H6 Functions that return ranges)

$(P
Earlier, we have created a $(C StudentRange) object by explicitly writing $(C StudentRange(school)).
)

$(P
$(IX convenience function) In most cases, a convenience function that returns the object of such a range is used instead. For example, a function with the whole purpose of returning a $(C StudentRange) would simplify the code:
)

---
StudentRange studentsOf(ref School school) {
    return StudentRange(school);
}

// ...

    // Note: Again, taking advantage of UFCS
    print(school.$(HILITE studentsOf));
---

$(P
This is a convenience over having to remember and spell out the names of range types explicitly, which can get quite complicated in practice.
)

$(P
$(IX take, std.range) We can see an example of this with the simple $(C std.range.take) function. $(C take()) is a function that provides access to a specified number of elements of a range, from the beginning. In reality, this functionality is not achieved by the $(C take()) function itself, but by a special range object that it returns. This fact need not be explicit when using $(C take()):
)

---
import std.range;

// ...

    auto school = School( [ Student("Ebru", 1),
                            Student("Derya", 2) ,
                            Student("Damla", 3) ] );

    print(school.studentsOf.$(HILITE take(2)));
---

$(P
$(C take()) returns a temporary range object above, which provides access to the first 2 elements of $(C school). In turn, $(C print()) uses that object and produces the following output:
)

$(SHELL
 Ebru(1) Derya(2)
)

$(P
The operations above still don't make any changes to $(C school); it still has 3 elements:
)

---
    print(school.studentsOf.take(2));
    assert(school.students.length == 3);
---

$(P
The specific types of the range objects that are returned by functions like $(C take()) are not important. These types may sometimes be exposed in error messages, or we can print them ourselves with the help of $(C typeof) and $(C stringof):
)

---
    writeln(typeof(school.studentsOf.take(2)).stringof);
---

$(P
According to the output, $(C take()) returns an instance of a template named $(C Take):
)

$(SHELL
Take!(StudentRange)
)

$(H6 $(IX std.range) $(IX std.algorithm) $(C std.range) and $(C std.algorithm) modules)

$(P
A great benefit of defining our types as ranges is being able to use them not only with our own functions, but with Phobos and other libraries as well.
)

$(P
$(C std.range) includes a large number of range functions, structs, and classes. $(C std.algorithm) includes many algorithms that are commonly found also in the standard libraries of other languages.
)

$(P
$(IX swapFront, std.algorithm) To see an example of how our types can be used with standard modules, let's use $(C School) with the $(C std.algorithm.swapFront) algorithm. $(C swapFront()) swaps the front elements of two $(C InputRange) ranges. (It requires that the front elements of the two ranges are swappable. Arrays satisfy that condition.)
)

$(P

)

---
import std.algorithm;

// ...

    auto turkishSchool = School( [ Student("Ebru", 1),
                                   Student("Derya", 2) ,
                                   Student("Damla", 3) ] );

    auto americanSchool = School( [ Student("Mary", 10),
                                    Student("Jane", 20) ] );

    $(HILITE swapFront)(turkishSchool.studentsOf,
              americanSchool.studentsOf);

    print(turkishSchool.studentsOf);
    print(americanSchool.studentsOf);
---

$(P
The first elements of the two schools are swapped:
)

$(SHELL
 $(HILITE Mary(10)) Derya(2) Damla(3)
 $(HILITE Ebru(1)) Jane(20)
)

$(P
$(IX filter, std.algorithm) As another example, let's now look at the $(C std.algorithm.filter) algorithm. $(C filter()) returns a special range that filters out elements that do not satisfy a specific condition (a $(I predicate)). The operation of filtering out the elements only affects accessing the elements; the original range is preserved.
)

$(P
$(IX predicate) Predicates are expressions that must evaluate to $(C true) for the elements that are considered to satisfy a condition, and $(C false) for the elements that do not. There are a number of ways of specifying the predicate that $(C filter()) should use. As we have seen in earlier examples, one way is to use a lambda expression. The parameter $(C a) below represents each student:
)

---
    school.studentsOf.filter!(a => a.number % 2)
---

$(P
The predicate above selects the elements of the range $(C school.studentsOf) that have odd numbers.
)

$(P
Like $(C take()), $(C filter()) returns a special range object as well. That range object in turn can be passed to other range functions. For example, it can be passed to $(C print()):
)

---
    print(school.studentsOf.filter!(a => a.number % 2));
---

$(P
That expression can be explained as $(I start with the range $(C school.studentsOf), construct a range object that will filter out the elements of that initial range, and pass the new range object to $(C print())).
)

$(P
The output consists of students with odd numbers:
)

$(SHELL
 Ebru(1) Damla(3)
)

$(P
As long as it returns $(C true) for the elements that satisfy the condition, the predicate can also be specified as a function:
)

---
import std.array;

// ...

    bool startsWithD(Student student) {
        return student.name.front == 'D';
    }

    print(school.studentsOf.filter!startsWithD);
---

$(P
The predicate function above returns $(C true) for students having names starting with the letter D, and $(C false) for the others.
)

$(P
$(I $(B Note:) Using $(C student.name[0]) would have meant the first UTF-8 code unit, not the first letter. As I have mentioned above, $(C front) uses $(C name) as a range and always returns the first Unicode character.)
)

$(P
This time the students whose names start with D are selected and printed:
)

$(SHELL
 Derya(2) Damla(3)
)

$(P
$(IX generate, std.range) $(C generate()), a convenience function template of the $(C std.range) module, makes it easy to present values returned from a function as the elements of an $(C InputRange). It takes any callable entity (function pointer, delegate, etc.) and returns an $(C InputRange) object conceptually consisting of the values that are returned from that callable entity.
)

$(P
The returned range object is infinite. Every time the $(C front) property of that range object is accessed, the original callable entity is called to get a new $(I element) from it. The $(C popFront()) function of the range object does not perform any work.
)

$(P
For example, the following range object $(C diceThrower) can be used as an infinite range:
)

---
import std.stdio;
import std.range;
import std.random;

void main() {
    auto diceThrower = $(HILITE generate)!(() => uniform(0, 6));
    writeln(diceThrower.take(10));
}
---

$(SHELL
[1, 0, 3, 5, 5, 1, 5, 1, 0, 4]
)

$(H6 $(IX lazy range) Laziness)

$(P
Another benefit of functions' returning range objects is that, those objects can be used lazily. Lazy ranges produce their elements one at a time and only when needed. This may be essential for execution speed and memory consumption. Indeed, the fact that infinite ranges can even exist is made possible by ranges being lazy.
)

$(P
Lazy ranges produce their elements one at a time and only when needed. We see an example of this with the $(C FibonacciSeries) range: The elements are calculated by $(C popFront()) only as they are needed. If $(C FibonacciSeries) were an eager range and tried to produce all of the elements up front, it could never end or find room for the elements that it produced.
)

$(P
Another problem of eager ranges is the fact that they would have to spend time and space for elements that would perhaps never going to be used.
)

$(P
Like most of the algorithms in Phobos, $(C take()) and $(C filter()) benefit from laziness. For example, we can pass $(C FibonacciSeries) to $(C take()) and have it generate a finite number of elements:
)

---
    print(FibonacciSeries().take(10));
---

$(P
Although $(C FibonacciSeries) is infinite, the output contains only the first 10 numbers:
)

$(SHELL
 0 1 1 2 3 5 8 13 21 34
)

$(H5 $(IX ForwardRange) $(C ForwardRange))

$(P
$(C InputRange) models a range where elements are taken out of the range as they are iterated over.
)

$(P
Some ranges are capable of saving their states, as well as operating as an $(C InputRange). For example, $(C FibonacciSeries) objects can save their states because these objects can freely be copied and the two copies continue their lives independently from each other.
)

$(P
$(IX save) $(C ForwardRange) provides the $(C save) member function, which is expected to return a copy of the range. The copy that $(C save) returns must operate independently from the range object that it was copied from: iterating over one copy must not affect the other copy.
)

$(P
Importing $(C std.array) automatically makes slices become $(C ForwardRange) ranges.
)

$(P
In order to implement $(C save) for $(C FibonacciSeries), we can simply return a copy of the object:
)

---
$(CODE_NAME FibonacciSeries)struct FibonacciSeries {
// ...

    FibonacciSeries save() const {
        return this;
    }
$(CODE_XREF FibonacciSeries_InputRange)}
---

$(P
The returned copy is a separate range that would continue from the point where it was copied from.
)

$(P
$(IX popFrontN, std.range) We can demonstrate that the copied object is independent from the actual range with the following program. The algorithm $(C std.range.popFrontN()) in the following code removes a specified number of elements from the specified range:
)

---
$(CODE_XREF FibonacciSeries)import std.range;

// ...

void report(T)(const dchar[] title, const ref T range) {
    writefln("%40s: %s", title, range.take(5));
}

void main() {
    auto range = FibonacciSeries();
    report("Original range", range);

    range.popFrontN(2);
    report("After removing two elements", range);

    auto theCopy = $(HILITE range.save);
    report("The copy", theCopy);

    range.popFrontN(3);
    report("After removing three more elements", range);
    report("The copy", theCopy);
}
---

$(P
The output of the program shows that removing elements from the range does not affect its saved copy:
)

$(SHELL
                          Original range: [0, 1, 1, 2, 3]
             After removing two elements: [1, 2, 3, 5, 8]
                                $(HILITE The copy: [1, 2, 3, 5, 8])
      After removing three more elements: [5, 8, 13, 21, 34]
                                $(HILITE The copy: [1, 2, 3, 5, 8])
)

$(P
Also note that the range is passed directly to $(C writefln) in $(C report()). Like our $(C print()) function, the output functions of the $(C stdio) module can take $(C InputRange) objects. I will use $(C stdio)'s output functions from now on.
)

$(P
$(IX cycle, std.range) An algorithm that works with $(C ForwardRange) is $(C std.range.cycle). $(C cycle()) iterates over the elements of a range repeatedly from the beginning to the end. In order to be able to start over from the beginning it must be able to save a copy of the initial state of the range, so it requires a $(C ForwardRange).
)

$(P
Since $(C FibonacciSeries) is now a $(C ForwardRange), we can try $(C cycle()) with a $(C FibonacciSeries) object; but in order to avoid having $(C cycle()) iterate over an infinite range, and as a result never find the end of it, we must first make a finite range by passing $(C FibonacciSeries) through $(C take()):
)

---
    writeln(FibonacciSeries().take(5).cycle.take(20));
---

$(P
In order to make the resultant range finite as well, the range that is returned by $(C cycle) is also passed through $(C take()). The output consists of $(I the first twenty elements of cycling through the first five elements of $(C FibonacciSeries)):
)

$(SHELL
[0, 1, 1, 2, 3, 0, 1, 1, 2, 3, 0, 1, 1, 2, 3, 0, 1, 1, 2, 3]
)

$(P
We could have defined intermediate variables as well. The following is an equivalent of the single-line code above:
)

---
    auto series                   = FibonacciSeries();
    auto firstPart                = series.take(5);
    auto cycledThrough            = firstPart.cycle;
    auto firstPartOfCycledThrough = cycledThrough.take(20);

    writeln(firstPartOfCycledThrough);
---

$(P
I would like to point out the importance of laziness one more time: The first four lines above merely construct range objects that will eventually produce the elements. The numbers that are part of the result are calculated by $(C FibonacciSeries.popFront()) as needed.
)

$(P
$(I $(B Note:) Although we have started with $(C FibonacciSeries) as a $(C ForwardRange), we have actually passed the result of $(C FibonacciSeries().take(5)) to $(C cycle()). $(C take()) is adaptive: the range that it returns is a $(C ForwardRange) if its parameter is a $(C ForwardRange). We will see how this is accomplished with $(C isForwardRange) in the next chapter.)
)

$(H5 $(IX BidirectionalRange) $(C BidirectionalRange))

$(P
$(IX back) $(IX popBack) $(C BidirectionalRange) provides two member functions over the member functions of $(C ForwardRange). $(C back) is similar to $(C front): it provides access to the last element of the range. $(C popBack()) is similar to $(C popFront()): it removes the last element from the range.
)

$(P
Importing $(C std.array) automatically makes slices become $(C BidirectionalRange) ranges.
)

$(P
$(IX retro, std.range) A good $(C BidirectionalRange) example is the $(C std.range.retro) function. $(C retro()) takes a $(C BidirectionalRange) and ties its $(C front) to $(C back), and $(C popFront()) to $(C popBack()). As a result, the original range is iterated over in reverse order:
)

---
    writeln([ 1, 2, 3 ].retro);
---

$(P
The output:
)

$(SHELL
[3, 2, 1]
)

$(P
Let's define a range that behaves similarly to the special range that $(C retro()) returns. Although the following range has limited functionality, it shows how powerful ranges are:
)

---
import std.array;
import std.stdio;

struct Reversed {
    int[] range;

    this(int[] range) {
        this.range = range;
    }

    bool empty() const {
        return range.empty;
    }

    int $(HILITE front)() const {
        return range.$(HILITE back);  // ← reverse
    }

    int back() const {
        return range.front; // ← reverse
    }

    void popFront() {
        range.popBack();    // ← reverse
    }

    void popBack() {
        range.popFront();   // ← reverse
    }
}

void main() {
    writeln(Reversed([ 1, 2, 3]));
}
---

$(P
The output is the same as $(C retro()):
)

$(SHELL
[3, 2, 1]
)

$(H5 $(IX RandomAccessRange) $(C RandomAccessRange))

$(P
$(IX opIndex) $(C RandomAccessRange) represents ranges that allow accessing elements by the $(C []) operator. As we have seen in the $(LINK2 operator_overloading.html, Operator Overloading chapter), $(C []) operator is defined by the $(C opIndex()) member function.
)

$(P
Importing $(C std.array) module makes slices become $(C RandomAccessRange) ranges only if possible. For example, since UTF-8 and UTF-16 encodings do not allow accessing Unicode characters by an index, $(C char) and $(C wchar) arrays cannot be used as $(C RandomAccessRange) ranges of Unicode characters. On the other hand, since the codes of the UTF-32 encoding correspond one-to-one to Unicode character codes, $(C dchar) arrays can be used as $(C RandomAccessRange) ranges of Unicode characters.
)

$(P
$(IX constant time access) It is natural that every type would define the $(C opIndex()) member function according to its functionality. However, computer science has an expectation on its algorithmic complexity: random access must take $(I constant time). Constant time access means that the time spent when accessing an element is independent of the number of elements in the container. Therefore, no matter how large the range is, element access should not depend on the length of the range.
)

$(P
In order to be considered a $(C RandomAccessRange), $(I one) of the following conditions must also be satisfied:
)

$(UL
$(LI to be an infinite $(C ForwardRange))
)

$(P
or
)

$(UL
$(LI $(IX length, BidirectionalRange) to be a $(C BidirectionalRange) that also provides the $(C length) property)
)

$(P
Depending on the condition that is satisfied, the range is either infinite or finite.
)

$(H6 Infinite $(C RandomAccessRange))

$(P
The following are all of the requirements of a $(C RandomAccessRange) that is based on an $(I infinite $(C ForwardRange)):
)

$(UL
$(LI $(C empty), $(C front) and $(C popFront()) that $(C InputRange) requires)
$(LI $(C save) that $(C ForwardRange) requires)
$(LI $(C opIndex()) that $(C RandomAccessRange) requires)
$(LI the value of $(C empty) to be known at compile time as $(C false))
)

$(P
We were able to define $(C FibonacciSeries) as a $(C ForwardRange). However, $(C opIndex()) cannot be implemented to operate at constant time for $(C FibonacciSeries) because accessing an element requires accessing all of the previous elements first.
)

$(P
As an example where $(C opIndex()) can operate at constant time, let's define an infinite range that consists of squares of integers. Although the following range is infinite, accessing any one of its elements can happen at constant time:
)

---
class SquaresRange {
    int first;

    this(int first = 0) {
        this.first = first;
    }

    enum empty = false;

    int front() const {
        return opIndex(0);
    }

    void popFront() {
        ++first;
    }

    SquaresRange save() const {
        return new SquaresRange(first);
    }

    int opIndex(size_t index) const {
         /* This function operates at constant time */
        immutable integerValue = first + cast(int)index;
        return integerValue * integerValue;
    }
}
---

$(P
$(I $(B Note:) It would make more sense to define $(C SquaresRange) as a $(C struct).)
)

$(P
Although no space has been allocated for the elements of this range, the elements can be accessed by the $(C []) operator:
)

---
    auto squares = new SquaresRange();

    writeln(squares$(HILITE [5]));
    writeln(squares$(HILITE [10]));
---

$(P
The output contains the elements at indexes 5 and 10:
)

$(SHELL
25
100
)

$(P
The element with index 0 should always represent the first element of the range. We can take advantage of $(C popFrontN()) when testing whether this really is the case:
)

---
    squares.popFrontN(5);
    writeln(squares$(HILITE [0]));
---

$(P
The first 5 elements of the range are 0, 1, 4, 9 and 16; the squares of 0, 1, 2, 3 and 4. After removing those, the square of the next value becomes the first element of the range:
)

$(SHELL
25
)

$(P
Being a $(C RandomAccessRange) (the most functional range), $(C SquaresRange) can also be used as other types of ranges. For example, as an $(C InputRange) when passing to $(C filter()):
)

---
    bool are_lastTwoDigitsSame(int value) {
        /* Must have at least two digits */
        if (value < 10) {
            return false;
        }

        /* Last two digits must be divisible by 11 */
        immutable lastTwoDigits = value % 100;
        return (lastTwoDigits % 11) == 0;
    }

    writeln(squares.take(50).filter!are_lastTwoDigitsSame);
---

$(P
The output consists of elements among the first 50, where last two digits are the same:
)

$(SHELL
[100, 144, 400, 900, 1444, 1600]
)

$(H6 Finite $(C RandomAccessRange))

$(P
The following are all of the requirements of a $(C RandomAccessRange) that is based on a $(I finite $(C BidirectionalRange)):
)

$(UL
$(LI $(C empty), $(C front) and $(C popFront()) that $(C InputRange) requires)
$(LI $(C save) that $(C ForwardRange) requires)
$(LI $(C back) and $(C popBack()) that $(C BidirectionalRange) requires)
$(LI $(C opIndex()) that $(C RandomAccessRange) requires)
$(LI $(C length), which provides the length of the range)
)

$(P
$(IX chain, std.range) As an example of a finite $(C RandomAccessRange), let's define a range that works similarly to $(C std.range.chain). $(C chain()) presents the elements of a number of separate ranges as if they are elements of a single larger range. Although $(C chain()) works with any type of element and any type of range, to keep the example short, let's implement a range that works only with $(C int) slices.
)

$(P
Let's name this range $(C Together) and expect the following behavior from it:
)

---
    auto range = Together([ 1, 2, 3 ], [ 101, 102, 103]);
    writeln(range[4]);
---

$(P
When constructed with the two separate arrays above, $(C range) should present all of those elements as a single range. For example, although neither array has an element at index 4, the element 102 should be the element that corresponds to index 4 of the collective range:
)

$(SHELL
102
)

$(P
As expected, printing the entire range should contain all of the elements:
)

---
    writeln(range);
---

$(P
The output:
)

$(SHELL
[1, 2, 3, 101, 102, 103]
)

$(P
$(C Together) will operate lazily: the elements will not be copied to a new larger array; they will be accessed from the original slices.
)

$(P
We can take advantage of $(I variadic functions), which were introduced in the $(LINK2 parameter_flexibility.html, Variable Number of Parameters chapter), to initialize the range by any number of original slices:
)

---
struct Together {
    const(int)[][] slices;

    this(const(int)[][] slices$(HILITE ...)) {
        this.slices = slices.dup;

        clearFront();
        clearBack();
    }

// ...
}
---

$(P
Note that the element type is $(C const(int)), indicating that this $(C struct) will not modify the elements of the ranges. However, the slices will necessarily be modified by $(C popFront()) to implement iteration.
)

$(P
The $(C clearFront()) and $(C clearBack()) calls that the constructor makes are to remove empty slices from the beginning and the end of the original slices. Such empty slices do not change the behavior of $(C Together) and removing them up front will simplify the implementation:
)

---
struct Together {
// ...

    private void clearFront() {
        while (!slices.empty && slices.front.empty) {
            slices.popFront();
        }
    }

    private void clearBack() {
        while (!slices.empty && slices.back.empty) {
            slices.popBack();
        }
    }
}
---

$(P
We will call those functions later from $(C popFront()) and $(C popBack()) as well.
)

$(P
Since $(C clearFront()) and $(C clearBack()) remove all of the empty slices from the beginning and the end, still having a slice would mean that the collective range is not yet empty. In other words, the range should be considered empty only if there is no slice left:
)

---
struct Together {
// ...

    bool empty() const {
        return slices.empty;
    }
}
---

$(P
The first element of the first slice is the first element of this $(C Together) range:
)

---
struct Together {
// ...

    int front() const {
        return slices.front.front;
    }
}
---

$(P
Removing the first element of the first slice removes the first element of this range as well. Since this operation may leave the first slice empty, we must call $(C clearFront()) to remove that empty slice and the ones that are after that one:
)

---
struct Together {
// ...

    void popFront() {
        slices.front.popFront();
        clearFront();
    }
}
---

$(P
A copy of this range can be constructed from a copy of the $(C slices) member:
)

---
struct Together {
// ...

    Together save() const {
        return Together(slices.dup);
    }
}
---

$(P
$(I Please note that $(C .dup) copies only $(C slices) in this case, not the slice elements that it contains.)
)

$(P
The operations at the end of the range are similar to the ones at the beginning:
)

---
struct Together {
// ...

    int back() const {
        return slices.back.back;
    }

    void popBack() {
        slices.back.popBack();
        clearBack();
    }
}
---

$(P
The length of the range can be calculated as the sum of the lengths of the slices:
)

---
struct Together {
// ...

    size_t length() const {
        size_t totalLength = 0;

        foreach (slice; slices) {
            totalLength += slice.length;
        }

        return totalLength;
    }
}
---

$(P
$(IX fold, std.algorithm) Alternatively, the length may be calculated with less code by taking advantage of $(C std.algorithm.fold). $(C fold()) takes an operation as its template parameter and applies that operation to all elements of a range:
)

---
import std.algorithm;

// ...

    size_t length() const {
        return slices.fold!((a, b) => a + b.length)(size_t.init);
    }
---

$(P
The $(C a) in the template parameter represents the current result ($(I the sum) in this case) and $(C b) represents the current element. The first function parameter is the range that contains the elements and the second function parameter is the initial value of the result ($(C size_t.init) is 0). (Note how $(C slices) is written before $(C fold) by taking advantage of $(LINK2 ufcs.html, UFCS).)
)

$(P
$(I $(B Note:) Further, instead of calculating the length every time when $(C length) is called, it may be measurably faster to maintain a member variable perhaps named $(C length_), which always equals the correct length of the collective range. That member may be calculated once in the constructor and adjusted accordingly as elements are removed by $(C popFront()) and $(C popBack()).)
)

$(P
One way of returning the element that corresponds to a specific index is to look at every slice to determine whether the element would be among the elements of that slice:
)

---
struct Together {
// ...

    int opIndex(size_t index) const {
        /* Save the index for the error message */
        immutable originalIndex = index;

        foreach (slice; slices) {
            if (slice.length > index) {
                return slice[index];

            } else {
                index -= slice.length;
            }
        }

        throw new Exception(
            format("Invalid index: %s (length: %s)",
                   originalIndex, this.length));
    }
}
---

$(P
$(I $(B Note:) This $(C opIndex()) does not satisfy the constant time requirement that has been mentioned above. For this implementation to be acceptably fast, the $(C slices) member must not be too long.)
)

$(P
This new range is now ready to be used with any number of $(C int) slices. With the help of $(C take()) and $(C array()), we can even include the range types that we have defined earlier in this chapter:
)

---
    auto range = Together(FibonacciSeries().take(10).array,
                          [ 777, 888 ],
                          (new SquaresRange()).take(5).array);

    writeln(range.save);
---

$(P
The elements of the three slices are accessed as if they were elements of a single large array:
)

$(SHELL
[0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 777, 888, 0, 1, 4, 9, 16]
)

$(P
We can pass this range to other range algorithms. For example, to $(C retro()), which requires a $(C BidirectionalRange):
)

---
    writeln(range.save.retro);
---

$(P
The output:
)

$(SHELL
[16, 9, 4, 1, 0, 888, 777, 34, 21, 13, 8, 5, 3, 2, 1, 1, 0]
)

$(P
Of course you should use the more functional $(C std.range.chain) instead of $(C Together) in your programs.
)

$(H5 $(IX OutputRange) $(C OutputRange))

$(P
All of the range types that we have seen so far are about element access. $(C OutputRange) represents streamed element output, similar to sending characters to $(C stdout).
)

$(P
$(IX put) I have mentioned earlier that $(C OutputRange) requires support for the $(C put(range,&nbsp;element)) operation. $(C put()) is a function defined in the $(C std.range) module. It determines the capabilities of the range and the element at compile time and uses the most appropriate method to $(I output) the element.
)

$(P
$(C put()) considers the following cases in the order that they are listed below, and applies the method for the first matching case. $(C R) represents the type of the range; $(C range), a range object; $(C E), the type of the element; and $(C e) an element of the range:
)

$(TABLE full,
$(HEAD2 Case Considered, Method Applied)
$(ROW2
$(C R) has a member function named $(C put)$(BR)
and $(C put) can take an $(C E) as argument,

$(C range.put(e);)

)
$(ROW2
$(C R) has a member function named $(C put)$(BR)
and $(C put) can take an $(C E[]) as argument,

$(C range.put([ e ]);)

)
$(ROW2
$(C R) is an $(C InputRange)$(BR)
and $(C e) can be assigned to $(C range.front),

$(C range.front = e;)
$(BR)
$(C range.popFront();)

)
$(ROW2
$(C E) is an $(C InputRange)$(BR)
and can be copied to $(C R),

$(C for (; !e.empty; e.popFront()))
$(BR)
$(C put(range, e.front);)

)
$(ROW2
$(C R) can take $(C E) as argument$(BR)
(e.g. $(C R) could be a delegate),

$(C range(e);)

)
$(ROW2
$(C R) can take $(C E[]) as argument$(BR)
(e.g. $(C R) could be a delegate),

$(C range([ e ]);)

)
)

$(P
Let's define a range that matches the first case: The range will have a member function named $(C put()), which takes a parameter that matches the type of the output range.
)

$(P
This output range will be used for outputting elements to multiple files, including $(C stdout). When elements are outputted with $(C put()), they will all be written to all of those files. As an additional functionality, let's add the ability to specify a delimiter to be written after each element.
)

---
$(CODE_NAME MultiFile)struct MultiFile {
    string delimiter;
    File[] files;

    this(string delimiter, string[] fileNames...) {
        this.delimiter = delimiter;

        /* stdout is always included */
        this.files ~= stdout;

        /* A File object for each file name */
        foreach (fileName; fileNames) {
            this.files ~= File(fileName, "w");
        }
    }

    // This is the version that takes arrays (but not strings)
    void put(T)(T slice)
            if (isArray!T && !isSomeString!T) {
        foreach (element; slice) {
            // Note that this is a call to the other version
            // of put() below
            put(element);
        }
    }

    // This is the version that takes non-arrays and strings
    void put(T)(T value)
            if (!isArray!T || isSomeString!T) {
        foreach (file; files) {
            file.write(value, delimiter);
        }
    }
}
---

$(P
In order to be used as an output range of any type of elements, $(C put()) is also templatized on the element type.
)

$(P
$(IX copy, std.algorithm) An algorithm in Phobos that uses $(C OutputRange) is $(C std.algorithm.copy). $(C copy()) is a very simple algorithm, which copies the elements of an $(C InputRange) to an $(C OutputRange).
)

---
import std.traits;
import std.stdio;
import std.algorithm;

$(CODE_XREF MultiFile)// ...

void main() {
    auto output = MultiFile("\n", "output_0", "output_1");
    copy([ 1, 2, 3], output);
    copy([ "red", "blue", "green" ], output);
}
---

$(P
That code outputs the elements of the input ranges both to $(C stdout) and to files named "output_0" and "output_1":
)

$(SHELL
1
2
3
red
blue
green
)

$(H6 $(IX slice, as OutputRange) Using slices as $(C OutputRange))

$(P
The $(C std.range) module makes slices $(C OutputRange) objects as well. (By contrast, $(C std.array) makes them only input ranges.) Unfortunately, using slices as $(C OutputRange) objects has a confusing effect: slices lose an element for each $(C put()) operation on them; and that element is the element that has just been outputted!
)

$(P
The reason for this behavior is a consequence of slices' not having a $(C put()) member function. As a result, the third case of the previous table is matched for slices and the following method is applied:
)

---
    range.front = e;
    range.popFront();
---

$(P
As the code above is executed for each $(C put()), the front element of the slice is assigned to the value of the $(I outputted) element, to be subsequently removed from the slice with $(C popFront()):
)

---
import std.stdio;
import std.range;

void main() {
    int[] slice = [ 1, 2, 3 ];
    $(HILITE put(slice, 100));
    writeln(slice);
}
---

$(P
As a result, although the slice is used as an $(C OutputRange), it surprisingly $(I loses) elements:
)

$(SHELL
[2, 3]
)

$(P
To avoid this, a separate slice must be used as an $(C OutputRange) instead:
)

---
import std.stdio;
import std.range;

void main() {
    int[] slice = [ 1, 2, 3 ];
    int[] slice2 = slice;

    put($(HILITE slice2), 100);

    writeln(slice2);
    writeln(slice);
}
---

$(P
This time the second slice is consumed and the original slice has the expected elements:
)

$(SHELL
[2, 3]
[100, 2, 3]    $(SHELL_NOTE expected result)
)

$(P
Another important fact is that the length of the slice does not grow when used as an $(C OutputRange). It is the programmer's responsibility to ensure that there is enough room in the slice:
)

---
    int[] slice = [ 1, 2, 3 ];
    int[] slice2 = slice;

    foreach (i; 0 .. 4) {    // ← no room for 4 elements
        put(slice2, i * 100);
    }
---

$(P
When the slice becomes completely empty because of the indirect $(C popFront()) calls, the program terminates with an exception:
)

$(SHELL
core.exception.AssertError@...: Attempting to fetch the $(HILITE front
of an empty array of int)
)

$(P
$(IX appender, std.array) $(C std.array.Appender) and its convenience function $(C appender) allows using slices as $(I an $(C OutputRange) where the elements are appended). The $(C put()) function of the special range object that $(C appender()) returns actually appends the elements to the original slice:
)

---
import std.array;

// ...

    auto a = appender([ 1, 2, 3 ]);

    foreach (i; 0 .. 4) {
        a.put(i * 100);
    }
---

$(P
In the code above, $(C appender) is called with an array and returns a special range object. That range object is in turn used as an $(C OutputRange) by calling its $(C put()) member function. The resultant elements are accessed by its $(C .data) property:
)

---
    writeln(a.data);
---

$(P
The output:
)

$(SHELL
[1, 2, 3, 0, 100, 200, 300]
)

$(P
$(C Appender) supports the $(C ~=) operator as well:
)

---
    a $(HILITE ~=) 1000;
    writeln(a.data);
---

$(P
The output:
)

$(SHELL
[1, 2, 3, 0, 100, 200, 300, 1000]
)

$(H6 $(IX toString, OutputRange) $(C toString()) with an $(C OutputRange) parameter)

$(P
Similar to how $(C toString) member functions can be defined as $(LINK2 lambda.html, taking a $(C delegate) parameter), it is possible to define one that takes an $(C OutputRange). Functions like $(C format), $(C writefln), and $(C writeln) operate more efficiently by placing the output characters right inside the output buffer of the output range.
)

$(P
To be able to work with any $(C OutputRange) type, such $(C toString) definitions need to be function templates, optionally with template constraints:
)

---
import std.stdio;
import std.range;

struct S {
    void toString(O)(ref O o) const
            if (isOutputRange!(O, char)) {
        $(HILITE put)(o, "hello");
    }
}

void main() {
    auto s = S();
    writeln(s);
}
---

$(P
Note that the code inside $(C main()) does not define an $(C OutputRange) object. That object is defined by $(C writeln) to store the characters before printing them:
)

$(SHELL
hello
)

$(H5 Range templates)

$(P
Although we have used mostly $(C int) ranges in this chapter, ranges and range algorithms are much more useful when defined as templates.
)

$(P
The $(C std.range) module includes many range templates. We will see these templates in the next chapter.
)

$(H5 Summary)

$(UL

$(LI Ranges abstract data structures from algorithms and allow them to be used with algorithms seamlessly.)

$(LI Ranges are a D concept and are the basis for many features of Phobos.)

$(LI Many Phobos algorithms return lazy range objects to accomplish their special tasks.)

$(LI UFCS works well with range algorithms.)

$(LI When used as $(C InputRange) objects, the elements of strings are Unicode characters.)

$(LI $(C InputRange) requires $(C empty), $(C front) and $(C popFront()).)

$(LI $(C ForwardRange) additionally requires $(C save).)

$(LI $(C BidirectionalRange) additionally requires $(C back) and $(C popBack()).)

$(LI Infinite $(C RandomAccessRange) requires $(C opIndex()) over $(C ForwardRange).)

$(LI Finite $(C RandomAccessRange) requires $(C opIndex()) and $(C length) over $(C BidirectionalRange).)

$(LI $(C std.array.appender) returns an $(C OutputRange) that appends to slices.)

$(LI Slices are ranges of finite $(C RandomAccessRange))

$(LI Fixed-length arrays are not ranges.)

)

macros:
        TITLE=Ranges

        DESCRIPTION=Phobos ranges that abstract data structures from algorithms and that enables them to be used seamlessly.

        KEYWORDS=d programming language tutorial book range OutputRange InputRange ForwardRange BidirectionalRange RandomAccessRange

MINI_SOZLUK=
