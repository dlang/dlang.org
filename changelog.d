Ddoc

$(D_S D Change Log,

$(VERSION 063, XXX x, 2010, =================================================,

    $(BUGSFIXED
	$(LI $(BUGZILLA 978): std.utf's toUTF* functions accept some invalid and reject some valid UTF)
	$(LI $(BUGZILLA 2835): std.socket.TcpSocket doesn't actually connect)
    )
)

$(VERSION 062, Jun 9, 2010, =================================================,

    $(WHATSNEW
	$(LI $(BUGZILLA 2008): Poor optimization of functions with ref parameters)
	$(LI $(BUGZILLA 4296): Reduce parasitic error messages)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1193): regression: "matches more than one template declaration" doesn't list the location of the conflicting templates)
	$(LI $(BUGZILLA 1894): scope(exit) is ignored except in compound statements)
	$(LI $(BUGZILLA 1941): missing line on inaccesable external private module member)
	$(LI $(BUGZILLA 2127): inliner turns struct "return *this" from by-value into by-ref)
	$(LI $(BUGZILLA 2276): Error message missing line number on array operation)
	$(LI $(BUGZILLA 2546): Array Ops silently fail when no slice symbol is used.)
	$(LI $(BUGZILLA 2881): x.stringof returns typeof(x).stringof when x is an enum)
	$(LI $(BUGZILLA 3064): Invalid array operation accepted, generates bad code)
	$(LI $(BUGZILLA 3323): Segfault or ICE(e2ir.c) using struct with destructor almost anywhere)
	$(LI $(BUGZILLA 3398): Attributes inside a union screws data alignment)
	$(LI $(BUGZILLA 3547): for option -od for relative path the path is added twice)
	$(LI $(BUGZILLA 3548): ICE occurs when an array is returned from a function is incorrectly used in an array op expression.)
	$(LI $(BUGZILLA 3651): mangleof broken for enums)
	$(LI $(BUGZILLA 3854): Error on static initialization of arrays with trailing comma.)
	$(LI $(BUGZILLA 4003): The result changes only with the order of source files.)
	$(LI $(BUGZILLA 4045): [CTFE] increasing array length)
	$(LI $(BUGZILLA 4052): [CTFE] increment from array item)
	$(LI $(BUGZILLA 4078): [CTFE] Failed return of dynamic array item)
	$(LI $(BUGZILLA 4084): Ignored missing main() closing bracket)
	$(LI $(BUGZILLA 4143): fix warnings in dmd build)
	$(LI $(BUGZILLA 4156): Segfault with array+=array)
	$(LI $(BUGZILLA 4169): building dmd with a modern gcc produces a buggy compiler)
	$(LI $(BUGZILLA 4175): linux.mak doesn't declare sufficient dependencies to support parallel builds)
	$(LI $(BUGZILLA 4210): Random crashes / heisenbugs caused by dmd commit 478: compiler messes up vtables)
	$(LI $(BUGZILLA 4212): DWARF: void arrays cause gdb errors)
	$(LI $(BUGZILLA 4213): Strange behaviour with static void[] arrays)
	$(LI $(BUGZILLA 4242): ICE(module.c): importing a module with same name as package)
	$(LI $(BUGZILLA 4252): [CTFE] No array bounds checking in assignment to char[] array)
	$(LI $(BUGZILLA 4257): ICE(interpret.c): passing parameter into CTFE as ref parameter)
	$(LI $(BUGZILLA 4259): Header generation omits leading '@' for properties)
	$(LI $(BUGZILLA 4270): Missing line number in 'can only catch class objects' error message)
    )
)

<div id=version>
$(UL 
	$(NEW1 062)
	$(NEW1 061)
	$(NEW1 060)
	$(NEW1 059)
	$(NEW1 058)
	$(NEW1 057)
	$(NEW1 056)
	$(NEW1 055)
	$(NEW1 054)
	$(NEW1 053)
	$(NEW1 052)
	$(NEW1 051)
	$(NEW1 050)
	$(NEW1 049)
	$(NEW1 048)
	$(NEW1 047)
	$(NEW1 046)
	$(NEW1 045)
	$(NEW1 044)
	$(NEW1 043)
	$(NEW1 042)
	$(NEW1 041)
	$(NEW1 040)
	$(NEW1 039)
	$(NEW1 038)
	$(NEW1 037)
	$(NEW1 036)
	$(NEW1 035)
	$(NEW1 034)
	$(NEW1 033)
	$(NEW1 032)
	$(NEW1 031)
	$(NEW1 030)
	$(NEW1 029)
	$(NEW1 028)
	$(NEW1 027)
	$(NEW1 026)
	$(NEW1 025)
	$(NEW1 024)
	$(NEW1 023)
	$(NEW1 022)
	$(NEW1 021)
	$(NEW1 020)
	$(NEW1 019)
	$(NEW1 018)
	$(NEW1 017)
	$(NEW1 016)
	$(NEW1 015)
	$(NEW1 014)
	$(NEW1 013)
	$(NEW1 012)
	$(NEW1 011)
	$(NEW1 010)
	$(NEW1 009)
	$(NEW1 007)
	$(NEW1 006)
	$(NEW1 005)
	$(NEW1 004)
	$(NEW1 003)
	$(NEW1 002)
	$(NEW1 001)

	$(LI $(LINK2 http://www.digitalmars.com/d/changelog.html, change log for D 2.0))
	$(LI $(LINK2 changelog2.html, older versions))
	$(LI $(LINK2 changelog1.html, even older versions))

	$(LI Download latest stable (1.030)
	 <a HREF="http://ftp.digitalmars.com/dmd.1.030.zip" title="download D compiler">
	 D compiler</a> for Win32 and x86 linux)

	$(LI $(LINK2 http://www.digitalmars.com/pnews/index.php?category=2, tech support))
$(COMMENT
	$(LI $(LINK2 http://www.digitalmars.com/drn-bin/wwwnews?newsgroups=*, tech support))
)
)
</div>

$(VERSION 061, May 10, 2010, =================================================,

    $(WHATSNEW
	$(LI Add hints for missing import declarations.)
	$(LI Speed up compilation.)
    )
    $(BUGSFIXED
	$(LI Fix hanging problem on undefined identifiers.)
	$(LI $(BUGZILLA 461): Constant not understood to be constant when circular module dependency exists.)
	$(LI $(BUGZILLA 945): template forward reference with named nested struct only)
	$(LI $(BUGZILLA 1055): union forward reference "overlapping initialization" error)
	$(LI $(BUGZILLA 2085): CTFE fails if the function is forward referenced)
	$(LI $(BUGZILLA 2386): Array of forward referenced struct doesn't compile)
	$(LI $(BUGZILLA 4015): forward reference in alias causes error)
	$(LI $(BUGZILLA 4016): const initializer cannot forward reference other const initializer)
	$(LI $(BUGZILLA 4042): Unable to instantiate a struct template.)
	$(LI $(BUGZILLA 4100): Break and continue to label should mention foreach)
    )
)


$(VERSION 060, May 4, 2010, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI Another try at fixing the Dwarf issues.)
    )
)

$(VERSION 059, Apr 30, 2010, =================================================,

    $(WHATSNEW
	$(LI Improve spelling checking distance to 2.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1079): gdb: Dwarf Error: Cannot find DIE at 0xb705 referenced from DIE at 0x250)
	$(LI $(BUGZILLA 2549): Segfault on array multiplication.)
	$(LI $(BUGZILLA 3066): Array operation without a slice as the lvalue accepted, bad codegen)
	$(LI $(BUGZILLA 3207): gdb: Push D patches upstream)
	$(LI $(BUGZILLA 3415): broken JSON output)
	$(LI $(BUGZILLA 3522): ICE(cg87.c): variable*array[].)
	$(LI $(BUGZILLA 3974): ICE(init.c): Static array initializer with more elements than destination array)
	$(LI $(BUGZILLA 3987): [gdb] Invalid DWARF output for function pointers)
	$(LI $(BUGZILLA 4036): Segfault with -inline and literal of struct containing union)
	$(LI $(BUGZILLA 4037): [gdb] Invalid DWARF output for wchar)
	$(LI $(BUGZILLA 4038): [gdb] Invalid DWARF output for function pointers with ref args)
	$(LI $(BUGZILLA 4067): [CTFE] Code inside try-catch blocks is silently ignored)
	$(LI $(BUGZILLA 4089): crash when creating JSON output for incomplete struct)
	$(LI $(BUGZILLA 4093): Segfault(interpret.c): with recursive struct templates)
	$(LI $(BUGZILLA 4105): Stack overflow involving alias template parameters and undefined identifier)
    )
)

$(VERSION 058, Apr 6, 2010, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 122): DDoc newline behaviour produces suboptimal results)
	$(LI $(BUGZILLA 1628): Ddoc produces invalid documentation for --- blocks)
	$(LI $(BUGZILLA 2609): No documentation generated for destructor)
	$(LI $(BUGZILLA 3808): Assertion Failure : Assertion failure: 'classinfo->structsize == CLASSINFO_SIZE' on line 870 in file 'toobj.c')
	$(LI $(BUGZILLA 3842): ICE(expression.c) using pointer in CTFE)
	$(LI $(BUGZILLA 3884): Segfault: defining a typedef with an invalid object.d)
	$(LI $(BUGZILLA 3885): No multithread support for Windows DLL)
	$(LI $(BUGZILLA 3899): CTFE: poor error message for use of uninitialized variable)
	$(LI $(BUGZILLA 3900): CTFE: Wrong return value for array.var assignment)
	$(LI $(BUGZILLA 3901): PATCH: Nested struct assignment for CTFE)
	$(LI $(BUGZILLA 3914): Struct as argument that fits in register has member accessed wrong)
	$(LI $(BUGZILLA 3919): ICE(expression.c, 9944): * or / with typedef ireal)
	$(LI $(BUGZILLA 3920): Assertion failure: '0' on line 10018 in file 'expression.c')
	$(LI $(BUGZILLA 3958): mixin(non-static method) crashes compiler)
	$(LI $(BUGZILLA 3972): Regarding module with name different from its file name)
	$(LI $(BUGZILLA 4002): dmd.conf and binary path in dmd -v output)
	$(LI $(BUGZILLA 4004): DMD 2.042 CTFE regression with functions taking ref parameters)
	$(LI $(BUGZILLA 4005): std.c.stdlib.exit in CTFE and more)
	$(LI $(BUGZILLA 4011): Incorrect function overloading using mixins)
	$(LI $(BUGZILLA 4019): [CTFE] Adding an item to an empty AA)
	$(LI $(BUGZILLA 4020): [ICE][CTFE] struct postblit in CTFE)
	$(LI $(BUGZILLA 4027): Closures in CTFE generate wrong code)
	$(LI $(BUGZILLA 4029): CTFE: cannot invoke delegate returned from function)
    )
)


$(VERSION 057, Mar 7, 2010, =================================================,

    $(WHATSNEW
	$(LI Warnings no longer halt the parsing/semantic passes, though they still return
	 an error status and still do not generate output files. They also no longer count
	 as errors when testing with "compiles" traits.)
	$(LI Added $(B -wi) switch for $(BUGZILLA 2567))
	$(LI Associative array contents can now be compared for equality)
	$(LI Add simple spell checking.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 2321): spec on inline asm can be misunderstood)
	$(LI $(BUGZILLA 2463): No line number in "statement is not reachable" warning)
	$(LI $(BUGZILLA 3029): Bug in array value mangling rule)
	$(LI $(BUGZILLA 3306): bad function/delegate literal generated into header files)
	$(LI $(BUGZILLA 3373): bad codeview debug info for long and ulong)
	$(LI Posix only, $(BUGZILLA 3420): [PATCH] Allow string import of files using subdirectories)
	$(LI $(BUGZILLA 3450): incorrect result for is (typeof({ ... }())) inside a struct)
	$(LI $(BUGZILLA 3500): super behaves differently with -inline)
	$(LI $(BUGZILLA 3558): Optimizer bug results in false if condition being taken)
	$(LI $(BUGZILLA 3670): Declarator grammar rule is broken)
	$(LI $(BUGZILLA 3710): Typo in allMembers description?)
	$(LI $(BUGZILLA 3736): corrupted struct returned by function with optimizations (-O))
	$(LI $(BUGZILLA 3737): SEG-V at expression.c:6255 from bad opDispatch)
	$(LI $(BUGZILLA 3768): reapeted quotes in ddoc.html)
	$(LI $(BUGZILLA 3769): Regression: Segfault(constfold.c) array literals and case statements)
	$(LI $(BUGZILLA 3775): Segfault(cast.c): casting no-parameter template function using property syntax)
	$(LI $(BUGZILLA 3781): ICE(interpret.c): using no-argument C-style variadic function in CTFE)
	$(LI $(BUGZILLA 3792): Regression: "non-constant expression" for a template inside a struct using a struct initializer)
	$(LI $(BUGZILLA 3803): compiler segfaults)
	$(LI $(BUGZILLA 3840): Jump to: section in the docs should be sorted)
    )
)

$(VERSION 056, Jan 29, 2010, =================================================,

    $(WHATSNEW
	$(LI Clarification: function returns are not lvalues)
	$(LI Add $(B -map) command line switch)
	$(LI Delegates and function pointers may be used in CTFE)
	$(LI Delegate literals and function literals may be used in CTFE)
	$(LI Lazy function parameters may now be used in CTFE)
	$(LI Slicing of char[] arrays may now be used in CTFE)
    )
    $(BUGSFIXED
	$(LI $(CPPBUGZILLA 48): Internal error: cgreg 784)
	$(LI $(BUGZILLA 1298): CTFE: tuple foreach bugs)
	$(LI $(BUGZILLA 1790): CTFE: foreach(Tuple) won't compile if Tuple contains string)
	$(LI $(BUGZILLA 2101): CTFE: Please may I use mutable arrays at compile time?)
	$(LI Partial fix for $(BUGZILLA 3569), stops the stack overflow)
	$(LI $(BUGZILLA 3668): foreach over typedef'd array crashes dmd)
	$(LI $(BUGZILLA 3674): forward reference error with multiple overloads with same name)
	$(LI $(BUGZILLA 3685): Regression(D1 only): DMD silently exits on valid code)
	$(LI $(BUGZILLA 3687): Array operation "slice times scalar" tramples over memory)
	$(LI $(BUGZILLA 3719): forward references can cause out-of-memory error)
	$(LI $(BUGZILLA 3723): Regression: forward referenced enum)
	$(LI $(BUGZILLA 3724): bug in Expression::arraySyntaxCopy (null pointer dereference on struct->union->struct))
	$(LI $(BUGZILLA 3726): Regression: ICE(mangle.c 81): struct forward reference with static this)
	$(LI $(BUGZILLA 3740): Regression: class with fwd reference of a nested struct breaks abstract)
    )
)

$(VERSION 055, Jan 1, 2010, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 3663): struct forward reference regresssion)
	$(LI $(BUGZILLA 3664): struct forward declaration causes enum to conflict with itself)
    )
)

$(VERSION 054, Dec 30, 2009, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(CPPBUGZILLA 45): Internal error: cgcod 1594)
	$(LI $(CPPBUGZILLA 46): Constant folding with long doubles)
	$(LI $(NG_digitalmars_D 103391): D1 garbage collector + threads + malloc = garbage?)
	$(LI $(BUGZILLA 282): Bizarre circular import nested name invisibility issue)
	$(LI $(BUGZILLA 390): Cannot forward reference enum nested in struct)
	$(LI $(BUGZILLA 400): forward reference error; no propety X for type Y (struct within struct))
	$(LI $(BUGZILLA 1160): enums can not be forward referenced)
	$(LI $(BUGZILLA 1564): Forward reference error for enum in circular import)
	$(LI $(BUGZILLA 2029): Typesafe variadic functions don't work in CTFE)
	$(LI $(BUGZILLA 2816): Sudden-death static assert is not very useful)
	$(LI $(BUGZILLA 3455): Some Unicode characters not allowed in identifiers)
	$(LI $(BUGZILLA 3575): CTFE: member structs not initialized correctly)
	$(LI $(BUGZILLA 3584): DeclDef rule is missing entries)
	$(LI $(BUGZILLA 3585): Duplicate clauses in EqualExpression and RelExpression rules)
	$(LI $(BUGZILLA 3587): Aggregate rule references undefined Tuple)
	$(LI $(BUGZILLA 3588): WithStatement rule references unspecified Symbol)
	$(LI $(BUGZILLA 3589): BaseClassList and InterfaceClasses rules are incorrect, missing ',')
	$(LI $(BUGZILLA 3590): FunctionParameterList rule is missing)
	$(LI $(BUGZILLA 3591): TemplateIdentifier rule is misspelled)
	$(LI $(BUGZILLA 3592): ClassTemplateDeclaration and FunctionTemplateDeclaration rules are unreferenced)
	$(LI $(BUGZILLA 3593): IntegerExpression rule unspecified)
	$(LI $(BUGZILLA 3594): AsmPrimaryExp rule references unspecified rules)
	$(LI $(BUGZILLA 3595): Several rules are missing ':' after rule name)
	$(LI $(BUGZILLA 3601): Debug and Release builds of DMD produce different object files)
	$(LI $(BUGZILLA 3611): Enum forward referencing regression)
	$(LI $(BUGZILLA 3612): ExpressionList is undefined)
	$(LI $(BUGZILLA 3617): CTFE: wrong code for if(x) where x is int or smaller)
	$(LI $(BUGZILLA 3628): can't cast null to int)
	$(LI $(BUGZILLA 3633): Optimizer causes access violation)
	$(LI $(BUGZILLA 3645): manifest constant (enum) crashes dmd)
    )
)

$(VERSION 053, Dec 3, 2009, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 111): appending a dchar to a char[])
	$(LI $(BUGZILLA 370): Compiler stack overflow on recursive typeof in function declaration.)
	$(LI $(BUGZILLA 2229): ICE(template.c) instantiating an invalid variadic template with more than one argument)
	$(LI $(BUGZILLA 2967): spec does not mention that inline asm is a valid "return" statement)
	$(LI $(BUGZILLA 3115): &gt;&gt;&gt; and &gt;&gt;&gt;= generate wrong code)
	$(LI $(BUGZILLA 3171): % not implemented correctly for floats)
	$(LI $(BUGZILLA 3381): [tdpl] Incorrect assessment of overriding in triangular-shaped hierarchy)
	$(LI $(BUGZILLA 3469): ICE(func.c): Regression. Calling non-template function as a template, from another module)
	$(LI $(BUGZILLA 3495): Segfault(typinf.c) instantiating D variadic function with too few arguments)
	$(LI $(BUGZILLA 3496): ICE(cgelem.c, optimizer bug) cast(void *)(x&1)== null.)
	$(LI $(BUGZILLA 3502): Fix for dropped Mac OS X 10.5)
	$(LI $(BUGZILLA 3521): Optimized code access popped register)
	$(LI $(BUGZILLA 3540): Another DWARF line number fix)
    )
)

