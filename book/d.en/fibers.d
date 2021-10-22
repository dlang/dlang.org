Ddoc

$(DERS_BOLUMU $(IX fiber) Fibers)

$(P
$(IX coroutine) $(IX green thread) $(IX thread, green) A fiber is a $(I thread of execution) enabling a single thread achieve multiple tasks. Compared to regular threads that are commonly used in parallelism and concurrency, it is more efficient to switch between fibers. Fibers are similar to $(I coroutines) and $(I green threads).
)

$(P
Fibers enable multiple call stacks per thread. For that reason, to fully understand and appreciate fibers, one must first understand the $(I call stack) of a thread.
)

$(H5 $(IX call stack) $(IX program stack) Call stack)

$(P
$(IX local state) The parameters, non-static local variables, the return value, and temporary expressions of a function, as well as any additional information that may be needed during its execution, comprise the $(I local state) of that function. The local state of a function is allocated and initialized automatically at run time every time that function is called.
)

$(P
$(IX stack frame) The storage space allocated for the local state of a function call is called a $(I frame) (or $(I stack frame)). As functions call other functions during the execution of a thread, their frames are conceptually placed on top of each other to form a stack of frames. The stack of frames of currently active function calls is the $(I call stack) of that thread.
)

$(P
For example, at the time the main thread of the following program starts executing the $(C bar()) function, there would be three levels of active function calls due to $(C main()) calling $(C foo()) and $(C foo()) calling $(C bar()):
)

---
void main() {
    int a;
    int b;

    int c = $(HILITE foo)(a, b);
}

int foo(int x, int y) {
    $(HILITE bar)(x + y);
    return 42;
}

void bar(int param) {
    string[] arr;
    // ...
}
---

$(P
During the execution of $(C bar()), the call stack would consist of three frames storing the local states of those currently active function calls:
)

$(MONO
The call stack grows upward
as function calls get deeper.    ▲  ▲
                                 │  │
   Top of the call stack → ┌──────────────┐
                           │ int param    │ ← bar's frame
                           │ string[] arr │
                           ├──────────────┤
                           │ int x        │
                           │ int y        │ ← foo's frame
                           │ return value │
                           ├──────────────┤
                           │ int a        │
                           │ int b        │ ← main's frame
                           │ int c        │
Bottom of the call stack → └──────────────┘
)

$(P
As layers of function calls get deeper when functions call other functions and shallower when functions return, the size of the call stack increases and decreases accordingly. For example, once $(C bar()) returns, its frame would no longer be needed and its space would later be used for another function call in the future:
)

$(MONO
$(LIGHT_GRAY                            ┌──────────────┐)
$(LIGHT_GRAY                            │ int param    │)
$(LIGHT_GRAY                            │ string[] arr │)
   Top of the call stack → ├──────────────┤
                           │ int a        │
                           │ int b        │ ← foo's frame
                           │ return value │
                           ├──────────────┤
                           │ int a        │
                           │ int b        │ ← main's frame
                           │ int c        │
Bottom of the call stack → └──────────────┘
)

$(P
We have been taking advantage of the call stack in every program that we have written so far. The advantages of the call stack is especially clear for recursive functions.
)

$(H6 $(IX recursion) Recursion)

$(P
Recursion is the situation where a function calls itself either directly or indirectly. Recursion greatly simplifies certain kinds of algorithms like the ones that are classified as $(I divide-and-conquer).
)

$(P
Let's consider the following function that calculates the sum of the elements of a slice. It achieves this task by calling itself recursively with a slice that is one element shorter than the one that it has received. The recursion continues until the slice becomes empty. The current result is carried over to the next recursion step as the second parameter:
)

---
import std.array;

int sum(int[] arr, int currentSum = 0) {
    if (arr.empty) {
        /* No element to add. The result is what has been
         * calculated so far. */
        return currentSum;
    }

    /* Add the front element to the current sum and call self
     * with the remaining elements. */
    return $(HILITE sum)(arr[1..$], currentSum + arr.front);
}

void main() {
    assert(sum([1, 2, 3]) == 6);
}
---

$(P
$(IX sum, std.algorithm) $(I $(B Note:) The code above is only for demonstration. Otherwise, the sum of the elements of a range should be calculated by $(C std.algorithm.sum), which uses special algorithms to achieve more accurate calculations for floating point types.)
)

