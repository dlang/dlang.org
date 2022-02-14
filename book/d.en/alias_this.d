Ddoc

$(DERS_BOLUMU $(IX alias this) $(CH4 alias this))

$(P
We have seen the individual meanings of the $(C alias) and the $(C this) keywords in previous chapters. These two keywords have a completely different meaning when used together as $(C alias&nbsp;this).
)

$(P
$(IX automatic type conversion) $(IX type conversion, automatic) $(IX implicit type conversion) $(IX type conversion, implicit) $(C alias this) enables $(I automatic type conversions) (also known as $(I implicit type conversions)) of user-defined types. As we have seen in $(LINK2 operator_overloading.html, the Operator Overloading chapter), another way of providing type conversions for a type is by defining $(C opCast) for that type. The difference is that, while $(C opCast) is for explicit type conversions, $(C alias this) is for automatic type conversions.
)

$(P
The keywords $(C alias) and $(C this) are written separately where the name of a member variable or a member function is specified between them:
)

---
    alias $(I member_variable_or_member_function) this;
---

$(P
$(C alias this) enables the specific conversion from the user-defined type to the type of that member. The value of the member becomes the resulting value of the conversion .
)

$(P
The following $(C Fraction) example uses $(C alias this) with a $(I member function). The $(C TeachingAssistant) example that is further below will use it with $(I member variables).
)

$(P
Since the return type of $(C value()) below is $(C double), the following $(C alias this) enables automatic conversion of $(C Fraction) objects to $(C double) values:
)

---
import std.stdio;

struct Fraction {
    long numerator;
    long denominator;

    $(HILITE double value()) const {
        return double(numerator) / denominator;
    }

    alias $(HILITE value) this;

    // ...
}

double calculate(double lhs, double rhs) {
    return 2 * lhs + rhs;
}

void main() {
    auto fraction = Fraction(1, 4);    // meaning 1/4
    writeln(calculate($(HILITE fraction), 0.75));
}
---

$(P
$(C value()) gets called automatically to produce a $(C double) value when $(C Fraction) objects appear in places where a $(C double) value is expected. That is why the variable $(C fraction) can be passed to $(C calculate()) as an argument. $(C value()) returns 0.25 as the value of 1/4 and the program prints the result of 2 * 0.25 + 0.75:
)

$(SHELL
1.25
)

Macros:
        TITLE=alias this

        DESCRIPTION=Nesnelerin otomatik olarak başka tür olarak kullanılmalarını sağlayan 'alias this'.

        KEYWORDS=d programlama dili ders dersler öğrenmek tutorial alias takma isim alias this

SOZLER=
$(kalitim)

