#!/usr/bin/env dub
/++
dub.sdl:
dependency "libdparse" version="0.7.0-beta.7"
dependency "mustache-d" version="0.1.3"
name "extract_dmd"
+/
/*
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

import mustache : MustacheEngine;
alias Mustache = MustacheEngine!(string);

class TraitsVisitor : ASTVisitor
{
    import dparse.lexer : tok, Token;

    alias visit = ASTVisitor.visit;
    alias Traits = Tuple!(string, "name", string, "comment");
    Traits[] traits;
    string specDir = "spec", destDir;

    mixin(AutoConstructor!(destDir));

    override void visit(const VariableDeclaration decl)
    {
        if (decl.comment)
        {
            string name = decl.autoDeclaration.parts.map!(a => cast(char[]) a.identifier.text).joiner.to!string;
            traits ~= Traits(name, decl.comment);
        }
    }

    void dump()
    {
        import std.path : buildPath, stripExtension;
        import std.file : dirEntries, mkdirRecurse, SpanMode;

        destDir.buildPath(specDir).mkdirRecurse;

        Mustache.Option opt = {
            ext: "dd"
        };
        auto mustache = new Mustache(opt);
        auto context = new Mustache.Context;

        context["traitsList"] = traits.map!(t => text("$(GBLINK ", t.name, ")")).joiner("\n").array;
        context["traitsListFull"] = traits.map!(t => text("$(H2 $(GNAME ", t.name, "))\n\n", t.comment)).joiner("\n").array;
        context["grammarTraitsList"] = traits.map!(t => text("$(TRAITS_LINK2 ", t.name, ")")).joiner("\n").array;

        foreach (file; specDir.dirEntries(SpanMode.shallow).filter!(f => f.name.endsWith(".dd")))
        {
            writefln("Reading: %s", file);
            File(destDir.buildPath(file), "w").rawWrite(mustache.render(file.stripExtension, context));
        }
    }

    // only look at public scope for now
    override void visit(const FunctionDeclaration decl) {}
    override void visit(const ClassDeclaration decl) {}
    override void visit(const InterfaceDeclaration decl) {}
    override void visit(const StructDeclaration decl) {}
    override void visit(const StaticConstructor decl) {}
}

void parseFile(string srcFile, string destFile)
{
    import dparse.lexer;
    import dparse.parser : parseModule;
    import dparse.rollback_allocator : RollbackAllocator;
    import std.array : uninitializedArray;

    auto inFile = File(srcFile);
    if (inFile.size == 0)
        warningf("%s is empty", inFile.name);

    ubyte[] sourceCode = uninitializedArray!(ubyte[])(to!size_t(inFile.size));
    if (sourceCode.length == 0)
        return;

    inFile.rawRead(sourceCode);
    LexerConfig config;
    auto cache = StringCache(StringCache.defaultBucketCount);
    const(Token)[] tokens = getTokensForParser(sourceCode, config, &cache).array;

    RollbackAllocator rba;
    auto m = parseModule(tokens, srcFile, &rba);
    auto visitor = new TraitsVisitor(destFile);
    visitor.visit(m);
    visitor.dump();
    delete visitor;
}

// Modify a path under oldBase to a new path with the same subpath under newBase.
// E.g.: `/foo/bar`.rebasePath(`/foo`, `/quux`) == `/quux/bar`
string rebasePath(string path, string oldBase, string newBase)
{
    import std.path : absolutePath, buildPath, relativePath;
    return buildPath(newBase, path.absolutePath.relativePath(oldBase.absolutePath));
}

void main(string[] args)
{
    import std.file;
    import std.getopt;
    import std.path;

    string inputDir, outputDir;
    string[] ignoredFiles;

    auto helpInfo = getopt(args, config.required,
            "inputdir|i", "Folder to start the recursive search for unittest blocks (can be a single file)", &inputDir,
            "outputdir|o", "Alternative folder to use as output (can be a single file)", &outputDir,
            "ignore", "List of files to exclude (partial matching is supported)", &ignoredFiles);

    if (helpInfo.helpWanted)
    {
        return defaultGetoptPrinter(`extract_dmd
Tries to lower EqualExpression in AssertExpressions of Unittest blocks to commented writeln calls.
`, helpInfo.options);
    }

    inputDir = inputDir.asNormalizedPath.array;

    DirEntry[] files;

    // inputDir as default output directory
    if (!outputDir.length)
        outputDir = inputDir;

    if (inputDir.isFile)
    {
        files = [DirEntry(inputDir)];
        inputDir = "";
        outputDir.dirName.mkdirRecurse;
    }
    else
    {
        files = dirEntries(inputDir, SpanMode.depth).filter!(
                a => a.name.endsWith(".d") && !a.name.canFind(".git")).array;
        outputDir.mkdirRecurse;
    }

    foreach (file; files)
    {
        if (!ignoredFiles.any!(x => file.name.canFind(x)))
        {
            // single files
            if (inputDir.length == 0)
                parseFile(file.name, outputDir);
            else
                parseFile(file.name, file.name.rebasePath(inputDir, outputDir));
        }
    }
}

static string AutoConstructor(fields ...)()
{
    import std.meta: staticMap;
    import std.traits: fullyQualifiedName;
    import std.string: join;

    enum fqns = staticMap!(fullyQualifiedName, fields);
    auto fields_str = "std.meta.AliasSeq!(" ~ [fqns].join(", ") ~ ")";

    return "
        static import std.meta;
        this(typeof(" ~ fields_str ~ ") args)
        {
            " ~ fields_str ~ " = args;
        }
    ";
}
