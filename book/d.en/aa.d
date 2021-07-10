Ddoc

$(DERS_BOLUMU $(IX associative array) $(IX AA) Associative Arrays)

$(P
Associative arrays are a feature that is found in most modern high-level languages. They are very fast data structures that work like mini databases and are used in many programs.
)

$(P
We saw in the $(LINK2 arrays.html, Arrays chapter) that plain arrays are containers that store their elements side-by-side and provide access to them by index. An array that stores the names of the days of the week can be defined like this:
)

---
    string[] dayNames =
        [ "Monday", "Tuesday", "Wednesday", "Thursday",
          "Friday", "Saturday", "Sunday" ];
---

$(P
The name of a specific day can be accessed by its index in that array:
)

---
    writeln(dayNames[1]);   // prints "Tuesday"
---

$(P
The fact that plain arrays provide access to their values through index numbers can be described as an $(I association) of indexes with values. In other words, arrays map indexes to values. Plain arrays can use only integers as indexes.
)

$(P
Associative arrays allow indexing not only using integers but also using any other type. They map the values of one type to the values of another type. The values of the type that associative arrays $(I map from) are called $(I keys), rather than indexes. Associative arrays store their elements as key-value pairs.
)

$(P
Associative arrays are implemented in D using a $(I hash table). Hash tables are among the fastest collections for storing and accessing elements. Other than in rare pathological cases, the time it takes to store or access an element is independent of the number of elements that are in the associative array.
)

$(P
The high performance of hash tables comes at the expense of storing the elements in an unordered way. Also, unlike arrays, the elements of hash tables are not stored side-by-side.
)

$(P
For plain arrays, index values are not stored at all. Because array elements are stored side-by-side in memory, index values are implicitly the relative positions of elements from the beginning of the array.
)

$(P
On the other hand, associative arrays do store both the keys and the values of elements. Although this difference makes associative arrays use more memory, it also allows them to use $(I sparse) key values. For example, when there are just two elements to store for keys 0 and 999, an associative array stores just two elements, not 1000 as a plain array has to.
)

$(H5 Definition)

$(P
The syntax of associative arrays is similar to the array syntax. The difference is that it is the type of the key that is specified within the square brackets, not the length of the array:
)

---
    $(I value_type)[$(I key_type)] $(I associative_array_name);
---

$(P
For example, an associative array that maps day names of type $(C string) to day numbers of type $(C int) can be defined like this:
)

---
    int[string] dayNumbers;
---

$(P
The $(C dayNumbers) variable above is an associative array that can be used as a table that provides a mapping from day names to day numbers. In other words, it can be used as the opposite of the $(C dayNames) array at the beginning of this chapter. We will use the $(C dayNumbers) associative array in the examples below.
)

$(P
The keys of associative arrays can be of any type, including user-defined $(C struct) and $(C class) types. We will see user-defined types in later chapters.
)

$(P
The length of associative arrays cannot be specified when defined. They grow automatically as key-value pairs are added.
)

$(P
$(I $(B Note:) An associative array that is defined without any element is $(LINK2 null_is.html, $(C null)), not empty. This distinction has an important consequence when  $(LINK2 function_parameters.html, passing associative arrays to functions). We will cover these concepts in later chapters.)
)

$(H5 Adding key-value pairs)

$(P
Using the assignment operator is sufficient to build the association between a key and a value:
)

---
    // associates value 0 with key "Monday"
    dayNumbers["Monday"] $(HILITE =) 0;

    // associates value 1 with key "Tuesday"
    dayNumbers["Tuesday"] $(HILITE =) 1;
---

$(P
The table grows automatically with each association. For example, $(C dayNumbers) would have two key-value pairs after the operations above. This can be demonstrated by printing the entire table:
)

---
    writeln(dayNumbers);
---

$(P
The output indicates that the values 0 and 1 correspond to keys "Monday" and "Tuesday", respectively:
)

$(SHELL
["Monday":0, "Tuesday":1]
)

$(P
There can be only one value per key. For that reason, when we assign a new key-value pair and the key already exists, the table does not grow; instead, the value of the existing key changes:
)

---
    dayNumbers["Tuesday"] = 222;
    writeln(dayNumbers);
---

$(P
The output:
)

$(SHELL
["Monday":0, "Tuesday":222]
)


$(H5 Initialization)

$(P
$(IX :, associative array) Sometimes some of the mappings between the keys and the values are already known at the time of the definition of the associative array. Associative arrays are initialized similarly to regular arrays, using a colon to separate each key from its respective value:
)

---
    // key : value
    int[string] dayNumbers =
        [ "Monday"   : 0, "Tuesday" : 1, "Wednesday" : 2,
          "Thursday" : 3, "Friday"  : 4, "Saturday"  : 5,
          "Sunday"   : 6 ];

    writeln(dayNumbers["Tuesday"]);    // prints 1
---

$(H5 Removing key-value pairs)

