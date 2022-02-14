Ddoc

$(DERS_BOLUMU $(IX arithmetic operation) Integers and Arithmetic Operations)

$(P
We have seen that the $(C if) and $(C while) statements allow programs to make decisions by using the $(C bool) type in the form of logical expressions. In this chapter, we will see arithmetic operations on the $(I integer) types of D. These features will allow us to write much more useful programs.
)

$(P
Although arithmetic operations are a part of our daily lives and are actually simple, there are very important concepts that a programmer must be aware of in order to produce correct programs: the $(I bit length of a type), $(I overflow) (wrap), and $(I truncation).
)

$(P
Before going further, I would like to summarize the arithmetic operations in the following table as a reference:
)

<table class="wide" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">Operator</th> <th scope="col">Effect</th> <th scope="col">Sample</th>

</tr>
<tr align="center"><td>++</td>
    <td>increments by one</td>
    <td>++variable</td>
</tr>
<tr align="center"><td>--</td>
    <td>decrements by one</td>
    <td>--variable</td>
</tr>
<tr align="center"><td>+</td>
    <td>the result of adding two values</td>
    <td>first&nbsp;+&nbsp;second</td>
</tr>
<tr align="center"><td>-</td>
    <td>the result of subtracting 'second' from 'first'</td>
    <td>first&nbsp;-&nbsp;second</td>
</tr>
<tr align="center"><td>*</td>
    <td>the result of multiplying two values</td>
    <td>first&nbsp;*&nbsp;second</td>
</tr>
<tr align="center"><td>/</td>
    <td>the result of dividing 'first' by 'second'</td>
    <td>first&nbsp;/&nbsp;second</td>
</tr>
<tr align="center"><td>%</td>
    <td>the remainder of dividing 'first' by 'second'</td>
    <td>first&nbsp;%&nbsp;second</td>
</tr>
<tr align="center"><td>^^</td>
    <td>the result of raising 'first' to the power of 'second'$(BR)(multiplying 'first' by itself 'second' times)</td>
    <td>first&nbsp;^^&nbsp;second</td>
</tr>
</table>

$(P
$(IX +=) $(IX -=) $(IX *=) $(IX /=) $(IX %=) $(IX ^^=) Most of those operators have counterparts that have an $(C =) sign attached: $(C +=), $(C -=), $(C *=), $(C /=), $(C %=), and $(C ^^=). The difference with these operators is that they assign the result to the left-hand side:
)

---
    variable += 10;
---

$(P
That expression adds the value of $(C variable) and 10 and assigns the result to $(C variable). In the end, the value of $(C variable) would be increased by 10. It is the equivalent of the following expression:
)

---
    variable = variable + 10;
---

$(P
I would like also to summarize two important concepts here before elaborating on them below.
)

$(P
$(IX wrap) $(B Overflow:) Not all values can fit in a variable of a given type. If the value is too big for the variable we say that the variable $(I overflows). For example, a variable of type $(C ubyte) can have values only in the range of 0 to 255; so when assigned 260, the variable overflows, wraps around, and its value becomes 4. ($(I $(B Note:) Unlike some other languages like C and C++, overflow for signed types is legal in D. It has the same wrap around behavior of unsigned types.))
)

$(P
Similarly, a variable cannot have a value that is less than the minimum value of its type.
)

$(P
$(B Truncation:) Integer types cannot have values with fractional parts. For example, the value of the $(C int) expression $(C 3/2) is 1, not 1.5.
)

$(P
We encounter arithmetic operations daily without many surprises: if a bagel is &#36;1, two bagels are &#36;2; if four sandwiches are &#36;15, one sandwich is &#36;3.75, etc.
)

$(P
Unfortunately, things are not as simple with arithmetic operations in computers. If we don't understand how values are stored in a computer, we may be surprised to see that a company's debt is $(I reduced) to &#36;1.7 billion when it borrows &#36;3 billion more on top of its existing debt of &#36;3 billion! Or when a box of ice cream serves 4 kids, an arithmetic operation may claim that 2 boxes would be sufficient for 11 kids!
)

$(P
Programmers must understand how integers are stored in computers.)

$(H6 $(IX integer) Integer types)

$(P
Integer types are the types that can have only whole values like -2, 0, 10, etc. These types cannot have fractional parts, as in 2.5. All of the integer types that we saw in the $(LINK2 types.html, Fundamental Types chapter) are the following:
)

<table class="narrow" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">$(BR)Type</th> <th scope="col">Number of$(BR)Bits</th> <th scope="col">Initial$(BR)Value</th>

