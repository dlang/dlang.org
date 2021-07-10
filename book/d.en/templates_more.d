Ddoc

$(DERS_BOLUMU $(IX template) More Templates)

$(P
We have seen the power and convenience of templates in $(LINK2 templates.html, the Templates chapter). A single templated definition of an algorithm or a data structure is sufficient to use that definition for multiple types.
)

$(P
That chapter covered only the most common uses of templates: function, $(C struct), and $(C class) templates and their uses  with $(I type) template parameters. In this chapter we will see templates in more detail. Before going further, I recommend that you review at least the summary section of that chapter.
)

$(H5 $(IX shortcut syntax, template) The shortcut syntax)

$(P
In addition to being powerful, D templates are easy to define and use and they are very readable. Defining a function, $(C struct), or $(C class) template is as simple as providing a template parameter list:
)

---
T twice$(HILITE (T))(T value) {
    return 2 * value;
}

class Fraction$(HILITE (T)) {
    T numerator;
    T denominator;

    // ...
}
---

$(P
Template definitions like the ones above are taking advantage of D's shortcut template syntax.
)

$(P
In their full syntax, templates are defined by the $(C template) keyword. The equivalents of the two template definitions above are the following:
)

---
template twice$(HILITE (T)) {
    T twice(T value) {
        return 2 * value;
    }
}

template Fraction$(HILITE (T)) {
    class Fraction {
        T numerator;
        T denominator;

        // ...
    }
}
---

$(P
Although most templates are defined by the shortcut syntax, the compiler always uses the full syntax. We can imagine the compiler applying the following steps to convert a shortcut syntax to its full form behind the scenes:
)

$(OL
$(LI Wrap the definition with a template block.)
$(LI Give the same name to that block.)
$(LI Move the template parameter list to the template block.)
)

$(P
The full syntax that is arrived after those steps is called an $(I eponymous template), which the programmer can define explicitly as well. We will see eponymous templates later below.
)

$(H6 $(IX name space, template) Template name space)

$(P
It is possible to have more than one definition inside a template block. The following template contains both a function and a $(C struct) definition:
)

---
template MyTemplate(T) {
    T foo(T value) {
        return value / 3;
    }

    struct S {
        T member;
    }
}
---

$(P
Instantiating the template for a specific type instantiates all of the definitions inside the block. The following code instantiates the template for $(C int) and $(C double):
)

---
    auto result = $(HILITE MyTemplate!int).foo(42);
    writeln(result);

    auto s = $(HILITE MyTemplate!double).S(5.6);
    writeln(s.member);
---

$(P
A specific instantiation of a template introduces a $(I name space). The definitions that are inside an instantiation can be used by that name. However, if these names are too long, it is always possible to use aliases as we have seen in $(LINK2 alias.html, the $(C alias) chapter):
)

---
    alias MyStruct = MyTemplate!dchar.S;

// ...

    auto o = $(HILITE MyStruct)('a');
    writeln(o.member);
---

$(H6 $(IX eponymous template) Eponymous templates)

$(P
Eponymous templates are $(C template) blocks that contain a definition that has the same name as that block. In fact, each shortcut template syntax is the shortcut of an eponymous template.
)

$(P
As an example, assume that a program needs to qualify types that are larger than 20 bytes as $(I too large). Such a qualification can be achieved by a constant $(C bool) value inside a template block:
)

---
template isTooLarge(T) {
    enum isTooLarge = T.sizeof > 20;
}
---

$(P
Note how the names of both the template block and its only definition are the same. This eponymous template is used by the shortcut syntax instead of the whole $(C isTooLarge!int.isTooLarge):
)

---
    writeln($(HILITE isTooLarge!int));
---

$(P
The highlighted part above is the same as the $(C bool) value inside the block. Since the size of $(C int) is less than 20, the output of the code would be $(C false).
)

$(P
That eponymous template can be defined by the shortcut syntax as well:
)

---
enum isTooLarge$(HILITE (T)) = T.sizeof > 20;
---

$(P
A common use of eponymous templates is defining type aliases depending on certain conditions. For example, the following eponymous template picks the larger of two types by setting an alias to it:
)

---
$(CODE_NAME LargerOf)template LargerOf(A, B) {
    static if (A.sizeof < B.sizeof) {
        alias LargerOf = B;

    } else {
        alias LargerOf = A;
    }
}
---

$(P
Since $(C long) is larger than $(C int) (8 bytes versus 4 bytes), $(C LargerOf!(int, long)) would be the same as the type $(C long). Such templates are especially useful in other templates where the two types are template parameters themselves (or depend on template parameters):
)

---
$(CODE_XREF LargerOf)// ...

/* The return type of this function is the larger of its two
 * template parameters: Either type A or type B. */
auto calculate(A, B)(A a, B b) {
    $(HILITE LargerOf!(A, B)) result;
    // ...
    return result;
}

void main() {
    auto f = calculate(1, 2$(HILITE L));
    static assert(is (typeof(f) == $(HILITE long)));
}
---

$(H5 Kinds of templates)

$(H6 Function, class, and struct templates)

$(P
We have already covered function, $(C class), and $(C struct) templates in $(LINK2 templates.html, the Templates chapter) and we have seen many examples of them since then.
)

$(H6 $(IX member function template) Member function templates)

$(P
$(C struct) and $(C class) member functions can be templates as well. For example, the following $(C put()) member function template would work with any parameter type as long as that type is compatible with the operations inside the template (for this specific template, it should be convertible to $(C string)):
)

---
class Sink {
    string content;

    void put$(HILITE (T))(auto ref const T value) {
        import std.conv;
        content ~= value.to!string;
    }
}
---

$(P
However, as templates can have potentially infinite number of instantiations, they cannot be $(LINK2 inheritance.html, virtual functions) because the compiler cannot know which specific instantiations of a template to include in the interface. (Accordingly, the $(C abstract) keyword cannot be used either.)
)

$(P
For example, although the presence of the $(C put()) template in the following subclass may give the impression that it is overriding a function, it actually hides the $(C put) name of the superclass (see $(I name hiding) in $(LINK2 alias.html, the alias chapter)):
)

---
class Sink {
    string content;

    void put(T)(auto ref const T value) {
        import std.conv;
        content ~= value.to!string;
    }
}

class SpecialSink : Sink {
    /* The following template definition does not override
     * the template instances of the superclass; it hides
     * those names. */
    void put(T)(auto ref const T value) {
        import std.string;
        super.put(format("{%s}", value));
    }
}

void fillSink($(HILITE Sink) sink) {
    /* The following function calls are not virtual. Because
     * parameter 'sink' is of type 'Sink', the calls will
     * always be dispatched to Sink's 'put' template
     * instances. */

    sink.put(42);
    sink.put("hello");
}

void main() {
    auto sink = new $(HILITE SpecialSink)();
    fillSink(sink);

    import std.stdio;
    writeln(sink.content);
}
---

$(P
As a result, although the object actually is a $(C SpecialSink), both of the calls inside $(C fillSink()) are dispatched to $(C Sink) and the content does not contain the curly brackets that $(C SpecialSink.put()) inserts:
)

