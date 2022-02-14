Ddoc

$(DERS_BOLUMU $(IX member function) $(IX function, member) Member Functions)

$(P
Although this chapter focuses only on structs, most of the information in this chapter is applicable to classes as well.
)

$(P
In this chapter we will cover member functions of structs and define the special $(C toString()) member function that is used for representing objects in the $(C string) format.
)

$(P
When a struct or class is defined, usually a number of functions are also defined alongside with it. We have seen examples of such functions in the earlier chapters: $(C addDuration()) and an overload of $(C info()) have been written specifically to be used with the $(C TimeOfDay) type. In a sense, these two functions define the $(I interface) of $(C TimeOfDay).
)

$(P
The first parameter of both $(C addDuration()) and $(C info()) has been the $(C TimeOfDay) object that each function would be operating on. Additionally, just like all of the other functions that we have seen so far, both of the functions have been defined at the $(I module level), outside of any other scope.
)

$(P
The concept of a set of functions determining the interface of a struct is very common. For that reason, functions that are closely related to a type can be defined within the body of that type.
)

$(H5 Defining member functions)

$(P
Functions that are defined within the curly brackets of a $(C struct) are called $(I member functions):
)

---
struct SomeStruct {
    void $(I member_function)(/* the parameters of the function */) {
        // ... the definition of the function ...
    }

    // ... the other members of the struct ...
}
---

$(P
Member functions are accessed the same way as member variables, separated from the name of the object by a dot:
)

---
    $(I object.member_function(arguments));
---

$(P
We have used member functions before when specifying $(C stdin) and $(C stdout) explicitly during input and output operations:
)

---
    stdin.readf(" %s", &number);
    stdout.writeln(number);
---

$(P
The $(C readf()) and $(C writeln()) above are member function calls, operating on the objects $(C stdin) and $(C stdout), respectively.
)

$(P
Let's define $(C info()) as a member function. Its previous definition has been the following:
)

---
void info(TimeOfDay time) {
    writef("%02s:%02s", time.hour, time.minute);
}
---

$(P
Making $(C info()) a member function is not as simple as moving its definition inside the struct. The function must be modified in two ways:
)

---
struct TimeOfDay {
    int hour;
    int minute;

    void info() {    // (1)
        writef("%02s:%02s", hour, minute);    // (2)
    }
}
---

$(OL
$(LI The member function does not take the object explicitly as a parameter.)

$(LI For that reason, it refers to the member variables simply as $(C hour) and $(C minute).)
)

$(P
This is because member functions are always called on an existing object. The object is implicitly available to the member function:
)

---
    auto time = TimeOfDay(10, 30);
    $(HILITE time.)info();
---

$(P
The $(C info()) member function is being called on the $(C time) object above. The members $(C hour) and $(C minute) that are referred to within the function definition correspond to the members of the $(C time) object, specifically $(C time.hour) and $(C time.minute).
)

$(P
The member function call above is almost the equivalent of the following regular function call:
)

---
    time.info();    // member function
    info(time);     // regular function (the previous definition)
---

$(P
Whenever a member function is called on an object, the members of the object are implicitly accessible by the function:
)

---
    auto morning = TimeOfDay(10, 0);
    auto evening = TimeOfDay(22, 0);

    $(HILITE morning.)info();
    write('-');
    $(HILITE evening.)info();
    writeln();
---

$(P
When called on $(C morning), the $(C hour) and $(C minute) that are used inside the member function refer to $(C morning.hour) and $(C morning.minute). Similarly, when called on $(C evening), they refer to $(C evening.hour) and $(C evening.minute):
)

$(SHELL
10:00-22:00
)

$(H6 $(IX toString) $(C toString()) for $(C string) representations)

$(P
We have discussed the limitations of the $(C info()) function in the previous chapter. There is at least one more inconvenience with it: Although it prints the time in human-readable format, printing the $(C '-') character and terminating the line still needs to be done explicitly by the programmer.
)

$(P
However, it would be more convenient if $(C TimeOfDay) objects could be used as easy as fundamental types as in the following code:
)

---
    writefln("%s-%s", morning, evening);
---

$(P
In addition to reducing four lines of code to one, it would also allow printing objects to any stream:
)

---
    auto file = File("time_information", "w");
    file.writefln("%s-%s", morning, evening);
---

$(P
The $(C toString()) member function of user-defined types is treated specially: It is called automatically to produce the $(C string) representations of objects. $(C toString()) must return the $(C string) representation of the object.
)

$(P
Without getting into more detail, let's first see how the $(C toString()) function is defined:
)

---
import std.stdio;

struct TimeOfDay {
    int hour;
    int minute;

    string toString() {
        return "todo";
    }
}

void main() {
    auto morning = TimeOfDay(10, 0);
    auto evening = TimeOfDay(22, 0);

    writefln("%s-%s", morning, evening);
}
---

$(P
$(C toString()) does not produce anything meaningful yet, but the output shows that it has been called by $(C writefln()) twice for the two object:
)

$(SHELL
todo-todo
)

$(P
Also note that $(C info()) is not needed anymore. $(C toString()) is replacing its functionality.
)

$(P
The simplest implementation of $(C toString()) would be to call $(C format()) of the $(C std.string) module. $(C format()) works in the same way as the formatted output functions like $(C writef()). The only difference is that instead of printing variables, it returns the formatted result in $(C string) format.
)

$(P
$(C toString()) can simply return the result of $(C format()) directly:
)

---
import std.string;
// ...
struct TimeOfDay {
// ...
    string toString() {
        return $(HILITE format)("%02s:%02s", hour, minute);
    }
}
---

