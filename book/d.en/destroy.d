Ddoc

$(DERS_BOLUMU $(CH4 destroy) and $(CH4 scoped))

$(P
We have seen the lifetimes of objects in the $(LINK2 lifetimes.html, Lifetimes and Fundamental Operations chapter).
)

$(P
In later chapters, we have seen that the objects are prepared for use in the constructor, which is called $(C this()); and the final operations of objects are applied in the destructor, which is called $(C ~this()).
)

$(P
For structs and other value types, the destructor is executed at the time when the lifetime of an object ends. For classes and other reference types, it is executed by the garbage collector some time in the future. The important distinction is that the destructor of a class object is not executed when its lifetime ends.
)

$(P
System resources are commonly returned back to the system in destructors. For example, $(C std.stdio.File) returns the file resource back to the operating system in its destructor. As it is not certain when the destructor of a class object will be called, the system resources that it holds may not be returned until too late when other objects cannot get a hold of the same resource.
)

$(H5 An example of calling destructors late)

$(P
Let's define a class to see the effects of executing class destructors late. The following constructor increments a $(C static) counter, and the destructor decrements it. As you remember, there is only one of each $(C static) member, which is shared by all of the objects of a type. Such a counter would indicate the number of objects that are yet to be destroyed.
)

---
$(CODE_NAME LifetimeObserved)class LifetimeObserved {
    int[] array;           // ← Belongs to each object

    static size_t counter; // ← Shared by all objects

    this() {
        /* We are using a relatively large array to make each
         * object consume a large amount of memory. Hopefully
         * this will make the garbage collector call object
         * destructors more frequently to open up space for
         * more objects. */
        array.length = 30_000;

        /* Increment the counter for this object that is being
         * constructed. */
        ++counter;
    }

    ~this() {
        /* Decrement the counter for this object that is being
         * destroyed. */
        --counter;
    }
}
---

$(P
The following program constructs objects of that class inside a loop:
)

---
$(CODE_XREF LifetimeObserved)import std.stdio;

void main() {
    foreach (i; 0 .. 20) {
        auto variable = new LifetimeObserved;  // ← start
        write(LifetimeObserved.counter, ' ');
    } // ← end

    writeln();
}
---

$(P
The lifetime of each $(C LifetimeObserved) object is in fact very short: Its life starts when it is constructed by the $(C new) keyword and ends at the closing curly bracket of the $(C foreach) loop. Each object then becomes the responsibility of the garbage collector. The $(COMMENT start) and $(COMMENT end) comments indicate the start and end of the lifetimes.
)

$(P
Even though there is up to one object alive at a given time, the value of the counter indicates that the destructor is not executed when the lifetime ends:
)

$(SHELL
1 2 3 4 5 6 7 8 2 3 4 5 6 7 8 2 3 4 5 6 
)

$(P
According to that output, the memory sweep algorithm of the garbage collector has delayed executing the destructor for up to 8 objects. ($(I Note: The output may be different depending on the garbage collection algorithm, available memory, and other factors.))
)

$(H5 $(IX destroy) $(IX destructor, execution) $(C destroy()) to execute the destructor)

$(P
$(C destroy()) executes the destructor for an object:
)

---
$(CODE_XREF LifetimeObserved)void main() {
    foreach (i; 0 .. 20) {
        auto variable = new LifetimeObserved;
        write(LifetimeObserved.counter, ' ');
        $(HILITE destroy(variable));
    }

    writeln();
}
---

$(P
Like before, the value of $(C LifetimeObserved.counter) is incremented by the constructor as a result of $(C new), and becomes 1. This time, right after it gets printed, $(C destroy()) executes the destructor for the object and the value of the counter is decremented again down to zero. For that reason, this time its value is always 1:
)

$(SHELL
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
)

$(P
Once destroyed, the object should be considered to be in an invalid state and must not be used anymore:
)

---
    destroy(variable);
    // ...
    // Warning: Using a potentially invalid object
    writeln(variable.array);
---

$(P
Although $(C destroy()) is primarily for reference types, it can also be called on $(C struct) objects to destroy them before the end of their normal lifetimes.
)

$(H5 When to use)

$(P
As has been seen in the previous example, $(C destroy()) is used when resources need to be released at a specific time without relying on the garbage collector.
)

$(H5 Example)

$(P
We had designed an $(C XmlElement) struct in the $(LINK2 special_functions.html, Constructor and Other Special Functions chapter). That struct was being used for printing XML elements in the format $(C &lt;tag&gt;value&lt;/tag&gt;). Printing the closing tag has been the responsibility of the destructor:
)

---
struct XmlElement {
    // ...

    ~this() {
        writeln(indentation, "</", name, '>');
    }
}
---

