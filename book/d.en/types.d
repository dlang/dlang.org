Ddoc

$(DERS_BOLUMU $(IX type) $(IX fundamental type) Fundamental Types)

$(P
We have seen that the brain of a computer is the CPU. Most of the tasks of a program are performed by the CPU and the rest are dispatched to other parts of the computer.
)

$(P
The smallest unit of data in a computer is called $(I a bit). The value of a bit can be either 0 or 1.
)

$(P
Since a type of data that can hold only the values 0 and 1 would have very limited use, the CPU supports larger data types that are combinations of more than one bit. As an example, a $(I byte) usually consists of 8 bits. If an N-bit data type is the most efficient data type supported by a CPU, we consider it to be an $(I N-bit CPU): as in 32-bit CPU, 64-bit CPU, etc.
)

$(P
The data types that the CPU supports are still not sufficient: they can't represent higher level concepts like $(I name of a student) or $(I a playing card). Likewise, D's fundamental data types are not sufficient to represent many higher level concepts. Such concepts must be defined by the programmer as $(I structs) and $(I classes), which we will see in later chapters.
)

$(P
$(IX bool)
$(IX byte)
$(IX ubyte)
$(IX short)
$(IX ushort)
$(IX int)
$(IX uint)
$(IX long)
$(IX ulong)
$(IX float)
$(IX double)
$(IX real)
$(IX ifloat)
$(IX idouble)
$(IX ireal)
$(IX cfloat)
$(IX cdouble)
$(IX creal)
$(IX char)
$(IX wchar)
$(IX dchar)
D's $(I fundamental types) are very similar to the fundamental types of many other languages, as seen in the following table. The terms that appear in the table are explained below:
)

<table class="full" border="1" cellpadding="4" cellspacing="0"><caption>D's Fundamental Data Types</caption>
	<tr><th scope="col">Type</th> <th scope="col">Definition</th> <th scope="col">Initial Value</th>

	</tr>
	<tr>		<td>bool</td>

		<td>Boolean type</td>
		<td>false</td>
	</tr>
	<tr>		<td>byte</td>
		<td>signed 8 bits</td>
		<td>0</td>

	</tr>
	<tr>		<td>ubyte</td>
		<td>unsigned 8 bits</td>
		<td>0</td>
	</tr>
	<tr>		<td>short</td>

		<td>signed 16 bits</td>
		<td>0</td>
	</tr>
	<tr>		<td>ushort</td>
		<td>unsigned 16 bits</td>
		<td>0</td>

	</tr>
	<tr>		<td>int</td>
		<td>signed 32 bits</td>
		<td>0</td>
	</tr>
	<tr>		<td>uint</td>

		<td>unsigned 32 bits</td>
		<td>0</td>
	</tr>
	<tr>		<td>long</td>
		<td>signed 64 bits</td>
		<td>0L</td>

	</tr>
	<tr>		<td>ulong</td>
		<td>unsigned 64 bits</td>
		<td>0LU</td>
	</tr>
	<tr>		<td>float</td>
		<td>32-bit floating point</td>
		<td>float.nan</td>
	</tr>
	<tr>		<td>double</td>

		<td>64-bit floating point</td>
		<td>double.nan</td>
	</tr>
	<tr>		<td>real</td>
		<td>either the largest floating point type that the hardware supports, or double; whichever is larger</td>

		<td>real.nan</td>
	</tr>
	<tr>		<td>ifloat</td>
		<td>imaginary value type of float</td>
		<td>float.nan * 1.0i</td>
	</tr>

	<tr>		<td>idouble</td>
		<td>imaginary value type of double</td>
		<td>double.nan * 1.0i</td>
	</tr>
	<tr>		<td>ireal</td>
		<td>imaginary value type of real</td>

		<td>real.nan * 1.0i</td>
	</tr>
	<tr>		<td>cfloat</td>
		<td>complex number type made of two floats</td>
		<td>float.nan + float.nan * 1.0i</td>
	</tr>

	<tr>		<td>cdouble</td>
		<td>complex number type made of two doubles</td>
		<td>double.nan + double.nan * 1.0i</td>
	</tr>
	<tr>		<td>creal</td>
		<td>complex number type made of two reals</td>

		<td>real.nan + real.nan * 1.0i</td>
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
In addition to the above, the keyword $(C void) represents $(I having no type). The keywords $(C cent) and $(C ucent) are reserved for future use to represent signed and unsigned 128 bit values.
)

