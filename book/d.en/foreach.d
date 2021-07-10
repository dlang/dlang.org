Ddoc

$(DERS_BOLUMU $(IX foreach) $(IX loop, foreach) $(CH4 foreach) Loop)

$(P
One of the most common statements in D is the $(C foreach) loop. It is used for applying the same operations to every element of a container (or a $(I range)).
)

$(P
Operations that are applied to elements of containers are very common in programming. We have seen in the $(LINK2 for.html, $(C for) Loop chapter) that elements of an array are accessed in a $(C for) loop by an index value that is incremented at each iteration:
)

---
    for (int i = 0; i != array.length; ++i) {
        writeln(array[i]);
    }
---

$(P
The following steps are involved in iterating over all the elements:
)

$(UL
$(LI Defining a variable as a counter, which is conventionally named as $(C i))

$(LI Iterating the loop up to the value of the $(C .length) property of the array)

$(LI Incrementing $(C i))

$(LI Accessing the element)
)

$(P
$(C foreach) has essentially the same behavior but it simplifies the code by handling those steps automatically:
)

---
    foreach (element; array) {
        writeln(element);
    }
---

$(P
Part of the power of $(C foreach) comes from the fact that it can be used the same way regardless of the type of the container. As we have seen in the previous chapter, one way of iterating over the values of an associative array in a $(C for) loop is by first calling the array's $(C .values) property:
)

---
    auto values = aa$(HILITE .values);
    for (int i = 0; i != values.length; ++i) {
        writeln(values[i]);
    }
---

$(P
$(C foreach) does not require anything special for associative arrays; it is used exactly the same as with arrays:
)

---
    foreach (value; aa) {
        writeln(value);
    }
---

$(H5 The $(C foreach) syntax)

$(P
$(C foreach) consists of three sections:
)

---
    foreach ($(I names); $(I container_or_range)) {
        $(I operations)
    }
---

$(UL
$(LI $(B $(I container_or_range)) specifies where the elements are.
)

$(LI $(B $(I operations)) specifies the operations to apply to each element.
)

$(LI $(B $(I names)) specifies the name of the element and potentially other variables depending on the type of the container or the range. Although the choice of names is up to the programmer, the number of and the types of these names depend on the type of the container.
)
)

$(H5 $(C continue) and $(C break))

$(P
These keywords have the same meaning as they do for the $(C for) loop: $(C continue) moves to the next iteration before completing the rest of the operations for the current element, and $(C break) terminates the loop altogether.
)

$(H5 $(C foreach) with arrays)

$(P
When using $(C foreach) with plain arrays and there is a single name specified in the $(I names) section, that name represents the value of the element at each iteration:
)

---
    foreach (element; array) {
        writeln(element);
    }
---

$(P
When two names are specified in the $(I names) section, they represent an automatic counter and the value of the element, respectively:
)

---
    foreach (i, element; array) {
        writeln(i, ": ", element);
    }
---

$(P
The counter is incremented automatically by $(C foreach). Although it can be named anything else, $(C i) is a very common name for the automatic counter.
)

$(H5 $(IX stride, std.range) $(C foreach) with strings and $(C std.range.stride))

$(P
Since strings are arrays of characters, $(C foreach) works with strings the same way as it does with arrays: A single name refers to the character, two names refer to the counter and the character, respectively:
)

---
    foreach (c; "hello") {
        writeln(c);
    }

    foreach (i, c; "hello") {
        writeln(i, ": ", c);
    }
---

$(P
However, being UTF code units, $(C char) and $(C wchar) iterate over UTF code units, not Unicode code points:
)

---
    foreach (i, code; "abcçd") {
        writeln(i, ": ", code);
    }
---

$(P
The two UTF-8 code units that make up ç would be accessed as separate elements:
)

$(SHELL
0: a
1: b
2: c
3: 
4: �
5: d
)

$(P
One way of iterating over Unicode characters of strings in a $(C foreach) loop is $(C stride) from the $(C std.range) module. $(C stride) presents the string as a container that consists of Unicode characters. Its second parameter is the number of steps that it should take as it $(I strides) over the characters:
)

---
import std.range;

// ...

    foreach (c; stride("abcçd", 1)) {
        writeln(c);
    }
---

$(P
Regardless of the character type of the string, $(C stride) always presents its elements as Unicode characters:
)

$(SHELL
a
b
c
ç
d
)

$(P
I will explain below why this loop could not include an automatic counter.
)

$(H5 $(C foreach) with associative arrays)

$(P
When using $(C foreach) with associative arrays, a single name refers to the value, while two names refer to the key and the value, respectively:
)

---
    foreach (value; aa) {
        writeln(value);
    }

    foreach (key, value; aa) {
        writeln(key, ": ", value);
    }
---

$(P
$(IX .byKey, foreach) $(IX .byValue, foreach) $(IX .byKeyValue, foreach) Associative arrays can provide their keys and values as $(I ranges) as well. We will see ranges in $(LINK2 ranges.html, a later chapter). $(C .byKey), $(C .byValue), and $(C .byKeyValue) return efficient range objects that are useful in contexts other than $(C foreach) loops as well.
)

$(P
$(C .byValue) does not bring any benefit in $(C foreach) loops over the regular value iteration above. On the other hand, $(C .byKey) is the only efficient way of iterating over $(I just) the keys of an associative array:
)

---
    foreach (key; aa$(HILITE .byKey)) {
        writeln(key);
    }
