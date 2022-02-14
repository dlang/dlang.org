Ddoc

$(DERS_BOLUMU $(IX data sharing concurrency) $(IX concurrency, data sharing) Data Sharing Concurrency)

$(P
The previous chapter was about threads sharing information through message passing. As it has been mentioned in that chapter, message passing is a safe method of concurrency.
)

$(P
Another method involves more than one thread reading from and writing to the same data. For example, the owner thread can start the worker with the address of a $(C bool) variable and the worker can determine whether to terminate or not by reading the current value of that variable. Another example would be where the owner starts multiple workers with the address of the same variable so that the variable gets modified by more than one worker.
)

$(P
One of the reasons why data sharing is not safe is $(I race conditions). A race condition occurs when more than one thread accesses the same mutable data in an uncontrolled order. Since the operating system pauses and starts individual threads in unspecified ways, the behavior of a program that has race conditions is unpredictable.
)

$(P
The examples in this chapter may look simplistic. However, the issues that they convey appear in real programs at greater scales. Also, although these examples use the $(C std.concurrency) module, the concepts of this chapter apply to the $(C core.thread) module as well.
)

$(H5 Sharing is not automatic)

$(P
Unlike most other programming languages, data is not automatically shared in D; data is thread-local by default. Although module-level variables may give the impression of being accessible by all threads, each thread actually gets its own copy:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

int $(HILITE variable);

void printInfo(string message) {
    writefln("%s: %s (@%s)", message, variable, &variable);
}

void worker() {
    variable = $(HILITE 42);
    printInfo("Before the worker is terminated");
}

void main() {
    spawn(&worker);
    thread_joinAll();
    printInfo("After the worker is terminated");
}
---

$(P
$(C variable) that is modified inside $(C worker()) is not the same $(C variable) that is seen by $(C main()). This fact can be observed by printing both the values and the addresses of the variables:
)

$(SHELL
Before the worker is terminated: 42 (@7F26C6711670)
After the worker is terminated: 0 (@7F26C68127D0)
)

$(P
Since each thread gets its own copy of data, $(C spawn()) does not allow passing references to thread-local variables. For example, the following program that tries to pass the address of a $(C bool) variable to another thread cannot be compiled:
)

---
import std.concurrency;

void worker($(HILITE bool * isDone)) {
    while (!(*isDone)) {
        // ...
    }
}

void main() {
    bool isDone = false;
    spawn(&worker, $(HILITE &isDone));      $(DERLEME_HATASI)

    // ...

    // Hoping to signal the worker to terminate:
    isDone = true;

    // ...
}
---

$(P
A $(C static assert) inside the $(C std.concurrency) module prevents accessing $(I mutable) data from another thread:
)

$(SHELL
src/phobos/std/concurrency.d(329): Error: static assert
"Aliases to $(HILITE mutable thread-local data) not allowed."
)

$(P
The address of the mutable variable $(C isDone) cannot be passed between threads.
)

$(P
$(IX __gshared) An exception to this rule is a variable that is defined as $(C __gshared):
)

---
__gshared int globallyShared;
---

$(P
There is only one copy of such a variable in the entire program and all threads can share that variable. $(C __gshared) is necessary when interacting with libraries of languages like C and C++ where data sharing is automatic by default.
)

$(H5 $(IX shared) $(C shared) to share mutable data between threads)

$(P
Mutable variables that need to be shared must be defined with the $(C shared) keyword:
)

---
import std.concurrency;

void worker($(HILITE shared(bool)) * isDone) {
    while (*isDone) {
        // ...
    }
}

void main() {
    $(HILITE shared(bool)) isDone = false;
    spawn(&worker, &isDone);

    // ...

    // Signalling the worker to terminate:
    isDone = true;

    // ...
}
---

$(P
$(I $(B Note:) Prefer message-passing to signal a thread.)
)

$(P
$(IX immutable, concurrency) On the other hand, since $(C immutable) variables cannot be modified, there is no problem with sharing them directly. For that reason, $(C immutable) implies $(C shared):
)

---
import std.stdio;
import std.concurrency;
import core.thread;

void worker($(HILITE immutable(int)) * data) {
    writeln("data: ", *data);
}

void main() {
    $(HILITE immutable(int)) i = 42;
    spawn(&worker, &i);         // ← compiles

    thread_joinAll();
}
---

$(P
The output:
)

$(SHELL
data: 42
)

$(P
Note that since the lifetime of $(C i) is defined by the scope of $(C main()), it is important that $(C main()) does not terminate before the worker thread. The call to $(C core.thread.thread_joinAll) above is to make a thread wait for all of its child threads to terminate.
)

$(H5 A race condition example)

$(P
The correctness of the program requires extra attention when mutable data is shared between threads.
)

$(P
To see an example of a race condition let's consider multiple threads sharing the same mutable variable. The threads in the following program receive the addresses as two variables and swap their values a large number of times:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

void swapper($(HILITE shared(int)) * first, $(HILITE shared(int)) * second) {
    foreach (i; 0 .. 10_000) {
        int temp = *second;
        *second = *first;
        *first = temp;
    }
}

void main() {
    $(HILITE shared(int)) i = 1;
    $(HILITE shared(int)) j = 2;

    writefln("before: %s and %s", i, j);

    foreach (id; 0 .. 10) {
        spawn(&swapper, &i, &j);
    }

    // Wait for all threads to finish their tasks
    thread_joinAll();

    writefln("after : %s and %s", i, j);
}
---

$(P
Although the program above gets compiled successfully, in most cases it would work incorrectly. Observe that it starts ten threads that all access the same two variables $(C i) and $(C j). As a result of the $(I race conditions) that they are in, they inadvertently spoil the operations of other threads.
)

$(P
Also observe that total number of swaps is 10 times 10 thousand. Since that amount is an even number, it is natural to expect that the variables end up having values 1 and 2, their initial values:
)

$(SHELL
before: 1 and 2
after : 1 and 2    $(SHELL_NOTE expected result)
)

$(P
Although it is possible that the program can indeed produce that result, most of the time the actual outcome would be one of the following:
)

$(SHELL
before: 1 and 2
after : 1 and 1    $(SHELL_NOTE_WRONG incorrect result)
)

$(SHELL
before: 1 and 2
after : 2 and 2    $(SHELL_NOTE_WRONG incorrect result)
)

$(P
It is possible but highly unlikely that the result may even end up being "2 and 1" as well.
)

$(P
The reason why the program works incorrectly can be explained by the following scenario between just two threads that are in a race condition. As the operating system pauses and restarts the threads at indeterminate times, the following order of execution of the operations of the two threads is likely as well.
)

$(P
Let's consider the state where $(C i) is 1 and $(C j) is 2. Although the two threads execute the same $(C swapper()) function, remember that the local variable $(C temp) is separate for each thread and it is independent from the other $(C temp) variables of other threads. To identify those separate variables, they are renamed as $(C tempA) and $(C tempB) below.
)

$(P
The chart below demonstrates how the 3-line code inside the $(C for) loop may be executed by each thread over time, from top to bottom, operation 1 being the first operation and operation 6 being the last operation. Whether $(C i) or $(C j) is modified at each step is indicated by highlighting that variable:
)

$(MONO
$(B Operation        Thread A                             Thread B)
────────────────────────────────────────────────────────────────────────────

  1:   int temp = *second; (tempA==2)
  2:   *second = *first;   (i==1, $(HILITE j==1))

          $(I (Assume that A is paused and B is started at this point))

  3:                                        int temp = *second; (tempB==1)
  4:                                        *second = *first;   (i==1, $(HILITE j==1))

          $(I (Assume that B is paused and A is restarted at this point))

  5:   *first = temp;    ($(HILITE i==2), j==1)

          $(I (Assume that A is paused and B is restarted at this point))

  6:                                        *first = temp;    ($(HILITE i==1), j==1)
)

$(P
As can be seen, at the end of the previous scenario both $(C i) and $(C j) end up having the value 1. It is not possible that they can ever have any other value after that point.
)

$(P
The scenario above is just one example that is sufficient to explain the incorrect results of the program. Obviously, the race conditions would be much more complicated in the case of the ten threads of this example.
)

$(H5 $(IX synchronized) $(C synchronized) to avoid race conditions)

$(P
The incorrect program behavior above is due to more than one thread accessing the same mutable data (and at least one of them modifying it). One way of avoiding these race conditions is to mark the common code with the $(C synchronized) keyword. The program would work correctly with the following change:
)

---
    foreach (i; 0 .. 10_000) {
        $(HILITE synchronized {)
            int temp = *b;
            *b = *a;
            *a = temp;
        $(HILITE })
    }
---

$(P
The output:
)

$(SHELL
before: 1 and 2
after : 1 and 2      $(SHELL_NOTE correct result)
)

$(P
$(IX lock) The effect of $(C synchronized) is to create a lock behind the scenes and to allow only one thread hold that lock at a given time. Only the thread that holds the lock can be executed and the others wait until the lock becomes available again when the executing thread completes its $(C synchronized) block. Since one thread executes the $(I synchronized) code at a time, each thread would now swap the values safely before another thread does the same. The state of the variables $(C i) and $(C j) would always be either "1 and 2" or "2 and 1" at the end of processing the synchronized block.
)

$(P
$(I $(B Note:) It is a relatively expensive operation for a thread to wait for a lock, which may slow down the execution of the program noticeably. Fortunately, in some cases program correctness can be ensured without the use of a $(C synchronized) block, by taking advantage of $(I atomic operations) that will be explained below.)
)

$(P
When it is needed to synchronize more than one block of code, it is possible to specify one or more locks with the $(C synchronized) keyword.
)

$(P
Let's see an example of this in the following program that has two separate code blocks that access the same shared variable. The program calls two functions with the address of the same variable, one function incrementing and the other function decrementing it equal number of times:
)

---
void incrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        *value = *value + 1;
    }
}

void decrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        *value = *value - 1;
    }
}
---

$(P
$(I $(B Note:) If the shorter equivalents of the expression above are used (i.e. $(C ++(*value)) and $(C &#8209;&#8209;(*value))), then the compiler warns that such read-modify-write operations on $(C shared) variables are deprecated.)
)

$(P
Unfortunately, marking those blocks individually with $(C synchronized) is not sufficient, because the anonymous locks of the two blocks would be independent. So, the two code blocks would still be accessing the same variable concurrently:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

enum count = 1000;

void incrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        $(HILITE synchronized) { // ← This lock is different from the one below.
            *value = *value + 1;
        }
    }
}

void decrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        $(HILITE synchronized) { // ← This lock is different from the one above.
            *value = *value - 1;
        }
    }
}

void main() {
    shared(int) number = 0;

    foreach (i; 0 .. 100) {
        spawn(&incrementer, &number);
        spawn(&decrementer, &number);
    }

    thread_joinAll();
    writeln("Final value: ", number);
}
---

$(P
Since there are equal number of threads that increment and decrement the same variable equal number of times, one would expect the final value of $(C number) to be zero. However, that is almost never the case:
)

$(SHELL
Final value: -672    $(SHELL_NOTE_WRONG not zero)
)

$(P
For more than one block to use the same lock or locks, the lock objects must be specified within the $(C synchronized) parentheses:
)

