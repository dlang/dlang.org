Ddoc

$(DERS_BOLUMU $(IX interface) Interfaces)

$(P
The $(C interface) keyword is for defining interfaces in class hierarchies. $(C interface) is very similar to $(C class) with the following restrictions:
)

$(UL

$(LI
The member functions that it declares (but not implements) are abstract even without the $(C abstract) keyword.
)

$(LI
The member functions that it implements must be $(C static) or $(C final). ($(C static) and $(C final) member functions are explained below.)
)

$(LI
Its member variables must be $(C static).
)

$(LI
Interfaces can inherit only interfaces.
)

)

$(P
Despite these restrictions, there is no limit on the number of $(C interface)s that a class can inherit from. (In contrast, a class can inherit from up to one $(C class).)
)

$(H5 Definition)

$(P
Interfaces are defined by the $(C interface) keyword, the same way as classes:
)

---
$(HILITE interface) SoundEmitter {
    // ...
}
---

$(P
An $(C interface) is for declaring member functions that are implicitly abstract:
)

---
interface SoundEmitter {
    string emitSound();    // Declared (not implemented)
}
---

$(P
Classes that inherit from that interface would have to provide the implementations of the abstract functions of the interface.
)

$(P
Interface function declarations can have $(C in) and $(C out) contract blocks:
)

---
interface I {
    int func(int i)
    $(HILITE in) {
        /* Strictest requirements that the callers of this
         * function must meet. (Derived interfaces and classes
         * can loosen these requirements.) */

    } $(HILITE out) {    // (optionally with (result) parameter)
        /* Exit guarantees that the implementations of this
         * function must give. (Derived interfaces and classes
         * can give additional guarantees.) */
    }
}
---

$(P
We will see examples of contract inheritance later in $(LINK2 invariant.html, the Contract Programming for Structs and Classes chapter).
)

$(H5 Inheriting from an $(C interface))

$(P
The $(C interface) inheritance syntax is the same as $(C class) inheritance:
)

---
class Violin : $(HILITE SoundEmitter) {
    string emitSound() {
        return "♩♪♪";
    }
}

class Bell : $(HILITE SoundEmitter) {
    string emitSound() {
        return "ding";
    }
}
---

$(P
Interfaces support polymorphism: Functions that take interface parameters can use those parameters without needing to know the actual types of objects. For example, the following function that takes a parameter of $(C SoundEmitter) calls $(C emitSound()) on that parameter without needing to know the actual type of the object:
)

---
void useSoundEmittingObject(SoundEmitter object) {
    // ... some operations ...
    writeln(object.emitSound());
    // ... more operations ...
}
---

$(P
Just like with classes, that function can be called with any type of object that inherits from the $(C SoundEmitter) interface:
)

---
    useSoundEmittingObject(new Violin);
    useSoundEmittingObject(new Bell);
---

$(P
The special $(C emitSound()) function for each object would get called and the outputs of $(C Violin.emitSound) and $(C Bell.emitSound) would be printed:
)

$(SHELL
♩♪♪
ding
)

$(H5 Inheriting from more than one $(C interface))

$(P
A class can be inherited from up to one $(C class). There is no limit on the number of $(C interface)s to inherit from.
)

$(P
Let's consider the following interface that represents communication devices:
)

---
interface CommunicationDevice {
    void talk(string message);
    string listen();
}
---

$(P
If a $(C Phone) class needs to be used both as a sound emitter and a communication device, it can inherit both of those interfaces:
)

---
class Phone : $(HILITE SoundEmitter, CommunicationDevice) {
    // ...
}
---

$(P
That definition represents both of these relationships: "phone is a sound emitter" and "phone is a communication device."
)

$(P
In order to construct objects of this class, $(C Phone) must implement the abstract functions of both of the interfaces:
)

---
class Phone : SoundEmitter, CommunicationDevice {
    string emitSound() {           // for SoundEmitter
        return "rrring";
    }

    void talk(string message) {    // for CommunicationDevice
        // ... put the message on the line ...
    }

    string listen() {              // for CommunicationDevice
        string soundOnTheLine;
        // ... get the message from the line ...
        return soundOnTheLine;
    }
}
---

$(P
A class can inherit from any number of interfaces as it makes sense according to the design of the program.
)

$(H5 Inheriting from $(C interface) and $(C class))

$(P
Classes can still inherit from up to one $(C class) as well:
)

---
$(HILITE class) Clock {
    // ... clock implementation ...
}

class AlarmClock : $(HILITE Clock), SoundEmitter {
    string emitSound() {
        return "beep";
    }
}
---

$(P
$(C AlarmClock) inherits the members of $(C Clock). Additionally, it also provides the $(C emitSound()) function that the $(C SoundEmitter) interface requires.
)

$(H5 Inheriting $(C interface) from $(C interface))

$(P
An interface that is inherited from another interface effectively increases the number of functions that the subclasses must implement:
)

---
interface MusicalInstrument : SoundEmitter {
    void adjustTuning();
}
---