</tr>
<tr align="right"><td>byte</td>
    <td>8</td>
    <td>0</td>

</tr>
<tr align="right"> <td>ubyte</td>
    <td>8</td>
    <td>0</td>
</tr>
<tr align="right"> <td>short</td>

    <td>16</td>
    <td>0</td>
</tr>
<tr align="right"> <td>ushort</td>
    <td>16</td>
    <td>0</td>

</tr>
<tr align="right"> <td>int</td>
    <td>32</td>
    <td>0</td>
</tr>
<tr align="right"> <td>uint</td>

    <td>32</td>
    <td>0</td>
</tr>
<tr align="right"> <td>long</td>
    <td>64</td>
    <td>0L</td>

</tr>
<tr align="right"> <td>ulong</td>
    <td>64</td>
    <td>0LU</td>
</tr>
</table>

$(P
The $(C u) at the beginning of the type names stands for "unsigned" and indicates that such types cannot have values less than zero.
)

$(P
Although they are equal to $(C 0); $(C 0L) and $(C 0LU) are $(I manifest constants) typed as $(C long) and $(C ulong), respectively.
)

$(H6 $(IX bit) Number of bits of a type)

$(P
In today's computer systems, the smallest unit of information is called a $(I bit). At the physical level, a bit is represented by electrical signals around certain points in the circuitry of a computer. A bit can be in one of two states that correspond to different voltages in the area that defines that particular bit. These two states are arbitrarily defined to have the values 0 and 1. As a result, a bit can have one of these two values.
)

$(P
As there aren't many concepts that can be represented by just two states, a bit is not a very useful type. It can only be useful for concepts with two states like heads or tails or whether a light switch is on or off.
)

$(P
If we consider two bits together, the total amount of information that can be represented multiplies. Based on each bit having a value of 0 or 1 individually, there are a total of 4 possible states. Assuming that the left and right digits represent the first and second bit respectively, these states are 00, 01, 10, and 11. Let's add one more bit to see this effect better; three bits can be in 8 different states: 000, 001, 010, 011, 100, 101, 110, 111. As can be seen, each added bit doubles the total number of states that can be represented.
)

$(P
The values to which these eight states correspond are defined by conventions. The following table shows these values for the signed and unsigned representations of 3 bits:
)

<table class="narrow" border="1" cellpadding="4" cellspacing="0">
<tr align="right"><th scope="col">Bit State</th> <th scope="col">Unsigned Value</th>  <th scope="col">Signed Value</th></tr>
<tr align="right"><td>000</td> <td>0</td> <td>0</td> </tr>
<tr align="right"><td>001</td> <td>1</td> <td>1</td> </tr>
<tr align="right"><td>010</td> <td>2</td> <td>2</td> </tr>
<tr align="right"><td>011</td> <td>3</td> <td>3</td> </tr>
<tr align="right"><td>100</td> <td>4</td> <td>-4</td> </tr>
<tr align="right"><td>101</td> <td>5</td> <td>-3</td> </tr>
<tr align="right"><td>110</td> <td>6</td> <td>-2</td> </tr>
<tr align="right"><td>111</td> <td>7</td> <td>-1</td> </tr>
</table>

$(P
We can construct the following table by adding more bits:
)

<table class="wide" style="font-size:.9em" border="1" cellpadding="4" cellspacing="0">
<tr align="right"><th scope="col">Bits</th> <th scope="col">Number of Distinct Values</th><th scope="col">D Type</th><th scope="col">Minimum Value</th><th scope="col">Maximum Value</th>  </tr>
<tr align="right"><td>1</td><td>2</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>2</td><td>4</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>3</td><td>8</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>4</td><td>16</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>5</td><td>32</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>6</td><td>64</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>7</td><td>128</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>8</td><td>256</td> <td>byte$(BR)ubyte</td><td>-128$(BR)0</td><td>127$(BR)255</td></tr>
<tr align="right"><td>...</td><td>...</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>16</td><td>65536</td> <td>short$(BR)ushort</td><td>-32768$(BR)0</td><td>32767$(BR)65535</td></tr>
<tr align="right"><td>...</td><td>...</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>32</td><td>4294967296</td> <td>int$(BR)uint</td><td>-2147483648$(BR)0</td><td>2147483647$(BR)4294967295</td></tr>
<tr align="right"><td>...</td><td>...</td> <td></td><td></td><td></td></tr>
<tr align="right"><td>64</td><td>18446744073709551616</td> <td>long$(BR)ulong</td><td>-9223372036854775808$(BR)0</td><td>9223372036854775807$(BR)18446744073709551615</td></tr>
<tr align="right"><td>...</td><td>...</td> <td></td><td></td><td></td></tr>
</table>

