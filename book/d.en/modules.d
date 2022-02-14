Ddoc

$(DERS_BOLUMU $(IX module) Modules and Libraries)

$(P
The building blocks of D programs (and libraries) are modules.
)

$(P
D modules are based on a simple concept: Every source file is a module. Accordingly, the single files that we have been writing our programs in have all been individual modules.
)

$(P
By default, the name of a module is the same as its filename without the $(C .d) extension. When explicitly specified, the name of the module is defined by the $(C module) keyword, which must appear as the first non-comment line in the source file.
)

$(P
For example, assuming that the name of a source file is "cat.d", the name of the module would be specified by the $(C module) keyword:
)

---
module cat;

class Cat {
    // ...
}
---

$(P
The $(C module) line is optional if the module is not part of any package (see below). When not specified, it is the same as the file name without the $(C .d) extension.
)

$(H6 $(IX static this, module) $(IX static ~this, module) $(IX this, static, module) $(IX ~this, static, module) $(IX module constructor, thread-local) $(C static this()) and $(C static ~this()))

$(P
$(C static this()) and $(C static ~this()) at module scope are similar to their $(C struct) and $(C class) counterparts:
)

---
module cat;

static this() {
    // ... the initial operations of the module ...
}

static ~this() {
    // ... the final operations of the module ...
}
---

$(P
Code that are in these scopes are executed once for each thread. (Note that most programs consist of a single thread that starts executing the $(C main()) function.) Code that should be executed only once for the entire program (e.g. initializing $(C shared) and $(C immutable) variables) must be defined in $(C shared static this()) and $(C shared static ~this()) blocks, which will be covered in $(LINK2 concurrency_shared.html, the Data Sharing Concurrency chapter).
)

$(H6 File and module names)

$(P
D supports Unicode in source code and module names. However, the Unicode support of file systems vary. For example, although most Linux file systems support Unicode, the file names in Windows file systems may not distinguish between lower and upper case letters. Additionally, most file systems limit the characters that can be used in file and directory names.
)

$(P
For portability reasons, I recommend that you use only lower case ASCII letters in file names. For example, "resume.d" would be a suitable file name for a class named $(C Résumé).
)

$(P
Accordingly, the name of the module would consist of ASCII letters as well:
)

---
module resume;  // Module name consisting of ASCII letters

class Résumé {  // Program code consisting of Unicode characters
    // ...
}
---

$(H5 $(IX package, definition) Packages)

$(P
A combination of related modules are called a $(I package). D packages are a simple concept as well: The source files that are inside the same directory are considered to belong to the same package. The name of the directory becomes the name of the package, which must also be specified as the first parts of module names.
)

$(P
For example, if "cat.d" and "dog.d" are inside the directory "animal", then specifying the directory name along with the module name makes them be a part of the same package:
)

---
module $(HILITE animal.)cat;

class Cat {
    // ...
}
---

$(P
Similarly, for the $(C dog) module:
)

---
module $(HILITE animal.)dog;

class Dog {
    // ...
}
---

$(P
For modules that are parts of packages, the $(C module) line is not optional and the whole module name including the package name must be specified.
)

$(P
Since package names correspond to directory names, the package names of modules that are deeper than one directory level must reflect that hierarchy. For example, if the "animal" directory included a "vertebrate" directory, the name of a module inside that directory would include $(C vertebrate) as well:
)

---
module animal.vertebrate.cat;
---

$(P
The directory hierarchies can be arbitrarily complex depending on the needs of the program. Relatively short programs usually have all of their source files in a single directory.
)

$(H5 Importing modules)

$(P
$(IX import) The $(C import) keyword, which we have been using in almost every program so far, is for introducing a module to the current module:
)

---
import std.stdio;
---

$(P
The module name may contain the package name as well. For example, the $(C std.) part above indicates that $(C stdio) is a module that is a part of the $(C std) package.
)

$(P
The $(C animal.cat) and $(C animal.dog) modules would be imported similarly. Let's assume that the following code is inside a file named "deneme.d":
)

