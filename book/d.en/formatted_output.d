Ddoc

$(DERS_BOLUMU $(IX output, formatted) $(IX formatted output) Formatted Output)

$(P
This chapter is about features of the $(C std.format) module, not about the core features of the D language.
)

$(P
$(IX std) $(IX Phobos) Like all modules that have the prefix $(C std), $(C std.format) is a module inside Phobos, the standard library of D. There is not enough space to fully explore Phobos in this book.
)

$(P
D's input and output format specifiers are similar to the ones in the C language.
)

$(P
Before going further, I would like to summarize the format specifiers and flags, for your reference:
)

$(MONO
$(B Flags) (can be used together)
     -     flush left
     +     print the sign
     #     print in the alternative way
     0     print zero-filled
   $(I space)   print space-filled

$(B Format Specifiers)
     s     default
     b     binary
     d     decimal
     o     octal
    x,X    hexadecimal
    f,F    floating point in the standard decimal notation
    e,E    floating point in scientific notation
    a,A    floating point in hexadecimal notation
    g,G    as e or f

     ,     digit separators

     (     element format start
     )     element format end
     |     element delimiter
)

$(P
We have been using functions like $(C writeln) with multiple parameters as necessary to print the desired output. The parameters would be converted to their string representations and then
 sent to the output.
)

$(P
Sometimes this is not sufficient. The output may have to be in a very specific format. Let's look at the following code that is used to print items of an invoice:
)

---
    items ~= 1.23;
    items ~= 45.6;

    for (int i = 0; i != items.length; ++i) {
        writeln("Item ", i + 1, ": ", items[i]);
    }
---

$(P
The output:
)

$(SHELL
Item 1: 1.23
Item 2: 45.6
)

$(P
Despite the information being correct, we may be required to print it in a different format. For example, maybe the decimal marks (the dots, in this case) must line up and we must ensure that there always are two digits after the decimal mark, as in the following output:
)

$(SHELL
Item 1:     1.23
Item 2:    45.60
)

$(P
Formatted output is useful in such cases. The output functions that we have been using so far have counterparts that contain the letter $(C f) in their names: $(C writef()) and $(C writefln()). The letter $(C f) is short for $(I formatted). The first parameter of these functions is a $(I format string) that describes how the other parameters should be printed.
)

$(P
For example, $(C writefln()) can produce the desired output above with the following format string:
)

---
        writefln("Item %d:%9.02f", i + 1, items[i]);
---

$(P
The format string contains regular characters that are passed to the output as is, as well as special format specifiers that correspond to each parameter that is to be printed. Format specifiers start with the $(C %) character and end with a $(I format character). The format string above has two format specifiers: $(C %d) and $(C %9.02f).
)

$(P
Every specifier is associated with the respective parameter, usually in order of appearance. For example, $(C %d) is associated with $(C i&nbsp;+&nbsp;1) and $(C %9.02f) is associated with $(C items[i]). Every specifier specifies the format of the parameter that it corresponds to. (Format specifiers may have parameter numbers as well. This will be explained later in the chapter.)
)

$(P
All of the other characters of the format string that are not part of format specifiers are printed as is. Such $(I regular) characters of the format specifier above are highlighted in $(C "$(HILITE Item&nbsp;)%d$(HILITE :)%9.02f").
)

$(P
Format specifiers consist of several parts, most of which are optional. The part named $(I position) will be explained later below. The others are the following: ($(I $(B Note:) The spaces between these parts are inserted here to help with readability; they are not part of the specifiers.))
)

$(MONO
    %  $(I$(C flags  width  separator  precision  format_character))
)

$(P
The $(C %) character at the beginning and the format character at the end are required; the others are optional.
)

$(P
Because $(C %) has a special meaning in format strings, when we need to print a $(C %) as a regular character, we must type it as $(C %%).
)

$(H5 $(I format_character))

$(P $(IX %b) $(C b): An integer argument is printed in the binary system.
)

$(P $(IX %o, output) $(C o): An integer argument is printed in the octal system.
)

$(P $(IX %x, output) $(IX %X) $(C x) and $(C X): An integer argument is printed in the hexadecimal system; with lowercase letters when using $(C x) and with uppercase letters when using $(C X).
)

