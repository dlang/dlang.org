Ddoc

$(COZUM_BOLUMU Strings)

$(OL

$(LI
Although some of the functions in Phobos modules will be easy to use with strings, library documentations are usually terse compared to tutorials. You may find especially the Phobos ranges confusing at this point. We will see Phobos ranges in a later chapter.
)

$(LI
Many other functions may be chained as well:

---
import std.stdio;
import std.string;

void main() {
    write("First name: ");
    string first = capitalize(strip(readln()));

    write("Last name: ");
    string last = capitalize(strip(readln()));

    string fullName = first ~ " " ~ last;
    writeln(fullName);
}
---

)

$(LI This program uses two indexes to make a slice:

---
import std.stdio;
import std.string;

void main() {
    write("Please enter a line: ");
    string line = strip(readln());

    ptrdiff_t first_e = indexOf(line, 'e');

    if (first_e == -1) {
        writeln("There is no letter e in this line.");

    } else {
        ptrdiff_t last_e = lastIndexOf(line, 'e');
        writeln(line[first_e .. last_e + 1]);
    }
}
---

)

)

Macros:
        TITLE=Strings Solution

        DESCRIPTION=Programming in D exercise solutions: strings

        KEYWORDS=programming in d tutorial strings solution
