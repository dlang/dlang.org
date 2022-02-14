Ddoc

$(DERS_BOLUMU $(IX bit operation) Bit Operations)

$(P
This chapter covers operations on bits, the smallest data units. Bit operations are among the most fundamental features of microprocessors.
)

$(P
System programmers must understand bit operations at least to use $(I flag) parameters correctly.
)

$(H5 Representation of data at the lowest level)

$(P
Programming languages are abstractions. A user type like $(C Student) defined in a programming language is not directly related to the internals of the computer. Programming languages are tools that help humans use the hardware without needing to know the details of the hardware.
)

$(P
Although it is usually not necessary to deal with the hardware directly, it is helpful to understand how data is represented at hardware level.
)

$(H6 $(IX transistor) Transistor)

$(P
The processing abilities of modern electronic devices are mostly based on the electronic element called $(I the transistor). A significant ability of the transistor is that it can be controlled by other parts of the electronic circuit that the transistor is a part of. In a way, it allows the electronic circuit be aware of itself and be able to change its own state.
)

$(H6 $(IX bit) Bit)

$(P
The smallest unit of information is a bit. A bit can be represented by any two-state system (e.g. by a special arrangement of a few transistors of an electronic circuit). A bit can have one of two values: 0 or 1. In the computer's memory, the information that is stored in a bit persists until a new value is stored or until the energy source is disconnected.
)

$(P
Computers do not provide direct access to bits. One reason is that doing so would complicate the design of the computer and as a consequence make the computer more expensive. Another reason is that there are not many concepts that can be represented by a single bit.
)

$(H6 $(IX byte) Byte)

$(P
A byte is a combination of 8 bits. The smallest unit of information that can be addressed uniquely is a byte. Computers read from or write to memory at least one byte at a time.
)

$(P
For that reason, although it carries one bit of information ($(C false) or $(C true)), even $(C bool) must be implemented as one byte:
)

---
    writefln("%s is %s byte(s)", bool.stringof, bool.sizeof);
---

$(SHELL_SMALL
bool is 1 byte(s)
)

$(H6 $(IX register, CPU) Register)

$(P
Data that are being operated on in a microprocessor are stored in registers. Registers provide very limited but very fast operations.
)

$(P
The size of the registers depend on the architecture of the microprocessor. For example, 32-bit microprocessors commonly have 4-byte registers and 64-bit microprocessors commonly have 8-byte registers. The size of the registers determine how much information the microprocessor can process efficiently at a time and how many memory addresses that it can support.
)

$(P
Every task that is achieved by a programming language ends up being executed by one or more registers of the microprocessor.
)

$(H5 $(IX binary system) Binary number system)

$(P
The decimal number system which is used in daily life consists of 10 numerals: 0123456789. In contrast, the binary number system which is used by computer hardware consists of 2 numerals: 0 and 1. This is a direct consequence of a bit consisting of two values. If bits had three values then the computers would use a number system based on three numerals.
)

$(P
The digits of the decimal system are named incrementally as $(I ones), $(I tens), $(I hundreds), $(I thousands), etc. For example, the number 1023 can be expanded as in the following way:
)

$(MONO
1023 == 1 count of thousand, no hundred, 2 counts of ten, and 3 counts of one
)

$(P
Naturally, moving one digit to the left multiplies the value of that digit by 10: 1, 10, 100, 1000, etc.
)

$(P
When the same rules are applied to a system that has two numerals, we arrive at the binary number system. The digits are named incrementally as $(I ones), $(I twos), $(I fours), $(I eights), etc. In other words, moving one digit to the left would multiply the value of that digit by 2: 1, 2, 4, 8, etc. For example, the $(I binary) number 1011 can be expanded as in the following way:
)

$(MONO
1011 == 1 count of eight, no four, 1 count of two, and 1 count of one
)

$(P
To make it easy to refer to digits, they are numbered from the rightmost digit to the leftmost digit, starting by 0. The following table lists the values of all of the digits of a 32-bit unsigned number in the binary system:
)

