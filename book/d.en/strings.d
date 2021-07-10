Ddoc

$(DERS_BOLUMU Strings)

$(P
We have used strings in many programs that we have seen so far. Strings are a combination of the two features that we have covered in the last three chapters: characters and arrays. In the simplest definition, strings are nothing but arrays of characters. For example, $(C char[]) is a type of string.
)

$(P
This simple definition may be misleading. As we have seen in the $(LINK2 characters.html, Characters chapter), D has three separate character types. Arrays of these character types lead to three separate string types, some of which may have surprising outcomes in some string operations.
)

$(H5 $(IX readln) $(IX strip) $(C readln) and $(C strip), instead of $(C readf))

$(P
There are surprises even when reading strings from the terminal.
)

$(P
Being character arrays, strings can contain control characters like $(STRING '\n') as well. When reading strings from the input, the control character that corresponds to the Enter key that is pressed at the end of the input becomes a part of the string as well. Further, because there is no way to tell $(C readf()) how many characters to read, it continues to read until the end of the entire input. For these reasons, $(C readf()) does not work as intended when reading strings:
)

---
import std.stdio;

void main() {
    char[] name;

    write("What is your name? ");
    readf(" %s", &name);

    writeln("Hello ", name, "!");
}
---

$(P
The Enter key that the user presses after the name does not terminate the input. $(C readf()) continues to wait for more characters to add to the string:
)

