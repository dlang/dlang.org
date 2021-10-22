Ddoc

$(DERS_BOLUMU $(IX memory management) Memory Management)

$(P
D is a language that does not require explicit memory management. However, it is important for a system programmer to know how to manage memory when needed for special cases.
)

$(P
Memory management is a very broad topic. This chapter will introduce only the garbage collector (GC), allocating memory from it, and constructing objects at specific memory locations. I encourage you to research various memory management methods as well as the $(C std.allocator) module, which was still at experimental stage at the time of writing this book.
)

$(P
As in some of the previous chapters, when I write $(I variable) below, I mean any type of variable including $(C struct) and $(C class) objects.
)

$(H5 $(IX memory) Memory)

$(P
Memory is a more significant resource than other system resources because both the running program and its data are located in the memory. The memory belongs ultimately to the operating system, which makes it available to programs to satisfy their needs. The amount of memory that a program uses may increase or decrease according to the immediate needs of a program. When a program terminates, the memory areas that it has been using are automatically returned back to the operating system.
)

$(P
The memory can be imagined like a large sheet of paper where the values of variables are noted down. Each variable is kept at a specific location where its value is written to and read from as needed. Once the lifetime of a variable ends, its place is used for another variable.
)

$(P
$(IX &, address of) The $(C &) (address-of) operator is useful when experimenting with memory. For example, the following program prints the addresses of two variables that are defined next to each other:
)

---
import std.stdio;

void main() {
    int i;
    int j;

    writeln("i: ", $(HILITE &)i);
    writeln("j: ", $(HILITE &)j);
}
---

$(P
$(I  $(B Note:) The addresses would likely be different every time the program is executed. Additionally, the mere act of taking the address of a variable disables the optimization that would otherwise make the variable live on a CPU register.)
)

$(P
As can be seen from the output, the locations of the variables are four bytes apart:
)

$(SHELL
i: 7FFF2B633E2$(HILITE 8)
j: 7FFF2B633E2$(HILITE C)
)

$(P
The last digits of the two addresses indicate that $(C i) lives in a memory location that is right before the location of $(C j): 8 plus 4 (size of $(C int)) makes 12 (C in hexadecimal notation).
)

$(H5 $(IX garbage collector) $(IX GC) The garbage collector)

