Ddoc

$(DERS_BOLUMU $(IX inheritance) Inheritance)

$(P
Inheritance is defining a more specialized type based on an existing more general base type. The specialized type acquires the members of the base type and as a result can be substituted in place of the base type.
)

$(P
$(IX superclass) $(IX subclass) Inheritance is available for classes, not structs. The class that inherits another class is called the $(I subclass), and the class that gets inherited is called the $(I superclass), also called the $(I base class).
)

$(P
There are two types of inheritance in D. We will cover $(I implementation inheritance) in this chapter and leave $(I interface inheritance) to a later chapter.
)

$(P
$(IX :, inheritance) When defining a subclass, the superclass is specified after a colon character:
)

---
class $(I SubClass) : $(I SuperClass) {
    // ...
}
---

$(P
To see an example of this, let's assume that there is already the following class that represents a clock:
)

---
$(CODE_NAME Clock)$(CODE_COMMENT_OUT)class Clock {
    int hour;
    int minute;
    int second;

    void adjust(int hour, int minute, int second = 0) {
        this.hour = hour;
        this.minute = minute;
        this.second = second;
    }
$(CODE_COMMENT_OUT)}
---

$(P
Apparently, the members of that class do not need special values during construction; so there is no constructor. Instead, the members are set by the $(C adjust()) member function:
)

---
    auto deskClock = new Clock;
    deskClock.adjust(20, 30);
    writefln(
        "%02s:%02s:%02s",
        deskClock.hour, deskClock.minute, deskClock.second);
---

$(P
$(I $(B Note:) It would be more useful to produce the time string by a $(C toString()) function. It will be added later when explaining the $(C override) keyword below.)
)

$(P
The output:
)

$(SHELL
20:30:00
)

$(P
With only that much functionality, $(C Clock) could be a struct as well, and depending on the needs of the program, that could be sufficient.
)

$(P
However, being a class makes it possible to inherit from $(C Clock).
)

$(P
To see an example of inheritance, let's consider an $(C AlarmClock) that not only includes all of the functionality of $(C Clock), but also provides a way of setting the alarm. Let's first define this type without regard to $(C Clock). If we did that, we would have to include the same three members of $(C Clock) and the same $(C adjust()) function that adjusted them. $(C AlarmClock) would also have other members for its additional functionality:
)

---
class AlarmClock {
    $(HILITE int hour;)
    $(HILITE int minute;)
    $(HILITE int second;)
    int alarmHour;
    int alarmMinute;

    $(HILITE void adjust(int hour, int minute, int second = 0) {)
        $(HILITE this.hour = hour;)
        $(HILITE this.minute = minute;)
        $(HILITE this.second = second;)
    $(HILITE })

    void adjustAlarm(int hour, int minute) {
        alarmHour = hour;
        alarmMinute = minute;
    }
}
---

$(P
The members that appear exactly in $(C Clock) are highlighted. As can be seen, defining $(C Clock) and $(C AlarmClock) separately results in code duplication.
)

$(P
Inheritance is helpful in such cases. Inheriting $(C AlarmClock) from $(C Clock) simplifies the new class and reduces code duplication:
)

---
$(CODE_NAME AlarmClock)$(CODE_COMMENT_OUT)class AlarmClock $(HILITE : Clock) {
    int alarmHour;
    int alarmMinute;

    void adjustAlarm(int hour, int minute) {
        alarmHour = hour;
        alarmMinute = minute;
    }
$(CODE_COMMENT_OUT)}
---

$(P
The new definition of $(C AlarmClock) is the equivalent of the previous one. The highlighted part of the new definition corresponds to the highlighted parts of the old definition.
)

$(P
Because $(C AlarmClock) inherits the members of $(C Clock), it can be used just like a $(C Clock):
)

---
    auto bedSideClock = new AlarmClock;
    bedSideClock.$(HILITE adjust(20, 30));
    bedSideClock.adjustAlarm(7, 0);
---

$(P
The members that are inherited from the superclass can be accessed as if they were the members of the subclass:
)

---
    writefln("%02s:%02s:%02s ♫%02s:%02s",
             bedSideClock$(HILITE .hour),
             bedSideClock$(HILITE .minute),
             bedSideClock$(HILITE .second),
             bedSideClock.alarmHour,
             bedSideClock.alarmMinute);
---

$(P
The output:
)

