Ddoc

$(DERS_BOLUMU $(IX file) Files)

$(P
We have seen in the previous chapter that the standard input and output streams can be redirected to and from files and other programs with the $(C >), $(C <), and $(C |) operators on the terminal. Despite being very powerful, these tools are not suitable in every situation because in many cases programs can not complete their tasks simply by reading from their input and writing to their output.
)

$(P
For example, a program that deals with student records may use its standard output to display the program menu. Such a program would need to write the student records to an actual file instead of to $(C stdout).
)

$(P
In this chapter, we will cover reading from and writing to files of file systems.
)

$(H5 Fundamental concepts)

$(P
Files are represented by the $(C File) $(I struct) of the $(C std.stdio) module. Since I haven't introduced structs yet, we will have to accept the syntax of struct construction as is for now.
)

$(P
Before getting to code samples we have to go through fundamental concepts about files.
)

$(H6 The producer and the consumer)

$(P
Files that are created on one platform may not be readily usable on other platforms. Merely opening a file and writing data to it may not be sufficient for that data to be available on the consumer's side. The producer and the consumer of the data must have already agreed on the format of the data that is in the file. For example, if the producer has written the id and the name of the student records in a certain order, the consumer must read the data back in the same order.
)

$(P
Additionally, the code samples below do not write a $(I byte order mark) (BOM) to the beginning of the file. This may make your files incompatible with systems that require a BOM. (The BOM specifies in what order the UTF code units of characters are arranged in a file.)
)

$(H6 Access rights)

$(P
File systems present files to programs under certain access rights. Access rights are important for both data integrity and performance.
)

$(P
When it comes to reading, allowing multiple programs to read from the same file can improve performance, because the programs will not have to wait for each other to perform the read operation. On the other hand, when it comes to writing, it is often beneficial to prevent concurrent accesses to a file, even when only a single program wants to write to it. By locking the file, the operating system can prevent other programs from reading partially written files, from overwriting each other's data and so on.
)

$(H6 Opening a file)

$(P
The standard input and output streams $(C stdin) and $(C stdout) are already $(I open) when programs start running. They are ready to be used.
)

$(P
On the other hand, normal files must first be opened by specifying the name of the file and the access rights that are needed. As we will see in the examples below, creating a $(C File) object is sufficient to open the file specified by its name:
)

---
    File file = File("student_records", "r");
---

$(H6 Closing a file)

$(P
Any file that has been opened by a program must be closed when the program finishes using that file. In most cases the files need not be closed explicitly; they are closed automatically when $(C File) objects are terminated automatically:
)

---
if (aCondition) {

    // Assume a File object has been created and used here.
    // ...

} // ← The actual file would be closed automatically here
  //   when leaving this scope. No need to close explicitly.
---

$(P
In some cases a file object may need to be re-opened to access a different file or the same file with different access rights. In such cases the file must be closed and re-opened:
)

---
    file.close();
    file.open("student_records", "r");
---

$(H6 Writing to and reading from files)

$(P
Since files are character streams, input and output functions $(C writeln), $(C readf), etc. are used exactly the same way with them. The only difference is that the name of the $(C File) variable and a dot must be typed:
)

---
    writeln("hello");        // writes to the standard output
    stdout.writeln("hello"); // same as above
    $(HILITE file.)writeln("hello");   // writes to the specified file
---

$(H6 $(IX eof) $(C eof()) to determine the end of a file)

$(P
The $(C eof()) member function determines whether the end of a file has been reached while reading from a file. It returns $(C true) if the end of the file has been reached.
)

$(P
For example, the following loop will be active until the end of the file:
)

---
    while (!file.eof()) {
        // ...
    }
---

$(H6 $(IX std.file) The $(C std.file) module)

$(P
The $(LINK2 http://dlang.org/phobos/std_file.html, $(C std.file) module) contains functions and types that are useful when working with contents of directories. For example, $(C exists) can be used to determine whether a file or a directory exists on the file systems:
)

---
import std.file;

// ...

    if (exists(fileName)) {
        // there is a file or directory under that name

    } else {
        // no file or directory under that name
    }
---

$(H5 $(IX File) $(C std.stdio.File) struct)

$(P
$(IX mode, file) The $(C File) struct is included in the $(LINK2 http://dlang.org/phobos/std_stdio.html, $(C std.stdio) module). To use it you specify the name of the file you want to open and the desired access rights, or mode. It uses the same mode characters that are used by $(C fopen) of the C programming language:
)

<table class="wide" border="1" cellpadding="4" cellspacing="0">
<tr align="center"><th scope="col">&nbsp;Mode&nbsp;</th> <th scope="col">Definition</th></tr>

<tr><td align="center">r</td><td>$(B read) access$(BR)the file is opened to be read from the beginning</td></tr>

<tr><td align="center">r+</td><td>$(B read and write) access$(BR)the file is opened to be read from and written at the beginning</td></tr>

<tr><td align="center">w</td><td>$(B write) access$(BR)if the file does not exist, it is created as empty$(BR)if the file already exists, its contents are cleared</td></tr>

<tr><td align="center">w+</td><td>$(B read and write) access$(BR)if the file does not exist, it is created as empty$(BR)if the file already exists, its contents are cleared</td></tr>

<tr><td align="center">a</td><td>$(B append) access$(BR)if the file does not exist, it is created as empty$(BR)if the file already exists, its contents are preserved and it is opened to be written at the end</td></tr>

<tr><td align="center">a+</td><td>$(B read and append) access$(BR)if the file does not exist, it is created as empty$(BR)if the file already exists, its contents are preserved and the file is opened to be read from the beginning and written at the end</td></tr>
</table>

$(P
A 'b' character may be added to the mode string, as in "rb". This may have an effect on platforms that support the $(I binary mode), but it is ignored on all POSIX systems.
)

$(H6 Writing to a file)

$(P
The file must have been opened in one of the write modes first:
)

---
import std.stdio;

void main() {
    File file = File("student_records", $(HILITE "w"));

    file.writeln("Name  : ", "Zafer");
    file.writeln("Number: ", 123);
    file.writeln("Class : ", "1A");
}
---

$(P
As you remember from the $(LINK2 strings.html, Strings chapter), the type of literals like $(STRING "student_records") is $(C string), consisting of immutable characters. For that reason, it is not possible to construct $(C File) objects by using mutable text to specify the file name (e.g. $(C char[])). When needed, call the $(C .idup) property of the mutable string to get an immutable copy.
)

$(P
The program above creates or overwrites the contents of a file named $(C student_records) in the directory that it has been started under (in the program's $(I working directory)).
)

$(P
$(I $(B Note:) File names can contain any character that is legal for that file system. To be portable, I will use only the commonly supported ASCII characters.)
)

$(H6 Reading from a file)

$(P
To read from a file the file must first have been opened in one of the read modes:
)

---
import std.stdio;
import std.string;

void main() {
    File file = File("student_records", $(HILITE "r"));

    while (!file.eof()) {
        string line = strip(file.readln());
        writeln("read line -> |", line);
    }
}
---

$(P
The program above reads all of the lines of the file named $(C student_records) and prints those lines to its standard output.
)

$(PROBLEM_TEK

$(P
Write a program that takes a file name from the user, opens that file, and writes all of the non-empty lines of that file to another file. The name of the new file can be based on the name of the original file. For example, if the original file is $(C foo.txt), the new file can be $(C foo.txt.out).
)

)

Macros:
        TITLE=Files

        DESCRIPTION=Basic file operations.

        KEYWORDS=d programming language tutorial book file
