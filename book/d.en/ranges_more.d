Ddoc

$(DERS_BOLUMU $(IX range) More Ranges)

$(P
We used mostly $(C int) ranges in the previous chapter. In practice, containers, algorithms, and ranges are almost always implemented as templates. The $(C print()) example in that chapter was a template as well:
)

---
void print$(HILITE (T))(T range) {
    // ...
}
---

$(P
What lacks from the implementation of $(C print()) is that even though it requires $(C T) to be a kind of $(C InputRange), it does not formalize that requirement with a template constraint. (We have seen template constraints in $(LINK2 templates_more.html, the More Templates chapter).)
)

$(P
The $(C std.range) module contains templates that are useful both in template constraints and in $(C static if) statements.
)

$(H5 Range kind templates)

$(P
The group of templates with names starting with $(C is) determine whether a type satisfies the requirements of a certain kind of range. For example, $(C isInputRange!T) answers the question "is $(C T) an $(C InputRange)?" The following templates are for determining whether a type is of a specific general range kind:
)

$(UL
$(LI $(IX isInputRange) $(C isInputRange))
$(LI $(IX isForwardRange) $(C isForwardRange))
$(LI $(IX isBidirectionalRange) $(C isBidirectionalRange))
$(LI $(IX isRandomAccessRange) $(C isRandomAccessRange))
$(LI $(IX isOutputRange) $(C isOutputRange))
)

$(P
Accordingly, the template constraint of $(C print()) can use $(C isInputRange):
)

---
void print(T)(T range)
        if ($(HILITE isInputRange!T)) {
    // ...
}
---

$(P
Unlike the others, $(C isOutputRange) takes two template parameters: The first one is a range type and the second one is an element type. It returns $(C true) if that range type allows outputting that element type. For example, the following constraint is for requiring that the range must be an $(C OutputRange) that accepts $(C double) elements:
)

---
void foo(T)(T range)
        if (isOutputRange!($(HILITE T, double))) {
    // ...
}
---

$(P
When used in conjunction with $(C static if), these constraints can determine the capabilities of user-defined ranges as well. For example, when a dependent range of a user-defined range is a $(C ForwardRange), the user-defined range can take advantage of that fact and can provide the $(C save()) function as well.
)

$(P
Let's see this on a range that produces the negatives of the elements of an existing range (more accurately, the $(I numeric complements) of the elements). Let's start with just the $(C InputRange) functions:
)

---
struct Negative(T)
        if (isInputRange!T) {
    T range;

    bool empty() {
        return range.empty;
    }

    auto front() {
        return $(HILITE -range.front);
    }

    void popFront() {
        range.popFront();
    }
}
---

$(P
$(I $(B Note:) As we will see below, the return type of $(C front) can be specified as $(C ElementType!T) as well.)
)

$(P
The only functionality of this range is in the $(C front) function where it produces the negative of the front element of the original range.
)

$(P
As usual, the following is the convenience function that goes with that range:
)

---
Negative!T negative(T)(T range) {
    return Negative!T(range);
}
---

$(P
This range is ready to be used with e.g. $(C FibonacciSeries) that was defined in the previous chapter:
)

---
struct FibonacciSeries {
    int current = 0;
    int next = 1;

    enum empty = false;

    int front() const {
        return current;
    }

    void popFront() {
        const nextNext = current + next;
        current = next;
        next = nextNext;
    }

    FibonacciSeries save() const {
        return this;
    }
}

// ...

    writeln(FibonacciSeries().take(5).$(HILITE negative));
---

$(P
The output contains the negatives of the first five elements of the series:
)

$(SHELL
[0, -1, -1, -2, -3]
)

$(P
Naturally, being just an $(C InputRange), $(C Negative) cannot be used with algorithms like $(C cycle()) that require a $(C ForwardRange):
)

---
    writeln(FibonacciSeries()
            .take(5)
            .negative
            .cycle        $(DERLEME_HATASI)
            .take(10));
---

$(P
However, when the original range is already a $(C ForwardRange), there is no reason for $(C Negative) not to provide the $(C save()) function as well. This condition can be determined by a $(C static if) statement and $(C save()) can be provided if the original range is a $(C ForwardRange). In this case it is as trivial as returning a new $(C Negative) object that is constructed by a copy of the original range:
)

---
struct Negative(T)
        if (isInputRange!T) {
// ...

    $(HILITE static if) (isForwardRange!T) {
        Negative save() {
            return Negative(range.save);
        }
    }
}
---

