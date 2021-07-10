Ddoc

$(DERS_BOLUMU Function Pointers, Delegates, and Lambdas)

$(P
Function pointers are for storing addresses of functions in order to execute those functions at a later time. Function pointers are similar to their counterparts in the C programming language.
)

$(P
Delegates store both a function pointer and the context to execute that function pointer in. The stored context can either be the scope that the function execution will take place or a $(C struct) or $(C class) object.
)

$(P
Delegates enable $(I closures) as well, a concept that is supported by most functional programming languages.
)

$(H5 $(IX function pointer) $(IX pointer, function) Function pointers)

$(P
$(IX &, function address) We have seen in the previous chapter that it is possible to take addresses of functions with the $(C &) operator. In one of those examples, we passed such an address to a function template.
)

$(P
Taking advantage of the fact that template type parameters can match any type, let's pass a function pointer to a template to observe its type by printing its $(C .stringof) property:
)

---
import std.stdio;

int myFunction(char c, double d) {
    return 42;
}

void main() {
    myTemplate($(HILITE &myFunction));    // Taking the function's address and
                                // passing it as a parameter
}

void myTemplate(T)(T parameter) {
    writeln("type : ", T.stringof);
    writeln("value: ", parameter);
}
---

$(P
The output of the program reveals the type and the address of $(C myFunction()):
)

$(SHELL
type : int function(char c, double d)
value: 406948
)

$(H6 $(IX member function pointer) $(IX pointer, member function) Member function pointers)

$(P
The address of a member function can be taken either on a type or on an object of a type, with different results:
)

---
struct MyStruct {
    void func() {
    }
}

void main() {
    auto o = MyStruct();

    auto f = &$(HILITE MyStruct).func;    // on a type
    auto d = &$(HILITE o).func;           // on an object

    static assert(is (typeof($(HILITE f)) == void $(HILITE function)()));
    static assert(is (typeof($(HILITE d)) == void $(HILITE delegate)()));
}
---

$(P
As the two $(C static assert) lines above indicate, $(C f) is a $(C function) and $(C d) is a $(C delegate). We will see later below that $(C d) can be called directly but $(C f) needs an object to be called on.
)

$(H6 Definition)

$(P
$(IX function) Similar to regular pointers, each function pointer type can point exactly to a particular type of function; the parameter list and the return type of the function pointer and the function must match. Function pointers are defined by the $(C function) keyword between the return type and the parameter list of that particular type:
)

---
   $(I return_type) function($(I parameters)) ptr;
---

$(P
The names of the parameters ($(C c) and $(C d) in the output above) are optional. Because $(C myFunction()) takes a $(C char) and a $(C double) and returns an $(C int), the type of a function pointer that can point at $(C myFunction()) must be defined accordingly:
)

---
    int function(char, double) ptr = &myFunction;
---

$(P
The line above defines $(C ptr) as a function pointer taking two parameters ($(C char) and $(C double)) and returning $(C int). Its value is the address of $(C myFunction()).
)

$(P
Function pointer syntax is relatively harder to read; it is common to make code more readable by an $(C alias):
)

---
alias CalculationFunc = int function(char, double);
---

$(P
That alias makes the code easier to read:
)

---
    CalculationFunc ptr = &myFunction;
---

$(P
As with any type, $(C auto) can be used as well:
)

---
    auto ptr = &myFunction;
---

$(H6 Calling a function pointer)

$(P
Function pointers can be called exactly like functions:
)

---
    int result = $(HILITE ptr)('a', 5.67);
    assert(result == 42);
---

$(P
The call $(C ptr('a', 5.67)) above is the equivalent of calling the actual function by $(C myFunction('a', 5.67)).
)

$(H6 When to use)

$(P
Because function pointers store what function to call and they are called exactly like the functions that they point at, function pointers effectively store the behavior of the program for later.
)

$(P
There are many other features of D that are about program behavior. For example, the appropriate function to call to calculate the wages of an $(C Employee) can be determined by the value of an $(C enum) member:
)

