#!/usr/bin/env dub
/++
dub.sdl:
dependency "libdparse" version="0.7.0-beta.7"
name "assert_writeln_magic"
+/
/*
 * Tries to convert `assert`'s into user-friendly `writeln` calls.
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

class TestVisitor : ASTVisitor
{
    import dparse.lexer : tok, Token;

    this(string fileName)
    {
        this.fileName = fileName;
        fl = FileLines(fileName);
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

    string fileName;
    FileLines fl;
}

void parseFile(string fileName)
{
    import dparse.lexer;
    import dparse.parser : parseModule;
    import dparse.rollback_allocator : RollbackAllocator;
    import std.array : uninitializedArray;

    auto inFile = File(fileName);
    if (inFile.size == 0)
        warningf("%s is empty", inFile.name);

    ubyte[] sourceCode = uninitializedArray!(ubyte[])(to!size_t(inFile.size));
    inFile.rawRead(sourceCode);
    LexerConfig config;
    auto cache = StringCache(StringCache.defaultBucketCount);
    const(Token)[] tokens = getTokensForParser(sourceCode, config, &cache).array;

    RollbackAllocator rba;
    auto m = parseModule(tokens, fileName, &rba);
    auto visitor = new TestVisitor(fileName);
    visitor.visit(m);
    delete visitor;
}

void main(string[] args)
{
    import std.file;
    import std.getopt;
    import std.path : asNormalizedPath;

    string inputDir;
    string[] ignoredFiles;

    auto helpInfo = getopt(args, config.required,
            "inputdir|i", "Folder to start the recursive search for unittest blocks (can be a single file)", &inputDir,
            "ignore", "List of files to exclude (partial matching is supported)", &ignoredFiles);

    if (helpInfo.helpWanted)
    {
        return defaultGetoptPrinter(`assert_writeln_magic
Tries to lower EqualExpression in AssertExpressions of Unittest blocks to commented writeln calls.
`, helpInfo.options);
    }

    inputDir = inputDir.asNormalizedPath.array;

    DirEntry[] files;

    if (inputDir.isFile)
    {
        files = [DirEntry(inputDir)];
        inputDir = ".";
    }
    else
    {
        files = dirEntries(inputDir, SpanMode.depth).filter!(
                a => a.name.endsWith(".d") && !a.name.canFind(".git")).array;
    }

    foreach (file; files)
        if (!ignoredFiles.any!(x => file.name.canFind(x)))
            file.name.parseFile;
}

/**
A simple line-based in-memory representation of a file.
 - will automatically write all changes when the objct is destructed
 - will use a temporary file to do safe, whole file swaps
*/
struct FileLines
{
    import std.array, std.file, std.path;

    string[] lines;
    string destFile, path, tmpDir;
    bool hasWrittenChanges;

    this(string path)
    {
        this(path.dirName, path.baseName);
    }

    this(string repoDir, string path)
    {
        writeln("opening: ", path);

        this.path = path;
        destFile = buildPath(repoDir, path);
        lines = File(destFile).byLineCopy.array;

        // it's a good practise to use a common tmp folder -> easier to look at or clean
        tmpDir = buildPath(tempDir, "file_tester", path.stripExtension.replace("/", "_"));
        tmpDir.mkdirRecurse;
    }

    // dumps all changes
    ~this()
    {
        auto tmpFile = writeLinesToFile;
        tmpFile.copy(destFile);
        tmpFile.remove;
        tmpDir.rmdirRecurse;
    }

    // writes all changes to a random, temporary file
    auto writeLinesToFile(string s = null) {
        import std.uuid;

        if (!s.length)
            s = buildPath(tmpDir, randomUUID.to!string.replace("-", "") ~ ".d");

        writeln("writing: ", path);
        auto outFile = File(s, "w");
        // dump file
        foreach (line; lines)
            outFile.writeln(line);
        // within the docs we automatically inject std.stdio (hence we need to do the same here)
        // writeln needs to be @nogc, @safe, pure and nothrow (we just fake it)
        if (hasWrittenChanges)
            outFile.writeln("void writeln(T)(T l) { }");
        outFile.flush;

        return s;
    }

    string opIndex(size_t i) { return lines[i]; }
    void opIndexAssign(string line, size_t i) {
        hasWrittenChanges = true;
        lines[i] = line;
    }
}