$(SHELL
42hello    $(SHELL_NOTE Sink's behavior, not SpecialSink's)
)

$(H6 $(IX union template) Union templates)

$(P
Union templates are similar to struct templates. The shortcut syntax is available for them as well.
)

$(P
As an example, let's design a more general version of the $(C IpAdress) $(C union) that we saw in $(LINK2 union.html, the Unions chapter). There, the value of the IPv4 address was kept as a $(C uint) member in that earlier version of $(C IpAdress), and the element type of the segment array was $(C ubyte):
)

---
union IpAddress {
    uint value;
    ubyte[4] bytes;
}
---

$(P
The $(C bytes) array provided easy access to the four segments of the IPv4 address.
)

$(P
The same concept can be implemented in a more general way as the following $(C union) template:
)

---
union SegmentedValue($(HILITE ActualT, SegmentT)) {
    ActualT value;
    SegmentT[/* number of segments */] segments;
}
---

$(P
That template would allow specifying the types of the value and its segments freely.
)

$(P
The number of segments that are needed depends on the types of the actual value and the segments. Since an IPv4 address has four $(C ubyte) segments, that value was hard-coded as $(C 4) in the earlier definition of $(C IpAddress). For the $(C SegmentedValue) template, the number of segments must be computed at compile time when the template is instantiated for the two specific types.
)

$(P
The following eponymous template takes advantage of the $(C .sizeof) properties of the two types to calculate the number of segments needed:
)

---
$(CODE_NAME segmentCount)template segmentCount(ActualT, SegmentT) {
    enum segmentCount = ((ActualT.sizeof + (SegmentT.sizeof - 1))
                         / SegmentT.sizeof);
}
---

$(P
The shortcut syntax may be more readable:
)

---
enum segmentCount(ActualT, SegmentT) =
    ((ActualT.sizeof + (SegmentT.sizeof - 1))
     / SegmentT.sizeof);
---

$(P
$(I $(B Note:) The expression $(C SegmentT.sizeof - 1) is for when the sizes of the types cannot be divided evenly. For example, when the actual type is 5 bytes and the segment type is 2 bytes, even though a total of 3 segments are needed, the result of the integer division 5/2 would incorrectly be 2.)
)

$(P
The definition of the union template is now complete:
)

---
$(CODE_NAME SegmentedValue)$(CODE_XREF segmentCount)union SegmentedValue(ActualT, SegmentT) {
    ActualT value;
    SegmentT[segmentCount!(ActualT, SegmentT)] segments;
}
---

$(P
Instantiation of the template for $(C uint) and $(C ubyte) would be the equivalent of the earlier definition of $(C IpAddress):
)

---
$(CODE_XREF SegmentedValue)import std.stdio;

void main() {
    auto address = SegmentedValue!($(HILITE uint, ubyte))(0xc0a80102);

    foreach (octet; address.segments) {
        write(octet, ' ');
    }
}
---

$(P
The output of the program is the same as the one in $(LINK2 union.html, the Unions chapter):
)

$(SHELL_SMALL
2 1 168 192
)

$(P
To demonstrate the flexibility of this template, let's imagine that it is required to access the parts of the IPv4 address as two $(C ushort) values. It would be as easy as providing $(C ushort) as the segment type:
)

---
    auto address = SegmentedValue!(uint, $(HILITE ushort))(0xc0a80102);
---

$(P
Although unusual for an IPv4 address, the output of the program would consist of two $(C ushort) segment values:
)

$(SHELL_SMALL
258 49320
)

$(H6 $(IX interface template) Interface templates)

$(P
Interface templates provide flexibility on the types that are used on an interface (as well as values such as sizes of fixed-length arrays and other features of an interface).
)

$(P
Let's define an interface for colored objects where the type of the color is determined by a template parameter:
)

---
interface ColoredObject(ColorT) {
    void paint(ColorT color);
}
---

$(P
That interface template requires that its subtypes must define the $(C paint()) function but it leaves the type of the color flexible.
)

$(P
A class that represents a frame on a web page may choose to use a color type that is represented by its red, green, and blue components:
)

---
struct RGB {
    ubyte red;
    ubyte green;
    ubyte blue;
}

class PageFrame : ColoredObject$(HILITE !RGB) {
    void paint(RGB color) {
        // ...
    }
}
---

$(P
On the other hand, a class that uses the frequency of light can choose a completely different type to represent color:
)

---
alias Frequency = double;

class Bulb : ColoredObject$(HILITE !Frequency) {
    void paint(Frequency color) {
        // ...
    }
}
---

$(P
However, as explained in $(LINK2 templates.html, the Templates chapter), "every template instantiation yields a distinct type". Accordingly, the interfaces $(C ColoredObject!RGB) and $(C ColoredObject!Frequency) are unrelated interfaces, and $(C PageFrame) and $(C Bulb) are unrelated classes.
)

$(H5 $(IX parameter, template) Kinds of template parameters)

$(P
The template parameters that we have seen so far have all been $(I type) parameters. So far, parameters like $(C T) and $(C ColorT) all represented types.  For example, $(C T) meant $(C int), $(C double), $(C Student), etc. depending on the instantiation of the template.
)

$(P
There are other kinds of template parameters: value, $(C this), $(C alias), and tuple.
)

$(H6 $(IX type template parameter) Type template parameters)

$(P
This section is only for completeness. All of the templates that we have seen so far had type parameters.
)

$(H6 $(IX value template parameter) Value template parameters)

$(P
Value template parameters allow flexibility on certain values used in the template implementation.
)

$(P
Since templates are a compile-time feature, the values for the value template parameters must be known at compile time; values that must be calculated at run time cannot be used.
)

$(P
To see the advantage of value template parameters, let's start with a set of structs representing geometric shapes:
)

---
struct Triangle {
    Point[3] corners;
// ...
}

struct Rectangle {
    Point[4] corners;
// ...
}

struct Pentagon {
    Point[5] corners;
// ...
}
---

$(P
Let's assume that other member variables and member functions of those types are exactly the same and that the only difference is the $(I value) that determines the number of corners.
)

$(P
Value template parameters help in such cases. The following struct template is sufficient to represent all of the types above and more:
)

---
struct Polygon$(HILITE (size_t N)) {
    Point[N] corners;
// ...
}
---

$(P
The only template parameter of that struct template is a value named $(C N) of type $(C size_t). The value $(C N) can be used as a compile-time constant anywhere inside the template.
)

$(P
That template is flexible enough to represent shapes of any sides:
)

---
    auto centagon = Polygon!100();
---

$(P
The following aliases correspond to the earlier struct definitions:
)

---
alias Triangle = Polygon!3;
alias Rectangle = Polygon!4;
alias Pentagon = Polygon!5;

// ...

    auto triangle = Triangle();
    auto rectangle = Rectangle();
    auto pentagon = Pentagon();
---

$(P
The type of the $(I value) template parameter above was $(C size_t). As long as the value can be known at compile time, a value template parameter can be of any type: a fundamental type, a $(C struct) type, an array, a string, etc.
)

---
struct S {
    int i;
}

// Value template parameter of struct S
void foo($(HILITE S s))() {
    // ...
}

