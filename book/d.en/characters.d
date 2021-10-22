Ddoc

$(DERS_BOLUMU $(IX character) Characters)

$(P
Characters are building blocks of strings. Any symbol of a writing system is called a character: letters of alphabets, numerals, punctuation marks, the space character, etc. Confusingly, building blocks of characters themselves are called characters as well.
)

$(P
Arrays of characters make up $(I strings). We have seen arrays in the previous chapter; strings will be covered two chapters later.
)

$(P
Like any other data, characters are also represented as integer values that are made up of bits. For example, the integer value of the lowercase $(C 'a') is 97 and the integer value of the numeral $(C '1') is 49. These values are merely a convention, assigned when the ASCII standard was designed.
)

$(P
In many programming languages, characters are represented by the $(C char) type, which can hold only 256 distinct values. If you are familiar with the $(C char) type from other languages, you may already know that it is not large enough to support the symbols of many writing systems. Before getting to the three distinct character types of D, let's first take a look at the history of characters in computer systems.
)

$(H5 History)

$(H6 $(IX ASCII) ASCII Table)

$(P
The ASCII table was designed at a time when computer hardware was very limited compared to modern systems. Having been based on 7 bits, the ASCII table can have 128 distinct code values. That many distinct values are sufficient to represent the lowercase and uppercase versions of the 26 letters of the basic Latin alphabet, numerals, commonly used punctuation marks, and some terminal control characters.
)

$(P
As an example, the ASCII codes of the characters of the string $(STRING "hello") are the following (the commas are inserted just to make it easier to read):
)

$(MONO
104, 101, 108, 108, 111
)

$(P
Every code above represents a single letter of $(STRING "hello"). For example, there are two 108 values corresponding to the two $(C 'l') letters.
)

$(P
The codes of the ASCII table were later increased to 8 bits to become the Extended ASCII table. The Extended ASCII table has 256 distinct codes.
)

$(H6 $(IX code page) IBM Code Pages)

$(P
IBM Corporation has defined a set of tables, each one of which assign the codes of the Extended ASCII table from 128 to 255 to one or more writing systems. These code tables allowed supporting the letters of many more alphabets. For example, the special letters of the Turkish alphabet are a part of IBM's code page 857.
)

$(P
Despite being much more useful than ASCII, code pages have some problems and limitations: In order to display text correctly, it must be known what code page a given text was originally written in. This is because the same code corresponds to a different character in most other tables. For example, the code that represents $(C 'Ğ') in table 857 corresponds to $(C 'ª') in table 437.
)

$(P
In addition to the difficulty in supporting multiple alphabets in a single document, alphabets that have more than 128 non-ASCII characters cannot be supported by an IBM table at all.
)

$(H6 ISO/IEC 8859 Code Pages)

$(P
The ISO/IEC 8859 code pages are a result of international standardization efforts. They are similar to IBM's code pages in how they assign codes to characters. As an example, the special letters of the Turkish alphabet appear in code page 8859-9. These tables have the same problems and limitations as IBM's tables. For example, the Dutch digraph ĳ does not appear in any of these tables.
)

$(H6 $(IX unicode) Unicode)

$(P
Unicode solves all problems and limitations of previous solutions. Unicode includes more than a hundred thousand characters and symbols of the writing systems of many human languages, current and old. (New ones are constanly under review for addition to the table.) Each of these characters has a unique code. Documents that are encoded in Unicode can include all characters of separate writing systems without any confusion or limitation.
)

$(H5 $(IX encoding, unicode) Unicode encodings)

$(P
Unicode assigns a unique code for each character. Since there are more Unicode characters than an 8-bit value can hold, some characters must be represented by at least two 8-bit values. For example, the Unicode character code of $(C 'Ğ') (286) is greater than the maximum value of a $(C ubyte).
)

$(P
The way characters are represented in electronic mediums is called their $(I encoding). We have seen above how the string $(STRING "hello") is encoded in ASCII. We will now see three Unicode encodings that correspond to D's character types.
)

$(P
$(IX UTF-32) $(B UTF-32:) This encoding uses 32 bits (4 bytes) for every Unicode character. The UTF-32 encoding of $(STRING "hello") is similar to its ASCII encoding, but every character is represented with 4 bytes:
)

