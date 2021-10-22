Ddoc

$(COZUM_BOLUMU Pointers)

$(OL

$(LI
When parameters are value types like $(C int), the arguments are copied to functions. The preferred way of defining reference parameters is to specify them as $(C ref).

$(P
Another way is to define the parameters as pointers that point at the actual variables. The parts of the program that have been changed are highlighted:
)

---
void swap(int $(HILITE *) lhs, int $(HILITE *) rhs) {
    int temp = $(HILITE *)lhs;
    $(HILITE *)lhs = $(HILITE *)rhs;
    $(HILITE *)rhs = temp;
}

void main() {
    int i = 1;
    int j = 2;

    swap($(HILITE &)i, $(HILITE &)j);

    assert(i == 2);
    assert(j == 1);
}
---

$(P
The checks at the end of the program now pass.
)

)

$(LI
$(C Node) and $(C List) have been written to work only with the $(C int) type. We can convert these types to struct templates by adding $(C (T)) after their names and replacing appropriate $(C int)s in their definitions by $(C T)s:

---
$(CODE_NAME List)struct Node$(HILITE (T)) {
    $(HILITE T) element;
    Node * next;

    string toString() const {
        string result = to!string(element);

        if (next) {
            result ~= " -> " ~ to!string(*next);
        }

        return result;
    }
}

struct List$(HILITE (T)) {
    Node!$(HILITE T) * head;

    void insertAtHead($(HILITE T) element) {
        head = new Node!$(HILITE T)(element, head);
    }

    string toString() const {
        return format("(%s)", head ? to!string(*head) : "");
    }
}
---

$(P
$(C List) can now be used with any type:
)

---
$(CODE_XREF List)import std.stdio;
import std.conv;
import std.string;

// ...

struct Point {
    double x;
    double y;

    string toString() const {
        return format("(%s,%s)", x, y);
    }
}

void main() {
    $(HILITE List!Point) points;

    points.insertAtHead(Point(1.1, 2.2));
    points.insertAtHead(Point(3.3, 4.4));
    points.insertAtHead(Point(5.5, 6.6));

    writeln(points);
}
---

$(P
The output:
)

$(SHELL
((5.5,6.6) -> (3.3,4.4) -> (1.1,2.2))
)

)

$(LI In this case we need another pointer to point at the last node of the list. The new code is necessarily more complex in order to manage the new variable as well:

---
struct List(T) {
    Node!T * head;
    $(HILITE Node!T * tail);

    void append(T element) {
        /* Since there is no node after the last one, we set
         * the new node's next pointer to 'null'. */
        auto newNode = new Node!T(element, null);

        if (!head) {
            /* The list has been empty. The new node becomes
             * the head. */
            head = newNode;
        }

        if (tail) {
            /* We place this node after the current tail. */
            tail.next = newNode;
        }

        /* The new node becomes the new tail. */
        tail = newNode;
    }

    void insertAtHead(T element) {
        auto newNode = new Node!T(element, head);

        /* The new node becomes the new head. */
        head = newNode;

        if (!tail) {
            /* The list has been empty. The new node becomes
             * the tail. */
            tail = newNode;
        }
    }

    string toString() const {
        return format("(%s)", head ? to!string(*head) : "");
    }
}
---

$(P
The new implementation of $(C insertAtHead()) can actually be shorter:
)

---
    void insertAtHead(T element) {
        head = new Node!T(element, head);

        if (!tail) {
            tail = head;
        }
    }
---

$(P
The following program uses the new $(C List) to insert $(C Point) objects with odd values at the head and $(C Point) objects with even values at the end.
)

---
void $(CODE_DONT_TEST)main() {
    List!Point points;

    foreach (i; 1 .. 7) {
        if (i % 2) {
            points.insertAtHead(Point(i, i));

        } else {
            points.append(Point(i, i));
        }
    }

    writeln(points);
}
---

$(P
The output:
)

$(SHELL
((5,5) -> (3,3) -> (1,1) -> (2,2) -> (4,4) -> (6,6))
)

)

)

Macros:
        TITLE=Pointers Solutions

        DESCRIPTION=Programming in D Solutions: Pointers

        KEYWORDS=d programming language tutorial book pointers
