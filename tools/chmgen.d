// D HTML to CHM converter/generator
// By Vladimir Panteleev <vladimir@thecybershadow.net> (2007-2015)
// Placed in the Public Domain
// Written in the D Programming Language, version 2

import std.algorithm;
import std.exception;
import std.file;
import std.getopt;
import std.range;
import std.stdio : File, stderr;
import std.string;
import std.regex;
import std.path;

// ********************************************************************

// List of files to completely exclude from parsing.
string[] excludes = [
    "404.html",
    "forum-template.html",
];

// List of broken links to ignore.
string[] brokenLinks = [
    "d-keyring.gpg",
    "dlangspec.mobi",
    "dlangspec.pdf",
    "library-prerelease/index.html",
];

// ********************************************************************

string docRoot = `.`;
string chmDir = "chm";
bool prerelease;
string target;

// ********************************************************************

struct KeyLink
{
    /// Anchor identifier (fragment part of URL)
    string anchor;

    /// Same as the addKeyword parameter.
    int confidence;

    /// Source files that the link was observed from.
    string[] sources;
}

/// Hashmap of keywords (for the CHM keyword tab);
/// for each keyword, a hashmap of pages it appears on.
/// Keys are: keywords[keyword][original url w/o anchor] = anchor/confidence
KeyLink[string][string] keywords;

/// List of all keywords, sorted alphabetically, case-insensitive
string[] keywordList;

/// Index of all seen anchors.
/// Key is the file name and fragment part.
/// Value is true if we saw a definition of the anchor,
/// false if we only saw a link to it (so far).
bool[string] sawAnchor;

/**
   Register an anchor.
   Params:
     keyword    = Some human-readable text associated with the anchor
                  (section title, link text)
     link       = The URL including the filename and any fragment part
     source     = The source file the link was observed from
     confidence = A number indicating the preference of using the given anchor text
                  (higher numbers take preference over lower ones)
     isAnchor   = true (default) if this is the definition of an anchor,
                  false if it is a link to it
*/
void addKeyword(string keyword, string link, string source, int confidence, bool isAnchor = true)
{
    keyword = keyword.strip();
    if (!keyword.length)
        return;
    link = link.strip();

    while (link.skipOver("./")) {}
    if (link.endsWith("/"))
        link ~= "index.html";

    if (prerelease && link.skipOver("phobos/"))
        link = "phobos-prerelease/" ~ link;

    string file = link.stripAnchor();
    string anchor = link.getAnchor();

    if (keyword !in keywords
     || file !in keywords[keyword])
        keywords[keyword][file] = KeyLink.init;

    auto pkeyLink = file in keywords[keyword];
    if (pkeyLink.confidence < confidence)
    {
        pkeyLink.anchor = anchor;
        pkeyLink.confidence = confidence;
    }
    pkeyLink.sources ~= source;

    if (anchor.length)
    {
        if (link !in sawAnchor)
            sawAnchor[link] = false;
        if (isAnchor)
            sawAnchor[link] = true;
    }
}

/// Information about a particular page.
struct Page
{
    /// Page title (as in HTML).
    string title;
}
/// Mapping of page file names to page information (title).
Page*[string] pages;

// ********************************************************************