---

$(P
$(C .byKeyValue) provides each key-value element through a variable that is similar to a $(LINK2 tuples.html, tuple). The key and the value are accessed separately through the $(C .key) and $(C .value) properties of that variable:
)

---
    foreach (element; aa$(HILITE .byKeyValue)) {
        writefln("The value for key %s is %s",
                 element$(HILITE .key), element$(HILITE.value));
    }
---

$(H5 $(IX number range) $(IX .., number range) $(C foreach) with number ranges)

$(P
We have seen number ranges before, in the $(LINK2 slices.html, Slices and Other Array Features chapter). It is possible to specify a number range in the $(I container_or_range) section:
)

---
    foreach (number; 10..15) {
        writeln(number);
    }
---

$(P
Remember that 10 would be included in the range but 15 would not be.
)

$(H5 $(C foreach) with structs, classes, and ranges)

$(P
$(C foreach) can also be used with objects of user-defined types that define their own iteration in $(C foreach) loops. Structs and classes provide support for $(C foreach) iteration either by their $(C opApply()) member functions, or by a set of $(I range) member functions. We will see these features in later chapters.
)

$(H5 $(IX counter, foreach) The counter is automatic only for arrays)

$(P
The automatic counter is provided only when iterating over arrays. There are two options for other containers
)
$(UL
$(LI Taking advantage of $(C std.range.enumerate) as we will see later in $(LINK2 foreach_opapply.html, the $(C foreach) with Structs and Classes chapter).)

$(LI Defining and incrementing a counter variable explicitly:

---
    size_t $(HILITE i) = 0;
    foreach (element; container) {
        // ...
        ++i;
    }
---
)
)

$(P
Such a variable is needed when counting a specific condition as well. For example, the following code counts only the values that are divisible by 10:
)

---
import std.stdio;

void main() {
    auto numbers = [ 1, 0, 15, 10, 3, 5, 20, 30 ];

    size_t count = 0;
    foreach (number; numbers) {
        if ((number % 10) == 0) {
            $(HILITE ++count);
            write(count);

        } else {
            write(' ');
        }

        writeln(": ", number);
    }
}
---

$(P
The output:
)

$(SHELL

 : 1
1: 0
 : 15
2: 10
 : 3
 : 5
3: 20
4: 30
)

$(H5 The copy of the element, not the element itself)

$(P
The $(C foreach) loop normally provides a copy of the element, not the actual element that is stored in the container. This may be a cause of bugs.
)

$(P
To see an example of this, let's have a look at the following program that is trying to double the values of the elements of an array:
)

---
import std.stdio;

void main() {
    double[] numbers = [ 1.2, 3.4, 5.6 ];

    writefln("Before: %s", numbers);

    foreach (number; numbers) {
        number *= 2;
    }

    writefln("After : %s", numbers);
}
---

$(P
The output of the program indicates that the assignment made to each element inside the $(C foreach) body does not have any effect on the elements of the container:
)

$(SHELL
Before: [1.2, 3.4, 5.6]
After : [1.2, 3.4, 5.6]
)

$(P
$(IX ref, foreach) That is because $(C number) is not an actual element of the array, but a copy of each element. When the actual elements need to be operated on, the name must be defined as a $(I reference) of the actual element, by using the $(C ref) keyword:
)

---
    foreach ($(HILITE ref) number; numbers) {
        number *= 2;
    }
---

$(P
The new output shows that the assignments now modify the actual elements of the array:
)

$(SHELL
Before: [1.2, 3.4, 5.6]
After : [2.4, 6.8, 11.2]
)

$(P
The $(C ref) keyword makes $(C number) an $(I alias) of the actual element at each iteration. As a result, the modifications through $(C number) modify that actual element of the container.
)

$(H5 The integrity of the container must be preserved)

$(P
Although it is fine to modify the elements of a container through $(C ref) variables, the structure of a container must not be changed during its iteration. For example, elements must not be removed nor added to the container during a $(C foreach) loop.
)

$(P
Such modifications may confuse the inner workings of the loop iteration and result in incorrect program states.
)

$(H5 $(IX foreach_reverse) $(IX loop, foreach_reverse) $(C foreach_reverse) to iterate in the reverse direction)

$(P
$(C foreach_reverse) works the same way as $(C foreach) except it iterates in the reverse direction:
)

---
    auto container = [ 1, 2, 3 ];

    foreach_reverse (element; container) {
        writefln("%s ", element);
    }
---

$(P
The output:
)

$(SHELL
3 
2 
1 
)

$(P
The use of $(C foreach_reverse) is not common because the range function $(C retro()) achieves the same goal. We will see $(C retro()) in a later chapter.
)

$(PROBLEM_TEK

$(P
We know that associative arrays provide a mapping from keys to values. This mapping is unidirectional: values are accessed by keys but not the other way around.
)

$(P
Assume that there is already the following associative array:
)

---
    string[int] names = [ 1:"one", 7:"seven", 20:"twenty" ];
---

$(P
Use that associative array and a $(C foreach) loop to fill another associative array named $(C values). The new associative array should provide values that correspond to names. For example, the following line should print 20:
)

---
    writeln(values["twenty"]);
---

)


Macros:
        TITLE=foreach Loop

        DESCRIPTION=The foreach loop that is used to iterate over the elements of containers.

        KEYWORDS=d programming language tutorial book foreach
