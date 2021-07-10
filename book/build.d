module book.build;
import std;
void compileToPath(string compileThis, string outputPath, bool loud = false)
{
    import core.stdc.stdlib;
    if(outputPath.indexOf("cozum") == -1)
    {
        if(loud)
            writeln(outputPath.replace(".html", ".cozum.html"));
        //exit(0);
    }
    
    const compileString = format!"dmd -revert=markdown -D  macros.ddoc html.ddoc dlang.org.ddoc doc.ddoc aliBook.ddoc %s -Df%s "(compileThis, outputPath);
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
    const jobs = args.length == 2 ? args[1].to!ubyte : 1;
    const outDir = "../web/book";
    writeln("Building the book at ", outDir);
    //scope(failure) return 1;

    enforce(executeShell("which dmd").output != "", "dmd doesn't seem to be present");
    if(outDir.exists) {
        executeShell("rm -rf " ~ outDir);
    }
    auto rng = dirEntries("d.en", "*.d", SpanMode.shallow)
        .map!(dFile => tuple(dFile.name, buildPath(outDir, baseName(dFile).setExtension("html"))))
        .parallel(jobs)
        .each!(elem => compileToPath(elem.tupleof));
    dirEntries("d.en", "*.png", SpanMode.shallow)
        .each!(p => copy(p, buildPath(outDir, baseName(p).setExtension("png"))));
    return 0;
}