$(P
Unless there is a specific reason not to, you can use $(C int) to represent whole values. To represent concepts that can have fractional values, consider $(C double).
)

$(P
The following are the terms that appeared in the table:
)

$(UL

$(LI
$(B Boolean:) The type of logical expressions, having the value $(C true) for truth and $(C false) for falsity.
)

$(LI
$(B Signed type:) A type that can have negative and positive values. For example, $(C byte) can have values from -128 to 127. The names of these types come from the negative $(I sign).
)

$(LI
$(B Unsigned type:) A type that can have only positive values. For example, $(C ubyte) can have values from 0 to 255. The $(C u) at the beginning of the name of these types comes from $(I unsigned).
)

$(LI
$(B Floating point:) The type that can represent values with fractions as in 1.25. The precision of floating point calculations are directly related to the bit count of the type: higher the bit count, more precise the results are. Only floating point types can represent fractions; integer types like $(C int) can only represent whole values like 1 and 2.
)

$(LI
$(B Complex number type:) The type that can represent the complex numbers of mathematics.
)

$(LI
$(B Imaginary number type:) The type that represents only the imaginary part of complex numbers. The $(C i) that appears in the Initial Value column is the square root of -1 in mathematics.
)

$(LI
$(IX .nan) $(B nan:) Short for "not a number", representing $(I invalid floating point value).
)

)

$(H5 Properties of types)

$(P
D types have $(I properties). Properties are accessed with a dot after the name of the type. For example, the $(C sizeof) property of $(C int) is accessed as $(C int.sizeof). We will see only some of type properties in this chapter:
)

$(UL

$(LI $(IX .stringof) $(C .stringof) is the name of the type)

$(LI $(IX .sizeof) $(C .sizeof) is the length of the type in terms of bytes. (In order to determine the bit count, this value must be multiplied by 8, the number of bits in a $(C byte).)
)

$(LI $(IX .min) $(C .min) is short for "minimum"; this is the smallest value that the type can have)

$(LI $(IX .max) $(C .max) is short for "maximum"; this is the largest value that the type can have)

$(LI $(IX .init) $(IX initial value) $(IX default value, type) $(C .init) is short for "initial value" (default value); this is the value that D assigns to a type when an initial value is not specified)

)

$(P
Here is a program that prints these properties for $(C int):
)

---
import std.stdio;

void main() {
    writeln("Type           : ", int.stringof);
    writeln("Length in bytes: ", int.sizeof);
    writeln("Minimum value  : ", int.min);
    writeln("Maximum value  : ", int.max);
    writeln("Initial value  : ", int.init);
}
---

$(P
The output of the program is the following:
)

$(SHELL
Type           : int
Length in bytes: 4
Minimum value  : -2147483648
Maximum value  : 2147483647
Initial value  : 0
)

$(H5 $(IX size_t) $(C size_t))

$(P
You will come across the $(C size_t) type as well. $(C size_t) is not a separate type but an alias of an existing unsigned type. Its name comes from "size type". It is the most suitable type to represent concepts like $(I size) or $(I count).
)

$(P
$(C size_t) is large enough to represent the number of bytes of the memory that a program can potentially be using. Its actual size depends on the system: $(C uint) on a 32-bit system and $(C ulong) on a 64-bit system. For that reason, $(C ulong) is larger than $(C size_t) on a 32-bit system.
)

$(P
You can use the $(C .stringof) property to see what $(C size_t) is an alias of on your system:
)

---
import std.stdio;

void main() {
    writeln(size_t.stringof);
}
---

$(P
The output of the program is the following on my system:
)

$(SHELL
ulong
)

$(PROBLEM_TEK

$(P
Print the properties of other types.
)

$(P
$(I $(B Note:) You can't use the reserved types $(C cent) and $(C ucent) in any program; and as an exception, $(C void) does not have the properties $(C .min), $(C .max) and $(C .init).)
)

$(P
$(I Additionally, the $(C .min) property is deprecated for floating point types. (You can see all the various properties for the fundamental types in the $(LINK2 http://dlang.org/property.html, D property specification)). If you use a floating point type in this exercise, you would be warned by the compiler that $(C .min) is not valid for that type. Instead, as we will see later in $(LINK2 floating_point.html, the Floating Point Types chapter), you must use the negative of the $(C .max) property e.g. as $(C -double.max).)
)

)


Macros:
        TITLE=Fundamental Types

        DESCRIPTION=The fundamental types of the D programming language

        KEYWORDS=d programming language tutorial book fundamental types numeric limits
