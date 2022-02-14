Ddoc

$(DERS_BOLUMU $(IX parallelism) Parallelism)

$(P
$(IX core) Most modern microprocessors consist of more than one $(I core), each of which can operate as an individual processing unit. They can execute different parts of different programs at the same time. The features of the $(C std.parallelism) module make it possible for programs to take advantage of all of the cores in order to run faster.
)

$(P
This chapter covers the following range algorithms. These algorithms should be used only when the operations that are to be executed $(I in parallel) are truly independent from each other. $(I In parallel) means that operations are executed on multiple cores at the same time:
)

$(UL

$(LI $(C parallel): Accesses the elements of a range in parallel.)

$(LI $(C task): Creates tasks that are executed in parallel.)

$(LI $(C asyncBuf): Iterates the elements of an $(C InputRange) semi-eagerly in parallel.)

$(LI $(C map): Calls functions with the elements of an $(C InputRange) semi-eagerly in parallel.)

$(LI $(C amap): Calls functions with the elements of a $(C RandomAccessRange) fully-eagerly in parallel.)

$(LI $(C reduce): Makes calculations over the elements of a $(C RandomAccessRange) in parallel.)

)

$(P
In the programs that we have written so far we have been assuming that the expressions of a program are executed in a certain order, at least in general line-by-line:
)

---
    ++i;
    ++j;
---

$(P
In the code above, we expect that the value of $(C i) is incremented before the value of $(C j) is incremented. Although that is semantically correct, it is rarely the case in reality: microprocessors and compilers use optimization techniques to have some variables reside in microprocessor's registers that are independent from each other. When that is the case, the microprocessor would execute operations like the increments above in parallel.
)

$(P
Although these optimizations are effective, they cannot be applied automatically to layers higher than the very low-level operations. Only the programmer can determine that certain high-level operations are independent and that they can be executed in parallel.
)

$(P
In a loop, the elements of a range are normally processed one after the other, operations of each element following the operations of previous elements:
)

---
    auto students =
        [ Student(1), Student(2), Student(3), Student(4) ];

    foreach (student; students) {
        student.aSlowOperation();
    }
---

$(P
Normally, a program would be executed on one of the cores of the microprocessor, which has been assigned by the operating system to execute the program. As the $(C foreach) loop normally operates on elements one after the other, $(C aSlowOperation()) would be called for each student sequentially. However, in many cases it is not necessary for the operations of preceding students to be completed before starting the operations of successive students. If the operations on the $(C Student) objects were truly independent, it would be wasteful to ignore the other microprocessor cores, which might potentially be waiting idle on the system.
)

$(P
$(IX Thread.sleep) To simulate long-lasting operations, the following examples call $(C Thread.sleep()) from the $(C core.thread) module. $(C Thread.sleep()) suspends the operations for the specified amount of time. $(C Thread.sleep) is admittedly an artifical method to use in the following examples because it takes time without ever busying any core. Despite being an unrealistic tool, it is still useful in this chapter to demonstrate the power of parallelism.
)

---
import std.stdio;
import core.thread;

struct Student {
    int number;

    void aSlowOperation() {
        writefln("The work on student %s has begun", number);

        // Wait for a while to simulate a long-lasting operation
        Thread.sleep(1.seconds);

        writefln("The work on student %s has ended", number);
    }
}

void main() {
    auto students =
        [ Student(1), Student(2), Student(3), Student(4) ];

    foreach (student; students) {
        student.aSlowOperation();
    }
}
---

$(P
The execution time of the program can be measured in a terminal by $(C time):
)

$(SHELL
$ $(HILITE time) ./deneme
$(SHELL_OBSERVED
The work on student 1 has begun
The work on student 1 has ended
The work on student 2 has begun
The work on student 2 has ended
The work on student 3 has begun
The work on student 3 has ended
The work on student 4 has begun
The work on student 4 has ended

real    0m4.005s    $(SHELL_NOTE 4 seconds total)
user    0m0.004s
sys     0m0.000s
)
)

$(P
Since the students are iterated over in sequence and since the work of each student takes 1 second, the total execution time comes out to be 4 seconds. However, if these operations were executed in an environment that had 4 cores, they could be operated on at the same time and the total time would be reduced to about 1 second.
)

$(P
$(IX totalCPUs) Before seeing how this is done, let's first determine the number of cores that are available on the system by $(C std.parallelism.totalCPUs):
)

---
import std.stdio;
import std.parallelism;

void main() {
    writefln("There are %s cores on this system.", totalCPUs);
}
---

$(P
The output of the program in the environment that this chapter has been written is the following:
)

$(SHELL
There are 4 cores on this system.
)

$(H5 $(IX parallel) $(C taskPool.parallel()))