$(VERSION 052, Nov 12, 2009, =================================================,

    $(WHATSNEW
	$(LI OSX versions 10.5 and older are no longer supported.)
    )
    $(BUGSFIXED
	$(LI Works on OSX 10.6 now.)
    )
)

$(VERSION 051, Nov 5, 2009, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI Problem with complicated array op expressions)
	$(LI $(BUGZILLA 195): DDoc generates bad output when example contains "protected" attribute)
	$(LI $(BUGZILLA 424): Unexpected OPTLINK Termination at EIP=0044C37B (too many fixups))
	$(LI $(BUGZILLA 874): Bad codegen: wrong value variable in tuple foreach, D1 only)
	$(LI $(BUGZILLA 1117): ddoc generates corrupted docs if code examples contain attributes with colons)
	$(LI $(BUGZILLA 1812): DDOC - Unicode identifiers are not correctly marked.)
	$(LI $(BUGZILLA 2862): ICE(template.c) using type tuple as function argument)
	$(LI $(BUGZILLA 3292): ICE(todt.c) when using a named mixin with an initializer as template alias parameter)
	$(LI $(BUGZILLA 3397): Unintended function call to static opCall)
	$(LI $(BUGZILLA 3401): Compiler crash on invariant + method overload)
	$(LI $(BUGZILLA 3422): ICE(cgcod.c) Structs with default initializers bigger than register size cannot be default parameters)
	$(LI $(BUGZILLA 3426): ICE(optimize.c): struct literal with cast, as function default parameter.)
	$(LI $(BUGZILLA 3432): ICE(e2ir.c): casting template expression)
    )
)

$(VERSION 050, Oct 14, 2009, =================================================,

    $(WHATSNEW
	$(LI Use $(B -X) to generate JSON files.)
    )
    $(BUGSFIXED
	$(LI Fold in patch from $(BUGZILLA 1170))
	$(LI $(BUGZILLA 923): No constant folding for template value default arguments, D1 only)
	$(LI $(BUGZILLA 1534): Can't mix in a case statement.)
	$(LI $(BUGZILLA 2423): Erroneous unreachable statement warning)
	$(LI $(BUGZILLA 3392): a cast of this to void in tango.core.Thread is not allowed)
    )
)

$(VERSION 049, Oct 11, 2009, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 258): Undefined identifier error for circular import)
	$(LI $(BUGZILLA 928): nested struct definition in unittest section of a templated class, hangs DMD)
	$(LI $(BUGZILLA 1140): ICE(cod1.c) casting last function parameter to 8 byte value)
	$(LI $(BUGZILLA 1592): dmd fail to resolve class symbol when i put files in a package)
	$(LI $(BUGZILLA 1787): Compiler segfaults on circular references.)
	$(LI $(BUGZILLA 1897): ICE(template.c) with tuple delegate)
	$(LI $(BUGZILLA 1934): ICE(e2ir.c) using static array as AA key)
	$(LI $(BUGZILLA 2229): ICE(template.c) instantiating an invalid variadic template with more than one argument)
	$(LI $(BUGZILLA 2687): ICE(statement.c): tuple foreach in an erroneous template.)
	$(LI $(BUGZILLA 2773): ICE(go.c) array assignment through a pointer, only with -O.)
	$(LI $(BUGZILLA 2829): ICE(expression.c) static array block-initialized in struct literal)
	$(LI $(BUGZILLA 2851): Segfault(expression.c) using C-style struct initializer with too few arguments)
	$(LI $(BUGZILLA 3006): ICE(e2ir.c, tocsym.c) template module using array operation)
	$(LI $(BUGZILLA 3041): Array slices can be compared to their element type: bad codegen or ICE)
	$(LI $(BUGZILLA 3101): Stack overflow: declaring aggregate member twice with static if)
	$(LI $(BUGZILLA 3174): ICE(mtype.c): Compiler crash or compiler error with auto returns and const / immutable / invarient / pure)
	$(LI $(BUGZILLA 3176): Compiler hangs on poorly formed mixin in variadic template)
	$(LI $(BUGZILLA 3261): compiler crash with mixin and forward reference)
	$(LI $(BUGZILLA 3286): Default parameter prevents to resolve inter-module circular dependency)
	$(LI $(BUGZILLA 3301): Undefined identifier error dependent on order of imports when a circular import is involved)
	$(LI $(BUGZILLA 3325): ICE(func.c) function literal with post-contract)
	$(LI $(BUGZILLA 3343): Crash by "auto main(){}")
	$(LI $(BUGZILLA 3344): ICE(e2ir.c) returning an invalid function from main())
	$(LI $(BUGZILLA 3357): ICE(cod1.c) using 'in' with a static char array as AA key)
	$(LI $(BUGZILLA 3366): Segfault(declaration.c) variadic template with unmatched constraint)
	$(LI $(BUGZILLA 3374): [tdpl] ICE(init.c): Associative array type not inferred)
    )
)