void main() {
    foo!(S(42))();    // Instantiating with literal S(42)
}
---

$(P
The following example uses a $(C string) template parameter to represent an XML tag to produce a simple XML output:
)

$(UL
$(LI First the tag between the $(C &lt;)&nbsp;$(C &gt;) characters: $(C &lt;tag&gt;))
$(LI Then the value)
$(LI Finally the tag between the $(C &lt;/)&nbsp;$(C &gt;) characters: $(C &lt;/tag&gt;))
)

$(P
For example, an XML tag representing $(I location 42) would be printed as $(C &lt;location&gt;42&lt;/location&gt;).
)

---
$(CODE_NAME XmlElement)import std.string;

class XmlElement$(HILITE (string tag)) {
    double value;

    this(double value) {
        this.value = value;
    }

    override string toString() const {
        return format("<%s>%s</%s>", tag, value, tag);
    }
}
---

$(P
Note that the template parameter is not about a type that is used in the implementation of the template, rather it is about a $(C string) $(I value). That value can be used anywhere inside the template as a $(C string).
)

$(P
The XML elements that a program needs can be defined as aliases as in the following code:
)

---
$(CODE_XREF XmlElement)alias Location = XmlElement!"location";
alias Temperature = XmlElement!"temperature";
alias Weight = XmlElement!"weight";

void main() {
    Object[] elements;

    elements ~= new Location(1);
    elements ~= new Temperature(23);
    elements ~= new Weight(78);

    writeln(elements);
}
---

$(P
The output:
)

$(SHELL_SMALL
[&lt;location&gt;1&lt;/location&gt;, &lt;temperature&gt;23&lt;/temperature&gt;, &lt;weight&gt;78&lt;/weight&gt;]
)

$(P
Value template parameters can have default values as well. For example, the following struct template represents points in a multi-dimensional space where the default number of dimensions is 3:
)

---
struct Point(T, size_t dimension $(HILITE = 3)) {
    T[dimension] coordinates;
}
---

$(P
That template can be used without specifying the $(C dimension) template parameter:
)

---
    Point!double center;    // a point in 3-dimensional space
---

$(P
The number of dimensions can still be specified when needed:
)

---
    Point!(int, 2) point;   // a point on a surface
---

$(P
We have seen in $(LINK2 parameter_flexibility.html, the Variable Number of Parameters chapter) how $(I special keywords) work differently depending on whether they appear inside code or as default function arguments.
)

$(P
Similarly, when used as default template arguments, the special keywords refer to where the template is instantiated at, not where the keywords appear:
)

---
import std.stdio;

void func(T,
          string functionName = $(HILITE __FUNCTION__),
          string file = $(HILITE __FILE__),
          size_t line = $(HILITE __LINE__))(T parameter) {
    writefln("Instantiated at function %s at file %s, line %s.",
             functionName, file, line);
}

void main() {
    func(42);    $(CODE_NOTE $(HILITE line 12))
}
---

$(P
Although the special keywords appear in the definition of the template, their values refer to $(C main()), where the template is instantiated at:
)

$(SHELL
Instantiated at function deneme.$(HILITE main) at file deneme.d, $(HILITE line 12).
)

$(P
We will use $(C __FUNCTION__) below in a multi-dimensional operator overloading example.
)

$(H6 $(IX this, template parameter) $(C this) template parameters for member functions)

$(P
Member functions can be templates as well. Their template parameters have the same meanings as other templates.
)

$(P
However, unlike other templates, member function template parameters can also be $(I $(C this) parameters). In that case, the identifier that comes after the $(C this) keyword represents the exact type of the $(C this) reference of the object. ($(I $(C this) reference) means the object itself, as is commonly written in constructors as $(C this.member&nbsp;=&nbsp;value).)
)

---
struct MyStruct(T) {
    void foo($(HILITE this OwnType))() const {
        writeln("Type of this object: ", OwnType.stringof);
    }
}
---

$(P
The $(C OwnType) template parameter is the actual type of the object that the member function is called on:
)

---
    auto m = MyStruct!int();
    auto c = const(MyStruct!int)();
    auto i = immutable(MyStruct!int)();

    m.foo();
    c.foo();
    i.foo();
---

$(P
The output:
)

$(SHELL_SMALL
Type of this object: MyStruct!int
Type of this object: const(MyStruct!int)
Type of this object: immutable(MyStruct!int)
)

$(P
As you can see, the type includes the corresponding type of $(C T) as well as the type qualifiers like $(C const) and $(C immutable).
)

$(P
The $(C struct) (or $(C class)) need not be a template. $(C this) template parameters can appear on member function templates of non-templated types as well.
)

$(P
$(C this) template parameters can be useful in $(I template mixins) as well, which we will see two chapters later.
)

$(H6 $(IX alias, template parameter) $(C alias) template parameters)

$(P
$(C alias) template parameters can correspond to any symbol or expression that is used in the program. The only constraint on such a template argument is that the argument must be compatible with its use inside the template.
)

$(P
$(C filter()) and $(C map()) use $(C alias) template parameters to determine the operations that they execute.
)

$(P
Let's see a simple example on a $(C struct) template that is for modifying an existing variable. The $(C struct) template takes the variable as an $(C alias) parameter:
)

---
struct MyStruct(alias variable) {
    void set(int value) {
        variable = value;
    }
}
---

$(P
The member function simply assigns its parameter to the variable that the $(C struct) template is instantiated with. That variable must be specified during the instantiation of the template:
)

---
    int x = 1;
    int y = 2;

    auto object = MyStruct!$(HILITE x)();
    object.set(10);
    writeln("x: ", x, ", y: ", y);
---

$(P
In that instantiation, the $(C variable) template parameter corresponds to the variable $(C x):
)

$(SHELL_SMALL
x: $(HILITE 10), y: 2
)

$(P
Conversely, $(C MyStruct!y) instantiation of the template would associate $(C variable) with $(C y).
)

$(P
Let's now have an $(C alias) parameter that represents a callable entity, similar to $(C filter()) and $(C map()):
)

---
void caller(alias func)() {
    write("calling: ");
    $(HILITE func());
}
---

$(P
As seen by the $(C ()) parentheses, $(C caller()) uses its template parameter as a function. Additionally, since the parentheses are empty, it must be legal to call the function without specifying any arguments.
)

$(P
Let's have the following two functions that match that description. They can both represent $(C func) because they can be called as $(C func()) in the template:
)

---
void foo() {
    writeln("foo called.");
}

void bar() {
    writeln("bar called.");
}
---

$(P
Those functions can be used as the $(C alias) parameter of $(C caller()):
)

---
    caller!foo();
    caller!bar();
---

$(P
The output:
)

$(SHELL_SMALL
calling: foo called.
calling: bar called.
)

$(P
As long as it matches the way it is used in the template, any symbol can be used as an $(C alias) parameter. As a counter example, using an $(C int) variable with $(C caller()) would cause a compilation error:
)

---
    int variable;
    caller!variable();    $(DERLEME_HATASI)
---

$(P
The compilation error indicates that the variable does not match its use in the template:
)

$(SHELL_SMALL
Error: $(HILITE function expected before ()), not variable of type int
)