---
    final switch (employee.type) {

    case EmployeeType.fullTime:
        fullTimeEmployeeWages();
        break;

    case EmployeeType.hourly:
        hourlyEmployeeWages();
        break;
    }
---

$(P
Unfortunately, that method is relatively harder to maintain because it obviously has to support all known employee types. If a new type of employee is added to the program, then all such $(C switch) statements must be located so that a new $(C case) clause is added for the new employee type.
)

$(P
A more common alternative of implementing behavior differences is polymorphism. An $(C Employee) interface can be defined and different wage calculations can be handled by different implementations of that interface:
)

---
interface Employee {
    double wages();
}

class FullTimeEmployee : Employee {
    double wages() {
        double result;
        // ...
        return result;
    }
}

class HourlyEmployee : Employee {
    double wages() {
        double result;
        // ...
        return result;
    }
}

// ...

    double result = employee.wages();
---

$(P
Function pointers are yet another alternative for implementing different behavior. They are more common in programming languages that do not support object oriented programming.
)

$(H6 Function pointer as a parameter)

$(P
Let's design a function that takes an array and returns another array. This function will filter out elements with values less than or equal to zero, and multiply the others by ten:
)

---
$(CODE_NAME filterAndConvert)int[] filterAndConvert(const int[] numbers) {
    int[] result;

    foreach (e; numbers) {
        if (e > 0) {                       // filtering,
            immutable newNumber = e * 10;  // and conversion
            result ~= newNumber;
        }
    }

    return result;
}
---

$(P
The following program demonstrates its behavior with randomly generated values:
)

---
$(CODE_XREF filterAndConvert)import std.stdio;
import std.random;

void main() {
    int[] numbers;

    // Random numbers
    foreach (i; 0 .. 10) {
        numbers ~= uniform(0, 10) - 5;
    }

    writeln("input : ", numbers);
    writeln("output: ", filterAndConvert(numbers));
}
---

$(P
The output contains numbers that are ten times the original numbers, which were greater than zero to begin with. The original numbers that have been selected are highlighted:
)

$(SHELL
input : [-2, $(HILITE 2), -2, $(HILITE 3), -2, $(HILITE 2), -1, -4, 0, 0]
output: [20, 30, 20]
)

$(P
$(C filterAndConvert()) is for a very specific task: It always selects numbers that are greater than zero and always multiplies them by ten. It could be more useful if the behaviors of filtering and conversion were parameterized.
)

$(P
Noting that filtering is a form of conversion as well (from $(C int) to $(C bool)), $(C filterAndConvert()) performs two conversions:
)

$(UL
$(LI $(C number > 0), which produces $(C bool) by considering an $(C int) value.)
$(LI $(C number * 10), which produces $(C int) from an $(C int) value.)
)

$(P
Let's define convenient aliases for function pointers that would match the two conversions above:
)

---
alias Predicate = bool function(int);    // makes bool from int
alias Convertor = int function(int);     // makes int from int
---

$(P
$(C Predicate) is the type of functions that take $(C int) and return $(C bool), and $(C Convertor) is the type of functions that take $(C int) and return $(C int).
)

$(P
If we provide such function pointers as parameters, we can have $(C filterAndConvert()) use those function pointers during its work:
)

---
int[] filterAndConvert(const int[] numbers,
                       $(HILITE Predicate predicate),
                       $(HILITE Convertor convertor)) {
    int[] result;

    foreach (number; numbers) {
        if ($(HILITE predicate(number))) {
            immutable newNumber = $(HILITE convertor(number));
            result ~= newNumber;
        }
    }

    return result;
}
---

$(P
$(C filterAndConvert()) is now an algorithm that is independent of the actual filtering and conversion operations. When desired, its earlier behavior can be achieved by the following two simple functions:
)

---
bool isGreaterThanZero(int number) {
    return number > 0;
}

int tenTimes(int number) {
    return number * 10;
}

// ...

    writeln("output: ", filterAndConvert(numbers,
                                         $(HILITE &isGreaterThanZero),
                                         $(HILITE &tenTimes)));
---

