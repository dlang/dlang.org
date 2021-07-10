Ddoc
$(COZUM_BOLUMU $(CH4 assert) and $(CH4 enforce))

$(OL

$(LI
You will notice that the program terminates normally when you enter $(C 06:09) and $(C 1:2). However, you may notice that the start time is not what has been entered by the user:

$(SHELL
1 hours and 2 minutes after 09:06 is 10:08.
)

$(P
As you can see, although the time that has been entered as $(C 06:09), the output contains $(C 09:06). This error will be caught by the help of an $(C assert) in the next problem.
)

)

$(LI
The $(C assert) failure after entering $(C 06:09) and $(C 15:2) takes us to the following line:

---
string timeToString(int hour, int minute) {
    $(HILITE assert((hour >= 0) && (hour <= 23));)
    // ...
}
---

$(P
For this $(C assert) check to fail, this function must have been called with invalid $(C hour) value.
)

$(P
The only two calls to $(C timeToString()) in the program do not appear to have any problems:
)

---
    writefln("%s hours and %s minutes after %s is %s.",
             durationHour, durationMinute,
             $(HILITE timeToString)(startHour, startMinute),
             $(HILITE timeToString)(endHour, endMinute));
---

$(P
A little more investigation should reveal the actual cause of the bug: The hour and minute variables are swapped when reading the start time:
)

---
    readTime("Start time", start$(HILITE Minute), start$(HILITE Hour));
---

$(P
That programming error causes the time to be interpreted as $(C 09:06) and incrementing it by duration $(C 15:2) causes an invalid hour value.
)

$(P
An obvious correction is to pass the hour and minute variables in the right order:
)

---
    readTime("Start time", startHour, startMinute);
---

$(P
The output:
)

$(SHELL
Start time? (HH:MM) 06:09
Duration? (HH:MM) 15:2
15 hours and 2 minutes after 06:09 is 21:11.
)

)

$(LI
It is again the same $(C assert) check:

---
    assert((hour >= 0) && (hour <= 23));
---

$(P
The reason is that $(C addDuration()) can produce hour values that are greater than 23. Adding a $(I remainder) operation at the end would ensure one of the $(I output guarantees) of the function:
)

---
void addDuration(int startHour, int startMinute,
                 int durationHour, int durationMinute,
                 out int resultHour, out int resultMinute) {
    resultHour = startHour + durationHour;
    resultMinute = startMinute + durationMinute;

    if (resultMinute > 59) {
        ++resultHour;
    }

    $(HILITE resultHour %= 24;)
}
---

$(P
Observe that the function has other problems. For example, $(C resultMinute) may end up being greater than 59. The following function calculates the minute value correctly and makes sure that the function's output guarantees are enforced:
)

---
void addDuration(int startHour, int startMinute,
                 int durationHour, int durationMinute,
                 out int resultHour, out int resultMinute) {
    resultHour = startHour + durationHour;
    resultMinute = startMinute + durationMinute;

    resultHour += resultMinute / 60;
    resultHour %= 24;
    resultMinute %= 60;

    assert((resultHour >= 0) && (resultHour <= 23));
    assert((resultMinute >= 0) && (resultMinute <= 59));
}
---

)

$(LI
Good luck.
)

)

Macros:
        TITLE=assert and enforce Solutions

        DESCRIPTION=Programming in D exercise solutions: assert and enforce

        KEYWORDS=programming in d tutorial functions
