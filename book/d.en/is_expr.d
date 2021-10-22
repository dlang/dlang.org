Ddoc

$(DERS_BOLUMU $(IX is, expression) $(CH4 is) Expression)

$(P
The $(C is) $(I expression) is not related to the $(C is) $(I operator) that we saw in $(LINK2 null_is.html, The $(CH4 null) Value and the $(CH4 is) Operator chapter), neither syntactically nor semantically:
)

---
    a is b            // is operator, which we have seen before

    is (/* ... */)    // is expression
---

$(P
The $(C is) expression is evaluated at compile time. It produces an $(C int) value, either 0 or 1 depending on the expression specified in parentheses. Although the expression that it takes is not a logical expression, the $(C is) expression itself is used as a compile time logical expression. It is especially useful in $(C static if) conditionals and template constraints.
)

$(P
The condition that it takes is always about types, which must be written in one of several syntaxes.
)

$(H5 $(C is ($(I T))))

$(P
Determines whether $(C T) is valid as a type.
)

$(P
It is difficult to come up with examples for this use at this point. We will take advantage of it in later chapters with template parameters.
)

---
    static if (is (int)) {
        writeln("valid");

    } else {
        writeln("invalid");
    }
---

$(P
$(C int) above is a valid type:
)

$(SHELL_SMALL
valid
)

$(P
As another example, because $(C void) is not valid as the key type of an associative array, the $(C else) block would be enabled below:
)

---
    static if (is (string[void])) {
        writeln("valid");

    } else {
        writeln("invalid");
    }
---

$(P
The output:
)

$(SHELL_SMALL
invalid
)


$(H5 $(C is ($(I T Alias))))

$(P
Works in the same way as the previous syntax. Additionally, defines $(C Alias) as an alias of $(C T):
)

---
    static if (is (int NewAlias)) {
        writeln("valid");
        NewAlias var = 42; // int and NewAlias are the same

    } else {
        writeln("invalid");
    }
---

$(P
Such aliases are useful especially in more complex $(C is) expressions as we will see below.
)

$(H5 $(C is ($(I T) : $(I OtherT))))

$(P
Determines whether $(C T) can automatically be converted to $(C OtherT).
)

$(P
It is used for detecting automatic type conversions which we have seen in $(LINK2 cast.html, the Type Conversions chapter), as well as relationships like "this type is of that type", which we have seen in $(LINK2 inheritance.html, the Inheritance chapter).
)

---
import std.stdio;

interface Clock {
    void tellTime();
}

class AlarmClock : Clock {
    override void tellTime() {
        writeln("10:00");
    }
}

void myFunction(T)(T parameter) {
    static if ($(HILITE is (T : Clock))) {
        // If we are here then T can be used as a Clock
        writeln("This is a Clock; we can tell the time");
        parameter.tellTime();

    } else {
        writeln("This is not a Clock");
    }
}

void main() {
    auto var = new AlarmClock;
    myFunction(var);
    myFunction(42);
}
---

$(P
When the $(C myFunction()) template is instantiated for a type that can be used like a $(C Clock), then the $(C tellTime()) member function is called on its parameter. Otherwise, the $(C else) clause gets compiled:
)

$(SHELL_SMALL
This is a Clock; we can tell the time  $(SHELL_NOTE for AlarmClock)
10:00                                  $(SHELL_NOTE for AlarmClock)
This is not a Clock                    $(SHELL_NOTE for int)
)

$(H5 $(C is ($(I T Alias) : $(I OtherT))))

$(P
Works in the same way as the previous syntax. Additionally, defines $(C Alias) as an alias of $(C T).
)

$(H5 $(C is ($(I T) == $(I Specifier))))

$(P
Determines whether $(C T) $(I is the same type) as $(C Specifier) or whether $(C T) $(I matches that specifier).
)

$(H6 Whether the same type)

$(P
When we change the previous example to use $(C ==) instead of $(C :), the condition would not be satisfied for $(C AlarmClock):
)

---
    static if (is (T $(HILITE ==) Clock)) {
        writeln("This is a Clock; we can tell the time");
        parameter.tellTime();

    } else {
        writeln("This is not a Clock");
    }
---

$(P
Although $(C AlarmClock) $(I is a) $(C Clock), it is not exactly the same type as $(C Clock). For that reason, now the condition is invalid for both $(C AlarmClock) and $(C int):
)

$(SHELL_SMALL
This is not a Clock
This is not a Clock
)

$(H6 Whether matches the same specifier)

$(P
When $(C Specifier) is one of the following keywords, this use of $(C is) determines whether the type matches that specifier (we will see some of these keywords in later chapters):
)