$(P
The dynamic variables that are used in D programs live on memory blocks that are owned by the garbage collector (GC). When the lifetime of a variable ends (i.e. it's no longer being used), that variable is subject to being finalized according to an algorithm that is executed by the GC. If nothing else needs the memory location containing the variable, the memory may be reclaimed to be used for other variables. This algorithm is called $(I garbage collection) and an execution of the algorithm is called a $(I garbage collection cycle).
)

$(P
The algorithm that the GC executes can roughly be described as the following. All of the memory blocks that can be reached directly or indirectly by pointers (including references) that are in the program roots are scanned. Any memory block that can be reached is tagged as being still in use and all the others are tagged as not being used anymore. The finalizers of objects and structs that live on inaccessible blocks are executed and those memory blocks are reclaimed to be used for future variables. The roots are defined as all of the program stack for every thread, all global and thread-local variables, and any additional data added via $(C GC.addRoot) or $(C GC.addRange).
)

$(P
Some GC algorithms can move objects around to keep them together in one place in memory. To preserve program correctness, all of the pointers (and references) that point to such objects are automatically modified to point to the new locations. D's current GC does not do this.
)

$(P
A GC is said to be "precise" if it knows exactly which memory contains pointers and which doesn't. A GC is conservative if it scans all memory as if it were pointers. D's GC is partially conservative, scanning only blocks that contain pointers, but it will scan all data in those blocks. For this reason, in some cases blocks are not ever collected, thereby "leaking" that memory. Large blocks are more likely to be targeted by "false pointers". In some cases it may be recommended to manually free large blocks you are no longer using to avoid this problem.
)

$(P
The order of executing the finalizers is unspecified. For example, a reference member of an object may be finalized before the object that contains that member. For that reason, no class member that refers to a dynamic variable should be accessed inside the destructor. Note that this is very different from the deterministic destruction order of languages like C++.
)

$(P
A garbage collection cycle can be started for various reasons like needing to find space for more data. Depending on the GC implementation, because allocating new objects during a garbage collection cycle can interfere with the collection process itself, all of the running threads may have to be halted during collection cycles. Sometimes this can be observed as a hesitation in the execution of the program.
)

$(P
In most cases the programmer does not need to interfere with the garbage collection process. However, it is possible to delay or dispatch garbage collection cycles as needed by the functions defined in the $(C core.memory) module.
)

$(H6 $(IX GC.enable) $(IX GC.disable) $(IX GC.collect) Starting and delaying garbage collection cycles)

$(P
It may be desired to delay the execution of garbage collection cycles during a part of the program where it is important for the program to be responsive. $(C GC.disable) disables garbage collection cycles and $(C GC.enable) enables them again:
)

---
    GC.disable();

// ... a part of the program where responsiveness is important ...

    GC.enable();
---

$(P
However, $(C GC.disable) is not guaranteed to prevent a garbage collection cycle from executing: If the GC needs to obtain more memory from the OS, but it cannot, it still goes ahead and runs a garbage collection cycle as a last-ditch effort to gain some available memory.
)

$(P
Instead of relying on garbage collections happening automatically at unspecified times, a garbage collection cycle can be started explicitly using $(C GC.collect()):
)

---
import core.memory;

// ...

    GC.collect();    // starts a garbage collection cycle
---

$(P
Normally, the GC does not return memory blocks back to the operating system; it holds on to those memory pages for future needs of the program. If desired, the GC can be asked to give unused memory back to the operating system using $(C GC.minimize()):
)

---
    GC.minimize();
---

$(H5 Allocating memory)

$(P
System languages allow programmers to specify the memory areas where objects should live. Such memory areas are commonly called $(I buffers).
)

$(P
There are several methods of allocating memory. The simplest method would be using a fixed-length array:
)

---
    ubyte[100] buffer;    // A memory area of 100 bytes
---

$(P
$(IX uninitialized array) $(IX array, uninitialized) $(IX = void) $(C buffer) is ready to be used as a 100-byte memory area. Instead of $(C ubyte), it is also possible to define such buffers as arrays of $(C void), without any association to any type. Since $(C void) cannot be assigned any value, it cannot have the $(C .init) value either. Such arrays must be initialized by the special syntax $(C =void):
)

---
    void[100] buffer = void;    // A memory area of 100 bytes
---

$(P
$(IX GC.calloc) We will use only $(C GC.calloc) from the $(C core.memory) module to reserve memory in this chapter. That module has many other features that are useful in various situations. Additionally, the memory allocation functions of the C standard library are avaliable in the $(C core.stdc.stdlib) module.
)

$(P
$(C GC.calloc) allocates a memory area of the specified size pre-filled with all 0 values, and returns the beginning address of the allocated area:
)

---
import core.memory;
// ...
    void * buffer = GC.calloc(100);
                            // A memory area of 100 zero bytes
---

$(P
$(IX void*) Normally, the returned $(C void*) value is cast to a pointer of the proper type:
)

---
    int * intBuffer = cast(int*)buffer;
---

$(P
However, that intermediate step is usually skipped and the return value is cast directly:
)

---
    int * intBuffer = $(HILITE cast(int*))GC.calloc(100);
---

$(P
Instead of arbitrary values like 100, the size of the memory area is usually calculated by multiplying the number of elements needed with the size of each element:
)

---
    // Allocate room for 25 ints
    int * intBuffer = cast(int*)GC.calloc($(HILITE int.sizeof * 25));
---

$(P
$(IX classInstanceSize) $(IX .sizeof, class) There is an important difference for classes: The size of a class variable and the size of a class object are not the same. $(C .sizeof) is the size of a class variable and is always the same value: 8 on 64-bit systems and 4 on 32-bit systems. The size of a class object must be obtained by $(C __traits(classInstanceSize)):
)

---
    // Allocate room for 10 MyClass objects
    MyClass * buffer =
        cast(MyClass*)GC.calloc(
            $(HILITE __traits(classInstanceSize, MyClass)) * 10);
---

$(P
$(IX OutOfMemoryError) When there is not enough memory in the system for the requested size, then a $(C core.exception.OutOfMemoryError) exception is thrown:
)

---
    void * buffer = GC.calloc(10_000_000_000);
---

$(P
The output on a system that does not have that much free space:
)

$(SHELL
core.exception.OutOfMemoryError
)

$(P
$(IX GC.free) The memory areas that are allocated from the GC can be returned back to it using $(C GC.free):
)

---
    GC.free(buffer);
---

$(P
However, calling $(C free()) does not necessarily execute the destructors of the variables that live on that memory block. The destructors may be executed explicitly by calling $(C destroy()) for each variable. Note that various internal mechanisms are used to call finalizers on $(C class) and $(C struct) variables during GC collection or freeing. The best way to ensure these are called is to use the $(C new) operator when allocating variables. In that case, $(C GC.free) will call the destructors.
)

$(P
$(IX GC.realloc) Sometimes the program may determine that a previously allocated memory area is all used up and does not have room for more data. It is possible to $(I extend) a previously allocated memory area by $(C GC.realloc). $(C realloc()) takes the previously allocated memory pointer and the newly requested size, and returns a new area:
)

---
    void * oldBuffer = GC.calloc(100);
// ...
    void * newBuffer = GC.realloc(oldBuffer, 200);
---

$(P
$(C realloc()) tries to be efficient by not actually allocating new memory unless it is really necessary:
)

$(UL

$(LI If the memory area following the old area is not in use for any other purpose and is large enough to satisfy the new request, $(C realloc()) adds that part of the memory to the old area, extending the buffer $(I in-place).)

$(LI If the memory area following the old area is already in use or is not large enough, then $(C realloc()) allocates a new larger memory area and copies the contents of the old area to the new one.)

$(LI It is possible to pass $(C null) as $(C oldBuffer), in which case $(C realloc()) simply allocates new memory.)

$(LI It is possible to pass a size less than the previous one, in which case the remaining part of the old memory is returned back to the GC.)

$(LI It is possible to pass 0 as the new size, in which case $(C realloc()) simply frees the memory.)

)

$(P
$(C GC.realloc) is adapted from the C standard library function $(C realloc()). For having such a complicated behavior, $(C realloc()) is considered to have a badly designed function interface. A potentially surprising aspect of $(C GC.realloc) is that even if the original memory has been allocated with $(C GC.calloc), the extended part is never cleared. For that reason, when it is important that the memory is zero-initialized, a function like $(C reallocCleared()) below would be useful. We will see the meaning of $(C blockAttributes) later below:
)

---
$(CODE_NAME reallocCleared)import core.memory;

/* Works like GC.realloc but clears the extra bytes if memory
 * is extended. */
void * reallocCleared(
    void * buffer,
    size_t oldLength,
    size_t newLength,
    GC.BlkAttr blockAttributes = GC.BlkAttr.NONE,
    const TypeInfo typeInfo = null) {
    /* Dispatch the actual work to GC.realloc. */
    buffer = GC.realloc(buffer, newLength,
                        blockAttributes, typeInfo);

    /* Clear the extra bytes if extended. */
    if (newLength > oldLength) {
        import core.stdc.string;

        auto extendedPart = buffer + oldLength;
        const extendedLength = newLength - oldLength;

        memset(extendedPart, 0, extendedLength);
    }

    return buffer;
}
---

$(P
$(IX memset, core.stdc.string) The function above uses $(C memset()) from the $(C core.stdc.string) module to clear the newly extended bytes. $(C memset()) assigns the specified value to the bytes of a memory area specified by a pointer and a length. In the example, it assigns $(C 0) to $(C extendedLength) number of bytes at $(C extendedPart).
)

$(P
We will use $(C reallocCleared()) in an example below.
)

$(P
$(IX GC.extend) The behavior of the similar function $(C GC.extend) is not complicated like $(C realloc()); it applies only the first item above: If the memory area cannot be extended in-place, $(C extend()) does not do anything and returns 0.
)

$(H6 $(IX memory block attribute) $(IX BlkAttr) Memory block attributes)

$(P
The concepts and the steps of a GC algorithm can be configured to some degree for each memory block by $(C enum BlkAttr). $(C BlkAttr) is an optional parameter of $(C GC.calloc) and other allocation functions. It consists of the following values:
)

$(UL

$(LI $(C NONE): The value zero; specifies $(I no attribute).)

$(LI $(C FINALIZE): Specifies that the objects that live in the memory block should be finalized.

$(P
Normally, the GC assumes that the lifetimes of objects that live on explicitly-allocated memory locations are under the control of the programmer; it does not finalize objects on such memory areas. $(C GC.BlkAttr.FINALIZE) is for requesting the GC to execute the destructors of objects:
)

---
    Class * buffer =
        cast(Class*)GC.calloc(
            __traits(classInstanceSize, Class) * 10,
            GC.BlkAttr.FINALIZE);
---

$(P
Note that $(C FINALIZE) depends on implementation details properly set up on the block. It is highly recommended to let the GC take care of setting up these details using the $(C new) operator.
)

)

$(LI $(C NO_SCAN): Specifies that the memory area should not be scanned by the GC.

$(P
The byte values in a memory area may accidentally look like pointers to unrelated objects in other parts of the memory. When that happens, the GC would assume that those objects are still in use even after their actual lifetimes have ended.
)

$(P
A memory block that is known to not contain any object pointers should be marked as $(C GC.BlkAttr.NO_SCAN):
)

---
    int * intBuffer =
        cast(int*)GC.calloc(100, GC.BlkAttr.NO_SCAN);
---

$(P
The $(C int) variables placed in that memory block can have any value without concern of being mistaken for object pointers.
)

)

$(LI $(C NO_MOVE): Specifies that objects in the memory block should not be moved to other places.)

$(LI $(C APPENDABLE): This is an internal flag used by the D runtime to aid in fast appending. You should not use this flag when allocating memory.)

$(LI $(C NO_INTERIOR): Specifies that only pointers to the block's first address exist. This allows one to cut down on "false pointers" because a pointer to the middle of the block does not count when tracing where a pointer goes.)

)

$(P
$(IX |) The values of $(C enum BlkAttr) are suitable to be used as bit flags that we saw in $(LINK2 bit_operations.html, the Bit Operations chapter). The following is how two attributes can be merged by the $(C |) operator:
)

---
    const attributes =
        GC.BlkAttr.NO_SCAN $(HILITE |) GC.BlkAttr.NO_INTERIOR;
---

$(P
Naturally, the GC would be aware only of memory blocks that are reserved by its own functions and scans only those memory blocks. For example, it would not know about a memory block allocated by $(C core.stdc.stdlib.calloc).
)

$(P
$(IX GC.addRange) $(IX GC.removeRange) $(IX GC.addRoot) $(C GC.addRange) is for introducing unrelated memory blocks to the GC. The complement function $(C GC.removeRange) should be called before freeing a memory block by other means e.g. by $(C core.stdc.stdlib.free).
)

$(P
In some cases, there may be no reference in the program to a memory block even if that memory block has been reserved by the GC. For example, if the only reference to a memory block lives inside a C library, the GC would normally not know about that reference and assume that the memory block is not in use anymore.
)

$(P
$(C GC.addRoot) introduces a memory block to the GC as a $(I root), to be scanned during collection cycles. All of the variables that can be reached directly or indirectly through that memory block would be marked as alive. The complement function $(C GC.removeRoot) should be called when a memory block is not in use anymore.
)

$(H6 Example of extending a memory area)

$(P
Let's design a simple $(C struct) template that works like an array. To keep the example short, let's provide only the functionality of adding and accessing elements. Similar to arrays, let's increase the capacity as needed. The following program uses $(C reallocCleared()), which has been defined above:
)

---
$(CODE_NAME Array)$(CODE_XREF reallocCleared)struct Array(T) {
    T * buffer;         // Memory area that holds the elements
    size_t capacity;    // The element capacity of the buffer
    size_t length;      // The number of actual elements

    /* Returns the specified element */
    T element(size_t index) {
        import std.string;
        enforce(index < length,
                format("Invalid index %s", index));

        return *(buffer + index);
    }

    /* Appends the element to the end */
    void append(T element) {
        writefln("Appending element %s", length);

        if (length == capacity) {
            /* There is no room for the new element; must
             * increase capacity. */
            size_t newCapacity = capacity + (capacity / 2) + 1;
            increaseCapacity(newCapacity);
        }

        /* Place the element at the end */
        *(buffer + length) = element;
        ++length;
    }

    void increaseCapacity(size_t newCapacity) {
        writefln("Increasing capacity from %s to %s",
                 capacity, newCapacity);

        size_t oldBufferSize = capacity * T.sizeof;
        size_t newBufferSize = newCapacity * T.sizeof;

        /* Also specify that this memory block should not be
         * scanned for pointers. */
        buffer = cast(T*)$(HILITE reallocCleared)(
            buffer, oldBufferSize, newBufferSize,
            GC.BlkAttr.NO_SCAN);

        capacity = newCapacity;
    }
}
---

$(P
The capacity of the array grows by about 50%. For example, after the capacity for 100 elements is consumed, the new capacity would become 151. ($(I The extra 1 is for the case of 0 length, where adding 50% would not grow the array.))
)

$(P
The following program uses that template with the $(C double) type:
)

---
$(CODE_XREF Array)import std.stdio;
import core.memory;
import std.exception;

// ...

void main() {
    auto array = Array!double();

    const count = 10;

    foreach (i; 0 .. count) {
        double elementValue = i * 1.1;
        array.append(elementValue);
    }

    writeln("The elements:");

    foreach (i; 0 .. count) {
        write(array.element(i), ' ');
    }

    writeln();
}
---

$(P
The output:
)

$(SHELL
Adding element with index 0
Increasing capacity from 0 to 1
Adding element with index 1
Increasing capacity from 1 to 2
Adding element with index 2
Increasing capacity from 2 to 4
Adding element with index 3
Adding element with index 4
Increasing capacity from 4 to 7
Adding element with index 5
Adding element with index 6
Adding element with index 7
Increasing capacity from 7 to 11
Adding element with index 8
Adding element with index 9
The elements:
0 1.1 2.2 3.3 4.4 5.5 6.6 7.7 8.8 9.9 
)

$(H5 $(IX alignment) Alignment)

$(P
By default, every object is placed at memory locations that are multiples of an amount specific to the type of that object. That amount is called the $(I alignment) of that type. For example, the alignment of $(C int) is 4 because $(C int) variables are placed at memory locations that are multiples of 4 (4, 8, 12, etc.).
)

$(P
Alignment is needed for CPU performance or requirements, because accessing misaligned memory addresses can be slower or cause a bus error. In addition, certain types of variables only work properly at aligned addresses.
)

$(H6 $(IX .alignof) The $(C .alignof) property)

$(P
$(IX classInstanceAlignment) The $(C .alignof) property of a type is its default alignment value. For classes, $(C .alignof) is the alignment of the class variable, not the class object. The alignment of a class object is obtained by $(C std.traits.classInstanceAlignment).
)

$(P
The following program prints the alignments of various types:
)

---
import std.stdio;
import std.meta;
import std.traits;

struct EmptyStruct {
}

struct Struct {
    char c;
    double d;
}

class EmptyClass {
}

class Class {
    char c;
}

void main() {
    alias Types = AliasSeq!(char, short, int, long,
                            double, real,
                            string, int[int], int*,
                            EmptyStruct, Struct,
                            EmptyClass, Class);

    writeln(" Size  Alignment  Type\n",
            "=========================");

    foreach (Type; Types) {
        static if (is (Type == class)) {
            size_t size = __traits(classInstanceSize, Type);
            size_t alignment = $(HILITE classInstanceAlignment!Type);

        } else {
            size_t size = Type.sizeof;
            size_t alignment = $(HILITE Type.alignof);
        }

        writefln("%4s%8s      %s",
                 size, alignment, Type.stringof);
    }
}
---

$(P
The output of the program may be different in different environments. The following is a sample output:
)

$(SHELL
 Size  Alignment  Type
=========================
   1       1      char
   2       2      short
   4       4      int
   8       8      long
   8       8      double
  16      16      real
  16       8      string
   8       8      int[int]
   8       8      int*
   1       1      EmptyStruct
  16       8      Struct
  16       8      EmptyClass
  17       8      Class
)

$(P
We will see later below how variables can be constructed (emplaced) at specific memory locations. For correctness and efficiency, objects must be constructed at addresses that match their alignments.
)

$(P
Let's consider two $(I consecutive) objects of $(C Class) type above, which are 17 bytes each. Although 0 is not a legal address for a variable on most platforms, to simplify the example let's assume that the first object is at address 0. The 17 bytes of this object would be at adresses from 0 to 16:
)

$(MONO
     $(HILITE 0)    1           16
  ┌────┬────┬─ ... ─┬────┬─ ...
  │$(HILITE <────first object────>)│
  └────┴────┴─ ... ─┴────┴─ ...
)

$(P
$(IX padding) Although the next available address is 17, that location cannot be used for a $(C Class) object because 17 is not a multiple of the alignment value 8 of that type. The nearest possible address for the second object is 24 because 24 is the next smallest multiple of 8. When the second object is placed at that address, there would be unused bytes between the two objects. Those bytes are called $(I padding bytes):
)

$(P
)

$(MONO
     $(HILITE 0)    1           16   17           23   $(HILITE 24)   25           30
  ┌────┬────┬─ ... ─┬────┬────┬─ ... ─┬────┬────┬────┬─ ... ─┬────┬─ ...
  │$(HILITE <────first object────>)│<────$(I padding)────>│$(HILITE <───second object────>)│
  └────┴────┴─ ... ─┴────┴────┴─ ... ─┴────┴────┴────┴─ ... ─┴────┴─ ...
)

$(P
The following formula can determine the nearest address value that an object can be placed at:
)

---
    (candidateAddress + alignmentValue - 1)
    / alignmentValue
    * alignmentValue
---

$(P
For that formula to work, the fractional part of the result of the division must be truncated. Since truncation is automatic for integral types, all of the variables above are assumed to be integral types.
)

$(P
We will use the following function in the examples later below:
)

---
$(CODE_NAME nextAlignedAddress)T * nextAlignedAddress(T)(T * candidateAddr) {
    import std.traits;

    static if (is (T == class)) {
        const alignment = classInstanceAlignment!T;

    } else {
        const alignment = T.alignof;
    }

    const result = (cast(size_t)candidateAddr + alignment - 1)
                   / alignment * alignment;
    return cast(T*)result;
}
---

$(P
That function template deduces the type of the object from its template parameter. Since that is not possible when the type is $(C void*), the type must be provided as an explicit template argument for the $(C void*) overload. That overload can trivially forward the call to the function template above:
)

---
$(CODE_NAME nextAlignedAddress_void)void * nextAlignedAddress(T)(void * candidateAddr) {
    return nextAlignedAddress(cast(T*)candidateAddr);
}
---

$(P
The function template above will be useful below when constructing $(I class) objects by $(C emplace()).
)

$(P
Let's define one more function template to calculate the total size of an object including the padding bytes that must be placed between two objects of that type:
)

---
$(CODE_NAME sizeWithPadding)size_t sizeWithPadding(T)() {
    static if (is (T == class)) {
        const candidateAddr = __traits(classInstanceSize, T);

    } else {
        const candidateAddr = T.sizeof;
    }

    return cast(size_t)nextAlignedAddress(cast(T*)candidateAddr);
}
---

$(H6 $(IX .offsetof) The $(C .offsetof) property)

$(P
Alignment is observed for members of user-defined types as well. There may be padding bytes $(I between) members so that the members are aligned according to their respective types. For that reason, the size of the following $(C struct) is not 6 bytes as one might expect, but 12:
)

---
struct A {
    byte b;     // 1 byte
    int i;      // 4 bytes
    ubyte u;    // 1 byte
}

static assert($(HILITE A.sizeof == 12));    // More than 1 + 4 + 1
---

$(P
This is due to padding bytes before the $(C int) member so that it is aligned at an address that is a multiple of 4, as well as padding bytes at the end for the alignment of the entire $(C struct) object itself.
)

$(P
The $(C .offsetof) property gives the number of bytes a member variable is from the beginning of the object that it is a part of. The following function prints the layout of a type by determining the padding bytes by $(C .offsetof):
)

---
$(CODE_NAME printObjectLayout)void printObjectLayout(T)()
        if (is (T == struct) || is (T == union)) {
    import std.stdio;
    import std.string;

    writefln("=== Memory layout of '%s'" ~
             " (.sizeof: %s, .alignof: %s) ===",
             T.stringof, T.sizeof, T.alignof);

    /* Prints a single line of layout information. */
    void printLine(size_t offset, string info) {
        writefln("%4s: %s", offset, info);
    }

    /* Prints padding information if padding is actually
     * observed. */
    void maybePrintPaddingInfo(size_t expectedOffset,
                               size_t actualOffset) {
        if (expectedOffset < actualOffset) {
            /* There is some padding because the actual offset
             * is beyond the expected one. */

            const paddingSize = actualOffset - expectedOffset;

            printLine(expectedOffset,
                      format("... %s-byte PADDING",
                             paddingSize));
        }
    }

    /* This is the expected offset of the next member if there
     * were no padding bytes before that member. */
    size_t noPaddingOffset = 0;

    /* Note: __traits(allMembers) is a 'string' collection of
     * names of the members of a type. */
    foreach (memberName; __traits(allMembers, T)) {
        mixin (format("alias member = %s.%s;",
                      T.stringof, memberName));

        const offset = member$(HILITE .offsetof);
        maybePrintPaddingInfo(noPaddingOffset, offset);

        const typeName = typeof(member).stringof;
        printLine(offset,
                  format("%s %s", typeName, memberName));

        noPaddingOffset = offset + member.sizeof;
    }

    maybePrintPaddingInfo(noPaddingOffset, T.sizeof);
}
---

$(P
The following program prints the layout of the 12-byte $(C struct A) that was defined above:
)

---
$(CODE_XREF printObjectLayout)struct A {
    byte b;
    int i;
    ubyte u;
}

void main() {
    printObjectLayout!A();
}
---

$(P
The output of the program showns where the total of 6 padding bytes are located inside the object. The first column of the output is the offset from the beginning of the object:
)

$(SHELL
=== Memory layout of 'A' (.sizeof: $(HILITE 12), .alignof: 4) ===
   0: byte b
   1: ... 3-byte PADDING
   4: int i
   8: ubyte u
   9: ... 3-byte PADDING
)

$(P
One technique of minimizing padding is ordering the members by their sizes from the largest to the smallest. For example, when the $(C int) member is moved to the beginning of the previous $(C struct) then the size of the object would be less:
)

---
$(CODE_XREF printObjectLayout)struct B {
    $(HILITE int i;)    // Moved up inside the struct definition
    byte b;
    ubyte u;
}

void main() {
    printObjectLayout!B();
}
---

$(P
This time, the size of the object is down to 8 due to just 2 bytes of padding at the end:
)

$(SHELL
=== Memory layout of 'B' (.sizeof: $(HILITE 8), .alignof: 4) ===
   0: int i
   4: byte b
   5: ubyte u
   6: ... 2-byte PADDING
)

$(H6 $(IX align) The $(C align) attribute)

$(P
The $(C align) attribute is for specifying alignments of variables, user-defined types, and members of user-defined types. The value provided in parentheses specifies the alignment value. Every definition can be specified separately. For example, the following definition would align $(C S) objects at 2-byte boundaries and its $(C i) member at 1-byte boundaries (1-byte alignment always results in no padding at all):
)

---
$(CODE_XREF printObjectLayout)$(HILITE align (2))               // The alignment of 'S' objects
struct S {
    byte b;
    $(HILITE align (1)) int i;    // The alignment of member 'i'
    ubyte u;
}

void main() {
    printObjectLayout!S();
}
---

$(P
When the $(C int) member is aligned at a 1-byte boundary, there is no padding before it and this time the size of the object ends up being exactly 6:
)

$(SHELL
=== Memory layout of 'S' (.sizeof: $(HILITE 6), .alignof: 4) ===
   0: byte b
   1: int i
   5: ubyte u
)

$(P
Although $(C align) can reduce sizes of user-defined types, there can be $(I significant performance penalties) when default alignments of types are not observed (and on some CPUs, using misaligned data can actually crash the program).
)

$(P
$(C align) can specify the alignment of variables as well:
)

---
    $(HILITE align (32)) double d;    // The alignment of a variable
---

$(P
However, objects that are allocated by $(C new) must always be aligned at multiples of the size of the $(C size_t) type because that is what the GC assumes. Doing otherwise is undefined behavior. For example, if $(C size_t) is 8 bytes long, than the alignments of variables allocated by $(C new) must be a multiple of 8.
)

$(H5 $(IX construction, emplace) $(IX emplace) Constructing variables at specific memory locations)

$(P
$(IX new) The $(C new) expression achieves three tasks:
)

$(OL

$(LI Allocates memory large enough for the object. The newly allocated memory area is considered to be $(I raw), not associated with any type or any object.
)

$(LI Copies the $(C .init) value of that type on that memory area and executes the constructor of the object on that area. Only after this step the object becomes $(I placed) on that memory area.
)

$(LI Configures the memory block so it has all the necessary flags and infrastructure to properly destroy the object when freed.
)

)

$(P
We have already seen that the first of these tasks can explicitly be achieved by memory allocation functions like $(C GC.calloc). Being a system language, D allows the programmer manage the second step as well.
)

$(P
Variables can be constructed at specific locations with $(C std.conv.emplace).
)

$(H6 $(IX emplace, struct) Constructing a struct object at a specific location)

$(P
$(C emplace()) takes the address of a memory location as its first parameter and constructs an object at that location. If provided, it uses the remaining parameters as the object's constructor arguments:
)

---
import std.conv;
// ...
    emplace($(I address), /* ... constructor arguments ... */);
---

$(P
It is not necessary to specify the type of the object explicitly when constructing a $(C struct) object because $(C emplace()) deduces the type of the object from the type of the pointer. For example, since the type of the following pointer is $(C Student*), $(C emplace()) constructs a $(C Student) object at that address:
)

---
        Student * objectAddr = nextAlignedAddress(candidateAddr);
// ...
        emplace(objectAddr, name, id);
---

$(P
The following program allocates a memory area large enough for three objects and constructs them one by one at aligned addresses inside that memory area:
)

---
$(CODE_XREF sizeWithPadding)$(CODE_XREF nextAlignedAddress)import std.stdio;
import std.string;
import core.memory;
import std.conv;

// ...

struct Student {
    string name;
    int id;

    string toString() {
        return format("%s(%s)", name, id);
    }
}

void main() {
    /* Some information about this type. */
    writefln("Student.sizeof: %#x (%s) bytes",
             Student.sizeof, Student.sizeof);
    writefln("Student.alignof: %#x (%s) bytes",
             Student.alignof, Student.alignof);

    string[] names = [ "Amy", "Tim", "Joe" ];
    const totalSize = sizeWithPadding!Student() * names.length;

    /* Reserve room for all Student objects.
     *
     * Warning! The objects that are accessible through this
     * slice are not constructed yet; they should not be
     * accessed until after they are properly constructed. */
    Student[] students =
        (cast(Student*)GC.calloc(totalSize))[0 .. names.length];

    foreach (i, name; names) {
        Student * candidateAddr = students.ptr + i;
        Student * objectAddr =
            nextAlignedAddress(candidateAddr);
        writefln("address of object %s: %s", i, objectAddr);

        const id = 100 + i.to!int;
        $(HILITE emplace)(objectAddr, name, id);
    }

    /* All of the objects are constructed and can be used. */
    writeln(students);
}
---

$(P
The output of the program:
)

$(SHELL
Student.sizeof: 0x18 (24) bytes
Student.alignof: 0x8 (8) bytes
address of object 0: 7F1532861F00
address of object 1: 7F1532861F18
address of object 2: 7F1532861F30
[Amy(100), Tim(101), Joe(102)]
)

$(H6 $(IX emplace, class) Constructing a class object at a specific location)

$(P
Class variables need not be of the exact type of class objects. For example, a class variable of type $(C Animal) can refer to a $(C Cat) object. For that reason, $(C emplace()) does not determine the type of the object from the type of the memory pointer. Instead, the actual type of the object must be explicitly specified as a template argument of $(C emplace()). ($(I $(B Note:) Additionally, a class pointer is a pointer to a class variable, not to a class object. For that reason, specifying the actual type allows the programmer to specify whether to emplace a class object or a class variable.))
)

$(P
$(IX void[]) The memory location for a class object must be specified as a $(C void[]) slice with the following syntax:
)

---
    Type variable =
        emplace!$(I Type)($(I voidSlice),
                         /* ... constructor arguments ... */);
---

$(P
$(C emplace()) constructs a class $(I object) at the location specified by the slice and returns a class $(I variable) for that object.
)

$(P
Let's use $(C emplace()) on objects of an $(C Animal) hierarchy. The objects of this hierarchy will be placed $(I side-by-side) on a piece of memory that is allocated by $(C GC.calloc). To make the example more interesting, we will ensure that the subclasses have different sizes. This will be useful to demonstrate how the address of a subsequent object can be determined depending on the size of the previous one.
)

---
$(CODE_NAME Animal)interface Animal {
    string sing();
}

class Cat : Animal {
    string sing() {
        return "meow";
    }
}

class Parrot : Animal {
    string[] lyrics;

    this(string[] lyrics) {
        this.lyrics = lyrics;
    }

    string sing() {
        /* std.algorithm.joiner joins elements of a range with
         * the specified separator. */
        return lyrics.joiner(", ").to!string;
    }
}
---

$(P
The buffer that holds the objects will be allocated with $(C GC.calloc):
)

---
    const capacity = 10_000;
    void * buffer = GC.calloc(capacity);
---

$(P
Normally, it must be ensured that there is always available capacity for objects. We will ignore that check here to keep the example simple and assume that the objects in the example will fit in ten thousand bytes.
)

$(P
The buffer will be used for constructing a $(C Cat) and a $(C Parrot) object:
)

---
    Cat cat = emplace!Cat(catPlace);
// ...
    Parrot parrot =
        emplace!Parrot(parrotPlace, [ "squawk", "arrgh" ]);
---

$(P
Note that the constructor argument of $(C Parrot) is specified after the address of the object.
)

$(P
The variables that $(C emplace()) returns will be stored in an $(C Animal) slice later to be used in a $(C foreach) loop:
)

---
    Animal[] animals;
// ...
    animals ~= cat;
// ...
    animals ~= parrot;

    foreach (animal; animals) {
        writeln(animal.sing());
    }
---

$(P
More explanations are inside the code comments:
)

---
$(CODE_XREF Animal)$(CODE_XREF nextAlignedAddress)$(CODE_XREF nextAlignedAddress_void)import std.stdio;
import std.algorithm;
import std.conv;
import core.memory;

// ...

void main() {
    /* A slice of Animal variables (not Animal objects). */
    Animal[] animals;

    /* Allocating a buffer with an arbitrary capacity and
     * assuming that the two objects in this example will fit
     * in that area. Normally, this condition must be
     * validated. */
    const capacity = 10_000;
    void * buffer = GC.calloc(capacity);

    /* Let's first place a Cat object. */
    void * catCandidateAddr = buffer;
    void * catAddr = nextAlignedAddress!Cat(catCandidateAddr);
    writeln("Cat address   : ", catAddr);

    /* Since emplace() requires a void[] for a class object,
     * we must first produce a slice from the pointer. */
    size_t catSize = __traits(classInstanceSize, Cat);
    void[] catPlace = catAddr[0..catSize];

    /* Construct a Cat object inside that memory slice and
     * store the returned class variable for later use. */
    Cat cat = $(HILITE emplace!Cat)(catPlace);
    animals ~= cat;

    /* Now construct a Parrot object at the next available
     * address that satisfies the alignment requirement. */
    void * parrotCandidateAddr = catAddr + catSize;
    void * parrotAddr =
        nextAlignedAddress!Parrot(parrotCandidateAddr);
    writeln("Parrot address: ", parrotAddr);

    size_t parrotSize = __traits(classInstanceSize, Parrot);
    void[] parrotPlace = parrotAddr[0..parrotSize];

    Parrot parrot =
        $(HILITE emplace!Parrot)(parrotPlace, [ "squawk", "arrgh" ]);
    animals ~= parrot;

    /* Use the objects. */
    foreach (animal; animals) {
        writeln(animal.sing());
    }
}
---

$(P
The output:
)

$(SHELL
Cat address   : 7F0E343A2000
Parrot address: 7F0E343A2018
meow
squawk, arrgh
)

$(P
Instead of repeating the steps inside $(C main()) for each object, a function template like $(C newObject(T)) would be more useful.
)

$(H5 Destroying objects explicitly)

$(P
The reverse operations of the $(C new) operator are destroying an object and returning the object's memory back to the GC. Normally, these operations are executed automatically at unspecified times.
)

$(P
However, sometimes it is necessary to execute destructors at specific points in the program. For example, an object may be closing a $(C File) member in its destructor and the destructor may have to be executed immediately when the lifetime of the object ends.
)

$(P
$(IX destroy) $(C destroy()) calls the destructor of an object:
)

---
    destroy(variable);
---

$(P
$(IX .init) After executing the destructor, $(C destroy()) sets the variable to its $(C .init) state. Note that the $(C .init) state of a class variable is $(C null); so, a class variable cannot be used once destroyed. $(C destroy()) merely executes the destructor. It is still up to the GC when to reuse the piece of memory that used to be occupied by the destroyed object.
)

$(P
$(B Warning:) When used with a $(I struct) pointer, $(C destroy()) must receive the pointee, not the pointer. Otherwise, the pointer would be set to $(C null) but the object would not be destroyed:
)

---
import std.stdio;

struct S {
    int i;

    this(int i) {
        this.i = i;
        writefln("Constructing object with value %s", i);
    }

    ~this() {
        writefln("Destroying object with value %s", i);
    }
}

void main() {
    auto p = new S(42);

    writeln("Before destroy()");
    destroy($(HILITE p));                        // ← WRONG USAGE
    writeln("After destroy()");

    writefln("p: %s", p);

    writeln("Leaving main");
}
---

$(P
When $(C destroy()) receives a pointer, it is the pointer that gets destroyed (i.e. the pointer becomes $(C null)):
)

$(SHELL
Constructing object with value 42
Before destroy()
After destroy()  $(SHELL_NOTE_WRONG The object is not destroyed before this line)
p: null          $(SHELL_NOTE_WRONG Instead, the pointer becomes null)
Leaving main
Destroying object with value 42
)

$(P
For that reason, when used with a struct pointer, $(C destroy()) must receive the pointee:
)

---
    destroy($(HILITE *p));                       // ← Correct usage
---

$(P
This time the destructor is executed at the right spot and the pointer is not set to $(C null):
)

$(SHELL
Constructing object with value 42
Before destroy()
Destroying object with value 42  $(SHELL_NOTE Destroyed at the right spot)
After destroy()
p: 7FB64FE3F200                  $(SHELL_NOTE The pointer is not null)
Leaving main
Destroying object with value 0   $(SHELL_NOTE Once more for S.init)
)

$(P
The last line is due to executing the destructor one more time for the same object, which now has the value $(C S.init).
)

$(H5 $(IX construction, by name) Constructing objects at run time by name)

$(P
$(IX factory) $(IX Object) The $(C factory()) member function of $(C Object) takes the fully qualified name of a class type as parameter, constructs an object of that type, and returns a class variable for that object:
)

---
$(HILITE module test_module);

import std.stdio;

interface Animal {
    string sing();
}

class Cat : Animal {
    string sing() {
        return "meow";
    }
}

class Dog : Animal {
    string sing() {
        return "woof";
    }
}

void main() {
    string[] toConstruct = [ "Cat", "Dog", "Cat" ];

    Animal[] animals;

    foreach (typeName; toConstruct) {
        /* The pseudo variable __MODULE__ is always the name
         * of the current module, which can be used as a
         * string literal at compile time. */
        const fullName = __MODULE__ ~ '.' ~ typeName;
        writefln("Constructing %s", fullName);
        animals ~= cast(Animal)$(HILITE Object.factory)(fullName);
    }

    foreach (animal; animals) {
        writeln(animal.sing());
    }
}
---

$(P
Although there is no explicit $(C new) expression in that program, three class objects are created and added to the $(C animals) slice:
)

$(SHELL
Constructing test_module.Cat
Constructing test_module.Dog
Constructing test_module.Cat
meow
woof
meow
)

$(P
Note that $(C Object.factory()) takes the fully qualified name of the type of the object. Also, the return type of $(C factory()) is $(C Object); so, it must be cast to the actual type of the object before being used in the program.
)

$(H5 Summary)

$(UL
$(LI The garbage collector scans the memory at unspecified times, determines the objects that cannot possibly be reached anymore by the program, destroys them, and reclaims their memory locations.)

$(LI The operations of the GC may be controlled by the programmer to some extent by $(C GC.collect), $(C GC.disable), $(C GC.enable), $(C GC.minimize), etc.)

$(LI $(C GC.calloc) and other functions reserve memory, $(C GC.realloc) extends a previously allocated memory area, and $(C GC.free) returns it back to the GC.)

$(LI It is possible to mark the allocated memory by attributes like $(C GC.BlkAttr.NO_SCAN), $(C GC.BlkAttr.NO_INTERIOR), etc.)

$(LI The $(C .alignof) property is the default memory alignment of a type. Alignment must be obtained by $(C classInstanceAlignment) for class $(I objects).)

$(LI The $(C .offsetof) property is the number of bytes a member is from the beginning of the object that it is a part of.)

$(LI The $(C align) attribute specifies the alignment of a variable, a user-defined type, or a member.)

$(LI $(C emplace()) takes a pointer when constructing a $(C struct) object, a $(C void[]) slice when constructing a $(C class) object.)

$(LI $(C destroy()) executes the destructor of objects. (One must destroy the struct pointee, not the struct pointer.))

$(LI $(C Object.factory()) constructs objects with their fully qualified type names.)

)

macros:
        TITLE=Memory Management

        DESCRIPTION=The memory, the garbage collector, and managing memory explicitly.

        KEYWORDS=d programming language tutorial book integer gc memory
