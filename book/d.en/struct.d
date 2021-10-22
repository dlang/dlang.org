Ddoc

$(DERS_BOLUMU $(IX struct) Structs)

$(P
As has been mentioned several times earlier in the book, fundamental types are not suitable to represent higher-level concepts. For example, although a value of type $(C int) is suitable to represent the hour of day, two $(C int) variables would be more suitable together to represent a point in time: one for the hour and the other for the minute.
)

$(P
$(IX user defined type) Structs are the feature that allow defining new types by combining already existing other types. The new type is defined by the $(C struct) keyword. By this definition, structs are $(I user defined types). Most of the content of this chapter is directly applicable to classes as well. Especially the concept of $(I combining existing types to define a new type) is exactly the same for them.
)

$(P
This chapter covers only the basic features of structs. We will see more of structs in the following chapters:
)

$(UL
$(LI $(LINK2 member_functions.html, Member Functions))
$(LI $(LINK2 const_member_functions.html, const ref Parameters and const Member Functions))
$(LI $(LINK2 special_functions.html, Constructor and Other Special Functions))
$(LI $(LINK2 operator_overloading.html, Operator Overloading))
$(LI $(LINK2 encapsulation.html, Encapsulation and Protection Attributes))
$(LI $(LINK2 property.html, Properties))
$(LI $(LINK2 invariant.html, Contract Programming for Structs and Classes))
$(LI $(LINK2 foreach_opapply.html, foreach with Structs and Classes))
)

$(P
To understand how useful structs are, let's take a look at the $(C addDuration()) function that we had defined earlier in the $(LINK2 assert.html, $(C assert) and $(C enforce) chapter). The following definition is from the exercise solution of that chapter:
)

---
void addDuration(int startHour, int startMinute,
                 int durationHour, int durationMinute,
                 out int resultHour, out int resultMinute) {
    resultHour = startHour + durationHour;
    resultMinute = startMinute + durationMinute;
    resultHour += resultMinute / 60;

    resultMinute %= 60;
    resultHour %= 24;
}
---

$(P $(I $(B Note:) I will ignore the $(C in), $(C out), and $(C unittest) blocks in this chapter to keep the code samples short.)
)

$(P
Although the function above clearly takes six parameters, when the three pairs of parameters are considered, it is conceptually taking only three bits of information for the starting time, the duration, and the result.
)

$(H5 Definition)

$(P
The $(C struct) keyword defines a new type by combining variables that are related in some way:
)

---
$(CODE_NAME TimeOfDay)struct TimeOfDay {
    int hour;
    int minute;
}
---

$(P
The code above defines a new type named $(C TimeOfDay), which consists of two variables named $(C hour) and $(C minute). That definition allows the new $(C TimeOfDay) type to be used in the program just like any other type. The following code demonstrates how similar its use is to an $(C int)'s:
)

---
    int number;            // a variable
    number = otherNumber;  // taking the value of otherNumber

    TimeOfDay time;        // an object
    time = otherTime;      // taking the value of otherTime
---

$(P
The syntax of $(C struct) definition is the following:
)

---
struct $(I TypeName) {
    // ... member variables and functions ...
}
---

$(P
We will see member functions in later chapters.
)

$(P
The variables that a struct combines are called its $(I members). According to this definition, $(C TimeOfDay) has two members: $(C hour) and $(C minute).
)

$(H6 $(C struct) defines a type, not a variable)

$(P
There is an important distinction here: Especially after the $(LINK2 name_space.html, Name Scope) and $(LINK2 lifetimes.html, Lifetimes and Fundamental Operations) chapters, the curly brackets of $(C struct) definitions may give the wrong impression that the struct members start and end their lives inside that scope. This is not true.
)

$(P
Member definitions are not variable definitions:
)

---
struct TimeOfDay {
    int hour;      // ← Not a variable; will become a part of
                   //   a struct variable used in the program.

    int minute;    // ← Not a variable; will become a part of
                   //   a struct variable used in the program.
}
---

$(P
The definition of a $(C struct) determines the types and the names of the members that the objects of that $(C struct) will have. Those member variables will be constructed as parts of $(C TimeOfDay) objects that take part in the program:
)

---
    TimeOfDay bedTime;    // This object contains its own hour
                          // and minute member variables.

    TimeOfDay wakeUpTime; // This object contains its own hour
                          // and minute member variables as
                          // well. The member variables of
                          // this object are not related to
                          // the member variables of the
                          // previous object.
---