$(P
According to the definition above, in order to be a $(C MusicalInstrument), both the $(C emitSound()) function that $(C SoundEmitter) requires and the $(C adjustTuning()) function that $(C MusicalInstrument) requires must be implemented.
)

$(P
For example, if $(C Violin) inherits from $(C MusicalInstrument) instead of $(C SoundEmitter), it must now also implement $(C adjustTuning()):
)

---
class Violin : MusicalInstrument {
    string emitSound() {     // for SoundEmitter
        return "♩♪♪";
    }

    void adjustTuning() {    // for MusicalInstrument
        // ... special tuning of the violin ...
    }
}
---

$(H5 $(IX static, member function) $(C static) member functions)

$(P
I have delayed explaining $(C static) member functions until this chapter to keep the earlier chapters shorter. $(C static) member functions are available for structs, classes, and interfaces.
)

$(P
Regular member functions are always called on an object. The member variables that are referenced inside the member function are the members of a particular object:
)

---
struct Foo {
    int i;

    void modify(int value) {
        $(HILITE i) = value;
    }
}

void main() {
    auto object0 = Foo();
    auto object1 = Foo();

    object0.modify(10);    // object0.i changes
    object1.modify(10);    // object1.i changes
}
---

$(P
The members can also be referenced by $(C this):
)

---
    void modify(int value) {
        this.i = value;    // equivalent of the previous one
    }
---

$(P
A $(C static) member function does not operate on an object; there is no object that the $(C this) keyword would refer to, so $(C this) is not valid inside a $(C static) function. For that reason, none of the regular member variables are available inside $(C static) member functions:
)

---
struct Foo {
    int i;

    $(HILITE static) void commonFunction(int value) {
        i = value;         $(DERLEME_HATASI)
        this.i = value;    $(DERLEME_HATASI)
    }
}
---

$(P
$(C static) member functions can use only the $(C static) member variables.
)

$(P
Let's redesign the $(C Point) struct that we have seen earlier in $(LINK2 struct.html, the Structs chapter), this time with a $(C static) member function. In the following code, every $(C Point) object gets a unique id, which is determined by a $(C static) member function:
)

---
import std.stdio;

struct Point {
    size_t id;    // Object id
    int line;
    int column;

    // The id to be used for the next object
    $(HILITE static) size_t nextId;

    this(int line, int column) {
        this.line = line;
        this.column = column;
        this.id = makeNewId();
    }

    $(HILITE static) size_t makeNewId() {
        immutable newId = nextId;
        ++nextId;
        return newId;
    }
}

void main() {
    auto top = Point(7, 0);
    auto middle = Point(8, 0);
    auto bottom =  Point(9, 0);

    writeln(top.id);
    writeln(middle.id);
    writeln(bottom.id);
}
---

$(P
The $(C static) $(C makeNewId()) function can use the common variable $(C nextId). As a result, every object gets a unique id:
)

$(SHELL
0
1
2
)

$(P
Although the example above contains a $(C struct), $(C static) member functions are available for classes and interfaces as well.
)

$(H5 $(IX final) $(C final) member functions)

$(P
I have delayed explaining $(C final) member functions until this chapter to keep the earlier chapters shorter. $(C final) member functions are relevant only for classes and interfaces because structs do not support inheritance.
)

$(P
$(C final) specifies that a member function cannot be redefined by a subclass. In a sense, the implementation that this $(C class) or $(C interface) provides is the $(I final) implementation of that function. An example of a case where this feature is useful is where the general steps of an algorithm are defined by an interface and the finer details are left to subclasses.
)

$(P
Let's see an example of this with a $(C Game) interface. The general steps of playing a game is being determined by the $(C play()) function of the following $(C interface):
)

---
$(CODE_NAME Game)interface Game {
    $(HILITE final) void play() {
        string name = gameName();
        writefln("Starting %s", name);

        introducePlayers();
        prepare();
        begin();
        end();

        writefln("Ending %s", name);
    }

    string gameName();
    void introducePlayers();
    void prepare();
    void begin();
    void end();
}
---

$(P
It is not possible for subclasses to modify the definition of the $(C play()) member function. The subclasses can (and must) provide the definitions of the five abstract member functions that are declared by the interface. By doing so, the subclasses complete the missing steps of the algorithm:
)

---
$(CODE_XREF Game)import std.stdio;
import std.string;
import std.random;
import std.conv;

class DiceSummingGame : Game {
    string player;
    size_t count;
    size_t sum;

    string gameName() {
        return "Dice Summing Game";
    }

    void introducePlayers() {
        write("What is your name? ");
        player = strip(readln());
    }

    void prepare() {
        write("How many times to throw the dice? ");
        readf(" %s", &count);
        sum = 0;
    }

    void begin() {
        foreach (i; 0 .. count) {
            immutable dice = uniform(1, 7);
            writefln("%s: %s", i, dice);
            sum += dice;
        }
    }

    void end() {
        writefln("Player: %s, Dice sum: %s, Average: %s",
                 player, sum, to!double(sum) / count);
    }
}

void useGame(Game game) {
    game.play();
}

void main() {
    useGame(new DiceSummingGame());
}
---

