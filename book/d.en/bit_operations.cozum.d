Ddoc

$(COZUM_BOLUMU Bit Operations)

$(OL

$(LI
It may be acceptable to use magic constants in such a short function. Otherwise, the code may get too complicated.

---
string dotted(uint address) {
    return format("%s.%s.%s.%s",
                  (address >> 24) & 0xff,
                  (address >> 16) & 0xff,
                  (address >>  8) & 0xff,
                  (address >>  0) & 0xff);
}
---

$(P
Because the type is an unsigned type, the bits that are inserted into the value from the left-hand side will all have 0 values. For that reason, there is no need to mask the value that is shifted by 24 bits. Additionally, since shifting by 0 bits has no effect, that operation can be eliminated as well:
)

---
string dotted(uint address) {
    return format("%s.%s.%s.%s",
                   address >> 24,
                  (address >> 16) & 0xff,
                  (address >>  8) & 0xff,
                   address        & 0xff);
}
---

)

$(LI
Each octet can be shifted to its proper position in the IPv4 address and then these expressions can be "$(I orred)":

---
uint ipAddress(ubyte octet3,    // most significant octet
               ubyte octet2,
               ubyte octet1,
               ubyte octet0) {  // least significant octet
    return
        (octet3 << 24) |
        (octet2 << 16) |
        (octet1 <<  8) |
        (octet0 <<  0);
}
---

)

$(LI
The following method starts with a value where all of the bits are 1. First, the value is shifted to the right so that the upper bits become 0, and then it is shifted to the left so that the lower bits become 0:

---
uint mask(int lowestBit, int width) {
    uint result = uint.max;
    result >>= (uint.sizeof * 8) - width;
    result <<= lowestBit;
    return result;
}
---

$(P
$(C uint.max) is the value where all of the bits are 1. Alternatively, the calculation can start with the value that is the complement of 0, which is the same as $(C uint.max):
)

---
    uint result = ~0;
    // ...
---

)

)

Macros:
        TITLE=Bit Operations Solutions

        DESCRIPTION=Bit Operations chapter exercise solutions

        KEYWORDS=programming in d tutorial bit operations exercise solution
