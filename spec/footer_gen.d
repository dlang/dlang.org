#!/usr/bin/env rdmd
/*
 * TOC + footer generator for the specification pages.
 * This script can be used to update the TOC index and navigation footers.
 *
 * Copyright (C) 2017-2018 by D Language Foundation
 *
 * Author: Sebastian Wilzbach
 *
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE_1_0.txt or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
*/
// Written in the D programming language.
import std.algorithm, std.array, std.ascii, std.conv, std.file, std.functional,
        std.meta, std.path, std.range, std.string, std.typecons;
import std.stdio : File, writeln, writefln;

// a range until the next ')', nested () are ignored
auto untilClosingParentheses(R)(R rs)
{
    return rs.cumulativeFold!((count, r){
        switch(r)
        {
            case '(':
                count++;
                break;
            case ')':
                count--;
                break;
            default:
        }
        return count;
    })(1).zip(rs).until!(e => e[0] == 0).map!(e => e[1]);
}

unittest
{
    import std.algorithm.comparison : equal;
    assert("aa $(foo $(bar)foobar)".untilClosingParentheses.equal("aa $(foo $(bar)foobar)"));
    assert("$(FOO a, b, $(ARGS e, f)))".untilClosingParentheses.equal("$(FOO a, b, $(ARGS e, f))"));
}

// Adds pagination to the spec pages
// The default Ddoc macro is `$(SPEC_SUBNAV_PREV_NEXT)`
// The first and last page have special ddoc macros (`$(SPEC_SUBNAV_NEXT)`, `$(SPEC_SUBNAV_PREV)`)
auto genFooter(Entries)(string fileText, size_t i, Entries entries)
{
    enum ddocKey = "$(SPEC_SUBNAV_";

    // build the prev|next Ddoc string
    string navString = ddocKey;
    if (i == 0)
        navString ~= text("NEXT ", entries[i + 1].name.stripExtension, ", ", entries[i + 1].title);
    else if (i < entries.length - 1)
        navString ~= text("PREV_NEXT ", entries[i - 1].name.stripExtension, ", ", entries[i - 1].title, ", ",
            entries[i + 1].name.stripExtension, ", ", entries[i + 1].title);
    else
        navString ~= text("PREV ", entries[i - 1].name.stripExtension, ", ", entries[i - 1].title);

    navString ~= ")";
    return updateDdocTag(fileText, ddocKey, navString);
}

// replaces the content of a DDoc macro call
auto updateDdocTag(string fileText, string ddocKey, string newContent)
{
    auto pos = fileText.representation.countUntil(ddocKey);
    if (pos < 0)
        return fileText;
    const ddocStartLength = ddocKey.representation.until('(', No.openRight).count;
    auto len = fileText[pos .. $].representation.drop(ddocStartLength).untilClosingParentheses.walkLength;
    return fileText.replace(fileText[pos .. pos + len + ddocStartLength + 1], newContent);
}

version(unittest) {} else
void main()
{
    auto specDir = __FILE_FULL_PATH__.dirName.buildNormalizedPath;
    auto mainFile = specDir.buildPath("./spec.ddoc");

    alias Entry = Tuple!(string, "name", string, "title");
    Entry[] entries;

    // parse the menu from the Ddoc file
    auto specText = mainFile.readText;
    if (!specText.findSkip("SUBMENU2"))
        writeln("Menu file has an invalid format.");
    foreach (line; specText.splitter("\n"))
    {
        enum ddocEntryStart = "$(ROOT_DIR)spec/";
        if (line.find!(not!isWhite).startsWith(ddocEntryStart))
        {
            auto ps = line.splitter(ddocEntryStart).dropOne.front.splitter(",");
            entries ~= Entry(ps.front.stripExtension.withExtension(".dd").to!string,
                             ps.dropOne.front.idup.strip);
        }
    }

    foreach (i, entry; entries)
    {
        auto fileName = specDir.buildPath(entry.name);
        auto text = fileName.readText;
        auto newText = genFooter(text, i, entries);
        if (text != newText)
        {
            writefln("Updating %s", entry.name);
            fileName.write(newText);
        }
    }
}