$(P
This design allows calling $(C filterAndConvert()) with any filtering and conversion behaviors. For example, the following two functions would make $(C filterAndConvert()) produce $(I the negatives of the even numbers):
)

---
bool isEven(int number) {
    return (number % 2) == 0;
}

int negativeOf(int number) {
    return -number;
}

// ...

    writeln("output: ", filterAndConvert(numbers,
                                         &isEven,
                                         &negativeOf));
---

$(P
The output:
)

$(SHELL
input : [3, -3, 2, 1, -5, 1, 2, 3, 4, -4]
output: [-2, -2, -4, 4]
)

$(P
As seen in these examples, sometimes such functions are so trivial that defining them as proper functions with name, return type, parameter list, and curly brackets is unnecessarily wordy.
)

$(P
As we will see below, the $(C =>) syntax of anonymous functions makes the code more concise and more readable. The following line has anonymous functions that are the equivalents of $(C isEven()) and $(C negativeOf()), without proper function definitions:
)

---
    writeln("output: ", filterAndConvert(numbers,
                                         number => (number % 2) == 0,
                                         number => -number));
---

$(H6 Function pointer as a member)

$(P
Function pointers can be stored as members of structs and classes as well. To see this, let's design a $(C class) that takes the predicate and convertor as constructor parameters in order to use them later on:
)

---
class NumberHandler {
    $(HILITE Predicate predicate);
    $(HILITE Convertor convertor);

    this(Predicate predicate, Convertor convertor) {
        this.predicate = predicate;
        this.convertor = convertor;
    }

    int[] handle(const int[] numbers) {
        int[] result;

        foreach (number; numbers) {
            if (predicate(number)) {
                immutable newNumber = convertor(number);
                result ~= newNumber;
            }
        }

        return result;
    }
}
---

$(P
An object of that type can be used similarly to $(C filterAndConvert()):
)

---
    auto handler = new NumberHandler($(HILITE &isEven), $(HILITE &negativeOf));
    writeln("result: ", handler.handle(numbers));
---

$(H5 $(IX anonymous function) $(IX function, anonymous) $(IX function, lambda) $(IX function literal) $(IX literal, function) $(IX lambda) Anonymous functions)

$(P
The code can be more readable and concise when short functions are defined without proper function definitions.
)

$(P
Anonymous functions, which are also knows as $(I function literals) or $(I lambdas), allow defining functions inside of expressions. Anonymous functions can be used at any point where a function pointer can be used.
)

$(P
We will get to their shorter $(C =>) syntax later below. Let's first see their full syntax, which is usually too wordy especially when it appears inside of other expressions:
)

---
    function $(I return_type)($(I parameters)) { /* operations */ }
---

$(P
For example, an object of $(C NumberHandler) that produces $(I 7 times the numbers that are greater than 2) can be constructed by anonymous functions as in the following code:
)

---
    new NumberHandler(function bool(int number) { return number > 2; },
                      function int(int number) { return number * 7; });
---

$(P
Two advantages of the code above is that the functions are not defined as proper functions and that their implementations are visible right where the $(C NumberHandler) object is constructed.
)

$(P
Note that the anonymous function syntax is very similar to regular function syntax. Although this consistency has benefits, the full syntax of anonymous functions makes code too wordy.
)

$(P
For that reason, there are various shorter ways of defining anonymous functions.
)

$(H6 Shorter syntax)

$(P
When the return type can be deduced from the $(C return) statement inside the anonymous function, then the return type need not be specified (The place where the return type would normally appear is highlighted by code comments.):
)

---
    new NumberHandler(function /**/(int number) { return number > 2; },
                      function /**/(int number) { return number * 7; });
---

$(P
Further, when the anonymous function does not take parameters, its parameter list need not be provided. Let's consider a function that takes a function pointer that takes $(I nothing) and returns $(C double):
)

---
void foo(double function$(HILITE ()) func) {
    // ...
}
---

$(P
Anonymous functions that are passed to that function need not have the empty parameter list. Therefore, all three of the following anonymous function syntaxes are equivalent:
)

---
    foo(function double() { return 42.42; });
    foo(function () { return 42.42; });
    foo(function { return 42.42; });
