Ddoc

$(DERS_BOLUMU $(IX Object) $(CH4 Object))

$(P
Classes that do not explicitly inherit any class, automatically inherit the $(C Object) class.
)

$(P
By that definition, the topmost class in any class hierarchy inherits $(C Object):
)

---
// ": Object" is not written; it is automatic
class MusicalInstrument $(DEL : Object ) {
    // ...
}

// Inherits Object indirectly
class StringInstrument : MusicalInstrument {
    // ...
}
---

$(P
Since the topmost class inherits $(C Object), every class indirectly inherits $(C Object) as well. In that sense, every class "is an" $(C Object).
)

$(P
Every class inherits the following member functions of $(C Object):
)

$(UL
$(LI $(C toString): The $(C string) representation of the object.)
$(LI $(C opEquals): Equality comparison with another object.)
$(LI $(C opCmp): Sort order comparison with another object.)
$(LI $(C toHash): Associative array hash value.)
)

$(P
The last three of these functions emphasize the values of objects. They also make a class eligible for being the key type of associative arrays.
)

$(P
Because these functions are inherited, their redefinitions for the subclasses require the $(C override) keyword.
)

$(P $(I $(B Note:) $(C Object) defines other members as well. This chapter will include only those four member functions of it.)
)

$(H5 $(IX typeid) $(IX TypeInfo) $(C typeid) and $(C TypeInfo))