$(UL
$(LI $(IX struct, is expression) $(C struct))
$(LI $(IX union, is expression) $(C union))
$(LI $(IX class, is expression) $(C class))
$(LI $(IX interface, is expression) $(C interface))
$(LI $(IX enum, is expression) $(C enum))
$(LI $(IX function, is expression) $(C function))
$(LI $(IX delegate, is expression) $(C delegate))
$(LI $(IX const, is expression) $(C const))
$(LI $(IX immutable, is expression) $(C immutable))
$(LI $(IX shared, is expression) $(C shared))
)

---
void myFunction(T)(T parameter) {
    static if (is (T == class)) {
        writeln("This is a class type");

    } else static if (is (T == enum)) {
        writeln("This is an enum type");

    } else static if (is (T == const)) {
        writeln("This is a const type");

    } else {
        writeln("This is some other type");
    }
}
---

$(P
Function templates can take advantage of such information to behave differently depending on the type that the template is instantiated with. The following code demonstrates how different blocks of the template above get compiled for different types:
)

---
    auto var = new AlarmClock;
    myFunction(var);

    // (enum WeekDays will be defined below for another example)
    myFunction(WeekDays.Monday);

    const double number = 1.2;
    myFunction(number);

    myFunction(42);
---

$(P
The output:
)

$(SHELL_SMALL
This is a class type
This is an enum type
This is a const type
This is some other type
)

$(H5 $(C is ($(I T identifier) == $(I Specifier))))

$(P
$(IX super, is expression)
$(IX return, is expression)
$(IX __parameters, is expression)
Works in the same way as the previous syntax. $(C identifier) is either an alias of the type; or some other information depending on $(C Specifier):
)

<table class="wide" border="1" cellpadding="4" cellspacing="0">
<tr>	<th  style="padding-left:1em; padding-right:1em;" scope="col">$(C Specifier)</th>
<th scope="col">The meaning of $(C identifier)</th>

</tr>

<tr>	<td>$(C struct)</td>
<td>alias of the type that satisfied the condition</td>
</tr>

<tr>	<td>$(C union)</td>
<td>alias of the type that satisfied the condition</td>
</tr>

<tr>	<td>$(C class)</td>
<td>alias of the type that satisfied the condition</td>
</tr>

<tr>	<td>$(C interface)</td>
<td>alias of the type that satisfied the condition</td>
</tr>

<tr>	<td>$(C super)</td>
<td>a $(I tuple) consisting of the base classes and the interfaces</td>
</tr>

<tr>	<td>$(C enum)</td>
<td>the actual implementation type of the $(C enum)</td>
</tr>

<tr>	<td>$(C function)</td>
<td>a $(I tuple) consisting of the function parameters</td>
</tr>

<tr>	<td>$(C delegate)</td>
<td>the type of the $(C delegate)</td>
</tr>

<tr>	<td>$(C return)</td>
<td>the return type of the regular function, the $(C delegate), or the function pointer</td>
</tr>

<tr>	<td>$(C __parameters)</td>
<td>a $(I tuple) consisting of the parameters of the regular function, the $(C delegate), or the function pointer</td>
</tr>

<tr>	<td>$(C const)</td>
<td>alias of the type that satisfied the condition</td>
</tr>

<tr>	<td>$(C immutable)</td>
<td>alias of the type that satisfied the condition</td>
</tr>

<tr>	<td>$(C shared)</td>
<td>alias of the type that satisfied the condition</td>
</tr>

</table>

$(P
Let's first define various types before experimenting with this syntax:
)

---
struct Point {
    // ...
}

interface Clock {
    // ...
}

class AlarmClock : Clock {
    // ...
}

enum WeekDays {
    Monday, Tuesday, Wednesday, Thursday, Friday,
    Saturday, Sunday
}

char foo(double d, int i, Clock c) {
    return 'a';
}
---

$(P
The following function template uses different specifiers with this syntax of the $(C is) expression:
)

