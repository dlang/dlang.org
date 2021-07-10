Ddoc

$(DERS_BOLUMU $(IX user defined attributes) $(IX UDA) User Defined Attributes (UDA))

$(P
Any declaration (e.g. struct type, class type, variable, etc.) can be assigned attributes, which can then be accessed at compile time to alter the way the code is compiled. User defined attributes is purely a compile-time feature.
)

$(P
$(IX @) The user defined attribute syntax consists of the $(C @) sign followed by the attribute and appear before the declaration that it is being assigned to. For example, the following code assigns the $(C Encrypted) attribute to the declaration of $(C name):
)

---
    $(HILITE @Encrypted) string name;
---

$(P
Multiple attributes can be specified separately or as a parenthesized list of attributes. For example, both of the following variables have the same attributes:
)

---
    @Encrypted @Colored string lastName;     $(CODE_NOTE separately)
    @$(HILITE $(PARANTEZ_AC))Encrypted, Colored$(HILITE $(PARANTEZ_KAPA)) string address;    $(CODE_NOTE together)
---

$(P
An attribute can be a type name as well as a value of a user defined or a fundamental type. However, because their meanings may not be clear, attributes consisting of literal values like $(C 42) are discouraged:
)

---
$(CODE_NAME Encrypted)struct Encrypted {
}

enum Color { black, blue, red }

struct Colored {
    Color color;
}

void main() {
    @Encrypted           int a;    $(CODE_NOTE type name)
    @Encrypted()         int b;    $(CODE_NOTE object)
    @Colored(Color.blue) int c;    $(CODE_NOTE object)
    @(42)                int d;    $(CODE_NOTE literal (discouraged))
}
---

$(P
The attributes of $(C a) and $(C b) above are of different kinds: The attribute of $(C a) is the type $(C Encrypted) itself, while the attribute of $(C b) is an $(I object) of type $(C Encrypted). This is an important difference that affects the way attributes are used at compile time. We will see an example of this difference below.
)

$(P
$(IX __traits) $(IX getAttributes) The meaning of attributes is solely determined by the programmer for the needs of the program. The attributes are determined by $(C __traits(getAttributes)) at compile time and the code is compiled according to those attributes.
)

$(P
The following code shows how the attributes of a specific $(C struct) member (e.g. $(C Person.name)) can be accessed by $(C __traits(getAttributes)):
)

---
$(CODE_NAME Person)import std.stdio;

// ...

struct Person {
    @Encrypted @Colored(Color.blue) string name;
    string lastName;
    @Colored(Color.red) string address;
}

void $(CODE_DONT_TEST)main() {
    foreach (attr; __traits($(HILITE getAttributes), Person.name)) {
        writeln(attr.stringof);
    }
}
---

$(P
The output of the program lists the attributes of $(C Person.name):
)

$(SHELL
Encrypted
Colored(cast(Color)1)
)

$(P
Two other $(C __traits) expressions are useful when dealing with user defined attributes:
)

$(UL

$(LI $(IX allMembers) $(C __traits(allMembers)) produces the members of a type (or a module) as strings.)

$(LI $(IX getMember) $(C __traits(getMember)) produces a $(I symbol) useful when accessing a member. Its first argument is a symbol (e.g. a type or a variable name) and its second argument is a string. It produces a symbol by combining its first argument, a dot, and its second argument. For example, $(C __traits(getMember, Person, $(STRING "name"))) produces the symbol $(C Person.name).
)

)

---
$(CODE_XREF Encrypted)$(CODE_XREF Person)import std.string;

// ...

void main() {
    foreach (memberName; __traits($(HILITE allMembers), Person)) {
        writef("The attributes of %-8s:", memberName);

        foreach (attr; __traits(getAttributes,
                                __traits($(HILITE getMember),
                                         Person, memberName))) {
            writef(" %s", attr.stringof);
        }

        writeln();
    }
}
---

$(P
The output of the program lists all attributes of all members of $(C Person):
)

$(SHELL
The attributes of name    : Encrypted Colored(cast(Color)1)
The attributes of lastName:
The attributes of address : Colored(cast(Color)2)
)