---

$(P
The first one is written in the full syntax. The second one omits the return type, taking advantage of the return type deduction. The third one omits the unnecessary parameter list.
)

$(P
Even further, the keyword $(C function) need not be provided either. In that case it is left to the compiler to determine whether it is an anonymous function or an anonymous delegate. Unless it uses a variable from one of the enclosing scopes, it is a function:
)

---
    foo({ return 42.42; });
---

$(P
Most anonymous functions can be defined even shorter by the $(I lambda syntax).
)

$(H6 $(IX =>) Lambda syntax instead of a single $(C return) statement)

$(P
In most cases even the shortest syntax above is unnecessarily cluttered. The curly brackets that are just inside the function parameter list make the code harder to read and a $(C return) statement as well as its semicolon inside a function argument looks out of place.
)

$(P
Let's start with the full syntax of an anonymous function that has a single $(C return) statement:
)

---
    function $(I return_type)($(I parameters)) { return $(I expression); }
---

$(P
We have already seen that the $(C function) keyword is not necessary and the return type can be deduced:
)

---
    ($(I parameters)) { return $(I expression); }
---

$(P
The equivalent of that definition is the following $(C =>) syntax, where the $(C =>) characters replace the curly brackets, the $(C return) keyword, and the semicolon:
)

---
    ($(I parameters)) => $(I expression)
---

$(P
The meaning of that syntax can be spelled out as "given those parameters, produce this expression (value)".
)

$(P
Further, when there is a single parameter, the parentheses around the parameter list can be omitted as well:
)

---
    $(I single_parameter) => $(I expression)
---

$(P
On the other hand, to avoid grammar ambiguities, the parameter list must still be written as empty parentheses when there is no parameter at all:
)

---
    () => $(I expression)
---

$(P
Programmers who know lambdas from other languages may make a mistake of using curly brackets after the $(C =>) characters, which can be valid D syntax with a different meaning:
)

---
    // A lambda that returns 'a + 1'
    auto l0 = (int a) => a + 1

    // A lambda that returns a parameter-less lambda that
    // returns 'a + 1'
    auto l1 = (int a) => $(HILITE {) return a + 1; $(HILITE })

    assert(l0(42) == 43);
    assert(l1(42)$(HILITE ()) == 43);    // Executing what l1 returns
---

$(P
$(IX filter, std.algorithm) Let's use the lambda syntax in a predicate passed to $(C std.algorithm.filter). $(C filter()) takes a predicate as its template parameter and a range as its function parameter. It applies the predicate to each element of the range and returns the ones that satisfy the predicate. One of several ways of specifying the predicate is the lambda syntax.
)

$(P
($(I Note: We will see ranges in a later chapter. At this point, it should be sufficient to know that D slices are ranges.))
)

$(P
The following lambda is a predicate that matches elements that are greater than 10:
)

---
import std.stdio;
import std.algorithm;

void main() {
    int[] numbers = [ 20, 1, 10, 300, -2 ];
    writeln(numbers.filter!($(HILITE number => number > 10)));
}
---

$(P
The output contains only the elements that satisfy the predicate:
)

$(SHELL
[20, 300]
)

$(P
For comparison, let's write the same lambda in the longest syntax. The curly brackets that define the body of the anonymous function are highlighted:
)

---
    writeln(numbers.filter!(function bool(int number) $(HILITE {)
                                return number > 10;
                            $(HILITE })));
---

$(P
As another example, this time let's define an anonymous function that takes two parameters. The following algorithm takes two slices and passes their corresponding elements one by one to a $(C function) that itself takes two parameters. It then collects and returns the results as another slice:
)

---
$(CODE_NAME binaryAlgorithm)import std.exception;

int[] binaryAlgorithm(int function$(HILITE (int, int)) func,
                      const int[] slice1,
                      const int[] slice2) {
    enforce(slice1.length == slice2.length);

    int[] results;

    foreach (i; 0 .. slice1.length) {
        results ~= func(slice1[i], slice2[i]);
    }

    return results;
}
---

