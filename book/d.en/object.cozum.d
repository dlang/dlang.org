Ddoc

$(COZUM_BOLUMU $(CH4 Object))

$(OL

$(LI
For the equality comparison, $(C rhs) being non-$(C null) and the members being equal would be sufficient:

---
enum Color { blue, green, red }

class Point {
    int x;
    int y;
    Color color;

// ...

    override bool opEquals(Object o) const {
        const rhs = cast(const Point)o;

        return rhs && (x == rhs.x) && (y == rhs.y);
    }
}
---

)

$(LI
When the type of the right-hand side object is also $(C Point), they are compared according to the values of the $(C x) members first and then according to the values of the $(C y) members:

---
class Point {
    int x;
    int y;
    Color color;

// ...

    override int opCmp(Object o) const {
        const rhs = cast(const Point)o;
        enforce(rhs);

        return (x != rhs.x
                ? x - rhs.x
                : y - rhs.y);
    }
}
---

)

$(LI
Note that it is not possible to cast to type $(C const TriangularArea) inside $(C opCmp) below. When $(C rhs) is $(C const TriangularArea), then its member $(C rhs.points) would be $(C const) as well. Since the parameter of $(C opCmp) is non-$(C const), it would not be possible to pass $(C rhs.points[i]) to $(C point.opCmp).

---
class TriangularArea {
    Point[3] points;

    this(Point one, Point two, Point three) {
        points = [ one, two, three ];
    }

    override bool opEquals(Object o) const {
        const rhs = cast(const TriangularArea)o;
        return rhs && (points == rhs.points);
    }

    override int opCmp(Object o) const {
        $(HILITE auto) rhs = $(HILITE cast(TriangularArea))o;
        enforce(rhs);

        foreach (i, point; points) {
            immutable comparison = point.opCmp(rhs.points[i]);

            if (comparison != 0) {
                /* The sort order has already been
                 * determined. Simply return the result. */
                return comparison;
            }
        }

        /* The objects are considered equal because all of
         * their points have been equal. */
        return 0;
    }

    override size_t toHash() const {
        /* Since the 'points' member is an array, we can take
         * advantage of the existing toHash algorithm for
         * array types. */
        return typeid(points).getHash(&points);
    }
}
---

)

)


Macros:
        TITLE=Object Solutions

        DESCRIPTION=Programming in D exercise solutions: Object

        KEYWORDS=programming in d tutorial Object