<table class="narrow" border="1" cellpadding="4" cellspacing="0"><tr><th scope="col">Digit</th> <th scope="col">Value</th></tr>
<tr align="right"><td>31</td><td>2,147,483,648</td></tr>
<tr align="right"><td>30</td><td>1,073,741,824</td></tr>
<tr align="right"><td>29</td><td>536,870,912</td></tr>
<tr align="right"><td>28</td><td>268,435,456</td></tr>
<tr align="right"><td>27</td><td>134,217,728</td></tr>
<tr align="right"><td>26</td><td>67,108,864</td></tr>
<tr align="right"><td>25</td><td>33,554,432</td></tr>
<tr align="right"><td>24</td><td>16,777,216</td></tr>
<tr align="right"><td>23</td><td>8,388,608</td></tr>
<tr align="right"><td>22</td><td>4,194,304</td></tr>
<tr align="right"><td>21</td><td>2,097,152</td></tr>
<tr align="right"><td>20</td><td>1,048,576</td></tr>
<tr align="right"><td>19</td><td>524,288</td></tr>
<tr align="right"><td>18</td><td>262,144</td></tr>
<tr align="right"><td>17</td><td>131,072</td></tr>
<tr align="right"><td>16</td><td>65,536</td></tr>
<tr align="right"><td>15</td><td>32,768</td></tr>
<tr align="right"><td>14</td><td>16,384</td></tr>
<tr align="right"><td>13</td><td>8,192</td></tr>
<tr align="right"><td>12</td><td>4,096</td></tr>
<tr align="right"><td>11</td><td>2,048</td></tr>
<tr align="right"><td>10</td><td>1,024</td></tr>
<tr align="right"><td>9</td><td>512</td></tr>
<tr align="right"><td>8</td><td>256</td></tr>
<tr align="right"><td>7</td><td>128</td></tr>
<tr align="right"><td>6</td><td>64</td></tr>
<tr align="right"><td>5</td><td>32</td></tr>
<tr align="right"><td>4</td><td>16</td></tr>
<tr align="right"><td>3</td><td>8</td></tr>
<tr align="right"><td>2</td><td>4</td></tr>
<tr align="right"><td>1</td><td>2</td></tr>
<tr align="right"><td>0</td><td>1</td></tr>
</table>

$(P
The bits that have higher values are called the $(I upper) bits and the bits that have lower values are called the $(I lower) bits.
)

$(P
Remembering from $(LINK2 literals.html, the Literals chapter) that binary literals are specified by the $(C 0b) prefix, the following program demonstrates how the value of a literal would correspond to the rows of the previous table:
)

---
import std.stdio;

void main() {
    //               1073741824                     4 1
    //               ↓                              ↓ ↓
    int number = 0b_01000000_00000000_00000000_00000101;
    writeln(number);
}
---

$(P
The output:
)

$(SHELL_SMALL
1073741829
)

$(P
Note that the literal consists of only three nonzero bits. The value that is printed is the sum of the values that correspond to those bits from the previous table: 1073741824 + 4 + 1 == 1073741829.
)

$(H6 $(IX sign bit) The $(I sign) bit of signed integer types)

$(P
The uppermost bit of a signed type determines whether the value is positive or negative:
)

---
    int number = 0b_$(HILITE 1)0000000_00000000_00000000_00000000;
    writeln(number);
---

$(SHELL_SMALL
-2147483648
)

$(P
However, the uppermost bit is not entirely separate from the value. For example, as evidenced above, the fact that all of the other bits of the number being 0 does not mean that the value is -0. (In fact, -0 is not a valid value for integers.) I will not get into more detail in this chapter other than noting that this is due to the $(I twos complement) representation, which is used by D as well.
)

$(P
What is important here is that 2,147,483,648; the highest value in the previous table, is only for unsigned integer types. The same experiment with $(C uint) would print that exact value:
)

---
    $(HILITE uint) number = 0b_10000000_00000000_00000000_00000000;
    writeln(number);
---

$(SHELL_SMALL
2147483648
)

$(P
Partly for that reason, unless there is a reason not to, bit operations must always be executed on unsigned types: $(C ubyte), $(C ushort), $(C uint), and $(C ulong).
)

$(H5 $(IX hexadecimal system) Hexadecimal number system)

$(P
As can be seen in the literals above, consisting only of 0s and 1s, the binary system may not be readable especially when the numbers are large. For that reason, the more readable hexadecimal system has been widely adopted especially in computer technologies.
)

$(P
The hexadecimal system has 16 numerals. Since alphabets do not have more than 10 numerals, this system borrows 6 letters from the Latin alphabet and uses them along with regular numerals: 0123456789abcdef. The numerals a, b, c, d, e, and f have the values 10, 11, 12, 13, 14, and 15, respectively. The letters ABCDEF can be used as well.
)

