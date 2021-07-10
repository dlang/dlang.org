Ddoc

$(DERS_BOLUMU $(IX floating point) Floating Point Types)

$(P
In the previous chapter, we have seen that despite their ease of use, arithmetic operations on integers are prone to programming errors due to overflow and truncation. We have also seen that integers cannot have values with fractional parts, as in 1.25.
)

$(P
Floating point types are designed to support fractional parts. The "point" in their name comes from the $(I radix point), which separates the integer part from the fractional part, and "floating" refers to a detail in how these types are implemented: the decimal point $(I floats) left and right as appropriate. (This detail is not important when using these types.)
)

$(P
We must cover important details in this chapter as well. Before doing that, I would like to give a list of some of the interesting aspects of floating point types:
)

$(UL

$(LI Adding 0.001 a thousand times is not the same as adding 1.)

$(LI Using the logical operators $(C ==) and $(C !=) with floating point types is erroneous in most cases.)

$(LI The initial value of floating point types is $(C .nan), not 0. $(C .nan) may not be used in expressions in any meaningful way. When used in comparison operations, $(C .nan) is not less than nor greater than any value.)

$(LI The two overflow values are $(C .infinity) and negative $(C .infinity).)
)

$(P
Although floating point types are more useful in some cases, they have peculiarities that every programmer must know. Compared to integers, they are very good at avoiding truncation because their main purpose is to support fractional values. Like any other type, being based on a certain number of bits, they too are prone to overflow, but compared to integers, the range of values that they can support is vast. Additionally, instead of being silent in the case of overflow, they get the special values of positive and negative $(I infinity).
)

$(P
$(IX float)
$(IX double)
$(IX real)
As a reminder, the floating point types are the following:
)

<table class="wide" border="1" cellpadding="4" cellspacing="0">
<tr align="center"><th scope="col">Type</th> <th scope="col">Number of Bits</th> <th scope="col">Initial Value</th></tr>
<tr align="center"><td>float</td>
	<td>32</td>
	<td>float.nan</td>
</tr>
<tr align="center"><td>double</td>

	<td>64</td>
	<td>double.nan</td>
</tr>
<tr align="center"><td>real</td>
	<td>at least 64, maybe more$(BR)(e.g. 80, depending on hardware support)</td>

	<td>real.nan</td>
</tr>
</table>

$(H5 Floating point type properties)

$(P
Floating point types have more properties than other types:
)

$(UL

$(LI $(C .stringof) is the name of the type.)

$(LI $(C .sizeof) is the length of the type in terms of bytes. (In order to determine the bit count, this value must be multiplied by 8, the number of bits in a byte.))

$(LI $(IX .min, floating point) $(C .max) is the short for "maximum" and is the maximum value that the type can have. There is no separate $(C .min) property for floating types; the negative of $(C .max) is the minimum value that the type can have. For example, the minimum value of $(C double) is $(C -double.max).)

$(LI $(IX .min_normal) $(IX underflow) $(C .min_normal) is the smallest positive value that this type can represent with its normal precision. (Precision is explained below.) The type can represent smaller values than $(C .min_normal) but those values cannot be as precise as other values of the type and are generally slower to compute.  The condition of a floating point value being between negative $(C .min_normal) and positive $(C .min_normal) (excluding 0) is called $(I underflow).)

$(LI $(IX .dig) $(C .dig) is short for "digits" and specifies the number of digits that signify the precision of the type.)

$(LI $(IX .infinity) $(IX overflow, floating point) $(C .infinity) is the special value used to denote overflow.)

)