$(P
$(HILITE $(I $(B Note:) This feature is not supported by dmd $(DVER).))
)

---
    $(CODE_COMMENT Note: dmd $(DVER) does not support this feature.)
    synchronized ($(I lock_object), $(I another_lock_object), ...)
---

$(P
There is no need for a special lock type in D because any class object can be used as a $(C synchronized) lock. The following program defines an empty class named $(C Lock) to use its objects as locks:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

enum count = 1000;

$(HILITE class Lock {
})

void incrementer(shared(int) * value, $(HILITE shared(Lock) lock)) {
    foreach (i; 0 .. count) {
        synchronized $(HILITE (lock)) {
            *value = *value + 1;
        }
    }
}

void decrementer(shared(int) * value, $(HILITE shared(Lock) lock)) {
    foreach (i; 0 .. count) {
        synchronized $(HILITE (lock)) {
            *value = *value - 1;
        }
    }
}

void main() {
    $(HILITE shared(Lock) lock = new shared(Lock)());
    shared(int) number = 0;

    foreach (i; 0 .. 100) {
        spawn(&incrementer, &number, $(HILITE lock));
        spawn(&decrementer, &number, $(HILITE lock));
    }

    thread_joinAll();
    writeln("Final value: ", number);
}
---

$(P
Because this time both $(C synchronized) blocks are connected by the same lock, only one of them is executed at a given time and the result is zero as expected:
)

$(SHELL
Final value: 0       $(SHELL_NOTE correct result)
)

$(P
Class types can be defined as $(C synchronized) as well. This means that all of the non-static member functions of that type are synchronized on a given object of that class:
)

---
$(HILITE synchronized) class Class {
    void foo() {
        // ...
    }

    void bar() {
        // ...
    }
}
---

$(P
The following is the equivalent of the class definition above:
)

---
class Class {
    void foo() {
        synchronized (this) {
            // ...
        }
    }

    void bar() {
        synchronized (this) {
            // ...
        }
    }
}
---

$(P
When blocks of code need to be synchronized on more than one object, those objects must be specified together. Otherwise, it is possible that more than one thread may have locked objects that other threads are waiting for, in which case the program may be $(I deadlocked).
)

$(P
A well known example of this problem is a function that tries to transfer money from one bank account to another. For this function to work correctly in a multi-threaded environment, both of the accounts must first be locked. However, the following attempt would be incorrect:
)

---
void transferMoney(shared BankAccount from,
                   shared BankAccount to) {
    synchronized (from) {           $(CODE_NOTE_WRONG INCORRECT)
        synchronized (to) {
            // ...
        }
    }
}
---

$(P
$(IX deadlock) The error can be explained by an example where one thread attempting to transfer money from account A to account to B while another thread attempting to transfer money in the reverse direction. It is possible that each thread may have just locked its respective $(C from) object, hoping next to lock its $(C to) object. Since the $(C from) objects correspond to A and B in the two threads respectively, the objects would be in locked state in separate threads, making it impossible for the other thread to ever lock its $(C to) object. This situation is called a $(I deadlock).
)

$(P
The solution to this problem is to define an ordering relation between the objects and to lock them in that order, which is handled automatically by the $(C synchronized) statement. In D, it is sufficient to specify the objects in the same $(C synchronized) statement for the code to avoid such deadlocks:
)

$(P
$(HILITE $(I $(B Note:) This feature is not supported by dmd $(DVER).))
)

---
void transferMoney(shared BankAccount from,
                   shared BankAccount to) {
    $(CODE_COMMENT Note: dmd $(DVER) does not support this feature.)
    synchronized (from, to) {       $(CODE_NOTE correct)
        // ...
    }
}
---

$(H5 $(IX shared static this) $(IX static this, shared) $(IX shared static ~this) $(IX static ~this, shared) $(IX this, shared static) $(IX ~this, shared static) $(IX module constructor, shared) $(C shared static this()) for single initialization and $(C shared static ~this()) for single finalization)

$(P
We have already seen that $(C static this()) can be used for initializing modules, including their variables. Because data is thread-local by default, $(C static this()) must be executed by every thread so that module-level variables are initialized for all threads:
)

---
import std.stdio;
import std.concurrency;
import core.thread;

static this() {
    writeln("executing static this()");
}

void worker() {
}

void main() {
    spawn(&worker);

    thread_joinAll();
}
---

$(P
The $(C static this()) block above would be executed once for the main thread and once for the worker thread:
)

$(SHELL
executing static this()
executing static this()
)

$(P
This would cause problems for $(C shared) module variables because initializing a variable more than once would be wrong especially in concurrency due to race conditions. (That applies to $(C immutable) variables as well because they are implicitly $(C shared).) The solution is to use $(C shared static this()) blocks, which are executed only once per program:
)

---
int a;              // thread-local
immutable int b;    // shared by all threads

static this() {
    writeln("Initializing per-thread variable at ", &a);
    a = 42;
}

$(HILITE shared) static this() {
    writeln("Initializing per-program variable at ", &b);
    b = 43;
}
---

$(P
The output:
)

$(SHELL
Initializing per-program variable at 6B0120    $(SHELL_NOTE only once)
Initializing per-thread variable at 7FBDB36557D0
Initializing per-thread variable at 7FBDB3554670
)

$(P
Similarly, $(C shared static ~this()) is for final operations that must be executed only once per program.
)

$(H5 $(IX atomic operation) Atomic operations)

$(P
Another way of ensuring that only one thread mutates a certain variable is by using atomic operations, functionality of which are provided by the microprocessor, the compiler, or the operating system.
)

$(P
The atomic operations of D are in the $(C core.atomic) module. We will see only two of its functions in this chapter:
)

$(H6 $(IX atomicOp, core.atomic) $(C atomicOp))

$(P
This function applies its template parameter to its two function parameters. The template parameter must be a $(I binary operator) like $(STRING "+"), $(STRING "+="), etc.
)

---
import core.atomic;

// ...

        atomicOp!"+="(*value, 1);    // atomic
---

$(P
The line above is the equivalent of the following line, with the difference that the $(C +=) operation would be executed without interruptions by other threads (i.e. it would be executed $(I atomically)):
)

---
        *value += 1;                 // NOT atomic
---

$(P
Consequently, when it is only a binary operation that needs to be synchronized, then there is no need for a $(C synchronized) block, which is known to be slow because of needing to acquire a lock. The following equivalents of the $(C incrementer()) and $(C decrementer()) functions that use $(C atomicOp) are correct as well. Note that there is no need for the $(C Lock) class anymore either:
)

---
import core.atomic;

//...

void incrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        $(HILITE atomicOp!"+="(*value, 1));
    }
}

void decrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        $(HILITE atomicOp!"-="(*value, 1));
    }
}
---

$(P
$(C atomicOp) can be used with other binary operators as well.
)

$(H6 $(IX cas, core.atomic) $(C cas))

$(P
The name of this function is the abbreviation of "compare and swap". Its behavior can be described as $(I mutate the variable if it still has its currently known value). It is used by specifying the current and the desired values of the variable at the same time:
)

---
    bool is_mutated = cas(address_of_variable, currentValue, newValue);
---

$(P
The fact that the value of the variable still equals $(C currentValue) when $(C cas()) is operating is an indication that no other thread has mutated the variable since it has last been read by this thread. If so, $(C cas()) assigns $(C newValue) to the variable and returns $(C true). On the other hand, if the variable's value is different from $(C currentValue) then $(C cas()) does not mutate the variable and returns $(C false).
)

$(P
The following functions re-read the current value and call $(C cas()) until the operation succeeds. Again, these calls can be described as $(I if the value of the variable equals this old value, replace with this new value):
)

---
void incrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        int currentValue;

        do {
            currentValue = *value;
        } while (!$(HILITE cas(value, currentValue, currentValue + 1)));
    }
}

void decrementer(shared(int) * value) {
    foreach (i; 0 .. count) {
        int currentValue;

        do {
            currentValue = *value;
        } while (!$(HILITE cas(value, currentValue, currentValue - 1)));
    }
}
---

