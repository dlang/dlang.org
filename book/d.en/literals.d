Ddoc

$(DERS_BOLUMU $(IX literal) Literals)

$(P
Programs achieve their tasks by manipulating the values of variables and objects. They produce new values and new objects by using them with functions and operators.
)

$(P
Some values need not be produced during the execution of the program; they are instead written directly into the source code. For example, the floating point value $(C 0.75) and the $(C string) value $(STRING "Total price: ") below are not calculated by the program:
)

---
    discountedPrice = actualPrice * 0.75;
    totalPrice += count * discountedPrice;
    writeln("Total price: ", totalPrice);
---

$(P
Such values that are directly typed into the source code are called literals. We have used many literals in the programs that we have written so far. We will cover all of the types of literals and their syntax rules.
)

$(H5 Integer literals)

$(P
Integer literals can be written in one of four ways: the decimal system that we use in our daily lives; the hexadecimal and binary systems, which are more suitable for certain computing tasks; and the octal system, which may be needed in very rare cases.
)

$(P
In order to make the code more readable, it is possible to insert $(C _) characters anywhere after the first digit of integer literals. For example, we can use it to form groups of three digits, as in $(C 1_234_567). Another example would be if we measured some value in cents of a currency, and used it to separate the currency units from the cents, as in $(C 199_99). These characters are optional; they are ignored by the compiler.
)

$(P
$(B In the decimal system:) The literals are specified by the decimal numerals in exactly the same way as we are used to in our daily lives, such as $(C 12). When using the decimal system in D the first digit cannot be $(C 0). Such a leading zero digit is often used in other programming languages to indicate the octal system, so this constraint helps to prevent bugs that are caused by this easily overlooked difference. This does not preclude $(C 0) on its own: $(C 0) is zero.
)

$(P
$(B In the hexadecimal system:) The literals start with $(C 0x) or $(C 0X) and include the numerals of the hexadecimal system: "0123456789abcdef" and "ABCDEF" as in $(C 0x12ab00fe).
)

$(P
$(B In the octal system:) The literals are specified using the $(C octal) template from the $(C std.conv) module and include the numerals of the octal system: "01234567" as in $(C octal!576).
)

$(P
$(B In the binary system:) The literals start with $(C 0b) or $(C 0B) and include the numerals of the binary system: 0 and 1 as in $(C 0b01100011).
)

$(H6 The types of integer literals)

$(P
Just like any other value, every literal is of a certain type. The types of literals are not specified explicitly as $(C int), $(C double), etc. The compiler infers the type from the value and syntax of the literal itself.
)

$(P
Although most of the time the types of literals are not important, sometimes the types may not match the expressions that they are used in. In such cases the type must be explicitly specified.
)

$(P
By default, integer literals are inferred to be of type $(C int). When the value happens to be too large to be represented by an $(C int), the compiler uses the following logic to decide on the type of the literal:
)

$(UL

$(LI If the value of the literal does not fit an $(C int) and it is specified in the decimal system, then its type is $(C long).
)

$(LI If the value of the literal does not fit an $(C int) and it is specified in any other system, then the type becomes the first of the following types that can accomodate the value: $(C uint), $(C long), and $(C ulong).
)

)

$(P
To see this logic in action, let's try the following program that takes advantage of $(C typeof) and $(C stringof):
)

---
import std.stdio;

void main() {
    writeln("\n--- these are written in decimal ---");

    // fits an int, so the type is int
    writeln(       2_147_483_647, "\t\t",
            typeof(2_147_483_647).stringof);

    // does not fit an int and is decimal, so the type is long
    writeln(       2_147_483_648, "\t\t",
            typeof(2_147_483_648).stringof);

    writeln("\n--- these are NOT written in decimal ---");

    // fits an int, so the type is int
    writeln(       0x7FFF_FFFF, "\t\t",
            typeof(0x7FFF_FFFF).stringof);

    // does not fit an int and is not decimal, so the type is uint
    writeln(       0x8000_0000, "\t\t",
            typeof(0x8000_0000).stringof);

    // does not fit a uint and is not decimal, so the type is long
    writeln(       0x1_0000_0000, "\t\t",
            typeof(0x1_0000_0000).stringof);

    // does not fit a long and is not decimal, so the type is ulong
    writeln(       0x8000_0000_0000_0000, "\t\t",
            typeof(0x8000_0000_0000_0000).stringof);
}
---

$(P
The output:
)

$(SHELL
--- these are written in decimal ---
2147483647		int
2147483648		long

--- these are NOT written in decimal ---
2147483647		int
2147483648		uint
4294967296		long
9223372036854775808		ulong
)

$(H6 $(IX L, literal suffix) The $(C L) suffix)

$(P
Regardless of the magnitude of the value, if it ends with $(C L) as in $(C 10L), the type is $(C long).
)