$(P
$(IX object, struct) Variables of $(C struct) and $(C class) types are called $(I objects).
)

$(H6 Coding convenience)

$(P
Being able to combine the concepts of hour and minute together as a new type is a great convenience. For example, the function above can be rewritten in a more meaningful way by taking three $(C TimeOfDay) parameters instead of the existing six $(C int) parameters:
)

---
void addDuration(TimeOfDay start,
                 TimeOfDay duration,
                 out TimeOfDay result) {
    // ...
}
---

$(P $(I $(B Note:) It is not normal to add two variables that represent two points in time. For example, it is meaningless to add the lunch time 12:00 to the breakfast time 7:30. It would make more sense to define another type, appropriately called $(C Duration), and to add objects of that type to $(C TimeOfDay) objects. Despite this design flaw, I will continue using only $(C TimeOfDay) objects in this chapter and introduce $(C Duration) in a later chapter.)
)

$(P
As you remember, functions return up-to a single value. That has precisely been the reason why the earlier definition of $(C addDuration()) was taking two $(C out) parameters: It could not return the hour and minute information as a single value.
)

$(P
Structs remove this limitation as well: Since multiple values can be combined as a single $(C struct) type, functions can return an object of such a $(C struct), effectively returning multiple values at once. $(C addDuration()) can now be defined as returning its result:
)

---
TimeOfDay addDuration(TimeOfDay start,
                      TimeOfDay duration) {
    // ...
}
---

$(P
As a consequence, $(C addDuration()) now becomes a function that produces a value, as opposed to being a function that has side effects. As you would remember from the $(LINK2 functions.html, Functions chapter), producing results is preferred over having side effects.
)

$(P
Structs can be members of other structs. For example, the following $(C struct) has two $(C TimeOfDay) members:
)

---
struct Meeting {
    string    topic;
    size_t    attendanceCount;
    TimeOfDay start;
    TimeOfDay end;
}
---

$(P
$(C Meeting) can in turn be a member of another $(C struct). Assuming that there is also the $(C Meal) struct:
)

---
struct DailyPlan {
    Meeting projectMeeting;
    Meal    lunch;
    Meeting budgetMeeting;
}
---

$(H5 $(IX ., member) Accessing the members)

$(P
Struct members are used like any other variable. The only difference is that the actual struct variable and a $(I dot) must be specified before the name of the member:
)

---
    start.hour = 10;
---

$(P
The line above assigns the value 10 to the $(C hour) member of the $(C start) object.
)

$(P
Let's rewrite the $(C addDuration()) function with what we have seen so far:
)

---
$(CODE_NAME addDuration)TimeOfDay addDuration(TimeOfDay start,
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
Notice that the names of the variables are now much shorter in this version of the function: $(C start), $(C duration), and $(C result). Additionally, instead of using complex names like $(C startHour), it is possible to access struct members through their respective struct variables as in $(C start.hour).
)

$(P
Here is a code that uses the new $(C addDuration()) function. Given the start time and the duration, the following code calculates when a class period at a school would end:
)

---
$(CODE_XREF TimeOfDay)$(CODE_XREF addDuration)void main() {
    TimeOfDay periodStart;
    periodStart.hour = 8;
    periodStart.minute = 30;

    TimeOfDay periodDuration;
    periodDuration.hour = 1;
    periodDuration.minute = 15;

    immutable periodEnd = addDuration(periodStart,
                                      periodDuration);

    writefln("Period end: %s:%s",
              periodEnd.hour, periodEnd.minute);
}
---

$(P
The output:
)

$(SHELL
Period end: 9:45
)

$(P
The $(C main()) above has been written only by what we have seen so far. We will make this code even shorter and cleaner soon.
)

$(H5 $(IX construction) Construction)

$(P
The first three lines of $(C main()) are about constructing the $(C periodStart) object and the next three lines are about constructing the $(C periodDuration) object. In each three lines of code first an object is being defined and then its hour and minute values are being set.
)

$(P
In order for a variable to be used in a safe way, that variable must first be constructed in a consistent state. Because construction is so common, there is a special construction syntax for struct objects:
)

---
    TimeOfDay periodStart = TimeOfDay(8, 30);
    TimeOfDay periodDuration = TimeOfDay(1, 15);
---

$(P
The values are automatically assigned to the members in the order that they are specified: Because $(C hour) is defined first in the $(C struct), the value 8 is assigned to $(C periodStart.hour) and 30 is assigned to $(C periodStart.minute).
)

$(P
As we have seen in $(LINK2 cast.html, the Type Conversions chapter), the construction syntax can be used for other types as well:
)