$(P
I skipped many rows in the table and indicated the signed and unsigned versions of the D types that have the same number of bits on the same row (e.g. $(C int) and $(C uint) are both on the 32-bit row).
)

$(H6 Choosing a type)

$(P
D has no 3-bit type. But such a hypothetical type could only have 8 distinct values. It could only represent concepts such as the value of a die, or the week's day number.
)

$(P
On the other hand, although $(C uint) is a very large type, it cannot represent the concept of an ID number for each living person, as its maximum value is less than the world population of 7 billion. $(C long) and $(C ulong) would be more than enough to represent many concepts.
)

$(P
As a general rule, as long as there is no specific reason not to, you can use $(C int) for integer values.
)

$(H6 $(IX overflow) Overflow)

$(P
The fact that types can only hold values within a limited range may cause unexpected results. For example, although adding two $(C uint) variables with values of 3 billion each should produce 6 billion, because that sum is greater than the maximum value that a $(C uint) variable can hold (about 4 billion), this sum $(I overflows). Without any warning, only the difference of 6 and 4 billion gets stored. (A little more accurately, 6 minus 4.3 billion.)
)

$(H6 $(IX truncation) Truncation)

$(P
Since integers cannot have values with fractional parts, they lose the part after the decimal point. For example, assuming that a box of ice cream serves 4 kids, although 11 kids would actually need 2.75 boxes, the fractional part of that value cannot be stored in an integer type, so the value becomes 2.
)

$(P
I will show limited techniques to help reduce the risk of overflow and truncation later in the chapter.
)

$(H6 $(C .min) and $(C .max))

$(P
I will take advantage of the $(C .min) and $(C .max) properties below, which we have seen in the $(LINK2 types.html, Fundamental Types chapter). These properties provide the minimum and maximum values that an integer type can have.
)

$(H6 $(IX ++, pre-increment) $(IX increment) Increment: $(C ++))

$(P
This operator is used with a single variable (more generally, with a single expression) and is written before the name of that variable. It increments the value of that variable by 1:
)

---
import std.stdio;

void main() {
    int number = 10;
    $(HILITE ++)number;
    writeln("New value: ", number);
}
---

$(SHELL
New value: 11
)

$(P
The increment operator is the equivalent of using the $(I add-and-assign) operator with the value of 1:
)

---
    number += 1;      // same as ++number
---

$(P
If the result of the increment operation is greater than the maximum value of that type, the result $(I overflows) and becomes the minimum value. We can see this effect by incrementing a variable that initially has the value $(C int.max):
)

---
import std.stdio;

void main() {
    writeln("minimum int value   : ", int.min);
    writeln("maximum int value   : ", int.max);

    int number = int.max;
    writeln("before the increment: ", number);
    ++number;
    writeln("after the increment : ", number);
}
---

$(P
The value becomes $(C int.min) after the increment:
)

$(SHELL
minimum int value   : -2147483648
maximum int value   : 2147483647
before the increment: 2147483647
after the increment : -2147483648
)

$(P
This is a very important observation because the value changes from the maximum to the minimum as a result of $(I incrementing) and without any warning! This effect is called $(I overflow). We will see similar effects with other operations.
)

$(H6 $(IX --, pre-decrement) $(IX decrement) Decrement: $(C --))

$(P
This operator is similar to the increment operator; the difference is that the value is decreased by 1:
)

---
    --number;   // the value decreases by 1
---

$(P
The decrement operation is the equivalent of using the $(I subtract-and-assign) operator with the value of 1:
)

---
    number -= 1;      // same as --number
---


$(P
Similar to the $(C ++) operator, if the value is the minimum value to begin with, it becomes the maximum value. This effect is called $(I overflow) as well.
)

$(H6 $(IX +, addition) $(IX addition) Addition: +)

$(P
This operator is used with two expressions and adds their values:
)

---
import std.stdio;

void main() {
    int number_1 = 12;
    int number_2 = 100;

    writeln("Result: ", number_1 $(HILITE +) number_2);
    writeln("With a constant expression: ", 1000 $(HILITE +) number_2);
}
---

$(SHELL
Result: 112
With a constant expression: 1100
)