$(P
Although the mistake is with the $(C caller!variable) instantiation, the compilation error necessarily points at $(C func()) inside the $(C caller()) template because from the point of view of the compiler the error is with trying to call $(C variable) as a function. One way of dealing with this issue is to use $(I template constraints), which we will see below.
)

$(P
If the variable supports the function call syntax perhaps because it has an $(C opCall()) overload or it is a function literal, it would still work with the $(C caller()) template. The following example demonstrates both of those cases:
)

---
class C {
    void opCall() {
        writeln("C.opCall called.");
    }
}

// ...

    auto o = new C();
    caller!o();

    caller!({ writeln("Function literal called."); })();
---

$(P
The output:
)

$(SHELL
calling: C.opCall called.
calling: Function literal called.
)

$(P
$(C alias) parameters can be specialized as well. However, they have a different specialization syntax. The specialized type must be specified between the $(C alias) keyword and the name of the parameter:
)

---
import std.stdio;

void foo(alias variable)() {
    writefln("The general definition is using '%s' of type %s.",
             variable.stringof, typeof(variable).stringof);
}

void foo(alias $(HILITE int) i)() {
    writefln("The int specialization is using '%s'.",
             i.stringof);
}

void foo(alias $(HILITE double) d)() {
    writefln("The double specialization is using '%s'.",
             d.stringof);
}

void main() {
    string name;
    foo!name();

    int count;
    foo!count();

    double length;
    foo!length();
}
---

$(P
Also note that $(C alias) parameters make the names of the actual variables available inside the template:
)

$(SHELL
The general definition is using 'name' of type string.
The int specialization is using 'count'.
The double specialization is using 'length'.
)

$(H6 $(IX tuple template parameter) Tuple template parameters)

$(P
We have seen in $(LINK2 parameter_flexibility.html, the Variable Number of Parameters chapter) that variadic functions can take any number and any type of parameters. For example, $(C writeln()) can be called with any number of parameters of any type.
)

$(P
$(IX ..., template parameter) $(IX variadic template) Templates can be variadic as well. A template parameter that consists of a name followed by $(C ...) allows any number and kind of parameters at that parameter's position. Such parameters appear as a tuple inside the template, which can be used like an $(C AliasSeq).
)

$(P
Let's see an example of this with a template that simply prints information about every template argument that it is instantiated with:
)

---
$(CODE_NAME info)void info(T...)(T args) {
    // ...
}
---

$(P
The template parameter $(C T...) makes $(C info) a $(I variadic template). Both $(C T) and $(C args) are tuples:
)

$(UL
$(LI $(C T) represents the types of the arguments.)
$(LI $(C args) represents the arguments themselves.)
)

$(P
The following example instantiates that function template with three values of three different types:
)

---
$(CODE_XREF info)import std.stdio;

// ...

void main() {
    info($(HILITE 1, "abc", 2.3));
}
---

$(P
The following implementation simply prints information about the arguments by iterating over them in a $(C foreach) loop:
)

---
void info(T...)(T args) {
    // 'args' is being used like a tuple:
    foreach (i, arg; $(HILITE args)) {
        writefln("%s: %s argument %s",
                 i, typeof(arg).stringof, arg);
    }
}
---

$(P
$(I $(B Note:) As seen in the previous chapter, since the arguments are a tuple, the $(C foreach) statement above is a) compile-time $(C foreach).
)

$(P
The output:
)

$(SHELL_SMALL
0: int argument 1
1: string argument abc
2: double argument 2.3
)

$(P
Note that instead of obtaining the type of each argument by $(C typeof(arg)), we could have used $(C T[i]) as well.
)

$(P
We know that template arguments can be deduced for function templates. That's why the compiler deduces the types as $(C int), $(C string), and $(C double) in the previous program.
)

$(P
However, it is also possible to specify template parameters explicitly. For example, $(C std.conv.to) takes the destination type as an explicit template parameter:
)

---
    to!$(HILITE string)(42);
---

$(P
When template parameters are explicitly specified, they can be a mixture of value, type, and other kinds. That flexibility makes it necessary to be able to determine whether each template parameter is a type or not, so that the body of the template can be coded accordingly. That is achieved by treating the arguments as an $(C AliasSeq).
)

$(P
Let's see an example of this in a function template that produces $(C struct) definitions as source code in text form. Let's have this function return the produced source code as $(C string). This function can first take the name of the $(C struct) followed by the types and names of the members specified as pairs:
)

---
import std.stdio;

void $(CODE_DONT_TEST)main() {
    writeln(structDefinition!("Student",
                              string, "name",
                              int, "id",
                              int[], "grades")());
}
---

$(P
That $(C structDefinition) instantiation is expected to produce the following $(C string):
)

$(SHELL
struct Student {
    string name;
    int id;
    int[] grades;
}
)

$(P
$(I $(B Note:) Functions that produce source code are used with the $(C mixin) keyword, which we will see in $(LINK2 mixin.html, a later chapter).)
)

$(P
The following is an implementation that produces the desired output. Note how the function template makes use of the $(C is) expression. Remember that the expression $(C is&nbsp;(arg)) produces $(C true) when $(C arg) is a valid type:
)

---
import std.string;

string structDefinition(string name, $(HILITE Members)...)() {
    /* Ensure that members are specified as pairs: first the
     * type then the name. */
    static assert(($(HILITE Members).length % 2) == 0,
                  "Members must be specified as pairs.");

    /* The first part of the struct definition. */
    string result = "struct " ~ name ~ "\n{\n";

    foreach (i, arg; $(HILITE Members)) {
        static if (i % 2) {
            /* The odd numbered arguments should be the names
             * of members. Instead of dealing with the names
             * here, we use them as Members[i+1] in the 'else'
             * clause below.
             *
             * Let's at least ensure that the member name is
             * specified as a string. */
            static assert(is (typeof(arg) == string),
                          "Member name " ~ arg.stringof ~
                          " is not a string.");

        } else {
            /* In this case 'arg' is the type of the
             * member. Ensure that it is indeed a type. */
            static assert(is (arg),
                          arg.stringof ~ " is not a type.");

            /* Produce the member definition from its type and
             * its name.
             *
             * Note: We could have written 'arg' below instead
             * of Members[i]. */
            result ~= format("    %s %s;\n",
                             $(HILITE Members[i]).stringof, $(HILITE Members[i+1]));
        }
    }

    /* The closing bracket of the struct definition. */
    result ~= "}";

    return result;
}

import std.stdio;

void main() {
    writeln(structDefinition!("Student",
                              string, "name",
                              int, "id",
                              int[], "grades")());
}
---

$(H5 $(IX typeof(this)) $(IX typeof(super)) $(IX typeof(return))$(C typeof(this)), $(C typeof(super)), and $(C typeof(return)))

$(P
In some cases, the generic nature of templates makes it difficult to know or spell out certain types in the template code. The following three special $(C typeof) varieties are useful in such cases. Although they are introduced in this chapter, they work in non-templated code as well.
)

