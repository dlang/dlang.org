Ddoc

$(I
This is Ali Çehreli's book on D programming. Ali's pedagogical skills are renowned in the D community, for good reason. This book has hooks for many 
different fish - as well as being a careful and paced guide for programmers who are new to the D Programming language, it is also a useful reference 
for D practitioners, and even a perspicacious tutorial for people new to programming entirely. If you enjoy this book and would like to 
thank Ali financially, a Gumroad link is included below where you can buy this book on a pay-what-you-want basis. Enjoy!
)
$(DERS_BOLUMU Programming in D)

<div style="overflow: auto;">

<img style="border-width:0; float:left; margin:0 2em 1em 1em;" src="cover_thumb.png" height="180"/>

$(H6 ISBNs)
$(P
978-0-692-59943-3 hardcover by IngramSpark$(BR)
978-0-692-52957-7 paperback by IngramSpark$(BR)
978-1-515-07460-1 paperback by CreateSpace$(BR)
978-1-519-95441-1 ePUB by Draft2Digital$(BR)
)

$(P
These options have different prices, shipping times, shipping costs, customs and other fees, availability at local book stores, etc.
)

</div>

$(P
Also available as $(LINK2 https://gumroad.com/l/PinD, $(I pay-what-you-want) eBooks at Gumroad) and $(I free) here as $(LINK_DOWNLOAD http://ddili.org/Programming_in_D.pdf, PDF), $(LINK_DOWNLOAD http://ddili.org/Programming_in_D.epub, EPUB), $(LINK_DOWNLOAD http://ddili.org/Programming_in_D.azw3, AZW3), and $(LINK_DOWNLOAD http://ddili.org/Programming_in_D.mobi, MOBI).
)

$(P
$(LINK_DOWNLOAD /Programming_in_D_code_samples.zip, Click here to download code samples as a $(C .zip) file.)
)

$(H5 Online version)

$(UL
$(WORK_IN_PROCESS
$(LI $(LINK2 foreword1.html, Foreword by Walter Bright))
)
$(LI $(LINK2 foreword2.html, Foreword by Andrei Alexandrescu))
$(LI $(LINK2 preface.html, Preface))
$(LI $(LINK2 hello_world.html, The Hello World Program) $(INDEX_KEYWORDS main))
$(LI $(LINK2 writeln.html, writeln and write))
$(LI $(LINK2 compiler.html, Compilation))
$(LI $(LINK2 types.html, Fundamental Types) $(INDEX_KEYWORDS char int double (and more)))
$(LI $(LINK2 assignment.html, Assignment and Order of Evaluation) $(INDEX_KEYWORDS =))
$(LI $(LINK2 variables.html, Variables))
$(LI $(LINK2 io.html, Standard Input and Output Streams) $(INDEX_KEYWORDS stdin stdout))
$(LI $(LINK2 input.html, Reading from the Standard Input))
$(LI $(LINK2 logical_expressions.html, Logical Expressions) $(INDEX_KEYWORDS bool true false ! == != < <= > >= || &&))
$(LI $(LINK2 if.html, if Statement) $(INDEX_KEYWORDS if else))
$(LI $(LINK2 while.html, while Loop) $(INDEX_KEYWORDS while continue break))
$(LI $(LINK2 arithmetic.html, Integers and Arithmetic Operations) $(INDEX_KEYWORDS ++ -- + - * / % ^^ += -= *= /= %= ^^=))
$(LI $(LINK2 floating_point.html, Floating Point Types) $(INDEX_KEYWORDS .nan .infinity isNaN))
$(LI $(LINK2 arrays.html, Arrays) $(INDEX_KEYWORDS [] .length ~ ~=))
$(LI $(LINK2 characters.html, Characters) $(INDEX_KEYWORDS char wchar dchar))
$(LI $(LINK2 slices.html, Slices and Other Array Features) $(INDEX_KEYWORDS .. $ .dup capacity))
$(LI $(LINK2 strings.html, Strings) $(INDEX_KEYWORDS char[] wchar[] dchar[] string wstring dstring))
$(LI $(LINK2 stream_redirect.html, Redirecting Standard Input and Output Streams))
$(LI $(LINK2 files.html, Files) $(INDEX_KEYWORDS File))
$(LI $(LINK2 auto_and_typeof.html, auto and typeof) $(INDEX_KEYWORDS auto typeof))
$(LI $(LINK2 name_space.html, Name Scope))
$(LI $(LINK2 for.html, for Loop) $(INDEX_KEYWORDS for))
$(LI $(LINK2 ternary.html, Ternary Operator ?:) $(INDEX_KEYWORDS ?:))
$(LI $(LINK2 literals.html, Literals))
$(LI $(LINK2 formatted_output.html, Formatted Output) $(INDEX_KEYWORDS writef writefln))
$(LI $(LINK2 formatted_input.html, Formatted Input))
$(LI $(LINK2 do_while.html, do-while Loop) $(INDEX_KEYWORDS do while))
$(LI $(LINK2 aa.html, Associative Arrays) $(INDEX_KEYWORDS .keys .values .byKey .byValue .byKeyValue .get .remove in))
$(LI $(LINK2 foreach.html, foreach Loop) $(INDEX_KEYWORDS foreach .byKey .byValue .byKeyValue))
$(LI $(LINK2 switch_case.html, switch and case) $(INDEX_KEYWORDS switch, case, default, final switch))
$(LI $(LINK2 enum.html, enum) $(INDEX_KEYWORDS enum .min .max))
$(LI $(LINK2 functions.html, Functions) $(INDEX_KEYWORDS return void))
$(LI $(LINK2 const_and_immutable.html, Immutability) $(INDEX_KEYWORDS enum const immutable .dup .idup))
$(LI $(LINK2 value_vs_reference.html, Value Types and Reference Types) $(INDEX_KEYWORDS &))
$(LI $(LINK2 function_parameters.html, Function Parameters) $(INDEX_KEYWORDS in out ref inout lazy scope shared))
$(LI $(LINK2 lvalue_rvalue.html, Lvalues and Rvalues) $(INDEX_KEYWORDS auto ref))
$(LI $(LINK2 lazy_operators.html, Lazy Operators))
$(LI $(LINK2 main.html, Program Environment) $(INDEX_KEYWORDS main stderr))
$(LI $(LINK2 exceptions.html, Exceptions) $(INDEX_KEYWORDS throw try catch finally))
$(LI $(LINK2 scope.html, scope) $(INDEX_KEYWORDS scope(exit) scope(success) scope(failure)))
$(LI $(LINK2 assert.html, assert and enforce) $(INDEX_KEYWORDS assert enforce))
$(LI $(LINK2 unit_testing.html, Unit Testing) $(INDEX_KEYWORDS unittest))
$(LI $(LINK2 contracts.html, Contract Programming) $(INDEX_KEYWORDS in out))
$(LI $(LINK2 lifetimes.html, Lifetimes and Fundamental Operations))
$(LI $(LINK2 null_is.html, The null Value and the is Operator) $(INDEX_KEYWORDS null is !is))
$(LI $(LINK2 cast.html, Type Conversions) $(INDEX_KEYWORDS to assumeUnique cast))
$(LI $(LINK2 struct.html, Structs) $(INDEX_KEYWORDS struct . {} static, static this, static ~this))
$(LI $(LINK2 parameter_flexibility.html, Variable Number of Parameters) $(INDEX_KEYWORDS T[]... __MODULE__ __FILE__ __LINE__ __FUNCTION__ (and more)))
$(LI $(LINK2 function_overloading.html, Function Overloading))
$(LI $(LINK2 member_functions.html, Member Functions) $(INDEX_KEYWORDS toString))
$(LI $(LINK2 const_member_functions.html, const ref Parameters and const Member Functions) $(INDEX_KEYWORDS const ref, in ref, inout))
$(LI $(LINK2 special_functions.html, Constructor and Other Special Functions) $(INDEX_KEYWORDS this ~this this(this) opAssign @disable))
$(LI $(LINK2 operator_overloading.html, Operator Overloading) $(INDEX_KEYWORDS opUnary opBinary opEquals opCmp opIndex (and more)))
$(LI $(LINK2 class.html, Classes) $(INDEX_KEYWORDS class new))
$(LI $(LINK2 inheritance.html, Inheritance) $(INDEX_KEYWORDS : super override abstract))
$(LI $(LINK2 object.html, Object) $(INDEX_KEYWORDS toString opEquals opCmp toHash typeid TypeInfo))
$(LI $(LINK2 interface.html, Interfaces) $(INDEX_KEYWORDS interface static final))
$(LI $(LINK2 destroy.html, destroy and scoped) $(INDEX_KEYWORDS destroy scoped))
$(LI $(LINK2 modules.html, Modules and Libraries) $(INDEX_KEYWORDS import, module, static this, static ~this))
$(LI $(LINK2 encapsulation.html, Encapsulation and Protection Attributes) $(INDEX_KEYWORDS private protected public package))
$(LI $(LINK2 ufcs.html, Universal Function Call Syntax (UFCS)))
$(LI $(LINK2 property.html, Properties))
$(LI $(LINK2 invariant.html, Contract Programming for Structs and Classes) $(INDEX_KEYWORDS invariant))
$(LI $(LINK2 templates.html, Templates))
$(LI $(LINK2 pragma.html, Pragmas))
$(LI $(LINK2 alias.html, alias and with) $(INDEX_KEYWORDS alias with))
$(LI $(LINK2 alias_this.html, alias this) $(INDEX_KEYWORDS alias this))
$(LI $(LINK2 pointers.html, Pointers) $(INDEX_KEYWORDS * &))
$(LI $(LINK2 bit_operations.html, Bit Operations) $(INDEX_KEYWORDS ~ & | ^ >> >>> <<))
$(LI $(LINK2 cond_comp.html, Conditional Compilation) $(INDEX_KEYWORDS debug, version, static if, static assert, __traits))
$(LI $(LINK2 is_expr.html, is Expression) $(INDEX_KEYWORDS is()))
$(LI $(LINK2 lambda.html, Function Pointers, Delegates, and Lambdas) $(INDEX_KEYWORDS function delegate => toString))
$(LI $(LINK2 foreach_opapply.html, foreach with Structs and Classes) $(INDEX_KEYWORDS opApply empty popFront front (and more)))
$(LI $(LINK2 nested.html, Nested Functions, Structs, and Classes) $(INDEX_KEYWORDS static))
$(LI $(LINK2 union.html, Unions) $(INDEX_KEYWORDS union))
$(LI $(LINK2 goto.html, Labels and goto) $(INDEX_KEYWORDS goto))
$(LI $(LINK2 tuples.html, Tuples) $(INDEX_KEYWORDS tuple Tuple AliasSeq .tupleof foreach))
$(LI $(LINK2 templates_more.html, More Templates) $(INDEX_KEYWORDS template opDollar opIndex opSlice))
$(LI $(LINK2 functions_more.html, More Functions) $(INDEX_KEYWORDS inout pure nothrow @nogc @safe @trusted @system CTFE __ctfe))
$(LI $(LINK2 mixin.html, Mixins) $(INDEX_KEYWORDS mixin))
$(LI $(LINK2 ranges.html, Ranges) $(INDEX_KEYWORDS InputRange ForwardRange BidirectionalRange RandomAccessRange OutputRange))
$(LI $(LINK2 ranges_more.html, More Ranges) $(INDEX_KEYWORDS isInputRange ElementType hasLength inputRangeObject (and more)))
$(LI $(LINK2 static_foreach.html, static foreach))
$(LI $(LINK2 parallelism.html, Parallelism) $(INDEX_KEYWORDS parallel task asyncBuf map amap reduce))
$(LI $(LINK2 concurrency.html, Message Passing Concurrency) $(INDEX_KEYWORDS spawn thisTid ownerTid send receive (and more)))
$(LI $(LINK2 concurrency_shared.html, Data Sharing Concurrency) $(INDEX_KEYWORDS synchronized, shared, shared static this, shared static ~this))
$(LI $(LINK2 fibers.html, Fibers) $(INDEX_KEYWORDS call yield))
$(LI $(LINK2 memory.html, Memory Management) $(INDEX_KEYWORDS calloc realloc emplace destroy .alignof))
$(LI $(LINK2 uda.html, User Defined Attributes (UDA)) $(INDEX_KEYWORDS @))
$(LI $(LINK2 operator_precedence.html, Operator Precedence))
)

Macros:
        TITLE=Programming in D

        DESCRIPTION=D programming language tutorial from the ground up.

        KEYWORDS=d programming language tutorial book novice beginner

        BREADCRUMBS=$(BREADCRUMBS_INDEX)

SOZLER=

MINI_SOZLUK=