$(P $(IX %d, output) $(C d): An integer argument is printed in the decimal system; a negative sign is also printed if it is a signed type and the value is less than zero.
)

---
    int value = 12;

    writefln("Binary     : %b", value);
    writefln("Octal      : %o", value);
    writefln("Hexadecimal: %x", value);
    writefln("Decimal    : %d", value);
---

$(SHELL
Binary     : 1100
Octal      : 14
Hexadecimal: c
Decimal    : 12
)

$(P $(IX %e) $(C e): A floating point argument is printed according to the following rules.
)

$(UL
$(LI a single digit before the decimal mark)
$(LI a decimal mark if $(I precision) is nonzero)
$(LI the required digits after the decimal mark, the number of which is determined by $(I precision) (default precision is 6))
$(LI the $(C e) character (meaning "10 to the power of"))
$(LI the $(C -) or $(C +) character, depending on whether the exponent is less than or greater than zero)
$(LI the exponent, consisting of at least two digits)
)

$(P $(IX %E) $(C E): Same as $(C e), with the exception of outputting the character $(C E) instead of $(C e).
)

$(P $(IX %f, output) $(IX %F) $(C f) and $(C F): A floating point argument is printed in the decimal system; there is at least one digit before the decimal mark and the default precision is 6 digits after the decimal mark.
)

$(P $(IX %g) $(C g): Same as $(C f) if the exponent is between -5 and $(I precision); otherwise same as $(C e). $(I precision) does not specify the number of digits after the decimal mark, but the significant digits of the entire value. If there are no significant digits after the decimal mark, then the decimal mark is not printed. The rightmost zeros after the decimal mark are not printed.
)

$(P $(IX %G) $(C G): Same as $(C g), with the exception of outputting the character $(C E).
)

$(P $(IX %a) $(C a): A floating point argument is printed in the hexadecimal floating point notation:
)

$(UL
$(LI the characters $(C 0x))
$(LI a single hexadecimal digit)
$(LI a decimal mark if $(I precision) is nonzero)
$(LI the required digits after the decimal mark, the number of which is determined by $(I precision); if no $(I precision) is specified, then as many digits as necessary)
$(LI the $(C p) character (meaning "2 to the power of"))
$(LI the $(C -) or $(C +) character, depending on whether the exponent is less than or greater than zero)
$(LI the exponent, consisting of at least one digit (the exponent of the value 0 is 0))
)

$(P $(IX %A) $(C A): Same as $(C a), with the exception of outputting the characters $(C 0X) and $(C P).
)

---
    double value = 123.456789;

    writefln("with e: %e", value);
    writefln("with f: %f", value);
    writefln("with g: %g", value);
    writefln("with a: %a", value);
---

$(SHELL
with e: 1.234568e+02
with f: 123.456789
with g: 123.457
with a: 0x1.edd3c07ee0b0bp+6
)

$(P $(IX %s, output) $(C s): The value is printed in the same way as in regular output, according to the type of the argument:
)

$(UL

$(LI $(C bool) values as $(C true) or $(C false)
)
$(LI integer values same as $(C %d)
)
$(LI floating point values same as $(C %g)
)
$(LI strings in UTF-8 encoding; $(I precision) determines the maximum number of bytes to use (remember that in UTF-8 encoding, the number of bytes is not the same as the number of characters; for example, the string "ağ" has 2 characters, consisting a total of 3 bytes)
)
$(LI struct and class objects as the return value of the $(C toString()) member functions of their types; $(I precision) determines the maximum number of bytes to use
)
$(LI arrays as their element values, side by side
)

)

---
    bool b = true;
    int i = 365;
    double d = 9.87;
    string s = "formatted";
    auto o = File("test_file", "r");
    int[] a = [ 2, 4, 6, 8 ];

    writefln("bool  : %s", b);
    writefln("int   : %s", i);
    writefln("double: %s", d);
    writefln("string: %s", s);
    writefln("object: %s", o);
    writefln("array : %s", a);
---

$(SHELL
bool  : true
int   : 365
double: 9.87
string: formatted
object: File(55738FA0)
array : [2, 4, 6, 8]
)