$(P
The following output was produced by a program that used that struct. This time, I am replacing the word "class" with "course" to avoid confusing it with the $(C class) keyword:
)

$(SHELL
&lt;courses&gt;
  &lt;course0&gt;
    &lt;grade&gt;
      72
    &lt;/grade&gt;   $(SHELL_NOTE The closing tags appear on correct lines)
    &lt;grade&gt;
      97
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;grade&gt;
      90
    &lt;/grade&gt;   $(SHELL_NOTE)
  &lt;/course0&gt;   $(SHELL_NOTE)
  &lt;course1&gt;
    &lt;grade&gt;
      77
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;grade&gt;
      87
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;grade&gt;
      56
    &lt;/grade&gt;   $(SHELL_NOTE)
  &lt;/course1&gt;   $(SHELL_NOTE)
&lt;/courses&gt;     $(SHELL_NOTE)
)

$(P
The previous output happens to be correct because $(C XmlElement) is a $(C struct). The desired output is achieved simply by placing the objects in appropriate scopes:
)

---
void $(CODE_DONT_TEST)main() {
    const $(HILITE courses) = XmlElement("courses", 0);

    foreach (courseId; 0 .. 2) {
        const courseTag = "course" ~ to!string(courseId);
        const $(HILITE courseElement) = XmlElement(courseTag, 1);

        foreach (i; 0 .. 3) {
            const $(HILITE gradeElement) = XmlElement("grade", 2);
            const randomGrade = uniform(50, 101);

            writeln(indentationString(3), randomGrade);

        } // ← gradeElement is destroyed

    } // ← courseElement is destroyed

} // ← courses is destroyed
---

$(P
The destructor prints the closing tags as the objects gets destroyed.
)

$(P
To see how classes behave differently, let's convert $(C XmlElement) to a class:
)

---
import std.stdio;
import std.array;
import std.random;
import std.conv;

string indentationString(int level) {
    return replicate(" ", level * 2);
}

$(HILITE class) XmlElement {
    string name;
    string indentation;

    this(string name, int level) {
        this.name = name;
        this.indentation = indentationString(level);

        writeln(indentation, '<', name, '>');
    }

    ~this() {
        writeln(indentation, "</", name, '>');
    }
}

void main() {
    const courses = $(HILITE new) XmlElement("courses", 0);

    foreach (courseId; 0 .. 2) {
        const courseTag = "course" ~ to!string(courseId);
        const courseElement = $(HILITE new) XmlElement(courseTag, 1);

        foreach (i; 0 .. 3) {
            const gradeElement = $(HILITE new) XmlElement("grade", 2);
            const randomGrade = uniform(50, 101);

            writeln(indentationString(3), randomGrade);
        }
    }
}
---

$(P
As the responsibility of calling the destructors are now left to the garbage collector, the program does not produce the desired output:
)

$(SHELL_SMALL
&lt;courses&gt;
  &lt;course0&gt;
    &lt;grade&gt;
      57
    &lt;grade&gt;
      98
    &lt;grade&gt;
      87
  &lt;course1&gt;
    &lt;grade&gt;
      84
    &lt;grade&gt;
      60
    &lt;grade&gt;
      99
    &lt;/grade&gt;   $(SHELL_NOTE The closing tags appear at the end)
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;/grade&gt;   $(SHELL_NOTE)
  &lt;/course1&gt;   $(SHELL_NOTE)
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;/grade&gt;   $(SHELL_NOTE)
  &lt;/course0&gt;   $(SHELL_NOTE)
&lt;/courses&gt;     $(SHELL_NOTE)
)

$(P
The destructor is still executed for every object but this time at the end when the program is exiting. ($(I Note: The garbage collector does not guarantee that the destructor will be called for every object. In reality, it is possible that there are no closing tags printed at all.))
)

$(P
$(C destroy()) ensures that the destructor is called at desired points in the program:
)

---
void $(CODE_DONT_TEST)main() {
    const courses = new XmlElement("courses", 0);

    foreach (courseId; 0 .. 2) {
        const courseTag = "course" ~ to!string(courseId);
        const courseElement = new XmlElement(courseTag, 1);

        foreach (i; 0 .. 3) {
            const gradeElement = new XmlElement("grade", 2);
            const randomGrade = uniform(50, 101);

            writeln(indentationString(3), randomGrade);

            $(HILITE destroy(gradeElement));
        }

        $(HILITE destroy(courseElement));
    }

    $(HILITE destroy(courses));
}
---

$(P
With those changes, the output of the code now matches the output of the code that use structs:
)