---
    auto u = ubyte(42);    // u is a ubyte
    auto i = int(u);       // i is an int
---

$(H6 Constructing objects as $(C immutable))

$(P
Being able to construct the object by specifying the values of its members at once makes it possible to define objects as $(C immutable):
)

---
    immutable periodStart = TimeOfDay(8, 30);
    immutable periodDuration = TimeOfDay(1, 15);
---

$(P
Otherwise it would not be possible to mark an object first as $(C immutable) and then modify its members:
)

---
    $(HILITE immutable) TimeOfDay periodStart;
    periodStart.hour = 8;      $(DERLEME_HATASI)
    periodStart.minute = 30;   $(DERLEME_HATASI)
---

$(H6 Trailing members need not be specified)

$(P
There may be fewer values specified than the number of members. In that case, the remaining members are initialized by the $(C .init) values of their respective types.
)

$(P
The following program constructs $(C Test) objects each time with one less constructor parameter. The $(C assert) checks indicate that the unspecified members are initialized automatically by their $(C .init) values. (The reason for needing to call $(C isNaN()) is explained after the program):
)

---
import std.math;

struct Test {
    char   c;
    int    i;
    double d;
}

void main() {
    // The initial values of all of the members are specified
    auto t1 = Test('a', 1, 2.3);
    assert(t1.c == 'a');
    assert(t1.i == 1);
    assert(t1.d == 2.3);

    // Last one is missing
    auto t2 = Test('a', 1);
    assert(t2.c == 'a');
    assert(t2.i == 1);
    assert($(HILITE isNaN(t2.d)));

    // Last two are missing
    auto t3 = Test('a');
    assert(t3.c == 'a');
    assert($(HILITE t3.i == int.init));
    assert($(HILITE isNaN(t3.d)));

    // No initial value specified
    auto t4 = Test();
    assert($(HILITE t4.c == char.init));
    assert($(HILITE t4.i == int.init));
    assert($(HILITE isNaN(t4.d)));

    // The same as above
    Test t5;
    assert(t5.c == char.init);
    assert(t5.i == int.init);
    assert(isNaN(t5.d));
}
---

$(P
As you would remember from the $(LINK2 floating_point.html, Floating Point Types chapter), the initial value of $(C double) is $(C double.nan). Since the $(C .nan) value is $(I unordered), it is meaningless to use it in equality comparisons. That is why calling $(C std.math.isNaN) is the correct way of determining whether a value equals to $(C .nan).
)

$(H6 $(IX default value, member) Specifying default values for members)

$(P
It is important that member variables are automatically initialized with known initial values. This prevents the program from continuing with indeterminate values. However, the $(C .init) value of their respective types may not be suitable for every type. For example, $(C char.init) is not even a valid value.
)

$(P
The initial values of the members of a struct can be specified when the struct is defined. This is useful for example to initialize floating point members by $(C 0.0), instead of the mostly-unusable $(C .nan).
)

$(P
The default values are specified by the assignment syntax as the members are defined:
)

---
struct Test {
    char   c $(HILITE = 'A');
    int    i $(HILITE = 11);
    double d $(HILITE = 0.25);
}
---

$(P
Please note that the syntax above is not really assignment. The code above merely determines the default values that will be used when objects of that struct are actually constructed later in the program.
)

$(P
For example, the following $(C Test) object is being constructed without any specific values:
)

---
    Test t;  // no value is specified for the members
    writefln("%s,%s,%s", t.c, t.i, t.d);
---

$(P
All of the members are initialized by their default values:
)

$(SHELL
A,11,0.25
)

$(H6 $(IX {}, construction) $(IX C-style struct initialization) Constructing by the $(C {}) syntax)

$(P
Struct objects can also be constructed by the following syntax:
)

---
    TimeOfDay periodStart = { 8, 30 };
---

$(P
Similar to the earlier syntax, the specified values are assigned to the members in the order that they are specified. The trailing members get their default values.
)

$(P
This syntax is inherited from the C programming language:
)

---
    auto periodStart = TimeOfDay(8, 30);    // ← regular
    TimeOfDay periodEnd = { 9, 30 };        // ← C-style
---

$(P
$(IX designated initializer) This syntax allows $(I designated initializers). Designated initializers are for specifying the member that an initialization value is associated with. It is even possible to initialize members in a different order than they are defined in the $(C struct):
)

---
    TimeOfDay t = { $(HILITE minute:) 42, $(HILITE hour:) 7 };
