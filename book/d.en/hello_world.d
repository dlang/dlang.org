Ddoc

$(DIV_CLASS page_one,

$(DERS_BOLUMU $(IX hello world) The Hello World Program)

$(P
The first program to show in most programming language books is the $(I hello world) program. This very short and simple program merely writes "Hello, World!" and finishes. This program is important because it includes some of the essential concepts of that language.
)

$(P
Here is a $(I hello world) program in D:
)

---
import std.stdio;

void main() {
    writeln("Hello, World!");
}
---

$(P
The $(I source code) above needs to be compiled by a D compiler to produce an executable program.
)

$(H5 $(IX compiler installation) $(IX installation, compiler) Compiler installation)

$(P
$(IX gdc) $(IX ldc) At the time of writing this chapter, there are three D compilers to choose from: $(C dmd), the Digital Mars compiler; $(C gdc), the D compiler of GCC; and $(C ldc), the D compiler that targets the LLVM compiler infrastructure.
)

$(P
$(IX dmd) $(C dmd) is the D compiler that has been used during the design and development of the language over the years. All of the examples in this book have been tested with $(C dmd). For that reason, it would be the easiest for you to start with $(C dmd) and try other compilers only if you have a specific need to. The code samples in this book were compiled with $(C dmd) version $(DVER).
)

$(P
To install the latest version of $(C dmd), go to the $(LINK2 http://www.dlang.org/download.html, download page at Digital Mars) and select the compiler build that matches your computer environment. You must select the $(C dmd) build that is for your operating system and package management system, and whether you have a 32-bit or a 64-bit CPU and operating system. Do not install a D1 compiler. This book covers only $(I D version two).
)

$(P
The installation steps are different on different environments but it should be as easy as following simple on-screen instructions and clicking a couple of buttons.
)

$(H5 $(IX source file) Source file)

$(P
The file that the programmer writes for the D compiler to compile is called the $(I source file). Since D is usually used as a compiled language, the source file itself is not an executable program. The source file must be converted to an executable program by the compiler.
)

$(P
As with any file, the source file must have a name. Although the name can be anything that is legal on the file system, it is customary to use the $(C .d) $(I file extension) for D source files because development environments, programming tools, and programmers all expect this to be the case. For example, $(C test.d), $(C game.d), $(C invoice.d), etc. are appropriate D source file names.
)

$(H5 Compiling the hello world program)

$(P
$(IX text editor) $(IX editor, text) You will write the source file in a $(LINK2 http://wiki.dlang.org/Editors, text editor) (or an $(I IDE) as mentioned below). Copy or type the hello world program above into a text file and save it under the name $(C hello.d).
)

$(P
The compiler will soon check that the syntax of this source code is correct (i.e. it is valid according to the language rules) and make a program out of it by translating it into machine code. Follow these steps to compile the program:
)

$(OL

$(LI Open a terminal window.)

$(LI Go to the directory where you saved $(C hello.d).)

$(LI Enter the following command. (Do not type the $(C $) character; it is there to indicate the command line prompt.))

)

$(SHELL
$(SHELL_OBSERVED $) dmd hello.d
)

$(P
If you did not make any mistake, you may think that nothing has happened. To the contrary, it means that everything went well. There should be an executable file named $(C hello) (or $(C hello.exe) under Windows) that has just been created by the compiler.
)

$(P
If the compiler has instead printed some messages, you probably have made a mistake when copying the program code. Try to identify the mistake, correct it, and retry compiling. You will routinely make many mistakes when programming, so the process of correcting and compiling will become familiar to you.
)

$(P
Once the program has been created successfully, type the name of the executable program to run it. You should see that the program prints "Hello, World!":
)

$(SHELL
$(SHELL_OBSERVED $) ./hello      $(SHELL_NOTE running the program)
Hello, World!  $(SHELL_NOTE the message that it prints)
)

$(P
Congratulations! Your first D program works as expected.
)

$(H5 $(IX compiler switch) Compiler switches)

$(P
The compiler has many command line switches that are used for influencing how it compiles the program. To see a list of compiler switches enter just the name of the compiler:
)

$(SHELL
$(SHELL_OBSERVED $) dmd    $(SHELL_NOTE enter just the name)
DMD64 D Compiler v$(DVER)
...
  -de            show use of deprecated features as errors (halt compilation)
...
  -unittest      compile in unit tests
...
  -w             warnings as errors (compilation will halt)
...
)

$(P
The abbreviated output above shows only the command line switches that I recommend that you always use. Although it makes no difference with the hello world program in this chapter, the following command line would compile the program by enabling unit tests and not allowing any warnings or deprecated features. We will see these and other switches in more detail in later chapters:
)

$(SHELL
$(SHELL_OBSERVED $) dmd hello.d -de -w -unittest
)

$(P
The complete list of $(C dmd) command line switches can be found in the $(LINK2 http://dlang.org/dmd-linux.html, DMD Compiler documentation).
)

$(P
One other command line switch that you may find useful is $(C -run). It compiles the source code, produces the executable program, and runs it with a single command. $(C -run) must be the last of compiler switches, specified right before the name of the source file:
)

$(SHELL
$(SHELL_OBSERVED $) dmd -de -w -unittest $(HILITE -run) hello.d
Hello, World!  $(SHELL_NOTE the program is automatically executed)
)

$(H5 $(IX IDE) IDE)

$(P
In addition to the compiler, you may also consider installing an IDE (integrated development environment). IDEs are designed to make program development easier by simplifying the steps of writing, compiling, and debugging.
)

$(P
If you do install an IDE, compiling and running the program will be as simple as pressing a key or clicking a button on the IDE. I still recommend that you familiarize yourself with compiling programs manually in a terminal window.
)

$(P
If you decide to install an IDE, go to $(LINK2 http://wiki.dlang.org/IDEs, the IDEs page at dlang.org) to see a list of available IDEs.
)

$(H5 Contents of the hello world program)

$(P
Here is a quick list of the many D concepts that have appeared in this short program:
)

$(P $(B Core feature): Every language defines its syntax, fundamental types, keywords, rules, etc. All of these make the $(I core features) of that language. The parentheses, semicolons, and words like $(C main) and $(C void) are all placed according to the rules of D. These are similar to the rules of English: subject, verb, punctuation, sentence structure, etc.
)

$(P $(B Library and function): The core features define only the structure of the language. They are used for defining functions and user types, and those in turn are used for building libraries. Libraries are collections of reusable program parts that get $(I linked) with your programs to help them achieve their purposes.
)

$(P
$(C writeln) above is a $(I function) in D's standard $(I library). It is used for printing a line of text, as its name suggests: write line.
)

$(P $(B Module): Library contents are grouped by types of tasks that they intend to help with. Such a group is called a module. The only module that this program uses is $(C std.stdio), which handles data input and output.
)

$(P $(B Character and string): Expressions like $(STRING "Hello, World!") are called $(I strings), and the elements of strings are called $(I characters). The only string in this program contains characters $(STRING 'H'), $(STRING 'e'), $(STRING '!'), and others.
)

$(P $(B Order of operations): Programs complete their tasks by executing operations in a certain order. These tasks start with the operations that are written in the function named $(C main). The only operation in this program writes "Hello world!".
)

$(P $(B Significance of uppercase and lowercase letters): You can choose to type any character inside strings, but you must type the other characters exactly as they appear in the program. This is because lowercase vs. uppercase is significant in D programs. For example, $(C writeln) and $(C Writeln) are two different names.
)

$(P
$(IX keyword) $(B Keyword): Special words that are a part of the core features of the language are $(I keywords). Such words are reserved for the language itself, and cannot be used for any other purpose in a D program. There are two keywords in this program: $(C import), which is used to introduce a module to the program; and $(C void), which here means "not returning anything".
)

$(P
The complete list of D keywords is $(C abstract), $(C alias), $(C align), $(C asm), $(C assert), $(C auto), $(C body), $(C bool), $(C break), $(C byte), $(C case), $(C cast), $(C catch), $(C cdouble), $(C cent), $(C cfloat), $(C char), $(C class), $(C const), $(C continue), $(C creal), $(C dchar), $(C debug), $(C default), $(C delegate), $(C delete), $(C deprecated), $(C do), $(C double), $(C else), $(C enum), $(C export), $(C extern), $(C false), $(C final), $(C finally), $(C float), $(C for), $(C foreach), $(C foreach_reverse), $(C function), $(C goto), $(C idouble), $(C if), $(C ifloat), $(C immutable), $(C import), $(C in), $(C inout), $(C int), $(C interface), $(C invariant), $(C ireal), $(C is), $(C lazy), $(C long), $(C macro), $(C mixin), $(C module), $(C new), $(C nothrow), $(C null), $(C out), $(C override), $(C package), $(C pragma), $(C private), $(C protected), $(C public), $(C pure), $(C real), $(C ref), $(C return), $(C scope), $(C shared), $(C short), $(C static), $(C struct), $(C super), $(C switch), $(C synchronized), $(C template), $(C this), $(C throw), $(C true), $(C try), $(C typedef), $(C typeid), $(C typeof), $(C ubyte), $(C ucent), $(C uint), $(C ulong), $(C union), $(C unittest), $(C ushort), $(C version), $(C void), $(C volatile), $(C wchar), $(C while), $(C with), $(C __FILE__), $(C __FILE_FULL_PATH__), $(C __MODULE__), $(C __LINE__), $(C __FUNCTION__), $(C __PRETTY_FUNCTION__), $(C __gshared), $(C __traits), $(C __vector), and $(C __parameters).
)

$(P
$(IX asm) $(IX body) $(IX __vector) $(IX delete) $(IX typedef) $(IX volatile) $(IX macro) We will cover these keywords in the upcoming chapters with the exception of the following ones: $(LINK2 http://dlang.org/statement.html#AsmStatement, $(C asm)) and $(LINK2 http://dlang.org/phobos/core_simd.html#.Vector, $(C __vector)) are outside of the scope of this book; $(C body), $(C delete), $(C typedef), and $(C volatile) are deprecated; and $(C macro) is unused by D at this time.
)

$(PROBLEM_COK

$(PROBLEM Make the program output something else.)

$(PROBLEM Change the program to output more than one line. You can do this by adding one more $(C writeln) line to the program.)

$(PROBLEM Try to compile the program after making other changes; e.g. remove the semicolon at the end of the line with $(C writeln) and observe a compilation error.
)

)

)

$(Ergin)

Macros:
        TITLE=The Hello World Program

        DESCRIPTION=The first D program: Hello World!

        KEYWORDS=d programming language tutorial book

SOZLER= 
