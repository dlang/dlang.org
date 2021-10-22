Ddoc

$(DERS_BOLUMU $(CH4 const ref) Parameters and $(CH4 const) Member Functions)

$(P
This chapter is about how parameters and member functions are marked as $(C const) so that they can be used with $(C immutable) variables as well. As we have already covered $(C const) parameters in earlier chapters, some information in this chapter will be a review of some of the features that you already know.
)

$(P
Although the examples in this chapter use only structs, $(C const) member functions apply to classes as well.
)

$(H5 $(C immutable) objects)

$(P
We have already seen that it is not possible to modify $(C immutable) variables:
)

---
    immutable readingTime = TimeOfDay(15, 0);
---

$(P
$(C readingTime) cannot be modified:
)

---
    readingTime = TimeOfDay(16, 0);    $(DERLEME_HATASI)
    readingTime.minute += 10;          $(DERLEME_HATASI)
---

$(P
The compiler does not allow modifying $(C immutable) objects in any way.
)

$(H5 $(C ref) parameters that are not $(C const))

$(P
We have seen this concept earlier in the $(LINK2 function_parameters.html, Function Parameters chapter). Parameters that are marked as $(C ref) can freely be modified by the function. For that reason, even if the function does not actually modify the parameter, the compiler does not allow passing $(C immutable) objects as that parameter:
)

---
/* Although not being modified by the function, 'duration'
 * is not marked as 'const' */
int totalSeconds(ref Duration duration) {
    return 60 * duration.minute;
}
// ...
    $(HILITE immutable) warmUpTime = Duration(3);
    totalSeconds(warmUpTime);    $(DERLEME_HATASI)
---

$(P
The compiler does not allow passing the $(C immutable) $(C warmUpTime) to $(C totalSeconds) because that function does not guarantee that the parameter will not be modified.
)

$(H5 $(IX const ref) $(IX ref const) $(IX parameter, const ref) $(C const ref) parameters)

$(P
$(C const ref) means that the parameter is not modified by the function:
)

---
int totalSeconds(const ref Duration duration) {
    return 60 * duration.minute;
}
// ...
    immutable warmUpTime = Duration(3);
    totalSeconds(warmUpTime);    // ← now compiles
---

$(P
Such functions can receive $(C immutable) objects as parameters because the immutability of the object is enforced by the compiler:
)

---
int totalSeconds(const ref Duration duration) {
    duration.minute = 7;    $(DERLEME_HATASI)
// ...
}
---

$(P
$(IX in ref) $(IX ref in) $(IX parameter, in ref) An alternative to $(C const ref) is $(C in ref). As we will see in $(LINK2 function_parameters.html, a later chapter), $(C in) means that the parameter is used only as input to the function, disallowing any modification to it.
)

---
int totalSeconds($(HILITE in ref) Duration duration) {
    // ...
}
---

$(H5 Non-$(C const) member functions)

$(P
As we have seen with the $(C TimeOfDay.increment) member function, objects can be modified through member functions as well. $(C increment()) modifies the members of the object that it is called on:
)

---
struct TimeOfDay {
// ...
    void increment(Duration duration) {
        minute += duration.minute;

        hour += minute / 60;
        minute %= 60;
        hour %= 24;
    }
// ...
}
// ...
    auto start = TimeOfDay(5, 30);
    start.increment(Duration(30));          // 'start' gets modified
---

$(H5 $(IX const, member function) $(C const) member functions )

$(P
Some member functions do not make any modifications to the object that they are called on. An example of such a function is $(C toString()):
)

---
struct TimeOfDay {
// ...
    string toString() {
        return format("%02s:%02s", hour, minute);
    }
// ...
}
---

$(P
Since the whole purpose of $(C toString()) is to represent the object in string format anyway, it should not modify the object.
)

$(P
The fact that a member function does not modify the object is declared by the $(C const) keyword after the parameter list:
)

---
struct TimeOfDay {
// ...
    string toString() $(HILITE const) {
        return format("%02s:%02s", hour, minute);
    }
}
---

$(P
That $(C const) guarantees that the object itself is not going to be modified by the member function. As a consequence, $(C toString()) member function is allowed to be called even on $(C immutable) objects. Otherwise, the struct's $(C toString()) would not be called:
)

---
struct TimeOfDay {
// ...
    // Inferior design: Not marked as 'const'
    string toString() {
        return format("%02s:%02s", hour, minute);
    }
}
// ...
    $(HILITE immutable) start = TimeOfDay(5, 30);
    writeln(start);    // TimeOfDay.toString() is not called!
---

$(P
The output is not the expected $(C 05:30), indicating that a generic function gets called instead of $(C TimeOfDay.toString):
)

$(SHELL
immutable(TimeOfDay)(5, 30)
)

$(P
Further, calling $(C toString()) on an $(C immutable) object explicitly would cause a compilation error:
)

---
    auto s = start.toString(); $(DERLEME_HATASI)
---

$(P
Accordingly, the $(C toString()) functions that we have defined in the previous chapter have all been designed incorrectly; they should have been marked as $(C const).
)

$(P $(I $(B Note:) The $(C const) keyword can be specified before the definition of the function as well:)
)

---
    // The same as above
    $(HILITE const) string toString() {
        return format("%02s:%02s", hour, minute);
    }
---

$(P $(I Since this version may give the incorrect impression that the $(C const) is a part of the return type, I recommend that you specify it after the parameter list.)
)

$(H5 $(IX inout, member function) $(C inout) member functions)

$(P
As we have seen in $(LINK2 function_parameters.html, the Function Parameters chapter), $(C inout) transfers the mutability of a parameter to the return type.
)

$(P
Similarly, an $(C inout) member function transfers the mutability of the $(I object) to the function's return type:
)

---
import std.stdio;

struct Container {
    int[] elements;

    $(HILITE inout)(int)[] firstPart(size_t n) $(HILITE inout) {
        return elements[0 .. n];
    }
}

void main() {
    {
        // An immutable container
        auto container = $(HILITE immutable)(Container)([ 1, 2, 3 ]);
        auto slice = container.firstPart(2);
        writeln(typeof(slice).stringof);
    }
    {
        // A const container
        auto container = $(HILITE const)(Container)([ 1, 2, 3 ]);
        auto slice = container.firstPart(2);
        writeln(typeof(slice).stringof);
    }
    {
        // A mutable container
        auto container = Container([ 1, 2, 3 ]);
        auto slice = container.firstPart(2);
        writeln(typeof(slice).stringof);
    }
}
---

$(P
The three slices that are returned by the three objects of different mutability are consistent with the objects that returned them:
)

$(SHELL
$(HILITE immutable)(int)[]
$(HILITE const)(int)[]
int[]
)

$(P
Because it must be called on $(C const) and $(C immutable) objects as well, an $(C inout) member function is compiled as if it were $(C const).
)

$(H5 How to use)

$(UL

$(LI
To give the guarantee that a parameter is not modified by the function, mark that parameter as $(C in), $(C const), or $(C const ref).
)

$(LI
Mark member functions that do not modify the object as $(C const):

---
struct TimeOfDay {
// ...
    string toString() $(HILITE const) {
        return format("%02s:%02s", hour, minute);
    }
}
---

$(P
This would make the struct (or class) more useful by removing an unnecessary limitation. The examples in the rest of the book will observe this guideline.
)

)

)

Macros:
        TITLE=const ref Parameters and const Member Functions

        DESCRIPTION=The const ref parameters and the const member functions of the D programming language

        KEYWORDS=d programming lesson book tutorial const member functions