$(P
Other properties of floating point types are used less commonly. You can see all of them at $(LINK2 http://dlang.org/property.html, Properties for Floating Point Types at dlang.org).
)

$(P
The properties of floating point types and their relations can be shown on a number line like the following:
)

$(MONO
   +     +─────────+─────────+   ...   +   ...   +─────────+─────────+     +
   │   -max       -1         │         0         │         1        max    │
   │                         │                   │                         │
-infinity               -min_normal          min_normal               infinity
)

$(P
Other than the two special infinity values, the line above is to scale: the number of values that can be represented between $(C min_normal) and 1 is equal to the number of values that can be represented between 1 and $(C max). This means that the precision of the fractional parts of the values that are between $(C min_normal) and 1 is very high. (The same is true for the negative side as well.)
)

$(H5 $(IX .nan) $(C .nan))

$(P
We have already seen that this is the default value of floating point variables. $(C .nan) may appear as a result of meaningless floating point expressions as well. For example, the floating point expressions in the following program all produce $(C double.nan):
)

---
import std.stdio;

void main() {
    double zero = 0;
    double infinity = double.infinity;

    writeln("any expression with nan: ", double.nan + 1);
    writeln("zero / zero            : ", zero / zero);
    writeln("zero * infinity        : ", zero * infinity);
    writeln("infinity / infinity    : ", infinity / infinity);
    writeln("infinity - infinity    : ", infinity - infinity);
}
---

$(P
$(C .nan) is not useful just because it indicates an uninitialized value. It is also useful because it is propagated through computations, making it easier and earlier to detect errors.
)

$(H5 Specifying floating point values)

$(P
Floating point values can be built from integer values without a decimal point, like 123, or created directly with a decimal point, like 123.0.
)

$(P
Floating point values can also be specified with the special floating point syntax, as in $(C 1.23e+4). The $(C e+) part in that syntax can be read as "times 10 to the power of". According to that reading, the previous value is "1.23 times 10 to the power of 4", which is the same as "1.23 times 10$(SUP 4)", which in turn is the same as 1.23x10000, being equal to 12300.
)

$(P
If the value after $(C e) is negative, as in $(C 5.67e-3), then it is read as "divided by 10 to the power of". Accordingly, this example is "5.67 divided by 10$(SUP 3)", which in turn is the same as 5.67/1000, being equal to 0.00567.
)

$(P
The floating point format is apparent in the output of the following program that prints the properties of the three floating point types:
)

---
import std.stdio;

void main() {
    writeln("Type                    : ", float.stringof);
    writeln("Precision               : ", float.dig);
    writeln("Minimum normalized value: ", float.min_normal);
    writeln("Minimum value           : ", -float.max);
    writeln("Maximum value           : ", float.max);
    writeln();

    writeln("Type                    : ", double.stringof);
    writeln("Precision               : ", double.dig);
    writeln("Minimum normalized value: ", double.min_normal);
    writeln("Minimum value           : ", -double.max);
    writeln("Maximum value           : ", double.max);
    writeln();

    writeln("Type                    : ", real.stringof);
    writeln("Precision               : ", real.dig);
    writeln("Minimum normalized value: ", real.min_normal);
    writeln("Minimum value           : ", -real.max);
    writeln("Maximum value           : ", real.max);
}
---

$(P
The output of the program is the following in my environment. Since $(C real) depends on the hardware, you may get a different output:
)

$(SHELL
Type                    : float
Precision               : 6
Minimum normalized value: 1.17549e-38
Minimum value           : -3.40282e+38
Maximum value           : 3.40282e+38

Type                    : double
Precision               : 15
Minimum normalized value: 2.22507e-308
Minimum value           : -1.79769e+308
Maximum value           : 1.79769e+308

Type                    : real
Precision               : 18
Minimum normalized value: 3.3621e-4932
Minimum value           : -1.18973e+4932
Maximum value           : 1.18973e+4932
)

$(P
$(I $(B Note:) Although $(C double) and $(C real) have more precision than $(C float), $(C writeln) prints all floating point values with 6 digits of precision. (Precision is explained below.))
)

$(H6 Observations)

$(P
As you will remember from the previous chapter, the maximum value of $(C ulong) has 20 digits: 18,446,744,073,709,551,616. That value looks small when compared to even the smallest floating point type: $(C float) can have values up to the 10$(SUP 38) range, e.g. 340,282,000,000,000,000,000,000,000,000,000,000,000. The maximum value of $(C real) is in the range 10$(SUP 4932), a value with more than 4900 digits!
)

$(P
As another observation, let's look at the minimum value that $(C double) can represent with 15-digit precision:
)

$(MONO
    0.000...$(I (there&nbsp;are&nbsp;300&nbsp;more&nbsp;zeroes&nbsp;here))...0000222507385850720
)

$(H5 Overflow is not ignored)

$(P
Despite being able to take very large values, floating point types are prone to overflow as well. The floating point types are safer than integer types in this regard because overflow is not ignored. The values that overflow on the positive side become $(C .infinity), and the values that overflow on the negative side become $(C &#8209;.infinity). To see this, let's increase the value of $(C .max) by 10%. Since the value is already at the maximum, increasing by 10% would overflow:
)

---
import std.stdio;

void main() {
    real value = real.max;

    writeln("Before         : ", value);

    // Multiplying by 1.1 is the same as adding 10%
    value *= 1.1;
    writeln("Added 10%      : ", value);

    // Let's try to reduce its value by dividing in half
    value /= 2;
    writeln("Divided in half: ", value);
}
---

$(P
Once the value overflows and becomes $(C real.infinity), it remains that way even after being divided in half:
)

$(SHELL
Before         : 1.18973e+4932
Added 10%      : inf
Divided in half: inf
)

$(H5 $(IX precision) Precision)

$(P
Precision is a concept that we come across in daily life but do not talk about much. Precision is the number of digits that is used when specifying a value. For example, when we say that the third of 100 is 33, the precision is 2 because 33 has 2 digits. When the value is specified more precisely as 33.33, then the precision is 4 digits.
)

$(P
The number of bits that each floating type has, not only affects its maximum value, but also its precision. The greater the number of bits, the more precise the values are.
)

$(H5 There is no truncation in division)

$(P
As we have seen in the previous chapter, integer division cannot preserve the fractional part of a result:
)

---
    int first = 3;
    int second = 2;
    writeln(first / second);
---

$(P
Output:
)

$(SHELL
1
)

$(P
Floating point types don't have this $(I truncation) problem; they are specifically designed for preserving the fractional parts:
)

---
    double first = 3;
    double second = 2;
    writeln(first / second);
---

$(P
Output:
)

$(SHELL
1.5
)

$(P
The accuracy of the fractional part depends on the precision of the type: $(C real) has the highest precision and $(C float) has the lowest precision.
)

$(H5 Which type to use)

$(P
Unless there is a specific reason not to, you can choose $(C double) for floating point values. $(C float) has low precision but due to being smaller than the other types it may be useful when memory is limited. On the other hand, since the precision of $(C real) is higher than $(C double) on some hardware, it would be preferable for high precision calculations.
)

$(H5 Cannot represent all values)

$(P
We cannot represent certain values in our daily lives. In the decimal system that we use daily, the digits before the decimal point represent ones, tens, hundreds, etc. and the digits after the decimal point represent tenths, hundredths, thousandths, etc.
)

$(P
If a value is created from a combination of these values, it can be represented exactly. For example, because the value 0.23 consists of 2 tenths and 3 hundredths it is represented exactly. On the other hand, the value 1/3 cannot be exactly represented in the decimal system because the number of digits is always insufficient, no matter how many are specified: 0.33333...
)

$(P
The situation is very similar with the floating point types. Because these types are based on a certain number of bits, they cannot represent every value exactly.
)

$(P
The difference with the binary system that the computers use is that the digits before the decimal point are ones, twos, fours, etc. and the digits after the decimal point are halves, quarters, eighths, etc. Only the values that are exact combinations of those digits can be represented exactly.
)

$(P
A value that cannot be represented exactly in the binary system used by computers is 0.1, as in 10 cents. Although this value can be represented exactly in the decimal system, its binary representation never ends and continuously repeats four digits: 0.0001100110011... (Note that the value is written in binary system, not decimal.) It is always inaccurate at some level depending on the precision of the floating point type that is used.
)

$(P
The following program demonstrates this problem. The value of a variable is being incremented by 0.001 a thousand times in a loop. Surprisingly, the result is not 1:
)

---
import std.stdio;

void main() {
    float result = 0;

    // Adding 0.001 for a thousand times:
    int counter = 1;
    while (counter <= 1000) {
        result += 0.001;
        ++counter;
    }

    if (result == 1) {
        writeln("As expected: 1");

    } else {
        writeln("DIFFERENT: ", result);
    }
}
---

$(P
Because 0.001 cannot be represented exactly, that inaccuracy affects the result at every iteration:
)

$(SHELL
DIFFERENT: 0.999991
)

$(P
$(I $(B Note:) The variable $(C counter) above is a loop counter. Defining a variable explicitly for that purpose is not recommended. Instead, a common approach is to use a $(C foreach) loop, which we will see in $(LINK2 foreach.html, a later chapter).)
)

$(H5 $(IX unordered)  Unorderedness)

$(P
The same comparison operators that we have covered with integers are used with floating point types as well. However, since the special value $(C .nan) represents invalid floating point values, comparing $(C .nan) to other values is not meaningful. For example, it does not make sense to ask whether $(C .nan) or $(C 1) is greater.
)

$(P
For that reason, floating point values introduce another comparison concept: unorderedness. Being unordered means that at least one of the values is $(C .nan).
)

$(P
The following table lists all the floating point comparison operators. All of them are binary operators (meaning that they take two operands) and used as in $(C left&nbsp;==&nbsp;right). The columns that contain $(C false) and $(C true) are the results of the comparison operations.
)

$(P
The last column indicates whether the operation is meaningful if one of the operands is $(C .nan). For example, even though the result of the expression $(C 1.2 < real.nan) is $(C false), that result is meaningless because one of the operands is $(C real.nan). The result of the reverse comparison $(C real.nan < 1.2) would produce $(C false) as well. The abreviation lhs stands for $(I left-hand side), indicating the expression on the left-hand side of each operator.
)

<table class="full" border="1" cellpadding="4" cellspacing="0">
<tr align="center">	<th scope="col">$(BR)Operator</th>
<th scope="col">$(BR)Meaning</th>
<th scope="col">If lhs$(BR)is greater</th>
<th scope="col">If lhs$(BR)is less</th>
<th scope="col">If both$(BR)are equal</th>

<th scope="col">If at least$(BR)one is .nan</th>
<th scope="col">Meaningful$(BR)with .nan</th>
</tr>
<tr align="center">	<td>==</td><td>is equal to</td>	<td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_YES yes)</td>

</tr>
<tr align="center">	<td>!=</td><td>is not equal to</td>	<td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_YES yes)</td>
</tr>
<tr align="center">	<td>&gt;</td><td>is greater than</td>	<td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_NO no)</td>