$(MONO
0,0,0,104, 0,0,0,101, 0,0,0,108, 0,0,0,108, 0,0,0,111
)

$(P
As another example, the UTF-32 encoding of $(STRING "aĞ") is the following:
)

$(MONO
0,0,0,97, 0,0,1,30
)

$(P
$(I $(B Note:) The order of the bytes of UTF-32 may be different on different computer systems.)
)

$(P
$(C 'a') and $(C 'Ğ') are represented by 1 and 2 significant bytes respectively, and the values of the other 5 bytes are all zeros. These zeros can be thought of as filler bytes to make every Unicode character occupy 4 bytes each.
)

$(P
For documents based on the basic Latin alphabet, this encoding always uses 4 times as many bytes as the ASCII encoding. When most of the characters of a given document have ASCII equivalents, the 3 filler bytes for each of those characters make this encoding more wasteful compared to other encodings.
)

$(P
On the other hand, there are benefits of representing every character by an equal number of bytes. For example, the next Unicode character is always exactly four bytes away.
)

$(P
$(IX UTF-16) $(B UTF-16:) This encoding uses 16 bits (2 bytes) to represent most of the Unicode characters. Since 16 bits can have about 65 thousand unique values, the other (less commonly used) 35 thousand Unicode characters must be represented using additional bytes.
)

$(P
As an example, $(STRING "aĞ") is encoded by 4 bytes in UTF-16:
)

$(MONO
0,97, 1,30
)

$(P
$(I $(B Note:) The order of the bytes of UTF-16 may be different on different computer systems.)
)

$(P
Compared to UTF-32, this encoding takes less space for most documents, but because some characters must be represented by more than 2 bytes, UTF-16 is more complicated to process.
)

$(P
$(IX UTF-8) $(B UTF-8:) This encoding uses 1 to 4 bytes for every character. If a character has an equivalent in the ASCII table, it is represented by 1 byte, with the same numeric code as in the ASCII table. The rest of the Unicode characters are represented by 2, 3, or 4 bytes. Most of the special characters of the European writing systems are among the group of characters that are represented by 2 bytes.
)

$(P
For most documents in western countries, UTF-8 is the encoding that takes the least amount of space. Another benefit of UTF-8 is that the documents that were produced using ASCII can be opened directly (without conversion) as UTF-8 documents. UTF-8 also does not waste any space with filler bytes, as every character is represented by significant bytes. As an example, the UTF-8 encoding of $(STRING "aĞ") is:
)

$(MONO
97, 196,158
)

$(H5 The character types of D)

$(P
$(IX char)
$(IX wchar)
$(IX dchar)
There are three D types to represent characters. These characters correspond to the three Unicode encodings mentioned above. Copying from $(LINK2 types.html, the Fundamental Types chapter):
)

<table class="wide" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">Type</th> <th scope="col">Definition</th> <th scope="col">Initial Value</th>
</tr>
<tr>		<td>char</td>
	<td>UTF-8 code unit</td>
	<td>0xFF</td>
</tr>

<tr>		<td>wchar</td>
	<td>UTF-16 code unit</td>
	<td>0xFFFF</td>
</tr>
<tr>		<td>dchar</td>
	<td>UTF-32 code unit and Unicode code point</td>

	<td>0x0000FFFF</td>
</tr>
</table>

$(P
Contrary to some other programming languages, characters in D may consist of different numbers of bytes. For example, because $(C 'Ğ') must be represented by at least 2 bytes in Unicode, it doesn't fit in a variable of type $(C char). On the other hand, because $(C dchar) consists of 4 bytes, it can hold any Unicode character.
)

$(H5 $(IX literal, character) Character literals)

$(P
Literals are constant values that are written in the program as a part of the source code. In D, character literals are specified within single quotes:
)

---
    char  letter_a = 'a';
    wchar letter_e_acute = 'é';
---

$(P
Double quotes are not valid for characters because double quotes are used when specifying $(I strings), which we will see in $(LINK2 strings.html, a later chapter). $(C 'a') is a character literal and $(STRING "a") is a string literal that consists of a single character.
)

