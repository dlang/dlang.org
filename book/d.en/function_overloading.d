Ddoc

$(DERS_BOLUMU $(IX function overloading) $(IX overloading, function) Function Overloading)

$(P
Defining more than one function having the same name is $(I function overloading). In order to be able to differentiate these functions, their parameters must be different. 
)

$(P
The following code has multiple overloads of the $(C info()) function, each taking a different type of parameter:
)

---
import std.stdio;

void info($(HILITE double) number) {
    writeln("Floating point: ", number);
}

void info($(HILITE int) number) {
    writeln("Integer       : ", number);
}

void info($(HILITE string) str) {
    writeln("String        : ", str);
}

void main() {
    info(1.2);
    info(3);
    info("hello");
}
---

$(P
Although all of the functions are named $(C info()), the compiler picks the one that matches the argument that is used when making the call. For example, because the literal $(C 1.2) is of type $(C double), the $(C info()) function that takes a $(C double) gets called for it.
)

$(P
The choice of which function to call is made at compile time, which may not always be easy or clear. For example, because $(C int) can implicitly be converted to both $(C double) and $(C real), the compiler cannot decide which of the functions to call in the following program:
)

---
real sevenTimes(real value) {
    return 7 * value;
}

double sevenTimes(double value) {
    return 7 * value;
}

void main() {
    int value = 5;
    auto result = sevenTimes(value);    $(DERLEME_HATASI)
}
---

$(P
$(I $(B Note:) It is usually unnecessary to write separate functions when the function bodies are exactly the same. We will see later in the $(LINK2 templates.html, Templates chapter) how a single definition can be used for multiple types.)
)

$(P
However, if there is another function overload that takes a $(C long) parameter, then the ambiguity would be resolved because $(C long) is a $(I better match) for $(C int) than $(C double) or $(C real):
)

---
long sevenTimes(long value) {
    return 7 * value;
}

// ...

    auto result = sevenTimes(value);    // now compiles
---

$(H5 Overload resolution)

$(P
The compiler picks the overload that is the $(I best match) for the arguments. This is called overload resolution.
)

$(P
Although overload resolution is simple and intuitive in most cases, it is sometimes complicated. The following are the rules of overload resolution. They are being presented in a simplified way in this book.
)

$(P
There are four states of match, listed from the worst to the best:
)

$(UL
$(LI mismatch)
$(LI match through automatic type conversion)
$(LI match through $(C const) qualification)
$(LI exact match)
)

$(P
The compiler considers all of the overloads of a function during overload resolution. It first determines the match state of every parameter for every overload. For each overload, the least match state among the parameters is taken to be the match state of that overload.
)

$(P
After all of the match states of the overloads are determined, then the overload with the best match is selected. If there are more than one overload that has the best match, then more complicated resolution rules are applied. I will not get into more details of these rules in this book. If your program is in a situation where it depends on complicated overload resolution rules, it may be an indication that it is time to change the design of the program. Another option is to take advantage of other features of D, like templates. An even simpler but not always desirable approach would be to abandon function overloading altogether by naming functions differently for each type e.g. like $(C sevenTimes_real()) and $(C sevenTimes_double()).
)

$(H5 Function overloading for user-defined types)

$(P
Function overloading is useful with structs and classes as well. Additionally, overload resolution ambiguities are much less frequent with user-defined types. Let's overload the $(C info()) function above for some of the types that we have defined in the $(LINK2 struct.html, Structs chapter):
)

---
struct TimeOfDay {
    int hour;
    int minute;
}

void info(TimeOfDay time) {
    writef("%02s:%02s", time.hour, time.minute);
}
---

$(P
That overload enables $(C TimeOfDay) objects to be used with $(C info()). As a result, variables of user-defined types can be printed in exactly the same way as fundamental types:
)

---
    auto breakfastTime = TimeOfDay(7, 0);
    info(breakfastTime);
---