$(P
Since the $(C function) parameter above takes two parameters, lambdas that can be passed to $(C binaryAlgorithm()) must take two parameters as well:
)

---
$(CODE_XREF binaryAlgorithm)import std.stdio;

void main() {
    writeln(binaryAlgorithm($(HILITE (a, b)) => (a * 10) + b,
                            [ 1, 2, 3 ],
                            [ 4, 5, 6 ]));
}
---

$(P
The output contains ten times the elements of the first array plus the elements of the second array (e.g. 14 is 10 * 1 + 4):
)

$(SHELL
[14, 25, 36]
)

$(H5 $(IX delegate) Delegates)

$(P
$(IX context) $(IX closure) A delegate is a combination of a function pointer and the context that it should be executed in. Delegates also support $(I closures) in D. Closures are a feature supported by many functional programming languages.
)

$(P
As we have seen in $(LINK2 lifetimes.html, the Lifetimes and Fundamental Operations chapter), the lifetime of a variable ends upon leaving the scope that it is defined in:
)

---
{
    int increment = 10;
    // ...
} // ← the life of 'increment' ends here
---

$(P
That is why the address of such a local variable cannot be returned from a function.
)

$(P
Let's imagine that $(C increment) is a local variable of a function that itself returns a $(C function). Let's make it so that the returned lambda happens to use that local variable:
)

---
alias Calculator = int function(int);

Calculator makeCalculator() {
    int increment = 10;
    return value => $(HILITE increment) + value;    $(DERLEME_HATASI)
}
---

$(P
That code is in error because the returned lambda makes use of a local variable that is about to go out of scope. If the code were allowed to compile, the lambda would be trying to access $(C increment), whose life has already ended.
)

$(P
For that code to be compiled and work correctly, the lifetime of $(C increment) must at least be as long as the lifetime of the lambda that uses it. Delegates extend the lifetime of the context of a lambda so that the local state that the function uses remains valid.
)

$(P
$(C delegate) syntax is similar to $(C function) syntax, the only difference being the keyword. That change is sufficient to make the previous code compile:
)

---
alias Calculator = int $(HILITE delegate)(int);

Calculator makeCalculator() {
    int increment = 10;
    return value => increment + value;
}
---

$(P
Having been used by a delegate, the local variable $(C increment) will now live as long as that delegate lives. The variable is available to the delegate just as any other variable would be, mutable as needed. We will see examples of this in the next chapter when using delegates with $(C opApply()) member functions.
)

$(P
The following is a test of the delegate above:
)

---
    auto calculator = makeCalculator();
    writeln("The result of the calculation: ", calculator(3));
---

$(P
Note that $(C makeCalculator()) returns an anonymous delegate. The code above assigns that delegate to the variable $(C calculator) and then calls it by $(C calculator(3)). Since the delegate is implemented to return the sum of its parameter and the variable $(C increment), the code outputs the sum of 3 and 10:
)

$(SHELL
The result of the calculation: 13
)

$(H6 Shorter syntax)

$(P
As we have already used in the previous example, delegates can take advantage of the shorter syntaxes as well. When neither $(C function) nor $(C delegate) is specified, the type of the lambda is decided by the compiler, depending on whether the lambda accesses local state. If so, then it is a $(C delegate).
)

$(P
The following example has a delegate that does not take any parameters:
)

---
int[] delimitedNumbers(int count, int delegate$(HILITE ()) numberGenerator) {
    int[] result = [ -1 ];
    result.reserve(count + 2);

    foreach (i; 0 .. count) {
        result ~= numberGenerator();
    }

    result ~= -1;

    return result;
}
---

$(P
The function $(C delimitedNumbers()) generates a slice where the first and last elements are -1. It takes two parameters that specify the other elements that come between those first and last elements.
)

$(P
Let's call that function with a trivial delegate that always returns the same value. Remember that when there is no parameter, the parameter list of a lambda must be specified as empty:
)

---
    writeln(delimitedNumbers(3, $(HILITE () => 42)));
---

$(P
The output:
)

$(SHELL
-1 42 42 42 -1
)