$(P
Similar to other number systems, the value of every digit is 16 times the value of the digit on its right-hand side: 1, 16, 256, 4096, etc. For example, the values of all of the digits of an 8-digit unsigned hexadecimal number are the following:
)

<table class="narrow" border="1" cellpadding="4" cellspacing="0"><tr><th scope="col">Digit</th> <th scope="col">Value</th></tr>
<tr align="right"><td>7</td><td>268,435,456</td></tr>
<tr align="right"><td>6</td><td>16,777,216</td></tr>
<tr align="right"><td>5</td><td>1,048,576</td></tr>
<tr align="right"><td>4</td><td>65,536</td></tr>
<tr align="right"><td>3</td><td>4,096</td></tr>
<tr align="right"><td>2</td><td>256</td></tr>
<tr align="right"><td>1</td><td>16</td></tr>
<tr align="right"><td>0</td><td>1</td></tr>
</table>

$(P
Remembering that hexadecimal literals are specified by the $(C 0x) prefix, we can see how the values of the digits contribute to the overall value of a number:
)

---
    //           1048576 4096 1
    //                 ↓  ↓  ↓
    uint number = 0x_0030_a00f;
    writeln(number);
---

$(SHELL_SMALL
3186703
)

$(P
The value that is printed is by the contributions of all of the nonzero digits: 3 count of 1048576, $(C a) count of 4096, and $(C f) count of 1. Remembering that $(C a) represents 10 and $(C f) represents 15, the value is 3145728 + 40960 + 15 == 3186703.
)

$(P
It is straightforward to convert between binary and hexadecimal numbers. In order to convert a hexadecimal number to binary, the digits of the hexadecimal number are converted to their binary representations individually. The corresponding representations in the three number systems are as in the following table:
)

<table class="narrow" border="1" cellpadding="4" cellspacing="0"><tr><th scope="col" align="center">Hexadecimal</th> <th scope="col">Binary</th>  <th scope="col">Decimal</th></tr>
<tr align="center"><td>0</td><td>0000</td><td>0</td></tr>
<tr align="center"><td>1</td><td>0001</td><td>1</td></tr>
<tr align="center"><td>2</td><td>0010</td><td>2</td></tr>
<tr align="center"><td>3</td><td>0011</td><td>3</td></tr>
<tr align="center"><td>4</td><td>0100</td><td>4</td></tr>
<tr align="center"><td>5</td><td>0101</td><td>5</td></tr>
<tr align="center"><td>6</td><td>0110</td><td>6</td></tr>
<tr align="center"><td>7</td><td>0111</td><td>7</td></tr>
<tr align="center"><td>8</td><td>1000</td><td>8</td></tr>
<tr align="center"><td>9</td><td>1001</td><td>9</td></tr>
<tr align="center"><td>a</td><td>1010</td><td>10</td></tr>
<tr align="center"><td>b</td><td>1011</td><td>11</td></tr>
<tr align="center"><td>c</td><td>1100</td><td>12</td></tr>
<tr align="center"><td>d</td><td>1101</td><td>13</td></tr>
<tr align="center"><td>e</td><td>1110</td><td>14</td></tr>
<tr align="center"><td>f</td><td>1111</td><td>15</td></tr>
</table>

$(P
For example, the hexadecimal number 0x0030a00f can be written in the binary form by converting its digits individually according to the previous table:
)

---
    // hexadecimal:     0    0    3    0    a    0    0    f
    uint binary = 0b_0000_0000_0011_0000_1010_0000_0000_1111;
---

$(P
Converting from binary to hexadecimal is the reverse: The digits of the binary number are converted to their hexadecimal representations four digits at a time. For example, here is how to write in hexadecimal the same binary value that we have used earlier:
)
---
    // binary:           0100 0000 0000 0000 0000 0000 0000 0101
    uint hexadecimal = 0x___4____0____0____0____0____0____0____5;
---

$(H5 Bit operations)

$(P
After going over how values are represented by bits and how numbers are represented in binary and hexadecimal, we can now see operations that change values at bit-level.
)

$(P
Because there is no direct access to individual bits, even though these operations are at bit-level, they affect at least 8 bits at a time. For example, for a variable of type $(C ubyte), a bit operation would be applied to all of the 8 bits of that variable.
)

