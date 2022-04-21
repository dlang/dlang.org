#!/usr/bin/env dub
/++ dub.sdl:
dependency "libdparse" version="0.19.0"
name "assert_writeln_magic"
+/
/*
 * Tries to convert `assert`s into user-friendly `writeln` calls.
 * The objective of this tool is to be conservative as
 * broken example look a lot worse than a few statements
 * that could have potentially been rewritten.
 *
 *  - only EqualExpressions are "lowered"
 *  - static asserts are ignored
 *  - only single-line assers are rewritten
 *
 * Copyright (C) 2017 by D Language Foundation
 *
 * Author: Sebastian Wilzbach
 *
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE_1_0.txt or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
*/
// Written in the D programming language.

import dparse.ast;
import std.algorithm;
import std.conv;
import std.experimental.logger;
import std.range;
import std.stdio;
import std.typecons;

private string formatNode(T)(const T t)
{
    import dparse.formatter;
    import std.array : appender;

    auto writer = appender!string();
    auto formatter = new Formatter!(typeof(writer))(writer);
    formatter.format(t);
    return writer.data;
}

class TestVisitor(Out) : ASTVisitor
{
    import dparse.lexer : tok, Token;

    this(Out fl)
    {
        this.fl = fl;
    }

    alias visit = ASTVisitor.visit;

    override void visit(const Unittest test)
    {
        resetTestState();
        inTest = true;
        scope(exit) inTest = false;
        test.accept(this);

        processLastAssert();
    }

    override void visit(const EqualExpression expr)
    {
        enum eqToken = tok!"==";
        if (inAssert && expr.operator == eqToken && expr.left !is null && expr.right !is null)
            lastEqualExpression = expr;
    }

    override void visit(const AssertExpression expr)
    {
        if (inFunctionCall)
            return;

        // only look at `a == b` within the AssertExpression
        if (!expr.assertArguments ||
            typeid(expr.assertArguments.assertion) != typeid(CmpExpression))
            return;

        lastAssert = expr;
        inAssert = true;
        expr.accept(this);
        inAssert = false;
        fromAssert = true;
    }

    // for now static asserts are ignored
    override void visit(const StaticAssertStatement expr)
    {
        fromStaticAssert = true;
        expr.accept(this);
    }

    /**
    The following code (in std.concurrency) leads to false positives:

        assertNotThrown!AssertError(assert(receiveOnly!int() == i));

    Hence we simply ignore all asserts in function calls.
    */
    override void visit(const FunctionCallExpression expr)
    {
        inFunctionCall = true;
        expr.accept(this);
        inFunctionCall = false;
    }

    /// A single line
    override void visit(const DeclarationOrStatement expr)
    {
        processLastAssert();
        expr.accept(this);
    }

    void processLastAssert()
    {
        import std.uni : isWhite;
        import std.format : format;

        if (fromAssert && !fromStaticAssert &&
            lastEqualExpression !is null && lastAssert !is null)
        {
            auto e = lastEqualExpression;
            if (e.left !is null && e.right !is null)
            {
                // libdparse starts the line count with 1
                auto lineNr = lastAssert.line - 1;

                // only replace single-line expressions (for now)
                if (fl[lineNr].endsWith(";"))
                {
                    auto wsLen = fl[lineNr].countUntil!(u => !u.isWhite);
                    auto indent = fl[lineNr][0 .. wsLen];

                    if (fl[lineNr][wsLen .. $].startsWith("assert", "static assert"))
                    {
                        auto left = lastEqualExpression.left.formatNode;
                        auto right = lastEqualExpression.right.formatNode;

                        if (left.length + right.length > 80)
                            fl[lineNr] = format("%s// %s\n%swriteln(%s);", indent, right, indent, left);
                        else
                            fl[lineNr] = format("%swriteln(%s); // %s", indent, left, right);

                        //writefln("line: %d, column: %d", lastAssert.line, lastAssert.column);
                    }
                }
            }
        }
        resetTestState();
    }

private:

    void resetTestState()
    {
        fromAssert = false;
        fromStaticAssert = false;
        lastEqualExpression = null;
        lastAssert = null;
    }

    /// within in the node
    bool inTest;
    bool inAssert;
    bool inFunctionCall;

    /// at a sibling after the node was seen, but the upper parent hasn't been reached yet
    bool fromAssert;
    bool fromStaticAssert;

