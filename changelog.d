Ddoc

$(D_S D Change Log,


$(UL 
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

$(VERSION 043, Xyz 99, 2009, =================================================,
$(WHATSNEW
        $(LI std.algorithm: added minPos)
        $(LI std.format: added raw specifier for reading)
        $(LI added File.byChunk)
		$(LI Improved exception message for assert(0) in Windows -release builds)
		)
		
$(BUGSFIXED
        $(LI $(BUGZILLA 2882): std.random.MersenneTwisterEngine without no seed))
        $(LI unlisted: made entropy work on const/immutable arrays))
)
        
$(VERSION 042, Mar 12, 2009, =================================================,

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
	$(LI Fix bug where / wasn't recognized as a path separator on Windows.)
	$(LI $(BUGZILLA 920): Fix one more out of date reference to 'auto' rather than 'scope')
	$(LI $(BUGZILLA 1923): GC optimization for contiguous pointers to the same page)
	$(LI $(BUGZILLA 2570): Patch for some mistakes in Ddoc comments)
	$(LI $(BUGZILLA 2705): Response file size cannot exceed 64kb)
	$(LI $(BUGZILLA 2711): -H produces bad headers files if function defintion is templated and have auto return value)
	$(LI $(BUGZILLA 2731): Errors in associative array example)
	$(LI $(BUGZILLA 2744): wrong init tocbuffer of forstatement)
	$(LI $(BUGZILLA 2745): missing token tochars in lexer.c)
	$(LI $(BUGZILLA 2747): improper toCBuffer of funcexp)
	$(LI $(BUGZILLA 2750): Optimize slice copy with size known at compile time)
	$(LI $(BUGZILLA 2751): incorrect scope storage class vardeclaration tocbuffer)
	$(LI $(BUGZILLA 2767): DMD incorrectly mangles NTFS stream names)
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
	DSTRESS = dstress $0
	BUGSFIXED = <h4>Bugs Fixed</h4> $(UL $0 )
	WHATSNEW = <h4>New/Changed Features</h4> $(UL $0 )
	LARGE=<font size=4>$0</font>