$(P
This function can also be called simply as $(C parallel()).
)

$(P
$(IX foreach, parallel) $(C parallel()) accesses the elements of a range in parallel. An effective usage is with $(C foreach) loops. Merely importing the $(C std.parallelism) module and replacing $(C students) with $(C parallel(students)) in the program above is sufficient to take advantage of all of the cores of the system:
)

---
import std.parallelism;
// ...
    foreach (student; $(HILITE parallel(students))) {
---

$(P
We have seen earlier in the $(LINK2 foreach_opapply.html, $(C foreach) for structs and classes chapter) that the expressions that are in $(C foreach) blocks are passed to $(C opApply()) member functions as delegates. $(C parallel()) returns a range object that knows how to distribute the execution of the $(C delegate) to a separate core for each element.
)

$(P
As a result, passing the $(C Student) range through $(C parallel()) makes the program above finish in 1 second on a system that has 4 cores:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED The work on student 2 has begun
The work on student 1 has begun
The work on student 4 has begun
The work on student 3 has begun
The work on student 1 has ended
The work on student 2 has ended
The work on student 4 has ended
The work on student 3 has ended

real    0m1.005s    $(SHELL_NOTE now only 1 second)
user    0m0.004s
sys     0m0.004s)
)

$(P
$(I $(B Note:) The execution time of the program may be different on other systems but it is expected to be roughly "4 seconds divided by the number of cores".)
)

$(P
$(IX thread) A flow of execution through certain parts of a program is called a a $(I thread of execution) or a $(I thread). Programs can consist of multiple threads that are being actively executed at the same time. The operating system starts and executes each thread on a core and then suspends it to execute other threads. The execution of each thread may involve many cycles of starting and suspending.
)

$(P
All of the threads of all of the programs that are active at a given time are executed on the very cores of the microprocessor. The operating system decides when and under what condition to start and suspend each thread. That is the reason why the messages that are printed by $(C aSlowOperation()) are in mixed order in the output above. This undeterministic order of thread execution may not matter if the operations of the $(C Student) objects are truly independent from each other.
)

$(P
It is the responsibility of the programmer to call $(C parallel()) only when the operations applied to each element are independent for each iteration. For example, if it were important that the messages appear in a certain order in the output, calling $(C parallel()) should be considered an error in the program above. The programming model that supports threads that depend on other threads is called $(I concurrency). Concurrency is the topic of the next chapter.
)

$(P
By the time parallel $(C foreach) ends, all of the operations inside the loop have been completed for all of the elements. The program can safely continue after the $(C foreach) loop.
)

$(H6 $(IX work unit size) Work unit size)

$(P
The second parameter of $(C parallel()) has an overloaded meaning and is ignored in some cases:
)

---
    /* ... */ = parallel($(I range), $(I work_unit_size) = 100);
---

$(UL

$(LI When iterating over $(C RandomAccessRange) ranges:

$(P
The distribution of threads to cores has some minimal cost. This cost may sometimes be significant especially when the operations of the loop are completed in a very short time. In such cases, it may be faster to have each thread execute more than one iteration of the loop. The work unit size determines the number of elements that each thread should execute at each of its iterations:
)

---
    foreach (student; parallel(students, $(HILITE 2))) {
        // ...
    }
---

$(P
The default value of work unit size is 100 and is suitable for most cases.
)

)

$(LI When iterating over non-$(C RandomAccessRange) ranges:

$(P
$(C parallel()) does not start parallel executions until $(I work unit size) number of elements of a non-$(C RandomAccessRange) have been executed serially first. Due to the relatively high value of 100, $(C parallel()) may give the wrong impression that it is not effective when tried on short non-$(C RandomAccessRange) ranges.
)

)

$(LI When iterating over the result ranges of $(C asyncBuf()) or parallel $(C map()) (both are explained later in this chapter):

$(P
When $(C parallel()) works on the results of $(C asyncBuf()) or $(C map()), it ignores the work unit size parameter. Instead, $(C parallel()) reuses the internal buffer of the result range.
)

)

)

$(H5 $(IX Task) $(C Task))

$(P
Operations that are executed in parallel with other operations of a program are called $(I tasks). Tasks are represented by the type $(C std.parallelism.Task).
)

$(P
In fact, $(C parallel()) constructs a new $(C Task) object for every worker thread and starts that task automatically. $(C parallel()) then waits for all of the tasks to be completed before finally exiting the loop. $(C parallel()) is very convenient as it $(I constructs), $(I starts), and $(I waits for) the tasks automatically.
)

$(P
$(IX task) $(IX executeInNewThread) $(IX yieldForce) When tasks do not correspond to or cannot be represented by elements of a range, these three steps can be handled explicitly by the programmer. $(C task()) constructs, $(C executeInNewThread()) starts, and $(C yieldForce()) waits for a task object. These three functions are explained further in the comments of the following program.
)

