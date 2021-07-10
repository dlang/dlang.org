Ddoc

$(DERS_BOLUMU $(IX operator overloading) $(IX overloading, operator) Operator Overloading)

$(P
The topics covered in this chapter apply mostly for classes as well. The biggest difference is that the behavior of assignment operation $(C opAssign()) cannot be overloaded for classes.
)

$(P
Operator overloading involves many concepts, some of which will be covered later in the book (templates, $(C auto ref), etc.). For that reason, you may find this chapter to be harder to follow than the previous ones.
)

$(P
Operator overloading enables defining how user-defined types behave when used with operators. In this context, the term $(I overload) means providing the definition of an operator for a specific type.
)

$(P
We have seen how to define structs and their member functions in previous chapters. As an example, we have defined the $(C increment()) member function to be able to add $(C Duration) objects to $(C TimeOfDay) objects. Here are the two structs from previous chapters, with only the parts that are relevant to this chapter:
)

---
struct Duration {
    int minute;
}

struct TimeOfDay {
    int hour;
    int minute;

    void $(HILITE increment)(Duration duration) {
        minute += duration.minute;

        hour += minute / 60;
        minute %= 60;
        hour %= 24;
    }
}

void main() {
    auto lunchTime = TimeOfDay(12, 0);
    lunchTime$(HILITE .increment)(Duration(10));
}
---

$(P
A benefit of member functions is being able to define operations of a type alongside the member variables of that type.
)

$(P
Despite their advantages, member functions can be seen as being limited compared to operations on fundamental types. After all, fundamental types can readily be used with operators:
)

---
    int weight = 50;
    weight $(HILITE +=) 10;                       // by an operator
---

$(P
According to what we have seen so far, similar operations can only be achieved by member functions for user-defined types:
)

---
    auto lunchTime = TimeOfDay(12, 0);
    lunchTime$(HILITE .increment)(Duration(10));  // by a member function
---

$(P
Operator overloading enables using structs and classes with operators as well. For example, assuming that the $(C +=) operator is defined for $(C TimeOfDay), the operation above can be written in exactly the same way as with fundamental types:
)

---
    lunchTime $(HILITE +=) Duration(10);          // by an operator
                                        // (even for a struct)
---

$(P
Before getting to the details of operator overloading, let's first see how the line above would be enabled for $(C TimeOfDay). What is needed is to redefine the $(C increment()) member function under the special name $(C opOpAssign(string op)) and also to specify that this definition is for the $(C +) character. As it will be explained below, this definition actually corresponds to the $(C +=) operator.
)

$(P
The definition of this member function does not look like the ones that we have seen so far. That is because $(C opOpAssign) is actually a $(I function template). Since we will see templates in much later chapters, I will have to ask you to accept the operator overloading syntax as is for now:
)

---
struct TimeOfDay {
// ...
    ref TimeOfDay opOpAssign(string op)(Duration duration) // (1)
            if (op == "+") {                               // (2)

        minute += duration.minute;
        hour += minute / 60;
        minute %= 60;
        hour %= 24;

        return this;
    }
}
---

$(P
The template definition consists of two parts:
)

$(OL

$(LI $(C opOpAssign(string op)): This part must be written as is and should be accepted as the $(I name) of the function. We will see below that there are other member functions in addition to $(C opOpAssign).
)

$(LI $(C if (op == $(STRING "+"))): $(C opOpAssign) is used for more than one operator overload. $(C $(STRING "+")) specifies that this is the operator overload that corresponds to the $(C +) character. This syntax is a $(I template constraint), which will also be covered in later chapters.
)

)

$(P
Also note that this time the return type is different from the return type of the $(C increment()) member function: It is not $(C void) anymore. We will discuss the return types of operators later below.
)

$(P
Behind the scenes, the compiler replaces the uses of the $(C +=) operator with calls to the $(C opOpAssign!$(STRING "+")) member function:
)

---
    lunchTime += Duration(10);

    // The following line is the equivalent of the previous one
    lunchTime.opOpAssign!"+"(Duration(10));
---

$(P
The $(C !$(STRING "+")) part that is after $(C opOpAssign) specifies that this call is for the definition of the operator for the $(C +) character. We will cover this template syntax in later chapters as well.
)

$(P
Note that the operator definition that corresponds to $(C +=) is defined by $(STRING "+"), not by $(STRING "+="). The $(C Assign) in the name of $(C opOpAssign()) already implies that this name is for an assignment operator.
)

$(P
Being able to define the behaviors of operators brings a responsibility: The programmer must observe expectations. As an extreme example, the previous operator could have been defined to decrement the time value instead of incrementing it. However, people who read the code would still expect the value to be incremented by the $(C +=) operator.
)

$(P
To some extent, the return types of operators can also be chosen freely. Still, general expectations must be observed for the return types as well.
)

$(P
Keep in mind that operators that behave unnaturally would cause confusion and bugs.
)

$(H5 Overloadable operators)

$(P
There are different kinds of operators that can be overloaded.
)

$(H6 $(IX unary operator) $(IX operator, unary) $(IX opUnary) Unary operators)

$(P
An operator that takes a single operand is called a unary operator:
)

---
    ++weight;
---

$(P
$(C ++) is a unary operator because it works on a single variable.
)

$(P
Unary operators are defined by member functions named $(C opUnary). $(C opUnary) does not take any parameters because it uses only the object that the operator is being executed on.
)

$(P
$(IX -, negation)
$(IX +, plus sign)
$(IX ~, bitwise complement)
$(IX *, pointee access)
$(IX ++, pre-increment)
$(IX --, pre-decrement)
The overloadable unary operators and the corresponding operator strings are the following:
)

$(TABLE full,
$(HEAD3 Operator, Description, Operator String)
$(ROW3 -object, negative of (numeric complement of), "-")
$(ROW3 +object, the same value as (or, a copy of), "+")
$(ROW3 ~object, bitwise negation, "~")
$(ROW3 *object, access to what it points to, "*")
$(ROW3 ++object, increment, "++")
$(ROW3 --object, decrement, "--")
)

$(P
For example, the $(C ++) operator for $(C Duration) can be defined like this:
)

---
struct Duration {
    int minute;

    ref Duration opUnary(string op)()
            if (op == "++") {
        ++minute;
        return this;
    }
}
---

$(P
Note that the return type of the operator is marked as $(C ref) here as well. This will be explained later below.
)

$(P
$(C Duration) objects can now be incremented by $(C ++):
)

---
    auto duration = Duration(20);
    ++duration;
---

$(P
$(IX ++, post-increment) $(IX --, post-decrement) The post-increment and post-decrement operators cannot be overloaded. The $(C object++) and $(C object--) uses are handled by the compiler automatically by saving the previous value of the object. For example, the compiler applies the equivalent of the following code for post-increment:
)

---
    /* The previous value is copied by the compiler
     * automatically: */
    Duration __previousValue__ = duration;

    /* The ++ operator is called: */
    ++duration;

    /* Then __previousValue__ is used as the value of the
     * post-increment operation. */