$(P
Let's call $(C delimitedNumbers()) this time with a delegate that makes use of a local variable:
)

---
    int lastNumber;
    writeln(delimitedNumbers(
                15, $(HILITE () => lastNumber += uniform(0, 3))));

    writeln("Last number: ", lastNumber);
---

$(P
Although that delegate produces a random value, since the value is added to the last one, none of the generated values is less than its predecessor:
)

$(SHELL
-1 0 2 3 4 6 6 8 9 9 9 10 12 14 15 17 -1
Last number: 17
)

$(H6 $(IX &, object delegate) $(IX delegate, member function) $(IX object delegate) $(IX member function delegate) An object and a member function as a delegate)

$(P
We have seen that a delegate is nothing but a function pointer and the context that it is to be executed in. Instead of those two, a delegate can also be composed of a member function and an existing object that that member function is to be called on.
)

$(P
The syntax that defines such a delegate from an object is the following:
)

---
    &$(I object).$(I member_function)
---

$(P
Let's first observe that such a syntax indeed defines a $(C delegate) by printing its $(C string) representation:
)

---
import std.stdio;

struct Location {
    long x;
    long y;

    void moveHorizontally(long step) { x += step; }
    void moveVertically(long step)   { y += step; }
}

void main() {
    auto location = Location();
    writeln(typeof($(HILITE &location.moveHorizontally)).stringof);
}
---

$(P
According to the output, the type of $(C moveHorizontally()) called on $(C location) is indeed a $(C delegate):
)

$(SHELL
void delegate(long step)
)

$(P
Note that the $(C &) syntax is only for constructing the delegate. The delegate will be called later by the function call syntax:
)

---
    // The definition of the delegate variable:
    auto directionFunction = &location.moveHorizontally;

    // Calling the delegate by the function call syntax:
    directionFunction$(HILITE (3));

    writeln(location);
---

$(P
Since the $(C delegate) combines the $(C location) object and the $(C moveHorizontally()) member function, calling the delegate is the equivalent of calling $(C moveHorizontally()) on $(C location). The output indicates that the object has indeed moved 3 steps horizontally:
)

$(SHELL
Location(3, 0)
)

$(P
Function pointers, lambdas, and delegates are expressions. They can be used in places where a value of their type is expected. For example, a slice of $(C delegate) objects is initialized below from delegates constructed from an object and its various member functions. The $(C delegate) elements of the slice are later called just like functions:
)

---
    auto location = Location();

    void delegate(long)[] movements =
        [ &location.moveHorizontally,
          &location.moveVertically,
          &location.moveHorizontally ];

    foreach (movement; movements) {
        movement$(HILITE (1));
    }

    writeln(location);
---

$(P
According to the elements of the slice, the location has been changed twice horizontally and once vertically:
)

$(SHELL
Location(2, 1)
)

$(H6 $(IX .ptr, delegate context) $(IX pointer, delegate context) $(IX .funcptr) $(IX function pointer, delegate) Delegate properties)

$(P
The function and context pointers of a delegate can be accessed through its $(C .funcptr) and $(C .ptr) properties, respectively:
)

---
struct MyStruct {
    void func() {
    }
}

void main() {
    auto o = MyStruct();

    auto d = &o.func;

    assert(d$(HILITE .funcptr) == &MyStruct.func);
    assert(d$(HILITE .ptr) == &o);
}
---

$(P
It is possible to make a $(C delegate) from scratch by setting those properties explicitly:
)

---
struct MyStruct {
    int i;

    void func() {
        import std.stdio;
        writeln(i);
    }
}

void main() {
    auto o = MyStruct(42);

    void delegate() d;
    assert(d is null);    // null to begin with

    d$(HILITE .funcptr) = &MyStruct.func;
    d$(HILITE .ptr) = &o;

    $(HILITE d());
}
---

$(P
Calling the delegate above as $(C d()) is the equivalent of the expression $(C o.func()) (i.e. calling $(C MyStruct.func) on $(C o)):
)

$(SHELL
42
)

$(H6 $(IX lazy parameter as delegate) Lazy parameters are delegates)