$(SHELL
20:30:00 ♫07:00
)

$(P $(I $(B Note:) An $(C AlarmClock.toString) function would be more useful in this case. It will be defined later below.)
)

$(P
The inheritance used in this example is $(I implementation inheritance.)
)

$(P
If we imagine the memory as a ribbon going from top to bottom, the placement of the members of $(C AlarmClock) in memory can be pictured as in the following illustration:
)

$(MONO
                            │      .      │
                            │      .      │
the address of the object → ├─────────────┤
                            │$(GRAY $(I (other data))) │
                            │$(HILITE &nbsp;hour        )│
                            │$(HILITE &nbsp;minute      )│
                            │$(HILITE &nbsp;second      )│
                            │ alarmHour   │
                            │ alarmMinute │
                            ├─────────────┤
                            │      .      │
                            │      .      │
)

$(P
$(IX vtbl) The illustration above is just to give an idea on how the members of the superclass and the subclass may be combined together. The actual layout of the members depends on the implementation details of the compiler in use. For example, the part that is marked as $(I other data) typically includes the pointer to the $(I virtual function table) (vtbl) of that particular class type. The details of the object layout are outside the scope of this book.
)

$(H5 $(IX is-a) Warning: Inherit only if "is a")

$(P
We have seen that implementation inheritance is about acquiring members. Consider this kind of inheritance only if the subtype can be thought of being a kind of the supertype as in the phrase "alarm clock $(I is a) clock."
)

$(P
$(IX has-a) "Is a" is not the only relationship between types; a more common relationship is the "has a" relationship. For example, let's assume that we want to add the concept of a $(C Battery) to the $(C Clock) class. It would not be appropriate to add $(C Battery) to $(C Clock) by inheritance because the statement "clock is a battery" is not true:
)

---
class Clock : Battery {    $(CODE_NOTE_WRONG WRONG DESIGN)
    // ...
}
---

$(P
A clock is not a battery; it $(I has a) battery. When there is such a relationship of containment, the type that is contained must be defined as a member of the type that contains it:
)

---
class Clock {
    Battery battery;       $(CODE_NOTE Correct design)
    // ...
}
---

$(H5 $(IX single inheritance) $(IX inheritance, single) $(IX hierarchy) Inheritance from at most one class)

$(P
Classes can only inherit from a single base class (which itself can potentially inherit from another single class). In other words, multiple inheritance is not supported in D.
)

$(P
For example, assuming that there is also a $(C SoundEmitter) class, and even though "alarm clock is a sound emitting object" is also true, it is not possible to inherit $(C AlarmClock) both from $(C Clock) and $(C SoundEmitter):
)

---
class SoundEmitter {
    // ...
}

class AlarmClock : Clock$(HILITE , SoundEmitter) {    $(DERLEME_HATASI)
    // ...
}
---

$(P
On the other hand, there is no limit to the number of $(I interfaces) that a class can inherit from. We will see the $(C interface) keyword in a later chapter.
)

$(P
Additionally, there is no limit to how deep the inheritance hierarchy can go:
)

---
class MusicalInstrument {
    // ...
}

class StringInstrument : MusicalInstrument {
    // ...
}

class Violin : StringInstrument {
    // ...
}
---

$(P
The inheritance hierarchy above defines a relationship from the more general to the more specific: musical instrument, string instrument, and violin.
)

$(H5 Hierarchy charts)

$(P
Types that are related by the "is a" relationship form a $(I class hierarchy).
)

$(P
According to OOP conventions, class hierarchies are represented by superclasses being on the top and the subclasses being at the bottom. The inheritance relationships are indicated by arrows pointing from the subclasses to the superclasses.
)

$(P
For example, the following can be a hierarchy of musical instruments:
)

$(MONO
             MusicalInstrument
                ↗         ↖
    StringInstrument   WindInstrument
         ↗    ↖            ↗    ↖
     Violin  Guitar    Flute   Recorder
)

$(H5 $(IX super, member access) Accessing superclass members)

$(P
The $(C super) keyword allows referring to members that are inherited from the superclass.
)

---
class AlarmClock : Clock {
    // ...

    void foo() {
        super.minute = 10; // The inherited 'minute' member
        minute = 10;       // Same thing if there is no ambiguity
    }
}
---