$(P
The $(C anOperation()) function is started twice in the following program. It prints the first letter of $(C id) to indicate which task it is working for.
)

$(P
$(IX flush, std.stdio) $(I $(B Note:) Normally, the characters that are printed to output streams like $(C stdout) do not appear on the output right away. They are instead stored in an output buffer until a line of output is completed. Since $(C write) does not output a new-line character, in order to observe the parallel execution of the following program, $(C stdout.flush()) is called to send the contents of the buffer to $(C stdout) even before reaching the end of a line.)
)

---
import std.stdio;
import std.parallelism;
import std.array;
import core.thread;

/* Prints the first letter of 'id' every half a second. It
 * arbitrarily returns the value 1 to simulate functions that
 * do calculations. This result will be used later in main. */
int anOperation(string id, int duration) {
    writefln("%s will take %s seconds", id, duration);

    foreach (i; 0 .. (duration * 2)) {
        Thread.sleep(500.msecs);  /* half a second */
        write(id.front);
        stdout.flush();
    }

    return 1;
}

void main() {
    /* Construct a task object that will execute
     * anOperation(). The function parameters that are
     * specified here are passed to the task function as its
     * function parameters. */
    auto theTask = $(HILITE task!anOperation)("theTask", 5);

    /* Start the task object */
    theTask.$(HILITE executeInNewThread());

    /* As 'theTask' continues executing, 'anOperation()' is
     * being called again, this time directly in main. */
    immutable result = anOperation("main's call", 3);

    /* At this point we are sure that the operation that has
     * been started directly from within main has been
     * completed, because it has been started by a regular
     * function call, not as a task. */

    /* On the other hand, it is not certain at this point
     * whether 'theTask' has completed its operations
     * yet. yieldForce() waits for the task to complete its
     * operations; it returns only when the task has been
     * completed. Its return value is the return value of
     * the task function, i.e. anOperation(). */
    immutable taskResult = theTask.$(HILITE yieldForce());

    writeln();
    writefln("All finished; the result is %s.",
             result + taskResult);
}
---

$(P
The output of the program should be similar to the following. The fact that the $(C m) and $(C t) letters are printed in mixed order indicates that the operations are executed in parallel:
)

$(SHELL
main's call will take 3 seconds
theTask will take 5 seconds
mtmttmmttmmttttt
All finished; the result is 2.
)

$(P
The task function above has been specified as a template parameter to $(C task()) as $(C task!anOperation). Although this method works well in most cases, as we have seen in $(LINK2 templates.html, the Templates chapter), each different instantiation of a template is a different type. This distinction may be undesirable in certain situations where seemingly $(I equivalent) task objects would actually have different types.
)

$(P
For example, although the following two functions have the same signature, the two $(C Task) instantiations that are produced through calls to the $(C task()) function template would have different types. As a result, they cannot be members of the same array:
)

---
import std.parallelism;

double foo(int i) {
    return i * 1.5;
}

double bar(int i) {
    return i * 2.5;
}

void main() {
    auto tasks = [ task$(HILITE !)foo(1),
                   task$(HILITE !)bar(2) ];    $(DERLEME_HATASI)
}
---

$(SHELL
Error: $(HILITE incompatible types) for ((task(1)) : (task(2))):
'Task!($(HILITE foo), int)*' and 'Task!($(HILITE bar), int)*'
)

$(P
Another overload of $(C task()) takes the function as its first function parameter instead:
)

---
    void someFunction(int value) {
        // ...
    }

    auto theTask = task($(HILITE &someFunction), 42);
---

$(P
As this method does not involve different instantiations of the $(C Task) template, it makes it possible to put such objects in the same array:
)

---
import std.parallelism;

double foo(int i) {
    return i * 1.5;
}

double bar(int i) {
    return i * 2.5;
}

void main() {
    auto tasks = [ task($(HILITE &)foo, 1),
                   task($(HILITE &)bar, 2) ];    $(CODE_NOTE compiles)
}
---

$(P
A lambda function or an object of a type that defines the $(C opCall) member can also be used as the task function. The following example starts a task that executes a lambda:
)

---
    auto theTask = task((int value) $(HILITE {)
                            /* ... */
                        $(HILITE }), 42);
---

$(H6 $(IX exception, parallelism) Exceptions)

$(P
As tasks are executed on separate threads, the exceptions that they throw cannot be caught by the thread that started them. For that reason, the exceptions that are thrown are automatically caught by the tasks themselves, to be rethrown later when $(C Task) member functions like $(C yieldForce()) are called. This makes it possible for the main thread to catch exceptions that are thrown by a task.
)