$(P
We saw the $(C lazy) keyword in $(LINK2 function_parameters.html, the Function Parameters chapter):
)

---
void log(Level level, $(HILITE lazy) string message) {
    if (level >= interestedLevel) {
        writeln(message);
    }
}

// ...

    if (failedToConnect) {
        log(Level.medium,
            $(HILITE format)("Failure. The connection state is '%s'.",
                   getConnectionState()));
    }
---

$(P
Because $(C message) is a $(C lazy) parameter above, the entire $(C format) expression (including the $(C getConnectionState()) call that it makes) would be evaluated if and when that parameter is used inside $(C log()).
)

$(P
Behind the scenes, lazy parameters are in fact delegates and the arguments that are passed to lazy parameters are delegate objects that are created automatically by the compiler. The code below is the equivalent of the one above:
)

---
void log(Level level, string $(HILITE delegate)() lazyMessage) {  // (1)
    if (level >= interestedLevel) {
        writefln("%s", $(HILITE lazyMessage()));                  // (2)
    }
}

// ...

    if (failedToConnect) {
        log(Level.medium,
            delegate string() $(HILITE {)                         // (3)
                return format(
                    "Failure. The connection state is '%s'.",
                    getConnectionState());
            $(HILITE }));
    }
---

$(OL

$(LI The $(C lazy) parameter is not a $(C string) but a delegate that returns a $(C string).)

$(LI The delegate is called to get its return value.)

$(LI The entire expression is wrapped inside a delegate and returned from it.)

)

$(H6 $(IX lazy variadic functions) $(IX variadic function, lazy) Lazy variadic functions)

$(P
When a function needs a variable number of lazy parameters, it is necessarily impossible to specify those $(I unknown number of) parameters as $(C lazy).
)

$(P
The solution is to use variadic $(C delegate) parameters. Such parameters can receive any number of expressions that are the same as the $(I return type) of those delegates. The delegates cannot take parameters:
)

---
import std.stdio;

void foo(double delegate()$(HILITE []) args$(HILITE ...)) {
    foreach (arg; args) {
        writeln($(HILITE arg()));     // Calling each delegate
    }
}

void main() {
    foo($(HILITE 1.5), () => 2.5);    // 'double' passed as delegate
}
---

$(P
Note how both a $(C double) expression and a lambda are matched to the variadic parameter. The $(C double) expression is automatically wrapped inside a delegate and the function prints the values of all its $(I effectively-lazy) parameters:
)

$(SHELL
1.5
2.5
)

$(P
A limitation of this method is that all parameters must be the same type ($(C double) above). We will see later in the $(LINK2 templates_more.html, More Templates chapter) how to take advantage of $(I tuple template parameters) to remove that limitation.
)

$(H5 $(IX sink) $(IX toString, delegate) $(C toString()) with a $(C delegate) parameter)

$(P
We have defined many $(C toString()) functions up to this point in the book to represent objects as strings. Those $(C toString()) definitions all returned a $(C string) without taking any parameters. As noted by the comment lines below, structs and classes took advantage of $(C toString()) functions of their respective members by simply passing those members to $(C format()):
)

---
import std.stdio;
import std.string;

struct Point {
    int x;
    int y;

    string toString() const {
        return format("(%s,%s)", x, y);
    }
}

struct Color {
    ubyte r;
    ubyte g;
    ubyte b;

    string toString() const {
        return format("RGB:%s,%s,%s", r, g, b);
    }
}

struct ColoredPoint {
    Color color;
    Point point;

    string toString() const {
        /* Taking advantage of Color.toString and
         * Point.toString: */
        return format("{%s;%s}", color, point);
    }
}

struct Polygon {
    ColoredPoint[] points;

    string toString() const {
        /* Taking advantage of ColoredPoint.toString: */
        return format("%s", points);
    }
}

void main() {
    auto polygon = Polygon(
        [ ColoredPoint(Color(10, 10, 10), Point(1, 1)),
          ColoredPoint(Color(20, 20, 20), Point(2, 2)),
          ColoredPoint(Color(30, 30, 30), Point(3, 3)) ]);

    writeln(polygon);
}
---