$(P
When $(C sum()) is eventually called with an empty slice for the initial argument of $(C [1, 2, 3]) above, the relevant parts of the call stack would consist of the following frames. The value of each parameter is indicated after an $(C ==) sign. Remember to read the frame contents from bottom to top:
)

$(MONO
              ┌─────────────────────────┐
              │ arr        == []        │ ← final call to sum
              │ currentSum == 6         │
              ├─────────────────────────┤
              │ arr        == [3]       │ ← third call to sum
              │ currentSum == 3         │
              ├─────────────────────────┤
              │ arr        == [2, 3]    │ ← second call to sum
              │ currentSum == 1         │
              ├─────────────────────────┤
              │ arr        == [1, 2, 3] │ ← first call to sum
              │ currentSum == 0         │
              ├─────────────────────────┤
              │            ...          │ ← main's frame
              └─────────────────────────┘
)

$(P
$(I $(B Note:) In practice, when the recursive function directly returns the result of calling itself, compilers use a technique called "tail-call optimization", which eliminates separate frames for each recursive call.)
)

$(P
In a multithreaded program, since each thread would be working on its own task, every thread gets it own call stack to maintain its own execution state.
)

$(P
The power of fibers is based on the fact that although a fiber is not a thread, it gets its own call stack, effectively enabling multiple call stacks per thread. Since one call stack maintains the execution state of one task, multiple call stacks enable a thread work on multiple tasks.
)

$(H5 Usage)

$(P
The following are common operations of fibers. We will see examples of these later below.
)

$(UL

$(LI $(IX fiber function) A fiber starts its execution from a callable entity (function pointer, delegate, etc.) that does not take any parameter and does not return anything. For example, the following function can be used as a fiber function:

---
void fiberFunction() {
    // ...
}
---

)

$(LI $(IX Fiber, core.thread) A fiber can be created as an object of class $(C core.thread.Fiber) with a callable entity:

---
import core.thread;

// ...

    auto fiber = new Fiber($(HILITE &)fiberFunction);
---

$(P
Alternatively, a subclass of $(C Fiber) can be defined and the fiber function can be passed to the constructor of the superclass. In the following example, the fiber function is a member function:
)

---
class MyFiber : $(HILITE Fiber) {
    this() {
        super($(HILITE &)run);
    }

    void run() {
        // ...
    }
}

// ...

    auto fiber = new MyFiber();
---

)

$(LI $(IX call, Fiber) A fiber is started and resumed by its $(C call()) member function:

---
    fiber.call();
---

$(P
Unlike threads, the caller is paused while the fiber is executing.
)

)

$(LI $(IX yield, Fiber) A fiber pauses itself ($(I yields) execution to its caller) by $(C Fiber.yield()):

---
void fiberFunction() {
    // ...

        Fiber.yield();

    // ...
}
---

$(P
The caller's execution resumes when the fiber yields.
)

)

$(LI $(IX .state, Fiber) The execution state of a fiber is determined by its $(C .state) property:

---
    if (fiber.state == Fiber.State.TERM) {
        // ...
    }
---

$(P
$(IX State, Fiber) $(C Fiber.State) is an enum with the following values:
)

$(UL

$(LI $(IX HOLD, Fiber.State) $(C HOLD): The fiber is paused, meaning that it can be started or resumed.)

$(LI $(IX EXEC, Fiber.State) $(C EXEC): The fiber is currently executing.)

$(LI $(IX TERM, Fiber.State) $(IX reset, Fiber) $(C TERM): The fiber has terminated. It must be $(C reset()) before it can be used again.)

)

)

)

$(H5 Fibers in range implementations)

$(P
Almost every range needs to store some information to remember its state of iteration. This is necessary for it to know what to do when its $(C popFront()) is called next time. Most range examples that we saw in $(LINK2 ranges.html, the Ranges) and later chapters have been storing some kind of state to achieve their tasks.
)

$(P
For example, $(C FibonacciSeries) that we have defined earlier was keeping two member variables to calculate the $(I next next) number in the series:
)

---
struct FibonacciSeries {
    int $(HILITE current) = 0;
    int $(HILITE next) = 1;

    enum empty = false;

    int front() const {
        return current;
    }

    void popFront() {
        const nextNext = current + next;
        current = next;
        next = nextNext;
    }
}
---