$(P
If the sum of the two expressions is greater than the maximum value of that type, it overflows and becomes a value that is less than both of the expressions:
)

---
import std.stdio;

void main() {
    // 3 billion each
    uint number_1 = 3000000000;
    uint number_2 = 3000000000;

    writeln("maximum value of uint: ", uint.max);
    writeln("             number_1: ", number_1);
    writeln("             number_2: ", number_2);
    writeln("                  sum: ", number_1 + number_2);
    writeln("OVERFLOW! The result is not 6 billion!");
}
---

$(SHELL
maximum value of uint: 4294967295
             number_1: 3000000000
             number_2: 3000000000
                  sum: 1705032704
OVERFLOW! The result is not 6 billion!
)

$(H6 $(IX -, subtraction) $(IX subtraction) Subtraction: $(C -))

$(P
This operator is used with two expressions and gives the difference between the first and the second:
)

---
import std.stdio;

void main() {
    int number_1 = 10;
    int number_2 = 20;

    writeln(number_1 $(HILITE -) number_2);
    writeln(number_2 $(HILITE -) number_1);
}
---

$(SHELL
-10
10
)

$(P
It is again surprising if the actual result is less than zero and is stored in an unsigned type. Let's rewrite the program using the $(C uint) type:
)

---
import std.stdio;

void main() {
    uint number_1 = 10;
    uint number_2 = 20;

    writeln("PROBLEM! uint cannot have negative values:");
    writeln(number_1 - number_2);
    writeln(number_2 - number_1);
}
---

$(SHELL
PROBLEM! uint cannot have negative values:
4294967286
10
)

$(P
It is a good guideline to use signed types to represent concepts that may ever be subtracted. As long as there is no specific reason not to, you can choose $(C int).
)

$(H6 $(IX *, multiplication) $(IX multiplication) Multiplication: $(C *))

$(P
This operator multiplies the values of two expressions; the result is again subject to overflow:
)

---
import std.stdio;

void main() {
    uint number_1 = 6;
    uint number_2 = 7;

    writeln(number_1 $(HILITE *) number_2);
}
---

$(SHELL
42
)

$(H6 $(IX /) $(IX division) Division: $(C /))

$(P
This operator divides the first expression by the second expression. Since integer types cannot have fractional values, the fractional part of the value is discarded. This effect is called $(I truncation). As a result, the following program prints 3, not 3.5:
)

---
import std.stdio;

void main() {
    writeln(7 $(HILITE /) 2);
}
---

$(SHELL
3
)

$(P
For calculations where fractional parts matter, $(I floating point types) must be used instead of integers. We will see floating point types in the next chapter.
)

$(H6 $(IX %) $(IX remainder) $(IX modulus) Remainder (modulus): %)

$(P
This operator divides the first expression by the second expression and produces the remainder of the division:
)

---
import std.stdio;

void main() {
    writeln(10 $(HILITE %) 6);
}
---

$(SHELL
4
)

$(P
A common application of this operator is to determine whether a value is odd or even. Since the remainder of dividing an even number by 2 is always 0, comparing the result against 0 is sufficient to make that distinction:
)

---
    if ((number % 2) == 0) {
        writeln("even number");

    } else {
        writeln("odd number");
    }
---

$(H6 $(IX ^^) $(IX power of) Power: ^^)

$(P
This operator raises the first expression to the power of the second expression. For example, raising 3 to the power of 4 is multiplying 3 by itself 4 times:
)

---
import std.stdio;

void main() {
    writeln(3 $(HILITE ^^) 4);
}
---

$(SHELL
81
)

$(H6 $(IX assignment, operation result) Arithmetic operations with assignment)

$(P
All of the operators that take two expressions have $(I assignment) counterparts. These operators assign the result back to the expression that is on the left-hand side:
)

---
import std.stdio;

void main() {
    int number = 10;

    number += 20;  // same as number = number + 20; now 30
    number -= 5;   // same as number = number - 5;  now 25
    number *= 2;   // same as number = number * 2;  now 50
    number /= 3;   // same as number = number / 3;  now 16
    number %= 7;   // same as number = number % 7;  now  2
    number ^^= 6;  // same as number = number ^^ 6; now 64

    writeln(number);
}
---

$(SHELL
64
)

$(H6 $(IX -, negation) $(IX negation) Negation: $(C -))

$(P
This operator converts the value of the expression from negative to positive or positive to negative:
)

---
import std.stdio;

void main() {
    int number_1 = 1;
    int number_2 = -2;

    writeln($(HILITE -)number_1);
    writeln($(HILITE -)number_2);
}
---