$(H5 $(IX width, output) $(I width))

$(P
$(IX *, formatted output) This part determines the width of the field that the argument is printed in. If the width is specified as the character $(C *), then the actual width value is read from the next argument (that argument must be an $(C int)). If width is a negative value, then the $(C -) flag is assumed.
)

---
    int value = 100;

    writefln("In a field of 10 characters:%10s", value);
    writefln("In a field of 5 characters :%5s", value);
---

$(SHELL
In a field of 10 characters:       100
In a field of 5 characters :  100
)

$(H5 $(IX $(PERCENT),) $(IX separator) $(I separator))

$(P
$(IX , (comma), output) The comma character specifies to separate digits of a number in groups. The default number of digits in a group is 3 but it can be specified after the comma:
)

---
    writefln("%,f", 1234.5678);        // Groups of 3
    writefln("%,s", 1000000);          // Groups of 3
    writefln("%,2s", 1000000);         // Groups of 2
---

$(SHELL
1,234.567,800
1,000,000
1,00,00,00
)

$(P
If the number of digits is specified as the character $(C *), then the actual number of digits is read from the next argument (that argument must be an $(C int)).
)

---
    writefln("%,*s", $(HILITE 1), 1000000);      // Groups of 1
---

$(SHELL
1,0,0,0,0,0,0
)

$(P
Similarly, it is possible to specify the separator character by using a question mark after the comma and providing the character as an additional argument before the number:
)

---
    writefln("%,?s", $(HILITE '.'), 1000000);    // The separator is '.'
---

$(SHELL
1$(HILITE .)000$(HILITE .)000
)

$(H5 $(IX precision, output) $(I precision))

$(P
Precision is specified after a dot in the format specifier. For floating point types, it determines the precision of the printed representation of the values. If the precision is specified as the character $(C *), then the actual precision is read from the next argument (that argument must be an $(C int)). Negative precision values are ignored.
)

---
    double value = 1234.56789;

    writefln("%.8g", value);
    writefln("%.3g", value);
    writefln("%.8f", value);
    writefln("%.3f", value);
---

$(SHELL
1234.5679
1.23e+03
1234.56789000
1234.568
)

---
    auto number = 0.123456789;
    writefln("Number: %.*g", 4, number);
---

$(SHELL
Number: 0.1235
)

$(H5 $(IX flags, output) $(I flags))

$(P
More than one flag can be specified.
)

$(P $(C -): the value is printed left-aligned in its field; this flag cancels the $(C 0) flag
)

---
    int value = 123;

    writefln("Normally right-aligned:|%10d|", value);
    writefln("Left-aligned          :|%-10d|", value);
---

$(SHELL
Normally right-aligned:|       123|
Left-aligned          :|123       |
)

$(P $(C +): if the value is positive, it is prepended with the $(C +) character; this flag cancels the $(I space) flag
)

---
    writefln("No effect for negative values    : %+d", -50);
    writefln("Positive value with the + flag   : %+d", 50);
    writefln("Positive value without the + flag: %d", 50);
---

$(SHELL
No effect for negative values    : -50
Positive value with the + flag   : +50
Positive value without the + flag: 50
)