---
import std.stdio;
import std.parallelism;
import core.thread;

void mayThrow() {
    writeln("mayThrow() is started");
    Thread.sleep(1.seconds);
    writeln("mayThrow() is throwing an exception");
    throw new Exception("Error message");
}

void main() {
    auto theTask = task!mayThrow();
    theTask.executeInNewThread();

    writeln("main is continuing");
    Thread.sleep(3.seconds);

    writeln("main is waiting for the task");
    theTask.yieldForce();
}
---

$(P
The output of the program shows that the uncaught exception that has been thrown by the task does not terminate the entire program right away (it terminates only the task):
)

$(SHELL
main is continuing
mayThrow() is started
mayThrow() is throwing an exception                 $(SHELL_NOTE thrown)
main is waiting for the task
object.Exception@deneme.d(10): Error message        $(SHELL_NOTE terminated)
)

$(P
$(C yieldForce()) can be called in a $(C try-catch) block to catch the exceptions that are thrown by the task. Note that this is different from single threads: In single-threaded programs like the samples that we have been writing until this chapter, $(C try-catch) wraps the code that may throw. In parallelism, it wraps $(C yieldForce()):
)

---
    try {
        theTask.yieldForce();

    } catch (Exception exc) {
        writefln("Detected an error in the task: '%s'", exc.msg);
    }
---

$(P
This time the exception is caught by the main thread instead of terminating the program:
)

$(SHELL
main is continuing
mayThrow() is started
mayThrow() is throwing an exception                 $(SHELL_NOTE thrown)
main is waiting for the task
Detected an error in the task: 'Error message'      $(SHELL_NOTE caught)
)

$(H6 Member functions of $(C Task))

$(UL

$(LI $(C done): Specifies whether the task has been completed; rethrows the exception if the task has been terminated with an exception.

---
    if (theTask.done) {
        writeln("Yes, the task has been completed");

    } else {
        writeln("No, the task is still going on");
    }
---

)

$(LI $(C executeInNewThread()): Starts the task in a new thread.)

$(LI $(C executeInNewThread(int priority)): Starts the task in a new thread with the specified priority. (Priority is an operating system concept that determines execution priorities of threads.))

)

$(P
There are three functions to wait for the completion of a task:
)

$(UL

$(LI $(C yieldForce()): Starts the task if it has not been started yet; if it has already been completed, returns its return value; if it is still running, waits for its completion without making the microprocessor busy; if an exception has been thrown, rethrows that exception.)

$(LI $(IX spinForce) $(C spinForce()): Works similarly to $(C yieldForce()), except that it makes the microprocessor busy while waiting, in order to catch the completion as early as possible.)

$(LI $(IX workForce) $(C workForce()): Works similarly to $(C yieldForce()), except that it starts a new task in the current thread while waiting for the task to be completed.)

)

$(P
In most cases $(C yieldForce()) is the most suitable function to call when waiting for a task to complete; it suspends the thread that calls $(C yieldForce()) until the task is completed. Although $(C spinForce()) makes the microprocessor busy while waiting, it is suitable when the task is expected to be completed in a very short time. $(C workForce()) can be called when starting other tasks is preferred over suspending the current thread.
)

$(P
Please see the online documentation of Phobos for the other member functions of $(C Task).
)

$(H5 $(IX asyncBuf) $(C taskPool.asyncBuf()))

$(P
Similarly to $(C parallel()), $(C asyncBuf()) iterates $(C InputRange) ranges in parallel. It stores the elements in a buffer as they are produced by the range, and serves the elements from that buffer to its user.
)

$(P
In order to avoid making a potentially fully-lazy input range a fully-eager range, it iterates the elements in $(I waves). Once it prepares certain number of elements in parallel, it waits until those elements are consumed by $(C popFront()) before producing the elements of the next wave.
)

$(P
$(C asyncBuf()) takes a range and an optional $(I buffer size) that determines how many elements to be made available during each wave:
)

---
    auto elements = taskPool.asyncBuf($(I range), $(I buffer_size));
---

$(P
To see the effects of $(C asyncBuf()), let's use a range that takes half a second to iterate and half a second to process each element. This range simply produces integers up to the specified limit:
)

---
import std.stdio;
import core.thread;

struct Range {
    int limit;
    int i;

    bool empty() const {
        return i >= limit;
    }

    int front() const {
        return i;
    }

    void popFront() {
        writefln("Producing the element after %s", i);
        Thread.sleep(500.msecs);
        ++i;
    }
}

void main() {
    auto range = Range(10);

    foreach (element; range) {
        writefln("Using element %s", element);
        Thread.sleep(500.msecs);
    }
}
---

