Ddoc

$(DERS_BOLUMU $(IX type conversion) $(IX conversion, type) Type Conversions)

$(P
Variables must be compatible with the expressions that they take part in. As it has probably been obvious from the programs that we have seen so far, D is a $(I statically typed language), meaning that the compatibility of types is validated at compile time.
)

$(P
All of the expressions that we have written so far always had compatible types because otherwise the code would be rejected by the compiler. The following is an example of code that has incompatible types:
)

---
    char[] slice;
    writeln(slice + 5);    $(DERLEME_HATASI)
---

$(P
The compiler rejects the code due to the incompatible types $(C char[]) and $(C int) for the addition operation:
)

$(SHELL
Error: $(HILITE incompatible types) for ((slice) + (5)): 'char[]' and 'int'
)

$(P
Type incompatibility does not mean that the types are different; different types can indeed be used in expressions safely. For example, an $(C int) variable can safely be used in place of a $(C double) value:
)

---
    double sum = 1.25;
    int increment = 3;
    sum += increment;
---

$(P
Even though $(C sum) and $(C increment) are of different types, the code above is valid because incrementing a $(C double) variable by an $(C int) value is legal.
)

$(H5 $(IX automatic type conversion) $(IX implicit type conversion) Automatic type conversions)

$(P
Automatic type conversions are also called $(I implicit type conversions).
)

$(P
Although $(C double) and $(C int) are compatible types in the expression above, the addition operation must still be evaluated as a specific type at the microprocessor level.  As you would remember from the $(LINK2 floating_point.html, Floating Point Types chapter), the 64-bit type $(C double) is $(I wider) (or $(I larger)) than the 32-bit type $(C int). Additionally, any value that fits in an $(C int) also fits in a $(C double).
)

$(P
When the compiler encounters an expression that involves mismatched types, it first converts the parts of the expressions to a common type and then evaluates the overall expression. The automatic conversions that are performed by the compiler are in the direction that avoids data loss. For example, $(C double) can hold any value that $(C int) can hold but the opposite is not true. The $(C +=) operation above can work because any $(C int) value can safely be converted to $(C double).
)

$(P
The value that has been generated automatically as a result of a conversion is always an anonymous (and often temporary) variable. The original value does not change. For example, the automatic conversion during $(C +=) above does not change the type of $(C increment); it is always an $(C int). Rather, a temporary value of type $(C double) is constructed with the value of $(C increment). The conversion that takes place in the background is equivalent to the following code:
)

---
    {
        double $(I an_anonymous_double_value) = increment;
        sum += $(I an_anonymous_double_value);
    }
---

$(P
The compiler converts the $(C int) value to a temporary $(C double) value and uses that value in the operation. In this example, the temporary variable lives only during the $(C +=) operation.
)

$(P
Automatic conversions are not limited to arithmetic operations. There are other cases where types are converted to other types automatically. As long as the conversions are valid, the compiler takes advantage of type conversions to be able to use values in expressions. For example, a $(C byte) value can be passed for an $(C int) parameter:
)

---
void func(int number) {
    // ...
}

void main() {
    byte smallValue = 7;
    func(smallValue);    // automatic type conversion
}
---

$(P
In the code above, first a temporary $(C int) value is constructed and the function is called with that value.
)

$(H6 $(IX integer promotion) $(IX promotion, integer) Integer promotions)

$(P
Values of types that are on the left-hand side of the following table never take part in arithmetic expressions as their actual types. Each type is first promoted to the type that is on the right-hand side of the table.
)

<table class="narrow" border="1" cellpadding="4" cellspacing="0">
<tr><th scope="col">From</th> <th scope="col">To</th>
</tr>

        <tr align="center">
	<td>bool</td>
	<td>int</td>
	</tr>

        <tr align="center">
	<td>byte</td>
	<td>int</td>
	</tr>

	<tr align="center">
	<td>ubyte</td>
	<td>int</td>
	</tr>

        <tr align="center">
	<td>short</td>
	<td>int</td>
	</tr>

	<tr align="center">
	<td>ushort</td>
	<td>int</td>
	</tr>

	<tr align="center">
	<td>char</td>
	<td>int</td>
	</tr>

        <tr align="center">
	<td>wchar</td>
	<td>int</td>
	</tr>

        <tr align="center">
	<td>dchar</td>
	<td>uint</td>
	</tr>
