Ddoc

$(DERS_BOLUMU $(IX enum) $(CH4 enum))

$(P
$(C enum) is the feature that enables defining named constant values.
)

$(H5 $(IX magic constant) Effects of magic constants on code quality)

$(P
The following code appeared in the $(LINK2 arithmetic.cozum.html, exercise solutions) of the Integers and Arithmetic Operations chapter:
)

---
        if (operation == 1) {
            result = first + second;

        } else if (operation == 2) {
            result = first - second;

        } else if (operation == 3) {
            result = first * second;

        } else if (operation == 4) {
            result = first / second;
        }
---

$(P
The integer literals $(C 1), $(C 2), $(C 3), and $(C 4) in that piece of code are called $(I magic constants). It is not easy to determine what each of those literals means in the program. One must examine the code in each scope to determine that $(C 1) means $(I addition), $(C 2) means $(I subtraction), etc. This task is relatively easy for the code above because all of the scopes contain just a single line. It would be considerably more difficult to decipher the meanings of magic constants in most other programs.
)

$(P
Magic constants must be avoided because they impair two important qualities of source code: readability and maintainability.
)

$(P
$(C enum) enables giving names to such constants and, as a consequence, making the code more readable and maintainable. Each condition would be readily understandable if the following $(C enum) constants were used:
)

---
        if (operation == Operation.add) {
            result = first + second;

        } else if (operation == Operation.subtract) {
            result = first - second;

        } else if (operation == Operation.multiply) {
            result = first * second;

        } else if (operation == Operation.divide) {
            result = first / second;
        }
---

$(P
The $(C enum) type $(C Operation) above that obviates the need for magic constants $(C 1), $(C 2), $(C 3), and $(C 4) can be defined like this:
)

---
    enum Operation { add = 1, subtract, multiply, divide }
---

$(H5 The $(C enum) syntax)

$(P
The common definition of an $(C enum) is the following:
)

---
    enum $(I TypeName) { $(I ValueName_1), $(I ValueName_2), /* etc. */ }
---

$(P
Sometimes it is necessary to specify the actual type (the $(I base type)) of the values as well:
)

---
    enum $(I TypeName) $(HILITE : $(I base_type)) { $(I ValueName_1), $(I ValueName_2), /* etc. */ }
---

$(P
We will see how this is used in the next section.
)

$(P
$(I TypeName) defines what the constants collectively mean. All of the member constants of an $(C enum) $(I type) are listed within curly brackets. Here are some examples:
)

---
    enum HeadsOrTails { heads, tails }
    enum Suit { spades, hearts, diamonds, clubs }
    enum Fare { regular, child, student, senior }
---

$(P
Each set of constants becomes part of a separate type. For example, $(C heads) and $(C tails) become members of the type $(C HeadsOrTails). The new type can be used like other fundamental types when defining variables:
)

---
    HeadsOrTails result;           // default initialized
    auto ht = HeadsOrTails.heads;  // inferred type
---

$(P
As has been seen in the pieces of code above, the members of $(C enum) types are always specified by the name of their $(C enum) type:
)

---
    if (result == $(HILITE HeadsOrTails.)heads) {
        // ...
    }
---

$(H5 Actual values and base types)

$(P
The member constants of $(C enum) types are by default implemented as $(C int) values. In other words, although on the surface they appear as just names such as $(C heads) and $(C tails), they also have numerical values. ($(I $(B Note:) It is possible to choose a type other than $(C int) when needed.)).
)

$(P
Unless explicitly specified by the programmer, the numerical values of $(C enum) members start at $(C 0) and are incremented by one for each member. For example, the two members of the $(C HeadsOrTails) $(C enum) have the numerical values 0 and 1:
)

---
    writeln("heads is 0: ", (HeadsOrTails.heads == 0));
    writeln("tails is 1: ", (HeadsOrTails.tails == 1));
---

$(P
The output:
)

$(SHELL
heads is 0: true
tails is 1: true
)

$(P
It is possible to manually (re)set the values at any point in the $(C enum). That was the case when we specified the value of $(C Operation.add) as 1 above. The following example manually sets a new count twice:
)

---
    enum Test { a, b, c, ç $(HILITE = 100), d, e, f $(HILITE = 222), g, ğ }
    writefln("%d %d %d", Test.b, Test.ç, Test.ğ);
---

$(P
The output:
)

$(SHELL
1 100 224
)

$(P
If $(C int) is not suitable as the base type of the $(C enum) values, the base type can be specified explicitly after the name of the $(C enum):
)

---
    enum NaturalConstant $(HILITE : double) { pi = 3.14, e = 2.72 }
    enum TemperatureUnit $(HILITE : string) { C = "Celsius", F = "Fahrenheit" }