$(P $(C #): prints the value in an $(I alternate) form depending on the $(I format_character)
)

$(UL
$(LI $(C o): the first character of the octal value is always printed as 0)

$(LI $(C x) and $(C X): if the value is not zero, it is prepended with $(C 0x) or $(C 0X))

$(LI floating points: a decimal mark is printed even if there are no significant digits after the decimal mark)

$(LI $(C g) and $(C G): even the insignificant zero digits after the decimal mark are printed)
)

---
    writefln("Octal starts with 0                        : %#o", 1000);
    writefln("Hexadecimal starts with 0x                 : %#x", 1000);
    writefln("Contains decimal mark even when unnecessary: %#g", 1f);
    writefln("Rightmost zeros are printed                : %#g", 1.2);
---

$(SHELL
Octal starts with 0                        : 01750
Hexadecimal starts with 0x                 : 0x3e8
Contains decimal mark even when unnecessary: 1.00000
Rightmost zeros are printed                : 1.20000
)

$(P $(C 0): the field is padded with zeros (unless the value is $(C nan) or $(C infinity)); if $(I precision) is also specified, this flag is ignored
)

---
    writefln("In a field of 8 characters: %08d", 42);
---

$(SHELL
In a field of 8 characters: 00000042
)

$(P $(I space) character: if the value is positive, a space character is prepended to align the negative and positive values)

---
    writefln("No effect for negative values: % d", -34);
    writefln("Positive value with space    : % d", 56);
    writefln("Positive value without space : %d", 56);
---

$(SHELL
No effect for negative values: -34
Positive value with space    :  56
Positive value without space : 56
)


$(H5 $(IX %1$) $(IX positional parameter, output) $(IX $, formatted output) Positional parameters)

$(P
We have seen above that the arguments are associated one by one with the specifiers in the format string. It is also possible to use position numbers within format specifiers. This enables associating the specifiers with specific arguments. Arguments are numbered in increasing fashion, starting with 1. The argument numbers are specified immediately after the $(C %) character, followed by a $(C $):
)

$(MONO
    %  $(I$(C $(HILITE position$)  flags  width  precision  format_character))
)

$(P
An advantage of positional parameters is being able to use the same argument in more than one place in the same format string:
)

---
    writefln("%1$d %1$x %1$o %1$b", 42);
---

$(P
The format string above uses the argument numbered 1 within four specifiers to print it in decimal, hexadecimal, octal, and binary formats:
)

$(SHELL
42 2a 52 101010
)

$(P
Another application of positional parameters is supporting multiple natural languages. When referred by position numbers, arguments can be moved anywhere within the specific format string for a given human language. For example, the number of students of a given classroom can be printed as in the following:
)

---
    writefln("There are %s students in room %s.", count, room);
---

$(SHELL
There are 20 students in room 1A.
)

$(P
Let's assume that the program must also support Turkish. In this case the format string needs to be selected according to the active language. The following method takes advantage of the ternary operator:
)

---
    auto format = (language == "en"
                   ? "There are %s students in room %s."
                   : "%s sınıfında %s öğrenci var.");

    writefln(format, count, room);
---

$(P
Unfortunately, when the arguments are associated one by one, the classroom and student count information appear in reverse order in the Turkish message; the room information is where the count should be and the count is where the room should be:
)

$(SHELL
20 sınıfında 1A öğrenci var.  $(SHELL_NOTE_WRONG Wrong: means "room 20", and "1A students"!)
)

$(P
To avoid this, the arguments can be specified by numbers, such as $(C 1$) and $(C 2$), to associate each specifier with the exact argument:
)

---
    auto format = (language == "en"
                   ? "There are %1$s students in room %2$s."
                   : "%2$s sınıfında %1$s öğrenci var.");

    writefln(format, count, room);
---

$(P
Now the arguments appear in the proper order, regardless of the language selected:
)

$(SHELL
There are 20 students in room 1A.
)

$(SHELL
1A sınıfında 20 öğrenci var.
)

$(H5 $(IX %$(PARANTEZ_AC)) $(IX %$(PARANTEZ_KAPA)) Formatted element output)

$(P
Format specifiers between $(STRING %$(PARANTEZ_AC)) and $(STRING %$(PARANTEZ_KAPA)) are applied to every element of a container (e.g. an array or a range):
)

---
    auto numbers = [ 1, 2, 3, 4 ];
    writefln("%(%s%)", numbers);
---

$(P
The format string above consists of three parts:
)

$(UL
$(LI $(STRING %$(PARANTEZ_AC)): Start of element format)
$(LI $(STRING %s): Format for each element)
$(LI $(STRING %$(PARANTEZ_KAPA)): End of element format)
)

$(P
Each being printed with the $(STRING %s) format, the elements appear one after the other:
)

$(SHELL
1234
)

$(P
The regular characters before and after the element format are repeated for each element. For example, the $(STRING {%s},) specifier would print each element between curly brackets separated by commas:
)

---
    writefln("%({%s},%)", numbers);
---

$(P
However, regular characters to the right of the format specifier are considered to be element delimiters and are printed only between elements, not after the last one:
)

$(SHELL
{1},{2},{3},{4  $(SHELL_NOTE '}' and ',' are not printed after the last element)
)

$(P
$(IX %|) $(STRING %|) is used for specifying the characters that should be printed even for the last element. Characters that are to the right of $(STRING %|) are considered to be the delimiters and are not printed for the last element. Conversely, characters to the left of $(STRING %|) are printed even for the last element.
)

$(P
For example, the following format specifier would print the closing curly bracket after the last element but not the comma:
)
---
    writefln("%({%s}%|,%)", numbers);
---

$(SHELL
{1},{2},{3},{4}  $(SHELL_NOTE '}' is printed after the last element as well)
)

$(P
Unlike strings that are printed individually, strings that are printed as elements appear within double quotes:
)

---
    auto vegetables = [ "spinach", "asparagus", "artichoke" ];
    writefln("%(%s, %)", vegetables);
---

$(SHELL
"spinach", "asparagus", "artichoke"
)

$(P
$(IX %-$(PARANTEZ_AC)) When the double quotes are not desired, the element format must be started with $(STRING %-$(PARANTEZ_AC)) instead of $(STRING %$(PARANTEZ_AC)):
)

---
    writefln("%-(%s, %)", vegetables);
---

$(SHELL
spinach, asparagus, artichoke
)

$(P
The same applies to characters as well. $(STRING %$(PARANTEZ_AC)) prints them within single quotes:
)

---
    writefln("%(%s%)", "hello");
---

$(SHELL
'h''e''l''l''o'
)

$(P
$(STRING %-$(PARANTEZ_AC)) prints them without quotes:
)

---
    writefln("%-(%s%)", "hello");
---

$(SHELL
hello
)

$(P
There must be two format specifiers for associative arrays: one for the keys and one for the values. For example, the following $(STRING %s&nbsp;(%s)) specifier would print first the key and then the value in parentheses:
)

---
    auto spelled = [ 1 : "one", 10 : "ten", 100 : "hundred" ];
    writefln("%-(%s (%s)%|, %)", spelled);
---

$(P
Also note that, being specified to the right of $(STRING %|), the comma is not printed for the last element:
)

$(SHELL
1 (one), 100 (hundred), 10 (ten)
)

$(H5 $(IX format, std.string) $(C format))

$(P
Formatted output is available through the $(C format()) function of the $(C std.string) module as well. $(C format()) works the same as $(C writef()) but it $(I returns) the result as a $(C string) instead of printing it to the output:
)

---
import std.stdio;
import std.string;

void main() {
    write("What is your name? ");
    auto name = strip(readln());

    auto result = $(HILITE format)("Hello %s!", name);
}
---

$(P
The program can make use of that result in later expressions.
)

$(H6 $(IX checked format string) Checked format string)

$(P
There is an alternative syntax for functions like $(C format) in the standard library that take a format string ($(C writef), $(C writefln), $(C formattedWrite), $(C readf), $(C formattedRead), etc.). It is possible to provide the format string as a $(I template argument) to these functions so that the validity of the format string and the arguments are checked at compile time:
)

---
import std.stdio;

void main() {
    writefln!"%s %s"(1);       $(DERLEME_HATASI) (extra %s)
    writefln!"%s"(1, 2);       $(DERLEME_HATASI) (extra 2)
    writefln!"%s %d"(1, 2.5);  $(DERLEME_HATASI) (mismatched %d and 2.5)
}
---

$(P
The $(C !) character above is the template instantiation operator, which we will see in $(LINK2 templates.html, a later chapter).
)

$(P
($(I $(B Note:) Although this snytax is safer because it catches potential programmer errors at compile time, it may also make compilation times longer.))
)

$(PROBLEM_COK

$(PROBLEM
Write a program that reads a value and prints it in the hexadecimal system.
)

$(PROBLEM
Write a program that reads a floating point value and prints it as percentage value with two digits after the decimal mark. For example, if the value is 1.2345, it should print $(C %1.23).
)

)

Macros:
        TITLE=Formatted Output

        DESCRIPTION=Printing values in certain formats.

        KEYWORDS=d programming language tutorial book format output