$(P
The $(C super) keyword is not always necessary; $(C minute) alone has the same meaning in the code above. The $(C super) keyword is needed when both the superclass and the subclass have members under the same names. We will see this below when we will need to write $(C super.reset()) and $(C super.toString()).
)

$(P
If multiple classes in an inheritance tree define a symbol with the same name, one can use the specific name of the class in the inheritance tree to disambiguate between the symbols:
)

---
class Device {
    string $(HILITE manufacturer);
}

class Clock : Device {
    string $(HILITE manufacturer);
}

class AlarmClock : Clock {
    // ...

    void foo() {
        $(HILITE Device.)manufacturer = "Sunny Horology, Inc.";
        $(HILITE Clock.)manufacturer = "Better Watches, Ltd.";
    }
}
---

$(H5 $(IX super, construction) Constructing superclass members)

$(P
The other use of the $(C super) keyword is to call the constructor of the superclass. This is similar to calling the overloaded constructors of the current class: $(C this) when calling constructors of the current class and $(C super) when calling constructors of the superclass.
)

$(P
It is not required to call the superclass constructor explicitly. If the constructor of the subclass makes an explicit call to any overload of $(C super), then that constructor is executed by that call. Otherwise, and if the superclass has a default constructor, it is executed automatically before entering the body of the subclass.
)

$(P
We have not defined constructors for the $(C Clock) and $(C AlarmClock) classes yet. For that reason, the members of both of those classes are initialized by the $(C .init) values of their respective types, which is 0 for $(C int).
)

$(P
Let's assume that $(C Clock) has the following constructor:
)

---
$(CODE_NAME Clock_ctor)$(CODE_COMMENT_OUT)class Clock {
    this(int hour, int minute, int second) {
        this.hour = hour;
        this.minute = minute;
        this.second = second;
    }

    // ...
$(CODE_COMMENT_OUT)}
---

$(P
That constructor must be used when constructing $(C Clock) objects:
)

---
    auto clock = new Clock(17, 15, 0);
---

$(P
Naturally, the programmers who use the $(C Clock) type directly would have to use that syntax. However, when constructing an $(C AlarmClock) object, they cannot construct its $(C Clock) part separately. Besides, the users of $(C AlarmClock) need not even know that it inherits from $(C Clock).
)

$(P
A user of $(C AlarmClock) should simply construct an $(C AlarmClock) object and use it in the program without needing to pay attention to its $(C Clock) heritage:
)

---
    auto bedSideClock = new AlarmClock(/* ... */);
    // ... use as an AlarmClock ...
---

$(P
For that reason, constructing the superclass part is the responsibility of the subclass. The subclass calls the constructor of the superclass with the $(C super()) syntax:
)

---
$(CODE_NAME AlarmClock_ctor)$(CODE_COMMENT_OUT)class AlarmClock : Clock {
    this(int hour, int minute, int second,  // for Clock's members
         int alarmHour, int alarmMinute) {  // for AlarmClock's members
        $(HILITE super)(hour, minute, second);
        this.alarmHour = alarmHour;
        this.alarmMinute = alarmMinute;
    }

    // ...
$(CODE_COMMENT_OUT)}
---

$(P
The constructor of $(C AlarmClock) takes arguments for both its own members and the members of its superclass. It then uses part of those arguments to construct its superclass part.
)

$(H5 $(IX override) Overriding the definitions of member functions)

$(P
One of the benefits of inheritance is being able to redefine the member functions of the superclass in the subclass. This is called $(I overriding): The existing definition of the member function of the superclass is overridden by the subclass with the $(C override) keyword.
)

$(P
$(IX virtual function) Overridable functions are called $(I virtual functions). Virtual functions are implemented by the compiler through $(I virtual function pointer tables) (vtbl) and $(I vtbl pointers). The details of this mechanism are outside the scope of this book. However, it must be known by every system programmer that virtual function calls are more expensive than regular function calls. Every non-private $(C class) member function in D is virtual by default. For that reason, when a superclass function does not need to be overridden at all, it should be defined as $(C final) so that it is not virtual. We will see the $(C final) keyword later in $(LINK2 interface.html, the Interfaces chapter).
)

$(P
Let's assume that $(C Clock) has a member function that is used for resetting its members all to zero:
)

---
class Clock {
    void reset() {
        hour = 0;
        minute = 0;
        second = 0;
    }

    // ...
}
---

$(P
That function is inherited by $(C AlarmClock) and can be called on an $(C AlarmClock) object:
)