</table>

$(P
Integer promotions are applied to $(C enum) values as well.
)

$(P
The reasons for integer promotions are both historical (where the rules come from C) and the fact that the natural arithmetic type for the microprocessor is $(C int). For example, although the following two variables are both $(C ubyte), the addition operation is performed only after both of the values are individually promoted to $(C int):
)

---
    ubyte a = 1;
    ubyte b = 2;
    writeln(typeof(a + b).stringof);  // the addition is not in ubyte
---

$(P
The output:
)

$(SHELL
int
)

$(P
Note that the types of the variables $(C a) and $(C b) do not change; only their values are temporarily promoted to $(C int) for the duration of the addition operation.
)

$(H6 $(IX arithmetic conversion) Arithmetic conversions)

$(P
There are other conversion rules that are applied for arithmetic operations. In general, automatic arithmetic conversions are applied in the safe direction: from the $(I narrower) type to the $(I wider) type. Although this rule is easy to remember and is correct in most cases, automatic conversion rules are very complicated and in the case of signed-to-unsigned conversions, carry some risk of bugs.
)

$(P
The arithmetic conversion rules are the following:
)

$(OL

$(LI If one of the values is $(C real), then the other value is converted to $(C real))

$(LI Else, if one of the values is $(C double), then the other value is converted to $(C double))

$(LI Else, if one of the values is $(C float), then the other value is converted to $(C float))

$(LI Else, first $(I integer promotions) are applied according to the table above, and then the following rules are followed:

$(OL
$(LI If both types are the same, then no more steps needed)
$(LI If both types are signed or both types are unsigned, then the narrower value is converted to the wider type)
$(LI If the signed type is wider than the unsigned type, then the unsigned value is converted to the signed type)
$(LI Otherwise the signed type is converted to the unsigned type)
)
)
)

$(P
Unfortunately, the last rule above can cause subtle bugs:
)

---
    int    a = 0;
    int    b = 1;
    size_t c = 0;
    writeln(a - b + c);  // Surprising result!
---

$(P
Surprisingly, the output is not -1, but $(C size_t.max):
)

$(SHELL
18446744073709551615
)

$(P
Although one would expect $(C (0 - 1 + 0)) to be calculated as -1, according to the rules above, the type of the entire expression is $(C size_t), not $(C int); and since $(C size_t) cannot hold negative values, the result overflows and becomes $(C size_t.max).
)

$(H6 Slice conversions)

$(P
$(IX fixed-length array, conversion to slice) $(IX static array, conversion to slice) As a convenience, fixed-length arrays can automatically be converted to slices when calling a function:
)

---
import std.stdio;

void foo() {
    $(HILITE int[2]) array = [ 1, 2 ];
    bar(array);    // Passes fixed-length array as a slice
}

void bar($(HILITE int[]) slice) {
    writeln(slice);
}

void main() {
    foo();
}
---

$(P
$(C bar()) receives a slice to all elements of the fixed-length array and prints it:
)

$(SHELL
[1, 2]
)

$(P
$(B Warning:) A $(I local) fixed-length array must not be passed as a slice if the function stores the slice for later use. For example, the following program has a bug because the slice that $(C bar()) stores would not be valid after $(C foo()) exits:
)

---
import std.stdio;

void foo() {
    int[2] array = [ 1, 2 ];
    bar(array);    // Passes fixed-length array as a slice

}  // ← NOTE: 'array' is not valid beyond this point

int[] sliceForLaterUse;

void bar(int[] slice) {
    // Saves a slice that is about to become invalid
    sliceForLaterUse = slice;
    writefln("Inside bar : %s", sliceForLaterUse);
}

void main() {
    foo();

    /* BUG: Accesses memory that is not array elements anymore */
    writefln("Inside main: %s", sliceForLaterUse);
}
---

$(P
The result of such a bug is undefined behavior. A sample execution can prove that the memory that used to be the elements of $(C array) has already been reused for other purposes:
)