$(P
As the uppermost bit is the sign bit for signed types, I will ignore signed types and use only $(C uint) in the examples below. You can repeat these operations with $(C ubyte), $(C ushort), and $(C ulong); as well as $(C byte), $(C short), $(C int), and $(C long) as long as you remember the special meaning of the uppermost bit.
)

$(P
Let's first define a function which will be useful later when examining how bit operators work. This function will print a value in binary, hexadecimal, and decimal systems:
)

---
import std.stdio;

void print(uint number) {
    writefln("  %032b %08x %10s", number, number, number);
}

void main() {
    print(123456789);
}
---

$(P
Here is the same value printed in the binary, hexadecimal, and decimal number systems:
)

$(SHELL_SMALL
  00000111010110111100110100010101 075bcd15  123456789
)

$(H6 $(IX ~, bitwise complement) $(IX complement, bitwise operator) Complement operator: $(C ~))

$(P
$(I Not to be confused with the $(I binary) $(C ~) operator that is used for array concatenation, this is the unary $(C ~) operator.)
)

$(P
This operator converts each bit of a value to its opposite: The bits that are 0 become 1, and the bits that are 1 become 0.
)

---
    uint value = 123456789;
    print(value);
    writeln("~ --------------------------------");
    print($(HILITE ~)value);
---

$(P
The effect is obvious in the binary representation. Every bit has been reversed (under the dashed line):
)

$(SHELL_SMALL
  00000111010110111100110100010101 075bcd15  123456789
~ --------------------------------
  11111000101001000011001011101010 f8a432ea 4171510506
)

$(P
Here is the summary of how the unary $(C ~) operator works:
)

$(MONO
~0 → 1
~1 → 0
)

$(H6 $(IX &, bitwise and) $(IX and, bitwise operator) $(I And) operator: $(C &))

$(P
$(C &) is a binary operator, written between two expressions. The microprocessor considers two corresponding bits of the two expressions separately from all of the other bits: Bits 31, 30, 29, etc. of the expressions are evaluated separately. The value of each resultant bit is 1 if both of the corresponding bits of the expressions are 1; 0 otherwise.
)

---
    uint lhs = 123456789;
    uint rhs = 987654321;

    print(lhs);
    print(rhs);
    writeln("& --------------------------------");
    print(lhs $(HILITE &) rhs);
---

$(P
The following output contains first the left-hand side expression (lhs) and then the right-hand side expression (rhs). The result of the $(C &) operation is under the dashed line:
)

$(SHELL_SMALL
  00000111010110111100110100010101 075bcd15  123456789
  00111010110111100110100010110001 3ade68b1  987654321
& --------------------------------
  00000010010110100100100000010001 025a4811   39471121
)

$(P
Note that the bits of the result that have the value 1 are the ones where the corresponding bits of the expressions are both 1.
)

$(P
This operator is called the $(I and) operator because it produces 1 when both the left-hand side $(I and) the right-hand side bits are 1. Among the four possible combinations of 0 and 1 values, only the one where both of the values are 1 produces 1:
)

$(MONO
0 & 0 → 0
0 & 1 → 0
1 & 0 → 0
1 & 1 → 1
)

$(P
Observations:
)

$(UL

$(LI When one of the bits is 0, regardless of the other bit the result is always 0. Accordingly, "$(I anding) a bit by 0" means to clear that bit.)

$(LI When one of the bits is 1, the result is the value of the other bit; $(I anding) by 1 has no effect.)

)

$(H6 $(IX |) $(IX or, bitwise operator) $(I Or) operator: $(C |))

$(P
$(C |) is a binary operator, written between two expressions. The microprocessor considers two corresponding bits of the two expressions separately from all of the other bits. The value of each resultant bit is 0 if both of the corresponding bits of the expressions are 0; 1 otherwise.
)

---
    uint lhs = 123456789;
    uint rhs = 987654321;

    print(lhs);
    print(rhs);
    writeln("| --------------------------------");
    print(lhs $(HILITE |) rhs);
---

$(SHELL_SMALL
  00000111010110111100110100010101 075bcd15  123456789
  00111010110111100110100010110001 3ade68b1  987654321
| --------------------------------
  00111111110111111110110110110101 3fdfedb5 1071639989
)

$(P
Note that the bits of the result that have the value 0 are the ones where the corresponding bits of the expressions are both 0. When the corresponding bit in the left-hand side or in the right-hand side is 1, then the result is 1:
)

$(MONO
0 | 0 → 0
0 | 1 → 1
1 | 0 → 1
1 | 1 → 1
)