$(P
While maintaining the iteration state is trivial for some ranges like $(C FibonacciSeries), it is surprisingly harder for some others, e.g. recursive data structures like binary search trees. The reason why it is surprising is that for such data structures, the same algorithms are trivial when implemented recursively.
)

$(P
For example, the following recursive implementations of $(C insert()) and $(C print()) do not define any variables and are independent of the number of elements contained in the tree. The recursive calls are highlighted. (Note that $(C insert()) is recursive indirectly through $(C insertOrSet()).)
)

---
import std.stdio;
import std.string;
import std.conv;
import std.random;
import std.range;
import std.algorithm;

/* Represents the nodes of a binary tree. This type is used in
 * the implementation of struct Tree below and should not be
 * used directly. */
struct Node {
    int element;
    Node * left;     // Left sub-tree
    Node * right;    // Right sub-tree

    void $(HILITE insert)(int element) {
        if (element < this.element) {
            /* Smaller elements go under the left sub-tree. */
            insertOrSet(left, element);

        } else if (element > this.element) {
            /* Larger elements go under the right sub-tree. */
            insertOrSet(right, element);

        } else {
            throw new Exception(format("%s already exists",
                                       element));
        }
    }

    void $(HILITE print)() const {
        /* First print the elements of the left sub-tree */
        if (left) {
            left.$(HILITE print)();
            write(' ');
        }

        /* Then print this element */
        write(element);

        /* Lastly, print the elements of the right sub-tree */
        if (right) {
            write(' ');
            right.$(HILITE print)();
        }
    }
}

/* Inserts the element to the specified sub-tree, potentially
 * initializing its node. */
void insertOrSet(ref Node * node, int element) {
    if (!node) {
        /* This is the first element of this sub-tree. */
        node = new Node(element);

    } else {
        node.$(HILITE insert)(element);
    }
}

/* This is the actual Tree representation. It allows an empty
 * tree by means of 'root' being equal to 'null'. */
struct Tree {
    Node * root;

    /* Inserts the element to this tree. */
    void insert(int element) {
        insertOrSet(root, element);
    }

    /* Prints the elements in sorted order. */
    void print() const {
        if (root) {
            root.print();
        }
    }
}

/* Populates the tree with 'n' random numbers picked out of a
 * set of '10 * n' numbers. */
Tree makeRandomTree(size_t n) {
    auto numbers = iota((n * 10).to!int)
                   .randomSample(n, Random(unpredictableSeed))
                   .array;

    randomShuffle(numbers);

    /* Populate the tree with those numbers. */
    auto tree = Tree();
    numbers.each!(e => tree.insert(e));

    return tree;
}

void main() {
    auto tree = makeRandomTree(10);
    tree.print();
}
---

$(P
$(I $(B Note:) The program above uses the following features from Phobos:)
)

$(UL

$(LI
$(IX iota, std.range) $(C std.range.iota) generates the elements of a given value range lazily. (By default, the first element is the $(C .init) value). For example, $(C iota(10)) is a range of $(C int) elements from $(C 0) to $(C 9).
)

$(LI
$(IX each, std.algorithm) $(IX map, vs. each) $(C std.algorithm.each) is similar to $(C std.algorithm.map). While $(C map()) generates a new result for each element, $(C each()) generates side effects for each element. Additionally, $(C map()) is lazy while $(C each()) is eager.
)

$(LI
$(IX randomSample, std.random) $(C std.random.randomSample) picks a random sampling of elements from a given range without changing their order.
)

$(LI
$(IX randomShuffle, std.random) $(C std.random.randomShuffle) shuffles the elements of a range randomly.
)

)

$(P
Like most containers, one would like this tree to provide a range interface so that its elements can be used with existing range algorithms. This can be done by defining an $(C opSlice()) member function:
)

---
struct Tree {
// ...

    /* Provides access to the elements of the tree in sorted
     * order. */
    struct InOrderRange {
        $(HILITE ... What should the implementation be? ...)
    }

    InOrderRange opSlice() const {
        return InOrderRange(root);
    }
}
---