$(P
The $(C TimeOfDay) objects would be matched with that overload of $(C info()):
)

$(SHELL
07:00
)

$(P
The following is an overload of $(C info()) for the $(C Meeting) type:
)

---
struct Meeting {
    string    topic;
    size_t    attendanceCount;
    TimeOfDay start;
    TimeOfDay end;
}

void info(Meeting meeting) {
    info(meeting.start);
    write('-');
    info(meeting.end);

    writef(" \"%s\" meeting with %s attendees",
           meeting.topic,
           meeting.attendanceCount);
}
---

$(P
Note that this overload makes use of the already-defined overload for $(C TimeOfDay). $(C Meeting) objects can now be printed in exactly the same way as fundamental types as well:
)

---
    auto bikeRideMeeting = Meeting("Bike Ride", 3,
                                   TimeOfDay(9, 0),
                                   TimeOfDay(9, 10));
    info(bikeRideMeeting);
---

$(P
The output:
)

$(SHELL
09:00-09:10 "Bike Ride" meeting with 3 attendees
)

$(H5 Limitations)

$(P
Although the $(C info()) function overloads above are a great convenience, this method has some limitations:
)

$(UL

$(LI
$(C info()) always prints to $(C stdout). It would be more useful if it could print to any $(C File). One way of achieving this is to pass the output stream as a parameter as well e.g. for the $(C TimeOfDay) type:

---
void info(File file, TimeOfDay time) {
    file.writef("%02s:%02s", time.hour, time.minute);
}
---

$(P
That would enable printing $(C TimeOfDay) objects to any file, including $(C stdout):
)

---
    info($(HILITE stdout), breakfastTime);

    auto file = File("a_file", "w");
    info($(HILITE file), breakfastTime);
---

$(P
$(I $(B Note:) The special objects $(C stdin), $(C stdout), and $(C stderr) are of type $(C File).)
)

)

$(LI
More importantly, $(C info()) does not solve the more general problem of producing the string representation of variables. For example, it does not help with passing objects of user-defined types to $(C writeln()):

---
    writeln(breakfastTime);  // Not useful: prints in generic format
---

$(P
The code above prints the object in a generic format that includes the name of the type and the values of its members, not in a way that would be useful in the program:
)

$(SHELL
TimeOfDay(7, 0)
)

$(P
It would be much more useful if there were a function that converted $(C TimeOfDay) objects to $(C string) in their special format as in $(STRING "12:34"). We will see how to define $(C string) representations of struct objects in the next chapter.
)

)

)

$(PROBLEM_TEK

$(P
Overload the $(C info()) function for the following structs as well:
)

---
struct Meal {
    TimeOfDay time;
    string    address;
}

struct DailyPlan {
    Meeting amMeeting;
    Meal    lunch;
    Meeting pmMeeting;
}
---

$(P
Since $(C Meal) has only the start time, add an hour and a half to determine its end time. You can use the $(C addDuration()) function that we have defined earlier in the structs chapter:
)

---
TimeOfDay addDuration(TimeOfDay start,
                      TimeOfDay duration) {
    TimeOfDay result;

    result.minute = start.minute + duration.minute;
    result.hour = start.hour + duration.hour;
    result.hour += result.minute / 60;

    result.minute %= 60;
    result.hour %= 24;

    return result;
}
---

$(P
Once the end times of $(C Meal) objects are calculated by $(C addDuration()), $(C DailyPlan) objects should be printed as in the following output:
)

$(SHELL
10:30-11:45 "Bike Ride" meeting with 4 attendees
12:30-14:00 Meal, Address: İstanbul
15:30-17:30 "Budget" meeting with 8 attendees
)

)

Macros:
        TITLE=Function Overloading

        DESCRIPTION=The function overloading feature of the D programming language, which increases the usability of functions by bringing uniformity through many types.

        KEYWORDS=d programming lesson book tutorial function overloading