$(P
Observations:
)

$(UL

$(LI When one of the bits is 1, regardless of the other bit the result is always 1. Accordingly, "$(I orring) a bit by 1" means to set it.)

$(LI When one of the bits is 0, the result is the value of the other bit; $(I orring) by 0 has no effect.)

)

$(H6 $(IX ^, bitwise exclusive or) $(IX xor, bitwise operator) $(IX exclusive or, bitwise operator) $(I Xor) operator: $(C ^))

$(P
$(I Xor) is the short for $(I exclusive or). This is a binary operator as well. It produces 1 if the corresponding bits of the two expressions are different:
)

---
    uint lhs = 123456789;
    uint rhs = 987654321;

    print(lhs);
    print(rhs);
    writeln("^ --------------------------------");
    print(lhs $(HILITE ^) rhs);
---

$(SHELL_SMALL
  00000111010110111100110100010101 075bcd15  123456789
  00111010110111100110100010110001 3ade68b1  987654321
^ --------------------------------
  00111101100001011010010110100100 3d85a5a4 1032168868
)

$(P
Note that the bits of the result that have the value 1 are the ones where the corresponding bits of the expressions are different from each other.
)

$(MONO
0 ^ 0 → 0
0 ^ 1 → 1
1 ^ 0 → 1
1 ^ 1 → 0
)

$(P
Observation:
)

$(UL
$(LI "$(I Xorring) a bit" with itself means to clear that bit.)
)

$(P
Regardless of its value, $(I xorring) a variable with itself always produces 0:
)

---
    uint value = 123456789;

    print(value ^ value);
---

$(SHELL_SMALL
  00000000000000000000000000000000 00000000          0
)

$(H6 $(IX >>) $(IX right shift, bitwise operator) Right-shift operator: $(C >>))

$(P
This operator shifts the bits of an expression by the specified number of bits to the right. The rightmost bits, which do not have room to shift into, get $(I dropped) from the value. For unsigned types, the leftmost bits are filled with zeros.
)

$(P
The following example produces a result by shifting a value by two bits to the right:
)

---
    uint value = 123456789;
    print(value);
    print(value $(HILITE >>) 2);
---

$(P
In the following output, I highlighted both the bits that are going to be lost due to dropping off from the right-hand side and the leftmost bits that get the value 0:
)

$(SHELL_SMALL
  000001110101101111001101000101$(HILITE 01) 075bcd15  123456789
  $(HILITE 00)000001110101101111001101000101 01d6f345   30864197
)

$(P
Note that the bits that are not highlighted have been shifted two bit positions to the right.
)

$(P
$(IX sign extension) The new bits that enter from the left-hand side are 0 only for unsigned types. For signed types, the value of the leftmost bits are determined by a process called $(I sign extension). Sign extension preserves the value of the sign bit of the original expression. The value of that bit is used for all of the bits that $(I enter) from the left.
)

$(P
Let's see this effect on a value of a signed type where the sign bit is 1 (i.e. the value is negative):
)

---
    $(HILITE int) value = 0x80010300;
    print(value);
    print(value >> 3);
---

$(P
Because the leftmost bit of the original value is 1, all of the new bits of the result are 1 as well:
)

$(SHELL_SMALL
  $(U 1)0000000000000010000001100000$(HILITE 000) 80010300 2147549952
  $(HILITE 111)10000000000000010000001100000 f0002060 4026540128
)

$(P
When the leftmost bit is 0, then all new bits are 0:
)

---
    $(HILITE int) value = 0x40010300;
    print(value);
    print(value >> 3);
---

$(SHELL_SMALL
  $(U 0)1000000000000010000001100000$(HILITE 000) 40010300 1073808128
  $(HILITE 000)01000000000000010000001100000 08002060  134226016
)

$(H6 $(IX >>>) $(IX unsigned right shift, bitwise operator) Unsigned right-shift operator: $(C >>>))

$(P
This operator works similarly to the regular right-shift operator. The difference is that the new leftmost bits are always 0 regardless of the type of the expression and the value of the leftmost bit:
)

---
    int value = 0x80010300;
    print(value);
    print(value $(HILITE >>>) 3);
---

$(SHELL_SMALL
  10000000000000010000001100000$(HILITE 000) 80010300 2147549952
  $(HILITE 000)10000000000000010000001100000 10002060  268443744
)

$(H6 $(IX <<) $(IX left shift, bitwise operator) Left-shift operator: $(C <<))