$(P
$(C Object) is defined in the $(LINK2 http://dlang.org/phobos/object.html, $(C object) module) (which is not a part of the $(C std) package). The $(C object) module defines $(C TypeInfo) as well, a class that provides information about types. Every type has a distinct $(C TypeInfo) object. The $(C typeid) $(I expression) provides access to the $(C TypeInfo) object that is associated with a particular type. As we will see later below, the $(C TypeInfo) class can be used for determining whether two types are the same, as well as for accessing special functions of a type ($(C toHash), $(C postblit), etc., most of which are not covered in this book).
)

$(P
$(C TypeInfo) is always about the actual run-time type. For example, although both $(C Violin) and $(C Guitar) below inherit $(C StringInstrument) directly and $(C MusicalInstrument) indirectly, the $(C TypeInfo) instances of $(C Violin) and $(C Guitar) are different. They are exactly for $(C Violin) and $(C Guitar) types, respectively:
)

---
class MusicalInstrument {
}

class StringInstrument : MusicalInstrument {
}

class Violin : StringInstrument {
}

class Guitar : StringInstrument {
}

void main() {
    TypeInfo v = $(HILITE typeid)(Violin);
    TypeInfo g = $(HILITE typeid)(Guitar);
    assert(v != g);    $(CODE_NOTE the two types are not the same)
}
---

$(P
The $(C typeid) expressions above are being used with $(I types) like $(C Violin) itself. $(C typeid) can take an $(I expression) as well, in which case it returns the $(C TypeInfo) object for the run-time type of that expression. For example, the following function takes two parameters of different but related types:
)

---
import std.stdio;

// ...

void foo($(HILITE MusicalInstrument) m, $(HILITE StringInstrument) s) {
    const isSame = (typeid(m) == typeid(s));

    writefln("The types of the arguments are %s.",
             isSame ? "the same" : "different");
}

// ...

    auto a = new $(HILITE Violin)();
    auto b = new $(HILITE Violin)();
    foo(a, b);
---

$(P
Since both arguments to $(C foo()) are two $(C Violin) objects for that particular call, $(C foo()) determines that their types are the same:
)

$(SHELL
The types of the arguments are $(HILITE the same).
)

$(P
Unlike $(C .sizeof) and $(C typeof), which never execute their expressions, $(C typeid) always executes the expression that it receives:
)

---
import std.stdio;

int foo(string when) {
    writefln("Called during '%s'.", when);
    return 0;
}

void main() {
    const s = foo("sizeof")$(HILITE .sizeof);     // foo() is not called
    alias T = $(HILITE typeof)(foo("typeof"));    // foo() is not called
    auto ti = $(HILITE typeid)(foo("typeid"));    // foo() is called
}
---

$(P
The output indicates that only the expression of $(C typeid) is executed:
)

$(SHELL
Called during 'typeid'.
)

$(P
The reason for this difference is because actual run-time types of expressions may not be known until those expressions are executed. For example, the exact return type of the following function would be either $(C Violin) or $(C Guitar) depending on the value of function argument $(C i):
)

---
MusicalInstrument foo(int i) {
    return ($(HILITE i) % 2) ? new Violin() : new Guitar();
}
---

$(P
$(IX TypeInfo_Class) $(IX .classinfo) There are various subclasses of $(C TypeInfo) for various kinds of types like arrays, structs, classes, etc. Of these, $(C TypeInfo_Class) can be particularly useful. For example, the name of the run-time type of an object can be obtained through its $(C TypeInfo_Class.name) property as a $(C string). You can access the $(C TypeInfo_Class) instance of an object by its $(C .classinfo) property:
)

---
    TypeInfo_Class info = a$(HILITE .classinfo);
    string runtimeTypeName = info$(HILITE .name);
---

$(H5 $(IX toString) $(C toString))

$(P
Same with structs, $(C toString) enables using class objects as strings:
)

---
    auto clock = new Clock(20, 30, 0);
    writeln(clock);         // Calls clock.toString()
---

$(P
The inherited $(C toString()) is usually not useful; it produces just the name of the type:
)

$(SHELL
deneme.Clock
)

$(P
The part before the name of the type is the name of the module. The output above indicates that $(C Clock) has been defined in the $(C deneme) module.
)

$(P
As we have seen in the previous chapter, this function is almost always overridden to produce a more meaningful $(C string) representation:
)

---
import std.string;

class Clock {
    override string toString() const {
        return format("%02s:%02s:%02s", hour, minute, second);
    }

    // ...
}

class AlarmClock : Clock {
    override string toString() const {
        return format("%s ♫%02s:%02s", super.toString(),
                      alarmHour, alarmMinute);
    }

    // ...
}

// ...

    auto bedSideClock = new AlarmClock(20, 30, 0, 7, 0);
    writeln(bedSideClock);
---

$(P
The output:
)

$(SHELL
20:30:00 ♫07:00
)

$(H5 $(IX opEquals) $(C opEquals))

$(P
As we have seen in the $(LINK2 operator_overloading.html, Operator Overloading chapter), this member function is about the behavior of the $(C ==) operator (and the $(C !=) operator indirectly). The return value of the operator must be $(C true) if the objects are considered to be equal and $(C false) otherwise.
)

$(P
$(B Warning:) The definition of this function must be consistent with $(C opCmp()); for two objects that $(C opEquals()) returns $(C true), $(C opCmp()) must return zero.
)

$(P
Contrary to structs, the compiler does not call $(C a.opEquals(b)) right away when it sees the expression $(C a&nbsp;==&nbsp;b). When two class objects are compared by the $(C ==) operator, a four-step algorithm is executed:
)

---
bool opEquals(Object a, Object b) {
    if (a is b) return true;                          // (1)
    if (a is null || b is null) return false;         // (2)
    if (typeid(a) == typeid(b)) return a.opEquals(b); // (3)
    return a.opEquals(b) && b.opEquals(a);            // (4)
}
---

$(OL

$(LI If the two variables provide access to the same object (or they are both $(C null)), then they are equal.)

$(LI Following from the previous check, if only one is $(C null) then they are not equal.)

$(LI If both of the objects are of the same type, then $(C a.opEquals(b)) is called to determine the equality.)

$(LI Otherwise, for the two objects to be considered equal, $(C opEquals) must have been defined for both of their types and $(C a.opEquals(b)) and $(C b.opEquals(a)) must agree that the objects are equal.)

)

$(P
Accordingly, if $(C opEquals()) is not provided for a class type, then the values of the objects are not considered; rather, equality is determined by checking whether the two class variables provide access to the same object:
)

---
    auto variable0 = new Clock(6, 7, 8);
    auto variable1 = new Clock(6, 7, 8);

    assert(variable0 != variable1); // They are not equal
                                    // because the objects are
                                    // different
---

$(P
Even though the two objects are constructed by the same arguments above, the variables are not equal because they are not associated with the same object.
)

$(P
On the other hand, because the following two variables provide access to the same object, they are $(I equal):
)

---
    auto partner0 = new Clock(9, 10, 11);
    auto partner1 = partner0;

    assert(partner0 == partner1);   // They are equal because
                                    // the object is the same
---

$(P
Sometimes it makes more sense to compare objects by their values instead of their identities. For example, it is conceivable that $(C variable0) and $(C variable1) above compare equal because their values are the same.
)

$(P
Different from structs, the type of the parameter of $(C opEquals) for classes is $(C Object):
)

---
class Clock {
    override bool opEquals($(HILITE Object o)) const {
        // ...
    }

    // ...
}
---

$(P
As you will see below, the parameter is almost never used directly. For that reason, it should be acceptable to name it simply as $(C o). Most of the time the first thing to do with that parameter is to use it in a type conversion.
)

$(P
The parameter of $(C opEquals) is the object that appears on the right-hand side of the $(C ==) operator:
)

---
    variable0 == variable1;    // o represents variable1
---

$(P
Since the purpose of $(C opEquals()) is to compare two objects of this class type, the first thing to do is to convert $(C o) to a variable of the same type of this class. Since it would not be appropriate to modify the right-hand side object in an equality comparison, it is also proper to convert the type as $(C const):
)

---
    override bool opEquals(Object o) const {
        auto rhs = cast(const Clock)o;

        // ...
    }
---

$(P
As you would remember, $(C rhs) is a common abbreviation for $(I right-hand side). Also, $(C std.conv.to) can be used for the conversion as well:
)

---
import std.conv;
// ...
        auto rhs = to!(const Clock)(o);
---

$(P
If the original object on the right-hand side can be converted to $(C Clock), then $(C rhs) becomes a non-$(C null) class variable. Otherwise, $(C rhs) is set to $(C null), indicating that the objects are not of the same type.
)

$(P
According to the design of a program, it may make sense to compare objects of two incompatible types. I will assume here that for the comparison to be valid, $(C rhs) must not be $(C null); so, the first logical expression in the following $(C return) statement checks that it is not $(C null). Otherwise, it would be an error to try to access the members of $(C rhs):
)

---
class Clock {
    int hour;
    int minute;
    int second;

    override bool opEquals(Object o) const {
        auto rhs = cast(const Clock)o;

        return ($(HILITE rhs) &&
                (hour == rhs.hour) &&
                (minute == rhs.minute) &&
                (second == rhs.second));
    }

    // ...
}
---

$(P
With that definition, $(C Clock) objects can now be compared by their values:
)

---
    auto variable0 = new Clock(6, 7, 8);
    auto variable1 = new Clock(6, 7, 8);

    assert(variable0 == variable1); // Now they are equal
                                    // because their values
                                    // are equal
---

$(P
When defining $(C opEquals) it is important to remember the members of the superclass. For example, when comparing objects of $(C AlarmClock) it would make sense to also consider the inherited members:
)

---
class AlarmClock : Clock {
    int alarmHour;
    int alarmMinute;

    override bool opEquals(Object o) const {
        auto rhs = cast(const AlarmClock)o;

        return (rhs &&
                (alarmHour == rhs.alarmHour) &&
                (alarmMinute == rhs.alarmMinute) &&
                $(HILITE super.opEquals(o)));
    }

    // ...
}
---

$(P
That expression could be written as $(C super&nbsp;==&nbsp;o) as well. However, that would initiate the four-step algorithm again and as a result, the code might be a little slower.
)

$(H5 $(IX opCmp) $(C opCmp))

$(P
This operator is used when sorting class objects. $(C opCmp) is the function that gets called behind the scenes for the $(C <), $(C <=), $(C >), and $(C >=).
)

$(P
This operator must return a negative value when the left-hand object is before, a positive value when the left-hand object is after, and zero when both objects have the same sorting order.
)

$(P
$(B Warning:) The definition of this function must be consistent with $(C opEquals()); for two objects that $(C opEquals()) returns $(C true), $(C opCmp()) must return zero.
)

$(P
Unlike $(C toString) and $(C opEquals), there is no default implementation of this function in $(C Object). If the implementation is not available, comparing objects for sort order causes an exception to be thrown:
)

---
    auto variable0 = new Clock(6, 7, 8);
    auto variable1 = new Clock(6, 7, 8);

    assert(variable0 <= variable1);    $(CODE_NOTE Causes exception)
---

$(SHELL
object.Exception: need opCmp for class deneme.Clock
)

$(P
It is up to the design of the program what happens when the left-hand and right-hand objects are of different types. One way is to take advantage of the order of types that is maintained by the compiler automatically. This is achieved by calling the $(C opCmp) function on the $(C typeid) values of the two types:
)

---
class Clock {
    int hour;
    int minute;
    int second;

    override int opCmp(Object o) const {
        /* Taking advantage of the automatically-maintained
         * order of the types. */
        if (typeid(this) != typeid(o)) {
            return typeid(this).opCmp(typeid(o));
        }

        auto rhs = cast(const Clock)o;
        /* No need to check whether rhs is null, because it is
         * known at this line that it has the same type as o. */

        if (hour != rhs.hour) {
            return hour - rhs.hour;

        } else if (minute != rhs.minute) {
            return minute - rhs.minute;

        } else {
            return second - rhs.second;
        }
    }

    // ...
}
---

$(P
The definition above first checks whether the types of the two objects are the same. If not, it uses the ordering of the types themselves. Otherwise, it compares the objects by the values of their $(C hour), $(C minute), and $(C second) members.
)

$(P
A chain of ternary operators may also be used:
)

---
    override int opCmp(Object o) const {
        if (typeid(this) != typeid(o)) {
            return typeid(this).opCmp(typeid(o));
        }

        auto rhs = cast(const Clock)o;

        return (hour != rhs.hour
                ? hour - rhs.hour
                : (minute != rhs.minute
                   ? minute - rhs.minute
                   : second - rhs.second));
    }
---

$(P
If important, the comparison of the members of the superclass must also be considered. The following $(C AlarmClock.opCmp) is calling $(C Clock.opCmp) first:
)

---
class AlarmClock : Clock {
    override int opCmp(Object o) const {
        auto rhs = cast(const AlarmClock)o;

        const int superResult = $(HILITE super.opCmp(o));

        if (superResult != 0) {
            return superResult;

        } else if (alarmHour != rhs.alarmHour) {
            return alarmHour - rhs.alarmHour;

        } else {
            return alarmMinute - rhs.alarmMinute;
        }
    }

    // ...
}
---

$(P
Above, if the superclass comparison returns a nonzero value then that result is used because the sort order of the objects is already determined by that value.
)

$(P
$(C AlarmClock) objects can now be compared for their sort orders:
)

---
    auto ac0 = new AlarmClock(8, 0, 0, 6, 30);
    auto ac1 = new AlarmClock(8, 0, 0, 6, 31);

    assert(ac0 < ac1);
---

$(P
$(C opCmp) is used by other language features and libraries as well. For example, the $(C sort()) function takes advantage of $(C opCmp) when sorting elements.
)

$(H6 $(C opCmp) for string members)

$(P
When some of the members are strings, they can be compared explicitly to return a negative, positive, or zero value:
)

---
import std.exception;

class Student {
    string name;

    override int opCmp(Object o) const {
        auto rhs = cast(Student)o;
        enforce(rhs);

        if (name < rhs.name) {
            return -1;

        } else if (name > rhs.name) {
            return 1;

        } else {
            return 0;
        }
    }

    // ...
}
---

$(P
Instead, the existing $(C std.algorithm.cmp) function can be used, which happens to be faster as well:
)

---
import std.algorithm;

class Student {
    string name;

    override int opCmp(Object o) const {
        auto rhs = cast(Student)o;
        enforce(rhs);

        return cmp(name, rhs.name);
    }

    // ...
}
---

$(P
Also note that $(C Student) does not support comparing incompatible types by enforcing that the conversion from $(C Object) to $(C Student) is possible.
)

$(H5 $(IX toHash) $(C toHash))

$(P
This function allows objects of a class type to be used as associative array $(I keys). It does not affect the cases where the type is used as associative array $(I values). If this function is defined, $(C opEquals) must be defined as well.
)

$(H6 $(IX hash table) Hash table indexes)

$(P
Associative arrays are a hash table implementation. Hash table is a very fast data structure when it comes to searching elements in the table. ($(I Note: Like most other things in software, this speed comes at a cost: Hash tables must keep elements in an unordered way, and they may be taking up space that is more than exactly necessary.))
)

$(P
The high speed of hash tables comes from the fact that they first produce integer values for keys. These integers are called $(I hash values). The hash values are then used for indexing into an internal array that is maintained by the table.
)

$(P
A benefit of this method is that any type that can produce unique integer values for its objects can be used as the key type of associative arrays. $(C toHash) is the function that returns the hash value for an object.
)

$(P
Even $(C Clock) objects can be used as associative array key values:
)

---
    string[$(HILITE Clock)] timeTags;
    timeTags[new Clock(12, 0, 0)] = "Noon";
---

$(P
The default definition of $(C toHash) that is inherited from $(C Clock) produces different hash values for different objects without regard to their values. This is similar to how the default behavior of $(C opEquals) considers different objects as being not equal.
)

$(P
The code above compiles and runs even when there is no special definition of $(C toHash) for $(C Clock). However, its default behavior is almost never what is desired. To see that default behavior, let's try to access an element by an object that is different from the one that has been used when inserting the element. Although the new $(C Clock) object below has the same value as the $(C Clock) object that has been used when inserting into the associative array above, the value cannot be found:
)

---
    if (new Clock(12, 0, 0) in timeTags) {
        writeln("Exists");

    } else {
        writeln("Missing");
    }
---

$(P
According to the $(C in) operator, there is no element in the table that corresponds to the value $(C Clock(12,&nbsp;0,&nbsp;0)):
)

$(SHELL
Missing
)

$(P
The reason for this surprising behavior is that the key object that has been used when inserting the element is not the same as the key object that has been used when accessing the element.
)

$(H6 Selecting members for $(C toHash))

$(P
Although the hash value is calculated from the members of an object, not every member is suitable for this task.
)

$(P
The candidates are the members that distinguish objects from each other. For example, the members $(C name) and $(C lastName) of a $(C Student) class would be suitable if those members can be used for identifying objects of that type.
)

$(P
On the other hand, a $(C grades) array of a $(C Student) class would not be suitable both because many objects may have the same array and also it is likely that the $(C grades) array may change over time.
)

$(H6 Calculating hash values)

$(P
The choice of hash values has a direct effect on the performance of associative arrays. Furthermore, a hash calculation that is effective on one type of data may not be as effective on another type of data. As $(I hash algorithms) are beyond the scope of this book, I will give just one guideline here: In general, it is better to produce different hash values for objects that are considered to have different values. However, it is not an error if two objects with different values produce the same index value; it is merely undesirable for performance reasons.
)

$(P
It is conceivable that all of the members of $(C Clock) are significant to distinguish its objects from each other. For that reason, the hash values can be calculated from the values of its three members. $(I The number of seconds since midnight) would be effective hash values for objects that represent different points in time:
)

---
class Clock {
    int hour;
    int minute;
    int second;

    override size_t toHash() const {
        /* Because there are 3600 seconds in an hour and 60
         * seconds in a minute: */
        return (3600 * hour) + (60 * minute) + second;
    }

    // ...
}
---

$(P
Whenever $(C Clock) is used as the key type of associative arrays, that special definition of $(C toHash) would be used. As a result, even though the two key objects of $(C Clock(12,&nbsp;0,&nbsp;0)) above are distinct, they would now produce the same hash value.
)

$(P
The new output:
)

$(SHELL
Exists
)

$(P
Similar to the other member functions, the superclass may need to be considered as well. For example, $(C AlarmClock.toHash) can take advantage of $(C Clock.toHash) during its index calculation:
)

---
class AlarmClock : Clock {
    int alarmHour;
    int alarmMinute;

    override size_t toHash() const {
        return $(HILITE super.toHash()) + alarmHour + alarmMinute;
    }

    // ...
}
---

$(P
$(I $(B Note:) Take the calculation above just as an example. In general, adding integer values is not an effective way of generating hash values.)
)

$(P
There are existing efficient algorithms for calculating hash values for variables of floating point, array, and struct types. These algorithms are available to the programmer as well.
)

$(P
$(IX getHash) What needs to be done is to call $(C getHash()) on the $(C typeid) of each member. The syntax of this method is the same for floating point, array, and struct types.
)

$(P
For example, hash values of a $(C Student) type can be calculated from its $(C name) member as in the following code:
)

---
class Student {
    string name;

    override size_t toHash() const {
        return typeid(name).getHash(&name);
    }

    // ...
}
---

$(H6 Hash values for structs)

$(P
Since structs are value types, hash values for their objects are calculated automatically by an efficient algorithm. That algorithm takes all of the members of the object into consideration.
)

$(P
When there is a specific reason like needing to exclude certain members from the hash calculation, $(C toHash()) can be overridden for structs as well.
)

$(PROBLEM_COK

$(PROBLEM
Start with the following class, which represents colored points:

---
enum Color { blue, green, red }

class Point {
    int x;
    int y;
    Color color;

    this(int x, int y, Color color) {
        this.x = x;
        this.y = y;
        this.color = color;
    }
}
---

$(P
Implement $(C opEquals) for this class in a way that ignores colors. When implemented in that way, the following $(C assert) check should pass:
)

---
    // Different colors
    auto bluePoint = new Point(1, 2, Color.blue);
    auto greenPoint = new Point(1, 2, Color.green);

    // They are still equal
    assert(bluePoint == greenPoint);
---

)

$(PROBLEM
Implement $(C opCmp) by considering first $(C x) then $(C y). The following $(C assert) checks should pass:

---
    auto redPoint1 = new Point(-1, 10, Color.red);
    auto redPoint2 = new Point(-2, 10, Color.red);
    auto redPoint3 = new Point(-2,  7, Color.red);

    assert(redPoint1 < bluePoint);
    assert(redPoint3 < redPoint2);

    /* Even though blue is before green in enum Color,
     * because color is being ignored, bluePoint must not be
     * before greenPoint. */
    assert(!(bluePoint < greenPoint));
---

$(P
Like the $(C Student) class above, you can implement $(C opCmp) by excluding incompatible types by the help of $(C enforce).
)

)

$(PROBLEM
Consider the following class that combines three $(C Point) objects in an array:

---
class TriangularArea {
    Point[3] points;

    this(Point one, Point two, Point three) {
        points = [ one, two, three ];
    }
}
---

$(P
Implement $(C toHash) for that class. Again, the following $(C assert) checks should pass:
)

---
    /* area1 and area2 are constructed by distinct points that
     * happen to have the same values. (Remember that
     * bluePoint and greenPoint should be considered equal.) */
    auto area1 = new TriangularArea(bluePoint, greenPoint, redPoint1);
    auto area2 = new TriangularArea(greenPoint, bluePoint, redPoint1);

    // The areas should be equal
    assert(area1 == area2);

    // An associative array
    double[TriangularArea] areas;

    // A value is being entered by area1
    areas[area1] = 1.25;

    // The value is being accessed by area2
    assert(area2 in areas);
    assert(areas[area2] == 1.25);
---

$(P
Remember that $(C opEquals) must also be defined when $(C toHash) is defined.
)

)

)

Macros:
        TITLE=Object

        DESCRIPTION=Object, the topmost class in class hierarchies in the D programming language

        KEYWORDS=d programming lesson book tutorial class Object opEquals opCmp toHash toString