</tr>
<tr align="center">	<td>&gt;=</td><td>is greater than or equal to</td>	<td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_NO no)</td>
</tr>
<tr align="center">	<td>&lt;</td><td>is less than</td>	<td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_NO no)</td>

</tr>
<tr align="center">	<td>&lt;=</td><td>is less than or equal to</td>	<td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_TRUE true)</td><td>$(UNORDERED_FALSE false)</td><td>$(UNORDERED_NO no)</td>
</tr>
</table>

$(P
Although meaningful to use with $(C .nan), the $(C ==) operator always produces $(C false) when used with a $(C .nan) value. This is the case even when both values are $(C .nan):
)

---
import std.stdio;

void main() {
    if (double.nan == double.nan) {
        writeln("equal");

    } else {
        writeln("not equal");
    }
}
---

$(P
Although one would expect $(C double.nan) to be equal to itself, the result of the comparison is $(C false):
)

$(SHELL
not equal
)

$(H6 $(IX isNan, std.math) $(C isNaN()) for $(C .nan) equality comparison)

$(P
As we have seen above, it is not possible to use the $(C ==) operator to determine whether the value of a floating point variable is $(C .nan):
)

---
    if (variable == double.nan) {    $(CODE_NOTE_WRONG WRONG)
        // ...
    }
