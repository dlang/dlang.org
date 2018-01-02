#!/usr/bin/env rdmd
/**
Checks the validity of examples in the D Language Specification.

Copyright: D Language Foundation 2017.

License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).

Example usage:

---
./dspec_tester
---

Author: Sebastian Wilzbach
*/

import std.algorithm;
import std.stdio;
import std.range;
import std.regex;

struct Config {
    string dmdBinPath = "dmd";
    bool printLineNumbers; // whether line numbers should be shown on errors
}
Config config;

// a range until the next ')', nested () are ignored
auto untilClosingParentheses(R)(R rs)
{
    struct State
    {
        size_t rightParensCount = 1;
        bool inCodeBlock;
        size_t dashCount;
    }
    return rs.cumulativeFold!((state, r){
        if (r == '-')
        {
            state.dashCount++;
        }
        else
        {
            if (state.dashCount >= 3)
                state.inCodeBlock = !state.inCodeBlock;

            state.dashCount = 0;
        }
        switch(r)
        {
            case '-':
                break;
            case '(':
                if (!state.inCodeBlock)
                    state.rightParensCount++;
                break;
            case ')':
                if (!state.inCodeBlock)
                    state.rightParensCount--;
                break;
            default:
        }
        return state;
    })(State()).zip(rs).until!(e => e[0].rightParensCount == 0).map!(e => e[1]);
}

unittest
{
    import std.algorithm.comparison : equal;
    assert("aa $(foo $(bar)foobar)".untilClosingParentheses.equal("aa $(foo $(bar)foobar)"));
}

auto findDdocMacro(R)(R text, string ddocKey)
{
    return text.splitter(ddocKey).map!untilClosingParentheses.dropOne;
}

auto ddocMacroToCode(R)(R text)
{
    import std.ascii : newline;
    import std.conv : to;
    return text.find("---")
               .findSplitAfter(newline)[1]
               .findSplitBefore("---")[0]
               .to!string;
}

int main(string[] args)
{
    import std.file, std.getopt, std.path;
    import std.parallelism : parallel;
    import std.process : environment;

    auto specDir = __FILE_FULL_PATH__.dirName.buildPath("spec");
    config.dmdBinPath = environment.get("DMD", "dmd");
    bool hasFailed;

    auto helpInformation = getopt(
        args,
        "l|lines", "Show the line numbers on errors", &config.printLineNumbers,
    );

    if (helpInformation.helpWanted)
    {
`D Specification tester
./dspec_tester
`.defaultGetoptPrinter(helpInformation.options);
        return 1;
    }

    // Find all examples in the specification
    foreach (file; specDir.dirEntries("*.dd", SpanMode.depth).parallel(1))
    {
        import std.uni : isWhite;
        auto allTests =
            file
            .readText
            .findDdocMacro("$(SPEC_RUNNABLE_EXAMPLE")
            .map!ddocMacroToCode
            .map!compileAndCheck;

        if (!allTests.empty)
        {
            writefln("%s: %d examples found", file.baseName, allTests.walkLength);
            if (allTests.any!(a => a != 0))
                hasFailed = true;
        }
    }
    return hasFailed;
}

/**
Executes source code with a D compiler (compile-only)

Params:
    buffer = example to check

Returns: the exit code of the compiler invocation.
*/
auto compileAndCheck(R)(R buffer)
{
    import std.process;
    import std.uni : isWhite;

    auto pipes = pipeProcess([config.dmdBinPath, "-c", "-o-", "-"],
            Redirect.stdin | Redirect.stdout | Redirect.stderr);

    static mainRegex = regex(`(void|int)\s+main`);
    const hasMain = !buffer.matchFirst(mainRegex).empty;

    // if it's not a standalone
    if (!buffer.find!(a => !a.isWhite).startsWith("module"))
    {
        buffer = "import std.stdio;\n" ~ buffer; // used too often

        if (!hasMain)
            buffer = "void main() {\n" ~ buffer ~ "\n}";
    }
    pipes.stdin.write(buffer);
    pipes.stdin.close;
    auto ret = wait(pipes.pid);
    if (ret != 0)
    {
        stderr.writeln("--- ");
        int lineNumber = 1;
        buffer
            .splitter("\n")
            .each!((a) {
                const indent = hasMain ? "    " : "";
                if (config.printLineNumbers)
                    stderr.writefln("%3d: %s%s", lineNumber++, indent, a);
                else
                    stderr.writefln("%s%s", indent, a);
        });

        stderr.writeln("---");
        pipes.stderr.byLine.each!(e => stderr.writeln(e));
    }
    return ret;
}
