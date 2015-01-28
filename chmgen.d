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

enum ROOT = `.`;

// ********************************************************************

class Nav
{
	string title, url;
	Nav[] children;
}

Nav loadNav(string fileName, string base, bool warn)
{
	import std.json;
	auto text = fileName
		.readText()
		.replace("\r", "")
		.replace("\n", "")
	//	.replaceAll(re!`/\*.*?\*/`, "")
		.replaceAll(re!`,\s*\]`, `]`)
	;
	scope(failure) std.file.write("error.json", text);
	auto json = text.parseJSON();

	Nav parseNav(JSONValue json)
	{
		if (json.type == JSON_TYPE.ARRAY)
		{
			auto nodes = json.array;
			auto root = parseNav(nodes[0]);
			root.children = nodes[1..$].map!parseNav.array().filter!`a`.array();
			return root;
		}
		else
		{
			auto obj = json.object;
			auto nav = new Nav;
			nav.title = obj["t"].str.strip();
			if ("a" in obj)
			{
				auto url = absoluteUrl(base, obj["a"].str.strip());
				if (url.canFind(`://`))
				{
					stderr.writeln("Skipping external navigation item: " ~ url);
					return null;
				}
				else
				if (!exists(`chm/files/` ~ url))
				{
					if (warn)
						stderr.writeln("Warning: Item in navigation does not exist: " ~ url);
					else
						stderr.writeln("Skipping non-existent navigation item: " ~ url);
					//url = "http://dlang.org/" ~ url;
					return null;
				}
				else
					nav.url = `files\` ~ url.backSlashes();
			}
			return nav;
		}
	}

	return parseNav(json);
}

Nav nav;

// ********************************************************************

struct KeyLink { string anchor; int confidence; bool sawAnchor; }
KeyLink[string][string] keywords;   // keywords[keyword][original url w/o anchor] = anchor/confidence
string[] keywordList; // Sorted alphabetically, case-insensitive
bool[string] sawAnchor;

void addKeyword(string keyword, string link, int confidence, bool isAnchor = true)
{
	keyword = keyword.strip();
	if (!keyword.length)
		return;
	link = link.strip();
	string file = link.stripAnchor();
	string anchor = link.getAnchor();

	if (keyword !in keywords
	 || file !in keywords[keyword]
	 || keywords[keyword][file].confidence < confidence)
		keywords[keyword][file] = KeyLink(anchor, confidence);

	if (anchor.length)
	{
		if (link !in sawAnchor)
			sawAnchor[link] = false;
		if (isAnchor)
			sawAnchor[link] = true;
	}
}

class Page
{
	string fileName, title;
}
Page[string] pages;

// ********************************************************************

void main(string[] args)
{
	bool onlyTags;

	getopt(args,
		"only-tags", &onlyTags,
	);

	bool chm = !onlyTags;

	if (chm)
	{
		if (exists(`chm`))
			rmdirRecurse(`chm`);
		mkdirRecurse(`chm/files`);
	}

	enforce(exists(ROOT ~ `/phobos/index.html`),
		`Phobos documentation not present. Please place Phobos documentation HTML files into the "phobos" subdirectory.`);

	string[] files = chain(
		dirEntries(ROOT ~ `/`       , "*.html", SpanMode.shallow),
		dirEntries(ROOT ~ `/phobos/`, "*.html", SpanMode.shallow),
	//	dirEntries(ROOT ~ `/js/`              , SpanMode.shallow),
		dirEntries(ROOT ~ `/css/`             , SpanMode.shallow),
		dirEntries(ROOT ~ `/images/`, "*.*"   , SpanMode.shallow),
		only(ROOT ~ `/favicon.ico`)
	).array();

	foreach (fileName; files)
	{
		scope(failure) stderr.writeln("Error while processing file: ", fileName);

		auto page = new Page;
		fileName = page.fileName = fileName[ROOT.length+1 .. $].forwardSlashes();
		pages[fileName] = page;

		auto newFileName = `chm/files/` ~ fileName;
		newFileName.dirName().mkdirRecurse();

		if (fileName.endsWith(`.html`))
		{
			stderr.writeln("Processing ", fileName);
			auto src = fileName.readText();

			// Find title

			foreach (m; src.match(re!`<title>(.*?) - D Programming Language</title>`))
				page.title = m.captures[1];

			// Add document CSS class

			src = src.replaceAll(re!`(<body id='.*?' class='.*?)('>)`, `\1 chm\2`);

			// Fix links

			src = src.replace(`<a href="."`, `<a href="index.html"`);
			src = src.replace(`<a href=".."`, `<a href="../index.html"`);

			// Find anchors

			enum attrs = `(?:(?:\w+=\"[^"]*\")?\s*)*`;
			enum name = `(?:name|id)`;

			foreach (m; src.matchAll(re!(`<a `~attrs~name~`="(\.?[^"]*)"`~attrs~`>(.*?)</a>`)))
				addKeyword(m.captures[2].replaceAll(re!`<.*?>`, ``), fileName ~ "#" ~ m.captures[1], 5);

			foreach (m; src.matchAll(re!(`<a `~attrs~name~`="(\.?([^"]*?)(\.\d+)?)"`~attrs~`>`)))
				addKeyword(m.captures[2], fileName ~ "#" ~ m.captures[1], 1);

			foreach (m; src.matchAll(re!(`<div class="quickindex" id="(quickindex\.(.+?))"></div>`)))
				addKeyword(m.captures[2], fileName ~ "#" ~ m.captures[1], 1);

			foreach (m; src.matchAll(re!(`<a `~attrs~`href="([^"]*)"`~attrs~`>(.*?)</a>`)))
				if (!m.captures[1].canFind("://"))
					addKeyword(m.captures[2].replaceAll(re!`<.*?>`, ``), absoluteUrl(fileName, m.captures[1]), 4, false);

			// Disable scripts

			src = src.replaceAll(re!`<script.*?</script>`, ``);
			src = src.replaceAll(re!`<script.*?\bsrc=.*?>`, ``);

			// Remove external stylesheets

			src = src.replaceAll(re!`<link rel="stylesheet" href="http.*?>`, ``);

			if (chm)
				std.file.write(newFileName, src);
		}
		else
		{
			if (chm)
			{
				stderr.writeln("Copying ", fileName);
				copy(fileName, newFileName);
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

void loadNavigation()
{
	stderr.writeln("Loading navigation");

	nav = loadNav("chm-nav-doc.json", ``, false);
	auto phobosIndex = `files\phobos\index.html`;
	auto navPhobos = nav.children.find!(child => child.url == phobosIndex).front;
	auto phobos = loadNav("chm-nav-std.json", `phobos/`, true);
	navPhobos.children = phobos.children.filter!(child => child.url != phobosIndex).array();
}

// ************************************************************

void lint()
{
	// Unknown URLs (links to pages we did not see)
	{
		bool[string] unknownPages;
		foreach (keyword; keywordList)
			foreach (page, link; keywords[keyword])
				if (page !in pages)
					unknownPages[page] = true;
		foreach (url; unknownPages.keys.sort())
			stderr.writeln("Warning: Unknown page: " ~ url);
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

	auto f = File(`chm\d.hhp`, "wt");
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
	foreach (page; pages)
		if (page.fileName.endsWith(`.html`))
			htmlList ~= `files\` ~ page.fileName.backSlashes();
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
				`<LI><OBJECT type="text/sitemap">`
				`<param name="Name" value="`, nav.title, `">`
				`<param name="Local" value="`, nav.url, `">`
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

	f.open(`chm\d.hhc`, "wt");
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

	f.open(`chm\d.hhk`, "wt");
	f.writeln(
`<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><HTML><BODY>
<UL>`);
	foreach (keyword; keywordList)
	{
		f.writeln(
`	<LI> <OBJECT type="text/sitemap">
		<param name="Name" value="`, keyword, `">`);
		foreach (url; keywords[keyword].keys.sort())
			if (url in pages)
			{
				f.writeln(
`		<param name="Name" value="`, pages[url].title, `">
		<param name="Local" value="files\`, url.backSlashes(), keywords[keyword][url].anchor, `">`);
			}
		f.writeln(
`		</OBJECT>`);
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

	File f;
	f.open(`d.tag`, "wt");
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
		pathSegments = pathSegments[0..$-1];
	}
	return (pathSegments ~ urlSegments).join(`/`);
}

Regex!char re(string pattern, alias flags = [])()
{
	static Regex!char r;
	if (r.empty)
		r = regex(pattern, flags);
	return r;
}
