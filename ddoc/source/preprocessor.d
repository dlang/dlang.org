#!/usr/bin/env rdmd
/**
A wrapper around DDoc to allow custom extensions

Copyright: D Language Foundation 2018

License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).

Example usage:

---
./ddoc --compiler=<path-to-dmd> --output=out.html myfile.dd
---

Author: Sebastian Wilzbach
*/
import std.algorithm, std.array, std.ascii, std.conv, std.file, std.format, std.functional,
        std.meta, std.path, std.range, std.string, std.typecons;
import std.stdio;

import dmd.cli;

struct Config
{
    string dmdBinPath = "dmd";
    string outputFile;
    string cwd = __FILE_FULL_PATH__.dirName.dirName.dirName;
}
Config config;

version(IsExecutable)
int main(string[] rootArgs)
{
    import assert_writeln_magic;
    import std.getopt;
    auto helpInformation = getopt(
        rootArgs, std.getopt.config.passThrough,
        std.getopt.config.required,
        "compiler", "Compiler to use", &config.dmdBinPath,
    );
    if (helpInformation.helpWanted)
    {
`DDoc wrapper
All unknown options are passed to the compiler.
./ddoc <file>...
`.defaultGetoptPrinter(helpInformation.options);
        return 1;
    }
    auto args = rootArgs[1 .. $];
    auto pos = args.countUntil!(a => a.endsWith(".dd", ".d") > 0);
    assert(pos >= 0, "An input file (.d or .dd) must be provided");
    auto inputFile = args[pos];
    auto text = inputFile.readText;

    // for now only non-package modules are supported
    if (!inputFile.endsWith("index.d"))
        // replace only works with 2.078.1, see: https://github.com/dlang/phobos/pull/6017
        args = args[0..pos].chain("-".only, args[pos..$].dropOne).array;

    // transform and extend the ddoc page
    text = genGrammar(text);
    text = genHeader(text);
    text = genChangelogVersion(inputFile, text);
    text = genSwitches(text);
    text = fixDdocBugs(inputFile, text);

    // Phobos index.d should have been named index.dd
    if (inputFile.endsWith(".d") && !inputFile.endsWith("index.d"))
        text = assertWritelnModule(inputFile, text);

    string[string] macros;
    macros["SRC_FILENAME"] = "%s\n".format(inputFile.buildNormalizedPath);
    return compile(text, args, inputFile, macros);
}

auto createTmpDir()
{
    import std.uuid : randomUUID;
    auto dir = tempDir.buildPath("ddoc_preprocessor_" ~ randomUUID.toString.replace("-", ""));
    mkdir(dir);
    return dir;
}

auto compile(R)(R buffer, string[] arguments, string inputFile, string[string] macros = null)
{
    import core.time : usecs;
    import core.thread : Thread;
    import std.process : execute;
    auto args = [config.dmdBinPath] ~ arguments;

    // Note: ideally we could pass in files directly on stdin.
    // However, for package.d files, we need to imitate package directory layout to avoid conflicts
    auto tmpDir = createTmpDir;
    auto inputTmpFile = tmpDir.buildPath(inputFile);
    inputTmpFile.dirName.mkdirRecurse;
    std.file.write(inputTmpFile, buffer);
    args = args.replace("-", inputTmpFile);
    scope(exit) tmpDir.rmdirRecurse;

    if (macros !is null)
    {
        auto macroString = macros.byPair.map!(a => "%s=%s".format(a[0], a[1])).join("\n");
        auto macroFile = tmpDir.buildPath("macros.ddoc");
        std.file.write(macroFile, macroString);
        args ~= macroFile;
    }

    foreach (arg; ["-c", "-o-"])
    {
        if (!args.canFind(arg))
            args ~= arg;
    }

    auto ret = execute(args);
    if (ret.status != 0)
    {
        stderr.writeln(
            "\n------------- File content -------------\n",
            buffer,
            "\n------------ Compiler output -----------\n",
            ret.output,
            "\n----------------------------------------\n",
        );
    }
    return ret.status;
}