$(H6 $(IX U, literal suffix) The $(C U) suffix)

$(P
If the literal ends with $(C U) as in $(C 10U), then its type is an unsigned type. Lowercase $(C u) can also be used.
)

$(P
$(IX LU, literal suffix) $(IX UL, literal suffix) The $(C L) and $(C U) specifiers can be used together in any order. For example, $(C 7UL) and $(C 8LU) are both of type $(C ulong).
)

$(H5 Floating point literals)

$(P
The floating point literals can be specified in either the decimal system, as in $(C 1.234), or in the hexadecimal system, as in $(C 0x9a.bc).
)

$(P $(B In the decimal system:) An exponent may be appended after the character $(C e) or $(C E), meaning "times 10 to the power of". For example, $(C 3.4e5) means "3.4 times 10 to the power of 5", or 340000.
)

$(P
The $(C -) character typed before the value of the exponent changes the meaning to be "divided by 10 to the power of". For example, $(C 7.8e-3) means "7.8 divided by 10 to the power of 3". A $(C +) character may also be specified before the value of the exponent, but it has no effect. For example, $(C 5.6e2) and $(C 5.6e+2) are the same.
)

$(P $(B In the hexadecimal system:) The value starts with either $(C 0x) or $(C 0X) and the parts before and after the point are specified in the numerals of the hexadecimal system. Since $(C e) and $(C E) are valid numerals in this system, the exponent is specified by $(C p) or $(C P).
)

$(P
Another difference is that the exponent does not mean "10 to the power of", but instead "2 to the power of". For example, the $(C P4) part in $(C 0xabc.defP4) means "2 to the power of 4".
)

$(P
Floating point literals almost always have a point but it may be omitted if an exponent is specified. For example, $(C 2e3) is a floating point literal with the value 2000.
)

$(P
The value before the point may be omitted if zero. For example, $(C .25) is a literal having the value "quarter".
)

$(P
The optional $(C _) characters may be used with floating point literals as well, as in $(C 1_000.5).
)

$(H6 The types of floating point literals)

$(P
Unless explicitly specified, the type of a floating point literal is $(C double). The $(C f) and $(C F) specifiers mean $(C float), and the $(C L) specifier means $(C real). For example; $(C 1.2) is $(C double), $(C 3.4f) is $(C float), and $(C 5.6L) is $(C real).
)

$(H5 Character literals)

$(P
Character literals are specified within single quotes as in $(C 'a'), $(C '\n'), $(C '\x21'), etc.
)

$(P $(B As the character itself:) The character may be typed directly by the keyboard or copied from a separate text: 'a', 'ş', etc.
)

$(P $(IX specifier, character) $(IX control character) $(B As the character specifier:) The character literal may be specified by a backslash character followed by a special character. For example, the backslash character itself can be specified by $(C '\\'). The following character specifiers are accepted:
)

<table class="medium" border="1" cellpadding="4" cellspacing="0">

<tr><th scope="col">&nbsp;Syntax&nbsp;</th> <th scope="col">Definition</th>
</tr>
<tr align="center"><td>\'</td>
    <td>single quote</td>
</tr>
<tr align="center"><td>\"</td>
    <td>double quote</td>
</tr>
<tr align="center"><td>\?</td>
    <td>question mark</td>
</tr>
<tr align="center"><td>\\</td>
    <td>backslash</td>
</tr>
<tr align="center"><td>\a</td>
    <td>alert (bell sound on some terminals)</td>
</tr>
<tr align="center"><td>\b</td>
    <td>delete character</td>
 </tr>
<tr align="center"><td>\f</td>
    <td>new page</td>
 </tr>
<tr align="center"><td>\n</td>
    <td>new-line</td>
 </tr>
<tr align="center"><td>\r</td>
    <td>carriage return</td>
 </tr>
<tr align="center"><td>\t</td>
    <td>tab</td>
 </tr>
<tr align="center"><td>\v</td>
    <td>vertical tab</td>
 </tr>
</table>

$(P $(B As the extended ASCII character code:) Character literals can also be specified by their codes. The codes can be specified either in the hexadecimal system or in the octal system. When using the hexadecimal system, the literal must start with $(C \x) and must use two digits for the code, and when using the octal system the literal must start with $(C \) and have up to three digits. For example, the literals $(C '\x21') and $(C '\41') are both the exclamation point.
)

$(P $(IX \u) $(IX \U) $(B As the Unicode character code:) When the literal is specified with $(C u) followed by 4 hexadecimal digits, then its type is $(C wchar). When it is specified with $(C U) followed by 8 hexadecimal digits, then its type is $(C dchar). For example, $(C '\u011e') and $(C '\U0000011e') are both the Ğ character, having the type $(C wchar) and $(C dchar), respectively.
)