$(P
Note that $(C toString()) returns the representation of only $(I this) object. The rest of the output is handled by $(C writefln()): It calls the $(C toString()) member function for the two objects separately, prints the $(C '-') character in between, and finally terminates the line:
)

$(SHELL
10:00-22:00
)

$(P
The definition of $(C toString()) that is explained above does not take any parameters; it simply produces a $(C string) and returns it. An alternative definition of $(C toString()) takes a $(C delegate) parameter. We will see that definition later in $(LINK2 lambda.html, the Function Pointers, Delegates, and Lambdas chapter).
)

$(H6 Example: $(C increment()) member function)

$(P
Let's define a member function that adds a duration to $(C TimeOfDay) objects.
)

$(P
Before doing that, let's first correct a design flaw that we have been living with. We have seen in the $(LINK2 struct.html, Structs chapter) that adding two $(C TimeOfDay) objects in $(C addDuration()) is not a meaningful operation:
)

---
TimeOfDay addDuration(TimeOfDay start,
                      TimeOfDay duration) {  // meaningless
    // ...
}
---

$(P
What is natural to add to a point in time is $(I duration). For example, adding the travel duration to the departure time would result in the arrival time.
)

$(P
On the other hand, subtracting two points in time is a natural operation, in which case the result would be a $(I duration).
)

$(P
The following program defines a $(C Duration) struct with minute-precision, and an $(C addDuration()) function that uses it:
)

---
struct Duration {
    int minute;
}

TimeOfDay addDuration(TimeOfDay start,
                      Duration duration) {
    // Begin with a copy of start
    TimeOfDay result = start;

    // Add the duration to it
    result.minute += duration.minute;

    // Take care of overflows
    result.hour += result.minute / 60;
    result.minute %= 60;
    result.hour %= 24;

    return result;
}

unittest {
    // A trivial test
    assert(addDuration(TimeOfDay(10, 30), Duration(10))
           == TimeOfDay(10, 40));

    // A time at midnight
    assert(addDuration(TimeOfDay(23, 9), Duration(51))
           == TimeOfDay(0, 0));

    // A time in the next day
    assert(addDuration(TimeOfDay(17, 45), Duration(8 * 60))
           == TimeOfDay(1, 45));
}
---

$(P
Let's redefine a similar function this time as a member function. $(C addDuration()) has been producing a new object as its result. Let's define an $(C increment()) member function that will directly modify $(I this) object instead:
)

---
struct Duration {
    int minute;
}

struct TimeOfDay {
    int hour;
    int minute;

    string toString() {
        return format("%02s:%02s", hour, minute);
    }

    void $(HILITE increment)(Duration duration) {
        minute += duration.minute;

        hour += minute / 60;
        minute %= 60;
        hour %= 24;
    }

    unittest {
        auto time = TimeOfDay(10, 30);

        // A trivial test
        time$(HILITE .increment)(Duration(10));
        assert(time == TimeOfDay(10, 40));

        // 15 hours later must be in the next day
        time$(HILITE .increment)(Duration(15 * 60));
        assert(time == TimeOfDay(1, 40));

        // 22 hours 20 minutes later must be midnight
        time$(HILITE .increment)(Duration(22 * 60 + 20));
        assert(time == TimeOfDay(0, 0));
    }
}
---

$(P
$(C increment()) increments the value of the object by the specified amount of duration. In a later chapter we will see how the $(I operator overloading) feature of D will make it possible to add a duration by the $(C +=) operator syntax:
)

---
    time += Duration(10);    // to be explained in a later chapter
---

$(P
Also note that $(C unittest) blocks can be written inside $(C struct) definitions as well, mostly for testing member functions. It is still possible to move such $(C unittest) blocks outside of the body of the struct:
)

---
struct TimeOfDay {
    // ... struct definition ...
}

unittest {
    // ... struct tests ...
}
---

$(PROBLEM_COK

$(PROBLEM
Add a $(C decrement()) member function to $(C TimeOfDay), which should reduce the time by the specified amount of duration. Similar to $(C increment()), it should $(I overflow) to the previous day when there is not enough time in the current day. For example, subtracting 10 minutes from 00:05 should result in 23:55.

$(P
In other words, implement $(C decrement()) to pass the following unit tests:
)

---
struct TimeOfDay {
    // ...

    void decrement(Duration duration) {
        // ... please implement this function ...
    }

    unittest {
        auto time = TimeOfDay(10, 30);

        // A trivial test
        time.decrement(Duration(12));
        assert(time == TimeOfDay(10, 18));

        // 3 days and 11 hours earlier
        time.decrement(Duration(3 * 24 * 60 + 11 * 60));
        assert(time == TimeOfDay(23, 18));

        // 23 hours and 18 minutes earlier must be midnight
        time.decrement(Duration(23 * 60 + 18));
        assert(time == TimeOfDay(0, 0));

        // 1 minute earlier
        time.decrement(Duration(1));
        assert(time == TimeOfDay(23, 59));
    }
}
---

)

$(PROBLEM
Convert $(C Meeting), $(C Meal), and $(C DailyPlan) overloads of $(C info()) to $(C toString()) member functions as well. (See $(LINK2 function_overloading.cozum.html, the exercise solutions of the Function Overloading chapter) for their $(C info()) overloads.)

$(P
You will notice that in addition to making their respective structs more convenient, the implementations of the $(C toString()) member functions will all consist of single lines.
)

)

)

Macros:
        TITLE=Member Functions

        DESCRIPTION=Adding special functionality to structs (and classes) as member functions in the D programming language.

        KEYWORDS=d programming lesson book tutorial member functions