$(SHELL
Inside bar : [1, 2]        $(SHELL_NOTE actual elements)
Inside main: [4396640, 0]  $(SHELL_NOTE_WRONG a manifestation of undefined behavior)
)

$(H6 $(C const) conversions)

$(P
As we have seen earlier in the $(LINK2 function_parameters.html, Function Parameters chapter), reference types can automatically be converted to the $(C const) of the same type. Conversion to $(C const) is safe because the width of the type does not change and $(C const) is a promise to not modify the variable:
)

---
char[] parenthesized($(HILITE const char[]) text) {
    return "{" ~ text ~ "}";
}

void main() {
    $(HILITE char[]) greeting;
    greeting ~= "hello world";
    parenthesized(greeting);
}
---

$(P
The mutable $(C greeting) above is automatically converted to a $(C const char[]) as it is passed to $(C parenthesized()).
)

$(P
As we have also seen earlier, the opposite conversion is not automatic. A $(C const) reference is not automatically converted to a mutable reference:
)

---
char[] parenthesized(const char[] text) {
    char[] argument = text;  $(DERLEME_HATASI)
// ...
}
---

$(P
Note that this topic is only about references; since variables of value types are copied, it is not possible to affect the original through the copy anyway:
)

---
    const int totalCorners = 4;
    int theCopy = totalCorners;      // compiles (value type)
---

$(P
The conversion from $(C const) to mutable above is legal because the copy is not a reference to the original.
)

$(H6 $(C immutable) conversions)

$(P
Because $(C immutable) specifies that a variable can never change, neither conversion from $(C immutable) nor to $(C immutable) are automatic:
)

---
    string a = "hello";    // immutable characters
    char[] b = a;          $(DERLEME_HATASI)
    string c = b;          $(DERLEME_HATASI)
---

$(P
As with $(C const) conversions above, this topic is also only about reference types. Since variables of value types are copied anyway, conversions to and from $(C immutable) are valid:
)

---
    immutable a = 10;
    int b = a;           // compiles (value type)
---

$(H6 $(C enum) conversions)

$(P
As we have seen in the $(LINK2 enum.html, $(C enum) chapter), $(C enum) is for defining $(I named constants):
)

---
    enum Suit { spades, hearts, diamonds, clubs }
---

$(P
Remember that since no values are specified explicitly above, the values of the $(C enum) members start with zero and are automatically incremented by one. Accordingly, the value of $(C Suit.clubs) is 3.
)

$(P
$(C enum) values are atomatically converted to integral types. For example, the value of $(C Suit.hearts) is taken to be 1 in the following calculation and the result becomes 11:
)

---
    int result = 10 + Suit.hearts;
    assert(result == 11);
---

$(P
The opposite conversion is not automatic: Integer values are not automatically converted to corresponding $(C enum) values. For example, the $(C suit) variable below might be expected to become $(C Suit.diamonds), but the code cannot be compiled:
)

---
    Suit suit = 2;    $(DERLEME_HATASI)
---

$(P
As we will see below, conversions from integers to $(C enum) values are still possible but they must be explicit.
)

$(H6 $(IX bool, automatic conversion) $(C bool) conversions)

$(P
$(IX bool, 1-bit integer) $(IX 1-bit integer) $(IX one-bit integer) Although $(C bool) is the natural type of logical expressions, as it has only two values, it can be seen as a 1-bit integer and does behave like one in some cases. $(C false) and $(C true) are automatically converted to 0 and 1, respectively:
)

---
    int a = false;
    assert(a == 0);

    int b = true;
    assert(b == 1);
---

$(P
Regarding $(I literal values), the opposite conversion is automatic only for two special literal values: 0 and 1 are converted automatically to $(C false) and $(C true), respectively:
)

---
    bool a = 0;
    assert(!a);     // false

    bool b = 1;
    assert(b);      // true
---

$(P
Other literal values cannot be converted to $(C bool) automatically:
)

---
    bool b = 2;    $(DERLEME_HATASI)
---

$(P
Some statements make use of logical expressions: $(C if), $(C while), etc. For the logical expressions of such statements, not only $(C bool) but most other types can be used as well. The value zero is automatically converted to $(C false) and the nonzero values are automatically converted to $(C true).
)

