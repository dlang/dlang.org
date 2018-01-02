#!/usr/bin/env rdmd
/*
 * Footer generator for the specification pages.
 * This script can be used to update the nav footers.
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
import std.algorithm, std.array, std.ascii, std.conv, std.file, std.functional,
        std.meta, std.path, std.range, std.string, std.typecons;
import std.stdio : File, writeln, writefln;

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

auto parseToc(string text)
{
    alias TocEntry = Tuple!(string, "id", string, "name");
    TocEntry[] toc;
    while (!text.empty)
    {
        enum needles = AliasSeq!("$(H2 ", "$(SECTION2 ");
        auto res = text.find(needles);
        if (res[0].empty)
            break;

        text = res[0].drop(needles.only[res[1] - 1].length);
        text.skipOver!isWhite;

        enum gname = "$(GNAME ";
        enum lNameNeedles = AliasSeq!("$(LNAME2", "$(LEGACY_LNAME2");
        if (text.startsWith(gname))
        {
            auto name = text.drop(gname.length).untilClosingParentheses.to!string.strip;
            toc ~= TocEntry(name, name);
        }
        else if (auto idx = text.startsWith(lNameNeedles))
        {
            auto arr = text.drop(lNameNeedles.only[idx - 1].length).splitter(",");
            toc ~= TocEntry(arr.front.strip, arr.dropOne.front.untilClosingParentheses.to!string.strip);
        }
    }
    return toc;
}

auto genHeader(string fileText)
{
    enum ddocKey = "$(SPEC_HEADERNAV";
    auto newContent = ddocKey ~ " foo)";
    parseToc(fileText).writeln;
    return updateDdocTag(fileText, ddocKey, newContent);
}

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

auto updateDdocTag(string fileText, string ddocKey, string newContent)
{
    auto pos = fileText.representation.countUntil(ddocKey);
    if (pos < 0)
        return fileText;
    const ddocStartLength = ddocKey.representation.until('(', No.openRight).count;
    auto len = fileText[pos .. $].representation.drop(ddocStartLength).untilClosingParentheses.walkLength;
    return fileText.replace(fileText[pos .. pos + len + ddocStartLength + 1], newContent);
}

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
        writefln("Processing %s", entry.name);
        auto fileName = specDir.buildPath(entry.name);
        auto text = fileName.readText;
        text = genHeader(text);
        text = genFooter(text, i, entries);
        fileName.write(text);
    }
}