---
void myFunction(T)(T parameter) {
    static if (is (T LocalAlias == struct)) {
        writefln("\n--- struct ---");
        // LocalAlias is the same as T. 'parameter' is the
        // struct object that has been passed to this
        // function.

        writefln("Constructing a new %s object by copying it.",
                 LocalAlias.stringof);
        LocalAlias theCopy = parameter;
    }

    static if (is (T baseTypes == super)) {
        writeln("\n--- super ---");
        // The 'baseTypes' tuple contains all of the base
        // types of T. 'parameter' is the class variable that
        // has been passed to this function.

        writefln("class %s has %s base types.",
                 T.stringof, baseTypes.length);

        writeln("All of the bases: ", baseTypes.stringof);
        writeln("The topmost base: ", baseTypes[0].stringof);
    }

    static if (is (T ImplT == enum)) {
        writeln("\n--- enum ---");
        // 'ImplT' is the actual implementation type of this
        //  enum type. 'parameter' is the enum value that has
        //  been passed to this function.

        writefln("The implementation type of enum %s is %s",
                 T.stringof, ImplT.stringof);
    }

    static if (is (T ReturnT == return)) {
        writeln("\n--- return ---");
        // 'ReturnT' is the return type of the function
        // pointer that has been passed to this function.

        writefln("This is a function with a return type of %s:",
                 ReturnT.stringof);
        writeln("    ", T.stringof);
        write("calling it... ");

        // Note: Function pointers can be called like
        // functions
        ReturnT result = parameter(1.5, 42, new AlarmClock);
        writefln("and the result is '%s'", result);
    }
}
---

$(P
Let's now call that function template with various types that we have defined above:
)

---
    // Calling with a struct object
    myFunction(Point());

    // Calling with a class reference
    myFunction(new AlarmClock);

    // Calling with an enum value
    myFunction(WeekDays.Monday);

    // Calling with a function pointer
    myFunction(&foo);
---

$(P
The output:
)

$(SHELL_SMALL
--- struct ---
Constructing a new Point object by copying it.

--- super ---
class AlarmClock has 2 base types.
All of the bases: (Object, Clock)
The topmost base: Object

--- enum ---
The implementation type of enum WeekDays is int

--- return ---
This is a function with a return type of char:
    char function(double d, int i, Clock c)
calling it... and the result is 'a'
)

$(H5 $(C is (/* ... */ $(I Specifier), $(I TemplateParamList))))

$(P
There are four different syntaxes of the $(C is) expression that uses a template parameter list:
)

$(UL

$(LI $(C is ($(I T) : $(I Specifier), $(I TemplateParamList))))

$(LI $(C is ($(I T) == $(I Specifier), $(I TemplateParamList))))

$(LI $(C is ($(I T identifier) : $(I Specifier), $(I TemplateParamList))))

$(LI $(C is ($(I T identifier) == $(I Specifier), $(I TemplateParamList))))

)

$(P
These syntaxes allow for more complex cases.
)

$(P
$(C identifier), $(C Specifier), $(C :), and $(C ==) all have the same meanings as described above.
)

$(P
$(C TemplateParamList) is both a part of the condition that needs to be satisfied and a facility to define additional aliases if the condition is indeed satisfied. It works in the same way as template type deduction.
)

$(P
As a simple example, let's assume that an $(C is) expression needs to match associative arrays that have keys of type $(C string):
)

---
    static if (is (T == Value[Key],   // (1)
                   Value,             // (2)
                   Key : string)) {   // (3)
---

$(P
That condition can be explained in three parts where the last two are parts of the $(C TemplateParamList):
)

$(OL
$(LI If $(C T) matches the syntax of $(C Value[Key]))
$(LI If $(C Value) is a type)
$(LI If $(C Key) is $(C string) (remember $(LINK2 templates.html, template specialization syntax)))
)

$(P
Having $(C Value[Key]) as the $(C Specifier) requires that $(C T) is an associative array. Leaving $(C Value) $(I as is) means that it can be any type. Additionally, the key type of the associative array must be $(C string). As a result, the previous $(C is) expression means "if $(C T) is an associative array where the key type is $(C string)."
)

$(P
The following program tests that $(C is) expression with four different types:
)

---
import std.stdio;

void myFunction(T)(T parameter) {
    writefln("\n--- Called with %s ---", T.stringof);

    static if (is (T == Value[Key],
                   Value,
                   Key : string)) {

        writeln("Yes, the condition has been satisfied.");

        writeln("The value type: ", Value.stringof);
        writeln("The key type  : ", Key.stringof);

    } else {
        writeln("No, the condition has not been satisfied.");
    }
}

void main() {
    int number;
    myFunction(number);

    int[string] intTable;
    myFunction(intTable);

    double[string] doubleTable;
    myFunction(doubleTable);

    dchar[long] dcharTable;
    myFunction(dcharTable);
}
---

$(P
The condition is satisfied only if the key type is $(C string):
)

$(SHELL_SMALL
--- Called with int ---
No, the condition has not been satisfied.

--- Called with int[string] ---
Yes, the condition has been satisfied.
The value type: int
The key type  : string

--- Called with double[string] ---
Yes, the condition has been satisfied.
The value type: double
The key type  : string

--- Called with dchar[long] ---
No, the condition has not been satisfied.
)

Macros:
        TITLE=is Expression

        DESCRIPTION=The is expression, one of the introspection features of the D programming language.

        KEYWORDS=d programming language tutorial book is expression