---
    int i;
    // ...

    if (i) {    // ← int value is being used as a logical expression
        // ... 'i' is not zero

    } else {
        // ... 'i' is zero
    }
---

$(P
Similarly, $(C null) references are automatically converted to $(C false) and non-$(C null) references are automatically converted to $(C true). This makes it easy to ensure that a reference is non-$(C null) before actually using it:
)

---
    int[] a;
    // ...

    if (a) {    // ← automatic bool conversion
        // ... not null; 'a' can be used ...

    } else {
        // ... null; 'a' cannot be used ...
    }
---

$(H5 $(IX explicit type conversion) $(IX type conversion, explicit) Explicit type conversions)

$(P
As we have seen above, there are cases where automatic conversions are not available:
)

$(UL
$(LI Conversions from wider types to narrower types)
$(LI Conversions from $(C const) to mutable)
$(LI $(C immutable) conversions)
$(LI Conversions from integers to $(C enum) values)
$(LI etc.)
)

$(P
If such a conversion is known to be safe, the programmer can explicitly ask for a type conversion by one of the following methods:
)

$(UL
$(LI Construction syntax)
$(LI $(C std.conv.to) function)
$(LI $(C std.exception.assumeUnique) function)
$(LI $(C cast) operator)
)

$(H6 $(IX construction, type conversion) Construction syntax)

$(P
The $(C struct) and $(C class) construction syntax is available for other types as well:
)

---
    $(I DestinationType)(value)
---

$(P
For example, the following $(I conversion) makes a $(C double) value from an $(C int) value, presumably to preserve the fractional part of the division operation:
)

---
    int i;
    // ...
    const result = $(HILITE double(i)) / 2;
---

$(H6 $(IX to, std.conv) $(C to()) for most conversions)

$(P
The $(C to()) function, which we have already used mostly to convert values to $(C string), can actually be used for many other types. Its complete syntax is the following:
)

---
    to!($(I DestinationType))(value)
---

$(P
Being a template, $(C to()) can take advantage of the shortcut template parameter notation: When the destination type consists only of a single token (generally, $(I a single word)), it can be called without the first pair of parentheses:
)

---
    to!$(I DestinationType)(value)
---

$(P
The following program is trying to convert a $(C double) value to $(C short) and a $(C string) value to $(C int):
)

---
void main() {
    double d = -1.75;

    short s = d;     $(DERLEME_HATASI)
    int i = "42";    $(DERLEME_HATASI)
}
---

$(P
Since not every $(C double) value can be represented as a $(C short) and not every $(C string) can be represented as an $(C int), those conversions are not automatic. When it is known by the programmer that the conversions are in fact safe or that the potential consequences are acceptable, then the types can be converted by $(C to()):
)

---
import std.conv;

void main() {
    double d = -1.75;

    short s = to!short(d);
    assert(s == -1);

    int i = to!int("42");
    assert(i == 42);
}
---

$(P
Note that because $(C short) cannot carry fractional values, the converted value is -1.
)

$(P
$(C to()) is safe: It throws an exception when a conversion is not possible.
)

$(H6 $(IX assumeUnique, std.exception) $(C assumeUnique()) for fast $(C immutable) conversions)

$(P
$(C to()) can perform $(C immutable) conversions as well:
)

---
    int[] slice = [ 10, 20, 30 ];
    auto immutableSlice = to!($(HILITE immutable int[]))(slice);
---

$(P
In order to guarantee that the elements of $(C immutableSlice) will never change, it cannot share the same elements with $(C slice). For that reason, $(C to()) creates an additional slice with $(C immutable) elements above. Otherwise, modifications to the elements of $(C slice) would cause the elements of $(C immutableSlice) change as well. This behavior is the same with the $(C .idup) property of arrays.
)

$(P
We can see that the elements of $(C immutableSlice) are indeed copies of the elements of $(C slice) by looking at the addresses of their first elements:
)

---
    assert(&(slice[0]) $(HILITE !=) &(immutableSlice[0]));
---