$(P
$(IX hasUDA, std.traits) Another useful tool is $(C std.traits.hasUDA), which determines whether a symbol has a specific attribute. The following $(C static assert) passes because $(C Person.name) has $(C Encrypted) attribute:
)

---
import std.traits;

// ...

static assert(hasUDA!(Person.name, Encrypted));
---

$(P
$(C hasUDA) can be used with an attribute type as well as a specific value of that type. The following $(C static assert) checks both pass because $(C Person.name) has $(C Colored(Color.blue)) attribute:
)

---
static assert(hasUDA!(Person.name, $(HILITE Colored)));
static assert(hasUDA!(Person.name, $(HILITE Colored(Color.blue))));
---

$(H5 Example)

$(P
Let's design a function template that prints the values of all members of a $(C struct) object in XML format. The following function considers the $(C Encrypted) and $(C Colored) attributes of each member when producing the output:
)

---
void printAsXML(T)(T object) {
// ...

    foreach (member; __traits($(HILITE allMembers), T)) {             // (1)
        string value =
            __traits($(HILITE getMember), object, member).to!string;  // (2)

        static if ($(HILITE hasUDA)!(__traits(getMember, T, member),  // (3)
                           Encrypted)) {
            value = value.encrypted.to!string;
        }

        writefln(`  <%1$s color="%2$s">%3$s</%1$s>`, member,
                 $(HILITE colorAttributeOf)!(T, member), value);      // (4)
    }
}
---

$(P
The highlighted parts of the code are explained below:
)

$(OL

$(LI The members of the type are determined by $(C __traits(allMembers)).)

$(LI The value of each member is converted to $(C string) to be used later when printing to the output. For example, when the member is $(STRING "name"), the right-hand side expression becomes $(C object.name.to!string).)

$(LI Each member is tested with $(C hasUDA) to determine whether it has the $(C Encrypted) attribute. The value of the member is encrypted if it has that attribute. (Because $(C hasUDA) requires $(I symbols) to work with, note how $(C __traits(getMember)) is used to get the member as a symbol (e.g. $(C Person.name)).))

$(LI The color attribute of each member is determined with $(C colorAttributeOf()), which we will see below.)

)

$(P
The $(C colorAttributeOf()) function template can be implemented as in the following code:
)

---
Color colorAttributeOf(T, string memberName)() {
    foreach (attr; __traits(getAttributes,
                            __traits(getMember, T, memberName))) {
        static if (is ($(HILITE typeof(attr)) == Colored)) {
            return attr.color;
        }
    }

    return Color.black;
}
---

$(P
When the compile-time evaluations are completed, the $(C printAsXML()) function template would be instantiated for the $(C Person) type as the equivalent of the following function:
)

---
/* The equivalent of the printAsXML!Person instance. */
void printAsXML_Person(Person object) {
// ...

    {
        string value = object.$(HILITE name).to!string;
        $(HILITE value = value.encrypted.to!string;)
        writefln(`  <%1$s color="%2$s">%3$s</%1$s>`,
                 "name", Color.blue, value);
    }
    {
        string value = object.$(HILITE lastName).to!string;
        writefln(`  <%1$s color="%2$s">%3$s</%1$s>`,
                 "lastName", Color.black, value);
    }
    {
        string value = object.$(HILITE address).to!string;
        writefln(`  <%1$s color="%2$s">%3$s</%1$s>`,
                 "address", Color.red, value);
    }
}
---

$(P
The complete program has more explanations:
)

---
import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.traits;

/* Specifies that the symbol that it is assigned to should be
 * encrypted. */
struct Encrypted {
}

enum Color { black, blue, red }

/* Specifies the color of the symbol that it is assigned to.
 * The default color is Color.black. */
struct Colored {
    Color color;
}

struct Person {
    /* This member is specified to be encrypted and printed in
     * blue. */
    @Encrypted @Colored(Color.blue) string name;

    /* This member does not have any user defined
     * attributes. */
    string lastName;

    /* This member is specified to be printed in red. */
    @Colored(Color.red) string address;
}

/* Returns the value of the Colored attribute if the specified
 * member has that attribute, Color.black otherwise. */