$(P
Although the $(C print()) member function above essentially achieves the same task of visiting every element in sorted order, it is not easy to implement an $(C InputRange) for a tree. I will not attempt to implement $(C InOrderRange) here but I encourage you to implement or at least research tree iterators. (Some implementations require that tree nodes have an additional $(C Node*) to point at each node's parent.)
)

$(P
The reason why recursive tree algorithms like $(C print()) are trivial is due to the automatic management of the call stack. The call stack implicitly contains information not only about what the current element is, but also how the execution of the program arrived at that element (e.g. at what nodes did the execution follow the left node versus the right node).
)

$(P
For example, when a recursive call to $(C left.print()) returns after printing the elements of the left sub-tree, the local state of the current $(C print()) call already implies that it is now time to print a space character:
)

---
    void print() const {
        if (left) {
            left.print();
            write(' ');   // ← Call stack implies this is next
        }

        // ...
    }
---

$(P
Fibers are useful for similar cases where using a call stack is much easier than maintaining state explicitly.
)

$(P
Although the benefits of fibers would not be apparent on a simple task like generating the Fibonacci series, for simplicity let's cover common fiber operations on a fiber implementation of one. We will implement a tree range later below.
)

---
import core.thread;

/* This is the fiber function that generates each element and
 * then sets the 'ref' parameter to that element. */
void fibonacciSeries($(HILITE ref) int current) {                 // (1)
    current = 0;    // Note that 'current' is the parameter
    int next = 1;

    while (true) {
        $(HILITE Fiber.yield());                                  // (2)
        /* Next call() will continue from this point */ // (3)

        const nextNext = current + next;
        current = next;
        next = nextNext;
    }
}

void main() {
    int current;                                        // (1)
                         // (4)
    Fiber fiber = new Fiber(() => fibonacciSeries(current));

    foreach (_; 0 .. 10) {
        fiber$(HILITE .call());                                   // (5)

        import std.stdio;
        writef("%s ", current);
    }
}
---

$(OL

$(LI The fiber function above takes a reference to an $(C int). It uses this parameter to communicate the current element to its caller. (The parameter could be qualified as $(C out) instead of $(C ref) as well).)

$(LI When the current element is ready for use, the fiber pauses itself by calling $(C Fiber.yield()).)

$(LI A later $(C call()) will resume the function right after the fiber's last $(C Fiber.yield()) call. (The first $(C call()) starts the function.))

$(LI Because fiber functions do not take parameters, $(C fibonacciSeries()) cannot be used directly as a fiber function. Instead, a parameter-less $(LINK2 lambda.html, delegate) is used as an adaptor to be passed to the $(C Fiber) constructor.)

$(LI The caller starts and resumes the fiber by its $(C call()) member function.)

)

$(P
As a result, $(C main()) receives the elements of the series through $(C current) and prints them:
)

$(SHELL
0 1 1 2 3 5 8 13 21 34 
)

$(H6 $(IX Generator, std.concurrency) $(C std.concurrency.Generator) for presenting fibers as ranges)

$(P
Although we have achieved generating the Fibonacci series with a fiber, that implementation has the following shortcomings:
)

$(UL

$(LI The solution above does not provide a range interface, making it incompatible with existing range algorithms.)

$(LI Presenting the elements by mutating a $(C ref) parameter is less desirable compared to a design where the elements are copied to the caller's context.)

$(LI Constructing and using the fiber explicitly through its member functions exposes $(I lower level) implementation details, compared to alternative designs.)

)

$(P
The $(C std.concurrency.Generator) class addresses all of these issues. Note how $(C fibonacciSeries()) below is written as a simple function. The only difference is that instead of returning a single element by $(C return), it can make multiple elements available by $(C yield()) ($(I infinite elements) in this example).
)

$(P
$(IX yield, std.concurrency) Also note that this time it is the $(C std.concurrency.yield) function, not the $(C Fiber.yield) member function that we used above.
)

---
import std.stdio;
import std.range;
import std.concurrency;

/* This alias is used for resolving the name conflict with
 * std.range.Generator. */
alias FiberRange = std.concurrency.Generator;

void fibonacciSeries() {
    int current = 0;
    int next = 1;

    while (true) {
        $(HILITE yield(current));

        const nextNext = current + next;
        current = next;
        next = nextNext;
    }
}

void main() {
    auto series = new $(HILITE FiberRange!int)(&fibonacciSeries);
    writefln("%(%s %)", series.take(10));
}
---

$(P
As a result, the elements that are produced by a fiber function are used conveniently as an $(C InputRange):
)

$(SHELL
0 1 1 2 3 5 8 13 21 34
)

$(P
Using $(C Generator), we can easily present the elements of a tree as an $(C InputRange) as well. Further, once the tree has an $(C InputRange) interface, the $(C print()) member function would not be needed anymore; hence it is removed. Especially note how $(C byNode()) is implemented as an adaptor over the recursive function $(C nextNode()):
)

---
import std.concurrency;

alias FiberRange = std.concurrency.Generator;

struct Node {
// ...

    /* Note: print() member function is removed because it is
     * not needed anymore. */

    auto opSlice() const {
        return byNode(&this);
    }
}

/* This is the fiber function that yields the next tree node
 * in sorted order. */
void nextNode(const(Node) * node) {
    if (!node) {
        /* No element at or under this node */
        return;
    }

    nextNode(node.left);    // First, elements on the left
    $(HILITE yield(node));            // Then, this element
    nextNode(node.right);   // Finally, elements on the right
}

/* Returns an InputRange to the nodes of the tree. */
auto byNode(const(Node) * node) {
    return new FiberRange!(const(Node)*)(
        () => nextNode(node));
}

// ...

struct Tree {
// ...

    /* Note: print() member function is removed because it is
     * not needed anymore. */

    auto opSlice() const {
        /* A translation from the nodes to the elements. */
        return byNode(this).map!(n => n.element);
    }
}

/* Returns an InputRange to the nodes of the tree. The
 * returned range is empty if the tree has no elements (i.e.
 * if 'root' is 'null'). */
auto byNode(const(Tree) tree) {
    if (tree.root) {
        return byNode(tree.root);

    } else {
        alias RangeType = typeof(return);
        return new RangeType(() {});    $(CODE_NOTE Empty range)
    }
}
---

$(P
$(C Tree) objects can now be sliced with $(C []) and the result can be used as an $(C InputRange):
)

---
    writefln("%(%s %)", tree$(HILITE []));
---

$(H5 $(IX asynchronous I/O, fiber) Fibers in asynchronous input and output)

$(P
The call stack of a fiber can simplify asynchronous input and output tasks as well.
)

$(P
As an example, let's imagine a system where users sign on to a service by connecting to a server and providing their $(I name), $(I email), and $(I age), in that order. This would be similar to the $(I sign-on user flow) of a website. To keep the example simple, instead of implementing an actual web service, let's simulate user interactions using data entered on the command line. Let's use the following simple sign-on protocol, where input data is highlighted:
)

$(UL
$(LI $(HILITE $(C hi)): A user connects and a flow id is generated)
$(LI $(HILITE $(C $(I id data))): The user of flow that corresponds to $(C id) enters the next expected data. For example, if the expected data for flow $(C 42) is $(I name), then the command for Alice would be $(C 42&nbsp;Alice).)
$(LI $(HILITE $(C bye)): Program exits)
)

$(P
For example, the following can be the interactions of Alice and Bob, where the inputs to the simulation program are highlighted. Each user connects and then provides $(I name), $(I email), and $(I age):
)

$(SHELL
> $(HILITE hi)                     $(SHELL_NOTE Alice connects)
Flow 0 started.
> $(HILITE 0 Alice)
> $(HILITE 0 alice@example.com)
> $(HILITE 0 20)
Flow 0 has completed.    $(SHELL_NOTE Alice finishes)
Added user 'Alice'.
> $(HILITE hi)                     $(SHELL_NOTE Bob connects)
Flow 1 started.
> $(HILITE 1 Bob)
> $(HILITE 1 bob@example.com)
> $(HILITE 1 30)
Flow 1 has completed.    $(SHELL_NOTE Bob finishes)
Added user 'Bob'.
> $(HILITE bye)
Goodbye.
Users:
  User("Alice", "alice@example.com", 20)
  User("Bob", "bob@example.com", 30)
)

$(P
This program can be designed to wait for the command $(C hi) in a loop and then call a function to receive the input data of the connected user:
)

---
    if (input == "hi") {
        signOnNewUser();    $(CODE_NOTE_WRONG WARNING: Blocking design)
    }
---

$(P
Unless the program had some kind of support for multitasking, such a design would be considered $(I blocking), meaning that all other users would be blocked until the current user completes their sign on flow. This would impact the responsiveness of even lightly-used services if users took several minutes to provide data.
)

$(P
There can be several designs that makes this service $(I non-blocking), meaning that more than one user can sign on at the same time:
)

$(UL

$(LI Maintaining tasks explicitly: The main thread can spawn one thread per user sign-on and pass input data to that thread by means of messages. Although this method would work, it might involve thread synchronization and it can be slower than a fiber. (The reasons for this potential performance penalty will be explained in the $(I cooperative multitasking) section below.))

$(LI Maintaining state: The program can accept more than one sign-on and remember the state of each sign-on explicitly. For example, if Alice has entered only her name so far, her state would have to indicate that the next input data would be her email information.)

)

$(P
Alternatively, a design based on fibers can employ one fiber per sign-on flow. This would enable implementing the flow in a linear fashion, matching the protocol exactly: first the name, then the email, and finally the age. For example, $(C run()) below does not need to do anything special to remember the state of the sign-on flow. When it is $(C call())'ed next time, it continues right after the last $(C Fiber.yield()) call that had paused it. The next line to be executed is implied by the call stack.
)

$(P
Differently from earlier examples, the following program uses a $(C Fiber) subclass:
)

---
import std.stdio;
import std.string;
import std.format;
import std.exception;
import std.conv;
import std.array;
import core.thread;

struct User {
    string name;
    string email;
    uint age;
}

/* This Fiber subclass represents the sign-on flow of a
 * user. */
class SignOnFlow : Fiber {
    /* The data read most recently for this flow. */
    string inputData_;

    /* The information to construct a User object. */
    string name;
    string email;
    uint age;

    this() {
        /* Set our 'run' member function as the starting point
         * of the fiber. */
        super(&run);
    }

    void run() {
        /* First input is name. */
        name = inputData_;
        $(HILITE Fiber.yield());

        /* Second input is email. */
        email = inputData_;
        $(HILITE Fiber.yield());

        /* Last input is age. */
        age = inputData_.to!uint;

        /* At this point we have collected all information to
         * construct the user. We now "return" instead of
         * 'Fiber.yield()'. As a result, the state of this
         * fiber becomes Fiber.State.TERM. */
    }

    /* This property function is to receive data from the
     * caller. */
    void inputData(string data) {
        inputData_ = data;
    }

    /* This property function is to construct a user and
     * return it to the caller. */
    User user() const {
        return User(name, email, age);
    }
}

/* Represents data read from the input for a specific flow. */
struct FlowData {
    size_t id;
    string data;
}

/* Parses data related to a flow. */
FlowData parseFlowData(string line) {
    size_t id;
    string data;

    const items = line.formattedRead!" %s %s"(id, data);
    enforce(items == 2, format("Bad input '%s'.", line));

    return FlowData(id, data);
}

void main() {
    User[] users;
    SignOnFlow[] flows;

    bool done = false;

    while (!done) {
        write("> ");
        string line = readln.strip;

        switch (line) {
        case "hi":
            /* Start a flow for the new connection. */
            flows ~= new SignOnFlow();

            writefln("Flow %s started.", flows.length - 1);
            break;

        case "bye":
            /* Exit the program. */
            done = true;
            break;

        default:
            /* Try to use the input as flow data. */
            try {
                auto user = handleFlowData(line, flows);

                if (!user.name.empty) {
                    users ~= user;
                    writefln("Added user '%s'.", user.name);
                }

            } catch (Exception exc) {
                writefln("Error: %s", exc.msg);
            }
            break;
        }
    }

    writeln("Goodbye.");
    writefln("Users:\n%(  %s\n%)", users);
}

/* Identifies the owner fiber for the input, sets its input
 * data, and resumes that fiber. Returns a user with valid
 * fields if the flow has been completed. */
User handleFlowData(string line, SignOnFlow[] flows) {
    const input = parseFlowData(line);
    const id = input.id;

    enforce(id < flows.length, format("Invalid id: %s.", id));

    auto flow = flows[id];

    enforce(flow.state == Fiber.State.HOLD,
            format("Flow %s is not runnable.", id));

    /* Set flow data. */
    flow.inputData = input.data;

    /* Resume the flow. */
    flow$(HILITE .call());

    User user;

    if (flow.state == Fiber.State.TERM) {
        writefln("Flow %s has completed.", id);

        /* Set the return value to the newly created user. */
        user = flow.user;

        /* TODO: This fiber's entry in the 'flows' array can
         * be reused for a new flow in the future. However, it
         * must first be reset by 'flow.reset()'. */
    }

    return user;
}
---

$(P
$(C main()) reads lines from the input, parses them, and dispatches flow data to the appropriate flow to be processed. The call stack of each flow maintains the flow state automatically. New users are added to the system when the complete user information becomes available.
)

$(P
When you run the program above, you see that no matter how long a user takes to complete their individual sign-on flow, the system always accepts new user connections. As an example, Alice's interaction is highlighted:
)

$(SHELL
> $(HILITE hi)                     $(SHELL_NOTE Alice connects)
Flow 0 started.
> $(HILITE 0 Alice)
> hi                     $(SHELL_NOTE Bob connects)
Flow 1 started.
> hi                     $(SHELL_NOTE Cindy connects)
Flow 2 started.
> $(HILITE 0 alice@example.com)
> 1 Bob
> 2 Cindy
> 2 cindy@example.com
> 2 40                   $(SHELL_NOTE Cindy finishes)
Flow 2 has completed.
Added user 'Cindy'.
> 1 bob@example.com
> 1 30                   $(SHELL_NOTE Bob finishes)
Flow 1 has completed.
Added user 'Bob'.
> $(HILITE 0 20)                   $(SHELL_NOTE Alice finishes)
Flow 0 has completed.
Added user 'Alice'.
> bye
Goodbye.
Users:
  User("Cindy", "cindy@example.com", 40)
  User("Bob", "bob@example.com", 30)
  User("Alice", "alice@example.com", 20)
)

$(P
Although Alice, Bob, and Cindy connect in that order, they complete their sign-on flows at different paces. As a result, the $(C users) array is populated in the order that the flows are completed.
)

$(P
One benefit of using fibers in this program is that $(C SignOnFlow.run()) is written trivially without regard to how fast or slow a user's input has been. Additionally, no user is blocked when other sign-on flows are in progress.
)

$(P
$(IX vibe.d) Many asynchronous input/output frameworks like $(LINK2 http://vibed.org, vibe.d) use similar designs based on fibers.
)

$(H5 $(IX exception, fiber) Exceptions and fibers)

$(P
In $(LINK2 exceptions.html, the Exceptions chapter) we saw how "an exception object that is thrown from a lower level function is transferred to the higher level functions one level at a time". We also saw that an uncaught exception "causes the program to finally exit the $(C main()) function." Although that chapter did not mention the call stack, the described behavior of the exception mechanism is achieved by the call stack as well.
)

$(P
$(IX stack unwinding) Continuing with the first example in this chapter, if an exception is thrown inside $(C bar()), first the frame of $(C bar()) would be removed from the call stack, then $(C foo())'s, and finally $(C main())'s. As functions are exited and their frames are removed from the call stack, the destructors of local variables are executed for their final operations. The process of leaving functions and executing destructors of local variables due to a thrown exception is called $(I stack unwinding).
)

$(P
Since fibers have their own stack, an exception that is thrown during the execution of the fiber unwinds the fiber's call stack, not its caller's. If the exception is not caught, the fiber function terminates and the fiber's state becomes $(C Fiber.State.TERM).
)

$(P
$(IX yieldAndThrow, Fiber) Although that may be the desired behavior in some cases, sometimes a fiber may need to communicate an error condition to its caller without losing its execution state. $(C Fiber.yieldAndThrow) allows a fiber to yield and immediately throw an exception in the caller's context.
)

$(P
To see how it can be used let's enter invalid age data to the sign-on program:
)

$(SHELL
> hi
Flow 0 started.
> 0 Alice
> 0 alice@example.com
> 0 $(HILITE hello)                       $(SHELL_NOTE_WRONG the user enters invalid age)
Error: Unexpected 'h' when converting from type string to type uint
> 0 $(HILITE 20)                          $(SHELL_NOTE attempts to correct the error)
Error: Flow 0 is not runnable.  $(SHELL_NOTE but the flow is terminated)
)

$(P
Instead of terminating the fiber and losing the entire sign-on flow, the fiber can catch the conversion error and communicate it to the caller by $(C yieldAndThrow()). This can be done by replacing the following line of the program where the fiber converts age data:
)

---
        age = inputData_.to!uint;
---

$(P
Wrapping that line with a $(C try-catch) statement inside an unconditional loop would be sufficient to keep the fiber alive until there is data that can be converted to a $(C uint):
)

---
        while (true) {
            try {
                age = inputData_.to!uint;
                break;  // ← Conversion worked; leave the loop

            } catch (ConvException exc) {
                Fiber.yieldAndThrow(exc);
            }
        }
---

$(P
This time the fiber remains in an unconditional loop until data is valid:
)

$(SHELL
> hi
Flow 0 started.
> 0 Alice
> 0 alice@example.com
> 0 $(HILITE hello)                       $(SHELL_NOTE_WRONG the user enters invalid age)
Error: Unexpected 'h' when converting from type string to type uint
> 0 $(HILITE world)                       $(SHELL_NOTE_WRONG enters invalid age again)
Error: Unexpected 'w' when converting from type string to type uint
> 0 $(HILITE 20)                          $(SHELL_NOTE finally, enters valid data)
Flow 0 has completed.
Added user 'Alice'.
> bye
Goodbye.
Users:
  User("Alice", "alice@example.com", 20)
)

$(P
As can be seen from the output, this time the sign-on flow is not lost and the user is added to the system.
)

$(H5 $(IX preemptive multitasking, vs. cooperative multitasking) $(IX cooperative multitasking) $(IX thread performance) Cooperative multitasking)

$(P
Unlike operating system threads, which are paused (suspended) and resumed by the operating system at unknown points in time, a fiber pauses itself explicitly and is resumed by its caller explicitly. According to this distinction, the kind of multitasking that the operating system provides is called $(I preemptive multitasking) and the kind that fibers provide is called $(I cooperative multitasking).
)

$(P
$(IX context switching) In preemptive multitasking, the operating system allots a certain amount of time to a thread when it starts or resumes its execution. When the time is up, that thread is paused and another one is resumed in its place. Moving from one thread to another is called $(I context switching). Context switching takes a relatively large amount of time, which could have better been spent doing actual work by threads.
)

$(P
Considering that a system is usually busy with high number of threads, context switching is unavoidable and is actually desired. However, sometimes threads need to pause themselves voluntarily before they use up the entire time that was alloted to them. This can happen when a thread needs information from another thread or from a device. When a thread pauses itself, the operating system must spend time again to switch to another thread. As a result, time that could have been used for doing actual work ends up being used for context switching.
)

$(P
With fibers, the caller and the fiber execute as parts of the same thread. (That is the reason why the caller and the fiber cannot execute at the same time.) As a benefit, there is no overhead of context switching between the caller and the fiber. (However, there is still some light overhead which is comparable to the overhead of a regular function call.)
)

$(P
Another benefit of cooperative multitasking is that the data that the caller and the fiber exchange is more likely to be in the CPU's data cache. Because data that is in the CPU cache can be accessed hundreds of times faster than data that needs to be read back from system memory, this further improves the performance of fibers.
)

$(P
Additionally, because the caller and the fiber are never executed at the same time, there is no possibility of race conditions, obviating the need for data synchronization. However, the programmer must still ensure that a fiber yields at the intended time (e.g. when data is actually ready). For example, the $(C func()) call below must not execute a $(C Fiber.yield()) call, even indirectly, as that would be premature, before the value of $(C sharedData) was doubled:
)

---
void fiberFunction() {
    // ...

        func();           $(CODE_NOTE must not yield prematurely)
        sharedData *= 2;
        Fiber.yield();    $(CODE_NOTE intended point to yield)

    // ...
}
---

$(P
$(IX M:N, threading) One obvious shortcoming of fibers is that only one core of the CPU is used for the caller and its fibers. The other cores of the CPU might be sitting idle, effectively wasting resources. It is possible to use different designs like the $(I M:N threading model (hybrid threading)) that employ other cores as well. I encourage you to research and compare different threading models.
)

$(H5 Summary)

$(UL

$(LI The call stack enables efficient allocation of local state and simplifies certain algorithms, especially the recursive ones.)

$(LI Fibers enable multiple call stacks per thread instead of the default single call stack per thread.)

$(LI A fiber and its caller are executed on the same thread (i.e. not at the same time).)

$(LI A fiber pauses itself by $(I yielding) to its caller and the caller resumes its fiber by $(I calling) it again.)

$(LI $(C Generator) presents a fiber as an $(C InputRange).)

$(LI Fibers simplify algorithms that rely heavily on the call stack.)

$(LI Fibers simplify asynchronous input/output operations.)

$(LI Fibers provide cooperative multitasking, which has different trade-offs from preemptive multitasking.)

)

macros:
        TITLE=Fibers

        DESCRIPTION=Generators and cooperative multitasking by fibers.

        KEYWORDS=d programming language tutorial book fiber cooperative multitasking