$(P
This operator works as the reverse of the right-shift operator. The bits are shifted to the left:
)

---
    uint value = 123456789;
    print(value);
    print(value $(HILITE <<) 4);
---

$(P
The bits on the left-hand side are lost and the new bits on the right-hand side are 0:
)

$(SHELL_SMALL
  $(HILITE 0000)0111010110111100110100010101 075bcd15  123456789
  0111010110111100110100010101$(HILITE 0000) 75bcd150 1975308624
)

$(H6 $(IX assignment, operation result) Operators with assignment)

$(P
All of the binary operators above have assignment counterparts: $(C &=), $(C |=), $(C ^=), $(C >>=), $(C >>>=), and $(C <<=). Similar to the operators that we saw in $(LINK2 arithmetic.html, the Integers and Arithmetic Operations chapter), these operators assign the result back to the left-hand operand.
)

$(P
Let's see this on the $(C &=) operator:
)

---
    value = value & 123;
    value &= 123;         // the same as above
---

$(H5 Semantics)

$(P
Merely understanding how these operators work at bit-level may not be sufficient to see how they are useful in programs. The following sections describe common ways that these operators are used in.
)

$(H6 $(C |) is a union set)

$(P
The $(C |) operator produces the union of the 1 bits in the two expressions.
)

$(P
As an extreme example, let's consider two values that both have alternating bits set to 1. The union of these values would produce a result where all of the bits are 1:
)

---
    uint lhs = 0xaaaaaaaa;
    uint rhs = 0x55555555;

    print(lhs);
    print(rhs);
    writeln("| --------------------------------");
    print(lhs | rhs);
---

$(SHELL_SMALL
  10101010101010101010101010101010 aaaaaaaa 2863311530
  01010101010101010101010101010101 55555555 1431655765
| --------------------------------
  11111111111111111111111111111111 ffffffff 4294967295
)

$(H6 $(C &) is an intersection set)

$(P
The $(C &) operator produces the intersection of the 1 bits in the two expressions.
)

$(P
As an extreme example, let's consider the last two values again. Since none of the 1 bits of the previous two expressions match the ones in the other expression, all of the bits of the result are 0:
)

---
    uint lhs = 0xaaaaaaaa;
    uint rhs = 0x55555555;

    print(lhs);
    print(rhs);
    writeln("& --------------------------------");
    print(lhs & rhs);
---

$(SHELL_SMALL
  10101010101010101010101010101010 aaaaaaaa 2863311530
  01010101010101010101010101010101 55555555 1431655765
& --------------------------------
  00000000000000000000000000000000 00000000          0
)

$(H6 $(C |=) sets selected bits to 1)

$(P
To understand how this works, it helps to see one of the expressions as the $(I actual) expression and the other expression as a $(I selector) for the bits to set to 1:
)

---
    uint expression = 0x00ff00ff;
    uint bitsToSet = 0x10001000;

    write("before     :"); print(expression);
    write("to set to 1:"); print(bitsToSet);

    expression $(HILITE |=) bitsToSet;
    write("after      :"); print(expression);
---

$(P
The before and after values of the bits that are affected are highlighted:
)

$(SHELL_SMALL
before     :  000$(HILITE 0)000011111111000$(HILITE 0)000011111111 00ff00ff   16711935
to set to 1:  00010000000000000001000000000000 10001000  268439552
after      :  000$(HILITE 1)000011111111000$(HILITE 1)000011111111 10ff10ff  285151487
)

$(P
In a sense, $(C bitsToSet) determines which bits to set to 1. The other bits are not affected.
)

$(H6 $(C &=) clears selected bits)

$(P
One of the expressions can be seen as the $(I actual) expression and the other expression can be seen as a $(I selector) for the bits to clear (to set to 0):
)

---
    uint expression = 0x00ff00ff;
    uint bitsToClear = 0xffefffef;

    write("before       :"); print(expression);
    write("bits to clear:"); print(bitsToClear);

    expression $(HILITE &=) bitsToClear;
    write("after        :"); print(expression);
---

$(P
The before and after values of the bits that are affected are highlighted:
)

$(SHELL_SMALL
before       :  00000000111$(HILITE 1)111100000000111$(HILITE 1)1111 00ff00ff   16711935
bits to clear:  11111111111011111111111111101111 ffefffef 4293918703
after        :  00000000111$(HILITE 0)111100000000111$(HILITE 0)1111 00ef00ef   15663343
)