$(P $(IX \&amp;) $(B As named character entity:) Characters that have entity names can be specified by that name using the HTML character entity syntax $(C '\&$(I name);'). D supports $(LINK2 http://dlang.org/entity.html, all character entities from HTML 5). For example, $(C '\&amp;euro;') is €, $(C '\&amp;hearts;') is ♥, and $(C '\&amp;copy;') is ©.
)

$(H5 $(IX string literal) $(IX literal, string) String literals)

$(P
String literals are a combination of character literals and can be specified in a variety of ways.
)

$(H6 Double-quoted string literals)

$(P
The most common way of specifying string literals is by typing their characters within double quotes as in $(C "hello"). Individual characters of string literals follow the rules of character literals. For example, the literal $(C "A4&nbsp;ka\u011fıt:&nbsp;3\&amp;frac12;TL") is the same as $(C "A4&nbsp;kağıt:&nbsp;3½TL").
)

$(H6 $(IX wysiwyg) $(I Wysiwyg) $(IX `) string literals)

$(P
When string literals are specified using back-quotes, the individual characters of the string do not obey the special syntax rules of character literals. For example, the literal $(STRING $(BACK_TICK)c:\nurten$(BACK_TICK)) can be a directory name on the Windows operating system. If it were written using double quotes, the $(C '\n') part would mean the $(I new-line) character:
)

---
    writeln(`c:\nurten`);
    writeln("c:\nurten");
---

$(SHELL
c:\nurten  $(SHELL_NOTE wysiwyg (what you see is what you get))
c:         $(SHELL_NOTE_WRONG the character literal is taken as new-line)
urten
)

$(P
Wysiwyg string literals can alternatively be specified using double quotes but prepended with the $(C r) character: $(C r"c:\nurten") is also a wysiwyg string literal.
)

$(H6 $(IX q&quot;&quot;) $(IX delimited string literal) Delimited string literals)

$(P
The string literal may contain delimiters that are typed right inside the double quotes. These delimiters are not considered to be parts of the value of the literal. Delimited string literals start with a $(C q) before the opening double quote. For example, the value of $(C q".hello.") is "hello"; the dots are not parts of the value. As long as it ends with a new-line, the delimiter can have more than one character:
)

---
writeln(q"MY_DELIMITER
first line
second line
MY_DELIMITER");
---

$(P
MY_DELIMITER is not a part of the value:
)

$(SHELL
first line
second line
)

$(P
$(IX heredoc) Such a multi-line string literal including all the indentation is called a $(I heredoc).
)

$(H6 $(IX q{}) $(IX token string literal) $(IX literal, token string) Token string literals)

$(P
String literals that start with $(C q) and that use $(C {) and $(C }) as delimiters can contain only legal D source code:
)

---
    auto str = q{int number = 42; ++number;};
    writeln(str);
---

$(P
The output:
)

$(SHELL
int number = 42; ++number;
)

$(P
This feature is particularly useful to help text editors display the contents of the string as syntax highlighted D code.
)

$(H6 $(IX string) $(IX wstring) $(IX dstring) Types of string literals)

$(P
By default the type of a string literal is $(C immutable(char)[]). An appended $(C c), $(C w), or $(C d) character specifies the type of the string explicitly as $(C immutable(char)[]), $(C immutable(wchar)[]), or $(C immutable(dchar)[]), respectively. For example, the characters of $(C "hello"d) are of type $(C immutable(dchar)).
)

$(P
We have seen in the $(LINK2 strings.html, Strings chapter) that these three string types are aliased as $(C string), $(C wstring), and $(C dstring), respectively.
)

$(H5 Literals are calculated at compile time)

$(P
It is possible to specify literals as expressions. For example, instead of writing the total number of seconds in January as $(C 2678400) or $(C 2_678_400), it is possible to specify it by the terms that make up that value, namely $(C 60 * 60 * 24 * 31). The multiplication operations in that expression do not affect the run-time speed of the program; the program is compiled as if $(C 2678400) were written instead.
)

$(P
The same applies to string literals. For example, the concatenation operation in $(C "hello&nbsp;"&nbsp;~&nbsp;"world") is executed at compile time, not at run time. The program is compiled as if the code contained the single string literal $(C "hello world").
)

$(PROBLEM_COK

$(PROBLEM
The following line causes a compilation error:

---
    int amount = 10_000_000_000;    $(DERLEME_HATASI)
---

$(P
Change the program so that the line can be compiled and that $(C amount) equals ten billions.
)

)

$(PROBLEM
Write a program that increases the value of a variable and prints it continuously. Make the value always be printed on the same line, overwriting the previous value:

$(SHELL
Number: 25774  $(SHELL_NOTE always on the same line)
)

$(P
A special character literal other than $(C '\n') may be useful here.
)

)

)

Macros:
        TITLE=Literals

        DESCRIPTION=The values that are typed in the source code.

        KEYWORDS=d programming language tutorial book literals
