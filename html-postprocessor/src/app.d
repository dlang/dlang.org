import hyphenate;

/// global immutable instance initialized for en-US
static immutable Hyphenator h;
shared static this()
{
    h = cast(immutable) Hyphenator(import("hyphen.tex"));
}

/// hyphenate a HTML file
void hyphenateHTML(string path)
{
    import html : createDocument, Node, NodeWrapper;
    import std.algorithm : canFind, splitter;
    import std.array : appender, replace;
    import std.file : readText;
    import std.regex : ctRegex, replaceAllInto;

    auto doc = createDocument(path.readText);

    void visit(NodeWrapper!Node node, bool hyphenate)
    {
        enum wordsRE = ctRegex!("[\\w\&shy;]+", "g");
        if (node.isTextNode)
        {
            if (hyphenate)
            {
                auto app = appender!string;
                replaceAllInto!((m, app) {
                    auto word = m.hit.replace("\&shy;", "");
                    h.hyphenate(word, "\&shy;", s => app.put(s));
                })(app, node.text, wordsRE);
                node.text = app.data;
            }
        }
        else
        {
            if (node.tag == "script" || node.tag == "style")
                return;

            if (node.attr("class").splitter.canFind("hyphenate"))
                hyphenate = true;
            else if (node.attr("class").splitter.canFind("donthyphenate"))
                hyphenate = false;

            foreach (child; node.children)
                visit(child, hyphenate);
        }
    }

    visit(doc.root, false);

    import std.stdio : File;

    with (File(path, "w"))
    {
        auto orng = lockingTextWriter;
        doc.root.innerHTML(orng);
    }
}

void main(string[] args)
{
    import std.parallelism : parallel;
    import std.file : readText;

    foreach (path; args[1 .. $].parallel)
        hyphenateHTML(path);
}
