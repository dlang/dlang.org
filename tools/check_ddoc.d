#!/usr/bin/env rdmd
/**
Search HTML output for errors:
- for undefined Ddoc macros
- raw macro leakage
- trailing parenthesis
*/
import std.algorithm, std.file, std.functional, std.range, std.stdio;

shared int errors = 0;

void error(string name, string file, size_t lineNr, const(char)[] line)
{
    import core.atomic;
    errors.atomicOp!"+="(1);
    synchronized
    {
        stderr.writefln("%s:%d: [%s] %s", file, lineNr, name, line);
    }
}

enum ErrorMessages
{
    undefinedMacro = "UNDEFINED MACRO",
    rawMacroLeakage = "RAW MACRO LEAKAGE",
    trailingParenthesis = "TRAILING PARENTHESIS",
}

void checkLine(alias errorFun)(string file, size_t lineNr, const(char)[] line)
{
    if (line.canFind("UNDEFINED MACRO"))
        errorFun(ErrorMessages.undefinedMacro, file, lineNr, line);

    if (line.findSplitAfter("$(")
            .pipe!(a => !a.expand.only.any!empty && a[1].front != '\''))
        errorFun(ErrorMessages.rawMacroLeakage, file, lineNr, line);

    if (line.equal(")"))
        errorFun(ErrorMessages.trailingParenthesis, file, lineNr, line);
}

version(unittest) {} else
int main(string[] args)
{
    import std.parallelism : parallel;

    auto files = args[1 .. $];
    foreach (file; files.parallel(1))
        foreach (nr, line; File(file, "r").byLine.enumerate)
            checkLine!error(file, nr, line);

    if (errors > 0)
        stderr.writefln("%s error%s found. Exiting.", errors, errors > 1 ? "s" : "");

    return errors != 0;
}

unittest
{
    string lastSeenError;
    void errorStub(string name, string file, size_t lineNr, const(char)[] line)
    {
        lastSeenError = name;
    }
    auto check(string line)
    {
        lastSeenError = null;
        checkLine!errorStub(null, 0, line);
        return lastSeenError;
    }

    assert(check(` <!--UNDEFINED MACRO: "D_CONTRIBUTORS"--> `) == ErrorMessages.undefinedMacro);

    assert(check("  $('") is null);
    assert(check("  $(") is null);
    assert(check("  $(FOO)") == ErrorMessages.rawMacroLeakage);

    assert(check("  )") is null);
    assert(check(") ") is null);
    assert(check(")") == ErrorMessages.trailingParenthesis);
}
