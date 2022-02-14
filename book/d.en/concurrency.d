Ddoc

$(DERS_BOLUMU $(IX concurrency, message passing) $(IX message passing concurrency) Message Passing Concurrency)

$(P
Concurrency is similar to but different from the topic of the previous chapter, parallelism. As these two concepts both involve executing programs on threads, and as parallelism is based on concurrency, they are sometimes confused with each other.
)

$(P
$(IX parallelism vs. concurrency) $(IX concurrency vs. parallelism) The following are the differences between parallelism and concurrency:
)

$(UL

$(LI
The main purpose of parallelism is to take advantage of microprocessor cores to improve the performance of programs. Concurrency on the other hand, is a concept that may be needed even on a single-core environment. Concurrency is about making a program run on more than one thread at a time. An example of a concurrent program would be a server program that is responding to requests of more than one client at the same time.
)

$(LI
In parallelism, tasks are independent from each other. In fact, it would be a bug if they did depend on results of other tasks that are running at the same time. In concurrency, it is normal for threads to depend on results of other threads.
)

$(LI
Although both programming models use operating system threads, in parallelism threads are encapsulated by the concept of task. Concurrency makes use of threads explicitly.
)

$(LI
Parallelism is easy to use, and as long as tasks are independent it is easy to produce programs that work correctly. Concurrency is easy only when it is based on $(I message passing). It is very difficult to write correct concurrent programs if they are based on the traditional model of concurrency that involves lock-based data sharing.
)

)

$(P
D supports both models of concurrency: message passing and data sharing. We will cover message passing in this chapter and data sharing in the next chapter.
)

$(H5 Concepts)

$(P
$(IX thread) $(B Thread): Operating systems execute programs as work units called $(I threads). D programs start executing with $(C main()) on a thread that has been assigned to that program by the operating system. All of the operations of the program are normally executed on that thread. The program is free to start other threads to be able to work on multiple tasks at the same time. In fact, tasks that have been covered in the previous chapter are based on threads that are started automatically by $(C std.parallelism).
)

$(P
The operating system can pause threads at unpredictable times for unpredictable durations. As a result, even operations as simple as incrementing a variable may be paused mid operation:
)

---
    ++i;
---

$(P
The operation above involves three steps: Reading the value of the variable, incrementing the value, and assigning the new value back to the variable. The thread may be paused at any point between these steps to be continued after an unpredictable time.
)

$(P
$(IX message) $(B Message): Data that is passed between threads are called messages. Messages may be composed of any type and any number of variables.
)

$(P
$(IX thread id) $(B Thread identifier): Every thread has an id, which is used for specifying recipients of messages.
)

$(P
$(IX owner) $(B Owner): Any thread that starts another thread is called the owner of the new thread.
)

$(P
$(IX worker) $(B Worker): Any thread that is started by an owner is called a worker.
)

$(H5 $(IX spawn) Starting threads)

$(P
$(C spawn()) takes a function pointer as a parameter and starts a new thread from that function. Any operations that are carried out by that function, including other functions that it may call, would be executed on the new thread. The main difference between a thread that is started with $(C spawn()) and a thread that is started with $(LINK2 parallelism.html, $(C task())) is the fact that $(C spawn()) makes it possible for threads to send messages to each other.
)