$(P
In a sense, $(C bitsToClear) determines which bits to set to 0. The other bits are not affected.
)

$(H6 $(C &) determines whether a bit is 1 or not)

$(P
If one of the expressions has only one bit set to 1, then it can be used to query whether the corresponding bit of the other expression is 1:
)

---
    uint expression = 123456789;
    uint bitToQuery = 0x00010000;

    print(expression);
    print(bitToQuery);
    writeln(expression $(HILITE &) bitToQuery ? "yes, 1" : "not 1");
---

$(P
The bit that is being $(I queried) is highlighted:
)

$(SHELL_SMALL
  000001110101101$(HILITE 1)1100110100010101 075bcd15  123456789
  00000000000000010000000000000000 00010000      65536
yes, 1
)

$(P
Let's query another bit of the same expression by this time having another bit of $(C bitToQuery) set to 1:
)

---
    uint bitToQuery = 0x00001000;
---

$(SHELL_SMALL
0000011101011011110$(HILITE 0)110100010101 075bcd15  123456789
00000000000000000001000000000000 00001000       4096
not 1
)

$(P
When the query expression has more than one bit set to 1, then the query would determine whether $(I any) of the corresponding bits in the other expression are 1.
)

$(H6 Right-shifting by one is the equivalent of dividing by two)

$(P
Shifting all of the bits of a value by one position to the right produces half of the original value. The reason for this can be seen in the digit-value table above: In that table, every bit has half the value of the bit that is on its left.
)

$(P
Shifting a value to the right multiple bits at a time means dividing by 2 for that many times. For example, right-shifting by 3 bits would divide a value by 8:
)

---
    uint value = 8000;

    writeln(value >> 3);
---

$(SHELL_SMALL
1000
)

$(P
According to how the $(I twos complement) system works, right-shifting has the same effect on signed values:
)

---
    $(HILITE int) value = -8000;

    writeln(value >> 3);
---

$(SHELL_SMALL
-1000
)

$(H6 Left-shifting by one is the equivalent of multiplying by two)

$(P
Because each bit is two times the value of the bit on its right, shifting a value one bit to the left means multiplying that value by two:
)

---
    uint value = 10;

    writeln(value << 5);
---

$(P
Multiplying by 2 a total of 5 times is the same as multiplying by 32:
)

$(SHELL_SMALL
320
)

$(H5 Common uses)

$(H6 $(IX flag, bit) Flags)

$(P
Flags are single-bit independent data that are kept together in the same variable. As they are only one bit wide each, they are suitable for representing binary concepts like enabled/disabled, valid/invalid, etc.
)

$(P
Such one-bit concepts are sometimes encountered in D modules that are based on C libraries.
)

$(P
Flags are usually defined as non-overlapping values of an $(C enum) type.
)

$(P
As an example, let's consider a car racing game where the realism of the game is configurable:
)

$(UL
$(LI The fuel consumption is realistic or not.)
$(LI Collisions can damage the cars or not.)
$(LI Tires can deteriorate by use or not.)
$(LI Skid marks are left on the road surface or not.)
)

$(P
These configuration options can be specified at run time by the following $(C enum) values:
)

---
enum Realism {
    fuelUse    = 1 << 0,
    bodyDamage = 1 << 1,
    tireUse    = 1 << 2,
    skidMarks  = 1 << 3
}
---

$(P
Note that all of those values consist of single bits that do not conflict with each other. Each value is determined by left-shifting 1 by a different number of bits. The corresponding bit representations are the following:
)

$(MONO
fuelUse   : 0001
bodyDamage: 0010
tireUse   : 0100
skidMarks : 1000
)

$(P
Since their 1 bits do not match others', these values can be combined by the $(C |) operator to be kept in the same variable. For example, the two configuration options that are related to tires can be combined as in the following code:
)

---
    Realism flags = Realism.tireUse | Realism.skidMarks;
    writefln("%b", flags);
---

$(P
The bits of these two flags would be side-by-side in the variable $(C flags):
)

$(SHELL_SMALL
1100
)

$(P
Later, these flags can be queried by the $(C &) operator:
)

---
    if (flags & Realism.fuelUse) {
        // ... code related to fuel consumption ...
    }

    if (flags & Realism.tireUse) {
        // ... code related to tire consumption ...
    }
---

$(P
The $(C &) operator produces 1 only if the specified flag is set in $(C flags).
)