---

$(H5 $(IX copy, struct) $(IX assignment, struct) Copying and assignment)

$(P
Structs are value types. As has been described in the $(LINK2 value_vs_reference.html, Value Types and Reference Types chapter), this means that every $(C struct) object has its own value. Objects get their own values when constructed, and their values change when they are assigned new values.
)

---
    auto yourLunchTime = TimeOfDay(12, 0);
    auto myLunchTime = yourLunchTime;

    // Only my lunch time becomes 12:05:
    myLunchTime.minute += 5;

    // ... your lunch time is still the same:
    assert(yourLunchTime.minute == 0);
---

$(P
During a copy, all of the members of the source object are automatically copied to the corresponding members of the destination object. Similarly, assignment involves assigning each member of the source to the corresponding member of the destination.
)

$(P
Struct members that are of reference types need extra attention.
)

$(H6 $(IX reference type, member) Careful with members that are of reference types!)

$(P
As you remember, copying or assigning variables of reference types does not change any value, it changes what object is being referenced. As a result, copying or assigning generates one more reference to the right-hand side object. The relevance of this for struct members is that, the members of two separate struct objects would start providing access to the same value.
)

$(P
To see an example of this, let's have a look at a struct where one of the members is a reference type. This struct is used for keeping the student number and the grades of a student:
)

---
struct Student {
    int number;
    int[] grades;
}
---

$(P
The following code constructs a second $(C Student) object by copying an existing one:
)

---
    // Constructing the first object:
    auto student1 = Student(1, [ 70, 90, 85 ]);

    // Constructing the second student as a copy of the first
    // one and then changing its number:
    auto student2 = student1;
    student2.number = 2;

    // WARNING: The grades are now being shared by the two objects!

    // Changing the grades of the first student ...
    student1.grades[0] += 5;

    // ... affects the second student as well:
    writeln(student2.grades[0]);
---

$(P
When $(C student2) is constructed, its members get the values of the members of $(C student1). Since $(C int) is a value type, the second object gets its own $(C number) value.
)

$(P
The two $(C Student) objects also have individual $(C grades) members as well. However, since slices are reference types, the actual elements that the two slices share are the same. Consequently, a change made through one of the slices is seen through the other slice.
)

$(P
The output of the code indicates that the grade of the second student has been increased as well:
)

$(SHELL
75
)

$(P
For that reason, a better approach might be to construct the second object by the copies of the grades of the first one:
)

---
    // The second Student is being constructed by the copies
    // of the grades of the first one:
    auto student2 = Student(2, student1.grades$(HILITE .dup));

    // Changing the grades of the first student ...
    student1.grades[0] += 5;

    // ... does not affect the grades of the second student:
    writeln(student2.grades[0]);
---

$(P
Since the grades have been copied by $(C .dup), this time the grades of the second student are not affected:
)

$(SHELL
70
)

$(P
$(I Note: It is possible to have even the reference members copied automatically. We will see how this is done later when covering struct member functions.)
)

$(H5 $(IX literal, struct) Struct literals)

$(P
Similar to being able to use integer literal values like 10 in expressions without needing to define a variable, struct objects can be used as literals as well.
)

$(P
Struct literals are constructed by the object construction syntax.
)

---
    TimeOfDay(8, 30) // ← struct literal value
---

$(P
Let's first rewrite the $(C main()) function above with what we have learned since its last version. The variables are constructed by the construction syntax and are $(C immutable) this time:
)

---
$(CODE_XREF TimeOfDay)$(CODE_XREF addDuration)void main() {
    immutable periodStart = TimeOfDay(8, 30);
    immutable periodDuration = TimeOfDay(1, 15);

    immutable periodEnd = addDuration(periodStart,
                                      periodDuration);

    writefln("Period end: %s:%s",
              periodEnd.hour, periodEnd.minute);
}
---

$(P
Note that $(C periodStart) and $(C periodDuration) need not be defined as named variables in the code above. Those are in fact temporary variables in this simple program, which are used only for calculating the $(C periodEnd) variable. They could be passed to $(C addDuration()) as literal values instead:
)

---
$(CODE_XREF TimeOfDay)$(CODE_XREF addDuration)void main() {
    immutable periodEnd = addDuration(TimeOfDay(8, 30),
                                      TimeOfDay(1, 15));

    writefln("Period end: %s:%s",
              periodEnd.hour, periodEnd.minute);
}
---

$(H5 $(IX static, member) $(C static) members)