$(SHELL
What is your name? Mert
   $(SHELL_NOTE The input is not terminated although Enter has been pressed)
   $(SHELL_NOTE (Let's assume that Enter is pressed a second time here))
)

$(P
One way of terminating the standard input stream in a terminal is pressing Ctrl-D under Unix-based systems and Ctrl-Z under Windows systems. If the user eventually terminates the input that way, we see that the new-line characters have been read as parts of the string as well:
)

$(SHELL
Hello Mert
   $(SHELL_NOTE_WRONG new-line character after the name)
!  $(SHELL_NOTE_WRONG (one more before the exclamation mark))
)

$(P
The exclamation mark appears after those characters instead of being printed right after the name.
)

$(P
$(C readln()) is more suitable when reading strings. Short for "read line", $(C readln()) reads until the end of the line. It is used differently because the $(STRING " %s") format string and the $(C &) operator are not needed:
)

---
import std.stdio;

void main() {
    char[] name;

    write("What is your name? ");
    $(HILITE readln(name));

    writeln("Hello ", name, "!");
}
---

$(P
$(C readln()) stores the new-line character as well. This is so that the program has a way of determining whether the input consisted of a complete line or whether the end of input has been reached:
)

$(SHELL
What is your name? Mert
Hello Mert
!  $(SHELL_NOTE_WRONG new-line character before the exclamation mark)
)

$(P
Such control characters as well as all whitespace characters at both ends of strings can be removed by $(C std.string.strip):
)

---
import std.stdio;
$(HILITE import std.string;)

void main() {
    char[] name;

    write("What is your name? ");
    readln(name);
    $(HILITE name = strip(name);)

    writeln("Hello ", name, "!");
}
---

$(P
The $(C strip()) expression above returns a new string that does not contain the trailing control characters. Assigning that return value back to $(C name) produces the intended output:
)

$(SHELL
What is your name? Mert
Hello Mert!    $(SHELL_NOTE no new-line character)
)

$(P
$(C readln()) can be used without a parameter. In that case it $(I returns) the line that it has just read. Chaining the result of $(C readln()) to $(C strip()) enables a shorter and more readable syntax:
)

---
    string name = strip(readln());
---

$(P
I will start using that form after introducing the $(C string) type below.
)

$(H5 $(IX formattedRead) $(C formattedRead) for parsing strings)

$(P
Once a line is read from the input or from any other source, it is possible to parse and convert separate data that it may contain with $(C formattedRead()) from the $(C std.format) module. Its first parameter is the line that contains the data, and the rest of the parameters are used exacly like $(C readf()):
)

---
import std.stdio;
import std.string;
$(HILITE import std.format;)

void main() {
    write("Please enter your name and age," ~
          " separated with a space: ");

    string line = strip(readln());

    string name;
    int age;
    $(HILITE formattedRead)(line, " %s %s", name, age);

    writeln("Your name is ", name,
            ", and your age is ", age, '.');
}
---

$(SHELL
Please enter your name and age, separated with a space: $(HILITE Mert 30)
Your name is $(HILITE Mert), and your age is $(HILITE 30).
)

$(P
Both $(C readf()) and $(C formattedRead()) $(I return) the number of items that they could parse and convert successfully. That value can be compared against the expected number of data items so that the input can be validated. For example, as the $(C formattedRead()) call above expects to read $(I two) items (a $(C string) as name and an $(C int) as age), the following check ensures that it really is the case:
)

---
    $(HILITE uint items) = formattedRead(line, " %s %s", name, age);

    if ($(HILITE items != 2)) {
        writeln("Error: Unexpected line.");

    } else {
        writeln("Your name is ", name,
                ", and your age is ", age, '.');
    }
---

$(P
When the input cannot be converted to $(C name) and $(C age), the program prints an error:
)

$(SHELL
Please enter your name and age, separated with a space: $(HILITE Mert)
Error: Unexpected line.
)

$(H5 $(IX &quot;) Double quotes, not single quotes)

$(P
We have seen that single quotes are used to define character literals. String literals are defined with double quotes. $(STRING 'a') is a character; $(STRING "a") is a string that contains a single character.
)

$(H5 $(IX string) $(IX wstring) $(IX dstring) $(IX char[]) $(IX wchar[]) $(IX dchar[]) $(IX immutable) $(C string), $(C wstring), and $(C dstring) are immutable)

$(P
There are three string types that correspond to the three character types: $(C char[]), $(C wchar[]), and $(C dchar[]).
)

$(P
There are three $(I aliases) of the $(I immutable) versions of those types: $(C string), $(C wstring), and $(C dstring). The characters of the variables that are defined by these aliases cannot be modified. For example, the characters of a $(C wchar[]) can be modified but the characters of a $(C wstring) cannot be modified. (We will see D's $(I immutability) concept in later chapters.)
)

$(P
For example, the following code that tries to capitalize the first letter of a $(C string) would cause a compilation error:
)

---
    string cannotBeMutated = "hello";
    cannotBeMutated[0] = 'H';             $(DERLEME_HATASI)
---

$(P
We may think of defining the variable as a $(C char[]) instead of the $(C string) alias but that cannot be compiled either:
)

---
    char[] a_slice = "hello";  $(DERLEME_HATASI)
---

$(P
This time the compilation error is due to the combination of two factors:
)

$(OL
$(LI The type of string literals like $(STRING "hello") is $(C string), not $(C char[]), so they are immutable.
)
$(LI The $(C char[]) on the left-hand side is a slice, which, if the code compiled, would provide access to all of the characters of the right-hand side.
)
)

$(P
Since $(C char[]) is mutable and $(C string) is not, there is a mismatch. The compiler does not allow accessing characters of an immutable array through a mutable slice.
)

$(P
The solution here is to take a copy of the immutable string by using the $(C .dup) property:
)

---
import std.stdio;

void main() {
    char[] s = "hello"$(HILITE .dup);
    s[0] = 'H';
    writeln(s);
}
---

$(P
The program can now be compiled and will print the modified string:
)

$(SHELL
Hello
)

$(P
Similarly, $(C char[]) cannot be used where a $(C string) is needed. In such cases, the $(C .idup) property can be used to produce an immutable $(C string) variable from a mutable $(C char[]) variable. For example, if $(C s) is a variable of type $(C char[]), the following line will fail to compile:
)

---
    string result = s ~ '.';          $(DERLEME_HATASI)
---

$(P
When the type of $(C s) is $(C char[]), the type of the expression on the right-hand side of the assignment above is $(C char[]) as well. $(C .idup) is used for producing immutable strings from existing strings:
)

---
    string result = (s ~ '.')$(HILITE .idup);   // ← now compiles
---

$(H5 $(IX length, string) Potentially confusing length of strings)

$(P
We have seen that some Unicode characters are represented by more than one byte. For example, the character 'é' (the latin letter 'e' combined with an acute accent) is represented by Unicode encodings using at least two bytes. This fact is reflected in the $(C .length) property of strings:
)

---
    writeln("résumé".length);
---

$(P
Although "résumé" contains six $(I letters), the length of the $(C string) is the number of UTF-8 code units that it contains:
)

$(SHELL
8
)

$(P
The type of the elements of string literals like $(STRING "hello") is $(C char) and each $(C char) value represents a UTF-8 code unit. A problem that this may cause is when we try to replace a two-code-unit character with a single-code-unit character:
)

---
    char[] s = "résumé".dup;
    writeln("Before: ", s);
    s[1] = 'e';
    s[5] = 'e';
    writeln("After : ", s);
---

$(P
The two 'e' characters do not replace the two 'é' characters; they replace single code units, resulting in an invalid UTF-8 encoding:
)

$(SHELL
Before: résumé
After : re�sueé    $(SHELL_NOTE_WRONG INCORRECT)
)

$(P
When dealing with letters, symbols, and other Unicode characters directly, as in the code above, the correct type to use is $(C dchar):
)

---
    dchar[] s = "résumé"d.dup;
    writeln("Before: ", s);
    s[1] = 'e';
    s[5] = 'e';
    writeln("After : ", s);
---

$(P
The output:
)

$(SHELL
Before: résumé
After : resume
)

$(P
Please note the two differences in the new code:
)
$(OL
$(LI The type of the string is $(C dchar[]).
$(LI There is a $(C d) at the end of the literal $(STRING "résumé"d), specifying its type as an array of $(C dchar)s.)
)
)

$(P
In any case, keep in mind that the use of $(C dchar[]) and $(C dstring) does not solve all of the problems of manipulating Unicode characters. For instance, if the user inputs the text "résumé" you and your program cannot assume that the string length will be 6 even for $(C dchar) strings. It might be greater if e.g. at least one of the 'é' characters is not encoded as a single code point but as the combination of an 'e' and a combining accute accent. To avoid dealing with this and many other Unicode issues, consider using a Unicode-aware text manipulation library in your programs.
)

$(H5 $(IX literal, string) String literals)

$(P
The optional character that is specified after string literals determines the type of the elements of the string:
)

---
import std.stdio;

void main() {
     string s = "résumé"c;   // same as "résumé"
    wstring w = "résumé"w;
    dstring d = "résumé"d;

    writeln(s.length);
    writeln(w.length);
    writeln(d.length);
}
---

$(P
The output:
)

$(SHELL
8
6
6
)

$(P
Because all of the Unicode characters of "résumé" can be represented by a single $(C wchar) or $(C dchar), the last two lengths are equal to the number of characters.
)

$(H5 $(IX concatenation, string) String concatenation)

$(P
Since they are actually arrays, all of the array operations can be applied to strings as well. $(C ~) concatenates two strings and $(C ~=) appends to an existing string:
)

---
import std.stdio;
import std.string;

void main() {
    write("What is your name? ");
    string name = strip(readln());

    // Concatenate:
    string greeting = "Hello " ~ name;

    // Append:
    greeting ~= "! Welcome...";

    writeln(greeting);
}
---

$(P
The output:
)

$(SHELL
What is your name? Can
Hello Can! Welcome...
)

$(H5 Comparing strings)

$(P
$(I $(B Note:) Unicode does not define how the characters are ordered other than their Unicode codes. For that reason, you may get results that don't match your expectations below.)
)

$(P
We have used comparison operators $(C <), $(C >=), etc. with integer and floating point values before. The same operators can be used with strings as well, but with a different meaning: strings are ordered $(I lexicographically). This ordering takes each character's Unicode code to be its place in a hypothetical grand Unicode alphabet. The concepts of $(I less) and $(I greater) are replaced with $(I before) and $(I after) in this hypothetical alphabet:
)

---
import std.stdio;
import std.string;

void main() {
    write("      Enter a string: ");
    string s1 = strip(readln());

    write("Enter another string: ");
    string s2 = strip(readln());

    if (s1 $(HILITE ==) s2) {
        writeln("They are the same!");

    } else {
        string former;
        string latter;

        if (s1 $(HILITE <) s2) {
            former = s1;
            latter = s2;

        } else {
            former = s2;
            latter = s1;
        }

        writeln("'", former, "' comes before '", latter, "'.");
    }
}
---

$(P
Because Unicode adopts the letters of the basic Latin alphabet from the ASCII table, the strings that contain only the letters of the ASCII table will always be ordered correctly.
)

$(H5 Lowercase and uppercase are different)

$(P
Because each character has a unique code, every letter variant is different from the others. For example, 'A' and 'a' are different letters, when directly comparing Unicode strings.
)

$(P
Additionally, as a consequence of their ASCII code values, all of the latin uppercase letters are sorted before all of the lowercase letters. For example, 'B' comes before 'a'. The $(C icmp()) function of the $(C std.string) module can be used when strings need to be compared regardless of lowercase and uppercase. You can see the functions of this module at $(LINK2 http://dlang.org/phobos/std_string.html, its online documentation).
)

$(P
Because strings are arrays (and as a corollary, $(I ranges)), the functions of the $(C std.array), $(C std.algorithm), and $(C std.range) modules are very useful with strings as well.
)

$(PROBLEM_COK

$(PROBLEM
Browse the documentations of the $(C std.string), $(C std.array), $(C std.algorithm), and $(C std.range) modules.
)

$(PROBLEM
Write a program that makes use of the $(C ~) operator: The user enters the first name and the last name, all in lowercase letters. Produce the full name that contains the proper capitalization of the first and last names. For example, when the strings are "ebru" and "domates" the program should print "Ebru&nbsp;Domates".
)

$(PROBLEM
Read a line from the input and print the part between the first and last 'e' letters of the line. For example, when the line is "this line has five words" the program should print "e has five".

$(P
You may find the $(C indexOf()) and $(C lastIndexOf()) functions useful to get the two indexes needed to produce a slice.
)

$(P
As it is indicated in their documentation, the return types of $(C indexOf()) and $(C lastIndexOf()) are not $(C int) nor $(C size_t), but $(C ptrdiff_t). You may have to define variables of that exact type:
)

---
    ptrdiff_t first_e = indexOf(line, 'e');
---

$(P
It is possible to define variables with the $(C auto) keyword, which we will see in a later chapter:
)

---
    auto first_e = indexOf(line, 'e');
---

)

)

Macros:
        TITLE=Strings

        DESCRIPTION=The strings of the D programming language

        KEYWORDS=d programming language tutorial book string