$(P
In order for $(C polygon) to be sent to the output as a $(C string) on the last line of the program, all of the $(C toString()) functions of $(C Polygon), $(C ColoredPoint), $(C Color), and $(C Point) are called indirectly, creating a total of 10 strings in the process. Note that the strings that are constructed and returned by the lower-level functions are used only once by the respective higher-level function that called them.
)

$(P
However, although a total of 10 strings get constructed, only the very last one is printed to the output:
)

$(SHELL
[{RGB:10,10,10;(1,1)}, {RGB:20,20,20;(2,2)}, {RGB:30,30,30;(3,3)}]
)

$(P
However practical, this method may degrade the performance of the program because of the many $(C string) objects that are constructed and promptly thrown away.
)

$(P
An overload of $(C toString()) avoids this performance issue by taking a $(C delegate) parameter:
)

---
    void toString(void delegate(const(char)[]) sink) const;
---

$(P
As seen in its declaration, this overload of $(C toString()) does not return a $(C string). Instead, the characters that are going to be printed are passed to its $(C delegate) parameter. It is the responsibility of the $(C delegate) to append those characters to the single $(C string) that is going to be printed to the output.
)

$(P
$(IX formattedWrite, std.format) All the programmer needs to do differently is to call $(C std.format.formattedWrite) instead of $(C std.string.format) and pass the $(C delegate) parameter as its first parameter (in UFCS below). Also note that the following calls are providing the format strings as template arguments to take advantage of $(C formattedWrite)'s compile-time format string checks.
)

---
import std.stdio;
$(HILITE import std.format;)

struct Point {
    int x;
    int y;

    void toString(void delegate(const(char)[]) sink) const {
        sink.$(HILITE formattedWrite)!"(%s,%s)"(x, y);
    }
}

struct Color {
    ubyte r;
    ubyte g;
    ubyte b;

    void toString(void delegate(const(char)[]) sink) const {
        sink.$(HILITE formattedWrite)!"RGB:%s,%s,%s"(r, g, b);
    }
}

struct ColoredPoint {
    Color color;
    Point point;

    void toString(void delegate(const(char)[]) sink) const {
        sink.$(HILITE formattedWrite)!"{%s;%s}"(color, point);
    }
}

struct Polygon {
    ColoredPoint[] points;

    void toString(void delegate(const(char)[]) sink) const {
        sink.$(HILITE formattedWrite)!"%s"(points);
    }
}

void main() {
    auto polygon = Polygon(
        [ ColoredPoint(Color(10, 10, 10), Point(1, 1)),
          ColoredPoint(Color(20, 20, 20), Point(2, 2)),
          ColoredPoint(Color(30, 30, 30), Point(3, 3)) ]);

    writeln(polygon);
}
---

$(P
The advantage of this program is that, even though there are still a total of 10 calls made to various $(C toString()) functions, those calls collectively produce a single $(C string), not 10.
)

$(H5 Summary)

$(UL
$(LI The $(C function) keyword is for defining function pointers to be called later just like a function.)

$(LI The $(C delegate) keyword is for defining delegates. A delegate is the pair of a function pointer and the context that that function pointer to be executed in.)

$(LI A $(C delegate) can be created from an object and a member function by the syntax $(C &amp;object.member_function).)

$(LI A delegate can be constructed explicitly by setting its $(C .funcptr) and $(C .ptr) properties.)

$(LI Anonymous functions and anonymous delegates (lambdas) can be used in places of function pointers and delegates in expressions.)

$(LI There are several syntaxes for lambdas, the shortest of which is for when the equivalent consists only of a single $(C return) statement: $(C parameter&nbsp;=>&nbsp;expression).)

$(LI A more efficient overload of $(C toString()) takes a $(C delegate).)

)

Macros:
        TITLE=Function Pointers, Delegates, and Lambdas

        DESCRIPTION=C-like function pointers, delegates that are commonly found in functional programming languages, and anonymous functions (lambdas).

        KEYWORDS=d programming language tutorial book function pointer delegate anonymous function lambda