$(P
Also note that the result is usable in the $(C if) condition due to automatic conversion of the nonzero value to $(C true). The conditional expression is $(C false) when the result of $(C &) is 0 and $(C true) otherwise. As a result, the corresponding code block is executed only if the flag is enabled.
)

$(H6 $(IX mask, bit) Masking)

$(P
In some libraries and some protocols an integer value may carry more than one piece of information. For example, the upper 3 bits of a 32-bit value may have a certain meaning, while the lower 29 bits may have another meaning. These separate parts of data can be extracted from the variable by masking.
)

$(P
The four octets of an IPv4 address are an example of this concept. The octets are the individual values that make up the common dotted representation of an IPv4 address. They are all kept in a single 32-bit value.  For example, the IPv4 address 192.168.1.2 is the 32-bit value 0xc0a80102:
)

$(MONO
c0 == 12 * 16 + 0 = 192
a8 == 10 * 16 + 8 = 168
01 ==  0 * 16 + 1 =   1
02 ==  0 * 16 + 2 =   2
)

$(P
A mask consists of a number of 1 bits that would $(I cover) the specific part of a variable. $(I "And"ing) the value by the mask extracts the part of the variable that is covered by that mask. For example, the mask value of 0x000000ff would cover the lower 8 bits of a value:
)

---
    uint value = 123456789;
    uint mask  = 0x000000ff;

    write("value :"); print(value);
    write("mask  :"); print(mask);
    write("result:"); print(value & mask);
---

$(P
The bits that are covered by the mask are highlighted. All of the other bits are cleared:
)

$(SHELL_SMALL
value :  000001110101101111001101$(HILITE 00010101) 075bcd15  123456789
mask  :  00000000000000000000000011111111 000000ff        255
result:  000000000000000000000000$(HILITE 00010101) 00000015         21
)

$(P
Let's apply the same method to the 0xc0a80102 IPv4 address with a mask that would cover the uppermost 8 bits:
)

---
    uint value = 0xc0a80102;
    uint mask  = 0xff000000;

    write("value :"); print(value);
    write("mask  :"); print(mask);
    write("result:"); print(value & mask);
---

$(P
This mask covers the uppermost 8 bits of the value:
)

$(SHELL_SMALL
value :  $(HILITE 11000000)101010000000000100000010 c0a80102 3232235778
mask  :  11111111000000000000000000000000 ff000000 4278190080
result:  $(HILITE 11000000)000000000000000000000000 c0000000 3221225472
)

$(P
However, note that the printed result is not the expected 192 but 3221225472. That is because the masked value must also be shifted all the way to the right-hand side. Shifting the value 24 bit positions to the right would produce the value that those 8 bits represent:
)

---
    uint value = 0xc0a80102;
    uint mask  = 0xff000000;

    write("value :"); print(value);
    write("mask  :"); print(mask);
    write("result:"); print((value & mask) $(HILITE >> 24));
---

$(SHELL_SMALL
value :  $(HILITE 11000000)101010000000000100000010 c0a80102 3232235778
mask  :  11111111000000000000000000000000 ff000000 4278190080
result:  000000000000000000000000$(HILITE 11000000) 000000c0        $(HILITE 192)
)

$(PROBLEM_COK

$(PROBLEM
Write a function that returns an IPv4 address in its dotted form:

---
string dotted(uint address) {
    // ...
}

unittest {
    assert(dotted(0xc0a80102) == "192.168.1.2");
}
---

)

$(PROBLEM
Write a function that converts four octet values to the corresponding 32-bit IPv4 address:

---
uint ipAddress(ubyte octet3,    // most significant octet
               ubyte octet2,
               ubyte octet1,
               ubyte octet0) {  // least significant octet
    // ...
}

unittest {
    assert(ipAddress(192, 168, 1, 2) == 0xc0a80102);
}
---

)

$(PROBLEM
Write a function that can be used for making a mask. It should start with the specified bit and have the specified width:

---
uint mask(int lowestBit, int width) {
    // ...
}

unittest {
    assert(mask(2, 5) ==
           0b_0000_0000_0000_0000_0000_0000_0111_1100);
    //                                            ↑
    //                              lowest bit is 2,
    //                              and the mask is 5-bit wide
}
---

)

)

Macros:
        TITLE=Bit Operations

        DESCRIPTION=The low-level features of D that allow manipulating values at bit-level.

        KEYWORDS=d programming language tutorial book bit operations