$(UL

$(LI $(C typeof(this)) generates the type of the $(C this) reference. It works in any $(C struct) or $(C class), even outside of member functions:

---
struct List(T) {
    // The type of 'next' is List!int when T is int
    typeof(this) *next;
    // ...
}
---

)

$(LI $(C typeof(super)) generates the base type of a $(C class) (i.e. the type of $(C super)).

---
class ListImpl(T) {
    // ...
}

class List(T) : ListImpl!T {
    // The type of 'next' is ListImpl!int when T is int
    typeof(super) *next;
    // ...
}
---

)

$(LI $(C typeof(return)) generates the return type of a function, inside that function.

$(P
For example, instead of defining the $(C calculate()) function above as an $(C auto) function, we can be more explicit by replacing $(C auto) with $(C LargerOf!(A, B)) in its definition. (Being more explicit would have the added benefit of obviating at least some part of its function comment.)
)

---
$(HILITE LargerOf!(A, B)) calculate(A, B)(A a, B b) {
    // ...
}
---

$(P
$(C typeof(return)) prevents having to repeat the return type inside the function body:
)

---
LargerOf!(A, B) calculate(A, B)(A a, B b) {
    $(HILITE typeof(return)) result;    // The type is either A or B
    // ...
    return result;
}
---

)

)

$(H5 Template specializations)

$(P
We have seen template specializations in $(LINK2 templates.html, the Templates chapter). Like type parameters, other kinds of template parameters can be specialized as well. The following is the general definition of a template and its specialization for 0:
)

---
void foo(int value)() {
    // ... general definition ...
}

void foo(int value $(HILITE : 0))() {
    // ... special definition for zero ...
}
---

$(P
We will take advantage of template specializations in the $(I meta programming) section below.
)

$(H5 $(IX meta programming) Meta programming)

$(P
As they are about code generation, templates are among the higher level features of D. A template is indeed code that generates code. Writing code that generates code is called $(I meta programming).
)

$(P
Due to templates being compile-time features, some operations that are normally executed at runtime can be moved to compile time as template instantiations.
)

$(P
($(I $(B Note:) Compile time function execution) (CTFE) $(I is another feature that achieves the same goal. We will see CTFE in a later chapter.))
)

$(P
$(I Executing) templates at compile time is commonly based on recursive template instantiations.
)

$(P
To see an example of this, let's first consider a regular function that calculates the sum of numbers from 0 to a specific value. For example, when its argument is 4, this fuction should return the result of 0+1+2+3+4:
)

---
int sum(int last) {
    int result = 0;

    foreach (value; 0 .. last + 1) {
        result += value;
    }

    return result;
}
---

$(P
$(IX recursion) That is an iterative implementation of the function. The same function can be implemented by recursion as well:
)

---
int sum(int last) {
    return (last == 0
            ? last
            : last + $(HILITE sum)(last - 1));
}
---

$(P
The recursive function returns the sum of the last value and the previous sum. As you can see, the function terminates the recursion by treating the value 0 specially.
)

$(P
Functions are normally run-time features. As usual, $(C sum()) can be executed at run time:
)

---
    writeln(sum(4));
---

$(P
When the result is needed at compile time, one way of achieving the same calculation is by defining a function template. In this case, the parameter must be a template parameter, not a function parameter:
)

---
// WARNING: This code is incorrect.
int sum($(HILITE int last))() {
    return (last == 0
            ? last
            : last + sum$(HILITE !(last - 1))());
}
---

$(P
That function template instantiates itself by $(C last - 1) and tries to calculate the sum again by recursion. However, that code is incorrect.
)

$(P
As the ternary operator would be compiled to be executed at run time, there is no condition check that terminates the recursion at compile time:
)

---
    writeln(sum!4());    $(DERLEME_HATASI)
---

$(P
The compiler detects that the template instances would recurse infinitely and stops at an arbitrary number of recursions:
)

$(SHELL_SMALL
Error: template instance deneme.sum!($(HILITE -296)) recursive expansion
)

$(P
Considering the difference between the template argument 4 and -296, the compiler restricts template expansion at 300 by default.
)

$(P
In meta programming, recursion is terminated by a template specialization. The following specialization for 0 produces the expected result:
)

---
$(CODE_NAME sum)// The general definition
int sum(int last)() {
    return last + sum!(last - 1)();
}

// The special definition for zero
int sum(int last $(HILITE : 0))() {
    return 0;
}
---

$(P
The following is a program that tests $(C sum()):
)

---
$(CODE_XREF sum)import std.stdio;

void main() {
    writeln(sum!4());
}
---

$(P
Now the program compiles successfully and produces the result of 4+3+2+1+0:
)

$(SHELL_SMALL
10
)

$(P
An important point to make here is that the function $(C sum!4()) is executed entirely at compile time. The compiled code is the equivalent of calling $(C writeln()) with literal $(C 10):
)

---
    writeln(10);         // the equivalent of writeln(sum!4())
---

$(P
As a result, the compiled code is as fast and simple as can be. Although the value 10 is still calculated as the result of 4+3+2+1+0, the entire calculation happens at compile time.
)

$(P
The previous example demonstrates one of the benefits of meta programming: moving operations from run time to compile time. CTFE obviates some of the idioms of meta programming in D.
)

$(H5 $(IX polymorphism, compile-time) $(IX compile-time polymorphism) Compile-time polymorphism)

$(P
In object oriented programming (OOP), polymorphism is achieved by inheritance. For example, if a function takes an interface, it accepts objects of any class that inherits that interface.
)

$(P
Let's recall an earlier example from a previous chapter:
)

---
import std.stdio;

interface SoundEmitter {
    string emitSound();
}

class Violin : SoundEmitter {
    string emitSound() {
        return "♩♪♪";
    }
}

class Bell : SoundEmitter {
    string emitSound() {
        return "ding";
    }
}

void useSoundEmittingObject($(HILITE SoundEmitter object)) {
    // ... some operations ...
    writeln(object.emitSound());
    // ... more operations ...
}

void main() {
    useSoundEmittingObject(new Violin);
    useSoundEmittingObject(new Bell);
}
---

$(P
$(C useSoundEmittingObject()) is benefiting from polymorphism. It takes a $(C SoundEmitter) so that it can be used with any type that is derived from that interface.
)

$(P
Since $(I working with any type) is inherent to templates, they can be seen as providing a kind of polymorphism as well. Being a compile-time feature, the polymorphism that templates provide is called $(I compile-time polymorphism). Conversely, OOP's polymorphism is called $(I run-time polymorphism).
)

$(P
In reality, neither kind of polymorphism allows being used with $(I any type) because the types must satisfy certain requirements.
)

$(P
Run-time polymorphism requires that the type implements a certain interface.
)

$(P
Compile-time polymorphism requires that the type is compatible with how it is used by the template. As long as the code compiles, the template argument can be used with that template. ($(I $(B Note:) Optionally, the argument must satisfy template constraints as well. We will see template constraints later below.))
)

$(P
For example, if $(C useSoundEmittingObject()) were implemented as a function template instead of a function, it could be used with any type that supported the $(C object.emitSound()) call:
)

---
void useSoundEmittingObject$(HILITE (T))(T object) {
    // ... some operations ...
    writeln(object.emitSound());
    // ... more operations ...
}