Color colorAttributeOf(T, string memberName)() {
    auto result = Color.black;

    foreach (attr;
             __traits(getAttributes,
                      __traits(getMember, T, memberName))) {
        static if (is (typeof(attr) == Colored)) {
            result = attr.color;
        }
    }

    return result;
}

/* Returns the Caesar-encrypted version of the specified
 * string. (Warning: Caesar cipher is a very weak encryption
 * method.) */
auto encrypted(string value) {
    return value.map!(a => dchar(a + 1));
}

unittest {
    assert("abcdefghij".encrypted.equal("bcdefghijk"));
}

/* Prints the specified object in XML format according to the
 * attributes of its members. */
void printAsXML(T)(T object) {
    writefln("<%s>", T.stringof);
    scope(exit) writefln("</%s>", T.stringof);

    foreach (member; __traits(allMembers, T)) {
        string value =
            __traits(getMember, object, member).to!string;

        static if (hasUDA!(__traits(getMember, T, member),
                           Encrypted)) {
            value = value.encrypted.to!string;
        }

        writefln(`  <%1$s color="%2$s">%3$s</%1$s>`,
                 member, colorAttributeOf!(T, member), value);
    }
}

void main() {
    auto people = [ Person("Alice", "Davignon", "Avignon"),
                    Person("Ben", "de Bordeaux", "Bordeaux") ];

    foreach (person; people) {
        printAsXML(person);
    }
}
---

$(P
The output of the program shows that the members have the correct color and that the $(C name) member is encrypted:
)

$(SHELL
&lt;Person&gt;
  &lt;name color="blue"&gt;Bmjdf&lt;/name&gt;                $(SHELL_NOTE blue and encrypted)
  &lt;lastName color="black"&gt;Davignon&lt;/lastName&gt;
  &lt;address color="red"&gt;Avignon&lt;/address&gt;         $(SHELL_NOTE red)
&lt;/Person&gt;
&lt;Person&gt;
  &lt;name color="blue"&gt;Cfo&lt;/name&gt;                  $(SHELL_NOTE blue and encrypted)
  &lt;lastName color="black"&gt;de Bordeaux&lt;/lastName&gt;
  &lt;address color="red"&gt;Bordeaux&lt;/address&gt;        $(SHELL_NOTE red)
&lt;/Person&gt;
)

$(H5 The benefit of user defined attributes)

$(P
The benefit of user defined attributes is being able to change the attributes of declarations without needing to change any other part of the program. For example, all of the members of $(C Person) can become encrypted in the XML output by the trivial change below:
)

---
struct Person {
    $(HILITE @Encrypted) {
        string name;
        string lastName;
        string address;
    }
}

// ...

    printAsXML(Person("Cindy", "de Cannes", "Cannes"));
---

$(P
The output:
)

$(SHELL
&lt;Person&gt;
  &lt;name color="black"&gt;Djoez&lt;/name&gt;              $(SHELL_NOTE encrypted)
  &lt;lastName color="black"&gt;ef!Dbooft&lt;/lastName&gt;  $(SHELL_NOTE encrypted)
  &lt;address color="black"&gt;Dbooft&lt;/address&gt;       $(SHELL_NOTE encrypted)
&lt;/Person&gt;
)

$(P
Further, $(C printAsXML()) and the attributes that it considers can be used with other types as well:
)

---
struct Data {
    $(HILITE @Colored(Color.blue)) string message;
}

// ...

    printAsXML(Data("hello world"));
---

$(P
The output:
)

$(SHELL
&lt;Data&gt;
  &lt;message color="blue"&gt;hello world&lt;/message&gt;    $(SHELL_NOTE blue)
&lt;/Data&gt;
)

$(H5 Summary)

$(UL

$(LI User defined attributes can be assigned to any declaration.)

$(LI User defined attributes can be type names as well as values.)

$(LI User defined attributes can be accessed at compile time by $(C hasUDA) and $(C __traits(getAttributes)) to alter the way the program is compiled.)

)

macros:
        TITLE=User Defined Attributes (UDA)

        DESCRIPTION=Assigning user defined attributes to declarations, determining the attributes at compile time, and compiling the code according to those attributes.

        KEYWORDS=d programming language tutorial book user defined attributes UDA