---
module deneme;        // the name of this module

import animal.cat;    // a module that it uses
import animal.dog;    // another module that it uses

void main() {
    auto cat = new Cat();
    auto dog = new Dog();
}
---

$(P
$(I $(B Note:) As described below, for the program to be built correctly, those module files must also be provided to the linker.)
)

$(P
More than one module can be imported at the same time:
)

---
import animal.cat, animal.dog;
---

$(H6 $(IX selective import) $(IX import, selective) Selective imports)

$(P
$(IX :, import) Instead of importing a module as a whole with all of its names, it is possible to import just specific names from it.
)

---
import std.stdio $(HILITE : writeln;)

// ...

    write$(HILITE f)ln("Hello %s.", name);    $(DERLEME_HATASI)
---

$(P
The code above cannot be compiled because only $(C writeln) is imported, not $(C writefln).
)

$(P
Selective imports are considered to be better than importing an entire module because it reduces the chance of $(I name collisions). As we will see in an example below, a name collision can occur when the same name appears in more than one imported module.
)

$(P
Selective imports may reduce compilation times as well because the compiler needs to compile only the parts of a module that are actually imported. On the other hand, selective imports require more work as every imported name must be specified separately on the $(C import) line.
)

$(P
This book does not take advantage of selective imports mostly for brevity.
)

$(H6 $(IX local import) $(IX import, local) Local imports)

$(P
So far we have always imported all of the required modules at the tops of programs:
)

---
import std.stdio;     $(CODE_NOTE at the top)
import std.string;    $(CODE_NOTE at the top)

// ... the rest of the module ...
---

$(P
Instead, modules can be imported at any other line of the source code. For example, the two functions of the following program import the modules that they need in their own scopes:
)

---
string makeGreeting(string name) {
    $(HILITE import std.string;)

    string greeting = format("Hello %s", name);
    return greeting;
}

void interactWithUser() {
    $(HILITE import std.stdio;)

    write("Please enter your name: ");
    string name = readln();
    writeln(makeGreeting(name));
}

void main() {
    interactWithUser();
}
---

$(P
Local imports are recommended over global imports because instead of importing every module unconditionally at the top, the compiler can import only the ones that are in the scopes that are actually used. If the compiler knows that the program never calls a function, it can ignore the import directives inside that function.
)

$(P
Additionally, a locally imported module is accessible only inside that local scope, further reducing the risk of name collisions.
)

$(P
We will later see in $(LINK2 mixin.html, the Mixins chapter) that local imports are in fact required for $(I template mixins.)
)

$(P
The examples throughout this book do not take advantage of local imports mostly because local imports were added to D after the start of writing this book.
)

$(H6 Locations of modules)

$(P
The compiler finds the module files by converting the package and module names directly to directory and file names.
)

$(P
For example, the previous two modules would be located as "animal/cat.d" and "animal/dog.d", respectively (or "animal\cat.d" and "animal\dog.d", depending on the file system). Considering the main source file as well, the program above consists of three files.
)

$(H6 Long and short module names)

$(P
The names that are used in the program may be spelled out with the module and package names:
)

---
    auto cat0 = Cat();
    auto cat1 = animal.cat.Cat();   // same as above
---

$(P
The long names are normally not needed but sometimes there are name conflicts. For example, when referring to a name that appears in more than one module, the compiler cannot decide which one is meant.
)

$(P
The following program is spelling out the long names to distinguish between two separate $(C Jaguar) structs that are defined in two separate modules: $(C animal) and $(C car):
)

---
import animal.jaguar;
import car.jaguar;

// ...

    auto conflicted =  Jaguar();            $(DERLEME_HATASI)

    auto myAnimal = animal.jaguar.Jaguar(); $(CODE_NOTE compiles)
    auto myCar    =    car.jaguar.Jaguar(); $(CODE_NOTE compiles)
---

$(H6 Renamed imports)