class Car {
    string emitSound() {
        return "honk honk";
    }
}

// ...

    useSoundEmittingObject(new Violin);
    useSoundEmittingObject(new Bell);
    useSoundEmittingObject(new Car);
---

$(P
Note that although $(C Car) has no inheritance relationship with any other type, the code compiles successfully, and the $(C emitSound()) member function of each type gets called.
)

$(P
$(IX duck typing) Compile-time polymorphism is also known as $(I duck typing), a humorous term, emphasizing behavior over actual type.
)

$(H5 $(IX code bloat) Code bloat)

$(P
The code generated by the compiler is different for every different argument of a type parameter, of a value parameter, etc.)

$(P
The reason for that can be seen by considering $(C int) and $(C double) as type template arguments. Each type would have to be processed by different kinds of CPU registers. For that reason, the same template needs to be compiled differently for different template arguments. In other words, the compiler needs to generate different code for each instantiation of a template.
)

$(P
For example, if $(C useSoundEmittingObject()) were implemented as a template, it would be compiled as many times as the number of different instantiations of it.
)

$(P
Because it results in larger program size, this effect is called $(I code bloat). Although this is not a problem in most programs, it is an effect of templates that must be known.
)

$(P
Conversely, non-templated version of $(C useSoundEmittingObject()) would not have any code repetition. The compiler would compile that function just once and execute the same code for all types of the $(C SoundEmitter) interface. In run-time polymorphism, having the same code behave differently for different types is achieved by function pointers on the background. Although function pointers have a small cost at run time, that cost is not significant in most programs.
)

$(P
Since both code bloat and run-time polymorphism have effects on program performance, it cannot be known beforehand whether run-time polymorphism or compile-time polymorphism would be a better approach for a specific program.
)

$(H5 $(IX constraint, template) $(IX template constraint) Template constraints)

$(P
The fact that templates can be instantiated with any argument yet not every argument is compatible with every template brings an inconvenience. If a template argument is not compatible with a particular template, the incompatibility is necessarily detected during the compilation of the template code for that argument. As a result, the compilation error points at a line inside the template implementation.
)

$(P
Let's see this by using $(C useSoundEmittingObject()) with a type that does not support the $(C object.emitSound()) call:
)

---
class Cup {
    // ... does not have emitSound() ...
}

// ...

    useSoundEmittingObject(new Cup);   // ← incompatible type
---

$(P
Although arguably the error is with the code that uses the template with an incompatible type, the compilation error points at a line inside the template:
)

---
void useSoundEmittingObject(T)(T object) {
    // ... some operations ...
    writeln(object.emitSound());    $(DERLEME_HATASI)
    // ... more operations ...
}
---

$(P
An undesired consequence is that when the template is a part of a third-party library module, the compilation error would appear to be a problem with the library itself.
)

$(P
Note that this issue does not exist for interfaces: A function that takes an interface can only be called with a type that implements that interface. Attempting to call such a function with any other type is a compilation error at the caller.
)

$(P
$(IX if, template constraint) Template contraints are for disallowing incorrect instantiations of templates. They are defined as logical expressions of an $(C if) condition right before the template body:
)

---
void foo(T)()
        if (/* ... constraints ... */) {
    // ...
}
---

$(P
A template definition is considered by the compiler only if its constraints evaluate to $(C true) for a specific instantiation of the template. Otherwise, the template definition is ignored for that use.
)

$(P
Since templates are a compile-time feature, template constraints must be evaluable at compile time. The $(C is) expression that we saw in $(LINK2 is_expr.html, the $(C is) Expression chapter) is commonly used in template constraints. We will use the $(C is) expression in the following examples as well.
)

$(H6 $(IX single-element tuple template parameter) $(IX tuple template parameter, single-element) Tuple parameter of single element)

$(P
Sometimes the single parameter of a template needs to be one of type, value, or $(C alias) kinds. That can be achieved by a tuple parameter of length one:
)

---
template myTemplate(T...)
        $(HILITE if (T.length == 1)) {
    static if (is ($(HILITE T[0]))) {
        // The single parameter is a type
        enum bool myTemplate = /* ... */;

    } else {
        // The single parameter is some other kind
        enum bool myTemplate = /* ... */;
    }
}
---

$(P
Some of the templates of the $(C std.traits) module take advantage of this idiom. We will see $(C std.traits) in a later chapter.
)

$(H6 $(IX named template constraint) Named constraints)

$(P
Sometimes the constraints are complex, making it hard to understand the requirements of template parameters. This complexity can be handled by an idiom that effectively gives names to constraints. This idiom combines four features of D: anonymous functions, $(C typeof), the $(C is) expression, and eponymous templates.
)

$(P
Let's see this on a function template that has a type parameter. The template uses its function parameter in specific ways:
)

---
void use(T)(T object) {
    // ...
    object.prepare();
    // ...
    object.fly(42);
    // ...
    object.land();
    // ...
}
---

$(P
As is obvious from the implementation of the template, the types that this function can work with must support three specific function calls on the object: $(C prepare()), $(C fly(42)), and $(C land()).
)

$(P
One way of specifying a template constraint for that type is by the $(C is) and $(C typeof) expressions for each function call inside the template:
)

---
void use(T)(T object)
        if (is (typeof(object.prepare())) &&
            is (typeof(object.fly(1))) &&
            is (typeof(object.land()))) {
    // ...
}
---

$(P
I will explain that syntax below. For now, accept the whole construct of $(C is&nbsp;(typeof(object.prepare()))) to mean $(I whether the type supports the $(C .prepare()) call).
)

$(P
Although such constraints achieve the desired goal, sometimes they are too complex to be readable. Instead, it is possible to give a more descriptive name to the whole constraint:
)

---
void use(T)(T object)
        if (canFlyAndLand!T) {
    // ...
}
---

$(P
That constraint is more readable because it is now more clear that the template is designed to work with types that $(I can fly and land).
)

$(P
Such constraints are achieved by an idiom that is implemented similar to the following eponymous template:
)

---
template canFlyAndLand(T) {
    enum canFlyAndLand = is (typeof(
    {
        T object;
        object.prepare();  // should be preparable for flight
        object.fly(1);     // should be flyable for a certain distance
        object.land();     // should be landable
    }()));
}
---

$(P
The D features that take part in that idiom and how they interact with each other are explained below:
)

---
template canFlyAndLand(T) {
    //        (6)        (5)  (4)
    enum canFlyAndLand = is (typeof(
    $(HILITE {) // (1)
        T object;         // (2)
        object.prepare();
        object.fly(1);
        object.land();
 // (3)
    $(HILITE })()));
}
---