void main(string[] args)
{
    bool onlyTags;

    getopt(args,
        "only-tags", &onlyTags,
        "root", &docRoot,
        "dir", &chmDir,
        "target", &target,
    );
    prerelease = target == "prerelease";

    bool chm = !onlyTags;

    if (chm)
    {
        if (exists(chmDir))
            rmdirRecurse(chmDir);
        mkdirRecurse(chmDir ~ `/files`);
    }

    string phobosDir = prerelease ? "/phobos-prerelease/" : "/phobos/";

    enforce(exists(docRoot ~ phobosDir ~ `index.html`),
        `Phobos documentation not present. Please place Phobos documentation HTML files into the "phobos" subdirectory.`);

    string[] files = chain(
        dirEntries(docRoot ~ `/`          , "*.html", SpanMode.shallow),
        dirEntries(docRoot ~ phobosDir    , "*.html", SpanMode.shallow),
        dirEntries(docRoot ~ `/spec/`     , "*.html", SpanMode.shallow),
        dirEntries(docRoot ~ `/changelog/`, "*.html", SpanMode.shallow),
    //  dirEntries(docRoot ~ `/js/`                 , SpanMode.shallow),
        dirEntries(docRoot ~ `/css/`                , SpanMode.shallow),
        dirEntries(docRoot ~ `/images/`   , "*.*"   , SpanMode.shallow),
        only(docRoot ~ `/favicon.ico`)
    ).array();

    foreach (filePath; files)
    {
        scope(failure) stderr.writeln("Error while processing file: ", filePath);

        auto page = new Page;
        auto fileName = filePath[docRoot.length+1 .. $].forwardSlashes();

        pages[fileName] = page;

        auto outPath = chmDir ~ `/files/` ~ fileName;
        if (chm)
            outPath.dirName().mkdirRecurse();

        if (fileName.endsWith(`.html`))
        {
            if (excludes.canFind(fileName))
                continue;

            stderr.writeln("Processing ", fileName);
            auto src = filePath.readText();

            // Find title

            foreach (m; src.match(re!`<title>(.*?) - D Programming Language</title>`))
                page.title = m.captures[1];

            // Add document CSS class

            src = src.replaceAll(re!`(<body id='.*?' class='.*?)('>)`, `$1 chm$2`);

            // Fix links

            enum attrs = `(?:(?:\w+=\"[^"]*\")?\s*)*`;

            src = src.replaceAll(re!(`(<a `~attrs~`href="\.\.?)"`), `$1/index.html"`);

            // Find anchors

            enum name = `(?:name|id)`;

            foreach (m; src.matchAll(re!(`<a `~attrs~name~`="(\.?[^"]*)"`~attrs~`>(.*?)</a>`)))
                addKeyword(m.captures[2].replaceAll(re!`<.*?>`, ``), fileName ~ "#" ~ m.captures[1], fileName, 5);

            foreach (m; src.matchAll(re!(`<a `~attrs~name~`="(\.?([^"]*?)(\.\d+)?)"`~attrs~`>`)))
                addKeyword(m.captures[2], fileName ~ "#" ~ m.captures[1], fileName, 1);

            foreach (m; src.matchAll(re!(`<div class="quickindex" id="(quickindex\.(.+?))"></div>`)))
                addKeyword(m.captures[2], fileName ~ "#" ~ m.captures[1], fileName, 1);

            foreach (m; src.matchAll(re!(`<a `~attrs~`href="([^"]*)"`~attrs~`>(.*?)</a>`)))
                if (!m.captures[1].isAbsoluteURL())
                    addKeyword(m.captures[2].replaceAll(re!`<.*?>`, ``), absoluteUrl(fileName, m.captures[1].strip()), fileName, 4, false);

            // Disable scripts

            src = src.replaceAll(re!`<script.*?</script>`, ``);
            src = src.replaceAll(re!`<script.*?\bsrc=.*?>`, ``);

            // Remove external stylesheets

            src = src.replaceAll(re!`<link rel="stylesheet" href="http.*?>`, ``);

            if (chm)
                std.file.write(outPath, src);
        }
        else
        {
            if (chm)
            {
                stderr.writeln("Copying ", fileName);
                copy(filePath, outPath);
            }
        }
    }

    foreach (keyword, urlList; keywords)
        keywordList ~= keyword;
    keywordList.multiSort!(q{icmp(a, b) < 0}, q{a < b});

    if (chm)
    {
        loadNavigation();
        lint();
        writeCHM();
    }

    writeTags();

    stderr.writeln("Done!");
}

// ************************************************************

class Nav
{
    string title, url;
    Nav[] children;
}

Nav nav;

