Ddoc

$(DERS_BOLUMU $(IX union) Unions)

$(P
Unions, a low-level feature inherited from the C programming language, allow more than one member to share the same memory area.
)

$(P
Unions are very similar to structs with the following main differences:
)

$(UL

$(LI Unions are defined by the $(C union) keyword.)

$(LI The members of a $(C union) are not independent; they share the same memory area.)

)

$(P
Just like structs, unions can have member functions as well.
)

$(P
$(IX -m32, compiler switch) The examples below will produce different results depending on whether they are compiled on a 32-bit or a 64-bit environment. To avoid getting confusing results, please use the $(C -m32) compiler switch when compiling the examples in this chapter. Otherwise, your results may be different than mine due to $(I alignment), which we will see in a later chapter.
)

$(P
Naturally, $(C struct) objects are as large as necessary to accommodate all of their members:
)

---
// Note: Please compile with the -m32 compiler switch
struct S {
    int i;
    double d;
}

// ...

    writeln(S.sizeof);
---

$(P
Since $(C int) is 4 bytes long and $(C double) is 8 bytes long, the size of that $(C struct) is the sum of their sizes:
)

$(SHELL_SMALL
12
)

$(P
In contrast, the size of a $(C union) with the same members is only as large as its largest member:
)

---
$(HILITE union) U {
    int i;
    double d;
}

// ...

    writeln(U.sizeof);
---

$(P
The 4-byte $(C int) and the 8-byte $(C double) share the same area. As a result, the size of the entire $(C union) is the same as its largest member:
)

$(SHELL_SMALL
8
)

$(P
Unions are not a memory-saving feature. It is impossible to fit multiple data into the same memory location. The purpose of a union is to use the same area for different type of data at different times. Only one of the members can be used reliably at one time. However, although doing so may not be portable to different platforms, $(C union) members can be used for accessing fragments of other members.
)

$(P
One of the examples below takes advantage of $(C typeid) to disallow access to members other than the one that is currently valid.
)

$(P
The following diagram shows how the 8 bytes of the $(C union) above are shared by its members:
)

$(MONO
       0      1      2      3      4      5      6      7
───┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬───
   │$(HILITE <───  4 bytes for int  ───>)                            │
   │$(HILITE <───────────────  8 bytes for double  ────────────────>)│
───┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴──────┴───
)

$(P
Either all of the 8 bytes are used for the $(C double) member, or only the first 4 bytes are used for the $(C int) member and the other 4 bytes are unused.
)

$(P
Unions can have as many members as needed. All of the members would share the same memory location.
)

$(P
The fact that the same memory location is used for all of the members can have surprising effects. For example, let's initialize a $(C union) object by its $(C int) member and then access its $(C double) member:
)

---
    auto u = U(42);    // initializing the int member
    writeln(u.d);      // accessing the double member
---

$(P
Initializing the $(C int) member by the value 42 sets just the first 4 bytes, and this affects the $(C double) member in an unpredictable way:
)

$(SHELL_SMALL
2.07508e-322
)

$(P
Depending on the endianness of the microprocessor, the 4 bytes may be arranged in memory as 0|0|0|42, 42|0|0|0, or in some other order. For that reason, the value of the $(C double) member may appear differently on different platforms.
)

$(H5 $(IX anonymous union) Anonymous unions)

$(P
Anonymous unions specify what members of a user-defined type share the same area:
)

---
struct S {
    int first;

    union {
        int second;
        int third;
    }
}

// ...

    writeln(S.sizeof);
---

$(P
The last two members of $(C S) share the same area. So, the size of the $(C struct) is a total of two $(C int)s: 4 bytes needed for $(C first) and another 4 bytes to be shared by $(C second) and $(C third):
)

$(SHELL_SMALL
8
)

$(H5 Dissecting other members)

$(P
Unions can be used for accessing individual bytes of variables of other types. For example, they make it easy to access the 4 bytes of an IPv4 address individually.
)

$(P
The 32-bit value of the IPv4 address and a fixed-length array can be defined as the two members of a $(C union):
)

---
$(CODE_NAME IpAddress)union IpAddress {
    uint value;
    ubyte[4] bytes;
}
---

$(P
The members of that $(C union) would share the same memory area as in the following figure:
)

$(MONO
        0          1          2          3
───┬──────────┬──────────┬──────────┬──────────┬───
   │$(HILITE  <────  32 bits of the IPv4 address  ────> )│
   │ bytes[0] │ bytes[1] │ bytes[2] │ bytes[3] │
───┴──────────┴──────────┴──────────┴──────────┴───
)

$(P
For example, when an object of this $(C union) is initialized by 0xc0a80102 (the value that corresponds to the dotted form 192.168.1.2), the elements of the $(C bytes) array would automatically have the values of the four octets:
)

---
$(CODE_XREF IpAddress)import std.stdio;

void main() {
    auto address = IpAddress(0xc0a80102);
    writeln(address$(HILITE .bytes));
}
---

$(P
When run on a little-endian system, the octets would appear in reverse of their dotted form:
)

$(SHELL_SMALL
[2, 1, 168, 192]
)

$(P
The reverse order of the octets is another example of how accessing different members of a $(C union) may produce unpredictable results. This is because the behavior of a $(C union) is guaranteed only if that $(C union) is used through just one of its members. There are no guarantees on the values of the members other than the one that the $(C union) has been initialized with.
)