---

$(P
$(C isNaN()) function from the $(C std.math) module is for determining whether a value is $(C .nan):
)

---
import std.math;
// ...
    if (isNaN(variable)) {           $(CODE_NOTE correct)
        // ...
    }
---

$(P
Similarly, to determine whether a value is $(I not) $(C .nan), one must use $(C !isNaN()) because otherwise the $(C !=) operator would always produce $(C true).
)

$(PROBLEM_COK

$(PROBLEM
Instead of $(C float), use $(C double) (or $(C real)) in the program above which added 0.001 a thousand times:

---
    $(HILITE double) result = 0;
---

$(P
This exercise demonstrates how misleading floating point equality comparisons can be.
)

)

$(PROBLEM
Modify the calculator from the previous chapter to support floating point types. The new calculator should work more accurately with that change. When trying the calculator, you can enter floating point values in various formats, as in 1000, 1.23, and 1.23e4.
)

$(PROBLEM
Write a program that reads 5 floating point values from the input. Make the program first print twice of each value and then one fifth of each value.

$(P
This exercise is a preparation for the array concept of the next chapter. If you write this program with what you have seen so far, you will understand arrays more easily and will better appreciate them.
)

)

)

Macros:
        TITLE=Floating Point Types

        DESCRIPTION=The floating point types of the D programming language.

        KEYWORDS=d programming language tutorial book floating point float double real numeric limits