$(P
Variables of type $(C char) can only hold letters that are in the ASCII table.
)

$(P
There are many ways of inserting characters in code:
)

$(UL
$(LI Most naturally, typing them on the keyboard.
)

$(LI Copying from another program or another text. For example, you can copy and paste from a web site, or from a program that is specifically for displaying Unicode characters. (One such program in most Linux environments is $(I Character Map) ($(C charmap) on the terminal).)
)

$(LI Using short names of the characters. The syntax for this feature is $(C \&$(I character_name);). For example, the name of the Euro sign is $(C euro) and it can be specified in the program as follows:

---
    wchar currencySymbol = '\&euro;';
---

$(P
See $(LINK2 http://dlang.org/entity.html, the list of named characters) for all characters that can be specified this way.
)

)

$(LI Specifying characters by their integer Unicode values:

---
    char a = 97;
    wchar Ğ = 286;
---

)

$(LI Specifying the codes of the characters of the ASCII table either by $(C \$(I value_in_octal)) or $(C \x$(I value_in_hexadecimal)) syntax:

---
    char questionMarkOctal = '\77';
    char questionMarkHexadecimal = '\x3f';
---

)

$(LI Specifying the Unicode values of the characters by using the $(C \u$(I four_digit_value)) syntax for $(C wchar), and the $(C \U$(I eight_digit_value)) syntax for $(C dchar) (note $(C u) versus $(C U)). The Unicode values must be specified in hexadecimal:

---
    wchar Ğ_w = '\u011e';
    dchar Ğ_d = '\U0000011e';
---

)

)

$(P
These methods can be used to specify the characters within strings as well. For example, the following two lines have the same string literals:
)
---
    writeln("Résumé preparation: 10.25€");
    writeln("\x52\&eacute;sum\u00e9 preparation: 10.25\&euro;");
---

$(H5 $(IX control character) Control characters)

$(P
Some characters only affect the formatting of the text, they don't have a visual representation themselves. For example, the $(I new-line) character, which specifies that the output should continue on a new line, does not have a visual representation. Such characters are called $(I control characters). Some common control characters can be specified with the $(C \$(I control_character)) syntax.
)

<table class="wide" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">Syntax</th> <th scope="col">Name</th> <th scope="col">Definition</th>

</tr>
<tr>
 <td>\n</td>
 <td>new&nbsp;line</td>
 <td>Moves the printing to a new line</td>
</tr>
<tr>
 <td>\r</td>
 <td>carriage&nbsp;return</td>
 <td>Moves the printing to the beginning of the current line</td>
</tr>
<tr>
 <td>\t</td>
 <td>tab</td>
 <td>Moves the printing to the next tab stop</td>
</tr>
</table>

$(P
For example, the $(C write()) function, which does not start a new line automatically, would do so for every $(C \n) character. Every occurrence of the $(C \n) control character within the following literal represents the start of a new line:
)

---
    write("first line\nsecond line\nthird line\n");
---

$(P
The output:
)

$(SHELL
first line
second line
third line
)

$(H5 $(IX ') $(IX \) Single quote and backslash)

$(P
The single quote character itself cannot be written within single quotes because the compiler would take the second one as the closing character of the first one: $(C '''). The first two would be the opening and closing quotes, and the third one would be left alone, causing a compilation error.
)

$(P
Similarly, since the backslash character has a special meaning in the control character and literal syntaxes, the compiler would take it as the start of such a syntax: $(C '\'). The compiler then would be looking for a closing single quote character, not finding one, and emitting a compilation error.
)

$(P
For those reasons, the single quote and the backslash characters are $(I escaped) by a preceding backslash character:
)

<table class="wide" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">Syntax</th> <th scope="col">Name</th> <th scope="col">Definition</th>

</tr>
<tr>
 <td>\'</td>
 <td>single&nbsp;quote</td>
 <td>Allows specifying the single quote character:'\''</td>
</tr>
<tr>
 <td>\\</td>
 <td>backslash</td>
 <td>Allows specifying the backslash character: '\\' or "\\"</td>
</tr>
</table>

$(H5 $(IX std.uni) The std.uni module)

$(P
The $(C std.uni) module includes functions that are useful for working with Unicode characters. You can see this module at $(LINK2 http://dlang.org/phobos/std_uni.html, its documentation).
)

$(P
The functions that start with $(C is) answer certain questions about characters. The result is $(C false) or $(C true) depending on whether the answer is no or yes, respectively. These functions are useful in logical expressions:
)

$(UL
$(LI $(C isLower): is it a lowercase character?
)
$(LI $(C isUpper): is it an uppercase character?
)
$(LI $(C isAlpha): is it a Unicode alphabetic character?
)
$(LI $(C isWhite): is it a whitespace character?
)
)

$(P
The functions that start with $(C to) produce new characters from existing ones:
)

$(UL
$(LI $(C toLower): produces the lowercase version of the given character
)
$(LI $(C toUpper): produces the uppercase version of the given character
)
)

$(P
Here is a program that uses all those functions:
)

---
import std.stdio;
import std.uni;

void main() {
    writeln("Is ğ lowercase? ", isLower('ğ'));
    writeln("Is Ş lowercase? ", isLower('Ş'));

    writeln("Is İ uppercase? ", isUpper('İ'));
    writeln("Is ç uppercase? ", isUpper('ç'));

    writeln("Is z alphabetic? ",       isAlpha('z'));
    writeln("Is \&euro; alphabetic? ", isAlpha('\&euro;'));

    writeln("Is new-line whitespace? ",   isWhite('\n'));
    writeln("Is the underscore whitespace? ", isWhite('_'));

    writeln("The lowercase of Ğ: ", toLower('Ğ'));
    writeln("The lowercase of İ: ", toLower('İ'));

    writeln("The uppercase of ş: ", toUpper('ş'));
    writeln("The uppercase of ı: ", toUpper('ı'));
}
---

$(P
The output:
)

$(SHELL
Is ğ lowercase? true
Is Ş lowercase? false
Is İ uppercase? true
Is ç uppercase? false
Is z alphabetic? true
Is € alphabetic? false
Is new-line whitespace? true
Is the underscore whitespace? false
The lowercase of Ğ: ğ
The lowercase of İ: i
The uppercase of ş: Ş
The uppercase of ı: I
)

$(H5 Limited support for ı and i)

$(P
The lowercase and uppercase versions of the letters $(C 'ı') and $(C 'i') are consistently dotted or undotted in some alphabets (e.g. the Turkish alphabet). Most other aphabets are inconsistent in this regard: the uppercase of the dotted $(C 'i') is undotted $(C 'I').
)

$(P
Because the computer systems have started with the ASCII table, traditionally the uppercase of $(C 'i') is $(C 'I') and the lowercase of $(C 'I') is $(C 'i'). For that reason, these two letters may need special attention. The following program demonstrates this problem:
)

---
import std.stdio;
import std.uni;

void main() {
    writeln("The uppercase of i: ", toUpper('i'));
    writeln("The lowercase of I: ", toLower('I'));
}
---

$(P
The output is according to the basic Latin alphabet:
)

$(SHELL
The uppercase of i: I
The lowercase of I: i
)

$(P
Characters are converted between their uppercase and lowercase versions normally by their Unicode character codes. This method is problematic for many alphabets. For example, the Azeri and Celt alphabets are subject to the same problem of producing the lowercase of $(C 'I') as $(C 'i').
)

$(P
There are similar problems with sorting: Many letters like $(C 'ğ') and $(C 'á') may be sorted after $(C 'z') even for the basic Latin alphabet.
)

$(H5 $(IX read, character) Problems with reading characters)

$(P
The flexibility and power of D's Unicode characters may cause unexpected results when reading characters from an input stream. This contradiction is due to the multiple meanings of the term $(I character). Before expanding on this further, let's look at a program that exhibits this problem:
)

---
import std.stdio;

void main() {
    char letter;
    write("Please enter a letter: ");
    readf(" %s", &letter);
    writeln("The letter that has been read: ", letter);
}
---

$(P
If you try that program in an environment that does not use Unicode, you may see that even the non-ASCII characters are read and printed correctly.
)

$(P
On the other hand, if you start the same program in a Unicode environment (e.g. a Linux terminal), you may see that the character printed on the output is not the same character that has been entered. To see this, let's enter a non-ASCII character in a terminal that uses the UTF-8 encoding (like most Linux terminals):
)

$(SHELL
Please enter a letter: ğ
The letter that has been read:   $(SHELL_NOTE no letter on the output)
)

$(P
The reason for this problem is that the non-ASCII characters like $(C 'ğ') are represented by two codes, and reading a $(C char) from the input reads only the first one of those codes. Since that single $(C char) is not sufficient to represent the whole Unicode character, the program does not have a complete character to display.
)

$(P
To show that the UTF-8 codes that make up a character are indeed read one $(C char) at a time, let's read two $(C char) variables and print them one after the other:
)

---
import std.stdio;

void main() {
    char firstCode;
    char secondCode;

    write("Please enter a letter: ");
    readf(" %s", &firstCode);
    readf(" %s", &secondCode);

    writeln("The letter that has been read: ",
            firstCode, secondCode);
}
---

$(P
The program reads two $(C char) variables from the input and prints them in the same order that they are read. When those codes are sent to the terminal in that same order, they complete the UTF-8 encoding of the Unicode character on the terminal and this time the Unicode character is printed correctly:
)

$(SHELL
Please enter a letter: ğ
The letter that has been read: ğ
)

$(P
These results are also related to the fact that the standard inputs and outputs of programs are $(C char) streams.
)

$(P
We will see later in $(LINK2 strings.html, the Strings chapter) that it is easier to read characters as strings, instead of dealing with UTF codes individually.
)

$(H5 D's Unicode support)

$(P
Unicode is a large and complicated standard. D supports a very useful subset of it.
)

$(P
A Unicode-encoded document consists of the following levels of concepts, from the lowermost to the uppermost:
)

$(UL

$(LI $(IX code unit) $(B Code unit): The values that make up the UTF encodings are called code units. Depending on the encoding and the characters themselves, Unicode characters are made up of one or more code units. For example, in the UTF-8 encoding the letter $(C 'a') is made up of a single code unit and the letter $(C 'ğ') is made up of two code units.

$(P
D's character types $(C char), $(C wchar), and $(C dchar) correspond to UTF-8, UTF-16, and UTF-32 code units, respectively.
)

)

$(LI $(IX code point) $(B Code point): Every letter, numeral, symbol, etc. that the Unicode standard defines is called a code point. For example, the Unicode code values of $(C 'a') and $(C 'ğ') are two distinct code points.

$(P
Depending on the encoding, code points are represented by one or more code units. As mentioned above, in the UTF-8 encoding $(C 'a') is represented by a single code unit, and $(C 'ğ') is represented by two code units. On the other hand, both $(C 'a') and $(C 'ğ') are represented by a single code unit in both UTF-16 and UTF-32 encodings.
)

$(P
The D type that supports code points is $(C dchar). $(C char) and $(C wchar) can only be used as code units.
)

)

$(LI $(B Character): Any symbol that the Unicode standard defines and what we call "character" or "letter" in daily talk is a character.

$(P
$(IX combined code point) This definition of character is flexible in Unicode, which brings a complication. Some characters can be formed by more than one code point. For example, the letter $(C 'ğ') can be specified in two ways:
)

$(UL

$(LI as the single code point for $(C 'ğ'))

$(LI as the two code points for $(C 'g') and $(C '˘') (combining breve)

)

)

$(P
Although they would mean the same character to a human reader, the single code point $(C 'ğ') is different from the two consecutive code points $(C 'g') and $(C '˘').
)

)

)

$(H5 Summary)

$(UL

$(LI Unicode supports all characters of all writing systems.)

$(LI $(C char) is for UTF-8 encoding; although it is not suitable to represent characters in general, it supports the ASCII table.)

$(LI $(C wchar) is for UTF-16 encoding; although it is not suitable to represent characters in general, it can support letters of multiple alphabets.)

$(LI $(C dchar) is for UTF-32 encoding; as it is 32 bits, it can also represent code points.)

)

Macros:
        TITLE=Characters

        DESCRIPTION=The character types of D and Unicode encodings

        KEYWORDS=d programming language tutorial book characters encoding char wchar dchar utf-8 utf-16 utf-32 unicode ascii