$(P
The elements are produced and used lazily. Since it takes one second for each element, the whole range takes ten seconds to process in this program:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED
Using element 0
Producing the element after 0
Using element 1
Producing the element after 1
Using element 2
...
Producing the element after 8
Using element 9
Producing the element after 9

real    0m10.007s    $(SHELL_NOTE 10 seconds total)
user    0m0.004s
sys     0m0.000s)
)

$(P
According to that output, the elements are produced and used sequentially.
)

$(P
On the other hand, it may not be necessary to wait for preceding elements to be processed before starting to produce the successive elements. The program would take less time if other elements could be produced while the front element is in use:
)

---
import std.parallelism;
//...
    foreach (element; $(HILITE taskPool.asyncBuf)(range, $(HILITE 2))) {
---

$(P
In the call above, $(C asyncBuf()) makes two elements ready in its buffer. Elements are produced in parallel while they are being used:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED
Producing the element after 0
Producing the element after 1
Using element 0
Producing the element after 2
Using element 1
Producing the element after 3
Using element 2
Producing the element after 4
Using element 3
Producing the element after 5
Using element 4
Producing the element after 6
Producing the element after 7
Using element 5
Using element 6
Producing the element after 8
Producing the element after 9
Using element 7
Using element 8
Using element 9

real    0m6.007s    $(SHELL_NOTE now 6 seconds)
user    0m0.000s
sys     0m0.004s)
)

$(P
The default value of buffer size is 100. The buffer size that produces the best performance would be different under different situations.
)

$(P
$(C asyncBuf()) can be used outside of $(C foreach) loops as well. For example, the following code uses the return value of $(C asyncBuf()) as an $(C InputRange) which operates semi-eagerly:
)

---
    auto range = Range(10);
    auto asyncRange = taskPool.asyncBuf(range, 2);
    writeln($(HILITE asyncRange.front));
---

$(H5 $(IX map, parallel) $(C taskPool.map()))

$(P
$(IX map, std.algorithm) It helps to explain $(C map()) from the $(C std.algorithm) module before explaining $(C taskPool.map()). $(C std.algorithm.map) is an algorithm commonly found in many functional languages. It calls a function with the elements of a range one-by-one and returns a range that consists of the results of calling that function with each element. It is a lazy algorithm: It calls the function as needed. (There is also $(C std.algorithm.each), which is for generating side effects for each element, as opposed to producing a result from it.)
)

$(P
The fact that $(C std.algorithm.map) operates lazily is very powerful in many programs. However, if the function needs to be called with every element anyway and the operations on each element are independent from each other, laziness may be unnecessarily slower than parallel execution. $(C taskPool.map()) and $(C taskPool.amap()) from the $(C std.parallelism) module take advantage of multiple cores and run faster in many cases.
)

$(P
Let's compare these three algorithms using the $(C Student) example. Let's assume that $(C Student) has a member function that returns the average grade of the student. To demonstrate how parallel algorithms are faster, let's again slow this function down with $(C Thread.sleep()).
)

$(P
$(C std.algorithm.map) takes the function as its template parameter, and the range as its function parameter. It returns a range that consists of the results of applying that function to the elements of the range:
)

---
    auto $(I result_range) = map!$(I func)($(I range));
---

$(P
The function may be specified by the $(C =>) syntax as a $(I lambda expression) as we have seen in earlier chapters. The following program uses $(C map()) to call the $(C averageGrade()) member function on each element:
)

---
import std.stdio;
import std.algorithm;
import core.thread;

struct Student {
    int number;
    int[] grades;

    double averageGrade() {
        writefln("Started working on student %s",
                 number);
        Thread.sleep(1.seconds);

        const average = grades.sum / grades.length;

        writefln("Finished working on student %s", number);
        return average;
    }
}

void main() {
    Student[] students;

    foreach (i; 0 .. 10) {
        /* Two grades for each student */
        students ~= Student(i, [80 + i, 90 + i]);
    }

    auto results = $(HILITE map)!(a => a.averageGrade)(students);

    foreach (result; results) {
        writeln(result);
    }
}
---

$(P
The output of the program demonstrates that $(C map()) operates lazily; $(C averageGrade()) is called for each result as the $(C foreach) loop iterates:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED
Started working on student 0
Finished working on student 0
85                   $(SHELL_NOTE calculated as foreach iterates)
Started working on student 1
Finished working on student 1
86
...
Started working on student 9
Finished working on student 9
94

real    0m10.006s    $(SHELL_NOTE 10 seconds total)
user    0m0.000s
sys     0m0.004s)
)

$(P
If $(C std.algorithm.map) were an eager algorithm, the messages about the starts and finishes of the operations would be printed altogether at the top.
)

