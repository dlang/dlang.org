Ddoc

$(DERS_BOLUMU $(IX input, formatted) $(IX formatted input) Formatted Input)

$(P
It is possible to specify the format of the data that is expected at the input. The format specifies both the data that is to be read and the characters that should be ignored.
)

$(P
D's input format specifiers are similar to the ones present in the C language.
)

$(P
As we have already been using in the previous chapters, the format specifier $(STRING " %s") reads the data according to the type of the variable. For example, as the type of the following variable is $(C double), the characters at the input would be read as floating point number:
)

---
    double number;

    readf(" %s", &number);
---

$(P
The format string can contain three types of information:
)

$(UL
$(LI $(B The space character): Indicates $(I zero) or more whitespace characters at the input and specifies that all of those characters should be read and ignored.)

$(LI $(B Format specifier): Similar to the output format specifiers, input format specifiers start with the $(C %) character and determine the format of the data that is to be read.)

$(LI $(B Any other character): Indicates the characters that are expected at the input as is, which should be read and ignored.)

)

$(P
The format string makes it possible to select specific information from the input and ignore the others.
)

$(P
Let's have a look at an example that uses all of the three types of information in the format string. Let's assume that the student number and the grade are expected to appear at the input in the following format:
)

$(SHELL
number:123 grade:90
)

$(P
Let's further assume that the tags $(C number:) and $(C grade:) must be ignored. The following format string would $(I select) the values of number and grade and would ignore the other characters:
)

---
    int number;
    int grade;
    readf("number:%s grade:%s", &number, &grade);
---

$(P
The characters that are highlighted in $(STRING "$(HILITE number:)%s&nbsp;$(HILITE grade:)%s") must appear at the input exactly as specified; $(C readf()) reads and ignores them.
)

$(P
The single space character that appears in the format string above would cause all of the whitespace characters that appear exactly at that position to be read and ignored.
)

$(P
As the $(C %) character has a special meaning in format strings, when that character itself needs to be read and ignored, it must be written twice in the format string as $(C %%).
)

$(P
Reading a single line of data from the input has been recommended as $(C strip(readln())) in the $(LINK2 strings.html, Strings chapter). Instead of that method, a $(C \n) character at the end of the format string can achieve a similar goal:
)

---
import std.stdio;

void main() {
    write("First name: ");
    string firstName;
    readf(" %s\n", &firstName);    // ← \n at the end

    write("Last name : ");
    string lastName;
    readf(" %s\n", &lastName);     // ← \n at the end

    write("Age       : ");
    int age;
    readf(" %s", &age);

    writefln("%s %s (%s)", firstName, lastName, age);
}
---

$(P
The $(C \n) characters at the ends of the format strings when reading $(C firstName) and $(C lastName) would cause the new-line characters to be read from the input and to be ignored. However, potential whitespace characters at the ends of the strings may still need to be removed by $(C strip()).
)

$(H5 Format specifier characters)

$(P
The way the data should be read is specified with the following format specifier characters:
)

$(P $(IX %d, input) $(C d): Read an integer in the decimal system.)

$(P $(IX %o, input) $(C o): Read an integer in the octal system.)

$(P $(IX %x, input) $(C x): Read an integer in the hexadecimal system.)

$(P $(IX %f, input) $(C f): Read a floating point number.)

$(P $(IX %s, input) $(C s): Read according to the type of the variable. This is the most commonly used specifier.)

$(P $(IX %c) $(C c): Read a single character. This specifier allows reading whitespace characters as well. (It cancels the ignore behavior.)
)

$(P
For example, if the input contains "23 23 23", the values would be read differently according to different format specifiers:
)

---
    int number_d;
    int number_o;
    int number_x;

    readf(" %d %o %x", &number_d, &number_o, &number_x);

    writeln("Read with %d: ", number_d);
    writeln("Read with %o: ", number_o);
    writeln("Read with %x: ", number_x);
---

$(P
Although the input contains three sets of "23" characters, the values of the variables are different:
)

$(SHELL
Read with %d: 23
Read with %o: 19
Read with %x: 35
)

$(P
$(I $(B Note:) Very briefly, "23" is equal to 2x8+3=19 in the octal system and to 2x16+3=35 in the hexadecimal system.)
)

$(PROBLEM_TEK

$(P
Assume that the input contains the date in the format $(I year.month.day). Write a program that prints the number of the month. For example, if the input is $(C 2009.09.30), the output should be $(C 9).
)

)

Macros:
        TITLE=Formatted Input

        DESCRIPTION=Reading the input in certain format.

        KEYWORDS=d programming language tutorial book format input