$(P
The addition of the new $(C save()) function makes $(C Negative!FibonacciSeries) a $(C ForwardRange) as well and the $(C cycle()) call can now be compiled:
)

---
    writeln(FibonacciSeries()
            .take(5)
            .negative
            .cycle        // ← now compiles
            .take(10));
---

$(P
The output of the entire expression can be described as $(I take the first five elements of the Fibonacci series, take their negatives, cycle those indefinitely, and take the first ten of those elements):
)

$(SHELL
[0, -1, -1, -2, -3, 0, -1, -1, -2, -3]
)

$(P
With the same approach, $(C Negative) can be made a $(C BidirectionalRange) and a $(C RandomAccessRange) if the original range supports those functionalities:
)

---
struct Negative(T)
        if (isInputRange!T) {
// ...

    static if (isBidirectionalRange!T) {
        auto back() {
            return -range.back;
        }

        void popBack() {
            range.popBack();
        }
    }

    static if (isRandomAccessRange!T) {
        auto opIndex(size_t index) {
            return -range[index];
        }
    }
}
---

$(P
For example, when it is used with a slice, the negative elements can be accessed by the $(C []) operator:
)

---
    auto d = [ 1.5, 2.75 ];
    auto n = d.negative;
    writeln(n$(HILITE [1]));
---

$(P
The output:
)

$(SHELL
-2.75
)

$(H5 $(IX ElementType) $(IX ElementEncodingType) $(C ElementType) and $(C ElementEncodingType))

$(P
$(C ElementType) provides the types of the elements of the range.
)

$(P
For example, the following template constraint includes a requirement that is about the element type of the first range:
)

---
void foo(I1, I2, O)(I1 input1, I2 input2, O output)
        if (isInputRange!I1 &&
            isForwardRange!I2 &&
            isOutputRange!(O, $(HILITE ElementType!I1))) {
    // ...
}
---

$(P
The previous constraint can be described as $(I if $(C I1) is an $(C InputRange) and $(C I2) is a $(C ForwardRange) and $(C O) is an $(C OutputRange) that accepts the element type of $(C I1)).
)

$(P
$(IX dchar, string range) Since strings are always ranges of Unicode characters, regardless of their actual character types, they are always ranges of $(C dchar), which means that even $(C ElementType!string) and $(C ElementType!wstring) are $(C dchar). For that reason, when needed in a template, the actual UTF encoding type of a string range can be obtained by $(C ElementEncodingType).
)

$(H5 More range templates)

$(P
The $(C std.range) module has many more range templates that can be used with D's other compile-time features. The following is a sampling:
)

$(UL

$(LI $(IX isInfinite) $(C isInfinite): Whether the range is infinite)

$(LI $(IX hasLength) $(C hasLength): Whether the range has a $(C length) property)

$(LI $(IX hasSlicing) $(C hasSlicing): Whether the range supports slicing i.e. with $(C a[x..y]))

$(LI $(IX hasAssignableElements) $(C hasAssignableElements): Whether the return type of $(C front) is assignable)

$(LI $(IX hasSwappableElements) $(C hasSwappableElements): Whether the elements of the range are swappable e.g. with $(C std.algorithm.swap))

$(LI $(IX hasMobileElements) $(IX move, std.algorithm) $(C hasMobileElements): Whether the elements of the range are movable e.g. with $(C std.algorithm.move)

$(P
$(IX moveFront) $(IX moveBack) $(IX moveAt) This implies that the range has $(C moveFront()), $(C moveBack()), or $(C moveAt()), depending on the actual kind of the range. Since moving elements is usually faster than copying them, depending on the result of $(C hasMobileElements) a range can provide faster operations by calling $(C move()).
)

)

$(LI $(IX hasLvalueElements) $(IX lvalue) $(C hasLvalueElements): Whether the elements of the range are $(I lvalues) (roughly meaning that the elements are not copies of actual elements nor are temporary objects that are created on the fly)

$(P
For example, $(C hasLvalueElements!FibonacciSeries) is $(C false) because the elements of $(C FibonacciSeries) do not exist as themselves; rather, they are copies of the member $(C current) that is returned by $(C front). Similarly, $(C hasLvalueElements!(Negative!(int[]))) is $(C false) because although the $(C int) slice does have actual elements, the range that is represented by $(C Negative) does not provide access to those elements; rather, it returns copies that have the negative signs of the elements of the actual slice. Conversely, $(C hasLvalueElements!(int[])) is $(C true) because a slice provides access to actual elements of an array.
)

)

)