---

$(H5 $(C enum) values that are not of an $(C enum) type)

$(P
We have discussed that it is important to avoid magic constants and instead to take advantage of the $(C enum) feature.
)

$(P
However, sometimes it may not be natural to come up with $(C enum) type names just to use named constants. Let's assume that a named constant is needed to represent the number of seconds per day. It should not be necessary to also define an $(C enum) $(I type) to contain this constant value. All that is needed is a constant value that can be referred to by its name. In such cases, the type name of the $(C enum) and the curly brackets are omitted:
)

---
    enum secondsPerDay = 60 * 60 * 24;
---

$(P
The type of the constant can be specified explicitly, which would be required if the type cannot be inferred from the right hand side:
)

---
    enum $(HILITE int) secondsPerDay = 60 * 60 * 24;
---

$(P
Since there is no $(C enum) type to refer to, such named constants can be used in code simply by their names:
)

---
    totalSeconds = totalDays * $(HILITE secondsPerDay);
---

$(P
$(C enum) can be used for defining named constants of other types as well. For example, the type of the following constant would be $(C string):
)

---
    enum fileName = "list.txt";
---

$(P
$(IX manifest constant) $(IX constant, manifest) Such constants are $(LINK2 lvalue_rvalue.html, $(I rvalues)) and they are called $(I manifest constants).
)

$(P
It is possible to create manifest constants of arrays and associative arrays as well. However, as we will see later in $(LINK2 const_and_immutable.html, the Immutability chapter), $(C enum) arrays and associative arrays may have hidden costs.
)

$(H5 Properties)

$(P
The $(C .min) and $(C .max) properties are the minimum and maximum values of an $(C enum) type. When the values of the $(C enum) type are consecutive, they can be iterated over in a $(C for) loop within these limits:
)

---
    enum Suit { spades, hearts, diamonds, clubs }

    for (auto suit = Suit$(HILITE .min); suit <= Suit$(HILITE .max); ++suit) {
        writefln("%s: %d", suit, suit);
    }
---

$(P
Format specifiers $(STRING "%s") and $(STRING "%d") produce different outputs:
)

$(SHELL
spades: 0
hearts: 1
diamonds: 2
clubs: 3
)

$(P
Note that a $(C foreach) loop over that range would leave the $(C .max) value out of the iteration:
)

---
    foreach (suit; Suit.min .. Suit.max) {
        writefln("%s: %d", suit, suit);
    }
---

$(P
The output:
)

$(SHELL
spades: 0
hearts: 1
diamonds: 2
               $(SHELL_NOTE_WRONG clubs is missing)
)

$(P
$(IX EnumMembers, std.traits) For that reason, a correct way of iterating over all values of an $(C enum) is using the $(C EnumMembers) template from the $(C std.traits) module:
)

---
import std.traits;
// ...
    foreach (suit; $(HILITE EnumMembers!Suit)) {
        writefln("%s: %d", suit, suit);
    }
---

$(P
$(I $(B Note:) The $(C !) character above is for template instantiations, which will be covered in $(LINK2 templates.html, a later chapter).)
)

$(SHELL
spades: 0
hearts: 1
diamonds: 2
clubs: 3       $(SHELL_NOTE clubs is present)
)

$(H5 Converting from the base type)

$(P
As we saw in the formatted outputs above, an $(C enum) value can automatically be converted to its base type (e.g. to $(C int)). The reverse conversion is not automatic:
)

---
    Suit suit = 1;       $(DERLEME_HATASI)
---

$(P
One reason for this is to avoid ending up with invalid $(C enum) values:
)

---
    suit = 100;          // ← would be an invalid enum value
---

$(P
The values that are known to correspond to valid $(C enum) values of a particular $(C enum) type can still be converted to that type by an explicit $(I type cast):
)

---
    suit = cast(Suit)1;  // now hearts
---

$(P
It would be the programmer's responsibility to ensure the validity of the values when an explicit cast is used. We will see type casting in $(LINK2 cast.html, a later chapter).
)

$(PROBLEM_TEK

$(P
Modify the calculator program from the exercises of the $(LINK2 arithmetic.html, Integers and Arithmetic Operations chapter) to have the user select the arithmetic operation from a menu.
)

$(P
This program should be different from the previous one in at least the following areas:
)

$(UL
$(LI Use $(C enum) values, not magic constants.)
$(LI Use $(C double) instead of $(C int).)
$(LI Use a $(C switch) statement instead of an "if, else if, else" chain.)
)

)

Macros:
        TITLE=enum

        DESCRIPTION=The enum feature and how it is used to define named constant values.

        KEYWORDS=d programming language tutorial book enum