$(SHELL
-1
2
)

$(P
The type of the result of this operation is the same as the type of the expression. Since unsigned types cannot have negative values, the result of using this operator with unsigned types can be surprising:
)

---
    $(HILITE uint) number = 1;
    writeln("negation: ", -number);
---

$(P
The type of $(C -number) is $(C uint) as well, which cannot have negative values:
)

$(SHELL
negation: 4294967295
)

$(H6 $(IX +, plus sign) $(IX plus sign) Plus sign: $(C +))

$(P
This operator has no effect and exists only for symmetry with the negation operator. Positive values stay positive and negative values stay negative:
)

---
import std.stdio;

void main() {
    int number_1 = 1;
    int number_2 = -2;

    writeln($(HILITE +)number_1);
    writeln($(HILITE +)number_2);
}
---

$(SHELL
1
-2
)

$(H6 $(IX ++, post-increment) $(IX post-increment) $(IX increment, post) Post-increment: $(C ++))

$(P
$(I $(B Note:) Unless there is a strong reason not to, always use the regular increment operator (which is sometimes called the pre-increment operator).)
)

$(P
Contrary to the regular increment operator, it is written after the expression and still increments the value of the expression by 1. The difference is that the post-increment operation produces the old value of the expression. To see this difference, let's compare it with the regular increment operator:
)

---
import std.stdio;

void main() {
    int incremented_regularly = 1;
    writeln(++incremented_regularly);      // prints 2
    writeln(incremented_regularly);        // prints 2

    int post_incremented = 1;

    // Gets incremented, but its old value is used:
    writeln(post_incremented$(HILITE ++));           // prints 1
    writeln(post_incremented);             // prints 2
}
---

$(SHELL
2
2
1
2
)

$(P
The $(C writeln(post_incremented++);) statement above is the equivalent of the following code:
)

---
    int old_value = post_incremented;
    ++post_incremented;
    writeln(old_value);                    // prints 1
---

$(H6 $(IX --, post-decrement) $(IX post-decrement) $(IX decrement, post) Post-decrement: $(C --))

$(P
$(I $(B Note:) Unless there is a strong reason not to, always use the regular decrement operator (which is sometimes called the pre-decrement operator).)
)

$(P
This operator behaves the same way as the post-increment operator except that it decrements.
)

$(H6 Operator precedence)

$(P
The operators we've discussed above have all been used in operations on their own with only one or two expressions. However, similar to logical expressions, it is common to combine these operators to form more complex arithmetic expressions:
)

---
    int value = 77;
    int result = (((value + 8) * 3) / (value - 1)) % 5;
---

$(P
As with logical operators, arithmetic operators also obey operator precedence rules. For example, the $(C *) operator has precedence over the $(C +) operator. For that reason, when parentheses are not used (e.g. in the $(C value&nbsp;+&nbsp;8&nbsp;*&nbsp;3) expression), the $(C *) operator is evaluated before the $(C +) operator. As a result, that expression becomes the equivalent of $(C value&nbsp;+&nbsp;24), which is quite different from $(C (value&nbsp;+&nbsp;8)&nbsp;*&nbsp;3).
)

$(P
Using parentheses is useful both for ensuring correct results and for communicating the intent of the code to programmers who may work on it in the future.
)

$(P
The operator precedence table will be presented $(LINK2 operator_precedence.html, later in the book).
)

$(H6 Detecting overflow)

