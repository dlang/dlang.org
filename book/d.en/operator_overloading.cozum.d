Ddoc

$(COZUM_BOLUMU Operator Overloading)

$(P
The following implementation passes all of the unit tests. The design decisions have been included as code comments.
)

$(P
Some of the functions of this struct can be implemented to run more efficiently. Additionally, it would be beneficial to also $(I normalize) the numerator and denominator. For example, instead of keeping the values 20 and 60, the values could be divided by their $(I greatest common divisor) and the numerator and the denominator can be stored as 1 and 3 instead. Otherwise, most of the operations on the object would cause the values of the numerator and the denominator to increase.
)

---
import std.exception;
import std.conv;

struct Fraction {
    long num;  // numerator
    long den;  // denominator

    /* As a convenience, the constructor uses the default
     * value of 1 for the denominator. */
    this(long num, long den = 1) {
        enforce(den != 0, "The denominator cannot be zero");

        this.num = num;
        this.den = den;

        /* Ensuring that the denominator is always positive
         * will simplify the definitions of some of the
         * operator functions. */
        if (this.den < 0) {
            this.num = -this.num;
            this.den = -this.den;
        }
    }

    /* Unary -: Returns the negative of this fraction. */
    Fraction opUnary(string op)() const
            if (op == "-") {
        /* Simply constructs and returns an anonymous
         * object. */
        return Fraction(-num, den);
    }

    /* ++: Increments the value of the fraction by one. */
    ref Fraction opUnary(string op)()
            if (op == "++") {
        /* We could have used 'this += Fraction(1)' here. */
        num += den;
        return this;
    }

    /* --: Decrements the value of the fraction by one. */
    ref Fraction opUnary(string op)()
            if (op == "--") {
        /* We could have used 'this -= Fraction(1)' here. */
        num -= den;
        return this;
    }

    /* +=: Adds the right-hand fraction to this one. */
    ref Fraction opOpAssign(string op)(Fraction rhs)
            if (op == "+") {
        /* Addition formula: a/b + c/d = (a*d + c*b)/(b*d) */
        num = (num * rhs.den) + (rhs.num * den);
        den *= rhs.den;
        return this;
    }

    /* -=: Subtracts the right-hand fraction from this one. */
    ref Fraction opOpAssign(string op)(Fraction rhs)
            if (op == "-") {
        /* We make use of the already-defined operators += and
         * unary - here. Alternatively, the subtraction
         * formula could explicitly be applied similar to the
         * += operator above.
         *
         * Subtraction formula: a/b - c/d = (a*d - c*b)/(b*d)
         */
        this += -rhs;
        return this;
    }

    /* *=: Multiplies the fraction by the right-hand side. */
    ref Fraction opOpAssign(string op)(Fraction rhs)
            if (op == "*") {
        /* Multiplication formula: a/b * c/d = (a*c)/(b*d) */
        num *= rhs.num;
        den *= rhs.den;
        return this;
    }

    /* /=: Divides the fraction by the right-hand side. */
    ref Fraction opOpAssign(string op)(Fraction rhs)
            if (op == "/") {
        enforce(rhs.num != 0, "Cannot divide by zero");

        /* Division formula: (a/b) / (c/d) = (a*d)/(b*c) */
        num *= rhs.den;
        den *= rhs.num;
        return this;
    }

    /* Binary +: Produces the result of adding this and the
     * right-hand side fractions. */
    Fraction opBinary(string op)(Fraction rhs) const
            if (op == "+") {
        /* Takes a copy of this fraction and adds the
         * right-hand side fraction to that copy. */
        Fraction result = this;
        result += rhs;
        return result;
    }

    /* Binary -: Produces the result of subtracting the
     * right-hand side fraction from this one. */
    Fraction opBinary(string op)(Fraction rhs) const
            if (op == "-") {
        /* Uses the already-defined -= operator. */
        Fraction result = this;
        result -= rhs;
        return result;
    }

    /* Binary *: Produces the result of multiplying this
     * fraction with the right-hand side fraction. */
    Fraction opBinary(string op)(Fraction rhs) const
            if (op == "*") {
        /* Uses the already-defined *= operator. */
        Fraction result = this;
        result *= rhs;
        return result;
    }

    /* Binary /: Produces the result of dividing this fraction
     * by the right-hand side fraction. */
    Fraction opBinary(string op)(Fraction rhs) const
            if (op == "/") {
        /* Uses the already-defined /= operator. */
        Fraction result = this;
        result /= rhs;
        return result;
    }

    /* Returns the value of the fraction as double. */
    double opCast(T : double)() const {
        /* A simple division. However, as dividing values of
         * type long would lose the part of the value after
         * the decimal point, we could not have written
         * 'num/den' here. */
        return to!double(num) / den;
    }