$(P
Although the example above contains an $(C interface), $(C final) member functions are available for classes as well.
)

$(H5 How to use)

$(P
$(C interface) is a commonly used feature. There is one or more $(C interface) at the top of almost every class hierarchy. A kind of hierarchy that is commonly encountered in programs involves a single $(C interface) and a number of classes that implement that interface:
)

$(MONO
               $(I MusicalInstrument
                 (interface))
               /    |     \     \
          Violin  Guitar  Flute  ...
)

$(P
Although there are more complicated hierarchies in practice, the simple hierarchy above solves many problems.
)

$(P
It is also common to move common implementation details of class hierarchies to intermediate classes. The subclasses inherit from these intermediate classes. The $(C StringInstrument) and $(C WindInstrument) classes below can contain the common members of their respective subclasses:
)

$(MONO
               $(I MusicalInstrument
                 (interface))
                 /         \
   StringInstrument       WindInstrument
     /    |     \         /      |     \
Violin  Viola    ...   Flute  Clarinet  ...
)

$(P
The subclasses would implement their respective special definitions of member functions.
)

$(H5 $(IX abstraction) Abstraction)

$(P
Interfaces help make parts of programs independent from each other. This is called $(I abstraction). For example, a program that deals with musical instruments can be written primarily by using the $(C MusicalInstrument) interface, without ever specifying the actual types of the musical instruments.
)

$(P
A $(C Musician) class can contain a $(C MusicalInstrument) without ever knowing the actual type of the instrument:
)

---
class Musician {
    MusicalInstrument instrument;
    // ...
}
---

$(P
Different types of musical instruments can be combined in a collection without regard to the actual types of these instruments:
)

---
    MusicalInstrument[] orchestraInstruments;
---

$(P
Most of the functions of the program can be written only by using this interface:
)

---
bool needsTuning(MusicalInstrument instrument) {
    bool result;
    // ...
    return result;
}

void playInTune(MusicalInstrument instrument) {
    if (needsTuning(instrument)) {
        instrument.adjustTuning();
    }

    writeln(instrument.emitSound());
}
---

$(P
$(I Abstracting away) parts of a program from each other allows making changes in one part of the program without needing to modify the other parts. When implementations of certain parts of the program are $(I behind) a particular interface, the code that uses only that interface does not get affected.
)

$(H5 Example)

$(P
The following program defines the $(C SoundEmitter), $(C MusicalInstrument), and $(C CommunicationDevice) interfaces:
)

---
import std.stdio;

/* This interface requires emitSound(). */
interface SoundEmitter {
    string emitSound();
}

/* This class needs to implement only emitSound(). */
class Bell : SoundEmitter {
    string emitSound() {
        return "ding";
    }
}

/* This interface additionally requires adjustTuning(). */
interface MusicalInstrument : SoundEmitter {
    void adjustTuning();
}

/* This class needs to implement both emitSound() and
 * adjustTuning(). */
class Violin : MusicalInstrument {
    string emitSound() {
        return "♩♪♪";
    }

    void adjustTuning() {
        // ... tuning of the violin ...
    }
}

/* This interface requires talk() and listen(). */
interface CommunicationDevice {
    void talk(string message);
    string listen();
}

/* This class needs to implement emitSound(), talk(), and
 * listen(). */
class Phone : SoundEmitter, CommunicationDevice {
    string emitSound() {
        return "rrring";
    }

    void talk(string message) {
        // ... put the message on the line ...
    }

    string listen() {
        string soundOnTheLine;
        // ... get the message from the line ...
        return soundOnTheLine;
    }
}

class Clock {
    // ... the implementation of Clock ...
}

/* This class needs to implement only emitSound(). */
class AlarmClock : Clock, SoundEmitter {
    string emitSound() {
        return "beep";
    }

    // ... the implementation of AlarmClock ...
}

void main() {
    SoundEmitter[] devices;

    devices ~= new Bell;
    devices ~= new Violin;
    devices ~= new Phone;
    devices ~= new AlarmClock;

    foreach (device; devices) {
        writeln(device.emitSound());
    }
}
---

$(P
Because $(C devices) is a $(C SoundEmitter) slice, it can contain objects of any type that inherits from $(C SoundEmitter) (i.e. types that have an "is a" relationship with $(C SoundEmitter)). As a result, the output of the program consists of different sounds that are emitted by the different types of objects:
)

$(SHELL
ding
♩♪♪
rrring
beep
)

$(H5 Summary)

$(UL

$(LI
$(C interface) is similar to a $(C class) that consists only of abstract functions. $(C interface) can have $(C static) member variables and $(C static) or $(C final) member functions.
)

$(LI
For a class to be constructible, it must have implementations for all member functions of all interfaces that it inherits from.
)

$(LI
It is possible to inherit from unlimited number of $(C interface)s.
)

$(LI
A common hierarchy consists of a single $(C interface) and a number of subclasses that implement that interface.
)

)

Macros:
        TITLE=Interfaces

        DESCRIPTION=The interfaces of the D programming language.

        KEYWORDS=d programming lesson book tutorial interface