$(P
$(IX core.checkedint) $(IX checkedint) $(IX adds) $(IX addu) $(IX subs) $(IX subu) $(IX muls) $(IX mulu) $(IX negs) Although it uses $(LINK2 functions.html, functions) and $(LINK2 function_parameters.html, $(C ref) parameters), which we have not covered yet, I would like to mention here that $(LINK2 http://dlang.org/phobos/core_checkedint.html, the $(C core.checkedint) module) contains arithmetic functions that detect overflow. Instead of operators like $(C +) and $(C -), this module uses functions: $(C adds) and $(C addu) for signed and unsigned addition, $(C muls) and $(C mulu) for signed and unsigned multiplication, $(C subs) and $(C subu) for signed and unsigned subtraction, and $(C negs) for negation.
)

$(P
For example, assuming that $(C a) and $(C b) are two $(C int) variables, the following code would detect whether adding them has caused an overflow:
)

---
import core.checkedint;

void main() {
    // Let's cause overflow for test purposes
    int a = int.max - 1;
    int b = 2;

    // This variable will become 'true' if the addition
    // operation inside the 'adds' function overflows:
    bool hasOverflowed = false;
    int result = adds(a, b, $(HILITE hasOverflowed));

    if (hasOverflowed) {
        // We must not use 'result' because it has overflowed
        // ...

    } else {
        // We can use 'result'
        // ...
    }
}
---

$(P
$(IX experimental.checkedint) $(IX Checked) There is also $(LINK2 https://dlang.org/phobos/std_experimental_checkedint.html, the std.experimental.checkedint) module that defines the $(C Checked) template but both its usage and its implementation are too advanced at this point in the book.
)

$(H6 Preventing overflow)

$(P
If the result of an operation cannot fit in the type of the result, then there is nothing that can be done. Sometimes, although the ultimate result would fit in a certain type, the intermediate calculations may overflow and cause incorrect results.
)

$(P
As an example, let's assume that we need to plant an apple tree per 1000 square meters of an area that is 40 by 60 kilometers. How many trees are needed?
)

$(P
When we solve this problem on paper, we see that the result is 40000 times 60000 divided by 1000, being equal to 2.4 million trees. Let's write a program that executes this calculation:
)

---
import std.stdio;

void main() {
    int width  = 40000;
    int length = 60000;
    int areaPerTree = 1000;

    int treesNeeded = width * length / areaPerTree;

    writeln("Number of trees needed: ", treesNeeded);
}
---

$(SHELL
Number of trees needed: -1894967
)

$(P
Not to mention it is not even close, the result is also less than zero! In this case, the intermediate calculation $(C width&nbsp;*&nbsp;length) overflows and the subsequent calculation of $(C /&nbsp;areaPerTree) produces an incorrect result.
)

$(P
One way of avoiding the overflow in this example is to change the order of operations:
)

---
    int treesNeeded = width / areaPerTree * length ;
---

$(P
The result would now be correct:
)

$(SHELL
Number of trees needed: 2400000
)

$(P
The reason this method works is the fact that all of the steps of the calculation now fit the $(C int) type.
)

$(P
Please note that this is not a complete solution because this time the intermediate value is prone to truncation, which may affect the result significantly in certain other calculations. Another solution might be to use a floating point type instead of an integer type: $(C float), $(C double), or $(C real).
)

$(H6 Preventing truncation)

$(P
Changing the order of operations may be a solution to truncation as well. An interesting example of truncation can be seen by dividing and multiplying a value with the same number. We would expect the result of 10/9*9 to be 10, but it comes out as 9:
)

---
import std.stdio;

void main() {
    writeln(10 / 9 * 9);
}
---

$(SHELL
9
)

$(P
The result is correct when truncation is avoided by changing the order of operations:
)

---
    writeln(10 * 9 / 9);
---

$(SHELL
10
)

$(P
This too is not a complete solution: This time the intermediate calculation could be prone to overflow. Using a floating point type may be another solution to truncation in certain calculations.
)

$(PROBLEM_COK

$(PROBLEM
Write a program that takes two integers from the user, prints the integer quotient resulting from the division of the first by the second, and also prints the remainder. For example, when 7 and 3 are entered, have the program print the following equation:

$(SHELL
7 = 3 * 2 + 1
)

)

$(PROBLEM
Modify the program to print a shorter output when the remainder is 0. For example, when 10 and 5 are entered, it should not print "10 = 5 * 2 + 0" but just the following:

$(SHELL
10 = 5 * 2
)

)

$(PROBLEM
Write a simple calculator that supports the four basic arithmetic operations. Have the program let the operation to be selected from a menu and apply that operation to the two values that are entered. You can ignore overflow and truncation in this program.
)

$(PROBLEM
Write a program that prints the values from 1 to 10, each on a separate line, with the exception of value 7. Do not use repeated lines as in the following code:

---
import std.stdio;

void main() {
    // Do not do this!
    writeln(1);
    writeln(2);
    writeln(3);
    writeln(4);
    writeln(5);
    writeln(6);
    writeln(8);
    writeln(9);
    writeln(10);
}
---

$(P
Instead, imagine a variable whose value is incremented in a loop. You may need to take advantage of the $(I is not equal to) operator $(C !=) here.
)

)

)

Macros:
        TITLE=Integers and Arithmetic Operations

        DESCRIPTION=The integer arithmetic operations of the D language

        KEYWORDS=d programming language tutorial book integer arithmetic operations

MINI_SOZLUK=
$(Ergin)