---
    auto bedSideClock = new AlarmClock(20, 30, 0, 7, 0);
    // ...
    bedSideClock.reset();
---

$(P
However, necessarily ignorant of the members of $(C AlarmClock), $(C Clock.reset) can only reset its own members. For that reason, to reset the members of the subclass as well, $(C reset()) must be overridden:
)

---
class AlarmClock : Clock {
    $(HILITE override) void reset() {
        super.reset();
        alarmHour = 0;
        alarmMinute = 0;
    }

    // ...
}
---

$(P
The subclass resets only its own members and dispatches the rest of the task to $(C Clock) by the $(C super.reset()) call. Note that writing just $(C reset()) would not work as it would call the $(C reset()) function of $(C AlarmClock) itself. Calling $(C reset()) from within itself would cause an infinite recursion.
)

$(P
The reason that I have delayed the definition of $(C toString()) until this point is that it must be defined by the $(C override) keyword for classes. As we will see in the next chapter, every class is automatically inherited from a superclass called $(C Object) and $(C Object) already defines a $(C toString()) member function.
)

$(P
For that reason, the $(C toString()) member function for classes must be defined by using the $(C override) keyword:
)

---
$(CODE_NAME Clock_AlarmClock)import std.string;

class Clock {
    $(HILITE override) string toString() const {
        return format("%02s:%02s:%02s", hour, minute, second);
    }

    // ...
$(CODE_XREF Clock)$(CODE_XREF Clock_ctor)}

class AlarmClock : Clock {
    $(HILITE override) string toString() const {
        return format("%s ♫%02s:%02s", super.toString(),
                      alarmHour, alarmMinute);
    }

    // ...
$(CODE_XREF AlarmClock)$(CODE_XREF AlarmClock_ctor)}
---

$(P
Note that $(C AlarmClock) is again dispatching some of the task to $(C Clock) by the $(C super.toString()) call.
)

$(P
Those two overrides of $(C toString()) allow converting $(C AlarmClock) objects to strings:
)

---
$(CODE_XREF Clock_AlarmClock)void main() {
    auto deskClock = new AlarmClock(10, 15, 0, 6, 45);
    writeln($(HILITE deskClock));
}
---

$(P
The output:
)

$(SHELL
10:15:00 ♫06:45
)

$(H5 $(IX polymorphism, run-time) $(IX run-time polymorphism) Using the subclass in place of the superclass)

$(P
Since the superclass is more $(I general) and the subclass is more $(I specialized), objects of a subclass can be used in places where an object of the superclass type is required. This is called $(I polymorphism).
)

$(P
The concepts of general and specialized types can be seen in statements like "this type is of that type": "alarm clock is a clock", "student is a person", "cat is an animal", etc. Accordingly, an alarm clock can be used where a clock is needed, a student can be used where a person is needed, and a cat can be used where an animal is needed.
)

$(P
When a subclass object is being used as a superclass object, it does not lose its own specialized type. This is similar to the examples in real life: Using an alarm clock simply as a clock does not change the fact that it is an alarm clock; it would still behave like an alarm clock.
)

$(P
Let's assume that a function takes a $(C Clock) object as parameter, which it resets at some point during its execution:
)

---
void use(Clock clock) {
    // ...
    clock.reset();
    // ...
}
---

$(P
Polymorphism makes it possible to send an $(C AlarmClock) to such a function:
)

---
    auto deskClock = new AlarmClock(10, 15, 0, 6, 45);
    writeln("Before: ", deskClock);
    $(HILITE use(deskClock));
    writeln("After : ", deskClock);
---

$(P
This is in accordance with the relationship "alarm clock is a clock." As a result, the members of the $(C deskClock) object get reset:
)

$(SHELL
Before: 10:15:00 ♫06:45
After : 00:00:00 ♫$(HILITE 00:00)
)

$(P
The important observation here is that not only the members of $(C Clock) but also the members of $(C AlarmClock) have been reset.
)

$(P
Although $(C use()) calls $(C reset()) on a $(C Clock) object, since the actual object is an $(C AlarmClock), the function that gets called is $(C AlarmClock.reset). According to its definition above, $(C AlarmClock.reset) resets the members of both $(C Clock) and $(C AlarmClock).
)

$(P
In other words, although $(C use()) uses the object as a $(C Clock), the actual object may be an inherited type that behaves in its own special way.
)