---

$(P
Unlike some other languages, the copy inside post-increment has no cost in D if the value of the post-increment expression is not actually used. This is because the compiler replaces such post-increment expressions with their pre-increment counterparts:
)

---
    /* The value of the expression is not used below. The
     * only effect of the expression is incrementing 'i'. */
    i++;
---

$(P
Because the $(I previous value) of $(C i) is not actually used above, the compiler replaces the expression with the following one:
)

---
    /* The expression that is actually used by the compiler: */
    ++i;
---

$(P
Additionally, if an $(C opBinary) overload supports the $(C duration += 1) usage, then $(C opUnary) need not be overloaded for $(C ++duration) and $(C duration++). Instead, the compiler uses the $(C duration += 1) expression behind the scenes. Similarly, the $(C duration -= 1) overload covers the uses of $(C --duration) and $(C duration--) as well.
)

$(H6 $(IX binary operator) $(IX operator, binary) Binary operators)

$(P
An operator that takes two operands is called a binary operator:
)

---
    totalWeight $(HILITE =) boxWeight $(HILITE +) chocolateWeight;
---

$(P
The line above has two separate binary operators: the $(C +) operator, which adds the values of the two operands that are on its two sides, and the $(C =) operator that assigns the value of its right-hand operand to its left-hand operand.
)

$(P
$(IX +, addition)
$(IX -, subtraction)
$(IX *, multiplication)
$(IX /)
$(IX %)
$(IX ^^)
$(IX &, bitwise and)
$(IX |)
$(IX ^, bitwise exclusive or)
$(IX <<)
$(IX >>)
$(IX >>>)
$(IX ~, concatenation)
$(IX in, operator)
$(IX ==)
$(IX !=)
$(IX <, less than)
$(IX <=)
$(IX >, greater than)
$(IX >=)
$(IX =)
$(IX +=)
$(IX -=)
$(IX *=)
$(IX /=)
$(IX %=)
$(IX ^^=)
$(IX &=)
$(IX |=)
$(IX ^=)
$(IX <<=)
$(IX >>=)
$(IX >>>=)
$(IX ~=)
$(IX opBinary)
$(IX opAssign)
$(IX opOpAssign)
$(IX opBinaryRight)
The rightmost column below describes the category of each operator. The ones marked as "=" assign to the left-hand side object.
)

$(TABLE full,
$(HEAD5 $(BR)Operator, $(BR)Description, $(BR)Function name, Function name$(BR)for right-hand side, $(BR)Category)
$(ROW5 +, add, 	opBinary, 	opBinaryRight, arithmetic)
$(ROW5 -, subtract, 	opBinary, 	opBinaryRight, arithmetic)
$(ROW5 *, multiply, 	opBinary, 	opBinaryRight, arithmetic)
$(ROW5 /, divide, 	opBinary, 	opBinaryRight, arithmetic)
$(ROW5 %, remainder of, 	opBinary, 	opBinaryRight, arithmetic)
$(ROW5 ^^, to the power of, 	opBinary, 	opBinaryRight, arithmetic)
$(ROW5 &, bitwise $(I and), 	opBinary, 	opBinaryRight, bitwise)
$(ROW5 |, bitwise $(I or), 	opBinary, 	opBinaryRight, bitwise)
$(ROW5 ^, bitwise $(I xor), 	opBinary, 	opBinaryRight, bitwise)
$(ROW5 <<, left-shift, 	opBinary, 	opBinaryRight, bitwise)
$(ROW5 >>, right-shift, 	opBinary, 	opBinaryRight, bitwise)
$(ROW5 >>>, unsigned right-shift, 	opBinary, 	opBinaryRight, bitwise)
$(ROW5 ~, concatenate, 	opBinary, 	opBinaryRight, )
$(ROW5 in, whether contained in, 	opBinary, 	opBinaryRight, )
$(ROW5 ==, whether equal to, 	opEquals, 	-, logical)
$(ROW5 !=, whether not equal to, 	opEquals, 	-, logical)
$(ROW5 <, whether before, 	opCmp, 	-, sorting)
$(ROW5 <=, whether not after, 	opCmp, 	-, sorting)
$(ROW5 >, whether after, 	opCmp, 	-, sorting)
$(ROW5 >=, whether not before, 	opCmp, 	-, sorting)
$(ROW5 =, assign, 	opAssign, 	-, =)
$(ROW5 +=, increment by, 	opOpAssign, 	-, =)
$(ROW5 -=, decrement by, 	opOpAssign, 	-, =)
$(ROW5 *=, multiply and assign, 	opOpAssign, 	-, =)
$(ROW5 /=, divide and assign, 	opOpAssign, 	-, =)
$(ROW5 %=, assign the remainder of, 	opOpAssign, 	-, =)
$(ROW5 ^^=, assign the power of, 	opOpAssign, 	-, =)
$(ROW5 &=, assign the result of &, 	opOpAssign, 	-, =)
$(ROW5 |=, assign the result of |, 	opOpAssign, 	-, =)
$(ROW5 ^=, assign the result of ^, 	opOpAssign, 	-, =)
$(ROW5 <<=, assign the result of <<, 	opOpAssign, 	-, =)
$(ROW5 >>=, assign the result of >>, 	opOpAssign, 	-, =)
$(ROW5 >>>=, assign the result of >>>, 	opOpAssign, 	-, =)
$(ROW5 ~=, append, 	opOpAssign, 	-, =)
)

$(P
$(C opBinaryRight) is for when the object can appear on the right-hand side of the operator. Let's assume a binary operator that we shall call $(I op) appears in the program:
)

---
    x $(I op) y
---

$(P
In order to determine what member function to call, the compiler considers the following two options:
)

---
    // the definition for x being on the left:
    x.opBinary!"op"(y);

    // the definition for y being on the right:
    y.opBinaryRight!"op"(x);
---

$(P
The compiler picks the option that is a better match than the other.
)

$(P
$(C opBinaryRight) is useful when defining arithmetic types that would normally work on both sides of an operator like e.g. $(C int) does:
)

---
    auto x = MyInt(42);
    x + 1;    // calls opBinary!"+"
    1 + x;    // calls opBinaryRight!"+"
---

$(P
Another common use of $(C opBinaryRight) is the $(C in) operator. It usually makes more sense to define $(C opBinaryRight) for the object that appears on the right-hand side of $(C in). We will see an example of this below.
)

$(P
The parameter name $(C rhs) that appears in the following definitions is short for $(I right-hand side). It denotes the operand that appears on the right-hand side of the operator:
)

---
    x $(I op) y
---

$(P
For the expression above, the $(C rhs) parameter would represent the variable $(C y).
)

$(H5 Element indexing and slicing operators)

$(P
The following operators enable using a type as a collection of elements:
)