$(P
$(IX renamed import) It is possible to rename imported modules either for convenience or to resolve name conflicts:
)

---
import $(HILITE carnivore =) animal.jaguar;
import $(HILITE vehicle =) car.jaguar;

// ...

    auto myAnimal = $(HILITE carnivore.)Jaguar();       $(CODE_NOTE compiles)
    auto myCar    = $(HILITE vehicle.)Jaguar();         $(CODE_NOTE compiles)
---

$(P
Instead of renaming the entire import, it is possible to rename individual imported symbols.
)

$(P
For example, when the following code is compiled with the $(C -w) compiler switch, the compiler would warn that $(C sort()) $(I function) should be preferred instead of $(C .sort) $(I property):
)

---
import std.stdio;
import std.algorithm;

// ...

    auto arr = [ 2, 10, 1, 5 ];
    arr$(HILITE .sort);    $(CODE_NOTE_WRONG compilation WARNING)
    writeln(arr);
---

$(SHELL
Warning: use std.algorithm.sort instead of .sort property
)

$(P
$(I $(B Note:) The $(C arr.sort) expression above is the equivalent of $(C sort(arr)) but it is written in the UFCS syntax, which we will see in $(LINK2 ufcs.html, a later chapter).)
)

$(P
One solution in this case is to import $(C std.algorithm.sort) by renaming it. The new name $(C algSort) below means the $(C sort()) $(I function) and the compiler warning is eliminated:
)

---
import std.stdio;
import std.algorithm : $(HILITE algSort =) sort;

void main() {
    auto arr = [ 2, 10, 1, 5 ];
    arr$(HILITE .algSort);
    writeln(arr);
}
---

$(H6 $(IX package import) Importing a package as a module)

$(P
Sometimes multiple modules of a package may need to be imported together. For example, whenever one module from the $(C animal) package is imported, all of the other modules may need to be imported as well: $(C animal.cat), $(C animal.dog), $(C animal.horse), etc.
)

$(P
In such cases it is possible to import some or all of the modules of a package by importing the package as if it were a module:
)

---
import animal;    // ← entire package imported as a module
---

$(P
$(IX package.d) It is achieved by a special configuration file in the package directory, which must always be named as $(C package.d). That special file includes the $(C module) directive for the package and imports the modules of the package $(I publicly):
)

---
// The contents of the file animal/package.d:
module animal;

$(HILITE public) import animal.cat;
$(HILITE public) import animal.dog;
$(HILITE public) import animal.horse;
// ... same for the other modules ...
---

$(P
Importing a module publicly makes that module available to the users of the importing module as well. As a result, when the users import just the $(C animal) module (which actually is a package), they get access to $(C animal.cat) and all the other modules as well.
)

$(H6 $(IX deprecated) Deprecating features)

$(P
Modules evolve over time and get released under new version numbers. Going forward from a particular version, the authors of the module may decide to $(I deprecate) some of its features. Deprecating a feature means that newly written programs should not rely on that feature anymore; using a deprecated feature is disapproved. Deprecated features may even be removed from the module in the future.
)

$(P
There can be many reasons why a feature is deprecated. For example, the new version of the module may include a better alternative, the feature may have been moved to another module, the name of the feature may have changed to be consistent with the rest of the module, etc.
)

$(P
The deprecation of a feature is made official by defining it with the $(C deprecated) attribute, optionally with a custom message. For example, the following deprecation message communicates to its user that the name of the function has been changed:
)

---
deprecated("Please use doSomething() instead.")
void do_something() {
    // ...
}
---

$(P
By specifying one of the following compiler switches, the user of the module can determine how the compiler should react when a deprecated feature is used:
)

$(UL
$(LI $(IX -d, compiler switch) $(C -d): Using deprecated features should be allowed)
$(LI $(IX -dw, compiler switch) $(C -dw): Using deprecated features should produce compilation warnings)
$(LI $(IX -de, compiler switch) $(C -de): Using deprecated features should produce compilation errors)
)

