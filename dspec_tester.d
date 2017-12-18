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

int main(string[] args)
{
    import std.conv, std.file, std.getopt, std.path;
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
    auto r = regex(`SPEC_RUNNABLE_EXAMPLE\n\s*---+\n[^-]*---+\n\s*\)`, "s");
    foreach (file; specDir.dirEntries("*.dd", SpanMode.depth).parallel(1))
    {
        import std.ascii : newline;
        import std.uni : isWhite;
        auto allTests =
            file
            .readText
            .matchAll(r)
            .map!(a => a[0])
            .map!(a => a
                    .find("---")
                    .findSplitAfter(newline)[1]
                    .findSplitBefore("---")[0]
                    .to!string)
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