    Rebindable!(const AssertExpression) lastAssert;
    Rebindable!(const EqualExpression) lastEqualExpression;

    Out fl;
}

void parseString(Visitor)(const string filepath, ubyte[] sourceCode, Visitor visitor)
{
    import dparse.lexer;
    import dparse.parser : parseModule, ParserConfig;
    import dparse.rollback_allocator : RollbackAllocator;

    LexerConfig config;
    auto cache = StringCache(StringCache.defaultBucketCount);
    const(Token)[] tokens = getTokensForParser(sourceCode, config, &cache).array;

    RollbackAllocator rba;
    auto m = parseModule(ParserConfig(tokens, filepath, &rba));
    visitor.visit(m);
}

private auto assertWritelnModuleImpl(const string filepath, string fileText)
{
    import std.string : representation;
    auto fl = FileLines(fileText);
    scope visitor = new TestVisitor!(typeof(fl))(fl);
    // libdparse doesn't allow to work on immutable source code
    parseString(filepath, cast(ubyte[]) fileText.representation, visitor);
    return fl;
}

auto assertWritelnModule(const string filepath, string fileText)
{
    return assertWritelnModuleImpl(filepath, fileText).buildLines;
}
auto assertWritelnBlock(const string filepath, string fileText)
{
    auto source = "unittest{\n" ~ fileText ~ "}\n";
    auto fl = assertWritelnModuleImpl(filepath, source);
    auto app = appender!string;
    foreach (line; fl.lines[1 .. $ - 2])
    {
        app ~= line;
        app ~= "\n";
    }
    return app.data;
}

/**
A simple line-based in-memory representation of a file.
 - will automatically write all changes when the object is destructed
 - will use a temporary file to do safe, whole file swaps
*/
struct FileLines
{
    import std.array, std.file, std.path;

    string[] lines;
    string destFile;
    bool hasWrittenChanges;

    this(string inputText)
    {
        lines = inputText.split("\n");
    }

    // writes all changes to a random, temporary file
    auto buildLines() {
        auto app = appender!string;
        // dump file
        foreach (line; lines)
        {
            app ~= line;
            app ~= "\n";
        }
        // within the docs we automatically inject std.stdio (hence we need to do the same here)
        // writeln needs to be @nogc, @safe, pure and nothrow (we just fake it)
        app ~= "// \nprivate void writeln(T)(T l) { }";
        return app.data;
    }

    string opIndex(size_t i) { return lines[i]; }
    void opIndexAssign(string line, size_t i) {
        hasWrittenChanges = true;
        lines[i] = line;
    }
}

version(unittest)
{
    struct FileLinesMock
    {
        string[] lines;
        string opIndex(size_t i) { return lines[i]; }
        void opIndexAssign(string line, size_t i) {
            lines[i] = line;
        }
    }
    auto runTest(string sourceCode)
    {
        import std.string : representation;
        auto mock = FileLinesMock(sourceCode.split("\n"));
        scope visitor = new TestVisitor!(typeof(mock))(mock);
        parseString("unittest.d", sourceCode.representation.dup, visitor);
        return mock;
    }
}


unittest
{
    "Running tests for assert_writeln_magic".writeln;

    // purposefully not indented
    string testCode = q{
unittest
{
assert(equal(splitter!(a => a == ' ')("hello  world"), [ "hello", "", "world" ]));
assert(equal(splitter!(a => a == 0)(a), w));
}
    };
    auto res = runTest(testCode);
    assert(res.lines[3 .. $ - 2] == [
        "assert(equal(splitter!(a => a == ' ')(\"hello  world\"), [ \"hello\", \"\", \"world\" ]));",
        "assert(equal(splitter!(a => a == 0)(a), w));"
    ]);
}

unittest
{
    string testCode = q{
unittest
{
assert(1 == 2);
assert(foo() == "bar");
assert(foo() == bar);
assert(arr == [0, 1, 2]);
assert(r.back == 1);
}
    };
    auto res = runTest(testCode);
    assert(res.lines[3 .. $ - 2] == [
        "writeln(1); // 2",
        "writeln(foo()); // \"bar\"",
        "writeln(foo()); // bar",
        "writeln(arr); // [0, 1, 2]",
        "writeln(r.back); // 1",
    ]);

    "Successfully ran tests for assert_writeln_magic".writeln;
}