$(P
For example, calling the deprecated feature in a program and compiling it with $(C -de) would fail compilation:
)

---
    do_something();
---

$(SHELL_SMALL
$ dmd deneme.d $(HILITE -de)
$(SHELL_OBSERVED deneme.d: $(HILITE Deprecation): function deneme.do_something is
deprecated - Please use doSomething() instead.)
)

$(P
The name of a deprecated feature is usually defined as an $(C alias) of the new name:
)

---
deprecated("Please use doSomething() instead.")
$(HILITE alias do_something) = doSomething;

void doSomething() {
    // ...
}
---

$(P
We will see the $(C alias) keyword in $(LINK2 alias.html, a later chapter).
)

$(H6 Adding module definitions to the program)

$(P
The $(C import) keyword is not sufficient to make modules become parts of the program. It simply makes available the features of a module inside the current module. That much is needed only to $(I compile) the code.
)

$(P
It is not possible to build the previous program only by the main source file, "deneme.d":
)

$(SHELL_SMALL
$ dmd deneme.d -w -de
$(SHELL_OBSERVED deneme.o: In function `_Dmain':
deneme.d: $(HILITE undefined reference) to `_D6animal3cat3Cat7__ClassZ'
deneme.d: $(HILITE undefined reference) to `_D6animal3dog3Dog7__ClassZ'
collect2: ld returned 1 exit status)
)

$(P
Those error messages are generated by the $(I linker). Although they are not user-friendly messages, they indicate that some definitions that are needed by the program are missing.
)

$(P
$(IX linker) $(IX building the program) The actual build of the program is the responsibility of the linker, which gets called automatically by the compiler behind the scenes. The compiler passes the modules that it has just compiled to the linker, and the linker combines those modules (and libraries) to produce the executable program.
)

$(P
For that reason, all of the modules that make up the program must be provided to the linker. For the program above to be built, "animal/cat.d" and "animal/dog.d" must also be specified on the compilation line:
)

$(SHELL_SMALL
$ dmd deneme.d animal/cat.d animal/dog.d -w -de
)

$(P
Instead of having to mention the modules individually every time on the command line, they can be combined as libraries.
)

$(H5 $(IX library) Libraries)

$(P
A collection of compiled modules is called a library. Libraries are not programs themselves; they do not have the $(C main()) function. Libraries contain compiled definitions of functions, structs, classes, and other features of modules, which are to be linked later by the linker to produce the program.
)

$(P
dmd's $(C -lib) command line option is for making libraries. The following command makes a library that contains the "cat.d" and the "dog.d" modules. The name of the library is specified with the $(C -of) switch:
)

$(SHELL_SMALL
$ dmd animal/cat.d animal/dog.d -lib -ofanimal -w -de
)

$(P
The actual name of the library file depends on the platform. For example, the extension of library files is $(C .a) under Linux systems: $(C animal.a).
)

$(P
Once that library is built, It is not necessary to specify the "animal/cat.d" and "animal/dog.d" modules individually anymore. The library file is sufficient:
)

$(SHELL_SMALL
$ dmd deneme.d animal.a -w -de
)

$(P
The command above replaces the following one:
)

$(SHELL_SMALL
$ dmd deneme.d animal/cat.d animal/dog.d -w -de
)

$(P
$(IX Phobos, library) As an exception, the D standard library Phobos need not be specified on the command line. That library is automatically included behind the scenes. Otherwise, it could be specified similar to the following line:
)

$(SHELL_SMALL
$ dmd deneme.d animal.a /usr/lib64/libphobos2.a -w -de
)

$(P
$(I $(B Note:) The name and location of the Phobos library may be different on different systems.)
)

$(H6 Using libraries of other languages)

$(P
D can use libraries that are written in some other compiled languages like C and C++. However, because different languages use different $(I linkages), such libraries are available to D code only through their $(I D bindings).
)

$(P
$(IX linkage) $(IX name mangling) $(IX mangling, name) $(IX symbol) Linkage is the set of rules that determines the accessibility of entities in a library as well as how the names (symbols) of those entities are represented in compiled code. The names in compiled code are different from the names that the programmer writes in source code: The compiled names are $(I name-mangled) according to the rules of a particular language or compiler.
)

$(P
$(IX mangle, core.demangle) $(IX demangle) For example, according to C linkage, the C function name $(C foo) would be $(I mangled) with a leading underscore as $(C _foo) in compiled code. Name-mangling is more complex in languages like C++ and D because these languages allow using the same name for different entities in different modules, structs, classes, etc. as well as for overloads of functions. A D function named $(C foo) in source code has to be mangled in a way that would differentiate it from all other $(C foo) names that can exist in a program. Although the exact mangled names are usually not important to the programmer, the $(C core.demangle) module can be used to mangle and demangle symbols:
)

---
module deneme;

import std.stdio;
import core.demangle;

void foo() {
}

void main() {
    writeln($(HILITE mangle)!(typeof(foo))("deneme.foo"));
}
---

$(P
$(I $(B Note:) $(C mangle()) is a function template, the syntax of which is unfamiliar at this point in the book. We will see templates later in $(LINK2 templates.html, the Templates chapter).)
)

$(P
A function that has the same type as $(C foo) above and is named as $(C deneme.foo), has the following mangled name in compiled code:
)

$(SHELL_SMALL
_D6deneme3fooFZv
)

$(P
Name mangling is the reason why linker error messages cannot include user-friendly names. For example, a symbol in an error message above was $(C _D6animal3cat3Cat7__ClassZ) instead of $(C animal.cat.Cat).
)

$(P
$(IX extern()) $(IX C) $(IX C++) $(IX D) $(IX Objective-C) $(IX Pascal) $(IX System) $(IX Windows) The $(C extern()) attribute specifies the linkage of entities. The valid linkage types that can be used with $(C extern()) are $(C C), $(C C++), $(C D), $(C Objective-C), $(C Pascal), $(C System), and $(C Windows). For example, when a D code needs to make a call to a function that is defined in a C library, that function must be declared as having C linkage:
)

---
// Declaring that 'foo' has C linkage (e.g. it may be defined
// in a C library):
$(HILITE extern(C)) void foo();

void main() {
    foo();  // this call would be compiled as a call to '_foo'
}
---

$(P
$(IX namespace, C++) In the case of C++ linkage, the namespace that a name is defined in is specified as the second argument to the $(C extern()) attribute. For example, according to the following declaration, $(C bar()) is the declaration of the function $(C a::b::c::bar()) defined in a C++ library (note that D code uses dots instead of colons):
)

---
// Declaring that 'bar' is defined inside namespace a::b::c
// and that it has C++ linkage:
extern(C++, $(HILITE a.b.c)) void bar();

void main() {
    bar();          // a call to a::b::c::bar()
    a.b.c.bar();    // same as above
}
---

$(P
$(IX binding) A file that contains such D declarations of the features of an external library is called a $(I D binding) of that library. Fortunately, in most cases programmers do not need to write them from scratch as D bindings for many popular non-D libraries are available through $(LINK2 https://github.com/D-Programming-Deimos/, the Deimos project).
)

$(P
$(IX extern) When used without a linkage type, the $(C extern) attribute has a different meaning: It specifies that the storage for a variable is the responsibility of an external library; the D compiler should not reserve space for it in this module. Having different meanings, $(C extern) and $(C extern()) can be used together:
)

---
// Declaring that the storage for 'g_variable' is already
// defined in a C library:
extern(C) $(HILITE extern) int g_variable;
---

$(P
If the $(C extern) attribute were not specified above, while having C linkage, $(C g_variable) would be a variable of this D module.
)

Macros:
        TITLE=Modules and Libraries

        DESCRIPTION=D modules and libraries

        KEYWORDS=d programming lesson book tutorial module library