$(P
The functions above work correctly without the need for $(C synchronized) blocks.
)

$(P
In most cases, the features of the $(C core.atomic) module can be several times faster than using $(C synchronized) blocks. I recommend that you consider this module as long as the operations that need synchronization are less than a block of code.
)

$(P
Atomic operations enable $(I lock-free data structures) as well, which are beyond the scope of this book.
)

$(P
You may also want to investigate the $(C core.sync) package, which contains classic concurrency primitives in the following modules:
)

$(UL

$(LI $(C core.sync.barrier))
$(LI $(C core.sync.condition))
$(LI $(C core.sync.config))
$(LI $(C core.sync.exception))
$(LI $(C core.sync.mutex))
$(LI $(C core.sync.rwmutex))
$(LI $(C core.sync.semaphore))

)

$(H5 Summary)

$(UL

$(LI When threads do not depend on other threads, prefer $(I parallelism). Consider $(I concurrency) only when threads depend on operations of other threads.)

$(LI Even then, prefer $(I message passing concurrency), which has been the topic of the previous chapter.)

$(LI Only $(C shared) data can be shared; $(C immutable) is implicitly $(C shared).)

$(LI $(C __gshared) provides data sharing as in C and C++ languages.)

$(LI $(C synchronized) is for preventing other threads from intervening when a thread is executing a certain piece of code.)

$(LI A class can be defined as $(C synchronized) so that only one member function can be executed on a given object at a given time. In other words, a thread can execute a member function only if no other thread is executing a member function on the same object.)

$(LI $(C static this()) is executed once for each thread; $(C shared static this()) is executed once for the entire program.)

$(LI The $(C core.atomic) module enables safe data sharing that can be multiple times faster than $(C synchronized).)

$(LI The $(C core.sync) package includes many other concurrency primitives.)

)

macros:
        TITLE=Data Sharing Concurrency

        DESCRIPTION=Executing multiple threads that share data.

        KEYWORDS=d programming language tutorial book concurrency thread data sharing
