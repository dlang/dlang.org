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
shared Config config;

// a range until the next ')', nested () are ignored
auto untilClosingParentheses(R)(R rs)
{
    struct State
    {
        uint rightParensCount = 1;
        bool inCodeBlock;
        uint dashCount;
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
    import std.typecons : Tuple;

    auto specDir = __FILE_FULL_PATH__.dirName.dirName.buildPath("spec");
    bool hasFailed;

    config.dmdBinPath = environment.get("DMD", "dmd");
    auto helpInformation = getopt(
        args,
        "l|lines", "Show the line numbers on errors", cast(bool*) &config.printLineNumbers,
        "compiler", "D compiler to use", cast(string*) &config.dmdBinPath,
    );

    if (helpInformation.helpWanted)
    {
`D Specification tester
./dspec_tester
`.defaultGetoptPrinter(helpInformation.options);
        return 1;
    }

    // Find all examples in the specification
    alias findExamples = (file, ddocKey) => file
            .readText
            .findDdocMacro(ddocKey)
            .map!ddocMacroToCode;

    alias SpecType = Tuple!(string, "key", CompileConfig.TestMode, "mode");
    auto specTypes = [
        SpecType("$(SPEC_RUNNABLE_EXAMPLE_COMPILE", CompileConfig.TestMode.compile),
        SpecType("$(SPEC_RUNNABLE_EXAMPLE_RUN", CompileConfig.TestMode.run),
        SpecType("$(SPEC_RUNNABLE_EXAMPLE_FAIL", CompileConfig.TestMode.fail),
    ];
    foreach (file; specDir.dirEntries("*.dd", SpanMode.depth).parallel(1))
    {
        auto allTests = specTypes.map!(c => findExamples(file, c.key)
                                            .map!(e => compileAndCheck(e, CompileConfig(c.mode))))
                                 .joiner;
        if (!allTests.empty)
        {
            writefln("%s: %d examples found", file.baseName, allTests.walkLength);
            if (allTests.any!(a => a != 0))
                hasFailed = true;
        }
    }
    return hasFailed;
}

struct CompileConfig
{
    enum TestMode { run, compile, fail }
    TestMode mode;
    string[] args;
    string expectedStdout;
    string expectedStderr;
}

/**
Executes source code with a D compiler (compile-only)

Params:
    buffer = example to check

Returns: the exit code of the compiler invocation.
*/
auto compileAndCheck(R)(R buffer, CompileConfig config)
{
    import std.process;
    import std.uni : isWhite;

    string[] args = [.config.dmdBinPath];
    args ~= config.args;
    with (CompileConfig.TestMode)
    final switch (config.mode)
    {
        case run:
            args ~= ["-run"];
            break;
        case compile:
            args ~= ["-c", "-o-"];
            break;
        case fail:
            args ~= ["-c", "-o-"];
            break;
    }
    args ~= "-";

    auto pipes = pipeProcess(args, Redirect.all);

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
    if (config.mode == CompileConfig.TestMode.fail)
    {
        if (ret == 0)
        {
            stderr.writefln("Compilation should have failed for:\n%s", buffer);
            ret = 1;
        }
        else
        {
            ret = 0;
        }
    }
    else if (ret != 0)
    {
        stderr.writeln("---");
        int lineNumber = 1;
        buffer
            .splitter("\n")
            .each!((a) {
                const indent = hasMain ? "    " : "";
                if (.config.printLineNumbers)
                    stderr.writefln("%3d: %s%s", lineNumber++, indent, a);
                else
                    stderr.writefln("%s%s", indent, a);
        });

        stderr.writeln("---");
        pipes.stderr.byLine.each!(e => stderr.writeln(e));
    }
    // check stdout or stderr
    static foreach (stream; ["stdout", "stderr"])
    {{
        import std.ascii : toUpper;
        import std.conv : to;
        mixin("auto expected = config.expected" ~ stream.front.toUpper.to!string ~ stream.dropOne~ ";");
        if (expected)
        {
            mixin("auto stream = pipes." ~ stream ~ ";");
            auto obs = appender!string;
            stream.byChunk(4096).each!(c => obs.put(c));
            scope(failure) {
                stderr.writefln("Expected: %s", expected);
                stderr.writefln("Observed: %s", obs.data);
            }
            assert(obs.data == expected);
        }
    }}
    return ret;
}