$(OL

$(LI $(B Anonymous function:) We have seen anonymous functions in $(LINK2 lambda.html, the Function Pointers, Delegates, and Lambdas chapter). The highlighted curly brackets above define an anonymous function.
)

$(LI $(B Function block:) The function block uses the type as it is supposed to be used in the actual template. First an object of that type is defined and then that object is used in specific ways. (This code never gets executed; see below.)
)

$(LI $(B Evaluation of the function:) The empty parentheses at the end of an anonymous function normally execute that function. However, since that call syntax is within a $(C typeof), it is never executed.
)

$(LI $(IX typeof) $(B The $(C typeof) expression:) $(C typeof) produces the type of an expression.

$(P
An important fact about $(C typeof) is that it never executes the expression. Rather, it produces the type of the expression $(I if) that expression would be executed:
)

---
    int i = 42;
    typeof(++i) j;    // same as 'int j;'

    assert(i == 42);  // ++i has not been executed
---

$(P
As the previous $(C assert) proves, the expression $(C ++i) has not been executed. $(C typeof) has merely produced the type of that expression as $(C int).
)

$(P
If the expression that $(C typeof) receives is not valid, $(C typeof) produces no type at all (not even $(C void)). So, if the anonymous function inside $(C canFlyAndLand) can be compiled successfully for $(C T), $(C typeof) produces a valid type. Otherwise, it produces no type at all.
)

)

$(LI $(B The $(C is) expression:) We have seen many different uses of the $(C is) expression in $(LINK2 is_expr.html, the $(C is) Expression chapter). The $(C is&nbsp;($(I Type))) syntax produces $(C true) if $(C Type) is valid:

---
    int i;
    writeln(is (typeof(i)));                  // true
    writeln(is (typeof(nonexistentSymbol)));  // false
---

$(P
Although the second $(C typeof) above receives a nonexistent symbol, the compiler does not emit a compilation error. Rather, the effect is that the $(C typeof) expression does not produce any type, so the $(C is) expression produces $(C false):
)

$(SHELL_SMALL
true
false
)

)

$(LI $(B Eponymous template:) As described above, since the $(C canFlyAndLand) template contains a definition by the same name, the template instantiation is that definition itself.
)

)

$(P
In the end, $(C use()) gains a more descriptive constraint:
)

---
void use(T)(T object)
        if (canFlyAndLand!T) {
    // ...
}
---

$(P
Let's try to use that template with two types, one that satisfies the constraint and one that does not satisfy the constraint:
)

---
// A type that does match the template's operations
class ModelAirplane {
    void prepare() {
    }

    void fly(int distance) {
    }

    void land() {
    }
}

// A type that does not match the template's operations
class Pigeon {
    void fly(int distance) {
    }
}

// ...

    use(new ModelAirplane);    // ← compiles
    use(new Pigeon);           $(DERLEME_HATASI)
---

$(P
Named or not, since the template has a constraint, the compilation error points at the line where the template is used rather than where it is implemented.
)

$(H5 $(IX overloading, operator) $(IX multi-dimensional operator overloading) $(IX operator overloading, multi-dimensional) Using templates in multi-dimensional operator overloading)

$(P
We have seen in $(LINK2 operator_overloading.html, the Operator Overloading chapter) that $(C opDollar), $(C opIndex), and $(C opSlice) are for element indexing and slicing. When overloaded for single-dimensional collections, these operators have the following responsibilities:
)

$(UL

$(LI $(C opDollar): Returns the number of elements of the collection.)

$(LI $(C opSlice): Returns an object that represents some or all of the elements of the collection.)

$(LI $(C opIndex): Provides access to an element.)

)

$(P
Those operator functions have templated versions as well, which have different responsibilities from the non-templated ones above. Note especially that in multi-dimensional operator overloading $(C opIndex) assumes the responsibility of $(C opSlice).
)

$(UL

$(LI $(IX opDollar template) $(C opDollar) template: Returns the length of a specific dimension of the collection. The dimension is determined by the template parameter:

---
    size_t opDollar$(HILITE (size_t dimension))() const {
        // ...
    }
---

)

$(LI $(IX opSlice template) $(C opSlice) template: Returns the range information that specifies the range of elements (e.g. the $(C begin) and $(C end) values in $(C array[begin..end])). The information can be returned as $(C Tuple!(size_t, size_t)) or an equivalent type. The dimension that the range specifies is determined by the template parameter:

---
    Tuple!(size_t, size_t) opSlice$(HILITE (size_t dimension))(size_t begin,
                                                     size_t end) {
        return tuple(begin, end);
    }
---

)

$(LI $(IX opIndex template) $(C opIndex) template: Returns a range object that represents a part of the collection. The range of elements are determined by the template parameters:

---
    Range opIndex$(HILITE (A...))(A arguments) {
        // ...
    }
---

)

)

$(P
$(IX opIndexAssign template) $(IX opIndexOpAssign template) $(C opIndexAssign) and $(C opIndexOpAssign) have templated versions as well, which operate on a range of elements of the collection.
)

$(P
The user-defined types that define these operators can be used with the multi-dimensional indexing and slicing syntax:
)

---
              // Assigns 42 to the elements specified by the
              // indexing and slicing arguments:
              m[a, b..c, $-1, d..e] = 42;
//              ↑   ↑     ↑    ↑
// dimensions:  0   1     2    3
---

$(P
Such expressions are first converted to the ones that call the operator functions. The conversions are performed by replacing the $(C $) characters with calls to $(C opDollar!dimension()), and the index ranges with calls to $(C opSlice!dimension(begin, end)). The length and range information that is returned by those calls is in turn used as arguments when calling e.g. $(C opIndexAssign). Accordingly, the expression above is executed as the following equivalent (the dimension values are highlighted):
)

---
    // The equivalent of the above:
    m.opIndexAssign(
        42,                    // ← value to assign
        a,                     // ← argument for dimension 0
        m.opSlice!$(HILITE 1)(b, c),     // ← argument for dimension 1
        m.opDollar!$(HILITE 2)() - 1,    // ← argument for dimension 2
        m.opSlice!$(HILITE 3)(d, e));    // ← argument for dimension 3
---

$(P
Consequently, $(C opIndexAssign) determines the range of elements from the arguments.
)

$(H6 Multi-dimensional operator overloading example)

$(P
The following $(C Matrix) example demonstrates how these operators can be overloaded for a two-dimensional type.
)

$(P
Note that this code can be implemented in more efficient ways. For example, instead of constructing a $(I single-element sub-matrix) even when operating on a single element e.g. by $(C m[i, j]), it could apply the operation directly on that element.
)

$(P
Additionally, the $(C writeln(__FUNCTION__)) expressions inside the functions have nothing to do with the behavior of the code. They merely help expose the functions that get called behind the scenes for different operator usages.
)

$(P
Also note that the correctness of dimension values are enforced by template constraints.
)

---
import std.stdio;
import std.format;
import std.string;

/* Works as a two-dimensional int array. */
struct Matrix {
private:

    int[][] rows;

    /* Represents a range of rows or columns. */
    struct Range {
        size_t begin;
        size_t end;
    }

    /* Returns the sub-matrix that is specified by the row and
     * column ranges. */
    Matrix subMatrix(Range rowRange, Range columnRange) {
        writeln(__FUNCTION__);

        int[][] slices;

        foreach (row; rows[rowRange.begin .. rowRange.end]) {
            slices ~= row[columnRange.begin .. columnRange.end];
        }

        return Matrix(slices);
    }

public:

    this(size_t height, size_t width) {
        writeln(__FUNCTION__);

        rows = new int[][](height, width);
    }