$(P
Although objects mostly need individual copies of the struct's members, sometimes it makes sense for the objects of a particular struct type to share some variables. This may be necessary to maintain e.g. a general information about that struct type.
)

$(P
As an example, let's imagine a type that assigns a separate identifier for every object that is constructed of that type:
)

---
struct Point {
    // The identifier of each object
    size_t id;

    int line;
    int column;
}
---

$(P
In order to be able to assign different ids to each object, a separate variable is needed to keep the next available id. It would be incremented every time a new object is created. Assume that $(C nextId) is to be defined elsewhere and to be available in the following function:
)

---
Point makePoint(int line, int column) {
    size_t id = nextId;
    ++nextId;

    return Point(id, line, column);
}
---

$(P
A decision must be made regarding where the common $(C nextId) variable is to be defined. $(C static) members are useful in such cases.
)

$(P
Such common information is defined as a $(C static) member of the struct. Contrary to the regular members, there is a single variable of each $(C static) member for each thread. (Note that most programs consist of a single thread that starts executing the $(C main()) function.) That single variable is shared by all of the objects of that struct in that thread:
)

---
import std.stdio;

struct Point {
    // The identifier of each object
    size_t id;

    int line;
    int column;

    // The id of the next object to construct
    $(HILITE static size_t nextId;)
}

Point makePoint(int line, int column) {
    size_t id = $(HILITE Point.)nextId;
    ++$(HILITE Point.)nextId;

    return Point(id, line, column);
}

void main() {
    auto top = makePoint(7, 0);
    auto middle = makePoint(8, 0);
    auto bottom =  makePoint(9, 0);

    writeln(top.id);
    writeln(middle.id);
    writeln(bottom.id);
}
---

$(P
As $(C nextId) is incremented at each object construction, each object gets a unique id:
)

$(SHELL
0
1
2
)

$(P
Since $(C static) members are owned by the entire type, there need not be an object to access them. As we have seen above, such objects can be accessed by the name of the type, as well as by the name of any object of that struct:
)

---
    ++Point.nextId;
    ++$(HILITE bottom).nextId;    // would be the same as above
---

$(P
When a variable is needed not $(I one per thread) but $(I one per program), then those variables must be defined as $(C shared static). We will see the $(C shared) keyword in a later chapter.
)

$(H6 $(IX static this, struct) $(IX static ~this, struct) $(IX this, static, struct) $(IX ~this, static, struct) $(C static&nbsp;this()) for initialization and $(C static&nbsp;~this()) for finalization)

$(P
Instead of explicitly assigning an initial value to $(C nextId) above, we relied on its default initial value, zero. We could have used any other value:
)

---
    static size_t nextId $(HILITE = 1000);
---

$(P
However, such initialization is possible only when the initial value is known at compile time. Further, some special code may have to be executed before a struct can be used in a thread. Such code is written in $(C static this()) scopes.
)

$(P
For example, the following code reads the initial value from a file if that file exists:
)

---
import std.file;

struct Point {
// ...

    enum nextIdFile = "Point_next_id_file";

    $(HILITE static this()) {
        if (exists(nextIdFile)) {
            auto file = File(nextIdFile, "r");
            file.readf(" %s", &nextId);
        }
    }
}
---

$(P
The contents of $(C static this()) blocks are automatically executed once per thread before the $(C struct) type is ever used in that thread. Code that should be executed only once for the entire program (e.g. initializing $(C shared) and $(C immutable) variables) must be defined in $(C shared static this()) and $(C shared static ~this()) blocks, which will be covered in $(LINK2 concurrency_shared.html, the Data Sharing Concurrency chapter).
)

$(P
Similarly, $(C static ~this()) is for the final operations of a thread and $(C shared static ~this()) is for the final operations of the entire program.
)

$(P
The following example complements the previous $(C static this()) by writing the value of $(C nextId) to the same file, effectively persisting the object ids over consecutive executions of the program:
)

---
struct Point {
// ...

    $(HILITE static ~this()) {
        auto file = File(nextIdFile, "w");
        file.writeln(nextId);
    }
}
---

$(P
The program would now initialize $(C nextId) from where it was left off. For example, the following would be the output of the program's second execution:
)

$(SHELL
3
4
5
)