// replaces the content of a DDoc macro call
auto updateDdocTag(string fileText, string ddocKey, string newContent)
{
    auto pos = fileText.representation.countUntil(ddocKey);
    if (pos < 0)
        return fileText;

    newContent ~= ")";

    const ddocStartLength = ddocKey.representation.until('(', No.openRight).count;
    auto len = fileText[pos .. $].representation.drop(ddocStartLength).untilClosingParentheses.walkLength;
    return fileText.replace(fileText[pos .. pos + len + ddocStartLength + 1], newContent);
}

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

// parse the ddoc file for H2 and H3 items
// H3 items are listed as subitems
auto parseToc(string text)
{
    alias TocEntry = Tuple!(string, "id", string, "name");
    alias TocTopEntry = Tuple!(TocEntry, "main", TocEntry[], "children");
    TocTopEntry[] toc;

    bool isH2 = true;
    void append(string id, string name)
    {
        auto entry = TocEntry(id, name);
        if (isH2)
        {
            toc ~= TocTopEntry(entry, null);
        }
        else
        {
            assert(toc.length > 0, "TOC generation error: $(H2) needs to come before $(H3)");
            toc.back.children ~= entry;
        }
    }
    while (!text.empty)
    {
        enum needles = AliasSeq!("$(H2 ", "$(SECTION2 ", "$(H3", "$(SECTION3");
        auto res = text.find(needles);
        if (res[0].empty)
            break;

        isH2 = res[1] <= 2;
        text = res[0].drop(needles.only[res[1] - 1].length);
        text.skipOver!isWhite;

        enum gname = "$(GNAME ";
        enum lNameNeedles = AliasSeq!("$(LNAME2", "$(LEGACY_LNAME2");
        if (text.startsWith(gname))
        {
            auto name = text.drop(gname.length).untilClosingParentheses.to!string.strip;
            append(name, name);
        }
        else if (auto idx = text.startsWith(lNameNeedles))
        {
            auto arr = text.drop(lNameNeedles.only[idx - 1].length).splitter(",");
            if (idx == 2)
                arr.popFront;
            append(arr.front.strip, arr.dropOne.joiner(",").untilClosingParentheses.to!string.strip);
        }
    }
    return toc;
}

// Ddoc splits arguments by commas
auto escapeDdoc(string s)
{
    return s.replace(",", "$(COMMA)");
}

// generated a HEADERNAV_TOC Ddoc macro with the parsed H2/H3 entries
auto genHeader(string fileText)
{
    enum ddocKey = "$(HEADERNAV_TOC";
    auto newContent = ddocKey ~ "\n";
    enum indent = "    ";
    if (fileText.canFind(ddocKey))
    {
        foreach (entry; fileText.parseToc)
        {
            if (entry.children)
            {
                newContent ~= "%s$(HEADERNAV_SUBITEMS %s, %s,\n".format(indent, entry.main.id, entry.main.name.escapeDdoc);
                foreach (child; entry.children)
                    newContent ~= "%s$(HEADERNAV_ITEM %s, %s)\n".format(indent.repeat(2).joiner, child.id, child.name.escapeDdoc);
                newContent ~= indent;
                newContent ~= ")\n";
            }
            else
            {
                newContent ~= "%s$(HEADERNAV_ITEM %s, %s)\n".format(indent, entry.main.id, entry.main.name.escapeDdoc);
            }
        }
    }
    return updateDdocTag(fileText, ddocKey, newContent);
}