$(P
Let's add another class to the $(C Clock) hierarchy. The $(C reset()) function of this type sets its members to random values:
)

---
import std.random;

class BrokenClock : Clock {
    this() {
        super(0, 0, 0);
    }

    override void reset() {
        hour = uniform(0, 24);
        minute = uniform(0, 60);
        second = uniform(0, 60);
    }
}
---

$(P
When an object of $(C BrokenClock) is sent to $(C use()), then the special $(C reset()) function of $(C BrokenClock) would be called. Again, although it is passed as a $(C Clock), the actual object is still a $(C BrokenClock):
)

---
    auto shelfClock = new BrokenClock;
    use(shelfClock);
    writeln(shelfClock);
---

$(P
The output shows random time values as a result of resetting a $(C BrokenClock):
)

$(SHELL
22:46:37
)

$(H5 Inheritance is transitive)

$(P
Polymorphism is not just limited to two classes. Subclasses of subclasses can also be used in place of any superclass in the hierarchy.
)

$(P
Let's consider the $(C MusicalInstrument) hierarchy:
)

---
class MusicalInstrument {
    // ...
}

class StringInstrument : MusicalInstrument {
    // ...
}

class Violin : StringInstrument {
    // ...
}
---

$(P
The inheritances above builds the following relationships: "string instrument is a musical instrument" and "violin is a string instrument." Therefore, it is also true that "violin is a musical instrument." Consequently, a $(C Violin) object can be used in place of a $(C MusicalInstrument).
)

$(P
Assuming that all of the supporting code below has also been defined:
)

---
void playInTune(MusicalInstrument instrument,
                MusicalPiece piece) {
    instrument.tune();
    instrument.play(piece);
}

// ...

auto myViolin = new Violin;
playInTune(myViolin, improvisation);
---

$(P
Although $(C playInTune()) expects a $(C MusicalInstrument), it is being called with a $(C Violin) due to the relationship "violin is a musical instrument."
)

$(P
Inheritance can be as deep as needed.
)

$(H5 $(IX abstract) Abstract member functions and abstract classes)

$(P
Sometimes there are member functions that are natural to appear in a class interface even though that class cannot provide its definition. When there is no $(I concrete) definition of a member function, that function is an $(I abstract) member function. A class that has at least one abstract member function is an abstract class.
)

$(P
For example, the $(C ChessPiece) superclass in a hierarchy may have an $(C isValid()) member function that determines whether a given move is valid for that chess piece. Since validity of a move depends on the actual type of the chess piece, the $(C ChessPiece) general class cannot make this decision itself. The valid moves can only be known by the subclasses like $(C Pawn), $(C King), etc.
)

$(P
The $(C abstract) keyword specifies that the inherited class must implement such a method itself:
)

---
class ChessPiece {
    $(HILITE abstract) bool isValid(Square from, Square to);
}
---

$(P
It is not possible to construct objects of abstract classes:
)

---
    auto piece = new ChessPiece;    $(DERLEME_HATASI)
---

$(P
The subclass would have to override and implement all the abstract functions in order to make the class non-abstract and therefore constructible:
)

---
class Pawn : ChessPiece {
    override bool isValid(Square from, Square to) {
        // ... the implementation of isValid for pawn ...
        return decision;
    }
}
---

$(P
It is now possible to construct objects of $(C Pawn):
)

---
    auto piece = new Pawn;             // compiles
---

$(P
Note that an abstract function may have an implementation of its own, but it would still require the subclass to provide its own implementation of such a function. For example, the $(C ChessPiece)'es implementation may provide some useful checks of its own:
)

---
class ChessPiece {
    $(HILITE abstract) bool isValid(Square from, Square to) {
        // We require the 'to' position to be different than
        // the 'from' position
        return from != to;
    }
}

class Pawn : ChessPiece {
    override bool isValid(Square from, Square to) {
        // First verify if it is a valid move for any ChessPiece
        if (!$(HILITE super.isValid)(from, to)) {
            return false;
        }

        // ... then check if it is valid for the Pawn ...

        return decision;
    }
}
---

$(P
The $(C ChessPiece) class is still abstract even though $(C isValid()) was already implemented, but the $(C Pawn) class is non-abstract and can be instantiated.
)

$(H5 Example)

$(P
Let's consider a class hierarchy that represents railway vehicles:
)