$(P
Key-value pairs can be removed by using $(C .remove()):
)

---
    dayNumbers.remove("Tuesday");
    writeln(dayNumbers["Tuesday"]);    // ← run-time ERROR
---

$(P
The first line above removes the key-value pair "Tuesday" / $(C 1). Since that key is not in the container anymore, the second line would cause an exception to be thrown and the program to be terminated if that exception is not caught. We will see exceptions in $(LINK2 exceptions.html, a later chapter).
)

$(P
$(C .clear) removes all elements:
)

---
    dayNumbers.clear;    // The associative array becomes empty
---

$(H5 $(IX in, associative array) Determining the presence of a key)

$(P
The $(C in) operator determines whether a given key exists in the associative array:
)

---
    int[string] colorCodes = [ /* ... */ ];

    if ("purple" $(HILITE in) colorCodes) {
        // key "purple" exists in the table

    } else {
        // key "purple" does not exist in the table
    }
---

$(P
Sometimes it makes sense to use a default value if a key does not exist in the associative array. For example, the special value of -1 can be used as the code for colors that are not in $(C colorCodes). $(C .get()) is useful in such cases: it returns the value associated with the specified key if that key exists, otherwise it returns the default value. The default value is specified as the second parameter of $(C .get()):
)

---
    int[string] colorCodes = [ "blue" : 10, "green" : 20 ];
    writeln(colorCodes.get("purple", $(HILITE -1)));
---

$(P
Since the array does not contain a value for the key $(STRING "purple"), $(C .get()) returns -1:
)

$(SHELL
-1
)

$(H5 Properties)

$(UL

$(LI $(IX .length) $(C .length) returns the number of key-value pairs.)

$(LI $(IX .keys) $(C .keys) returns a copy of all keys as a dynamic array.)

$(LI $(IX .byKey) $(C .byKey) provides access to the keys without copying them; we will see how $(C .byKey) is used in $(C foreach) loops in the next chapter.)

$(LI $(IX .values) $(C .values) returns a copy of all values as a dynamic array.)

$(LI $(IX .byValue) $(C .byValue) provides access to the values without copying them.)

$(LI $(IX .byKeyValue) $(C .byKeyValue) provides access to the key-value pairs without copying them.)

$(LI $(IX .rehash) $(C .rehash) may make the array more efficient in some cases, such as after inserting a large number of key-value pairs.)

$(LI $(IX .sizeof, associative array) $(C .sizeof) is the size of the array $(I reference) (it has nothing to do with the number of key-value pairs in the table and is the same value for all associative arrays).)

$(LI $(IX .get) $(C .get) returns the value if it exists, the default value otherwise.)

$(LI $(IX .remove, associative array) $(C .remove) removes the specified key and its value from the array.)

$(LI $(IX .clear) $(C .clear) removes all elements.)

)

$(H5 Example)

$(P
Here is a program that prints the Turkish names of colors that are specified in English:
)

---
import std.stdio;
import std.string;

void main() {
    string[string] colors = [ "black" : "siyah",
                              "white" : "beyaz",
                              "red"   : "kırmızı",
                              "green" : "yeşil",
                              "blue"  : "mavi" ];

    writefln("I know the Turkish names of these %s colors: %s",
             colors.length, colors.keys);

    write("Please ask me one: ");
    string inEnglish = strip(readln());

    if (inEnglish in colors) {
        writefln("\"%s\" is \"%s\" in Turkish.",
                 inEnglish, colors[inEnglish]);

    } else {
        writeln("I don't know that one.");
    }
}
---

$(PROBLEM_COK

$(PROBLEM
How can all of the key-value pairs of an associative array be removed other than calling $(C .clear)? ($(C .clear) is the most natural method.) There are at least three methods:

$(UL

$(LI Removing them one-by-one from the associative array.)

$(LI Assigning an empty associative array.)

$(LI Similar to the previous method, assigning the array's $(C .init) property.

$(P
$(IX .init, clearing a variable) $(I $(B Note:) The $(C .init) property of any variable or type is the initial value of that type:)
)

---
    number = int.init;    // 0 for int
---
)

)

)

$(PROBLEM
Just like with arrays, there can be only one value for each key. This may be seen as a limitation for some applications.

$(P
Assume that an associative array is used for storing student grades. For example, let's assume that the grades 90, 85, 95, etc. are to be stored for the student named "emre".
)

$(P
Associative arrays make it easy to access the grades by the name of the student as in $(C grades["emre"]). However, the grades cannot be inserted as in the following code because each grade would overwrite the previous one:
)

---
    int[string] grades;
    grades["emre"] = 90;
    grades["emre"] = 85;   // ← Overwrites the previous grade!
---

$(P
How can you solve this problem? Define an associative array that can store multiple grades per student.
)

)

)

Macros:
        TITLE=Associative Arrays

        DESCRIPTION=The associative arrays of the d programming language.

        KEYWORDS=d programming language tutorial book associative arrays