$(P
The following example takes advantage of $(C isInfinite) to provide $(C empty) as an $(C enum) when the original range is infinite, making it known at compile time that $(C Negative!T) is infinite as well:
)

---
struct Negative(T)
        if (isInputRange!T) {
// ...

    static if (isInfinite!T) {
        // Negative!T is infinite as well
        enum empty = false;

    } else {
        bool empty() {
            return range.empty;
        }
    }

// ...
}

static assert( isInfinite!(Negative!FibonacciSeries));
static assert(!isInfinite!(int[]));
---

$(H5 $(IX polymorphism, run-time) $(IX inputRangeObject) $(IX outputRangeObject) Run-time polymorphism with $(C inputRangeObject()) and $(C outputRangeObject()))

$(P
Being implemented mostly as templates, ranges exhibit $(I compile-time polymorphism), which we have been taking advantage of in the examples of this chapter and previous chapters. ($(I For differences between compile-time polymorphism and run-time polymorphism, see the "Compile-time polymorphism" section in $(LINK2 templates_more.html, the More Templates chapter).))
)

$(P
Compile-time polymorphism has to deal with the fact that every instantiation of a template is a different type. For example, the return type of the $(C take()) template is directly related to the original range:
)

---
    writeln(typeof([11, 22].negative.take(1)).stringof);
    writeln(typeof(FibonacciSeries().take(1)).stringof);
---

$(P
The output:
)

$(SHELL
Take!(Negative!(int[]))
Take!(FibonacciSeries)
)

$(P
A natural consequence of this fact is that different range types cannot be assigned to each other. The following is an example of this incompatibility between two $(C InputRange) ranges:
)

---
    auto range = [11, 22].negative;
    // ... at a later point ...
    range = FibonacciSeries();    $(DERLEME_HATASI)
---

$(P
As expected, the compilation error indicates that $(C FibonacciSeries) and $(C Negative!(int[])) are not compatible:
)

$(SHELL
Error: cannot implicitly convert expression (FibonacciSeries(0, 1))
of type $(HILITE FibonacciSeries) to $(HILITE Negative!(int[]))
)

$(P
However, although the actual types of the ranges are different, since they both are $(I ranges of $(C int)), this incompatibility can be seen as an unnecessary limitation. From the usage point of view, since both ranges simply provide $(C int) elements, the actual mechanism that produces those elements should not be important.
)

$(P
Phobos helps with this issue by $(C inputRangeObject()) and $(C outputRangeObject()). $(C inputRangeObject()) allows presenting ranges as $(I a specific kind of range of specific types of elements). With its help, a range can be used e.g. as $(I an $(C InputRange) of $(C int) elements), regardless of the actual type of the range.
)

$(P
$(C inputRangeObject()) is flexible enough to support all of the non-output ranges: $(C InputRange), $(C ForwardRange), $(C BidirectionalRange), and $(C RandomAccessRange). Because of that flexibility, the object that it returns cannot be defined by $(C auto). The exact kind of range that is required must be specified explicitly:
)

---
    // Meaning "InputRange of ints":
    $(HILITE InputRange!int) range = [11, 22].negative.$(HILITE inputRangeObject);

    // ... at a later point ...

    // The following assignment now compiles
    range = FibonacciSeries().$(HILITE inputRangeObject);
---

$(P
As another example, when the range needs to be used as $(I a $(C ForwardRange) of $(C int) elements), its type must be specified explicitly as $(C ForwardRange!int):
)

---
    $(HILITE ForwardRange!int) range = [11, 22].negative.inputRangeObject;

    auto copy = range.$(HILITE save);

    range = FibonacciSeries().inputRangeObject;
    writeln(range.$(HILITE save).take(10));
---

$(P
The example calls $(C save()) just to prove that the ranges can indeed be used as $(C ForwardRange) ranges.
)

$(P
Similarly, $(C outputRangeObject()) works with $(C OutputRange) ranges and allows their use as $(I an $(C OutputRange) that accepts specific types of elements).
)

$(H5 Summary)

$(UL

$(LI The $(C std.range) module contains many useful range templates.)

$(LI Some of those templates allow templates be more capable depending on the capabilities of original ranges.)

$(LI $(C inputRangeObject()) and $(C outputRangeObject()) provide run-time polymorphism, allowing using different types of ranges as $(I specific kinds of ranges of specific types of elements).)
)

macros:
        TITLE=More Ranges

        DESCRIPTION=Many useful range templates of the std.range module.

        KEYWORDS=d programming language tutorial book ranges