$(MONO
           RailwayVehicle
          /      |       \
  Locomotive   Train   RailwayCar { load()?, unload()? }
                          /   \
               PassengerCar   FreightCar
)

$(P
The functions that $(C RailwayCar) will declare as $(C abstract) are indicated by question marks.
)

$(P
Since my goal is only to present a class hierarchy and point out some of its design decisions, I will not fully implement these classes. Instead of doing actual work, they will simply print messages.
)

$(P
The most general class of the hierarchy above is $(C RailwayVehicle). In this program, it will only know how to move itself:
)

---
$(CODE_NAME RailwayVehicle)class RailwayVehicle {
    void advance(size_t kilometers) {
        writefln("The vehicle is advancing %s kilometers",
                 kilometers);
    }
}
---

$(P
A class that inherits from $(C RailwayVehicle) is $(C Locomotive), which does not have any special members yet:
)

---
$(CODE_NAME Locomotive)$(CODE_XREF RailwayVehicle)class Locomotive : RailwayVehicle {
}
---

$(P
We will add a special $(C makeSound()) member function to $(C Locomotive) later during one of the exercises.
)

$(P
$(C RailwayCar) is a $(C RailwayVehicle) as well. However, if the hierarchy supports different types of railway cars, then certain behaviors like loading and unloading must be done according to their exact types. For that reason, $(C RailwayCar) can only declare these two functions as abstract:
)

---
$(CODE_NAME RailwayCar)class RailwayCar : RailwayVehicle {
    $(HILITE abstract) void load();
    $(HILITE abstract) void unload();
}
---

$(P
Loading and unloading a passenger car is as simple as opening the doors of the car, while loading and unloading a freight car may involve porters and winches. The following subclasses provide definitions for the abstract functions of $(C RailwayCar):
)

---
$(CODE_NAME PassengerCar_FreightCar)class PassengerCar : RailwayCar {
    override void load() {
        writeln("The passengers are getting on");
    }

    override void unload() {
        writeln("The passengers are getting off");
    }
}

class FreightCar : RailwayCar {
    override void load() {
        writeln("The crates are being loaded");
    }

    override void unload() {
        writeln("The crates are being unloaded");
    }
}
---

$(P
Being an abstract class does not preclude the use of $(C RailwayCar) in the program. Objects of $(C RailwayCar) can not be constructed but $(C RailwayCar) can be used as an interface. As the subclasses define the two relationships "passenger car is a railway car" and "freight car is a railway car", the objects of $(C PassengerCar) and $(C FreightCar) can be used in places of $(C RailwayCar). This will be seen in the $(C Train) class below.
)

$(P
The class that represents a train can consist of a locomotive and an array of railwaycars:
)

---
$(CODE_NAME Train_members)$(CODE_COMMENT_OUT)class Train : RailwayVehicle {
    Locomotive locomotive;
    RailwayCar[] cars;

    // ...
$(CODE_COMMENT_OUT)}
---

$(P
I would like to repeat an important point: Although both $(C Locomotive) and $(C RailwayCar) inherit from $(C RailwayVehicle), it would not be correct to inherit $(C Train) from either of them. Inheritance models the "is a" relationship and a train is neither a locomotive nor a passenger car. A train consists of them.
)

$(P
If we require that every train must have a locomotive, the $(C Train) constructor must ensure that it takes a valid $(C Locomotive) object. Similarly, if the railway cars are optional, they can be added by a member function:
)

---
$(CODE_NAME Train_ctor)import std.exception;
// ...

$(CODE_COMMENT_OUT)class Train : RailwayVehicle {
    // ...

    this(Locomotive locomotive) {
        enforce(locomotive !is null,
                "Locomotive cannot be null");
        this.locomotive = locomotive;
    }

    void addCar(RailwayCar[] cars...) {
        this.cars ~= cars;
    }

    // ...
$(CODE_COMMENT_OUT)}
---

$(P
Note that $(C addCar()) can validate the $(C RailwayCar) objects as well. I am ignoring that validation here.
)

$(P
We can imagine that the departures and arrivals of trains should also be supported:
)

---
$(CODE_NAME Train)$(CODE_XREF RailwayCar)class Train : RailwayVehicle {
    // ...

    void departStation(string station) {
        foreach (car; cars) {
            car.load();
        }

        writefln("Departing from %s station", station);
    }

    void arriveStation(string station) {
        writefln("Arriving at %s station", station);

        foreach (car; cars) {
            car.unload();
        }
    }
$(CODE_XREF Train_members)$(CODE_XREF Train_ctor)}
---