$(P
$(C taskPool.map()) from the $(C std.parallelism) module works essentially the same as $(C std.algorithm.map). The only difference is that it executes the function calls semi-eagerly and stores the results in a buffer to be served from as needed. The size of this buffer is determined by the second parameter. For example, the following code would make ready the results of the function calls for three elements at a time:
)

---
import std.parallelism;
// ...
double averageGrade(Student student) {
    return student.averageGrade;
}
// ...
    auto results = $(HILITE taskPool.map)!averageGrade(students, $(HILITE 3));
---

$(P
$(I $(B Note:) The free-standing $(C averageGrade()) function above is needed due to a limitation that involves using local delegates with member function templates like $(C TaskPool.map). There would be a compilation error without that free-standing function:
))

---
auto results =
    taskPool.map!(a => a.averageGrade)(students, 3);  $(DERLEME_HATASI)
---

$(P
This time the operations are executed in waves of three elements:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED
Started working on student 1  $(SHELL_NOTE in parallel)
Started working on student 2  $(SHELL_NOTE but in unpredictable order)
Started working on student 0
Finished working on student 1
Finished working on student 2
Finished working on student 0
85
86
87
Started working on student 4
Started working on student 5
Started working on student 3
Finished working on student 4
Finished working on student 3
Finished working on student 5
88
89
90
Started working on student 7
Started working on student 8
Started working on student 6
Finished working on student 7
Finished working on student 6
Finished working on student 8
91
92
93
Started working on student 9
Finished working on student 9
94

real    0m4.007s    $(SHELL_NOTE 4 seconds total)
user    0m0.000s
sys     0m0.004s)
)

$(P
The second parameter of $(C map()) has the same meaning as $(C asyncBuf()): It determines the size of the buffer that $(C map()) uses to store the results in. The third parameter is the work unit size as in $(C parallel()); the difference being its default value, which is $(C size_t.max):
)

---
    /* ... */ = taskPool.map!$(I func)($(I range),
                                  $(I buffer_size) = 100
                                  $(I work_unit_size) = size_t.max);
---

$(H5 $(IX amap) $(C taskPool.amap()))

$(P
Parallel $(C amap()) works the same as parallel $(C map()) with two differences:
)

$(UL

$(LI
It is fully eager.
)

$(LI
It works with $(C RandomAccessRange) ranges.
)

)

---
    auto results = $(HILITE taskPool.amap)!averageGrade(students);
---

$(P
Since it is eager, all of the results are ready by the time $(C amap()) returns:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED
Started working on student 1    $(SHELL_NOTE all are executed up front)
Started working on student 0
Started working on student 2
Started working on student 3
Finished working on student 1
Started working on student 4
Finished working on student 2
Finished working on student 3
Started working on student 6
Finished working on student 0
Started working on student 7
Started working on student 5
Finished working on student 4
Started working on student 8
Finished working on student 6
Started working on student 9
Finished working on student 7
Finished working on student 5
Finished working on student 8
Finished working on student 9
85
86
87
88
89
90
91
92
93
94

real    0m3.005s    $(SHELL_NOTE 3 seconds total)
user    0m0.000s
sys     0m0.004s)
)

$(P
$(C amap()) works faster than $(C map()) at the expense of using an array that is large enough to store all of the results. It consumes more memory to gain speed.
)

$(P
The optional second parameter of $(C amap()) is the work unit size as well:
)

---
    auto results = taskPool.amap!averageGrade(students, $(HILITE 2));
---

$(P
The results can also be stored in a $(C RandomAccessRange) that is passed to $(C amap()) as its third parameter:
)

---
    double[] results;
    results.length = students.length;
    taskPool.amap!averageGrade(students, 2, $(HILITE results));
---

$(H5 $(IX reduce, parallel) $(C taskPool.reduce()))

$(P
$(IX reduce, std.algorithm) As with $(C map()), it helps to explain $(C reduce()) from the $(C std.algorithm) module first.
)

$(P
$(IX fold, std.algorithm) $(C reduce()) is the equivalent of $(C std.algorithm.fold), which we have seen before in the $(LINK2 ranges.html, Ranges chapter). The main difference between the two is that their function parameters are reversed. (For that reason, I recommend that you prefer $(C fold()) for non-parallel code as it can take advantage of $(LINK2 ufcs.html, UFCS) in chained range expressions.)
)

$(P
$(C reduce()) is another high-level algorithm commonly found in many functional languages. Just like $(C map()), it takes one or more functions as template parameters. As its function parameters, it takes a value to be used as the initial value of the result, and a range. $(C reduce()) calls the functions with the current value of the result and each element of the range. When no initial value is specified, the first element of the range is used instead.
)