$(TABLE full,
$(HEAD3 Description, Function Name, Sample Usage)
$(ROW3 element access, opIndex, collection[i])
$(ROW3 assignment to element, opIndexAssign, collection[i] = 7)
$(ROW3 unary operation on element, opIndexUnary, ++collection[i])
$(ROW3 operation with assignment on element, opIndexOpAssign, collection[i] *= 2)
$(ROW3 number of elements, opDollar, collection[$ - 1])
$(ROW3 slice of all elements, opSlice, collection[])
$(ROW3 slice of some elements, opSlice(size_t, size_t), collection[i..j])
)

$(P
We will cover those operators later below.
)

$(P
The following operator functions are from the earlier versions of D. They are discouraged:
)

$(TABLE full,
$(HEAD3 Description, Function Name, Sample Usage)
$(ROW3 unary operation on all elements, opSliceUnary (discouraged), ++collection[])
$(ROW3 unary operation on some elements, opSliceUnary (discouraged), ++collection[i..j])
$(ROW3 assignment to all elements, opSliceAssign (discouraged), collection[] = 42)
$(ROW3 assignment to some elements, opSliceAssign (discouraged), collection[i..j] = 7)
$(ROW3 operation with assignment on all elements, opSliceOpAssign (discouraged), collection[] *= 2)
$(ROW3 operation with assignment on some elements, opSliceOpAssign (discouraged), collection[i..j] *= 2)

)

$(H6 Other operators)

$(P
The following operators can be overloaded as well:
)

$(TABLE full,
$(HEAD3 Description, Function Name, Sample Usage)
$(ROW3 function call, opCall, object(42))
$(ROW3 type conversion, opCast, to!int(object))
$(ROW3 dispatch for non-existent function, opDispatch, object.nonExistent())
)

$(P
These operators will be explained below under their own sections.
)

$(H5 Defining more than one operator at the same time)

$(P
To keep the code samples short, we have used only the $(C ++), $(C +), and $(C +=) operators above. It is conceivable that when one operator is overloaded for a type, many others would also need to be overloaded. For example, the $(C --) and $(C -=) operators are also defined for the following $(C Duration):
)

---
struct Duration {
    int minute;

    ref Duration opUnary(string op)()
            if (op == "++") {
        $(HILITE ++)minute;
        return this;
    }

    ref Duration opUnary(string op)()
            if (op == "--") {
        $(HILITE --)minute;
        return this;
    }

    ref Duration opOpAssign(string op)(int amount)
            if (op == "+") {
        minute $(HILITE +)= amount;
        return this;
    }

    ref Duration opOpAssign(string op)(int amount)
            if (op == "-") {
        minute $(HILITE -)= amount;
        return this;
    }
}

unittest {
    auto duration = Duration(10);

    ++duration;
    assert(duration.minute == 11);

    --duration;
    assert(duration.minute == 10);

    duration += 5;
    assert(duration.minute == 15);

    duration -= 3;
    assert(duration.minute == 12);
}

void main() {
}
---

$(P
The operator overloads above have code duplications. The only differences between the similar functions are highlighted. Such code duplications can be reduced and sometimes avoided altogether by $(I string mixins). We will see the $(C mixin) keyword in a later chapter as well. I would like to show briefly how this keyword helps with operator overloading.
)

$(P
$(C mixin) inserts the specified string as source code right where the $(C mixin) statement appears in code. The following struct is the equivalent of the one above:
)

---
struct Duration {
    int minute;

    ref Duration opUnary(string op)()
            if ((op == "++") || (op == "--")) {
        $(HILITE mixin) (op ~ "minute;");
        return this;
    }

    ref Duration opOpAssign(string op)(int amount)
            if ((op == "+") || (op == "-")) {
        $(HILITE mixin) ("minute " ~ op ~ "= amount;");
        return this;
    }
}
---

$(P
If the $(C Duration) objects also need to be multiplied and divided by an amount, all that is needed is to add two more conditions to the template constraint:
)

---
struct Duration {
// ...

    ref Duration opOpAssign(string op)(int amount)
        if ((op == "+") || (op == "-") ||
            $(HILITE (op == "*") || (op == "/"))) {
        mixin ("minute " ~ op ~ "= amount;");
        return this;
    }
}

unittest {
    auto duration = Duration(12);

    duration $(HILITE *=) 4;
    assert(duration.minute == 48);

    duration $(HILITE /=) 2;
    assert(duration.minute == 24);
}
---

$(P
In fact, the template constraints are optional:
)

---
    ref Duration opOpAssign(string op)(int amount)
            /* no constraint */ {
        mixin ("minute " ~ op ~ "= amount;");
        return this;
    }
---

$(H5 $(IX return type, operator) Return types of operators)

$(P
When overloading an operator, it is advisable to observe the return type of the same operator on fundamental types. This would help with making sense of code and reducing confusions.
)

$(P
None of the operators on fundamental types return $(C void). This fact should be obvious for some operators. For example, the result of adding two $(C int) values as $(C a&nbsp;+&nbsp;b) is $(C int):
)

---
    int a = 1;
    int b = 2;
    int c = a + b;  // c gets initialized by the return value
                    // of the + operator
---

$(P
The return values of some other operators may not be so obvious. For example, even operators like $(C ++i) have values:
)

---
    int i = 1;
    writeln(++i);    // prints 2
---

$(P
The $(C ++) operator not only increments $(C i), it also produces the new value of $(C i). Further, the value that is produced by $(C ++) is not just the new value of $(C i), rather $(I the variable $(C i) itself). We can see this fact by printing the address of the result of that expression:
)

---
    int i = 1;
    writeln("The address of i                : ", &i);
    writeln("The address of the result of ++i: ", &(++i));
---

$(P
The output contains identical addresses:
)

$(SHELL
The address of i                : 7FFF39BFEE78
The address of the result of ++i: 7FFF39BFEE78
)

$(P
I recommend that you observe the following guidelines when overloading operators for your own types:
)