    this(int[][] rows) {
        writeln(__FUNCTION__);

        this.rows = rows;
    }

    void toString(void delegate(const(char)[]) sink) const {
        sink.formattedWrite!"%(%(%5s %)\n%)"(rows);
    }

    /* Assigns the specified value to each element of the
     * matrix. */
    Matrix opAssign(int value) {
        writeln(__FUNCTION__);

        foreach (row; rows) {
            row[] = value;
        }

        return this;
    }

    /* Uses each element and a value in a binary operation
     * and assigns the result back to that element. */
    Matrix opOpAssign(string op)(int value) {
        writeln(__FUNCTION__);

        foreach (row; rows) {
            mixin ("row[] " ~ op ~ "= value;");
        }

        return this;
    }

    /* Returns the length of the specified dimension. */
    size_t opDollar(size_t dimension)() const
            if (dimension <= 1) {
        writeln(__FUNCTION__);

        static if (dimension == 0) {
            /* The length of dimension 0 is the length of the
             * 'rows' array. */
            return rows.length;

        } else {
            /* The length of dimension 1 is the lengths of the
             * elements of 'rows'. */
            return rows.length ? rows[0].length : 0;
        }
    }

    /* Returns an object that represents the range from
     * 'begin' to 'end'.
     *
     * Note: Although the 'dimension' template parameter is
     * not used here, that information can be useful for other
     * types. */
    Range opSlice(size_t dimension)(size_t begin, size_t end)
            if (dimension <= 1) {
        writeln(__FUNCTION__);

        return Range(begin, end);
    }

    /* Returns a sub-matrix that is defined by the
     * arguments. */
    Matrix opIndex(A...)(A arguments)
            if (A.length <= 2) {
        writeln(__FUNCTION__);

        /* We start with ranges that represent the entire
         * matrix so that the parameter-less use of opIndex
         * means "all of the elements". */
        Range[2] ranges = [ Range(0, opDollar!0),
                            Range(0, opDollar!1) ];

        foreach (dimension, a; arguments) {
            static if (is (typeof(a) == Range)) {
                /* This dimension is already specified as a
                 * range like 'matrix[begin..end]', which can
                 * be used as is. */
                ranges[dimension] = a;

            } else static if (is (typeof(a) : size_t)) {
                /* This dimension is specified as a single
                 * index value like 'matrix[i]', which we want
                 * to represent as a single-element range. */
                ranges[dimension] = Range(a, a + 1);

            } else {
                /* We don't expect other types. */
                static assert(
                    false, format("Invalid index type: %s",
                                  typeof(a).stringof));
            }
        }

        /* Return the sub-matrix that is specified by
         * 'arguments'. */
        return subMatrix(ranges[0], ranges[1]);
    }

    /* Assigns the specified value to each element of the
     * sub-matrix. */
    Matrix opIndexAssign(A...)(int value, A arguments)
            if (A.length <= 2) {
        writeln(__FUNCTION__);

        Matrix subMatrix = opIndex(arguments);
        return subMatrix = value;
    }

    /* Uses each element of the sub-matrix and a value in a
     * binary operation and assigns the result back to that
     * element. */
    Matrix opIndexOpAssign(string op, A...)(int value,
                                            A arguments)
            if (A.length <= 2) {
        writeln(__FUNCTION__);

        Matrix subMatrix = opIndex(arguments);
        mixin ("return subMatrix " ~ op ~ "= value;");
    }
}

/* Executes the expression that is specified as a string, and
 * prints the result as well as the new state of the
 * matrix. */
void execute(string expression)(Matrix m) {
    writefln("\n--- %s ---", expression);
    mixin ("auto result = " ~ expression ~ ";");
    writefln("result:\n%s", result);
    writefln("m:\n%s", m);
}

void main() {
    enum height = 10;
    enum width = 8;

    auto m = Matrix(height, width);

    int counter = 0;
    foreach (row; 0 .. height) {
        foreach (column; 0 .. width) {
            writefln("Initializing %s of %s",
                     counter + 1, height * width);

            m[row, column] = counter;
            ++counter;
        }
    }

    writeln(m);

    execute!("m[1, 1] = 42")(m);
    execute!("m[0, 1 .. $] = 43")(m);
    execute!("m[0 .. $, 3] = 44")(m);
    execute!("m[$-4 .. $-1, $-4 .. $-1] = 7")(m);

    execute!("m[1, 1] *= 2")(m);
    execute!("m[0, 1 .. $] *= 4")(m);
    execute!("m[0 .. $, 0] *= 10")(m);
    execute!("m[$-4 .. $-2, $-4 .. $-2] -= 666")(m);

    execute!("m[1, 1]")(m);
    execute!("m[2, 0 .. $]")(m);
    execute!("m[0 .. $, 2]")(m);
    execute!("m[0 .. $ / 2, 0 .. $ / 2]")(m);

    execute!("++m[1..3, 1..3]")(m);
    execute!("--m[2..5, 2..5]")(m);

    execute!("m[]")(m);
    execute!("m[] = 20")(m);
    execute!("m[] /= 4")(m);
    execute!("(m[] += 5) /= 10")(m);
}
---

$(H5 Summary)

$(P
The earlier template chapter had the following reminders:
)

$(UL

$(LI Templates define the code as a pattern, for the compiler to generate instances of it according to the actual uses in the program.)

$(LI Templates are a compile-time feature.)

$(LI Specifying template parameter lists is sufficient to make function, struct, and class definitions templates.)

$(LI Template arguments can be specified explicitly after an exclamation mark. The parentheses are not necessary when there is only one token inside the parentheses.)

$(LI Each template instantiation yields a different type.)

$(LI Template arguments can only be deduced for function templates.)

$(LI Templates can be specialized for the type that is after the $(C :) character.)

$(LI Default template arguments are specified after the $(C =) character.)

)

$(P
This chapter added the following concepts:
)

$(UL

$(LI Templates can be defined by the full syntax or the shortcut syntax.)

$(LI The scope of the template is a name space.)

$(LI A template that contains a definition with the same name as the template is called an eponymous template. The template represents that definition.)

$(LI Templates can be of functions, classes, structs, unions, and interfaces, and every template body can contain any number of definitions.)

$(LI Template parameters can be of type, value, $(C this), $(C alias), and tuple kinds.)

$(LI $(C typeof(this)), $(C typeof(super)), and $(C typeof(return)) are useful in templates.)

$(LI Templates can be specialized for particular arguments.)

$(LI Meta programming is a way of executing operations at compile time.)

$(LI Templates enable $(I compile-time polymorphism).)

$(LI Separate code generation for different instantiations can cause $(I code bloat).)

$(LI Template constraints limit the uses of templates for specific template arguments. They help move compilation errors from the implementations of templates to where the templates are actually used incorrectly.)

$(LI It is more readable to give names to template constraints.)

$(LI The templated versions of $(C opDollar), $(C opSlice), $(C opIndex), $(C opIndexAssign), and $(C opIndexOpAssign) are for multi-dimensional indexing and slicing.)

)

Macros:
        TITLE=More Templates

        DESCRIPTION=One of generic programming features of D in more detail.

        KEYWORDS=d programming language tutorial book templates