$(P
Assuming that it defines a variable named $(C result) in its implementation, the way that $(C reduce()) works can be described by the following steps:
)

$(OL

$(LI Assigns the initial value to $(C result))

$(LI Executes the expression $(C result = func(result, element)) for every element)

$(LI Returns the final value of $(C result))

)

$(P
For example, the sum of the squares of the elements of an array can be calculated as in the following program:
)

---
import std.stdio;
import std.algorithm;

void main() {
    writeln(reduce!((a, b) => a + b * b)(0, [5, 10]));
}
---

$(P
When the function is specified by the $(C =>) syntax as in the program above, the first parameter (here $(C a)) represents the current value of the result (initialized by the parameter $(C 0) above) and the second parameter (here $(C b)) represents the current element.
)

$(P
The program outputs the sum of 25 and 100, the squares of 5 and 10:
)

$(SHELL
125
)

$(P
As obvious from its behavior, $(C reduce()) uses a loop in its implementation. Because that loop is normally executed on a single core, it may be unnecessarily slow when the function calls for each element are independent from each other. In such cases $(C taskPool.reduce()) from the $(C std.parallelism) module can be used for taking advantage of all of the cores.
)

$(P
To see an example of this let's use $(C reduce()) with a function that is slowed down again artificially:
)

---
import std.stdio;
import std.algorithm;
import core.thread;

int aCalculation(int result, int element) {
    writefln("started  - element: %s, result: %s",
             element, result);

    Thread.sleep(1.seconds);
    result += element;

    writefln("finished - element: %s, result: %s",
             element, result);

    return result;
}

void main() {
    writeln("Result: ", $(HILITE reduce)!aCalculation(0, [1, 2, 3, 4]));
}
---

$(P
$(C reduce()) uses the elements in sequence to reach the final value of the result:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED
started  - element: 1, result: 0
finished - element: 1, result: 1
started  - element: 2, result: 1
finished - element: 2, result: 3
started  - element: 3, result: 3
finished - element: 3, result: 6
started  - element: 4, result: 6
finished - element: 4, result: 10
Result: 10

real    0m4.003s    $(SHELL_NOTE 4 seconds total)
user    0m0.000s
sys     0m0.000s)
)

$(P
As in the $(C parallel()) and $(C map()) examples, importing the $(C std.parallelism) module and calling $(C taskPool.reduce()) is sufficient to take advantage of all of the cores:
)

---
import std.parallelism;
// ...
    writeln("Result: ", $(HILITE taskPool.reduce)!aCalculation(0, [1, 2, 3, 4]));
---

$(P
However, there are important differences in the way $(C taskPool.reduce()) works.
)

$(P
Like the other parallel algorithms, $(C taskPool.reduce()) executes the functions in parallel by using elements in different tasks. Each task works on the elements that it is assigned to and calculates a $(C result) that corresponds to the elements of that task. Since $(C reduce()) is called with only a single initial value, every task must use that same initial value to initialize its own $(C result) (the parameter $(C 0) above).
)

$(P
The final values of the results that each task produces are themselves used in the same $(C result) calculation one last time. These final calculations are executed sequentially, not in parallel. For that reason, $(C taskPool.reduce()) may execute slower in short examples as in this chapter as will be observed in the following output.
)

$(P
The fact that the same initial value is used for all of the tasks, effectively being used in the calculations multiple times, $(C taskPool.reduce()) may calculate a result that is different from what $(C std.algorithm.reduce()) calculates. For that reason, the initial value must be the $(I identity value) for the calculation that is being performed, e.g. the $(C 0) in this example which does not have any effect in addition.
)

$(P
Additionally, as the results are used by the same functions one last time in the sequential calculations, the types of the parameters that the functions take must be compatible with the types of the values that the functions return.
)

$(P
$(C taskPool.reduce()) should be used only under these considerations.
)

---
import std.parallelism;
// ...
    writeln("Result: ", $(HILITE taskPool.reduce)!aCalculation(0, [1, 2, 3, 4]));
---

$(P
The output of the program indicates that first the calculations are performed in parallel, and then their results are calculated sequentially. The calculations that are performed sequentially are highlighted:
)

$(SHELL
$ time ./deneme
$(SHELL_OBSERVED
started  - element: 3, result: 0 $(SHELL_NOTE first, the tasks in parallel)
started  - element: 2, result: 0
started  - element: 1, result: 0
started  - element: 4, result: 0
finished - element: 3, result: 3
finished - element: 1, result: 1
$(HILITE started  - element: 1, result: 0) $(SHELL_NOTE then, their results sequentially)
finished - element: 4, result: 4
finished - element: 2, result: 2
$(HILITE finished - element: 1, result: 1)
$(HILITE started  - element: 2, result: 1)
$(HILITE finished - element: 2, result: 3)
$(HILITE started  - element: 3, result: 3)
$(HILITE finished - element: 3, result: 6)
$(HILITE started  - element: 4, result: 6)
$(HILITE finished - element: 4, result: 10)
Result: 10

real    0m5.006s    $(SHELL_NOTE parallel reduce is slower in this example)
user    0m0.004s
sys     0m0.000s)
)