// parse the menu from the Ddoc file
auto specTocEntries()
{
    alias Entry = Tuple!(string, "name", string, "title", string, "fileName");
    Entry[] entries;

    immutable specDir = config.cwd.buildNormalizedPath("spec");
    immutable mainFile = specDir.buildPath("./spec.ddoc");

    auto specText = mainFile.readText;
    if (!specText.findSkip("SUBMENU2"))
        writeln("Menu file has an invalid format.");
    foreach (line; specText.splitter("\n"))
    {
        enum ddocEntryStart = "$(ROOT_DIR)spec/";
        if (line.find!(not!isWhite).startsWith(ddocEntryStart))
        {
            auto ps = line.splitter(ddocEntryStart).dropOne.front.splitter(",");
            auto name = ps.front.stripExtension.withExtension(".dd").to!string;
            auto fileName = specDir.buildPath(name);
            auto title = ps.dropOne.front.idup.strip;
            entries ~= Entry(name, title, fileName);
        }
    }
    return entries;
}

// Automatically generate spec/grammar
auto genGrammar(string fileText)
{
    import std.uni : toLower;

    enum ddocKey = "$(GRAMMAR_SUMMARY";
    auto newContent = ddocKey ~ "\n";

    if (fileText.canFind(ddocKey))
    {
        foreach (i, entry; specTocEntries)
        {
            if (entry.fileName.endsWith("grammar.dd", "lex.dd", "simd.dd"))
                continue;

            enum grammarKey = "$(GRAMMAR";
            auto text = entry.fileName.readText.find(grammarKey);
            if (text.length)
                newContent ~= "$(H2 $(LNAME2 %s, %s))\n".format(entry.title.toLower, entry.title);
            for (; text.length; text = text[ grammarKey.length .. $].find(grammarKey))
            {
                newContent ~= grammarKey;
                newContent ~= text.drop(grammarKey.length).untilClosingParentheses.to!string;
                newContent ~= ")\n";
            }
        }
        return updateDdocTag(fileText, ddocKey, newContent);
    }
    return fileText;
}

// Automatically generate a versions overview
auto genChangelogVersion(string fileName, string fileText)
{
    import std.regex;
    static re = regex(`^[0-9]\.[0-9][0-9][0-9](\.[0-9])?(_pre)?\.dd$`);
    if (fileName.dirName.baseName == "changelog" || fileName.endsWith("chm-nav.dd"))
    {
        string macros = "\nCHANGELOG_VERSIONS=";
        macros ~= "$(CHANGELOG_VERSION_NIGHTLY)\n";
        auto changelogFiles = dirEntries(fileName.dirName, SpanMode.depth).filter!(a => !a.name.baseName.matchFirst(re).empty).array;
        changelogFiles.sort;
        foreach (file; changelogFiles.retro)
        {
            auto arr = file.readText.findSplitAfter("$(VERSION ")[1].until!(a => a.among('\n', '=')).array;
            auto date = arr.retro.findSplitAfter(",")[1].retro;
            auto ver = file.name.baseName.stripExtension.until("_pre");
            macros ~= "$(CHANGELOG_VERSION%s %s, %s)\n".format(file.name.endsWith("_pre.dd") ? "_PRE" : "", ver, date);
        }

        // inject the changelog footer
        auto fileBaseName = fileName.baseName;
        auto r = changelogFiles.chain("pending.dd".only).enumerate.find!(a => a.value.baseName == fileBaseName);
        if (r.length != 0)
        {
            auto el = r.front;
            macros ~= "\nCHANGELOG_NAV_INJECT=";
            auto versions = changelogFiles.map!(a => a.baseName.until(".dd"));
            auto hasPrerelease = versions[$ - 1].canFind("_pre");
            // mapping for the first and last page is different
            if (el.index == 0)
            {
                macros ~="\n$(CHANGELOG_NAV_FIRST %s)".format(versions[1]);
            }
            else if (
                    // latest version + nightlies (pending.dd)
                    el.index >= versions.length ||
                    // prerelease pages
                    el.index == versions.length - 1 && hasPrerelease)
            {
                macros ~="\n$(CHANGELOG_NAV_LAST %s)".format(versions.retro.find!(v => !v.canFind("_pre", "pending")).front);
            }
            else if (el.index == versions.length - 1 && !hasPrerelease)
            {
                macros ~="\n$(CHANGELOG_NAV_LAST %s)".format(versions[$ - 2]);
            }
            else
            {
                const prevVersion = versions[el.index - 1].to!string;
                auto nextVersion = versions[el.index + 1].to!string;
                // the next version is the beta release
                if (el.index == versions.length - 2 && hasPrerelease)
                    nextVersion = std.array.replace(nextVersion, "_pre", "");

                macros ~="\n$(CHANGELOG_NAV %s, %s)".format(prevVersion, nextVersion);
            }
            macros ~= "\n_=";
        }
        fileText ~= macros;
    }
    return fileText;
}