$(UL

$(LI $(B Operators that modify the object)

$(P
With the exception of $(C opAssign), it is recommended that the operators that modify the object return the object itself. This guideline has been observed above with the $(C TimeOfDay.opOpAssign!$(STRING "+")) and $(C Duration.opUnary!$(STRING "++")).
)

$(P
The following two steps achieve returning the object itself:
)

$(OL

$(LI The return type is the type of the struct, marked by the $(C ref) keyword to mean $(I reference).
)

$(LI The function is exited by $$(C return this) to mean $(I return this object).
)

)

$(P
The operators that modify the object are $(C opUnary!$(STRING "++")), $(C opUnary!$(STRING "--")), and all of the $(C opOpAssign) overloads.
)

)

$(LI $(B Logical operators)

$(P
$(C opEquals) that represents both $(C ==) and $(C !=) must return $(C bool). Although the $(C in) operator normally returns $(I the contained object), it can simply return $(C bool) as well.
)

)

$(LI $(B Sort operators)

$(P
$(C opCmp) that represents $(C <), $(C <=), $(C >), and $(C >=) must return $(C int).
)

)

$(LI $(B Operators that make a new object)

$(P
Some operators must make and return a new object:
)

$(UL

$(LI Unary operators $(C -), $(C +), and $(C ~); and the binary operator $(C ~).)

$(LI Arithmetic operators $(C +), $(C -), $(C *), $(C /), $(C %), and $(C ^^).)

$(LI Bitwise operators $(C &), $(C |), $(C ^), $(C <<), $(C >>), and $(C >>>).)

$(LI As has been seen in the previous chapter, $(C opAssign) returns a copy of this object by $(C return this).

$(P $(I $(B Note:) As an optimization, sometimes it makes more sense for $(C opAssign) to return $(C const ref) for large structs. I will not apply this optimization in this book.))

)

)

$(P
As an example of an operator that makes a new object, let's define the $(C opBinary!$(STRING "+")) overload for $(C Duration). This operator should add two $(C Duration) objects to make and return a new one:
)

---
struct Duration {
    int minute;

    Duration opBinary(string op)(Duration rhs) const
            if (op == "+") {
        return Duration(minute + rhs.minute);  // new object
    }
}
---

$(P
That definition enables adding $(C Duration) objects by the $(C +) operator:
)

---
    auto travelDuration = Duration(10);
    auto returnDuration = Duration(11);
    Duration totalDuration;
    // ...
    totalDuration = travelDuration $(HILITE +) returnDuration;
---

$(P
The compiler replaces that expression with the following member function call on the $(C travelDuration) object:
)

---
    // the equivalent of the expression above:
    totalDuration =
        travelDuration.opBinary!"+"(returnDuration);
---

)

$(LI $(C opDollar)

$(P
Since it returns the number of elements of the container, the most suitable type for $(C opDollar) is $(C size_t). However, the return type can be other types as well (e.g. $(C int)).
)

)

$(LI $(B Unconstrained operators)

$(P
The return types of some of the operators depend entirely on the design of the user-defined type: The unary $(C *), $(C opCall), $(C opCast), $(C opDispatch), $(C opSlice), and all $(C opIndex) varieties.
)

)

)

$(H5 $(IX opEquals) $(C opEquals()) for equality comparisons)

$(P
This member function defines the behaviors of the $(C ==) and the $(C !=) operators.
)

$(P
The return type of $(C opEquals) is $(C bool).
)

$(P
For structs, the parameter of $(C opEquals) can be defined as $(C in). However, for speed efficiency $(C opEquals) can be defined as a template that takes $(C auto ref const) (also note the empty template parentheses below):
)

---
    bool opEquals$(HILITE ())(auto ref const TimeOfDay rhs) const {
        // ...
    }
---

$(P
As we have seen in $(LINK2 lvalue_rvalue.html, the Lvalues and Rvalues chapter), $(C auto ref) allows lvalues to be passed by reference and rvalues by copy. However, since rvalues are not copied, rather moved, the signature above is efficient for both lvalues and rvalues.
)

$(P
To reduce confusion, $(C opEquals) and $(C opCmp) must work consistently. For two objects that $(C opEquals) returns $(C true), $(C opCmp) must return zero.
)

$(P
Once $(C opEquals()) is defined for equality, the compiler uses its opposite for inequality:
)

---
    x == y;
    // the equivalent of the previous expression:
    x.opEquals(y);

    x != y;
    // the equivalent of the previous expression:
    !(x.opEquals(y));
---

$(P
Normally, it is not necessary to define $(C opEquals()) for structs. The compiler generates it for structs automatically. The automatically-generated $(C opEquals) compares all of the members individually.
)

$(P
Sometimes the equality of two objects must be defined differently from this automatic behavior. For example, some of the members may not be significant in this comparison, or the equality may depend on a more complex logic.
)

$(P
Just as an example, let's define $(C opEquals()) in a way that disregards the minute information altogether:
)

---
struct TimeOfDay {
    int hour;
    int minute;

    bool opEquals(TimeOfDay rhs) const {
        return hour == rhs.hour;
    }
}
// ...
    assert(TimeOfDay(20, 10) $(HILITE ==) TimeOfDay(20, 59));
---

$(P
Since the equality comparison considers the values of only the $(C hour) members, 20:10 and 20:59 end up being equal. (This is just an example; it should be clear that such an equality comparison would cause confusions.)
)

$(H5 $(IX opCmp) $(C opCmp()) for sorting)

$(P
Sort operators determine the sort orders of objects. All of the ordering operators $(C <), $(C <=), $(C >), and $(C >=) are covered by the $(C opCmp()) member function.
)

$(P
For structs, the parameter of $(C opCmp) can be defined as $(C in). However, as with $(C opEquals), it is more efficient to define $(C opCmp) as a template that takes $(C auto ref const):
)

---
    int opCmp$(HILITE ())(auto ref const TimeOfDay rhs) const {
        // ...
    }
---

$(P
To reduce confusion, $(C opEquals) and $(C opCmp) must work consistently. For two objects that $(C opEquals) returns $(C true), $(C opCmp) must return zero.
)

$(P
Let's assume that one of these four operators is used as in the following code:
)

