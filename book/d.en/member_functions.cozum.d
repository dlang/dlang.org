Ddoc

$(COZUM_BOLUMU Member Functions)

$(OL

$(LI
Potentially negative intermediate values make $(C decrement()) slightly more complicated than $(C increment()):

---
struct TimeOfDay {
    // ...

    void decrement(Duration duration) {
        auto minutesToSubtract = duration.minute % 60;
        auto hoursToSubtract = duration.minute / 60;

        minute -= minutesToSubtract;

        if (minute < 0) {
            minute += 60;
            ++hoursToSubtract;
        }

        hour -= hoursToSubtract;

        if (hour < 0) {
            hour = 24 - (-hour % 24);
        }
    }

    // ...
}
---

)

$(LI
To see how much easier it gets with $(C toString()) member functions, let's look at the $(C Meeting) overload of $(C info()) one more time:

---
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
Taking advantage of the already-defined $(C TimeOfDay.toString), the implementation of $(C Meeting.toString) becomes trivial:
)

---
    string toString() {
        return format("%s-%s \"%s\" meeting with %s attendees",
                      start, end, topic, attendanceCount);
    }
---

$(P
Here is the entire program:
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

    string toString() {
        return format("%02s:%02s", hour, minute);
    }

    void increment(Duration duration) {
        minute += duration.minute;

        hour += minute / 60;
        minute %= 60;
        hour %= 24;
    }
}

struct Meeting {
    string    topic;
    int       attendanceCount;
    TimeOfDay start;
    TimeOfDay end;

    string toString() {
        return format("%s-%s \"%s\" meeting with %s attendees",
                      start, end, topic, attendanceCount);
    }
}

struct Meal {
    TimeOfDay time;
    string    address;

    string toString() {
        TimeOfDay end = time;
        end.increment(Duration(90));

        return format("%s-%s Meal, Address: %s",
                      time, end, address);
    }
}

struct DailyPlan {
    Meeting amMeeting;
    Meal    lunch;
    Meeting pmMeeting;

    string toString() {
        return format("%s\n%s\n%s",
                      amMeeting,
                      lunch,
                      pmMeeting);
    }
}

void main() {
    auto bikeRideMeeting = Meeting("Bike Ride", 4,
                                   TimeOfDay(10, 30),
                                   TimeOfDay(11, 45));

    auto lunch = Meal(TimeOfDay(12, 30), "İstanbul");

    auto budgetMeeting = Meeting("Budget", 8,
                                 TimeOfDay(15, 30),
                                 TimeOfDay(17, 30));

    auto todaysPlan = DailyPlan(bikeRideMeeting,
                                lunch,
                                budgetMeeting);

    writeln(todaysPlan);
    writeln();
}
---

$(P
The output of the program is the same as the earlier one that has been using $(C info()) function overloads:
)

$(SHELL
10:30-11:45 "Bike Ride" meeting with 4 attendees
12:30-14:00 Meal, Address: İstanbul
15:30-17:30 "Budget" meeting with 8 attendees
)

)

)

Macros:
        TITLE=Member Functions

        DESCRIPTION=Programming in D exercise solutions: Member Functions

        KEYWORDS=d programming book tutorial member functions exercise solutions
