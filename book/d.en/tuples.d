Ddoc

$(DERS_BOLUMU $(IX tuple) $(IX Tuple, std.typecons) Tuples)

$(P
Tuples are for combining multiple values to be used as a single object. They are implemented as a library feature by the $(C Tuple) template from the $(C std.typecons) module.
)

$(P
$(C Tuple) makes use of $(C AliasSeq) from the $(C std.meta) module for some of its operations.
)

$(P
This chapter covers only the more common operations of tuples. For more information on tuples and templates see $(LINK2 https://github.com/PhilippeSigaud/D-templates-tutorial, Philippe Sigaud's $(I D Templates: A Tutorial)).
)

$(H5 $(C Tuple) and $(C tuple()))

$(P
Tuples are usually constructed by the convenience function $(C tuple()):
)

---
import std.stdio;
import std.typecons;

void main() {
    auto t = $(HILITE tuple(42, "hello"));
    writeln(t);
}
---

$(P
The $(C tuple) call above constructs an object that consists of the $(C int) value 42 and the $(C string) value $(STRING "hello"). The output of the program includes the type of the tuple object and its members:
)

$(SHELL
Tuple!(int, string)(42, "hello")
)

$(P
The tuple type above is the equivalent of the following pseudo $(C struct) definition and likely have been implemented in exactly the same way:
)

---
// The equivalent of Tuple!(int, string)
struct __Tuple_int_string {
    int __member_0;
    string __member_1;
}
---

$(P
The members of a tuple are normally accessed by their index values. That syntax suggests that tuples can be seen as arrays consisting of different types of elements:
)

---
    writeln(t$(HILITE [0]));
    writeln(t$(HILITE [1]));
---

$(P
The output:
)

$(SHELL
42
hello
)

$(H6 Member properties)

$(P
It is possible to access the members by properties if the tuple is constructed directly by the $(C Tuple) template instead of the $(C tuple()) function. The type and the name of each member are specified as two consecutive template parameters:
)

---
    auto t = Tuple!(int, "number",
                    string, "message")(42, "hello");
---

$(P
The definition above allows accessing the members by $(C .number) and $(C .message) properties as well:
)

---
    writeln("by index 0 : ", t[0]);
    writeln("by .number : ", t$(HILITE .number));
    writeln("by index 1 : ", t[1]);
    writeln("by .message: ", t$(HILITE .message));
---

$(P
The output:
)

$(SHELL
by index 0 : 42
by .number : 42
by index 1 : hello
by .message: hello
)

$(H6 $(IX .expand) Expanding the members as a list of values)

$(P
Tuple members can be expanded as a list of values that can be used e.g. as an argument list when calling a function. The members can be expanded either by the $(C .expand) property or by slicing:
)

---
import std.stdio;
import std.typecons;

void foo(int i, string s, double d, char c) {
    // ...
}

void bar(int i, double d, char c) {
    // ...
}

void main() {
    auto t = tuple(1, "2", 3.3, '4');

    // Both of the following lines are equivalents of
    // foo(1, "2", 3.3, '4'):
    foo(t$(HILITE .expand));
    foo(t$(HILITE []));

    // The equivalent of bar(1, 3.3, '4'):
    bar(t$(HILITE [0]), t$(HILITE [$-2..$]));
}
---

$(P
The tuple above consists of four values of $(C int), $(C string), $(C double), and $(C char). Since those types match the parameter list of $(C foo()), an expansion of its members can be used as arguments to $(C foo()). When calling $(C bar()), a matching argument list is made up of the first member and the last two members of the tuple.
)

$(P
As long as the members are compatible to be elements of the same array, the expansion of a tuple can be used as the element values of an array literal as well:
)

---
import std.stdio;
import std.typecons;

void main() {
    auto t = tuple(1, 2, 3);
    auto a = [ t.expand, t[] ];
    writeln(a);
}
---

$(P
The array literal above is initialized by expanding the same tuple twice:
)

$(SHELL
[1, 2, 3, 1, 2, 3]
)

$(H6 $(IX foreach, compile-time) $(IX compile-time foreach) Compile-time $(C foreach))

$(P
Because their values can be expanded, tuples can be used with the $(C foreach) statement as well:
)

---
    auto t = tuple(42, "hello", 1.5);

    foreach (i, member; $(HILITE t)) {
        writefln("%s: %s", i, member);
    }
---

$(P
The output:
)

$(SHELL
0: 42
1: hello
2: 1.5
)

$(P
$(IX unroll)
The $(C foreach) statement above may give a false impression: It may be thought of being a loop that gets executed at run time. That is not the case. Rather, a $(C foreach) statement that operates on the members of a tuple is an $(I unrolling) of the loop body for each member. The $(C foreach) statement above is the equivalent of the following code:
)

---
    {
        enum size_t i = 0;
        $(HILITE int) member = t[i];
        writefln("%s: %s", i, member);
    }
    {
        enum size_t i = 1;
        $(HILITE string) member = t[i];
        writefln("%s: %s", i, member);
    }
    {
        enum size_t i = 2;
        $(HILITE double) member = t[i];
        writefln("%s: %s", i, member);
    }
---

$(P
The reason for the unrolling is the fact that when the tuple members are of different types, the $(C foreach) body has to be compiled differently for each type.
)

$(P
We will see $(C static foreach), a more powerful loop unrolling feature, in $(LINK2 static_foreach.html, a later chapter).
)

$(H6 Returning multiple values from functions)

$(P
$(IX findSplit, std.algorithm) Tuples can be a simple solution to the limitation of functions having to return a single value. An example of this is $(C std.algorithm.findSplit). $(C findSplit()) searches for a range inside another range and produces a result consisting of three pieces: the part before the found range, the found range, and the part after the found range:
)

---
import std.algorithm;

// ...

    auto entireRange = "hello";
    auto searched = "ll";

    auto result = findSplit(entireRange, searched);

    writeln("before: ", result[0]);
    writeln("found : ", result[1]);
    writeln("after : ", result[2]);
---

$(P
The output:
)

$(SHELL
before: he
found : ll
after : o
)

$(P
Another option for returning multiple values from a function is to return a $(C struct) object:
)

---
struct Result {
    // ...
}

$(HILITE Result) foo() {
    // ...
}
---

$(H5 $(IX AliasSeq, std.meta) $(C AliasSeq))

$(P
$(C AliasSeq) is defined in the $(C std.meta) module. It is used for representing a concept that is normally used by the compiler but otherwise not available to the programmer as an entity: A comma-separated list of values, types, and symbols (i.e. $(C alias) template arguments). The following are three examples of such lists:
)

$(UL
$(LI Function argument list)
$(LI Template argument list)
$(LI Array literal element list)
)

$(P
The following three lines of code are examples of those lists in the same order:
)

---
    foo($(HILITE 1, "hello", 2.5));         // function arguments
    auto o = Bar!($(HILITE char, long))();  // template arguments
    auto a = [ $(HILITE 1, 2, 3, 4) ];      // array literal elements
---

$(P
$(C Tuple) takes advantage of $(C AliasSeq) when expanding its members.
)

$(P
$(IX TypeTuple, std.typetuple) The name $(C AliasSeq) comes from "alias sequence" and it can contain types, values, and symbols. ($(C AliasSeq) and $(C std.meta) used to be called $(C TypeTuple) and $(C std.typetuple), respectively.)
)

$(P
This chapter includes $(C AliasSeq) examples that consist only of types or only of values. Examples of its use with both types and values will appear in the next chapter. $(C AliasSeq) is especially useful with variadic templates, which we will see in the next chapter as well.
)

$(H6 $(C AliasSeq) consisting of values)

$(P
The values that an $(C AliasSeq) represents are specified as its template arguments.
)

$(P
Let's imagine a function that takes three parameters:
)

---
import std.stdio;

void foo($(HILITE int i, string s, double d)) {
    writefln("foo is called with %s, %s, and %s.", i, s, d);
}
---

$(P
That function would normally be called with three arguments:
)

---
    foo(1, "hello", 2.5);
---

$(P
$(C AliasSeq) can combine those arguments as a single entity and can automatically be expanded when calling functions:
)

---
import std.meta;

// ...

    alias arguments = AliasSeq!(1, "hello", 2.5);
    foo($(HILITE arguments));
---

$(P
Although it looks like the function is now being called with a single argument, the $(C foo()) call above is the equivalent of the previous one. As a result, both calls produce the same output:
)

$(SHELL
foo is called with 1, hello, and 2.5.
)

$(P
Also note that $(C arguments) is not defined as a variable, e.g. with $(C auto). Rather, it is an $(C alias) of a specific $(C AliasSeq) instance. Although it is possible to define variables of $(C AliasSeq)s as well, the examples in this chapter will use them only as aliases.
)

$(P
As we have seen above with $(C Tuple), when the values are compatible to be elements of the same array, an $(C AliasSeq) can be used to initialize an array literal as well:
)

---
    alias elements = AliasSeq!(1, 2, 3, 4);
    auto arr = [ $(HILITE elements) ];
    assert(arr == [ 1, 2, 3, 4 ]);
---

$(H6 Indexing and slicing)

$(P
Same with $(C Tuple), the members of an $(C AliasSeq) can be accessed by indexes and slices:
)

---
    alias arguments = AliasSeq!(1, "hello", 2.5);
    assert(arguments$(HILITE [0]) == 1);
    assert(arguments$(HILITE [1]) == "hello");
    assert(arguments$(HILITE [2]) == 2.5);
---

$(P
Let's assume there is a function with parameters matching the last two members of the $(C AliasSeq) above. That function can be called with a slice of just the last two members of the $(C AliasSeq):
)

---
void bar(string s, double d) {
    // ...
}

// ...

    bar(arguments$(HILITE [$-2 .. $]));
---

$(H6 $(C AliasSeq) consisting of types)

$(P
Members of an $(C AliasSeq) can consist of types. In other words, not a specific value of a specific type but a type like $(C int) itself. An $(C AliasSeq) consisting of types can represent template arguments.
)

$(P
Let's use an $(C AliasSeq) with a $(C struct) template that has two parameters. The first parameter of this template determines the element type of a member array and the second parameter determines the return value of a member function:
)

---
import std.conv;

struct S($(HILITE ElementT, ResultT)) {
    ElementT[] arr;

    ResultT length() {
        return to!ResultT(arr.length);
    }
}

void main() {
    auto s = S!$(HILITE (double, int))([ 1, 2, 3 ]);
    auto l = s.length();
}
---

$(P
In the code above, we see that the template is instantiated with $(C (double, int)). An $(C AliasSeq) can represent the same argument list as well:
)

---
import std.meta;

// ...

    alias Types = AliasSeq!(double, int);
    auto s = S!$(HILITE Types)([ 1, 2, 3 ]);
---

$(P
Although it appears to be a single template argument, $(C Types) gets expanded automatically and the template instantiation becomes $(C S!(double,&nbsp;int)) as before.
)

$(P
$(C AliasSeq) is especially useful in $(I variadic templates). We will see examples of this in the next chapter.
)

$(H6 $(C foreach) with $(C AliasSeq))

$(P
Same with $(C Tuple), the $(C foreach) statement operating on an $(C AliasSeq) is not a run time loop. Rather, it is the unrolling of the loop body for each member.
)

$(P
Let's see an example of this with a unit test written for the $(C S) struct that was defined above. The following code tests $(C S) for element types $(C int), $(C long), and $(C float) ($(C ResultT) is always $(C size_t) in this example):
)

---
unittest {
    alias Types = AliasSeq!($(HILITE int, long, float));

    foreach (Type; $(HILITE Types)) {
        auto s = S!(Type, size_t)([ Type.init, Type.init ]);
        assert(s.length() == 2);
    }
}
---

$(P
The $(C foreach) variable $(C Type) corresponds to $(C int), $(C long), and $(C float), in that order. As a result, the $(C foreach) statement gets compiled as the equivalent of the code below:
)

---
    {
        auto s = S!($(HILITE int), size_t)([ $(HILITE int).init, $(HILITE int).init ]);
        assert(s.length() == 2);
    }
    {
        auto s = S!($(HILITE long), size_t)([ $(HILITE long).init, $(HILITE long).init ]);
        assert(s.length() == 2);
    }
    {
        auto s = S!($(HILITE float), size_t)([ $(HILITE float).init, $(HILITE float).init ]);
        assert(s.length() == 2);
    }
---

$(H5 $(IX .tupleof) $(C .tupleof) property)

$(P
$(C .tupleof) represents the members of a type or an object. When applied to a user-defined type, $(C .tupleof) provides access to the definitions of the members of that type:
)

---
import std.stdio;

struct S {
    int number;
    string message;
    double value;
}

void main() {
    foreach (i, MemberType; typeof($(HILITE S.tupleof))) {
        writefln("Member %s:", i);
        writefln("  type: %s", MemberType.stringof);

        string name = $(HILITE S.tupleof)[i].stringof;
        writefln("  name: %s", name);
    }
}
---

$(P
$(C S.tupleof) appears in two places in the program. First, the types of the elements are obtained by applying $(C typeof) to $(C .tupleof) so that each type appears as the $(C MemberType) variable. Second, the name of the member is obtained by $(C S.tupleof[i].stringof).
)

$(SHELL
Member 0:
  type: int
  name: number
Member 1:
  type: string
  name: message
Member 2:
  type: double
  name: value
)

$(P
$(C .tupleof) can be applied to an object as well. In that case, it produces a tuple consisting of the values of the members of the object:
)

---
    auto object = S(42, "hello", 1.5);

    foreach (i, member; $(HILITE object.tupleof)) {
        writefln("Member %s:", i);
        writefln("  type : %s", typeof(member).stringof);
        writefln("  value: %s", member);
    }
---

$(P
The $(C foreach) variable $(C member) represents each member of the object:
)

$(SHELL
Member 0:
  type : int
  value: 42
Member 1:
  type : string
  value: hello
Member 2:
  type : double
  value: 1.5
)

$(P
Here, an important point to make is that the tuple that $(C .tupleof) returns consists of the members of the object themselves, not their copies. In other words, the tuple members are references to the actual object members.
)

$(H5 Summary)

$(UL

$(LI $(C tuple()) combines different types of values similar to a $(C struct) object.)

$(LI Explicit use of $(C Tuple) allows accessing the members by properties.)

$(LI The members can be expanded as a value list by $(C .expand) or by slicing.)

$(LI $(C foreach) with a tuple is not a run time loop; rather, it is a loop unrolling.)

$(LI $(C AliasSeq) represents concepts like function argument list, template argument list, array literal element list, etc.)

$(LI $(C AliasSeq) can consist of values and types.)

$(LI Tuples support indexing and slicing.)

$(LI $(C .tupleof) provides information about the members of types and objects.)

)

macros:
        TITLE=Tuples

        DESCRIPTION=Combining values and types to be able to access them as members of the same object.

        KEYWORDS=d programming language tutorial book Tuple AliasSeq tuple