$(P
Sometimes this copy is unnecessary and may slow the speed of the program noticeably in certain cases. As an example of this, let's look at the following function that takes an $(C immutable) slice:
)

---
void calculate(immutable int[] coordinates) {
    // ...
}

void main() {
    int[] numbers;
    numbers ~= 10;
    // ... various other modifications ...
    numbers[0] = 42;

    calculate(numbers);    $(DERLEME_HATASI)
}
---

$(P
The program above cannot be compiled because the caller is not passing an $(C immutable) argument to $(C calculate()). As we have seen above, an $(C immutable) slice can be created by $(C to()):
)

---
import std.conv;
// ...
    auto immutableNumbers = to!(immutable int[])(numbers);
    calculate(immutableNumbers);    // ← now compiles
---

$(P
However, if $(C numbers) is needed only to produce this argument and will never be used after the function is called, copying its elements to $(C immutableNumbers) would be unnecessary. $(C assumeUnique()) makes the elements of a slice $(C immutable) without copying:
)

---
import std.exception;
// ...
    auto immutableNumbers = assumeUnique(numbers);
    calculate(immutableNumbers);
    assert(numbers is null);    // the original slice becomes null
---

$(P
$(C assumeUnique()) returns a new slice that provides $(C immutable) access to the existing elements. It also makes the original slice $(C null) to prevent the elements from accidentally being modified through it.
)

$(H6 $(IX cast) The $(C cast) operator)

$(P
Both $(C to()) and $(C assumeUnique()) make use of the conversion operator $(C cast), which is available to the programmer as well.
)

$(P
The $(C cast) operator takes the destination type in parentheses:
)

---
    cast($(I DestinationType))value
---

$(P
$(C cast) is powerful even for conversions that $(C to()) cannot safely perform. For example, $(C to()) fails for the following conversions at runtime:
)

---
    Suit suit = to!Suit(7);    $(CODE_NOTE_WRONG throws exception)
    bool b = to!bool(2);       $(CODE_NOTE_WRONG throws exception)
---

$(SHELL
std.conv.ConvException@phobos/std/conv.d(1778): Value (7)
$(HILITE does not match any member) value of enum 'Suit'
)

$(P
Sometimes only the programmer can know whether an integer value corresponds to a valid $(C enum) value or that it makes sense to treat an integer value as a $(C bool). The $(C cast) operator can be used when the conversion is known to be correct according the program's logic:
)

---
    // Probably incorrect but possible:
    Suit suit = cast(Suit)7;

    bool b = cast(bool)2;
    assert(b);
---

$(P
$(C cast) is the only option when converting to and from pointer types:
)

---
    $(HILITE void *) v;
    // ...
    int * p = cast($(HILITE int*))v;
---

$(P
Although rare, some C library interfaces make it necessary to store a pointer value as a non-pointer type. If it is guaranteed that the conversion will preserve the actual value, $(C cast) can convert between pointer and non-pointer types as well:
)

---
    size_t savedPointerValue = cast($(HILITE size_t))p;
    // ...
    int * p2 = cast($(HILITE int*))savedPointerValue;
---

$(H5 Summary)

$(UL

$(LI Automatic type conversions are mostly in the safe direction: From the narrower type to the wider type and from mutable to $(C const).)

$(LI However, conversions to unsigned types may have surprising effects because unsigned types cannot have negative values.)

$(LI $(C enum) types can automatically be converted to integer values but the opposite conversion is not automatic.)

$(LI $(C false) and $(C true) are automatically converted to 0 and 1 respectively. Similarly, zero values are automatically converted to $(C false) and nonzero values are automatically converted to $(C true).)

$(LI $(C null) references are automatically converted to $(C false) and non-$(C null) references are automatically converted to $(C true).)

$(LI The construction syntax can be used for explicit conversions.)

$(LI $(C to()) covers most of the explicit conversions.)

$(LI $(C assumeUnique()) converts to $(C immutable) without copying.)

$(LI The $(C cast) operator is the most powerful conversion tool.)

)

Macros:
        TITLE=Type Conversions

        DESCRIPTION=The automatic and explicit type conversions in the D programming language.


        KEYWORDS=d programming lesson book tutorial type conversions