    /* Sort order operator: Returns a negative value if this
     * fraction is before, a positive value if this fraction
     * is after, and zero if both fractions have the same sort
     * order. */
    int opCmp(const Fraction rhs) const {
        immutable result = this - rhs;
        /* Being a long, num cannot be converted to int
         * automatically; it must be converted explicitly by
         * 'to' (or cast). */
        return to!int(result.num);
    }

    /* Equality comparison: Returns true if the fractions are
     * equal.
     *
     * The equality comparison had to be defined for this type
     * because the compiler-generated one would be comparing
     * the members one-by-one, without regard to the actual
     * values that the objects represent.
     *
     * For example, although the values of both Fraction(1,2)
     * and Fraction(2,4) are 0.5, the compiler-generated
     * opEquals would decide that they were not equal on
     * account of having members of different values. */
    bool opEquals(const Fraction rhs) const {
        /* Checking whether the return value of opCmp is zero
         * is sufficient here. */
        return opCmp(rhs) == 0;
    }
}

unittest {
    /* Must throw when denominator is zero. */
    assertThrown(Fraction(42, 0));

    /* Let's start with 1/3. */
    auto a = Fraction(1, 3);

    /* -1/3 */
    assert(-a == Fraction(-1, 3));

    /* 1/3 + 1 == 4/3 */
    ++a;
    assert(a == Fraction(4, 3));

    /* 4/3 - 1 == 1/3 */
    --a;
    assert(a == Fraction(1, 3));

    /* 1/3 + 2/3 == 3/3 */
    a += Fraction(2, 3);
    assert(a == Fraction(1));

    /* 3/3 - 2/3 == 1/3 */
    a -= Fraction(2, 3);
    assert(a == Fraction(1, 3));

    /* 1/3 * 8 == 8/3 */
    a *= Fraction(8);
    assert(a == Fraction(8, 3));

    /* 8/3 / 16/9 == 3/2 */
    a /= Fraction(16, 9);
    assert(a == Fraction(3, 2));

    /* Must produce the equivalent value in type 'double'.
     *
     * Note that although double cannot represent every value
     * precisely, 1.5 is an exception. That is why this test
     * is being applied at this point. */
    assert(to!double(a) == 1.5);

    /* 1.5 + 2.5 == 4 */
    assert(a + Fraction(5, 2) == Fraction(4, 1));

    /* 1.5 - 0.75 == 0.75 */
    assert(a - Fraction(3, 4) == Fraction(3, 4));

    /* 1.5 * 10 == 15 */
    assert(a * Fraction(10) == Fraction(15, 1));

    /* 1.5 / 4 == 3/8 */
    assert(a / Fraction(4) == Fraction(3, 8));

    /* Must throw when dividing by zero. */
    assertThrown(Fraction(42, 1) / Fraction(0));

    /* The one with lower numerator is before. */
    assert(Fraction(3, 5) < Fraction(4, 5));

    /* The one with larger denominator is before. */
    assert(Fraction(3, 9) < Fraction(3, 8));
    assert(Fraction(1, 1_000) > Fraction(1, 10_000));

    /* The one with lower value is before. */
    assert(Fraction(10, 100) < Fraction(1, 2));

    /* The one with negative value is before. */
    assert(Fraction(-1, 2) < Fraction(0));
    assert(Fraction(1, -2) < Fraction(0));

    /* The ones with equal values must be both <= and >=.  */
    assert(Fraction(-1, -2) <= Fraction(1, 2));
    assert(Fraction(1, 2) <= Fraction(-1, -2));
    assert(Fraction(3, 7) <= Fraction(9, 21));
    assert(Fraction(3, 7) >= Fraction(9, 21));

    /* The ones with equal values must be equal. */
    assert(Fraction(1, 3) == Fraction(20, 60));

    /* The ones with equal values with sign must be equal. */
    assert(Fraction(-1, 2) == Fraction(1, -2));
    assert(Fraction(1, 2) == Fraction(-1, -2));
}

void main() {
}
---

$(P
As has been mentioned in the chapter, string mixins can be used to combine the definitions of some of the operators. For example, the following definition covers the four arithmetic operators:
)

---
    /* Binary arithmetic operators. */
    Fraction opBinary(string op)(Fraction rhs) const
        if ((op == "+") || (op == "-") ||
            (op == "*") || (op == "/")) {
       /* Takes a copy of this fraction and applies the
        * right-hand side fraction to that copy. */
        Fraction result = this;
        mixin ("result " ~ op ~ "= rhs;");
        return result;
    }
---


Macros:
        TITLE=Operator Overloading Solution

        DESCRIPTION=Programming in D exercise solutions: operators overloading

        KEYWORDS=programming in d tutorial operator overloading solution
