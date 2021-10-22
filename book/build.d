module book.build;
import std.string;
import std.process;
import std.algorithm;
import std.file;
import std.stdio;
import std.exception;
import std.path;
void compileToPath(string compileThis, string outputPath, bool loud = false)
{
    import std.compiler;
    import core.stdc.stdlib;
    string[string] contextMacros;
    contextMacros["DVER"] = format!"%u.%03u"(version_major, version_minor);
    if(outputPath.indexOf("cozum") == -1)
    {
        //We need to build a little .ddoc file to set the right predefined build macros - these are context dependant.
        
        const cozumHtml = outputPath.baseName.replace(".html", ".cozum.html");
        contextMacros["COZUM_HTML"] = cozumHtml;
        //exit(0);
    }
    auto macroOut = File("contextMacros.ddoc", "w");
    
    foreach(key, value; contextMacros)
    {
        macroOut.writefln!"%s = %s"(key, value);
    }
    macroOut.flush();
    const compileString = format!"dmd -revert=markdown -D  contextMacros.ddoc macros.ddoc html.ddoc dlang.org.ddoc doc.ddoc aliBook.ddoc %s -Df%s "(compileThis, outputPath);
    if(loud)
        writefln!"%s:%s |> %s"(compileThis, outputPath, compileString);
    const res = executeShell(compileString);
    
    if(res.status != 0) {
        write(res.output);
        
        exit(0);
    }
}
int main(string[] args)
{
    import std.typecons;
    import std.path;
    import std.parallelism;
    import std.conv : to;
    const jobs = args.length == 2 ? args[1].to!ubyte : 1;
    const outDir = "../web/book";
    writeln("Building the book at ", outDir);

    enforce(executeShell("which dmd").output != "", "dmd doesn't seem to be present");
    if(outDir.exists) {
        executeShell("rm -rf " ~ outDir);
    }
    dirEntries("d.en", "*.d", SpanMode.shallow)
        .map!(dFile => tuple(dFile.name, buildPath(outDir, baseName(dFile).setExtension("html"))))
        //.parallel(jobs)
        .each!(elem => compileToPath(elem.tupleof));
    dirEntries("d.en", "*.png", SpanMode.shallow)
        .each!(p => copy(p, buildPath(outDir, baseName(p).setExtension("png"))));
    return 0;
}