$(PROBLEM_COK

$(PROBLEM
Design a struct named $(C Card) to represent a playing card.

$(P
This struct can have two members for the suit and the value. It may make sense to use an $(C enum) to represent the suit, or you can simply use the characters ♠, ♡, ♢, and ♣.
)

$(P
An $(C int) or a $(C dchar) value can be used for the card value. If you decide to use an $(C int), the values 1, 11, 12, and 13 may represent the cards that do not have numbers (ace, jack, queen, and king).
)

$(P
There are other design choices to make. For example, the card values can be represented by an $(C enum) type as well.
)

$(P
The way objects of this struct will be constructed will depend on the choice of the types of its members. For example, if both members are $(C dchar), then $(C Card) objects can be constructed like this:
)

---
    auto card = Card('♣', '2');
---

)

$(PROBLEM
Define a function named $(C printCard()), which takes a $(C Card) object as a parameter and simply prints it:

---
struct Card {
    // ... please define the struct ...
}

void printCard(Card card) {
    // ... please define the function body ...
}

void main() {
    auto card = Card(/* ... */);
    printCard(card);
}
---

$(P
For example, the function can print the 2 of clubs as:
)

$(SHELL
♣2
)

$(P
The implementation of that function may depend on the choice of the types of the members.
)

)

$(PROBLEM
Define a function named $(C newDeck()) and have it return 52 cards of a deck as a $(C Card) slice:

---
Card[] newDeck()
out (result) {
    assert(result.length == 52);

} do {
    // ... please define the function body ...
}
---

$(P
It should be possible to call $(C newDeck()) as in the following code:
)

---
    Card[] deck = newDeck();

    foreach (card; deck) {
        printCard(card);
        write(' ');
    }

    writeln();
---

$(P
The output should be similar to the following with 52 distinct cards:
)

$(SHELL
♠2 ♠3 ♠4 ♠5 ♠6 ♠7 ♠8 ♠9 ♠0 ♠J ♠Q ♠K ♠A ♡2 ♡3 ♡4
♡5 ♡6 ♡7 ♡8 ♡9 ♡0 ♡J ♡Q ♡K ♡A ♢2 ♢3 ♢4 ♢5 ♢6 ♢7
♢8 ♢9 ♢0 ♢J ♢Q ♢K ♢A ♣2 ♣3 ♣4 ♣5 ♣6 ♣7 ♣8 ♣9 ♣0
♣J ♣Q ♣K ♣A
)

)

$(PROBLEM
Write a function that shuffles the deck. One way is to pick two cards at random by $(C std.random.uniform), to swap those two cards, and to repeat this process a sufficient number of times. The function should take the number of repetition as a parameter:

---
void shuffle(Card[] deck, int repetition) {
    // ... please define the function body ...
}
---

$(P
Here is how it should be used:
)

---
    Card[] deck = newDeck();
    shuffle(deck, 1);

    foreach (card; deck) {
        printCard(card);
        write(' ');
    }

    writeln();
---

$(P
The function should swap cards $(C repetition) number of times. For example, when called by 1, the output should be similar to the following:
)

$(SHELL
♠2 ♠3 ♠4 ♠5 ♠6 ♠7 ♠8 ♠9 ♠0 ♠J ♠Q ♠K ♠A ♡2 ♡3 ♡4
♡5 ♡6 ♡7 ♡8 $(HILITE ♣4) ♡0 ♡J ♡Q ♡K ♡A ♢2 ♢3 ♢4 ♢5 ♢6 ♢7
♢8 ♢9 ♢0 ♢J ♢Q ♢K ♢A ♣2 ♣3 $(HILITE ♡9) ♣5 ♣6 ♣7 ♣8 ♣9 ♣0
♣J ♣Q ♣K ♣A
)

$(P
A higher value for $(C repetition) should result in a more shuffled deck:
)

---
    shuffled(deck, $(HILITE 100));
---

$(P
The output:
)

$(SHELL
♠4 ♣7 ♢9 ♢6 ♡2 ♠6 ♣6 ♢A ♣5 ♢8 ♢3 ♡Q ♢J ♣K ♣8 ♣4
♡J ♣Q ♠Q ♠9 ♢0 ♡A ♠A ♡9 ♠7 ♡3 ♢K ♢2 ♡0 ♠J ♢7 ♡7
♠8 ♡4 ♣J ♢4 ♣0 ♡6 ♢5 ♡5 ♡K ♠3 ♢Q ♠2 ♠5 ♣2 ♡8 ♣A
♠K ♣9 ♠0 ♣3
)

$(P
$(I $(B Note:) A much better way of shuffling the deck is explained in the solutions.)
)

)

)

Macros:
        TITLE=Structs

        DESCRIPTION=The 'struct' feature of the D programming language, which is used for defining user types.

        KEYWORDS=d programming book tutorial struct