$(VERSION 048, Oct 5, 2009, =================================================,

    $(WHATSNEW
	$(LI Compiler now detects some cases of illegal null dereferencing when compiled with -O)
	$(LI $(BUGZILLA 2905): Faster +-*/ involving a floating-pointing literal)
    )
    $(BUGSFIXED
	$(LI gdb stack trace should work now)
	$(LI $(BUGZILLA 302): in/out contract inheritance yet to be implemented)
	$(LI $(BUGZILLA 718): ICE(cgcod.c) with int /= cast(creal))
	$(LI $(BUGZILLA 814): lazy argument + variadic arguments = segfault)
	$(LI $(BUGZILLA 1168): Passing a .stringof of an expression as a template value parameter results in the string of the type)
	$(LI $(BUGZILLA 1571): Segfault(class.c) const on function parameters not carried through to .di file)
	$(LI $(BUGZILLA 1731): forward reference of function type alias resets calling convention)
	$(LI $(BUGZILLA 2202): Error getting type of non-static member of a class)
	$(LI $(BUGZILLA 2469): ICE(cod1.c) arbitrary struct accepted as struct initializer)
	$(LI $(BUGZILLA 2697): Cast of float function return to ulong or uint gives bogus value)
	$(LI $(BUGZILLA 2702): Struct initialisation silently inserts deadly casts)
	$(LI $(BUGZILLA 2839): ICE(cgcs.c) with int /= imaginary)
	$(LI $(BUGZILLA 3049): ICE(cod4.c) or segfault: Array operation on void[] array)
	$(LI $(BUGZILLA 3059): Nonsensical complex op= should be illegal)
	$(LI $(BUGZILLA 3160): ICE(cgcod.c 1511-D1) or bad code-D2 returning string from void main)
	$(LI $(BUGZILLA 3304): Segfault using 'is' with a pointer enum.)
	$(LI $(BUGZILLA 3305): Segfault(expression.c) with recursive struct template alias expressions)
	$(LI $(BUGZILLA 3335): minor warning cleanups)
	$(LI $(BUGZILLA 3336): ICE(glue.c) declaring AA with tuple key, only with -g)
	$(LI $(BUGZILLA 3353): storage class of a member function is propagated to default arguments)
    )
)