void loadNavigation()
{
    stderr.writeln("Loading navigation");

    import std.json;
    auto text = ("chm-nav-" ~ target ~ ".json")
        .readText()
        .replace("\r", "")
        .replace("\n", "")
    //  .replaceAll(re!`/\*.*?\*/`, "")
        .replaceAll(re!`,\s*\]`, `]`)
    ;
    scope(failure) std.file.write("error.json", text);
    auto json = text.parseJSON();

    Nav[string] subNavs;

    foreach_reverse (node; json.array)
    {
        auto hook = node["hook"].str;
        auto root = node["root"].str;
        if (prerelease && root == "phobos/")
            root = "phobos-prerelease/";

        Nav parseNav(JSONValue json)
        {
            if (json.type == JSON_TYPE.ARRAY)
            {
                auto nodes = json.array;
                auto parsedNodes = nodes.map!parseNav.array().filter!`a`.array();
                if (!parsedNodes.length)
                {
                    if (/*warn*/true)
                        stderr.writeln("Warning: Empty navigation group");
                    return null;
                }

                auto root = parsedNodes[0];
                root.children = parsedNodes[1..$];
                return root;
            }
            else
            {
                auto obj = json.object;
                auto nav = new Nav;
                nav.title = obj["t"].str.strip();
                if ("a" in obj)
                {
                    auto a = obj["a"].str.strip();
                    if (prerelease && a == "phobos/index.html")
                        a = "phobos-prerelease/index.html";

                    auto url = absoluteUrl(root, a);
                    if (url.canFind(`://`))
                    {
                        stderr.writeln("Skipping external navigation item: " ~ url);
                        return null;
                    }
                    else
                    if (!exists(chmDir ~ `/files/` ~ url))
                    {
                        if (/*warn*/true)
                            stderr.writeln("Warning: Item in navigation does not exist: " ~ url);
                        else
                            stderr.writeln("Skipping non-existent navigation item: " ~ url);
                        //url = "http://dlang.org/" ~ url;
                        return null;
                    }
                    else
                        nav.url = `files\` ~ url.backSlashes();
                }
                auto psubNav = nav.title in subNavs;
                if (psubNav)
                {
                //  if (nav.title != psubNav.title)
                //      stderr.writefln("Warning: Sub-navigation title mismatch: %s / %s", nav.title, psubNav.title);
                //  if (nav.url != psubNav.url)
                //      stderr.writefln("Warning: Sub-navigation url mismatch: %s / %s", nav.url, psubNav.url);
                    nav.url = psubNav.url;
                    nav.children = psubNav.children;
                }
                return nav;
            }
        }

        auto nav = parseNav(node["nav"]);
        subNavs[hook] = nav;
    }

    .nav = subNavs[""];
}

// ************************************************************

void lint()
{
    // Unknown URLs (links to pages we did not see)
    {
        string[][string] unknownPages;
        foreach (keyword; keywordList)
            foreach (page, link; keywords[keyword])
                if (page !in pages)
                    unknownPages[page] = link.sources;
        foreach (url; unknownPages.keys.sort())
        {
            if (brokenLinks.canFind(url))
                continue;
            stderr.writeln("Warning: Unknown page: " ~ url);
            stderr.writefln("  (linked from %d pages e.g. %s)", unknownPages[url].length, unknownPages[url][0]);
        }
    }

    // Unknown anchors
    {
        foreach (url; sawAnchor.keys.sort())
            if (!sawAnchor[url])
                stderr.writeln("Warning: Link to unknown anchor: " ~ url);
    }

    // Pages not in navigation
    {
        bool[string] sawPage;

        void visit(Nav nav)
        {
            if (nav.url)
            {
                auto url = nav.url
                    [6..$] // strip "files/"
                    .forwardSlashes();
                sawPage[url] = true;
            }
            foreach (child; nav.children)
                visit(child);
        }

        visit(nav);

        foreach (url; pages.keys.sort())
            if (url.endsWith(".html") && url !in sawPage)
                stderr.writeln("Warning: Page not in navigation: " ~ url);
    }
}

// ************************************************************

void writeCHM()
{
    stderr.writeln("Writing project file");

    auto f = File(chmDir ~ `/d.hhp`, "wt");
    f.writeln(
`[OPTIONS]
Binary Index=No
Compatibility=1.1 or later
Compiled file=d.chm
Contents file=d.hhc
Default Window=main
Default topic=files\index.html
Display compile progress=No
Full-text search=Yes
Index file=d.hhk
Language=0x409 English (United States)
Title=D

[WINDOWS]
main="D Programming Language","d.hhc","d.hhk","files\index.html","files\index.html",,,,,0x63520,,0x380e,[0,0,800,570],0x918f0000,,,,,,0

[FILES]`);
    string[] htmlList;
    foreach (fileName, page; pages)
        if (fileName.endsWith(`.html`))
            htmlList ~= `files\` ~ fileName.backSlashes();
    htmlList.sort();
    foreach (s; htmlList)
        f.writeln(s);
    f.writeln(`
[INFOTYPES]`);
    f.close();

    // ************************************************************

    stderr.writeln("Writing TOC file");

    void dumpNav(Nav nav, int level=0)
    {
        if (nav.title && (nav.url || nav.children.length))
        {
            auto t = "\t".replicate(level);
            f.writeln(t,
                `<LI><OBJECT type="text/sitemap">` ~
                `<param name="Name" value="`, nav.title, `">` ~
                `<param name="Local" value="`, nav.url, `">` ~
                `</OBJECT>`);
            if (nav.children.length)
            {
                f.writeln(t, `<UL>`);
                foreach (child; nav.children)
                    dumpNav(child, level+1);
                f.writeln(t, `</UL>`);
            }
        }
        else
        foreach (child; nav.children)
            dumpNav(child, level);
    }

    f.open(chmDir ~ `/d.hhc`, "wt");
    f.writeln(
`<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><HTML><BODY>
<OBJECT type="text/site properties"><param name="Window Styles" value="0x800025"></OBJECT>
<UL>`);
    dumpNav(nav);
    f.writeln(`</UL>
</BODY></HTML>`);
    f.close();

    // ************************************************************

    stderr.writeln("Writing index file");

    f.open(chmDir ~ `/d.hhk`, "wt");
    f.writeln(
`<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><HTML><BODY>
<UL>`);
    foreach (keyword; keywordList)
    {
        f.writeln(
`    <LI> <OBJECT type="text/sitemap">
        <param name="Name" value="`, keyword, `">`);
        foreach (url; keywords[keyword].keys.sort())
            if (url in pages)
            {
                f.writeln(
`        <param name="Name" value="`, pages[url].title, `">
        <param name="Local" value="files\`, url.backSlashes(), keywords[keyword][url].anchor, `">`);
            }
        f.writeln(
`        </OBJECT>`);
    }
    f.writeln(
`</UL>
</BODY></HTML>`);
    f.close();
}

// ************************************************************

void writeTags()
{
    stderr.writeln("Writing tags file");

    // D syntax
    File f;
    f.open("d-" ~ target ~ ".tag", "wt");
    f.writeln("[");
    foreach (keyword; keywordList)
    {
        static struct IndexEntry { string keyword; string[] urls; }
        IndexEntry entry;
        entry.keyword = keyword;
        foreach (url, link; keywords[keyword])
            if (url in pages)
                entry.urls ~= `http://dlang.org/` ~ url ~ link.anchor;
        f.writeln(entry, ",");
    }
    f.writeln("]");
    f.close();

    // JSON syntax
    import std.json;
    auto j = JSONValue((JSONValue[string]).init);
    foreach (keyword; keywordList)
        j[keyword] = JSONValue(keywords[keyword]
            .byKeyValue
            .map!(kv => JSONValue(`http://dlang.org/` ~ kv.key ~ kv.value.anchor))
            .array);
    std.file.write("d-tags-" ~ target ~ ".json", j.toString());
}

// ********************************************************************

string forwardSlashes(string s)
{
    return s.replace(`\`, `/`);
}

//                   '  *  '
string backSlashes(string s)
{
    return s.replace(`/`, `\`);
}

string getAnchor(string s)
{
    return s.findSplitBefore("#")[1];
}

string stripAnchor(string s)
{
    return s.findSplit("#")[0];
}

string absoluteUrl(string base, string url)
{
    if (url.canFind("://"))
        return url;

    assert(!base.canFind('\\'), format("%s", [base, url]));
    assert(!url .canFind('\\'));
    enforce(url.length, "Empty URL");

    if (url[0]=='#')
        return base ~ url;

    auto pathSegments = base.length ? base.split(`/`)[0..$-1] : null;
    auto urlSegments = url.split(`/`);

    while (urlSegments.startsWith([`..`]))
    {
        urlSegments = urlSegments[1..$];
        enforce(pathSegments.length,
            "Attempting to escape site root (dereferencing %s from %s)"
            .format(url, base));
        pathSegments = pathSegments[0..$-1];
    }
    return (pathSegments ~ urlSegments).join(`/`);
}

bool isAbsoluteURL(string s)
{
    return s.canFind("://")
        || s.startsWith("//")
        || s.startsWith("mailto:");
}

Regex!char re(string pattern, alias flags = [])()
{
    static Regex!char r;
    if (r.empty)
        r = regex(pattern, flags);
    return r;
}