$(P
Parallel $(C reduce()) is faster in many other calculations like the calculation of the math constant $(I pi) (π) by quadrature.
)

$(H5 Multiple functions and tuple results)

$(P
$(C std.algorithm.map()), $(C taskPool.map()), $(C taskPool.amap()), and $(C taskPool.reduce()) can all take more than one function, in which case the results are returned as a $(C Tuple). We have seen the $(C Tuple) type in the $(LINK2 tuples.html, Tuples chapter) before. The results of individual functions correspond to the elements of the tuple in the order that the functions are specified. For example, the result of the first function is the first member of the tuple.
)

$(P
The following program demonstrates multiple functions with $(C std.algorithm.map). Note that the return types of the functions need not be the same, as seen in the $(C quarterOf()) and $(C tenTimes()) functions below. In that case, the types of the members of the tuples would be different as well:
)

---
import std.stdio;
import std.algorithm;
import std.conv;

double quarterOf(double value) {
    return value / 4;
}

string tenTimes(double value) {
    return to!string(value * 10);
}

void main() {
    auto values = [10, 42, 100];
    auto results = map!($(HILITE quarterOf, tenTimes))(values);

    writefln(" Quarters  Ten Times");

    foreach (quarterResult, tenTimesResult; results) {
        writefln("%8.2f%8s", quarterResult, tenTimesResult);
    }
}
---

$(P
The output:
)

$(SHELL
 Quarters  Ten Times
    2.50     100
   10.50     420
   25.00    1000
)

$(P
In the case of $(C taskPool.reduce()), the initial values of the results must be specified as a tuple:
)

---
    taskPool.reduce!(foo, bar)($(HILITE tuple(0, 1)), [1, 2, 3, 4]);
---

$(H5 $(IX TaskPool) $(C TaskPool))

$(P
Behind the scenes, the parallel algorithms from the $(C std.parallelism) module all use task objects that are elements of a $(C TaskPool) container. Normally, all of the algorithms use the same container object named $(C taskPool).
)

$(P
$(C taskPool) contains appropriate number of tasks depending on the environment that the program runs under. For that reason, usually there is no need to create any other $(C TaskPool) object. Even so, explicit $(C TaskPool) objects may be created and used as needed.
)

$(P
The $(C TaskPool) constructor takes the number of threads to use during the parallel operations that are later started through it. The default value of the number of threads is one less than the number of cores on the system. All of the features that we have seen in this chapter can be applied to a separate $(C TaskPool) object.
)

$(P
The following example calls $(C parallel()) on a local $(C TaskPool) object:
)

---
import std.stdio;
import std.parallelism;

void $(CODE_DONT_TEST compiler_asm_deprecation_warning)main() {
    auto workers = new $(HILITE TaskPool(2));

    foreach (i; $(HILITE workers).parallel([1, 2, 3, 4])) {
        writefln("Working on %s", i);
    }

    $(HILITE workers).finish();
}
---

$(P
$(C TaskPool.finish()) tells the object to stop processing when all of its current tasks are completed.
)

$(H5 Summary)


$(UL

$(LI It is an error to execute operations in parallel unless those operations are independent from each other.)

$(LI $(C parallel()) accesses the elements of a range in parallel.)

$(LI Tasks can explicitly be created, started, and waited for by $(C task()), $(C executeInNewThread()), and $(C yieldForce()), respectively.)

$(LI The exceptions that are escaped from tasks can be caught later by most of the parallelism functions like $(C yieldForce()).)

$(LI $(C asyncBuf()) iterates the elements of an $(C InputRange) semi-eagerly in parallel.)

$(LI $(C map()) calls functions with the elements of an $(C InputRange) semi-eagerly in parallel.)

$(LI $(C amap()) calls functions with the elements of a $(C RandomAccessRange) fully-eagerly in parallel.)

$(LI $(C reduce()) makes calculations over the elements of a $(C RandomAccessRange) in parallel.)

$(LI $(C map()), $(C amap()), and $(C reduce()) can take multiple functions and return the results as tuples.)

$(LI When needed, $(C TaskPool) objects other than $(C taskPool) can be used.)

)

macros:
        TITLE=Parallelism

        DESCRIPTION=Parallel programming that enables taking advantage of microprocessor cores

        KEYWORDS=d programming language tutorial book parallel programming

MINI_SOZLUK=