// generate CLI documentation
auto genSwitches(string fileText)
{
    enum ddocKey = "$(CLI_SWITCHES";
    auto content = ddocKey ~ "\n";

    bool[string] seen;

    foreach (option; Usage.options)
    {
        string flag = option.flag;
        string helpText = option.helpText;
        if (!option.ddocText.empty)
            helpText = option.ddocText;

        // capitalize the first letter
        helpText = helpText.capitalize.to!string;

        highlightSpecialWords(flag, helpText);
        auto flagEndPos = flag.representation.countUntil("=", "$(", "<");
        string switchName;

        string swNameMacro = "SWNAME";
        // flags links should be unique
        auto swKey = flag[0 .. flagEndPos < 0 ? $ : flagEndPos];
        if (auto v = swKey in seen)
            swNameMacro = "B";
        seen[swKey] = 1;

        if (flagEndPos < 0)
            switchName = "$(%s -%s)".format(swNameMacro, flag);
        else
            switchName = "$(%s -%s)%s".format(swNameMacro, flag[0..flagEndPos], flag[flagEndPos..$].escapeDdoc);

        auto currentFlag = "$(SWITCH %s,\n
            %s
        )".format(switchName, helpText);

        with(TargetOS)
        switch(option.os)
        {
            case Windows:
                currentFlag = text("$(WINDOWS ", currentFlag, ")");
                break;
            case linux:
            case OSX:
            case OpenBSD:
            case FreeBSD:
            case Solaris:
            case DragonFlyBSD:
                currentFlag = text("$(UNIX ", currentFlag, ")");
                break;
            case all:
            default:
                break;
        }
        content ~= currentFlag;
    }
    return updateDdocTag(fileText, ddocKey, content);
}

auto italic(string w)
{
    return "$(I %s )".format(w);
}


// capitalize the first letter
auto capitalize(string w)
{
    import std.range, std.uni;
    return w.take(1).asUpperCase.chain(w.dropOne);
}

private void highlightSpecialWords(ref string flag, ref string helpText)
{
    if (flag.canFind("<", "[") && flag.canFind(">", "]"))
    {
        string specialWord;

        // detect special words in <...> and highlight them
        static foreach (t; [["<", ">"], ["[", "]"]])
        {
            if (flag.canFind(t[0]))
            {
                specialWord = flag.findSplit(t[0])[2].until(t[1]).to!string;
                // keep []
                auto replaceWord = t[0] == "<" ? t[0] ~ specialWord ~ t[1] : specialWord;
                flag = flag.replace(replaceWord, specialWord.italic);
            }
        }

        // highlight individual words in the description
        helpText = helpText
            .splitter(" ")
            .map!((w){
                auto wPlain = w.filter!(c => !c.among('<', '>', '`', '\'')).to!string;
                return wPlain == specialWord ? wPlain.italic: w;
            })
            .joiner(" ")
            .to!string;
    }
}

// Fix ddoc bugs
string fixDdocBugs(string inputFile, string text)
{

    // __FILE__ changes on every build
    // can be removed once https://github.com/dlang/phobos/pull/6321 is merged and part of a release
    if (inputFile.endsWith("exception.d"))
    {
        text = text.replace(`typeof(new E("", __FILE__, __LINE__)`, `typeof(new E("", string.init, size_t.init)`);
        text = text.replace(`typeof(new E(__FILE__, __LINE__)`, `typeof(new E(string.init, size_t.init)`);
    }
    return text;
}
