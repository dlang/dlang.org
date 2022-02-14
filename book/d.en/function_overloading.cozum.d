Ddoc

$(COZUM_BOLUMU Function Overloading)

$(P
The following two overloads take advantage of the existing $(C info()) overloads:
)

---
void info(Meal meal) {
    info(meal.time);
    write('-');
    info(addDuration(meal.time, TimeOfDay(1, 30)));

    write(" Meal, Address: ", meal.address);
}

void info(DailyPlan plan) {
    info(plan.amMeeting);
    writeln();
    info(plan.lunch);
    writeln();
    info(plan.pmMeeting);
}
---

$(P
Here is the entire program that uses all of these types:
)

---
import std.stdio;

struct TimeOfDay {
    int hour;
    int minute;
}

void info(TimeOfDay time) {
    writef("%02s:%02s", time.hour, time.minute);
}

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

struct Meal {
    TimeOfDay time;
    string    address;
}

void info(Meal meal) {
    info(meal.time);
    write('-');
    info(addDuration(meal.time, TimeOfDay(1, 30)));

    write(" Meal, Address: ", meal.address);
}

struct DailyPlan {
    Meeting amMeeting;
    Meal    lunch;
    Meeting pmMeeting;
}

void info(DailyPlan plan) {
    info(plan.amMeeting);
    writeln();
    info(plan.lunch);
    writeln();
    info(plan.pmMeeting);
}

void main() {
    immutable bikeRideMeeting = Meeting("Bike Ride", 4,
                                        TimeOfDay(10, 30),
                                        TimeOfDay(11, 45));

    immutable lunch = Meal(TimeOfDay(12, 30), "İstanbul");

    immutable budgetMeeting = Meeting("Budget", 8,
                                      TimeOfDay(15, 30),
                                      TimeOfDay(17, 30));

    immutable todaysPlan = DailyPlan(bikeRideMeeting,
                                     lunch,
                                     budgetMeeting);

    info(todaysPlan);
    writeln();
}
---

$(P
That $(C main()) function can also be written with only object literals:
)

---
void $(CODE_DONT_TEST)main() {
    info(DailyPlan(Meeting("Bike Ride", 4,
                           TimeOfDay(10, 30),
                           TimeOfDay(11, 45)),

                   Meal(TimeOfDay(12, 30), "İstanbul"),

                   Meeting("Budget", 8,
                           TimeOfDay(15, 30),
                           TimeOfDay(17, 30))));

    writeln();
}
---


Macros:
        TITLE=Function Overloading

        DESCRIPTION=Programming in D exercise solutions: Function Overloading

        KEYWORDS=d programming book tutorial function overloading exercise solutions