---
    if (x $(I op) y) {  $(CODE_NOTE $(I op) is one of <, <=, >, or >=)
---

$(P
The compiler converts that expression to the following logical expression and uses the result of the new logical expression:
)

---
    if (x.opCmp(y) $(I op) 0) {
---

$(P
Let's consider the $(C <=) operator:
)

---
    if (x $(HILITE <=) y) {
---

$(P
The compiler generates the following code behind the scenes:
)

---
    if (x.opCmp(y) $(HILITE <=) 0) {
---

$(P
For the user-defined $(C opCmp()) to work correctly, this member function must return a result according to the following rules:
)

$(UL
$(LI $(I A negative value) if the left-hand object is considered to be before the right-hand object)
$(LI $(I A positive value) if the left-hand object is considered to be after the right-hand object)
$(LI $(I Zero) if the objects are considered to have the same sort order)
)

$(P
To be able to support those values, the return type of $(C opCmp()) must be $(C int), not $(C bool).
)

$(P
The following is a way of ordering $(C TimeOfDay) objects by first comparing the values of the $(C hour) members, and then comparing the values of the $(C minute) members (only if the $(C hour) members are equal):
)

---
    int opCmp(TimeOfDay rhs) const {
        /* Note: Subtraction is a bug here if the result can
         * overflow. (See the following warning in text.) */

        return (hour == rhs.hour
                ? minute - rhs.minute
                : hour - rhs.hour);
    }
---

$(P
That definition returns the difference between the $(C minute) values when the $(C hour) members are the same, and the difference between the $(C hour) members otherwise. The return value would be a $(I negative value) when the $(I left-hand) object comes before in chronological order, a $(I positive value) if the $(I right-hand) object is before, and $(I zero) when they represent exactly the same time of day.
)

$(P
$(B Warning:) Using subtraction for the implementation of $(C opCmp) is a bug if valid values of a member can cause overflow. For example, the two objects below would be sorted incorrectly as the object with value $(C -2) is calculated to be $(I greater) than the one with value $(C int.max):
)

---
struct S {
    int i;

    int opCmp(S rhs) const {
        return i - rhs.i;          $(CODE_NOTE_WRONG BUG)
    }
}

void main() {
    assert(S(-2) $(HILITE >) S(int.max));    $(CODE_NOTE_WRONG wrong sort order)
}
---

$(P
On the other hand, subtraction is acceptable for $(C TimeOfDay) because none of the valid values of the members of that $(C struct) can cause overflow in subtraction.
)

$(P
$(IX cmp, std.algorithm) $(IX lexicographical) You can use $(C std.algorithm.cmp) for comparing slices (including all string types and ranges). $(C cmp()) compares slices lexicographically and produces a negative value, zero, or positive value depending on their  order. That result can directly be used as the return value of $(C opCmp):
)

---
import std.algorithm;

struct S {
    string name;

    int opCmp(S rhs) const {
        return $(HILITE cmp)(name, rhs.name);
    }
}
---

$(P
Once $(C opCmp()) is defined, this type can be used with sorting algorithms like $(C std.algorithm.sort) as well. As $(C sort()) works on the elements, it is the $(C opCmp()) operator that gets called behind the scenes to determine their order. The following program constructs 10 objects with random values and sorts them with $(C sort()):
)

---
import std.random;
import std.stdio;
import std.string;
import std.algorithm;

struct TimeOfDay {
    int hour;
    int minute;

    int opCmp(TimeOfDay rhs) const {
        return (hour == rhs.hour
                ? minute - rhs.minute
                : hour - rhs.hour);
    }

    string toString() const {
        return format("%02s:%02s", hour, minute);
    }
}

void main() {
    TimeOfDay[] times;

    foreach (i; 0 .. 10) {
        times ~= TimeOfDay(uniform(0, 24), uniform(0, 60));
    }

    sort(times);

    writeln(times);
}
---

$(P
As expected, the elements are sorted from the earliest time to the latest time:
)

$(SHELL
[03:40, 04:10, 09:06, 10:03, 10:09, 11:04, 13:42, 16:40, 18:03, 21:08]
)

$(H5 $(IX opCall) $(IX ()) $(C opCall()) to call objects as functions)

$(P
The parentheses around the parameter list when calling functions are operators as well. We have already seen how $(C static opCall()) makes it possible to use the name of the $(I type) as a function. $(C static opCall()) allows creating objects with default values at run time.
)

$(P
Non-static $(C opCall()) on the other hand allows using the $(I objects) of user-defined types as functions:
)

---
    Foo foo;
    foo$(HILITE ());
---

$(P
The object $(C foo) above is being called like a function.
)

$(P
As an example, let's consider a $(C struct) that represents a linear equation. This $(C struct) will be used for calculating the $(I y) values of the following linear equation for specific $(I x) values:
)

$(MONO
    $(I y) = $(I a)$(I x) + $(I b)
)

$(P
The following $(C opCall()) simply calculates and returns the value of $(I y) according to that equation:
)

---
struct LinearEquation {
    double a;
    double b;

    double opCall(double x) const {
        return a * x + b;
    }
}
---

$(P
With that definition, each object of $(C LinearEquation) represents a linear equation for specific $(I a) and $(I b) values. Such an object can be used as a function that calculates the $(I y) values:
)

---
    LinearEquation equation = { 1.2, 3.4 };
    // the object is being used like a function:
    double y = equation(5.6);
---

$(P
$(I $(B Note:) Defining $(C opCall()) for a $(C struct) disables the compiler-generated automatic constructor. That is why the $(C {&nbsp;}) syntax is used above instead of the recommended $(C LinearEquation(1.2, 3.4)). When the latter syntax is desired, a $(C static opCall()) that takes two $(C double) parameters must also be defined.)
)

$(P
$(C equation) above represents the $(I y&nbsp;=&nbsp;1.2x&nbsp;+&nbsp;3.4) linear equation. Using that object as a function executes the $(C opCall()) member function.
)

$(P
This feature can be useful to define and store the $(I a) and $(I b) values in an object once and to use that object multiple times later on. The following code uses such an object in a loop:
)

---
    LinearEquation equation = { 0.01, 0.4 };

    for (double x = 0.0; x <= 1.0; x += 0.125) {
        writefln("%f: %f", x, equation(x));
    }
---

$(P
That object represents the $(I y&nbsp;=&nbsp;0.01x&nbsp;+&nbsp;0.4) equation. It is being used for calculating the results for $(I x) values in the range from 0.0 to 1.0.
)

$(H5 $(IX opIndex) $(IX opIndexAssign) $(IX opIndexUnary) $(IX opIndexOpAssign) $(IX opDollar) Indexing operators)

$(P
$(C opIndex), $(C opIndexAssign), $(C opIndexUnary), $(C opIndexOpAssign), and $(C opDollar) make it possible to use indexing operators on user-defined types similar to arrays as in $(C object[index]).
)

$(P
Unlike arrays, these operators support multi-dimensional indexing as well. Multiple index values are specified as a comma-separated list inside the square brackets (e.g. $(C object[index0, index1])). In the following examples we will use these operators only with a single dimension and cover their multi-dimensional uses in $(LINK2 templates_more.html, the More Templates chapter).
)

$(P
The $(C deque) variable in the following examples is an object of $(C struct DoubleEndedQueue), which we will define below; and $(C e) is a variable of type $(C int).
)

$(P
$(C opIndex) is for element access. The index that is specified inside the brackets becomes the parameter of the operator function:
)

---
    e = deque[3];                    // the element at index 3
    e = deque.opIndex(3);            // the equivalent of the above
---

$(P
$(C opIndexAssign) is for assigning to an element. The first parameter is the value that is being assigned and the second parameter is the index of the element:
)

---
    deque[5] = 55;                   // assign 55 to the element at index 5
    deque.opIndexAssign(55, 5);      // the equivalent of the above
---

$(P
$(C opIndexUnary) is similar to $(C opUnary). The difference is that the operation is applied to the element at the specified index:
)

---
    ++deque[4];                      // increment the element at index 4
    deque.opIndexUnary!"++"(4);      // the equivalent of the above
---

$(P
$(C opIndexOpAssign) is similar to $(C opOpAssign). The difference is that the operation is applied to an element:
)

---
    deque[6] += 66;                  // add 66 to the element at index 6
    deque.opIndexOpAssign!"+"(66, 6);// the equivalent of the above
---

$(P
$(C opDollar) defines the $(C $) character that is used during indexing and slicing. It is for returning the number of elements in the container:
)

---
    e = deque[$ - 1];                // the last element
    e = deque[deque.opDollar() - 1]; // the equivalent of the above
---

$(H6 Indexing operators example)

$(P
$(I Double-ended queue) is a data structure that is similar to arrays but it provides efficient insertion at the head of the collection as well. (In contrast, inserting at the head of an array is a relatively slow operation as it requires moving the existing elements to a newly created array.)
)

$(P
One way of implementing a double-ended queue is to use two arrays in the background but to use the first one in reverse. The element that is conceptually inserted at the head of the queue is actually appended to the $(I head) array. As a result, this operation is as efficient as appending to the end.
)

$(P
The following $(C struct) implements a double-ended queue that overloads the operators that we have seen in this section:
)

---
$(CODE_NAME DoubleEndedQueue)import std.stdio;
import std.string;
import std.conv;

$(CODE_COMMENT_OUT)struct DoubleEndedQueue // Also known as Deque
$(CODE_COMMENT_OUT){
private:

    /* The elements are represented as the chaining of the two
     * member slices. However, 'head' is indexed in reverse so
     * that the first element of the entire collection is
     * head[$-1], the second one is head[$-2], etc.:
     *
     * head[$-1], head[$-2], ... head[0], tail[0], ... tail[$-1]
     */
    int[] head;    // the first group of elements
    int[] tail;    // the second group of elements

    /* Determines the actual slice that the specified element
     * resides in and returns it as a reference. */
    ref inout(int) elementAt(size_t index) inout {
        return (index < head.length
                ? head[$ - 1 - index]
                : tail[index - head.length]);
    }

public:

    string toString() const {
        string result;

        foreach_reverse (element; head) {
            result ~= format("%s ", to!string(element));
        }

        foreach (element; tail) {
            result ~= format("%s ", to!string(element));
        }

        return result;
    }

    /* Note: As we will see in the next chapter, the following
     * is a simpler and more efficient implementation of
     * toString(): */
    version (none) {
        void toString(void delegate(const(char)[]) sink) const {
            import std.format;
            import std.range;

            formattedWrite(
                sink, "%(%s %)", chain(head.retro, tail));
        }
    }

    /* Adds a new element to the head of the collection. */
    void insertAtHead(int value) {
        head ~= value;
    }

    /* Adds a new element to the tail of the collection.
     *
     * Sample: deque ~= value
     */
    ref DoubleEndedQueue opOpAssign(string op)(int value)
            if (op == "~") {
        tail ~= value;
        return this;
    }

    /* Returns the specified element.
     *
     * Sample: deque[index]
     */
    inout(int) opIndex(size_t index) inout {
        return elementAt(index);
    }

    /* Applies a unary operation to the specified element.
     *
     * Sample: ++deque[index]
     */
    int opIndexUnary(string op)(size_t index) {
        mixin ("return " ~ op ~ "elementAt(index);");
    }

    /* Assigns a value to the specified element.
     *
     * Sample: deque[index] = value
     */
    int opIndexAssign(int value, size_t index) {
        return elementAt(index) = value;
    }

    /* Uses the specified element and a value in a binary
     * operation and assigns the result back to the same
     * element.
     *
     * Sample: deque[index] += value
     */
    int opIndexOpAssign(string op)(int value, size_t index) {
        mixin ("return elementAt(index) " ~ op ~ "= value;");
    }

    /* Defines the $ character, which is the length of the
     * collection.
     *
     * Sample: deque[$ - 1]
     */
    size_t opDollar() const {
        return head.length + tail.length;
    }
$(CODE_COMMENT_OUT)}

void $(CODE_DONT_TEST)main() {
    auto deque = DoubleEndedQueue();

    foreach (i; 0 .. 10) {
        if (i % 2) {
            deque.insertAtHead(i);

        } else {
            deque ~= i;
        }
    }

    writefln("Element at index 3: %s",
             deque[3]);    // accessing an element
    ++deque[4];            // incrementing an element
    deque[5] = 55;         // assigning to an element
    deque[6] += 66;        // adding to an element

    (deque ~= 100) ~= 200;

    writeln(deque);
}
---

$(P
According to the guidelines above, the return type of $(C opOpAssign) is $(C ref) so that the $(C ~=) operator can be chained on the same collection:
)

---
    (deque ~= 100) ~= 200;
---

$(P
As a result, both 100 and 200 get appended to the same collection:
)

$(SHELL
Element at index 3: 3
9 7 5 3 2 55 68 4 6 8 100 200 
)

$(H5 $(IX opSlice) Slicing operators)

$(P
$(C opSlice) allows slicing the objects of user-defined types with the $(C []) operator.
)

$(P
$(IX opSliceUnary) $(IX opSliceAssign) $(IX opSliceOpAssign) In addition to this operator, there are also $(C opSliceUnary), $(C opSliceAssign), and $(C opSliceOpAssign) but they are discouraged.
)

$(P
D supports multi-dimensional slicing. We will see a multi-dimensional example later in $(LINK2 templates_more.html, the More Templates chapter). Although the methods described in that chapter can be used for a single dimension as well, they do not match the indexing operators that are defined above and they involve templates which we have not covered yet. For that reason, we will see the non-templated use of $(C opSlice) in this chapter, which works only with a single dimension. (This use of $(C opSlice) is discouraged as well.)
)

$(P
$(C opSlice) has two distinct forms:
)

$(UL

$(LI The square brackets can be empty as in $(C deque[]) to mean $(I all elements).)

$(LI The square brackets can contain a number range as in $(C deque[begin..end]) to mean $(I the elements in the specified range).)

)

$(P
The slicing operators are relatively more complex than other operators because they involve two distinct concepts: $(I container) and $(I range). We will see these concepts in more detail in later chapters.
)

$(P
In single-dimensional slicing which does not use templates, $(C opSlice) returns an object that represents a specific range of elements of the container. The object that $(C opSlice) returns is responsible for defining the operations that are applied on that range elements. For example, behind the scenes the following expression is executed by first calling $(C opSlice) to obtain a range object and then applying $(C opOpAssign!$(STRING "*")) on that object:
)

---
    deque[] *= 10;    // multiply all elements by 10

    // The equivalent of the above:
    {
        auto range = deque.opSlice();
        range.opOpAssign!"*"(10);
    }
---

$(P
Accordingly, the $(C opSlice) operators of $(C DoubleEndedQueue) return a special $(C Range) object so that the operations are applied to it:
)

---
import std.exception;

struct DoubleEndedQueue {
// ...

    /* Returns a range that represents all of the elements.
     * ('Range' struct is defined below.)
     *
     * Sample: deque[]
     */
    inout(Range) $(HILITE opSlice)() inout {
        return inout(Range)(head[], tail[]);
    }

    /* Returns a range that represents some of the elements.
     *
     * Sample: deque[begin .. end]
     */
    inout(Range) $(HILITE opSlice)(size_t begin, size_t end) inout {
        enforce(end <= opDollar());
        enforce(begin <= end);

        /* Determine what parts of 'head' and 'tail'
         * correspond to the specified range: */

        if (begin < head.length) {
            if (end < head.length) {
                /* The range is completely inside 'head'. */
                return inout(Range)(
                    head[$ - end .. $ - begin],
                    []);

            } else {
                /* Some part of the range is inside 'head' and
                 * the rest is inside 'tail'. */
                return inout(Range)(
                    head[0 .. $ - begin],
                    tail[0 .. end - head.length]);
            }

        } else {
            /* The range is completely inside 'tail'. */
            return inout(Range)(
                [],
                tail[begin - head.length .. end - head.length]);
        }
    }

    /* Represents a range of elements of the collection. This
     * struct is responsible for defining the opUnary,
     * opAssign, and opOpAssign operators. */
    struct $(HILITE Range) {
        int[] headRange;    // elements that are in 'head'
        int[] tailRange;    // elements that are in 'tail'

        /* Applies the unary operation to the elements of the
         * range. */
        Range opUnary(string op)() {
            mixin (op ~ "headRange[];");
            mixin (op ~ "tailRange[];");
            return this;
        }

        /* Assigns the specified value to each element of the
         * range. */
        Range opAssign(int value) {
            headRange[] = value;
            tailRange[] = value;
            return this;
        }

        /* Uses each element and a value in a binary operation
         * and assigns the result back to that element. */
        Range opOpAssign(string op)(int value) {
            mixin ("headRange[] " ~ op ~ "= value;");
            mixin ("tailRange[] " ~ op ~ "= value;");
            return this;
        }
    }
$(CODE_XREF DoubleEndedQueue)}

void $(CODE_DONT_TEST)main() {
    auto deque = DoubleEndedQueue();

    foreach (i; 0 .. 10) {
        if (i % 2) {
            deque.insertAtHead(i);

        } else {
            deque ~= i;
        }
    }

    writeln(deque);
    deque$(HILITE []) *= 10;
    deque$(HILITE [3 .. 7]) = -1;
    writeln(deque);
}
---

$(P
The output:
)

$(SHELL
9 7 5 3 1 0 2 4 6 8 
90 70 50 -1 -1 -1 -1 40 60 80 
)

$(H5 $(IX opCast) $(IX type conversion, opCast) $(C opCast) for type conversions)

$(P
$(C opCast) defines explicit type conversions. It can be overloaded separately for each target type. As you would remember from the earlier chapters, explicit type conversions are performed by the $(C to) function and the $(C cast) operator.
)

$(P
$(C opCast) is a template as well, but it has a different format: The target type is specified by the $(C (T&nbsp;:&nbsp;target_type)) syntax:
)

---
    $(I target_type) opCast(T : $(I target_type))() {
        // ...
    }
---

$(P
This syntax will become clear later after the templates chapter as well.
)

$(P
Let's change the definition of $(C Duration) so that it now has two members: hours and minutes. The operator that converts objects of this type to $(C double) can be defined as in the following code:
)

---
import std.stdio;
import std.conv;

struct Duration {
    int hour;
    int minute;

    double opCast(T : double)() const {
        return hour + (to!double(minute) / 60);
    }
}

void main() {
    auto duration = Duration(2, 30);
    double d = to!double(duration);
    // (could be 'cast(double)duration' as well)

    writeln(d);
}
---

$(P
The compiler replaces the type conversion call above with the following one:
)

---
    double d = duration.opCast!double();
---

$(P
The $(C double) conversion function above produces 2.5 for two hours and thirty minutes:
)

$(SHELL
2.5
)

$(P
$(IX opCast!bool) $(IX bool, opCast) Although $(C opCast) is for explicit type conversions, its $(C bool) specialization is called automatically when the variable is used in a logical expression:
)

---
struct Duration {
// ...

    bool opCast($(HILITE T : bool))() const {
        return (hour != 0) || (minute != 0);
    }
}

// ...

    if (duration) {               // compiles
        // ...
    }

    while (duration) {            // compiles
        // ...
    }

    auto r = duration ? 1 : 2;    // compiles
---

$(P
Still, the $(C bool) specialization of $(C opCast) is not for all implicit $(C bool) conversions:
)

---
void foo(bool b) {
    // ...
}

// ...

    foo(duration);                $(DERLEME_HATASI)
    bool b = duration;            $(DERLEME_HATASI)
---

$(SHELL
Error: cannot implicitly convert expression (duration) of type Duration to
bool
Error: function deneme.foo (bool b) is not callable using argument types
(Duration)
)

$(H5 $(IX opDispatch) Catch-all operator $(C opDispatch))

$(P
$(C opDispatch) gets called whenever a $(I missing) member of an object is accessed. All attempts to access non-existent members are dispatched to this function.
)

$(P
The name of the missing member becomes the template parameter value of $(C opDispatch).
)

$(P
The following code demonstrates a simple definition:
)

---
import std.stdio;

struct Foo {
    void opDispatch(string name, T)(T parameter) {
        writefln("Foo.opDispatch - name: %s, value: %s",
                 name, parameter);
    }
}

void main() {
    Foo foo;
    foo.aNonExistentFunction(42);
    foo.anotherNonExistentFunction(100);
}
---

$(P
There are no compiler errors for the calls to non-existent members. Instead, all of those calls are dispatched to $(C opDispatch). The first template parameter is the name of the member. The parameter values that are used when calling the function appear as the parameters of $(C opDispatch):
)

$(SHELL
Foo.opDispatch - name: aNonExistentFunction, value: 42
Foo.opDispatch - name: anotherNonExistentFunction, value: 100
)

$(P
The $(C name) template parameter can be used inside the function to make decisions on how the call to that specific non-existent function should be handled:
)

---
   switch (name) {
       // ...
   }
---

$(H5 $(IX in, operator overloading) $(IX !in) Inclusion query by $(C opBinaryRight!"in"))

$(P
This operator allows defining the behavior of the $(C in) operator for user-defined types. $(C in) is commonly used with associative arrays to determine whether a value for a specific key exists in the array.
)

$(P
Different from other operators, this operator is normally overloaded for the case where the object appears on the right-hand side:
)

---
        if (time in lunchBreak) {
---

$(P
The compiler would use $(C opBinaryRight) behind the scenes:
)

---
        // the equivalent of the above:
        if (lunchBreak.opBinaryRight!"in"(time)) {
---

$(P
There is also $(C !in) to determine whether a value for a specific key $(I does not) exist in the array:
)

---
        if (a !in b) {
---

$(P
$(C !in) cannot be overloaded because the compiler uses the negative of the result of the $(C in) operator instead:
)

---
        if (!(a in b)) {    // the equivalent of the above
---

$(H6 Example of the $(C in) operator)

$(P
The following program defines a $(C TimeSpan) type in addition to $(C Duration) and $(C TimeOfDay). The $(C in) operator that is defined for $(C TimeSpan) determines whether a moment in time is within that time span.
)

$(P
To keep the code short, the following program defines only the necessary member functions.
)

$(P
Note how the $(C TimeOfDay) object is used seamlessly in the $(C for) loop. That loop is a demonstration of how useful operator overloading can be.
)

---
import std.stdio;
import std.string;

struct Duration {
    int minute;
}

struct TimeOfDay {
    int hour;
    int minute;

    ref TimeOfDay opOpAssign(string op)(Duration duration)
            if (op == "+") {
        minute += duration.minute;

        hour += minute / 60;
        minute %= 60;
        hour %= 24;

        return this;
    }

    int opCmp(TimeOfDay rhs) const {
        return (hour == rhs.hour
                ? minute - rhs.minute
                : hour - rhs.hour);
    }

    string toString() const {
        return format("%02s:%02s", hour, minute);
    }
}

struct TimeSpan {
    TimeOfDay begin;
    TimeOfDay end;    // end is outside of the span

    bool opBinaryRight(string op)(TimeOfDay time) const
            if (op == "in") {
        return (time >= begin) && (time < end);
    }
}

void main() {
    auto lunchBreak = TimeSpan(TimeOfDay(12, 00),
                               TimeOfDay(13, 00));

    for (auto time = TimeOfDay(11, 30);
         time < TimeOfDay(13, 30);
         time += Duration(15)) {

        if (time in lunchBreak) {
            writeln(time, " is during the lunch break");

        } else {
            writeln(time, " is outside of the lunch break");
        }
    }
}
---

$(P
The output:
)

$(SHELL
11:30 is outside of the lunch break
11:45 is outside of the lunch break
12:00 is during the lunch break
12:15 is during the lunch break
12:30 is during the lunch break
12:45 is during the lunch break
13:00 is outside of the lunch break
13:15 is outside of the lunch break
)

$(PROBLEM_TEK

$(P
Define a fraction type that stores its numerator and denominator as members of type $(C long). Such a type may be useful because it does not lose value like $(C float), $(C double), and $(C real) do due to their precisions. For example, although the result of multiplying a $(C double) value of 1.0/3 by 3 is $(I not) 1.0, multiplying a $(C Fraction) object that represents the fraction 1/3 by 3 would be exactly 1:
)

---
struct Fraction {
    long num;  // numerator
    long den;  // denominator

    /* As a convenience, the constructor uses the default
     * value of 1 for the denominator. */
    this(long num, long den = 1) {
        enforce(den != 0, "The denominator cannot be zero");

        this.num = num;
        this.den = den;

        /* Ensuring that the denominator is always positive
         * will simplify the definitions of some of the
         * operator functions. */
        if (this.den < 0) {
            this.num = -this.num;
            this.den = -this.den;
        }
    }

    /* ... you define the operator overloads ... */
}
---

$(P
Define operators as needed for this type to make it a convenient type as close to fundamental types as possible. Ensure that the definition of the type passes all of the following unit tests. The unit tests ensure the following behaviors:
)

$(UL

$(LI An exception must be thrown when constructing an object with zero denominator. (This is already taken care of by the $(C enforce) expression above.))

$(LI Producing the negative of the value: For example, the negative of 1/3 should be -1/3 and negative of -2/5 should be 2/5.)

$(LI Incrementing and decrementing the value by $(C ++) and $(C --).)

$(LI Support for four arithmetic operations: Both modifying the value of an object by $(C +=), $(C -=), $(C *=), and $(C /=); and producing the result of using two objects with the $(C +), $(C -), $(C *), and $(C /) operators. (Similar to the constructor, dividing by zero should be prevented.)

$(P
As a reminder, here are the formulas of arithmetic operations that involve two fractions a/b and c/d:
)

$(UL
$(LI Addition: a/b + c/d = (a*d + c*b)/(b*d))
$(LI Subtraction: a/b - c/d = (a*d - c*b)/(b*d))
$(LI Multiplication: a/b * c/d = (a*c)/(b*d))
$(LI Division: (a/b) / (c/d) = (a*d)/(b*c))
)

)

$(LI The actual (and necessarily lossful) value of the object can be converted to $(C double).)

$(LI Sort order and equality comparisons are performed by the actual values of the fractions, not by the values of the numerators and denominators. For example, the fractions 1/3 and 20/60 must be considered to be equal.
)

)

---
unittest {
    /* Must throw when denominator is zero. */
    assertThrown(Fraction(42, 0));

    /* Let's start with 1/3. */
    auto a = Fraction(1, 3);

    /* -1/3 */
    assert(-a == Fraction(-1, 3));

    /* 1/3 + 1 == 4/3 */
    ++a;
    assert(a == Fraction(4, 3));

    /* 4/3 - 1 == 1/3 */
    --a;
    assert(a == Fraction(1, 3));

    /* 1/3 + 2/3 == 3/3 */
    a += Fraction(2, 3);
    assert(a == Fraction(1));

    /* 3/3 - 2/3 == 1/3 */
    a -= Fraction(2, 3);
    assert(a == Fraction(1, 3));

    /* 1/3 * 8 == 8/3 */
    a *= Fraction(8);
    assert(a == Fraction(8, 3));

    /* 8/3 / 16/9 == 3/2 */
    a /= Fraction(16, 9);
    assert(a == Fraction(3, 2));

    /* Must produce the equivalent value in type 'double'.
     *
     * Note that although double cannot represent every value
     * precisely, 1.5 is an exception. That is why this test
     * is being applied at this point. */
    assert(to!double(a) == 1.5);

    /* 1.5 + 2.5 == 4 */
    assert(a + Fraction(5, 2) == Fraction(4, 1));

    /* 1.5 - 0.75 == 0.75 */
    assert(a - Fraction(3, 4) == Fraction(3, 4));

    /* 1.5 * 10 == 15 */
    assert(a * Fraction(10) == Fraction(15, 1));

    /* 1.5 / 4 == 3/8 */
    assert(a / Fraction(4) == Fraction(3, 8));

    /* Must throw when dividing by zero. */
    assertThrown(Fraction(42, 1) / Fraction(0));

    /* The one with lower numerator is before. */
    assert(Fraction(3, 5) < Fraction(4, 5));

    /* The one with larger denominator is before. */
    assert(Fraction(3, 9) < Fraction(3, 8));
    assert(Fraction(1, 1_000) > Fraction(1, 10_000));

    /* The one with lower value is before. */
    assert(Fraction(10, 100) < Fraction(1, 2));

    /* The one with negative value is before. */
    assert(Fraction(-1, 2) < Fraction(0));
    assert(Fraction(1, -2) < Fraction(0));

    /* The ones with equal values must be both <= and >=. */
    assert(Fraction(-1, -2) <= Fraction(1, 2));
    assert(Fraction(1, 2) <= Fraction(-1, -2));
    assert(Fraction(3, 7) <= Fraction(9, 21));
    assert(Fraction(3, 7) >= Fraction(9, 21));

    /* The ones with equal values must be equal. */
    assert(Fraction(1, 3) == Fraction(20, 60));

    /* The ones with equal values with sign must be equal. */
    assert(Fraction(-1, 2) == Fraction(1, -2));
    assert(Fraction(1, 2) == Fraction(-1, -2));
}
---

)

Macros:
        TITLE=Operator Overloading

        DESCRIPTION=The operator overloading feature of the D programming language that makes user-defined types as convenient as fundamental types.

        KEYWORDS=d programming lesson book tutorial operator overloading