$(SHELL
&lt;courses&gt;
  &lt;course0&gt;
    &lt;grade&gt;
      66
    &lt;/grade&gt;   $(SHELL_NOTE The closing tags appear on correct lines)
    &lt;grade&gt;
      75
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;grade&gt;
      68
    &lt;/grade&gt;   $(SHELL_NOTE)
  &lt;/course0&gt;   $(SHELL_NOTE)
  &lt;course1&gt;
    &lt;grade&gt;
      73
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;grade&gt;
      62
    &lt;/grade&gt;   $(SHELL_NOTE)
    &lt;grade&gt;
      100
    &lt;/grade&gt;   $(SHELL_NOTE)
  &lt;/course1&gt;   $(SHELL_NOTE)
&lt;/courses&gt;     $(SHELL_NOTE)
)

$(H5 $(IX scoped) $(C scoped()) to call the destructor automatically)

$(P
The program above has a weakness: The scopes may be exited before the $(C destroy()) lines are executed, commonly by thrown exceptions. If the $(C destroy()) lines must be executed even when exceptions are thrown, a solution is to take advantage of $(C scope()) and other features that we saw in the $(LINK2 exceptions.html, Exceptions chapter).
)

$(P
Another solution is to construct class objects by $(C std.typecons.scoped) instead of by the $(C new) keyword. $(C scoped()) wraps the class object inside a $(C struct) and the destructor of that $(C struct) object destroys the class object when itself goes out of scope.
)

$(P
The effect of $(C scoped()) is to make class objects behave similar to struct objects regarding lifetimes.
)

$(P
With the following changes, the program produces the expected output as before:
)

---
$(HILITE import std.typecons;)
// ...
void $(CODE_DONT_TEST)main() {
    const courses = $(HILITE scoped!)XmlElement("courses", 0);

    foreach (courseId; 0 .. 2) {
        const courseTag = "course" ~ to!string(courseId);
        const courseElement = $(HILITE scoped!)XmlElement(courseTag, 1);

        foreach (i; 0 .. 3) {
            const gradeElement = $(HILITE scoped!)XmlElement("grade", 2);
            const randomGrade = uniform(50, 101);

            writeln(indentationString(3), randomGrade);
        }
    }
}
---

$(P
Note that there are no $(C destroy()) lines anymore.
)

$(P
$(IX proxy) $(IX RAII) $(C scoped()) is a function that returns a special $(C struct) object encapsulating the actual $(C class) object. The returned object acts as a proxy to the encapsulated one. (In fact, the type of $(C courses) above is $(C Scoped), not $(C XmlElement).)
)

$(P
When the destructor of the $(C struct) object is called automatically as its lifetime ends, it calls $(C destroy()) on the $(C class) object that it encapsulates. (This is an application of the $(I Resource Acquisition Is Initialization) (RAII) idiom. $(C scoped()) achieves this by the help of $(LINK2 templates.html, templates) and $(LINK2 alias_this.html, $(C alias this)), both of which we will see in later chapters.)
)

$(P
It is desirable for a proxy object to be used as conveniently as possible. In fact, the object that $(C scoped()) returns can be used exactly like the actual $(C class) type. For example, the member functions of the actual type can be called on it:
)

---
import std.typecons;

class C {
    void foo() {
    }
}

void main() {
    auto p = scoped!C();
    p$(HILITE .foo());    // Proxy object p is being used as type C
}
---

$(P
However, that convenience comes with a price: The proxy object may hand out a reference to the actual object right before destroying it. This can happen when the actual $(C class) type is specified explicitly on the left hand-side:
)

---
    $(HILITE C) c = scoped!C();    $(CODE_NOTE_WRONG BUG)
    c.foo();             $(CODE_NOTE_WRONG Accesses a destroyed object)
---

$(P
In that definition, $(C c) is not the proxy object; rather, as defined by the programmer, a $(C class) variable referencing the encapsulated object. Unfortunately, the proxy object that is constructed on the right-hand side gets terminated at the end of the expression that constructs it. As a result, using $(C c) in the program would be an error, likely causing a runtime error:
)

$(SHELL
Segmentation fault
)

$(P
For that reason, do not define $(C scoped()) variables by the actual type:
)

---
    $(HILITE C)         a = scoped!C();    $(CODE_NOTE_WRONG BUG)
    auto      b = scoped!C();    $(CODE_NOTE correct)
    const     c = scoped!C();    $(CODE_NOTE correct)
    immutable d = scoped!C();    $(CODE_NOTE correct)
---

$(H5 Summary)

$(UL

$(LI
$(C destroy()) is for executing the destructor of a class object explicitly.
)

$(LI
Objects that are constructed by $(C scoped()) are destroyed upon leaving their respective scopes.
)

$(LI It is a bug to define $(C scoped()) variables by the actual type.)

)

Macros:
        TITLE=destroy and scoped

        DESCRIPTION=destroy() to call destructors explicitly on class objects and std.typecons.scoped to have the destructors executed on class objects automatically.

        KEYWORDS=d programming language tutorial book destroy scoped
