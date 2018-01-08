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
import std.stdio;

struct Config
{
    string dmdBinPath = "dmd";
    string outputFile;
}
Config config;

int main(string[] args)
{
    import std.getopt;
    auto helpInformation = getopt(
        args,
        "compiler", "Compiler to use", &config.dmdBinPath,
        "o|output", "Output file", &config.outputFile,
    );

    assert(config.outputFile, "An output file is required.");
    assert(args.length > 1, "An input file is required.");

    if (helpInformation.helpWanted)
    {
`DDoc wrapper
./ddoc <file>...
`.defaultGetoptPrinter(helpInformation.options);
        return 1;
    }

    import std.file : readText;
    auto text = args[$ - 1].readText;
    return compile(text, args[1 .. $ - 1]);
}

auto compile(R)(R buffer, string[] arguments)
{
    import std.process : pipeProcess, Redirect, wait;
    auto args = [config.dmdBinPath, "-c", "-Df"~config.outputFile, "-o-"] ~ arguments;
    args ~= "-";
    auto pipes = pipeProcess(args, Redirect.stdin);
    pipes.stdin.write(buffer);
    pipes.stdin.close;
    return wait(pipes.pid);
}