$(P
As soon as a new thread is started, the owner and the worker start executing separately as if they were independent programs:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

void worker() {
    foreach (i; 0 .. 5) {
        Thread.sleep(500.msecs);
        writeln(i, " (worker)");
    }
}

void main() {
    $(HILITE spawn(&worker));

    foreach (i; 0 .. 5) {
        Thread.sleep(300.msecs);
        writeln(i, " (main)");
    }

    writeln("main is done.");
}
---

$(P
The examples in this chapter call $(C Thread.sleep) to slow down threads to demonstrate that they run at the same time. The output of the program shows that the two threads, one that runs $(C main()) and the other that has been started by $(C spawn()), execute independently at the same time:
)

$(SHELL
0 (main)
0 (worker)
1 (main)
2 (main)
1 (worker)
3 (main)
2 (worker)
4 (main)
main is done.
3 (worker)
4 (worker)
)

$(P
The program automatically waits for all of the threads to finish executing. We can see this in the output above by the fact that $(C worker()) continues executing even after $(C main()) exits after printing "main is done."
)

$(P
The parameters that the thread function takes are passed to $(C spawn()) as its second and later arguments. The two worker threads in the following program print four numbers each. They take the starting number as the thread function parameter:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

void worker($(HILITE int firstNumber)) {
    foreach (i; 0 .. 4) {
        Thread.sleep(500.msecs);
        writeln(firstNumber + i);
    }
}

void main() {
    foreach (i; 1 .. 3) {
        spawn(&worker, $(HILITE i * 10));
    }
}
---

$(P
The output of one of the threads is highlighted:
)

$(SHELL
10
$(HILITE 20)
11
$(HILITE 21)
12
$(HILITE 22)
13
$(HILITE 23)
)

$(P
The lines of the output may be different at different times depending on how the threads are paused and resumed by the operating system.
)

$(P
$(IX CPU bound) $(IX I/O bound) $(IX thread performance) Every operating system puts limits on the number of threads that can exist at one time. These limits can be set for each user, for the whole system, or for something else. The overall performance of the system can be reduced if there are more threads that are busily working than the number of cores in the system. A thread that is busily working at a given time is said to be $(I CPU bound) at that point in time. On the other hand, some threads spend considerable amount of their time waiting for some event to occur like input from a user, data from a network connection, the completion of a $(C Thread.sleep) call, etc. Such threads are said to be $(I I/O bound) at those times. If the majority of its threads are I/O bound, then a program can afford to start more threads than the number of cores without any degradation of performance. As it should be in every design decision that concerns program performance, one must take actual measurements to be exactly sure whether that really is the case.
)

$(H5 $(IX Tid) $(IX thisTid) $(IX ownerTid) Thread identifiers)

$(P
$(C thisTid()) returns the identifier of the $(I current) thread. It is commonly called without the function parentheses:
)

---
import std.stdio;
import std.concurrency;

void printTid(string tag) {
    writefln("%s: %s", tag, $(HILITE thisTid));
}

void worker() {
    printTid("Worker");
}

void main() {
    spawn(&worker);
    printTid("Owner ");
}
---

$(P
The return type of $(C thisTid()) is $(C Tid), which has no significance for the program. Even its $(C toString()) function is not overloaded:
)

$(SHELL
Owner : Tid(std.concurrency.MessageBox)
Worker: Tid(std.concurrency.MessageBox)
)

$(P
The return value of $(C spawn()), which I have been ignoring until this point, is the id of the worker thread:
)

---
    $(HILITE Tid myWorker) = spawn(&worker);
---

$(P
Conversely, the owner of a worker thread is obtained by the $(C ownerTid()) function.
)

$(P
In summary, the owner is identified by $(C ownerTid) and the worker is identified by the return value of $(C spawn()).
)

$(H5 $(IX send) $(IX receiveOnly) Message Passing)

$(P
$(C send()) sends messages and $(C receiveOnly()) waits for a message of a particular type. (There is also $(C prioritySend()), $(C receive()), and $(C receiveTimeout()), which will be explained later below.)
)

$(P
The owner in the following program sends its worker a message of type $(C int) and waits for a message from the worker of type $(C double). The threads continue sending messages back and forth until the owner sends a negative $(C int). This is the owner thread:
)

---
void $(CODE_DONT_TEST)main() {
    Tid worker = spawn(&workerFunc);

    foreach (value; 1 .. 5) {
        $(HILITE worker.send)(value);
        double result = $(HILITE receiveOnly!double)();
        writefln("sent: %s, received: %s", value, result);
    }

    /* Sending a negative value to the worker so that it
     * terminates. */
    $(HILITE worker.send)(-1);
}
---

$(P
$(C main()) stores the return value of $(C spawn()) under the name $(C worker) and uses that variable when sending messages to the worker.
)

$(P
On the other side, the worker receives the message that it needs as an $(C int), uses that value in a calculation, and sends the result as type $(C double) to its owner:
)

---
void workerFunc() {
    int value = 0;

    while (value >= 0) {
        value = $(HILITE receiveOnly!int)();
        double result = to!double(value) / 5;
        $(HILITE ownerTid.send)(result);
    }
}
---

$(P
The main thread reports the messages that it sends and the messages that it receives:
)

$(SHELL
sent: 1, received: 0.2
sent: 2, received: 0.4
sent: 3, received: 0.6
sent: 4, received: 0.8
)

$(P
It is possible to send more than one value as a part of the same message. The following message consists of three parts:
)

---
    ownerTid.send($(HILITE thisTid, 42, 1.5));
---

$(P
Values that are passed as parts of a single message appear as a tuple on the receiver's side. In such cases the template parameters of $(C receiveOnly()) must match the types of the tuple members:
)

---
    /* Wait for a message composed of Tid, int, and double. */
    auto message = receiveOnly!($(HILITE Tid, int, double))();

    auto sender   = message[0];    // of type Tid
    auto integer  = message[1];    // of type int
    auto floating = message[2];    // of type double
---

$(P
$(IX MessageMismatch) If the types do not match, a $(C MessageMismatch) exception is thrown:
)

---
import std.concurrency;

void workerFunc() {
    ownerTid.send("hello");    $(CODE_NOTE Sending $(HILITE string))
}

void main() {
    spawn(&workerFunc);

    auto message = receiveOnly!double();    $(CODE_NOTE Expecting $(HILITE double))
}
---

$(P
The output:
)

$(SHELL
std.concurrency.$(HILITE MessageMismatch)@std/concurrency.d(235):
Unexpected message type: expected 'double', got 'immutable(char)[]'
)

$(P
The exceptions that the worker may throw cannot be caught by the owner. One solution is to have the worker catch the exception to be sent as a message. We will see this below.
)

$(H6 Example)

$(P
Let's use what we have seen so far in a simulation program.
)

$(P
The following program simulates independent robots moving around randomly in a two dimensional space. The movement of each robot is handled by a separate thread that takes three pieces of information when started:
)

$(UL

$(LI The number (id) of the robot: This information is sent back to the owner to identify the robot that the message is related to.
)

$(LI The origin: This is where the robot starts moving from.
)

$(LI The duration between each step: This information is used for determining when the robot's next step will be.
)

)

$(P
That information can be stored in the following $(C Job) struct:
)

---
struct Job {
    size_t robotId;
    Position origin;
    Duration restDuration;
}
---

$(P
The thread function that moves each robot sends the id of the robot and its movement to the owner thread continuously:
)

---
void robotMover(Job job) {
    Position from = job.origin;

    while (true) {
        Thread.sleep(job.restDuration);

        Position to = randomNeighbor(from);
        Movement movement = Movement(from, to);
        from = to;

        ownerTid.send($(HILITE MovementMessage)(job.robotId, movement));
    }
}
---

$(P
The owner simply waits for these messages in an unconditional loop. It identifies the robots by the robot ids that are sent as parts of the messages. The owner simply prints every movement:
)

---
    while (true) {
        auto message = receiveOnly!$(HILITE MovementMessage)();

        writefln("%s %s",
                 robots[message.robotId], message.movement);
    }
---

$(P
All of the messages in this simple program go from the worker to the owner. Message passing normally involves more complicated communication in many kinds of programs.
)

$(P
Here is the complete program:
)

---
import std.stdio;
import std.random;
import std.string;
import std.concurrency;
import core.thread;

struct Position {
    int line;
    int column;

    string toString() {
        return format("%s,%s", line, column);
    }
}

struct Movement {
    Position from;
    Position to;

    string toString() {
        return ((from == to)
                ? format("%s (idle)", from)
                : format("%s -> %s", from, to));
    }
}

class Robot {
    string image;
    Duration restDuration;

    this(string image, Duration restDuration) {
        this.image = image;
        this.restDuration = restDuration;
    }

    override string toString() {
        return format("%s(%s)", image, restDuration);
    }
}

/* Returns a random position around 0,0. */
Position randomPosition() {
    return Position(uniform!"[]"(-10, 10),
                    uniform!"[]"(-10, 10));
}

/* Returns at most one step from the specified coordinate. */
int randomStep(int current) {
    return current + uniform!"[]"(-1, 1);
}

/* Returns a neighbor of the specified Position. It may be one
 * of the neighbors at eight directions, or the specified
 * position itself. */
Position randomNeighbor(Position position) {
    return Position(randomStep(position.line),
                    randomStep(position.column));
}

struct Job {
    size_t robotId;
    Position origin;
    Duration restDuration;
}

struct MovementMessage {
    size_t robotId;
    Movement movement;
}

void robotMover(Job job) {
    Position from = job.origin;

    while (true) {
        Thread.sleep(job.restDuration);

        Position to = randomNeighbor(from);
        Movement movement = Movement(from, to);
        from = to;

        ownerTid.send(MovementMessage(job.robotId, movement));
    }
}

void main() {
    /* Robots with various restDurations. */
    Robot[] robots = [ new Robot("A",  600.msecs),
                       new Robot("B", 2000.msecs),
                       new Robot("C", 5000.msecs) ];

    /* Start a mover thread for each robot. */
    foreach (robotId, robot; robots) {
        spawn(&robotMover, Job(robotId,
                               randomPosition(),
                               robot.restDuration));
    }

    /* Ready to collect information about the movements of the
     * robots. */
    while (true) {
        auto message = receiveOnly!MovementMessage();

        /* Print the movement of this robot. */
        writefln("%s %s",
                 robots[message.robotId], message.movement);
    }
}
---

$(P
The program prints every movement until terminated:
)

$(SHELL
A(600 ms) 6,2 -> 7,3
A(600 ms) 7,3 -> 8,3
A(600 ms) 8,3 -> 7,3
B(2 secs) -7,-4 -> -6,-3
A(600 ms) 7,3 -> 6,2
A(600 ms) 6,2 -> 7,1
A(600 ms) 7,1 (idle)
B(2 secs) -6,-3 (idle)
A(600 ms) 7,1 -> 7,2
A(600 ms) 7,2 -> 7,3
C(5 secs) -4,-4 -> -3,-5
A(600 ms) 7,3 -> 6,4
...
)

$(P
This program demonstrates how helpful message passing concurrency can be: Movements of robots are calculated independently by separate threads without knowledge of each other. It is the owner thread that $(I serializes) the printing process simply by receiving messages from its message box one by one.
)

$(H5 $(IX delegate, message passing) Expecting different types of messages)

$(P
$(C receiveOnly()) can expect only one type of message. $(C receive()) on the other hand can wait for more than one type of message. It dispatches messages to message handling delegates. When a message arrives, it is compared to the message type of each delegate. The delegate that matches the type of the particular message handles it.
)

$(P
For example, the following $(C receive()) call specifies two message handlers that handle messages of types $(C int) and $(C string), respectively:
)

---
$(CODE_NAME workerFunc)void workerFunc() {
    bool isDone = false;

    while (!isDone) {
        void intHandler($(HILITE int) message) {
            writeln("handling int message: ", message);

            if (message == -1) {
                writeln("exiting");
                isDone = true;
            }
        }

        void stringHandler($(HILITE string) message) {
            writeln("handling string message: ", message);
        }

        receive($(HILITE &intHandler), $(HILITE &stringHandler));
    }
}
---

$(P
Messages of type $(C int) would match $(C intHandler()) and messages of type $(C string) would match $(C stringHandler()). The worker thread above can be tested by the following program:
)

---
$(CODE_XREF workerFunc)import std.stdio;
import std.concurrency;

// ...

void main() {
    auto worker = spawn(&workerFunc);

    worker.send(10);
    worker.send(42);
    worker.send("hello");
    worker.send(-1);        // ← to terminate the worker
}
---

$(P
The output of the program indicates that the messages are handled by matching functions on the receiver's side:
)

$(SHELL
handling int message: 10
handling int message: 42
handling string message: hello
handling int message: -1
exiting
)

$(P
Lambda functions and objects of types that define the $(C opCall()) member function can also be passed to $(C receive()) as message handlers. The following worker handles messages by lambda functions. The following program also defines a special type named $(C Exit) used for communicating to the thread that it is time for it to exit. Using such a specific type is more expressive than sending the arbitrary value of -1 like it was done in the previous example.
)

$(P
There are three anonymous functions below that are passed to $(C receive()) as message handlers. Their curly brackets are highlighted:
)

---
import std.stdio;
import std.concurrency;

struct Exit {
}

void workerFunc() {
    bool isDone = false;

    while (!isDone) {
        receive(
            (int message) $(HILITE {)
                writeln("int message: ", message);
            $(HILITE }),

            (string message) $(HILITE {)
                writeln("string message: ", message);
            $(HILITE }),

            (Exit message) $(HILITE {)
                writeln("exiting");
                isDone = true;
            $(HILITE }));
    }
}

void main() {
    auto worker = spawn(&workerFunc);

    worker.send(10);
    worker.send(42);
    worker.send("hello");
    worker.send($(HILITE Exit()));
}
---

$(H6 Receiving any type of message)

$(P
$(IX Variant, concurrency) $(C std.variant.Variant) is a type that can encapsulate any type of data. Messages that do not match the handlers that are specified earlier in the argument list always match a $(C Variant) handler:
)

---
import std.stdio;
import std.concurrency;

void workerFunc() {
    receive(
        (int message) { /* ... */ },

        (double message) { /* ... */ },

        ($(HILITE Variant) message) {
            writeln("Unexpected message: ", message);
        });
}

struct SpecialMessage {
    // ...
}

void main() {
    auto worker = spawn(&workerFunc);
    worker.send(SpecialMessage());
}
---

$(P
The output:
)

$(SHELL
Unexpected message: SpecialMessage()
)

$(P
The details of $(C Variant) are outside of the scope of this chapter.
)

$(H5 $(IX receiveTimeout) Waiting for messages up to a certain time)

$(P
It may not make sense to wait for messages beyond a certain time. The sender may have been busy temporarily or may have terminated with an exception. $(C receiveTimeout()) prevents blocking the receiving thread indefinitely.
)

$(P
The first parameter of $(C receiveTimeout()) determines how long the message should be waited for. Its return value is $(C true) if a message has been received within that time, $(C false) otherwise.
)

---
import std.stdio;
import std.concurrency;
import core.thread;

void workerFunc() {
    Thread.sleep(3.seconds);
    ownerTid.send("hello");
}

void main() {
    spawn(&workerFunc);

    writeln("Waiting for a message");
    bool received = false;
    while (!received) {
        received = $(HILITE receiveTimeout)(600.msecs,
                                  (string message) {
                                      writeln("received: ", message);
                                });

        if (!received) {
            writeln("... no message yet");

            /* ... other operations may be executed here ... */
        }
    }
}
---

$(P
The owner above waits for a message for up to 600 milliseconds. It can continue working on other things if a message does not arrive within that time:
)

$(SHELL
Waiting for a message
... no message yet
... no message yet
... no message yet
... no message yet
received: hello
)

$(H5 $(IX exception, concurrency) Exceptions during the execution of the worker)

$(P
As we have seen in the previous chapter, the facilities of the $(C std.parallelism) module automatically catch exceptions that have been thrown during the execution of tasks and rethrow them in the context of the owner. This allows the owner to catch such exceptions:
)

---
    try {
        theTask.yieldForce();

    } catch (Exception exc) {
        writefln("Detected an error in the task: '%s'",
                 exc.msg);
    }
---

$(P
$(C std.concurrency) does not provide such a convenience for general exception types. However, the exceptions can be caught and sent explicitly by the worker. As we will see below, it is also possible to receive $(C OwnerTerminated) and $(C LinkTerminated) exceptions as messages.
)

$(P
The $(C calculate()) function below receives $(C string) messages, converts them to $(C double), adds 0.5, and sends the result back as a message:
)

---
$(CODE_NAME calculate)void calculate() {
    while (true) {
        auto message = receiveOnly!string();
        ownerTid.send(to!double(message) + 0.5);
    }
}
---

$(P
The $(C to!double()) call above would throw an exception if the string cannot be converted to a $(C double) value. Because such an exception would terminate the worker thread right away, the owner in the following program can receive a response only for the first message:
)

---
$(CODE_XREF calculate)import std.stdio;
import std.concurrency;
import std.conv;

// ...

void main() {
    Tid calculator = spawn(&calculate);

    calculator.send("1.2");
    calculator.send("hello");  // ← incorrect input
    calculator.send("3.4");

    foreach (i; 0 .. 3) {
        auto message = receiveOnly!double();
        writefln("result %s: %s", i, message);
    }
}
---

$(P
The owner receives the response for "1.2" as 1.7 but because the worker has been terminated, the owner would be blocked waiting for a message that would never arrive:
)

$(SHELL
result 0: 1.7
                 $(SHELL_NOTE waiting for a message that will never arrive)
)

$(P
One thing that the worker can do is to catch the exception explicitly and to send it as a special error message. The following program sends the reason of the failure as a $(C CalculationFailure) message. Additionally, this program takes advantage of a special message type to signal to the worker when it is time to exit:
)

---
import std.stdio;
import std.concurrency;
import std.conv;

struct CalculationFailure {
    string reason;
}

struct Exit {
}

void calculate() {
    bool isDone = false;

    while (!isDone) {
        receive(
            (string message) {
                try {
                    ownerTid.send(to!double(message) + 0.5);

                } $(HILITE catch) (Exception exc) {
                    ownerTid.send(CalculationFailure(exc.msg));
                }
            },

            (Exit message) {
                isDone = true;
            });
    }
}

void main() {
    Tid calculator = spawn(&calculate);

    calculator.send("1.2");
    calculator.send("hello");  // ← incorrect input
    calculator.send("3.4");
    calculator.send(Exit());

    foreach (i; 0 .. 3) {
        writef("result %s: ", i);

        receive(
            (double message) {
                writeln(message);
            },

            (CalculationFailure message) {
                writefln("ERROR! '%s'", message.reason);
            });
    }
}
---

$(P
This time the reason of the failure is printed by the owner:
)

$(SHELL
result 0: 1.7
result 1: ERROR! 'no digits seen'
result 2: 3.9
)

$(P
Another method would be to send the actual exception object itself to the owner. The owner can use the exception object or simply rethrow it:
)

---
// ... at the worker ...
                try {
                    // ...

                } catch ($(HILITE shared(Exception)) exc) {
                    ownerTid.send(exc);
                }},

// ... at the owner ...
        receive(
            // ...

            ($(HILITE shared(Exception)) exc) {
                throw exc;
            });
---

$(P
The reason why the $(C shared) specifiers are necessary is explained in the next chapter.
)

$(H5 Detecting thread termination)

$(P
Threads can detect that the receiver of a message has terminated.
)

$(H6 $(IX OwnerTerminated) $(C OwnerTerminated) exception)

$(P
This exception is thrown when receiving a message from the owner if the owner has been terminated. The intermediate owner thread below simply exits after sending two messages to its worker. This causes an $(C OwnerTerminated) exception to be thrown at the worker thread:
)

---
import std.stdio;
import std.concurrency;

void main() {
    spawn(&intermediaryFunc);
}

void intermediaryFunc() {
    auto worker = spawn(&workerFunc);
    worker.send(1);
    worker.send(2);
}  // ← Terminates after sending two messages

void workerFunc() {
    while (true) {
        auto m = receiveOnly!int(); // ← An exception is
                                    //   thrown if the owner
                                    //   has terminated.
        writeln("Message: ", m);
    }
}
---

$(P
The output:
)

$(SHELL
Message: 1
Message: 2
std.concurrency.$(HILITE OwnerTerminated)@std/concurrency.d(248):
Owner terminated
)

$(P
The worker can catch that exception to exit gracefully:
)

---
void workerFunc() {
    bool isDone = false;

    while (!isDone) {
        try {
            auto m = receiveOnly!int();
            writeln("Message: ", m);

        } catch ($(HILITE OwnerTerminated) exc) {
            writeln("The owner has terminated.");
            isDone = true;
        }
    }
}
---

$(P
The output:
)

$(SHELL
Message: 1
Message: 2
The owner has terminated.
)

$(P
We will see below that this exception can be received as a message as well.
)

$(H6 $(IX LinkTerminated) $(IX spawnLinked) $(C LinkTerminated) exception)

$(P
$(C spawnLinked()) is used in the same way as $(C spawn()). When a worker that has been started by $(C spawnLinked()) terminates, a $(C LinkTerminated) exception is thrown at the owner:
)

---
import std.stdio;
import std.concurrency;

void main() {
    auto worker = $(HILITE spawnLinked)(&workerFunc);

    while (true) {
        auto m = receiveOnly!int(); // ← An exception is
                                    //   thrown if the worker
                                    //   has terminated.
        writeln("Message: ", m);
    }
}

void workerFunc() {
    ownerTid.send(10);
    ownerTid.send(20);
}  // ← Terminates after sending two messages
---

$(P
The worker above terminates after sending two messages. Since the worker has been started by $(C spawnLinked()), the owner is notified of the worker's termination by a $(C LinkTerminated) exception:
)

$(SHELL
Message: 10
Message: 20
std.concurrency.$(HILITE LinkTerminated)@std/concurrency.d(263):
Link terminated
)

$(P
The owner can catch the exception to do something special like terminating gracefully:
)

---
    bool isDone = false;

    while (!isDone) {
        try {
            auto m = receiveOnly!int();
            writeln("Message: ", m);

        } catch ($(HILITE LinkTerminated) exc) {
            writeln("The worker has terminated.");
            isDone = true;
        }
    }
---

$(P
The output:
)

$(SHELL
Message: 10
Message: 20
The worker has terminated.
)

$(P
This exception can be received as a message as well.
)

$(H6 Receiving exceptions as messages)

$(P
The $(C OwnerTerminated) and $(C LinkTerminated) exceptions can be received as messages as well. The following code demonstrates this for the $(C OwnerTerminated) exception:
)

---
    bool isDone = false;

    while (!isDone) {
        receive(
            (int message) {
                writeln("Message: ", message);
            },

            ($(HILITE OwnerTerminated exc)) {
                writeln("The owner has terminated; exiting.");
                isDone = true;
            }
        );
    }
---

$(H5 Mailbox management)

$(P
Every thread has a private mailbox that holds the messages that are sent to that thread. The number of messages in a mailbox may increase or decrease depending on how long it takes for the thread to receive and respond to each message. A continuously growing mailbox puts stress on the entire system and may point to a design flaw in the program. It may also mean that the thread may never get to the most recent messages.
)

$(P
$(IX setMaxMailboxSize) $(C setMaxMailboxSize()) is used for limiting the number of messages that a mailbox can hold. Its three parameters specify the mailbox, the maximum number of messages that it can hold, and what should happen when the mailbox is full, in that order. There are four choices for the last parameter:
)

$(UL

$(LI $(IX OnCrowding) $(C OnCrowding.block): The sender waits until there is room in the mailbox.)

$(LI $(C OnCrowding.ignore): The message is discarded.)

$(LI $(IX MailboxFull) $(C OnCrowding.throwException): A $(C MailboxFull) exception is thrown when sending the message.)

$(LI A function pointer of type $(C bool function(Tid)): The specified function is called.)

)

$(P
Before seeing an example of $(C setMaxMailboxSize()), let's first cause a mailbox to grow continuously. The worker in the following program sends messages back to back but the owner spends some time for each message:
)

---
/* WARNING: Your system may become unresponsive when this
 *          program is running. */
import std.concurrency;
import core.thread;

void workerFunc() {
    while (true) {
        ownerTid.send(42);    // ← Produces messages continuously
    }
}

void main() {
    spawn(&workerFunc);

    while (true) {
        receive(
            (int message) {
                // Spends time for each message
                Thread.sleep(1.seconds);
            });
    }
}
---

$(P
Because the consumer is slower than the producer, the memory that the program above uses would grow continuously. To prevent that, the owner may limit the size of its mailbox before starting the worker:
)

---
void $(CODE_DONT_TEST)main() {
    setMaxMailboxSize(thisTid, 1000, OnCrowding.block);

    spawn(&workerFunc);
// ...
}
---

$(P
The $(C setMaxMailboxSize()) call above sets the main thread's mailbox size to 1000. $(C OnCrowding.block) causes the sender to wait until there is room in the mailbox.
)

$(P
The following example uses $(C OnCrowding.throwException), which causes a $(C MailboxFull) exception to be thrown when sending a message to a mailbox that is full:
)

---
import std.concurrency;
import core.thread;

void workerFunc() {
    while (true) {
        try {
            ownerTid.send(42);

        } catch ($(HILITE MailboxFull) exc) {
            /* Failed to send; will try again later. */
            Thread.sleep(1.msecs);
        }
    }
}

void main() {
    setMaxMailboxSize(thisTid, 1000, $(HILITE OnCrowding.throwException));

    spawn(&workerFunc);

    while (true) {
        receive(
            (int message) {
                Thread.sleep(1.seconds);
            });
    }
}
---

$(H5 $(IX prioritySend) $(IX PriorityMessageException) Priority messages)

$(P
Messages can be sent with higher priority than regular messages by $(C prioritySend()). These messages are handled before the other messages that are already in the mailbox:
)

---
    prioritySend(ownerTid, ImportantMessage(100));
---

$(P
If the receiver does not have a message handler that matches the type of the priority message, then a $(C PriorityMessageException) is thrown:
)

$(SHELL
std.concurrency.$(HILITE PriorityMessageException)@std/concurrency.d(280):
Priority message
)

$(H5 Thread names)

$(P
In the simple programs that we have used above, it was easy to pass the thread ids of owners and workers. Passing thread ids from thread to thread may be overly complicated in programs that use more than a couple of threads. To reduce this complexity, it is possible to assign names to threads, which are globally accessible from any thread.
)

$(P
The following three functions define an interface to an associative array that every thread has access to:
)

$(UL

$(LI $(IX register, concurrency) $(C register()): Associates a thread with a name.)

$(LI $(IX locate) $(C locate()): Returns the thread that is associated with the specified name. If there is no thread associated with that name, then $(C Tid.init) is returned.)

$(LI $(IX unregister) $(C unregister()): Breaks the association between the specified name and the thread.)

)

$(P
The following program starts two threads that find each other by their names. These threads continuously send messages to each other until instructed to terminate by an $(C Exit) message:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

struct Exit {
}

void main() {
    // A thread whose partner is named "second"
    auto first = spawn(&player, "second");
    $(HILITE register)("first", first);
    scope(exit) $(HILITE unregister)("first");

    // A thread whose partner is named "first"
    auto second = spawn(&player, "first");
    $(HILITE register)("second", second);
    scope(exit) $(HILITE unregister)("second");

    Thread.sleep(2.seconds);

    prioritySend(first, Exit());
    prioritySend(second, Exit());

    // For the unregister() calls to succeed, main() must wait
    // until the workers terminate.
    thread_joinAll();
}

void player(string nameOfPartner) {
    Tid partner;

    while (partner == Tid.init) {
        Thread.sleep(1.msecs);
        partner = $(HILITE locate)(nameOfPartner);
    }

    bool isDone = false;

    while (!isDone) {
        partner.send("hello " ~ nameOfPartner);
        receive(
            (string message) {
                writeln("Message: ", message);
                Thread.sleep(500.msecs);
            },

            (Exit message) {
                writefln("%s, I am exiting.", nameOfPartner);
                isDone = true;
            });
    }
}
---

$(P
$(IX thread_joinAll) The $(C thread_joinAll()) call that is seen at the end of $(C main()) is for making the owner to wait for all of its workers to terminate.
)

$(P
The output:
)

$(SHELL
Message: hello second
Message: hello first
Message: hello second
Message: hello first
Message: hello first
Message: hello second
Message: hello first
Message: hello second
second, I am exiting.
first, I am exiting.
)

$(H5 Summary)

$(UL

$(LI When threads do not depend on other threads, prefer $(I parallelism), which has been the topic of the previous chapter. Consider $(I concurrency) only when threads depend on operations of other threads.)

$(LI Because concurrency by data sharing is hard to implement correctly, prefer concurrency by message passing, which is the subject of this chapter.)

$(LI $(C spawn()) and $(C spawnLinked()) start threads.)

$(LI $(C thisTid) is the thread id of the current thread.)

$(LI $(C ownerTid) is the thread id of the owner of the current thread.)

$(LI $(C send()) and $(C prioritySend()) send messages.)

$(LI $(C receiveOnly()), $(C receive()), and $(C receiveTimeout()) wait for messages.)

$(LI $(C Variant) matches any type of message.)

$(LI $(C setMaxMailboxSize()) limits the size of mailboxes.)

$(LI $(C register()), $(C unregister()), and $(C locate()) allow referring to threads by name.)

$(LI Exceptions may be thrown during message passing: $(C MessageMismatch), $(C OwnerTerminated), $(C LinkTerminated), $(C MailboxFull), and $(C PriorityMessageException).)

$(LI The owner cannot automatically catch exceptions that are thrown from the worker.)

)

macros:
        TITLE=Message Passing Concurrency

        DESCRIPTION=Starting multiple threads in the D programming language and the interactions of threads by message passing.

        KEYWORDS=d programming language tutorial book concurrency thread

MINI_SOZLUK=