$(P
The following $(C main()) is making use of the $(C RailwayVehicle) hierarchy:
)

---
$(CODE_XREF Locomotive)$(CODE_XREF Train)$(CODE_XREF PassengerCar_FreightCar)import std.stdio;

// ...

void main() {
    auto locomotive = new Locomotive;
    auto train = new Train(locomotive);

    train.addCar(new PassengerCar, new FreightCar);

    train.departStation("Ankara");
    train.advance(500);
    train.arriveStation("Haydarpaşa");
}
---

$(P
The $(C Train) class is being used by functions that are provided by two separate interfaces:
)

$(OL

$(LI
When the $(C advance()) function is called, the $(C Train) object is being used as a $(C RailwayVehicle) because that function is declared by $(C RailwayVehicle).
)

$(LI When the $(C departStation()) and $(C arriveStation()) functions are called, $(C train) is being used as a $(C Train) because those functions are declared by $(C Train).)

)

$(P
The arrows indicate that $(C load()) and $(C unload()) functions work according to the actual type of $(C RailwayCar):
)

$(SHELL
The passengers are getting on     $(SHELL_NOTE)
The crates are being loaded       $(SHELL_NOTE)
Departing from Ankara station
The vehicle is advancing 500 kilometers
Arriving at Haydarpaşa station
The passengers are getting off    $(SHELL_NOTE)
The crates are being unloaded     $(SHELL_NOTE)
)

$(H5 Summary)

$(UL
$(LI Inheritance is used for the "is a" relationship.)
$(LI Every class can inherit from up to one $(C class).)
$(LI $(C super) has two uses: Calling the constructor of the superclass and accessing the members of the superclass.)
$(LI $(C override) is for redefining member functions of the superclass specially for the subclass.)
$(LI $(C abstract) requires that a member function must be overridden.)
)

$(PROBLEM_COK

$(PROBLEM
Let's modify $(C RailwayVehicle). In addition to reporting the distance that it advances, let's have it also make sounds. To keep the output short, let's print the sounds per 100 kilometers:

---
class RailwayVehicle {
    void advance(size_t kilometers) {
        writefln("The vehicle is advancing %s kilometers",
                 kilometers);

        foreach (i; 0 .. kilometers / 100) {
            writefln("  %s", makeSound());
        }
    }

    // ...
}
---

$(P
However, $(C makeSound()) cannot be defined by $(C RailwayVehicle) because vehicles may have different sounds:
)

$(UL
$(LI "choo choo" for $(C Locomotive))
$(LI "clack clack" for $(C RailwayCar))
)

$(P $(I $(B Note:) Leave $(C Train.makeSound) to the next exercise.)
)

$(P
Because it must be overridden, $(C makeSound()) must be declared as $(C abstract) by the superclass:
)

---
class RailwayVehicle {
    // ...

    abstract string makeSound();
}
---

$(P
Implement $(C makeSound()) for the subclasses and try the code with the following $(C main()):
)

---
$(CODE_XREF Locomotive)$(CODE_XREF Train)$(CODE_XREF PassengerCar_FreightCar)void main() {
    auto railwayCar1 = new PassengerCar;
    railwayCar1.advance(100);

    auto railwayCar2 = new FreightCar;
    railwayCar2.advance(200);

    auto locomotive = new Locomotive;
    locomotive.advance(300);
}
---

$(P
Make the program produce the following output:
)

$(SHELL
The vehicle is advancing 100 kilometers
  clack clack
The vehicle is advancing 200 kilometers
  clack clack
  clack clack
The vehicle is advancing 300 kilometers
  choo choo
  choo choo
  choo choo
)

$(P
Note that there is no requirement that the sounds of $(C PassengerCar) and $(C FreightCar) be different. They can share the same implemention from $(C RailwayCar).
)

)

$(PROBLEM
Think about how $(C makeSound()) can be implemented for $(C Train). One idea is that $(C Train.makeSound) may return a $(C string) that consists of the sounds of the members of $(C Train).
)

)

Macros:
        TITLE=Inheritance

        DESCRIPTION=Inheriting classes from classes in the D programming language.

        KEYWORDS=d programming lesson book tutorial class inheeritance
