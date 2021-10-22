Ddoc

$(COZUM_BOLUMU Unit Testing)

$(P
The first thing to do is to compile and run the program to ensure that the tests actually work and indeed fail:
)

$(SHELL
$ dmd deneme.d -w -unittest
$ ./deneme
$(SHELL_OBSERVED core.exception.AssertError@deneme(11): unittest failure)
)

$(P
The line number 11 indicates that the first one of the tests has failed.
)

$(P
For demonstration purposes let's write an obviously incorrect implementation that passes the first test by accident. The following function simply returns a copy of the input:
)

---
dstring toFront(dstring str, dchar letter) {
    dstring result;

    foreach (c; str) {
        result ~= c;
    }

    return result;
}

unittest {
    immutable str = "hello"d;

    assert(toFront(str, 'h') == "hello");
    assert(toFront(str, 'o') == "ohell");
    assert(toFront(str, 'l') == "llheo");
}

void main() {
}
---

$(P
The first test passes but the second one fails:
)

$(SHELL
$ ./deneme
$(SHELL_OBSERVED core.exception.AssertError@deneme.d($(HILITE 17)): unittest failure)
)

$(P
Here is a correct implementation that passes all of the tests:
)

---
dstring toFront(dstring str, dchar letter) {
    dchar[] firstPart;
    dchar[] lastPart;

    foreach (c; str) {
        if (c == letter) {
            firstPart ~= c;

        } else {
            lastPart ~= c;
        }
    }

    return (firstPart ~ lastPart).idup;
}

unittest {
    immutable str = "hello"d;

    assert(toFront(str, 'h') == "hello");
    assert(toFront(str, 'o') == "ohell");
    assert(toFront(str, 'l') == "llheo");
}

void main() {
}
---

$(P
The tests finally pass:
)

$(SHELL
$ ./deneme
$
)

$(P
This function can now be modified in different ways under the confidence that its tests will have to pass. The following two implementations are very different from the first one but they too are correct according to the tests.
)

$(UL

$(LI
An implementation that takes advantage of $(C std.algorithm.partition):

---
import std.algorithm;

dstring toFront(dstring str, dchar letter) {
    dchar[] result = str.dup;
    partition!(c => c == letter, SwapStrategy.stable)(result);

    return result.idup;
}

unittest {
    immutable str = "hello"d;

    assert(toFront(str, 'h') == "hello");
    assert(toFront(str, 'o') == "ohell");
    assert(toFront(str, 'l') == "llheo");
}

void main() {
}
---

$(P
$(I $(B Note:) The $(C =>) syntax that appears in the program above creates a $(I lambda function). We will see lambda functions in later chapters.)
)

)

$(LI
The following implementation first counts how many times the special letter appears in the string. That information is then sent to a separate function named $(C repeated()) to produce the first part of the result. Note that $(C repeated()) has a set of unit tests of its own:

---
dstring repeated(size_t count, dchar letter) {
    dstring result;

    foreach (i; 0..count) {
        result ~= letter;
    }

    return result;
}

unittest {
    assert(repeated(3, 'z') == "zzz");
    assert(repeated(10, 'é') == "éééééééééé");
}

dstring toFront(dstring str, dchar letter) {
    size_t specialLetterCount;
    dstring lastPart;

    foreach (c; str) {
        if (c == letter) {
            ++specialLetterCount;

        } else {
            lastPart ~= c;
        }
    }

    return repeated(specialLetterCount, letter) ~ lastPart;
}

unittest {
    immutable str = "hello"d;

    assert(toFront(str, 'h') == "hello");
    assert(toFront(str, 'o') == "ohell");
    assert(toFront(str, 'l') == "llheo");
}

void main() {
}
---

)

)

Macros:
        TITLE=Unit Testing

        DESCRIPTION=The exercise solutions for the Unit Testing chapter.

        KEYWORDS=programming in d tutorial unit testing
