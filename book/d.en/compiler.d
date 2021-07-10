Ddoc

$(DERS_BOLUMU $(IX compilation) Compilation)

$(P
We have seen that the two tools that are used most in D programming are $(I the text editor) and $(I the compiler). D programs are written in text editors.
)

$(P
The concept of compilation and the function of the compiler must also be understood when using $(I compiled) languages like D.
)

$(H5 $(IX machine code) Machine code)

$(P
$(IX CPU) $(IX microprocessor) The brain of the computer is the microprocessor (or the CPU, short for $(I central processing unit)). Telling the CPU what to do is called $(I coding), and the instructions that are used when doing so are called $(I machine code).
)

$(P
Most CPU architectures use machine code specific to that particular architecture. These machine code instructions are determined under hardware constraints during the design stage of the architecture. At the lowest level these machine code instructions are implemented as electrical signals. Because the ease of coding is not a primary consideration at this level, writing programs directly in the form of the machine code of the CPU is a very difficult task.
)

$(P
These machine code instructions are special numbers, which represent various operations supported by the CPU. For example, for an imaginary 8-bit CPU, the number 4 might represent the operation of loading, the number 5 might represent the operation of storing, and the number 6 might represent the operation of incrementing. Assuming that the leftmost 3 bits are the operation number and the rightmost 5 bits are the value that is used in that operation, a sample program in machine code for this CPU might look like the following:
)

$(MONO
$(B
Operation   Value            Meaning)
   100      11110        LOAD      11110
   101      10100        STORE     10100
   110      10100        INCREMENT 10100
   000      00000        PAUSE
)

$(P
Being so close to hardware, machine code is not suitable for representing higher level concepts like $(I a playing card) or $(I a student record).
)

$(H5 $(IX programming language) Programming language)

$(P
Programming languages are designed as efficient ways of programming a CPU, capable of representing higher-level concepts. Programming languages do not have to deal with hardware constraints; their main purposes are ease of use and expressiveness. Programming languages are easier for humans to understand, closer to natural languages:
)

$(MONO
if (a_card_has_been_played()) {
   display_the_card();
}
)

$(P
However, programming languages adhere to much more strict and formal rules than any spoken language.
)

$(H5 $(IX interpreter) Interpreter)

$(P
An interpreter is a tool (a program) that reads the instructions from source code and executes them. For example, for the code above, an interpreter would understand to first execute $(C a_card_has_been_played()) and then conditionally execute $(C display_the_card()). From the point of view of the programmer, executing with an interpreter involves just two steps: writing the source code and giving it to the interpreter.
)

$(P
The interpreter must read and understand the instructions every time the program is executed. For that reason, running a program with an interpreter is usually slower than running the compiled version of the same program. Additionally, interpreters usually perform very little analysis on the code before executing it. As a result, most interpreters discover programming errors only after they start executing the program.
)

$(P
Some languages like Perl, Python and Ruby have been designed to be very flexible and dynamic, making code analysis harder. These languages have traditionally been used with an interpreter.
)

$(H5 $(IX compiler) Compiler)

$(P
A compiler is another tool that reads the instructions of a program from source code. Different from an interpreter, it does not execute the code; rather, it produces a program written in another language (usually machine code). This produced program is responsible for the execution of the instructions that were written by the programmer. From the point of view of the programmer, executing with a compiler involves three steps: writing the source code, compiling it, and running the produced program.
)

$(P
Unlike an interpreter, the compiler reads and understands the source code only once, during compilation. For that reason and in general, a compiled program runs faster compared to executing that program with an interpreter. Compilers usually perform advanced analysis on the code, which help with producing fast programs and catching programming errors before the program even starts running. On the other hand, having to compile the program every time it is changed is a complication and a potential source of human errors. Moreover, the programs that are produced by a compiler can usually run only on a specific platform; to run on a different kind of processor or on a different operating system, the program would have to be recompiled. Additionally, the languages that are easy to compile are usually less dynamic than those that run in an interpreter.
)

$(P
For reasons like safety and performance, some languages have been designed to be compiled. Ada, C, C++, and D are some of them.
)

$(H6 $(IX error, compilation) $(IX compilation error) Compilation error)

$(P
As the compiler compiles a program according to the rules of the language, it stops the compilation as soon as it comes across $(I illegal) instructions. Illegal instructions are the ones that are outside the specifications of the language. Problems like a mismatched parenthesis, a missing semicolon, a misspelled keyword, etc. all cause compilation errors.
)

$(P
The compiler may also emit a $(I compilation warning) when it sees a suspicious piece of code that may cause concern but not necessarily an error. However, warnings almost always indicate an actual error or bad style, so it is a common practice to consider most or all warnings as errors. The $(C dmd) compiler switch to enable warnings as errors is $(C -w).
)

$(Ergin)

Macros:
        TITLE=Compiler

        DESCRIPTION=The introduction of the compiler and compiled languages

        KEYWORDS=d programming language tutorial book