$(P
$(IX bswap, std.bitop) $(IX endian, std.system) Although it is not directly related to this chapter, $(C bswap) from the $(C core.bitop) module is useful in dealing with endianness issues. $(C bswap) returns its parameter after swapping its bytes. Also taking advantage of the $(C endian) value from the $(C std.system) module, the octets of the previous IPv4 address can be printed in the expected order after swapping its bytes:
)

---
import std.system;
import core.bitop;

// ...

    if (endian == Endian.littleEndian) {
        address.value = bswap(address.value);
    }
---

$(P
The output:
)

$(SHELL_SMALL
[192, 168, 1, 2]
)

$(P
Please take the $(C IpAddress) type as a simple example; in general, it would be better to consider a dedicated networking module for non-trivial programs.
)

$(H5 Examples)

$(H6 Communication protocol)

$(P
In some protocols like TCP/IP, the meanings of certain parts of a protocol packet depend on a specific value inside the same packet. Usually, it is a field in the header of the packet that determines the meanings of successive bytes. Unions can be used for representing such protocol packets.
)

$(P
The following design represents a protocol packet that has two kinds:
)

---
struct Host {
    // ...
}

struct ProtocolA {
    // ...
}

struct ProtocolB {
    // ...
}

enum ProtocolType { A, B }

struct NetworkPacket {
    Host source;
    Host destination;
    ProtocolType $(HILITE type);

    $(HILITE union) {
        ProtocolA aParts;
        ProtocolB bParts;
    }

    ubyte[] payload;
}
---

$(P
The $(C struct) above can make use of the $(C type) member to determine whether $(C aParts) or $(C bParts) of the $(C union) to be used.
)

$(H6 $(IX discriminated union) Discriminated union)

$(P
Discriminated union is a data structure that brings type safety over a regular $(C union). Unlike a $(C union), it does not allow accessing the members other than the one that is currently valid.
)

$(P
The following is a simple discriminated union type that supports only two types: $(C int) and $(C double). In addition to a $(C union) to store the data, it maintains a $(LINK2 object.html, $(C TypeInfo)) member to know which one of the two $(C union) members is valid.
)

---
$(CODE_NAME Discriminated)import std.stdio;
import std.exception;

struct Discriminated {
private:

    TypeInfo validType_;

    union {
        int i_;
        double d_;
    }

public:

    this(int value) {
        // This is a call to the property function below:
        i = value;
    }

    // Setter for 'int' data
    void i(int value) {
        i_ = value;
        validType_ $(HILITE = typeid(int));
    }

    // Getter for 'int' data
    int i() const {
        enforce(validType_ $(HILITE == typeid(int)),
                "The data is not an 'int'.");
        return i_;
    }

    this(double value) {
        // This is a call to the property function below:
        d = value;
    }

    // Setter for 'double' data
    void d(double value) {
        d_ = value;
        validType_ $(HILITE = typeid(double));
    }

    // Getter for 'double' data
    double d() const {
        enforce(validType_ $(HILITE == typeid(double)),
                "The data is not a 'double'." );
        return d_;
    }

    // Identifies the type of the valid data
    const(TypeInfo) type() const {
        return validType_;
    }
}

unittest {
    // Let's start with 'int' data
    auto var = Discriminated(42);

    // The type should be reported as 'int'
    assert(var.type == typeid(int));

    // 'int' getter should work
    assert(var.i == 42);

    // 'double' getter should fail
    assertThrown(var.d);

    // Let's replace 'int' with 'double' data
    var.d = 1.5;

    // The type should be reported as 'double'
    assert(var.type == typeid(double));

    // Now 'double' getter should work ...
    assert(var.d == 1.5);

    // ... and 'int' getter should fail
    assertThrown(var.i);
}
---

$(P
$(IX Variant, std.variant) $(IX Algebraic, std.variant) This is just an example. You should consider using $(C Algebraic) and $(C Variant) from the $(C std.variant) module in your programs. Additionally, this code could take advantage of other features of D like $(LINK2 templates.html, templates) and $(LINK2 mixin.html, mixins) to reduce code duplication.
)

$(P
Regardless of the data that is being stored, there is only one $(C Discriminated) type. (An alternative template solution could take the data type as a template parameter, in which case each instantiation of the template would be a distinct type.) For that reason, it is possible to have an array of $(C Discriminated) objects, effectively enabling a collection where elements can be of different types. However, the user must still know the valid member before accessing it. For example, the following function determines the actual type of the valid data with the $(C type) property of $(C Discriminated):
)

---
$(CODE_XREF Discriminated)void main() {
    Discriminated[] arr = [ Discriminated(1),
                            Discriminated(2.5) ];

    foreach (value; arr) {
        if (value.type $(HILITE == typeid(int))) {
            writeln("Working with an 'int'  : ", value$(HILITE .i));

        } else if (value.type $(HILITE == typeid(double)))  {
            writeln("Working with a 'double': ", value$(HILITE .d));

        } else {
            assert(0);
        }
    }
}
---

$(SHELL
Working with an 'int'  : 1
Working with a 'double': 2.5
)

Macros:
        TITLE=Unions

        DESCRIPTION=Unions, the feature that allows sharing the same memory area for more than one member.

        KEYWORDS=d programming language tutorial book union