$(VERSION 047, Sep 2, 2009, =================================================,

    $(WHATSNEW
	$(LI $(BUGZILLA 3122): [patch] Adding support for fast and reliable build tools to the frontend)
	$(LI Added support for:
---
a[i].var = e2
---
	and:
---
a[] = e
---
	in CTFE. $(I (thanks, Don!)))
	$(LI Member functions can now be used in CTFE)
	$(LI Operator overloading can now be used in CTFE)
	$(LI Nested functions can now be used in CTFE)
	$(LI CTFE error messages now explain why the function could not be
	interpreted at compile time)
    )
    $(BUGSFIXED
	$(LI Fixed bug processing spaces in dmd's directory)
	$(LI $(BUGZILLA 601): statement.html - Formatting/markup errors in BNF)
	$(LI $(BUGZILLA 1461): Local variable as template alias parameter breaks CTFE)
	$(LI $(BUGZILLA 1605): break in switch with goto breaks in ctfe)
	$(LI $(BUGZILLA 1948): CTFE fails when mutating a struct in an array)
	$(LI $(BUGZILLA 1950): CTFE doesn't work correctly for structs passed by ref)
	$(LI $(BUGZILLA 2569): static arrays in CTFE functions don't compile)
	$(LI $(BUGZILLA 2575): gdb can not show code)
	$(LI $(BUGZILLA 2604): DW_TAG_module and GDB)
	$(LI $(BUGZILLA 2940): null is null cannot be evaluated at compile time)
	$(LI $(BUGZILLA 2960): CTFE rejects static array to dynamic array casts)
	$(LI $(BUGZILLA 3039): -vtls compiler flag not listed in man file)
	$(LI $(BUGZILLA 3165): What kind of integer division does D use?)
	$(LI $(BUGZILLA 3166): "positive" -> "non-negative" in modulo operator description)
	$(LI $(BUGZILLA 3168): Declaring structs as incomplete types no longer works)
	$(LI $(BUGZILLA 3170): Forward reference of nested class fails if outer class is not plain)
	$(LI $(BUGZILLA 3183): Spec of align attribute needs work)
	$(LI $(BUGZILLA 3186): corrections for http://www.digitalmars.com/d/2.0/dmd-osx.html)
	$(LI $(BUGZILLA 3192): asm in a anonymous delegate crash the compiler)
	$(LI $(BUGZILLA 3196): Segfault(mtype.c) after almost any error involving a delegate literal)
	$(LI $(BUGZILLA 3205): CTFE: $ cannot be used in lvalues)
	$(LI $(BUGZILLA 3246): ICE(init.c) using indexed array initializer on local array)
	$(LI $(BUGZILLA 3264): -O causes wrong "used before set" error when using enum.)
    )
)

$(VERSION 046, Jul 6, 2009, =================================================,

    $(WHATSNEW
	$(LI $(BUGZILLA 3080): dmd should output compilation errors to stderr, not stdout)
    )
    $(BUGSFIXED
	$(LI Fix dmd crash on multicore Windows.)
	$(LI $(BUGZILLA 106): template - mixin sequence)
	$(LI $(BUGZILLA 810): Cannot forward reference template)
	$(LI $(BUGZILLA 852): ICE(toir.c) using local class in non-static nested function in nested static function)
	$(LI $(BUGZILLA 854): TypeTuple in anonymous delegate causes ice in glue.c)
	$(LI $(BUGZILLA 1054): regression: circular aliases cause compiler stack overflow)
	$(LI $(BUGZILLA 1343): Various errors with static initialization of structs and arrays)
	$(LI $(BUGZILLA 1358): ICE(root.c) on Unicode codepoints greater than 0x7FFFFFFF)
	$(LI $(BUGZILLA 1459): ICE(cgcs.c) on attempt to set value of non-lvalue return struct)
	$(LI $(BUGZILLA 1524): ICE(constfold.c) on using "is" with strings in CTFE)
	$(LI $(BUGZILLA 1984): Assertion failure: 'e1->type' on line 1198 in file 'constfold.c')
	$(LI $(BUGZILLA 2323): ICE(cgcs.c): taking address of a method of a temporary struct)
	$(LI $(BUGZILLA 2429): std.stream.File incorrect flag parsing and sharing mode)
	$(LI $(BUGZILLA 2432): complex alias -> mtype.c:125: virtual Type* Type::syntaxCopy(): Assertion `0' failed.)
	$(LI $(BUGZILLA 2603): ICE(cgcs.c) on subtracting string literals)
	$(LI $(BUGZILLA 2843): ICE(constfold.c) with is-expression with invalid dot-expression in is-expression involving typeid)
	$(LI $(BUGZILLA 2884): ICE: Assert: 'template.c', line 3773, 'global.errors')
	$(LI $(BUGZILLA 2888): [PATCH] speedup for float * 2.0)
	$(LI $(BUGZILLA 2915): [Patch]: Optimize -a*-b into a*b)
	$(LI $(BUGZILLA 2923): -O generates bad code for ?:)
	$(LI $(BUGZILLA 2932): bad e_ehsize (36 != 52))
	$(LI $(BUGZILLA 2952): Segfault on exit when using array ops with arrays of doubles larger than 8 elements)
	$(LI $(BUGZILLA 3003): Need to implicitly add () on member template function calls)
	$(LI $(BUGZILLA 3014): ICE(template.c) instantiating template with tuple)
	$(LI $(BUGZILLA 3016): Errors in the documentation of std.math.acos)
	$(LI $(BUGZILLA 3026): Segfault with incomplete static array initializer)
	$(LI $(BUGZILLA 3044): Segfault(template.c) instantiating struct tuple constructor with zero arguments.)
	$(LI $(BUGZILLA 3078): NaN reported as equal to zero)
	$(LI $(BUGZILLA 3114): optlink failing on multicore machines)
	$(LI $(BUGZILLA 3117): dmd crash by *1)
	$(LI $(BUGZILLA 3128): Internal error: ..\ztc\cod4.c 2737)
	$(LI $(BUGZILLA 3130): Crashed with triple stars)
    )
)

$(VERSION 045, May 11, 2009, =================================================,

    $(WHATSNEW
	$(LI Folded in compiler/library changes by Unknown W. Brackets
	to support Solaris.)
	$(LI Migrate Posix uses of std.c.linux.linux to std.c.posix.posix)
	$(LI added .typeinfo to ClassInfo $(BUGZILLA 2836): Navigate from ClassInfo to TypeInfo)
    )
    $(BUGSFIXED
	$(LI Fix instruction scheduler bug on Linux)
        $(LI $(BUGZILLA 642): error: mixin "static this" into where it cannot be)
        $(LI $(BUGZILLA 713): circular const definitions with module operator "." cause the compiler to segfault)
        $(LI $(BUGZILLA 752): Assertion failure: 'e->type->ty != Ttuple' on line 4518 in file 'mtype.c')
        $(LI $(BUGZILLA 858): Forward reference to struct inside class crashes the compiler)
        $(LI $(BUGZILLA 884): Segfault in recursive template)
        $(LI $(BUGZILLA 934): Segfault taking mangleof a forward reference in a  template.)
        $(LI $(BUGZILLA 1011): illegal import declaration causes compile time segfault)
        $(LI $(BUGZILLA 1054): regression: circular aliases cause segfaults)
        $(LI $(BUGZILLA 1061): "asm inc [;" segfaults compiler.)
        $(LI $(BUGZILLA 1195): regression: aliasing an enum member causes compile time segfaults)
        $(LI $(BUGZILLA 1305): Compiler hangs with templated opCmp returning templated class)
        $(LI $(BUGZILLA 1385): Stack Overflow with huge array literal.)
        $(LI $(BUGZILLA 1428): Segfault on template specialization with delegates and tuples)
        $(LI $(BUGZILLA 1586): DMD and GDC segfaults on incomplete code segment.)
        $(LI $(BUGZILLA 1791): Segmentation fault with anon class in anon class and non-constant variable init)
        $(LI $(BUGZILLA 1916): segfault on invalid string concat)
        $(LI $(BUGZILLA 1946): Compiler crashes on attempt to implicit cast const typedef to non-const.)
        $(LI $(BUGZILLA 2048): DMD crash on CTFE that involves assigning to member variables of void-initialized struct)
        $(LI $(BUGZILLA 2061): wrong vtable call with multiple interface inheritance)
        $(LI $(BUGZILLA 2215): Forward reference enum with base type within a struct causes Segmentation Fault in the compiler)
        $(LI $(BUGZILLA 2309): Crash on a template mixing in a variadic template with an undefined template identifier)
        $(LI $(BUGZILLA 2346): ICE when comparing typedef'd class)
        $(LI $(BUGZILLA 2821): struct alignment inconsistent with C for { int, long })
	$(LI $(BUGZILLA 2920): recursive templates blow compiler stack)
    )
)

$(VERSION 044, Apr 9, 2009, =================================================,

    $(WHATSNEW
	$(LI Added std.c.posix.* to Phobos.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 675): %a format has an out-by-1 bug for denormals.)
	$(LI $(BUGZILLA 2064): Segfault with mixin(for/foreach) with empty loop body)
	$(LI $(BUGZILLA 2199): Segfault using array operation in function call)
	$(LI $(BUGZILLA 2203): typeof(class.template.foo) crashes compiler)
    )
)

$(VERSION 043, Apr 6, 2009, =================================================,

    $(WHATSNEW
	$(LI Added FreeBSD 7.1 support.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 2796): Dependency on libstdc++-v3)
    )
)

$(VERSION 042, Mar 31, 2009, =================================================,

    $(WHATSNEW
	$(LI Added response files for Linux and OSX)
	$(LI On Windows, if there are multiple source files on the command
	 line they are now read with a background thread. This may speed up
	 compilation.)
	$(LI Folded in patches for LDC compatibility from Tomas Lindquist Olsen)
	$(LI The $(B Posix) version identifier can now be set even though
	 it is reserved and predefined, because many build systems and makefiles
	 try to set it.)
    )
    $(BUGSFIXED
	$(LI std.math.hypot is wrong for subnormal arguments)
	$(LI Fix bug where / wasn't recognized as a path separator on Windows.)
	$(LI $(BUGZILLA 920): Fix one more out of date reference to 'auto' rather than 'scope')
	$(LI $(BUGZILLA 1923): GC optimization for contiguous pointers to the same page)
	$(LI $(BUGZILLA 2319): "Win32 Exception" not very useful)
	$(LI $(BUGZILLA 2570): Patch for some mistakes in Ddoc comments)
	$(LI $(BUGZILLA 2591): custom allocator new argument should be size_t instead of uint)
	$(LI $(BUGZILLA 2689): seek behaves incorrectly on MAC OSX)
	$(LI $(BUGZILLA 2692): alignment of double on x86 linux is incorrect)
	$(LI $(BUGZILLA 2705): Response file size cannot exceed 64kb)
	$(LI $(BUGZILLA 2711): -H produces bad headers files if function defintion is templated and have auto return value)
	$(LI $(BUGZILLA 2731): Errors in associative array example)
	$(LI $(BUGZILLA 2743): dumpobj gives "buss error" on Tiger)
	$(LI $(BUGZILLA 2744): wrong init tocbuffer of forstatement)
	$(LI $(BUGZILLA 2745): missing token tochars in lexer.c)
	$(LI $(BUGZILLA 2747): improper toCBuffer of funcexp)
	$(LI $(BUGZILLA 2750): Optimize slice copy with size known at compile time)
	$(LI $(BUGZILLA 2751): incorrect scope storage class vardeclaration tocbuffer)
	$(LI $(BUGZILLA 2767): DMD incorrectly mangles NTFS stream names)
	$(LI $(BUGZILLA 2772): lib can't open response file)
    )
)

$(VERSION 041, Mar 3, 2009, =================================================,

    $(WHATSNEW
	$(LI Added buildable dmd source.)
        $(LI Improved accuracy of exp, expm1, exp2, sinh, cosh, tanh on Mac OSX,
           and tripled speed on all platforms.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1629): Link error: Previous Definition Different:  blablah__initZ)
	$(LI $(BUGZILLA 1662): Falls back to libphobos if -debuglib isn't used when -g is)
	$(LI $(BUGZILLA 1681): cast(real) ulong.max == 0)
	$(LI $(BUGZILLA 2416): Slice of typedef'ed array should preserve the typedef'ed type)
	$(LI $(BUGZILLA 2582): Significantly Increased Compile Times For DWT)
	$(LI $(BUGZILLA 2670): std.file.read() should read files of 0 length)
	$(LI $(BUGZILLA 2673): Static constructors sometimes do not run when compiling with -lib)
	$(LI $(BUGZILLA 2678): for loops are already assumed to terminate)
	$(LI $(BUGZILLA 2679): Spurious "warning - " messages and erratic behaviour with is(typeof({void function}())))
	$(LI $(BUGZILLA 2690): DMD aborts with MALLOC_CHECK_ set)
    )
)

$(VERSION 040, Feb 11, 2009, =================================================,

    $(WHATSNEW
	$(LI Added Mac OSX support.)
	$(LI Separated bin and lib directories into windows, linux,
	and osx.)
	$(LI No longer need to download dmc to use the windows version.)
	$(LI Use version(OSX) for Mac OSX. Although version(darwin) is
	also supported for the time being, it is deprecated.)
    )
    $(BUGSFIXED
    )
)

$(VERSION 039, Jan 14, 2009, =================================================,

    $(WHATSNEW
	$(LI Improved speed of long division.)
	$(LI Added predefined $(LINK2 version.html#PredefinedVersions, version)
	$(B D_Ddoc) which is predefined when $(B -D) switch is thrown.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 2517): DDoc omits abstract on classes)
	$(LI $(BUGZILLA 2518): scope(success) not execuate and RAII variable destructor is not called)
	$(LI $(BUGZILLA 2519): Segfault when >> used in an invalid slice)
	$(LI $(BUGZILLA 2527): Alias Template Params Are Always Same Type As First Instantiation (according to typeof(x).stringof))
	$(LI $(BUGZILLA 2531): DDoc not generated correctly for struct methods inside static if)
	$(LI $(BUGZILLA 2537): compiler crashes on this code:)
	$(LI $(BUGZILLA 2542): array casts behave differently at compile and runtime)
    )
)

$(VERSION 038, Dec 11, 2008, =================================================,

    $(WHATSNEW
	$(LI Changed IUnknown to use the extern(System) interface rather
	that extern(Windows).)
	$(LI Added Partial IFTI $(BUGZILLA 493))
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1518): Crash using 'scope', 'with' and undefined 'RegExp')
	$(LI $(BUGZILLA 1685): Array index is evaluated twice)
	$(LI $(BUGZILLA 1963): -H creates broken headers)
	$(LI $(BUGZILLA 2041): Spec implies relationship between interfaces and COM objects)
	$(LI $(BUGZILLA 2105): added patch)
	$(LI $(BUGZILLA 2468): result type of AndAndExp and OrOrExp deduced incorrectly)
	$(LI $(BUGZILLA 2489): import in struct causes assertion failure)
	$(LI $(BUGZILLA 2490): extern(C++) can not handle structs as return types)
	$(LI $(BUGZILLA 2492): ICE building on Linux with -lib option)
	$(LI $(BUGZILLA 2499): Template alias default value cannot be template instantiation)
	$(LI $(BUGZILLA 2500): template struct methods are left unresolved if imported from multiple modules)
	$(LI $(BUGZILLA 2501): member function marked as final override ignores override requirements)
	$(LI Incorporated some of the patches from $(BUGZILLA 1752))
    )
)

$(VERSION 037, Nov 25, 2008, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 313): Fully qualified names bypass private imports)
	$(LI $(BUGZILLA 341): Undocumented function void print() in object.d)
	$(LI $(BUGZILLA 929): Resizing array of associative arrays (uint[char[]][]) causes infinite loop / hang)
	$(LI $(BUGZILLA 1372): Compiler accepts pragma(msg,))
	$(LI $(BUGZILLA 1610): Enum.stringof is int, not the name of the enum)
	$(LI $(BUGZILLA 1663): pragma(lib, "") don't work on linux)
	$(LI $(BUGZILLA 1797): Documentation comments - ///)
	$(LI $(BUGZILLA 2326): Methods within final class are not considered final when optimizing)
	$(LI $(BUGZILLA 2429): std.stream.File incorrect flag parsing and sharing mode)
	$(LI $(BUGZILLA 2431): Internal error: ../ztc/cgcod.c 1031 when using -O)
	$(LI $(BUGZILLA 2470): Cannot build libraries from other libraries)
	$(LI unittest functions now always use D linkage)
    )
)

$(VERSION 036, Oct 20, 2008, =================================================,

    $(WHATSNEW
	$(LI Improved performance of AAs by rebalancing trees when rehashing.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1229): Linker fills disk)
	$(LI $(BUGZILLA 2340): Template properties don't work)
	$(LI $(BUGZILLA 2365): compilation error: static const array in struct)
	$(LI $(BUGZILLA 2368): Calling a function with an address of another function, then calling a returned object is rejected)
	$(LI $(BUGZILLA 2373): freebsd select does not accept values  &gt; 999,999)
	$(LI $(BUGZILLA 2376): CTFE fails on array literal of array literals of chars)
	$(LI $(BUGZILLA 2380): static struct initializer accepted as non static initializer is not documented)
	$(LI $(BUGZILLA 2383): default arguments can implicitly access private global variables that are not visible at call site)
	$(LI $(BUGZILLA 2385): spec says all structs are returned via hidden pointer on linux, but it uses registers)
	$(LI $(BUGZILLA 2390): Missing warning on conversion from int to char)
    )
)

$(VERSION 035, Sep 2, 2008, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1627): ICE with a method called _ctor)
	$(LI $(BUGZILLA 1633): Nonsensical "C style cast illegal" message with !is)
	$(LI $(BUGZILLA 1637): regression: new unittest failure in std/math2.d, odd cosh() behavior)
	$(LI $(BUGZILLA 1763): EndianStream doesn't handle ubyte/byte read/writes. Simple fix.)
	$(LI $(BUGZILLA 1771): dmd fails to execute on linux)
	$(LI $(BUGZILLA 1773): excessively long integer literal)
	$(LI $(BUGZILLA 1785): Mixing in an incorrect array literal causes infinite loop.)
	$(LI $(BUGZILLA 2176): Assertion failure: 'sz == es2->sz' on line 1339 in file 'constfold.c' (concatenating strings of different types))
	$(LI $(BUGZILLA 2183): Bad formatting in std.c.stdlib)
	$(LI $(BUGZILLA 2232): DMD generates invalid code when an object file is compiled -inline)
	$(LI $(BUGZILLA 2241): DMD abort)
	$(LI $(BUGZILLA 2243): const bool = is(function literal), badly miscast)
	$(LI $(BUGZILLA 2262): -inline breaks -lib library)
	$(LI $(BUGZILLA 2286): movmskpd compiled incorrectly)
	$(LI $(BUGZILLA 2308): CTFE crash on foreach over nonexistent variable)
	$(LI $(BUGZILLA 2311): Static destructors in templates are never run)
	$(LI $(BUGZILLA 2314): Crash on anonymous class variable instantiation)
	$(LI $(BUGZILLA 2317): asm offsetof generates: Internal error: ../ztc/cod3.c 2651)
    )
)

$(VERSION 034, Aug 7, 2008, =================================================,

    $(WHATSNEW
	$(LI Now supports $(LINK2 arrays.html#array-operations, array operations).)
    )
    $(BUGSFIXED
	$(LI Added hash to generated module names when building libs to reduce collisions)
	$(LI $(BUGZILLA 1622): parameters to TypeInfo_Struct.compare seem to be switched around.)
	$(LI $(BUGZILLA 2216): bad code generation for static arrays of zero length static arrays)
	$(LI $(BUGZILLA 2223): Typo in error message)
	$(LI $(BUGZILLA 2242): linux system calls are canceled by GC)
	$(LI $(BUGZILLA 2247): bad header file generated for if (auto o = ...) {})
	$(LI $(BUGZILLA 2248): .di should be a supported file extension)
	$(LI $(BUGZILLA 2250): Update of user32.lib and kernel32.lib)
	$(LI $(BUGZILLA 2254): Size of executable almost triples)
	$(LI $(BUGZILLA 2258): Docs -> Inline Assembler -> Operand Types -> qword missing)
	$(LI $(BUGZILLA 2259): Assertion failure: '0' on line 122 in file 'statement.c')
	$(LI $(BUGZILLA 2269): D BUG: cosine of complex)
	$(LI $(BUGZILLA 2272): synchronized attribute documentation)
	$(LI $(BUGZILLA 2273): Whitespace is not inserted after commas)
    )
)

$(VERSION 033, Jul 11, 2008, =================================================,

    $(WHATSNEW
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 870): contradictory error messages for templates)
	$(LI $(BUGZILLA 2207): overload resolution fails with deprecation)
	$(LI $(BUGZILLA 2208): Deprecated function declarations cannot use deprecated types)
	$(LI $(BUGZILLA 2209): Typo in doc for offsetof)
    )
)

$(VERSION 032, Jul 9, 2008, =================================================,

    $(WHATSNEW
	$(LI Added $(B .__vptr) and $(B .__monitor) properties for class objects
	 for use in the internal runtime library.
	)
    )
    $(BUGSFIXED
	$(LI $(NG_digitalmars_D_announce 12322): mixin regression)
	$(LI $(BUGZILLA 203): std.format.doFormat() pads width incorrectly on Unicode strings)
	$(LI $(BUGZILLA 211): Linking error with alias mixin params and anonymous methods)
	$(LI $(BUGZILLA 224): Incorrect warning "no return at end of function")
	$(LI $(BUGZILLA 252): -w and switch returns = bogus "no return at end of function" warning)
	$(LI $(BUGZILLA 253): Invalid &lt;dl&gt; tag generated by Ddoc)
	$(LI $(BUGZILLA 294): DDoc: Function templates get double and incomplete documentation)
	$(LI $(BUGZILLA 398): No way to abort compilation in a doubly recursive mixin)
	$(LI $(BUGZILLA 423): dmd ignores empty commandline arguments)
	$(LI $(BUGZILLA 515): Spec incorrect in where .offsetof can be applied)
	$(LI $(BUGZILLA 520): Invariants allowed to call public functions)
	$(LI $(BUGZILLA 542): Function parameter of a deprecated type (other than a class) is not caught)
	$(LI $(BUGZILLA 543): Function return of a deprecated type is not caught)
	$(LI $(BUGZILLA 544): Variable declared of a deprecated type (other than a class) is not caught)
	$(LI $(BUGZILLA 545): Attempt to access a static built-in property of a deprecated struct, union, enum or typedef is not caught)
	$(LI $(BUGZILLA 547): Accessing a deprecated member variable through an explicit object reference is not caught)
	$(LI $(BUGZILLA 548): Accessing a value of a deprecated enum is not caught)
	$(LI $(BUGZILLA 566): Adding non-static members and functions to classes using a template doesn't error)
	$(LI $(BUGZILLA 570): Bogus recursive mixin error)
	$(LI $(BUGZILLA 571): class instance member template returns strange value)
	$(LI $(BUGZILLA 572): parse error when using template instantiation with typeof)
	$(LI $(BUGZILLA 581): Error message w/o line number in dot-instantiated template)
	$(LI $(BUGZILLA 617): IFTI doesn't use normal promotion rules for non-template parameters)
	$(LI $(BUGZILLA 951): Missing line number: no constructor provided for a class derived from a class with no default constructor)
	$(LI $(BUGZILLA 1097): Missing line number: casting array to array of different element size)
	$(LI $(BUGZILLA 1158): Missing line number: invalid mixin outside function scope)
	$(LI $(BUGZILLA 1176): Error missing file and line number)
	$(LI $(BUGZILLA 1187): Segfault with syntax error in two-level mixin.)
	$(LI $(BUGZILLA 1194): fcmov* emmits incorrect code)
	$(LI $(BUGZILLA 1207): Documentation on destructors is confusing)
	$(LI $(BUGZILLA 1341): typeof(int) should probably be legal)
	$(LI $(BUGZILLA 1601): shr and shl error message is missing line numbers)
	$(LI $(BUGZILLA 1612): No file/line number for using an undefined label in inline assembly)
	$(LI $(BUGZILLA 1907): Error message without a line number)
	$(LI $(BUGZILLA 1912): Error without line number (Tuple, invalid value argument))
	$(LI $(BUGZILLA 1936): Error with no line number (array dimension overflow))
	$(LI $(BUGZILLA 2161): Modify compiler to pass array TypeInfo to _adEq and _adCmp instead of element TypeInfo)
	$(LI $(BUGZILLA 2166): More stuff that doesn't compile in Phobos)
	$(LI $(BUGZILLA 2178): 3 errors without line number: typeof)
    )
)

$(VERSION 031, June 18, 2008, =================================================,

    $(WHATSNEW
	$(LI Added $(LINK2 version.html#PredefinedVersions, version identifier
	 $(B D_PIC)) when $(B -fPIC) switch is used.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1383): Implicit Function Instantiation with typesafe-variadic of delegates doesn't work)
	$(LI $(BUGZILLA 1559): version statement makes code outside of it disappear)
	$(LI $(BUGZILLA 1675): "Identifier too long" error with OMF object files)
	$(LI $(BUGZILLA 1963): -H creates broken headers)
	$(LI $(BUGZILLA 2111): Protection incorrectly resolved when accessing super class' tupleof)
	$(LI $(BUGZILLA 2118): Inconsistent use of string vs invariant(char[]) in doc)
	$(LI $(BUGZILLA 2123): Anonymous class crashes)
	$(LI $(BUGZILLA 2132): CTFE: can't evaluate ~= at compile time, D2 only.)
	$(LI $(BUGZILLA 2136): typeof(super(...)) counted as a constructor call)
	$(LI $(BUGZILLA 2140): static if as final statement with no code causes containing code to be skipped)
	$(LI $(BUGZILLA 2143): Mixed-in identifier is not recognized by static if)
	$(LI $(BUGZILLA 2144): 'is' is defined to be the same as '==' for non-class and non-array types, but does not call opEquals)
	$(LI $(BUGZILLA 2146): Multiple execution of 'static this' defined in template)
	$(LI $(BUGZILLA 2149): Auto variables loose the keyword "auto" in di files generated with -H option.)
    )
)

$(VERSION 030, May 16, 2008, =================================================,

    $(WHATSNEW
	$(LI Added $(B -lib) switch to generate library files.)
	$(LI Added $(B -man) switch to browse manual.)
	$(LI When generating an executable file, only one object file
	 is now generated containing all the modules that were compiled, rather
	 than one object file per module.)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 2031): Documentation: template value parameters)
	$(LI $(BUGZILLA 2032): Documentation for creating a class on the stack is unintuitive)
	$(LI $(BUGZILLA 2033): -g + circular refs =&gt; dmd hangs)
	$(LI $(BUGZILLA 2039): -ignore switch is missing from compiler docs)
	$(LI $(BUGZILLA 2044): -g hangs DMD)
	$(LI $(BUGZILLA 2055): (ICE) Compiler crash on struct initializer with too many elements)
	$(LI $(BUGZILLA 2058): Describe hidden value passed to class member functions)
	$(LI $(BUGZILLA 2067): call from anonymous class makes access violation.)
	$(LI $(BUGZILLA 2071): spec doesn't mention pointer arithmetic with two pointer operands)
	$(LI $(BUGZILLA 2075): Spec does not specify how array literals are stored.)
	$(LI $(BUGZILLA 2084): operator ?: does not compute the tightest type)
	$(LI $(BUGZILLA 2086): Describe relationship between string and char[] more explicitly)
	$(LI $(BUGZILLA 2089): Issues with CTFE and tuple indexes)
	$(LI $(BUGZILLA 2090): Cannot alias a tuple member which is a template instance)
    )
)

$(VERSION 029, Apr 23, 2008, =================================================,

    $(WHATSNEW
	$(LI Added $(B -ignore) switch to ignore unsupported pragmas.)
	$(LI Unsupported pragmas now printed out with $(B -v) switch.)
	$(LI Incorporated Benjamin Shropshire's doc changes)
    )
    $(BUGSFIXED
	$(LI $(BUGZILLA 1712): vtbl[0] for interface not set to corresponding Interface*)
	$(LI $(BUGZILLA 1741): crash on associative array with static array as index type)
	$(LI $(BUGZILLA 1905): foreach docs inconsistency)
	$(LI $(BUGZILLA 1906): foreach cannot use index with large arrays)
	$(LI $(BUGZILLA 1908): fix closure14.d)
	$(LI $(BUGZILLA 1935): The std.recls samples in the DMD .zip are obsolete.)
	$(LI $(BUGZILLA 1967): getDirName does not seem to use altsep on windows)
	$(LI $(BUGZILLA 1978): Wrong vtable call)
	$(LI $(BUGZILLA 1991): Dmd hangs)
	$(LI $(BUGZILLA 2019): Appending a one-element array literal doesn't work)
    )
)

$(VERSION 028, Mar 6, 2008, =================================================,

$(WHATSNEW
	$(LI Added compile time error for comparing class types against $(CODE null).)
)

$(BUGSFIXED
	$(LI Fixed dwarf bug with DT_AT_upper_bound)
	$(LI $(BUGZILLA 756): IFTI for tuples only works if tuple parameter is last)
	$(LI $(BUGZILLA 1454): IFTI cant  deduce parameter if alias argument used)
	$(LI $(BUGZILLA 1661): Not possible to specialize on template with integer parameter)
	$(LI $(BUGZILLA 1809): template.c:2600)
	$(LI $(BUGZILLA 1810): MmFile anonymous mapping does not work under win32)
	$(LI $(BUGZILLA 1819): spurious warning about missing return statement after synchronized)
	$(LI $(BUGZILLA 1828): Several Thread Issues)
	$(LI $(BUGZILLA 1833): std.c.windows.windows should use enums for constants, or be more selective about use of extern(Windows))
	$(LI $(BUGZILLA 1836): Inline assembler can't use enum values as parameters.)
	$(LI $(BUGZILLA 1837): Make dmd stop flooding the console: prints content of passed parameter file)
	$(LI $(BUGZILLA 1843): Bogus unreachable statement on forward referenced struct, lacks line number)
	$(LI $(BUGZILLA 1850): The compiler accepts lower case asm registers.)
	$(LI $(BUGZILLA 1852): you get opCall missing when cast to a struct(diagnostic))
	$(LI $(BUGZILLA 1853): opCmp documentation really needs some examples)
	$(LI $(BUGZILLA 1857): Runtime segfault while profileing - jump to invalid code address)
	$(LI $(BUGZILLA 1862): asm: [ESI+1*EAX] should be a legal addr mode)
	$(LI $(BUGZILLA 1864): Variable incorrectly declared final in final class template)
	$(LI $(BUGZILLA 1865): Escape sequences are flawed.)
	$(LI $(BUGZILLA 1877): Errors in the documentation of std.math.atan2)
	$(LI $(BUGZILLA 1879): Compiler segfaults on 'scope' and 'static if')
	$(LI $(BUGZILLA 1882): Internal error: ..\ztc\cod1.c 2529)
)
)


$(VERSION 027, Feb 18, 2008, =================================================,

$(WHATSNEW
	$(LI Re-enabled auto interfaces.)
)

$(BUGSFIXED
	$(LI Fixed display of ddoc template parameters that were aliased)
	$(LI $(BUGZILLA 1072): CTFE: crash on for loop with blank increment)
	$(LI $(BUGZILLA 1435): DDoc: Don't apply DDOC_PSYMBOL everywhere)
	$(LI $(BUGZILLA 1825): local instantiation and function nesting)
	$(LI $(BUGZILLA 1837): Make dmd stop flooding the console: prints content of passed parameter file)
	$(LI $(BUGZILLA 1842): Useless linker command line output during compilation on Linux)
)
)

$(VERSION 026, Jan 20, 2008, =================================================,

$(WHATSNEW
	$(LI $(CODE WinMain) and $(CODE DllMain) can now be in template mixins.)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 1697): Internal error: ..\ztc\cgcod.c 2322 with -O)
	$(LI $(BUGZILLA 1707): '==' in TemplateParameterList in IsExpression causes segfault)
	$(LI $(BUGZILLA 1711): typeof with delegate literal not allowed as template parameter)
	$(LI $(BUGZILLA 1718): obscure exit with error code 5)
	$(LI $(BUGZILLA 1719): Compiler crash or unstable code generation with scoped interface instances)
	$(LI $(BUGZILLA 1724): Internal error: toir.c 177)
	$(LI $(BUGZILLA 1725): std.stream.BufferedFile.create should use FileMode.OutNew)
	$(LI $(BUGZILLA 1767): rejects-valid, diagnostic)
	$(LI $(BUGZILLA 1769): Typo on the page about exceptions)
	$(LI $(BUGZILLA 1773): excessively long integer literal)
	$(LI $(BUGZILLA 1779): Compiler crash when deducing more than 2 type args)
	$(LI $(BUGZILLA 1783): DMD 1.025 asserts on code with struct, template, and alias)
	$(LI $(BUGZILLA 1788): dmd segfaults without info)
)
)


$(VERSION 025, Jan 1, 2008, =================================================,

$(BUGSFIXED
	$(LI $(BUGZILLA 1111): enum value referred to by another value of same enum is considered as enum's base type, not enum type)
	$(LI $(BUGZILLA 1720): std.math.NotImplemented missing a space in message)
	$(LI $(BUGZILLA 1738): Error on struct without line number)
	$(LI $(BUGZILLA 1742): CTFE fails on some template functions)
	$(LI $(BUGZILLA 1743): interpret.c:1421 assertion failure on CTFE code)
	$(LI $(BUGZILLA 1744): CTFE: crash on assigning void-returning function to variable)
	$(LI $(BUGZILLA 1749): std.socket not thread-safe due to strerror)
	$(LI $(BUGZILLA 1753): String corruption in recursive CTFE functions)
)
)


$(VERSION 024, Nov 27, 2007, =================================================,

$(WHATSNEW
	$(LI Changed the way coverage analysis is done so it is independent
	 of order dependencies among modules.)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 70): valgrind: Conditional jump or move depends on uninitialised value(s) in elf_findstr)
	$(LI $(BUGZILLA 71): valgrind: Invalid read of size 4 in elf_renumbersyms)
	$(LI $(BUGZILLA 204): Error message on attempting to instantiate an abstract class needs to be improved)
	$(LI $(BUGZILLA 1508): dmd/linux template symbol issues)
	$(LI $(BUGZILLA 1656): illegal declaration accepted)
	$(LI $(BUGZILLA 1664): (1.23).stringof  generates bad code)
	$(LI $(BUGZILLA 1665): Internal error: ..\ztc\cod2.c 411)
)
)


$(VERSION 023, Oct 31, 2007, =================================================,

$(WHATSNEW
	$(LI Data items in static data segment &gt;= 16 bytes in size
	are now paragraph aligned.)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 318): wait does not release thread resources on Linux)
	$(LI $(BUGZILLA 322): Spawning threads which allocate and free memory leads to pause error on collect)
	$(LI $(BUGZILLA 645): Race condition in std.thread.Thread.pauseAll)
	$(LI $(BUGZILLA 689): Clean up the spec printfs!)
	$(LI $(BUGZILLA 697): No const folding on asm db,dw, etc)
	$(LI $(BUGZILLA 706): incorrect type deduction for array literals in functions)
	$(LI $(BUGZILLA 708): inline assembler: "CVTPS2PI mm, xmm/m128" fails to compile)
	$(LI $(BUGZILLA 709): inline assembler: "CVTPD2PI mm, xmm/m128" fails to compile)
	$(LI $(BUGZILLA 718): Internal error: ../ztc/cgcod.c 562)
	$(LI $(BUGZILLA 723): bad mixin of class definitions at function level: func.c:535: virtual void FuncDeclaration::semantic3(Scope*): Assertion `0' failed)
	$(LI $(BUGZILLA 725): expression.c:6516: virtual Expression* MinAssignExp::semantic(Scope*): Assertion `e2->type->isfloating()' failed.)
	$(LI $(BUGZILLA 726): incorrect error line for "override" mixin)
	$(LI $(BUGZILLA 729): scope(...) statement in SwitchBody causes compiler to segfault)
	$(LI $(BUGZILLA 733): std.conv.toFloat does not catch errors)
	$(LI $(BUGZILLA 1258): Garbage collector loses memory upon array concatenation)
	$(LI $(BUGZILLA 1478): Avoid libc network api threadsafety issues)
	$(LI $(BUGZILLA 1480): std.stream throws the new override warning all over the place)
	$(LI $(BUGZILLA 1483): Errors in threads not directed to stderr)
	$(LI $(BUGZILLA 1491): Suppress SIGPIPE when sending to a dead socket)
	$(LI $(BUGZILLA 1557): std.zlib allocates void[]s instead of ubyte[]s, causing leaks.)
	$(LI $(BUGZILLA 1562): Deduction of template alias parameter fails)
	$(LI $(BUGZILLA 1575): Cannot do assignment of tuples)
	$(LI $(BUGZILLA 1593): ICE compiler crash empty return statement in function)
	$(LI $(BUGZILLA 1613): DMD hangs on syntax error)
	$(LI $(BUGZILLA 1618): Typo in std\system.d)
)
)

$(VERSION 022, Oct 1, 2007, =================================================,

$(BUGSFIXED
	$(LI Fix std.boxer boxing of Object's (unit test failure))
	$(LI Fix std.demangle to not show hidden parameters (this and delegate context pointers))
	$(LI $(BUGZILLA 217): typeof not working properly in internal/object.d)
	$(LI $(BUGZILLA 218): Clean up old code for packed bit array support)
	$(LI $(BUGZILLA 223): Error message for unset constants doesn't specify error location)
	$(LI $(BUGZILLA 278): dmd.conf search path doesn't work)
	$(LI $(BUGZILLA 479): can't compare arrayliteral statically with string)
	$(LI $(BUGZILLA 549): A class derived from a deprecated class is not caught)
	$(LI $(BUGZILLA 550): Shifting by more bits than size of quantity is allowed)
	$(LI $(BUGZILLA 551): Modulo operator works with imaginary and complex operands)
	$(LI $(BUGZILLA 556): is (Type Identifier : TypeSpecialization) doesn't work as it should)
	$(LI $(BUGZILLA 668): Use of *.di files breaks the order of static module construction)
	$(LI $(BUGZILLA 1125): Segfault using tuple in asm code, when size not specified)
	$(LI $(BUGZILLA 1437): dmd crash: "Internal error: ..\ztc\cod4.c 357")
	$(LI $(BUGZILLA 1474): regression: const struct with an initializer not recognized as a valid alias template param)
	$(LI $(BUGZILLA 1484): Forward reference of enum member crashes DMD)
	$(LI $(BUGZILLA 1488): Bad code generation when using tuple from asm)
	$(LI $(BUGZILLA 1510): ICE: Assertion failure: 'ad' on line 925 in file 'func.c')
	$(LI $(BUGZILLA 1523): struct literals not work with typedef)
	$(LI $(BUGZILLA 1531): cannot access typedef'd class field)
	$(LI $(BUGZILLA 1537): Internal error: ..\ztc\cgcod.c 1521)
	$(LI $(BUGZILLA 1609): TypeInfo_Typedef has incorrect implementation of next())
)
)

$(VERSION 021, Sep 5, 2007, =================================================,

$(WHATSNEW
	$(LI Added command line switches $(B -defaultlib) and $(B -debuglib))
	$(LI $(BUGZILLA 1445): Add default library options to sc.ini / dmd.conf)
	$(LI Added trace_term() to object.d to fix $(BUGZILLA 971): No profiling output is generated if the application terminates with exit)
	$(LI Multiple module static constructors/destructors allowed.)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 961): std.windows.registry stack corruption)
	$(LI $(BUGZILLA 1315): CTFE doesn't default initialise arrays of structs)
	$(LI $(BUGZILLA 1363): Compile-time issue with structs in 'for')
	$(LI $(BUGZILLA 1375): CTFE fails for null arrays)
	$(LI $(BUGZILLA 1378): A function call in an array literal causes compiler to crash)
	$(LI $(BUGZILLA 1384): Compiler segfaults when using struct variable like a function with no opCall member.)
	$(LI $(BUGZILLA 1388): multiple static constructors allowed in module)
	$(LI $(BUGZILLA 1414): compiler crashes with CTFE and structs)
	$(LI $(BUGZILLA 1423): Registry: corrupted value)
	$(LI $(BUGZILLA 1436): std.date.getLocalTZA() returns wrong values when in DST under Windows)
	$(LI $(BUGZILLA 1447): CTFE does not work for static member functions of a class)
	$(LI $(BUGZILLA 1448): UTF-8 output to console is seriously broken)
	$(LI $(BUGZILLA 1450): Registry: invalid UTF-8 sequence)
	$(LI $(BUGZILLA 1460): Compiler crash on valid code)
	$(LI $(BUGZILLA 1464): "static" foreach breaks CTFE)
)
)

$(VERSION 020, Jul 23, 2007, =================================================,

$(BUGSFIXED
	$(LI Fixed $(B extern (System)))
)
)

$(VERSION 019, Jul 21, 2007, =================================================,

$(WHATSNEW
	$(LI Added 0x78 Codeview extension for type $(B dchar).)
	$(LI Added $(B extern (System)))
	$(LI $(BUGZILLA 345): updated std.uni.isUniAlpha to Unicode 5.0.0)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 46): Included man files should be updated)
	$(LI $(BUGZILLA 268): Bug with SocketSet and classes)
	$(LI $(BUGZILLA 406): std.loader is broken on linux)
	$(LI $(BUGZILLA 561): Incorrect duplicate error message when trying to create instance of interface)
	$(LI $(BUGZILLA 588): lazy argument and nested symbol support to std.demangle)
	$(LI $(BUGZILLA 668): Use of *.di files breaks the order of static module construction)
	$(LI $(BUGZILLA 1110): std.format.doFormat + struct without toString() == crash)
	$(LI $(BUGZILLA 1199): Strange error messages when indexing empty arrays or strings at compile time)
	$(LI $(BUGZILLA 1300): Issues with struct in compile-time function)
	$(LI $(BUGZILLA 1306): extern (Windows) should work like extern (C) for variables)
	$(LI $(BUGZILLA 1331): header file genaration generates a ":" instead of ";" at pragma)
	$(LI $(BUGZILLA 1332): Internal error: ../ztc/cod4.c 357)
	$(LI $(BUGZILLA 1333): -inline ICE: passing an array element to an inner class's constructor in a nested function, all in a class or struct)
	$(LI $(BUGZILLA 1336): Internal error when trying to construct a class declared within a unittest from a templated class.)
)
)

$(VERSION 018, Jul 1, 2007, =================================================,

$(BUGSFIXED
	$(LI $(BUGZILLA 540): Nested template member function error - "function expected before ()")
	$(LI $(BUGZILLA 559): Final has no effect on methods)
	$(LI $(BUGZILLA 627): Concatenation of strings to string arrays with ~ corrupts data)
	$(LI $(BUGZILLA 629): Misleading error message "Can only append to dynamic arrays")
	$(LI $(BUGZILLA 639): Escaped tuple parameter ICEs dmd)
	$(LI $(BUGZILLA 641): Complex string operations in template argument ICEs dmd)
	$(LI $(BUGZILLA 657): version(): ignored)
	$(LI $(BUGZILLA 689): Clean up the spec printfs!)
	$(LI $(BUGZILLA 1103): metastrings.ToString fails for long &gt; 0xFFFF_FFFF)
	$(LI $(BUGZILLA 1107): CodeView: wrong CV type for bool)
	$(LI $(BUGZILLA 1118): weird switch statement behaviour)
	$(LI $(BUGZILLA 1186): Bind needs a small fix)
	$(LI $(BUGZILLA 1199): Strange error messages when indexing empty arrays or strings at compile time)
	$(LI $(BUGZILLA 1200): DMD crash: some statements containing only a ConditionalStatement with a false condition)
	$(LI $(BUGZILLA 1203): Cannot create Anonclass in loop)
	$(LI $(BUGZILLA 1204): segfault using struct in CTFE)
	$(LI $(BUGZILLA 1206): Compiler hangs on this() after method in class that forward references struct)
	$(LI $(BUGZILLA 1207): Documentation on destructors is confusing)
	$(LI $(BUGZILLA 1211): mixin("__LINE__") gives incorrect value)
	$(LI $(BUGZILLA 1212): dmd generates bad line info)
	$(LI $(BUGZILLA 1216): Concatenation gives 'non-constant expression' outside CTFE)
	$(LI $(BUGZILLA 1217): Dollar ($) seen as non-constant expression in non-char[] array)
	$(LI $(BUGZILLA 1219): long.max.stringof gets corrupted)
	$(LI $(BUGZILLA 1224): Compilation does not stop on asserts during CTFE)
	$(LI $(BUGZILLA 1228): Class invariants should not be called before the object is fully constructed)
	$(LI $(BUGZILLA 1233): std.string.ifind(char[] s, char[] sub) fails on certain non ascii strings)
	$(LI $(BUGZILLA 1234): Occurrence is misspelled almost everywhere)
	$(LI $(BUGZILLA 1235): std.string.tolower() fails on certain utf8 characters)
	$(LI $(BUGZILLA 1236): Grammar for Floating Literals is incomplete)
	$(LI $(BUGZILLA 1239): ICE when empty tuple is passed to variadic template function)
	$(LI $(BUGZILLA 1242): DMD AV)
	$(LI $(BUGZILLA 1244): Type of array length is unspecified)
	$(LI $(BUGZILLA 1247): No time zone info for India)
	$(LI $(BUGZILLA 1285): Exception typedefs not distinguished by catch)
	$(LI $(BUGZILLA 1287): Iterating over an array of tuples causes "glue.c:710: virtual unsigned int Type::totym(): Assertion `0' failed.")
	$(LI $(BUGZILLA 1290): Two ICEs, both involving real, imaginary, ? : and +=.)
	$(LI $(BUGZILLA 1291): .stringof for a class type returned from a template doesn't work)
	$(LI $(BUGZILLA 1292): Template argument deduction doesn't work)
	$(LI $(BUGZILLA 1294): referencing fields in static arrays of structs passed as arguments generates invalid code)
	$(LI $(BUGZILLA 1295): Some minor errors in the lexer grammar)
)
)

$(VERSION 017, Jun 25, 2007, =================================================,

$(WHATSNEW
	$(LI Added $(B __VENDOR__) and $(B __VERSION__).)
	$(LI The $(B .init) property for a variable is now based on its
	type, not its initializer.)
)

$(BUGSFIXED
	$(LI $(B std.compiler) now is automatically updated.)
	$(LI Fixed CFTE bug with e++ and e--.)
	$(LI $(BUGZILLA 1254): Using a parameter initialized to void in a compile-time evaluated function doesn't work)
	$(LI $(BUGZILLA 1256): "with" statement with symbol)
	$(LI $(BUGZILLA 1259): Inline build triggers an illegal error msg "Error: S() is not an lvalue")
	$(LI $(BUGZILLA 1260): Another tuple bug)
	$(LI $(BUGZILLA 1261): Regression from overzealous error message)
	$(LI $(BUGZILLA 1262): Local variable of struct type initialized by literal resets when compared to .init)
	$(LI $(BUGZILLA 1263): Template function overload fails when overloading on both template and non-template class)
	$(LI $(BUGZILLA 1268): Struct literals try to initialize static arrays of non-static structs incorrectly)
	$(LI $(BUGZILLA 1269): Compiler crash on assigning to an element of a void-initialized array in CTFE)
	$(LI $(BUGZILLA 1270): -inline produces an ICE)
	$(LI $(BUGZILLA 1272): problems with the new 1.0 section)
	$(LI $(BUGZILLA 1276): static assert message displayed with escaped characters)
	$(LI $(BUGZILLA 1283): writefln: formatter applies to following variable)
)
)

$(VERSION 016, Jun 14, 2007, =================================================,

$(WHATSNEW
	$(LI The compiler was not changed.)
	$(LI Added aliases $(B string), $(B wstring), and $(B dstring) to ease
	compatiblity with 2.0.)
)

$(BUGSFIXED
)
)

$(VERSION 015, Jun 5, 2007, =================================================,

$(BUGSFIXED
	$(LI Added missing \n to exception message going to stderr.)
	$(LI Fixed default struct initialization for CTFE.)
	$(LI $(BUGZILLA 1226): ICE on a struct literal)
	$(LI Fixed gc memory corrupting problem.)
)
)

$(VERSION 014, Apr 26, 2007, =================================================,

$(WHATSNEW
	$(LI Added $(LINK2 expression.html#AssocArrayLiteral, associative array literals))
	$(LI Added struct literals)
	$(LI Array element assignments can now be done in CTFE)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 1000): writefln fails on nested arrays)
	$(LI $(BUGZILLA 1143): Assertion failure: '0' on line 850 in 'template.c' - On specialization of IFTI template parameters.)
	$(LI $(BUGZILLA 1144): template mixin causes DMD crash)
	$(LI $(BUGZILLA 1146): mixin + assert() crashes compiler)
	$(LI $(BUGZILLA 1153): dmd assertion failure)
	$(LI $(BUGZILLA 1159): Various mixins cause "CompileExp::semantic" message, some crash DMD)
	$(LI $(BUGZILLA 1174): Program hangs creating an array of enums with nonzero initializer)
	$(LI $(BUGZILLA 1177): $(DOLLAR) no longer works inside CTFE functions.)
	$(LI $(BUGZILLA 1180): the GC failes to handle large allocation requests propperly)
	$(LI $(BUGZILLA 1189): Reverse the titles on web pages)
)
)

$(VERSION 013, Apr 19, 2007, =================================================,

$(BUGSFIXED
	$(LI Fixed crash with std.format and static arrrays)
	$(LI $(BUGZILLA 582): Cannot slice mixed tuples)
	$(LI $(BUGZILLA 594): can't cast arrayliteral statically)
	$(LI $(BUGZILLA 595): can't append to array/arrayliteral statically)
	$(LI $(BUGZILLA 997): [Regression] Struct-returning function that conditionally passes the result of another function straight through doesn't work (NRVO bug?))
	$(LI $(BUGZILLA 1090): Attribute specification: "}" vs "end of scope")
	$(LI $(BUGZILLA 1091): Wrong size reserved for critical sections)
	$(LI $(BUGZILLA 1094): switch bug)
	$(LI $(BUGZILLA 1096): Mysterious hang with toUTCString + UTCtoLocalTime + d_time_nan)
	$(LI $(BUGZILLA 1098): symbol collision in d/dmd/expression.c between math.h and port.h)
	$(LI $(BUGZILLA 1119): Internal error: ../ztc/cgcod.c 2190 (template instantiation))
	$(LI $(BUGZILLA 1121): Assertion codegen issue with templated function)
	$(LI $(BUGZILLA 1132): DMD calling linker over commandline)
	$(LI $(BUGZILLA 1134): incorrect calling convention used)
	$(LI $(BUGZILLA 1135): invariant keyword parsing is messed up)
	$(LI $(BUGZILLA 1147): Typo in phobos/std/file.d: 4069 should be 4096)
	$(LI $(BUGZILLA 1148): Problems returning structs from functions)
	$(LI $(BUGZILLA 1150): Compiler creates wrong code)
	$(LI $(BUGZILLA 1156): Installed libraries need to be passed in different order)
	$(LI $(BUGZILLA 1163): Can't initialize multiple variables with void.)
)
)

$(VERSION 012, Apr 12, 2007, =================================================,

$(BUGSFIXED
	$(LI $(NG_digitalmars_D_announce 8190) now works with $(B -v1))
	$(LI $(NG_digitalmars_D_announce 8193))
	$(LI $(BUGZILLA 532): Wrong name mangling for template alias params of local vars)
	$(LI $(BUGZILLA 1068): stack corruption with mixins and function templates)
	$(LI $(BUGZILLA 1089): Unsafe pointer comparison in TypeInfo_Pointer.compare)
	$(LI $(BUGZILLA 1127): -v1 doesn't disable the ref and macro keywords)
)
)

$(VERSION 011, Apr 11, 2007, =================================================,

$(WHATSNEW
	$(LI Extended $(LINK2 abi.html#codeview, Codeview)
	symbolic debug output with LF_OEM types.)
	$(LI Extended $(LINK2 abi.html#dwarf, Dwarf)
	symbolic debug output with DW_TAG_darray_type,
	DW_TAG_aarray_type, and DW_TAG_delegate types.)
	$(LI Added keywords $(B ref) and $(B macro).)
	$(LI $(B final) classes cannot be subclassed.)
	$(LI $(B final) for variables now works.)
	$(LI $(B ref) now works as a replacement for $(B inout).)
	$(LI Fixed so multiple type inferring declarations like
	$(CODE auto a=1,c=2;) works.)
)

$(BUGSFIXED
	$(LI Fixed problem with overloading of function templates that
	have the same template parameter list, but different function
	parameters.)
	$(LI Fixed problems with type deduction from specializations that
	are template instances.)
	$(LI Fixed assert template.c(2956) s->parent)
	$(LI Got .$(I property) to work for typeof.)
	$(LI Fixed bug in DW_AT_comp_dir output for some linux versions.)
	$(LI $(NG_digitalmars_D_announce 8027))
	$(LI $(NG_digitalmars_D_announce 8047))
	$(LI $(NG_digitalmars_D 51800))
	$(LI $(BUGZILLA 1028): Segfault using tuple inside asm code.)
	$(LI $(BUGZILLA 1052): DMD 1.009 - aliasing functions from superclasses may result in incorrect conflicts)
	$(LI $(BUGZILLA 1080): Failed to link to std.windows.registry)
	$(LI $(BUGZILLA 1081): with using real and -O option, dmd generate bug code)
	$(LI $(BUGZILLA 1082): The .offsetof property yields a signed int, a size_t would be more appropriate)
	$(LI $(BUGZILLA 1086): CodeView: missing line information for string switch)
	$(LI $(BUGZILLA 1092): compiler crash in ..\ztc\cod1.c 2528)
	$(LI $(BUGZILLA 1102): switch case couldn't contain template member)
	$(LI $(BUGZILLA 1108): Indexing an int[] not evaluatable at compile time)
	$(LI $(BUGZILLA 1122): dmd generate bad line number while reporting error message)
)
)

$(VERSION 010, Mar 24, 2007, =================================================,

$(WHATSNEW
	$(LI Added template partial specialization derived from multiple
	parameters.)
	$(LI Added Object.factory(char[] classname) method to create
	class objects based on a string.)
	$(LI Added std.gc.malloc(), std.gc.extend() and std.gc.capacity().)
	$(LI Added std.string.isEmail() and std.string.isURL().)
	$(LI Added std.stdio.readln().)
	$(LI Improved gc performance for array resize and append.)
	$(LI $(BUGZILLA 64): Unhandled errors should go to stderr)
	$(LI Added predefined Ddoc macro DOCFILENAME)
)

$(BUGSFIXED
	$(LI Fixed $(LINK2 http://www.digitalmars.com/d/archives/digitalmars/D/bugs/Broken_link_in_http_digitalmars.com_d_comparison.html_10906.html, Broken link in http://digitalmars.com/d/comparison.html))
	$(LI Fixed problem with CTFE and array literals)
	$(LI $(BUGZILLA 931): D Strings vs C++ Strings Page Incorrect)
	$(LI $(BUGZILLA 935): Extern Global C Variables)
	$(LI $(BUGZILLA 948): operatoroverloading.html - Rationale section is both out of date and incomplete)
	$(LI $(BUGZILLA 950): Missing filename and line number: conflict between implicit length in [...] and explicit length declared in the scope)
	$(LI $(BUGZILLA 959): smaller ddoc documentation issue)
	$(LI $(BUGZILLA 1056): segfault with pragma(msg) inside CTFE)
	$(LI $(BUGZILLA 1062): Cannot catch typedef'd class)
	$(LI $(BUGZILLA 1074): Dead link to std.c.locale webpage)
)
)

$(VERSION 009, Mar 10, 2007, =================================================,

$(BUGSFIXED
	$(LI $(NG_digitalmars_D 49928) 1)
	$(COMMENT $(NG_digitalmars_D_announce 7563))
	$(LI $(LINK2 http://www.digitalmars.com/d/archives/digitalmars/D/announce/DMD_1.007_release_7507.html#N7563, D.announce 7563))
	$(LI $(BUGZILLA 146): Wrong filename in DWARF debugging information for templates)
	$(LI $(BUGZILLA 992): CTFE Failure with static if)
	$(LI $(BUGZILLA 993): incorrect ABI documentation for float parameters)
	$(LI $(BUGZILLA 995): compile-time function return element of Tuple / const array)
	$(LI $(BUGZILLA 1005): dmd: tocsym.c:343: virtual Symbol* FuncDeclaration::toSymbol(): Assertion `0' failed.)
	$(LI $(BUGZILLA 1009): CodeView: out and inout parameters are declared void*)
	$(LI $(BUGZILLA 1014): Error with character literal escaping when generating header with -H)
	$(LI $(BUGZILLA 1016): CTFE fails with recursive functions)
	$(LI $(BUGZILLA 1017): CTFE doesn't support (string == string))
	$(LI $(BUGZILLA 1018): regression: Error: divide by 0)
	$(LI $(BUGZILLA 1019): regression: missing filename and line number: Error: array index X is out of bounds [0 .. Y])
	$(LI $(BUGZILLA 1020): regression: mov EAX, func)
	$(LI $(BUGZILLA 1021): CTFE and functions returning void)
	$(LI $(BUGZILLA 1022): CodeView: unions have zero length in typeleafs and datasymbols)
	$(LI $(BUGZILLA 1026): dmd SEGV when checking length of Tuple elements when length == 0)
	$(LI $(BUGZILLA 1030): ICE one-liner; struct in delegate)
	$(LI $(BUGZILLA 1038): explicit class cast breakage in 1.007)
)
)

$(VERSION 007, Feb 20, 2007, =================================================,

$(WHATSNEW
	$(LI Comparison operators are no longer associative; comparison,
	equality, identity and in operators all have the same precedence.)
	$(LI $(CODE out) and $(CODE inout) parameters are now allowed
	for compile time function execution.)
	$(LI The $(CODE .dup) property is now allowed
	for compile time function execution.)
	$(LI Updated $(LINK2 http://www.digitalmars.com/ctg/lib.html, lib)
	to insert COMDATs into symbol table.)
	$(LI Class references can no longer be implicitly converted to
	$(CODE void*).)
)

$(BUGSFIXED
	$(LI $(NG_digitalmars_D 48806) crash)
	$(LI $(NG_digitalmars_D 48811))
	$(LI $(NG_digitalmars_D 48845))
	$(LI $(NG_digitalmars_D 48869))
	$(LI $(NG_digitalmars_D 48917))
	$(LI $(NG_digitalmars_D 48953))
	$(LI $(NG_digitalmars_D 48990))
	$(LI $(NG_digitalmars_D 49033))
	$(LI $(NG_digitalmars_D_announce 7496))
	$(LI $(BUGZILLA 968): ICE on compile-time execution)
	$(LI $(BUGZILLA 974): compile-time parenthesis bug)
	$(LI $(BUGZILLA 975): compile-time const array makes dmd crash)
	$(LI $(BUGZILLA 980): If a function tries to concatenate a char to a empty array, dmd complains that the function can't be evaluated at compile time)
	$(LI $(BUGZILLA 981): CFTE fails in non-template and functions that takes no args.)
	$(LI $(BUGZILLA 986): Internal error: e2ir.c 1098)
)
)

$(VERSION 006, Feb 15, 2007, =================================================,

$(WHATSNEW
	$(LI Added $(B -J)$(I path) switch, which is now required in
	order to import text files.)
	$(LI Enhanced $(B -v) output to include actual filename.)
	$(LI name string for TypeInfo_Struct now part of the
	TypeInfo_Struct comdat.)
	$(LI $(LINK2 function.html#interpretation, Compile time execution)
	of functions)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 960): New: DMD 1.0 is in the past -- not the future)
	$(LI Codeview for classes now gives correct LF_CLASS)
)
)

$(VERSION 005, Feb 5, 2007, =================================================,

$(WHATSNEW
	$(LI $(B -v) now emits pragma library statements and
	imported file names)
	$(LI deprecated $(B ===), and $(B !==), tokens no longer recognized)
	$(LI $(CODE length) can no longer shadow other $(CODE length) declarations)
	$(LI Added $(LINK2 statement.html#MixinStatement, MixinStatement)s,
	  $(LINK2 expression.html#MixinExpression, MixinExpression)s,
	  and $(LINK2 module.html#MixinDeclaration, MixinDeclaration)s.)
	$(LI Added $(LINK2 expression.html#ImportExpression, ImportExpression)s.)
	$(LI Added $(LINK2 phobos/std_metastrings.html, std.metastrings))
)

$(BUGSFIXED
	$(LI $(BUGZILLA 761): std.format.doFormat fails for items of a char[][] containing %s)
	$(LI $(BUGZILLA 784): regression: [Issue 402] compiler crash with mixin and forward reference)
	$(LI $(BUGZILLA 787): incorrect documentation of std.ctype.isprint)
	$(LI $(BUGZILLA 788): Compiler rejects hex floats in the format: HexPrefix HexDigits . HexDigits(opt) with binary-exponent-part required)
	$(LI $(BUGZILLA 789): const initialization in forwarding constructors doesn't work)
	$(LI $(BUGZILLA 791): dhry.d example doesn't compile in 1.0 without trivial change)
	$(LI $(BUGZILLA 794): std.math.exp2(0) equals 0 instead of 1)
	$(LI $(BUGZILLA 800): writefln() on an associative array fails hard)
	$(LI $(BUGZILLA 821): segfault with char array copy; mistaken samples in doc)
	$(LI $(BUGZILLA 831): Warning!! String literals are read-only one some platforms.)
	$(LI $(BUGZILLA 832): NRVO: return inside foreach results in junk)
	$(LI $(BUGZILLA 835): RegExp.test wrongly matches strings on case insensitive attribute)
	$(LI $(BUGZILLA 846): Error 42: Symbol Undefined _D1a7__arrayZ)
	$(LI $(BUGZILLA 848): typo in C sorting example)
	$(LI $(BUGZILLA 862): Selectively importing a nonexistent identifier results in spurious and incorrect error message)
	$(LI $(BUGZILLA 872): Assertion in expression.c caused by taking typeof of "this.outer" in nested classes.)
	$(LI $(BUGZILLA 875): crash in glue.c line 700)
	$(LI $(BUGZILLA 886): std.zlib uncompression routines do not mark result as containing no pointers)
	$(LI $(BUGZILLA 887): TypeInfo does not correctly override opCmp, toHash)
	$(LI $(BUGZILLA 888): -cov and _ModuleInfo  linking bugs)
	$(LI $(BUGZILLA 890): Returning char[4] and assigning to char[] produces unexpected results.)
	$(LI $(BUGZILLA 891): Crash when compiling the following code (tested with 1.0, 1.001 and 1.002))
	$(LI $(BUGZILLA 893): The profile flag no longer seems to work on Linux x86 64)
	$(LI $(BUGZILLA 894): base class with implemented abstract method problem)
	$(LI $(BUGZILLA 897): fix default dmd.conf file)
	$(LI $(BUGZILLA 898): std.conv.toInt doesn't raise ConvOverflowError)
	$(LI $(BUGZILLA 901): Comparison of array literals fails)
	$(LI $(BUGZILLA 903): Example with printf and string literals crashes)
	$(LI $(BUGZILLA 908): compiler dies trying to inline static method call to nonstatic method in template code.)
	$(LI $(BUGZILLA 910): Error in description of "this" and "super" keywords)
	$(LI $(BUGZILLA 913): deprecated tokens still listed)
	$(LI $(BUGZILLA 915): dmd generate bad form return(retn 4) for invariant func)
	$(LI $(BUGZILLA 916): regression: Internal error: ../ztc/gloop.c 1305)
	$(LI $(BUGZILLA 917): regression: circular typedefs cause segfaults)
	$(LI $(BUGZILLA 924): GC collects valid objects)
	$(LI $(NG_digitalmars_D_announce 6983))
)
)

$(VERSION 004, Jan 26, 2007, =================================================,

$(BUGSFIXED
	$(LI $(BUGZILLA 892): Another bug in the new GC - pointers in mixins)
)
)

$(VERSION 003, Jan 26, 2007, =================================================,

$(BUGSFIXED
	$(LI $(NG_digitalmars_D_announce 6929))
	$(LI $(NG_digitalmars_D_announce 6953))
)
)

$(VERSION 002, Jan 24, 2007, =================================================,

$(BUGSFIXED
	$(LI $(NG_digitalmars_D_announce 6893): ClassInfo.flags incorrectly set)
	$(LI $(NG_digitalmars_D_announce 6906): Three subtle cases of tail recursion item 1 and 2)
)
)

$(VERSION 001, Jan 23, 2007, =================================================,

$(WHATSNEW
	$(LI tail recursion works again)
	$(LI New type aware GC)
)

$(BUGSFIXED
	$(LI $(BUGZILLA 621): When inside a loop, if you call break inside a try block the finally block is never executed)
	$(LI $(BUGZILLA 804): missing linux functions)
	$(LI $(BUGZILLA 815): scope(exit) isn't executed when "continue" is used to continue a while-loop)
	$(LI $(BUGZILLA 817): const char[] = string_literal - string_literal gets included for every reference)
	$(LI $(BUGZILLA 819): mention response files in cmd line usage)
	$(LI $(BUGZILLA 820): gc should scan only pointer types for pointers)
	$(LI $(BUGZILLA 823): frontend: incorrect verror declaration in mars.h)
	$(LI $(BUGZILLA 824): "mov EAX, func;" and "lea EAX, func;" generate incorrect code)
	$(LI $(BUGZILLA 825): dmd segmentation fault with large char[] template value parameter)
	$(LI $(BUGZILLA 826): ICE: is-expression with invalid template instantiation)
)
)

)

Macros:
	TITLE=Change Log
	WIKI=ChangeLog

	NEW1 = $(LI What's new for <a href="#new1_$0">D 1.$0</a>)

	VERSION=
	<div id=version>
	$(B $(LARGE <a name="new1_$1">
	  Version
	  <a HREF="http://ftp.digitalmars.com/dmd.1.$1.zip" title="D 1.$1">D 1.$1</a>
	))
	$(SMALL $(I $2, $3))
	$5
	</div>

	BUGZILLA = <a href="http://d.puremagic.com/issues/show_bug.cgi?id=$0">Bugzilla $0</a>
	CPPBUGZILLA = <a href="http://bugzilla.digitalmars.com/issues/show_bug.cgi?id=$0">Bugzilla $0</a>
	DSTRESS = dstress $0
	BUGSFIXED = <h4>Bugs Fixed</h4> $(UL $0 )
	WHATSNEW = <h4>New/Changed Features</h4> $(UL $0 )
	LARGE=<font size=4>$0</font>

