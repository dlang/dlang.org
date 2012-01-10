// D HTML to CHM converter/generator
// By Vladimir Panteleev <vladimir@thecybershadow.net> (2007-2011)
// Placed in the Public Domain
// Written in the D Programming Language, version 2

import std.algorithm : min, canFind, sort;
import std.array;
import std.ascii;
import std.exception;
import std.file;
import std.stdio;
import std.string;
import std.regex;
import std.path;

enum ROOT = `.`;

// ********************************************************************

string backSlash(string s)
{
	return s.replace(`/`, `\`);
}

bool contains(string s, string sub) { return s.indexOf(sub) >= 0; }

RegexMatch!string match;

bool test(string line, Regex!char re)
{
	match = std.regex.match(line, re);
	return !match.empty;
}

string getAnchor(string s)
{
	int i = s.indexOf('#');
	return i<0 ? "" : s[i..$];
}

string removeAnchor(string s)
{
	int i = s.indexOf('#');
	return i<0 ? s : s[0..i];
}

string absoluteUrl(string base, string url)
{
	if (url.contains("://"))
		return url;

	base = base.backSlash();
	url  = url.backSlash();
	enforce(url.length, "Empty URL");
	
	if (url[0]=='#')
		return base ~ url;

	auto baseParts = base.split(`\`);
	baseParts = baseParts[0..$-1];
	
	while (url.startsWith(`..\`))
	{
		url = url[3..$];
		baseParts = baseParts[0..$-1];
	}
	return baseParts.join(`\`) ~ `\` ~ url;
}

string movePath(string s)
{
	if (s.startsWith(ROOT ~ `\`))
		s = "chm" ~ s[ROOT.length..$];
	if (s == `chm\phobos\phobos.html`)
		s = `chm\phobos\index.html`;
	return s;
}

// ********************************************************************

class Nav
{
	string title, url;
	Nav[] children;

	this(string title, string url)
	{
		this.title = title;
		this.url   = url;
	}

	Nav findOrAdd(string title, string url)
	{
		title = title.strip();
		foreach (child; children)
			if (child.title == title)
				return child;
		auto child = new Nav(title, url);
		children ~= child;
		return child;
	}
}

Nav nav;

class Page
{
	string newFileName;
	string title;
	string src;
	bool[string] anchors;
}

struct KeyLink
{
	string anchor;
	string title;

	this(string anchor, string title)
	{
		this.anchor = anchor.strip();
		this.title  = title.strip();
	}
}

// ********************************************************************

Page[string] pages;
KeyLink[string][string] keywords;   // keywords[keyword][original url w/o anchor] = anchor/title
string[string] keyTable;

void addKeyword(string keyword, string link, string title = null)
{
	keyword = keyword.strip();
	string file = link.removeAnchor();
	file = file.backSlash();
	string anchor = link.getAnchor();

	if (!title && keyword in keywords && file in keywords[keyword])   // when title is present, it overrides any existing anchors/etc.
	{
		if (keywords[keyword][file].anchor > anchor) // "less" is better
			keywords[keyword][file] = KeyLink(anchor, title);
	}
	else
		keywords[keyword][file] = KeyLink(anchor, title);

	if (title && keyword in keyTable)
	{
		if (keyTable[keyword] > keyword) // "less" is better
			keyTable[keyword] = keyword;
	}
	else
		keyTable[keyword] = keyword;
}

void main()
{
	// clean up
	if (exists("chm"))
		rmdirRecurse("chm");
	mkdir("chm");

	string[] files;
	foreach (de; dirEntries(ROOT ~ `\`, "*.{html,css,gif,jpg,png,ico}", SpanMode.breadth))
		if (!de.name.baseName.startsWith("pdf-")
		 && !de.name.baseName.startsWith("std_consolidated_"))
			files ~= de.name;

	auto re_title        = regex(`<title>(.*) - (The )?D Programming Language( [0-9]\.[0-9])? - Digital Mars</title>`);
	auto re_title2       = regex(`<title>(Digital Mars - The )?D Programming Language( [0-9]\.[0-9])? - (.*)</title>`);
	auto re_title3       = regex(`<h1>(.*)</h1>`);
	auto re_heading      = regex(`<h2>(.*)</h2>`);
	auto re_heading_link = regex(`<h2><a href="([^"]*)"( title="([^"]*)")?>(.*)</a></h2>`);
	auto re_nav_link     = regex(`<li><a href="([^"]*)"( title="(.*)")?>(.*)</a>`);
	auto re_anchor_1     = regex(`<a name="([^"]*)">(<.{1,2}>)*([^<]+)<`);
	auto re_anchor_2     = regex(`<a name=([^">]*)>(<.{1,2}>)*([^<]+)<`);
	auto re_anchor_1h    = regex(`<a name="([^"]*)"`);
	auto re_anchor_2h    = regex(`<a name=([^">]*)>`);
	auto re_link         = regex(`<a href="([^"]*)">(<.{1,2}>)*([^<]+)<`);
	auto re_link_pl      = regex(`<li><a href="(http://www.digitalmars.com/d)?/?(\d\.\d)?/index.html" title="D Programming Language \d\.\d">`);
	auto re_def          = regex(`<dt><big>(.*)<u>([^<]+)<`);
	auto re_css_margin   = regex(`margin-left:\s*1[35]em;`);

	nav = new Nav(null, null);

	foreach (fileName; files)
		with (pages[fileName] = new Page)
		{
			scope(failure) writeln("Error while processing file: ", fileName);

			string destdir = fileName.getDirName().movePath();
			if (!exists(destdir))
				mkdirRecurse(destdir);

			newFileName = fileName.movePath();

			if (fileName.endsWith(`.html`))
			{
				writeln("Processing ", fileName);
				src = readText(fileName);
				string[] lines = splitLines(src);
				string[] newlines = null;
				bool skip, innavblock, intoctop;
				int dl = 0;
				anchors[""] = true;

				Nav[] navStack = [nav];
				if (fileName.startsWith(ROOT ~ `\phobos\`))
				{
					navStack ~= navStack[$-1].findOrAdd("Documentation", null);
					navStack ~= navStack[$-1].findOrAdd("Library Reference", `chm\phobos\index.html`);
					navStack ~= navStack[$-1].findOrAdd(null, null);
				}
				else
					navStack ~= null;
				bool foundNav = false;

				foreach (origline; lines)
				{
					scope(failure) writeln("Error while processing line: ", origline);
					string line = origline;
					bool nextSkip = skip;

					if (line.test(re_link_pl))
						continue; // don't process link as well
					
					if (line.test(re_title))
					{
						title = strip(/*re_title*/match.captures[1]);
						line = line.replace(re_title, `<title>` ~ title ~ `</title>`);
					}
					if (line.test(re_title2))
					{
						title = strip(/*re_title2*/match.captures[3]);
						line = line.replace(re_title2, `<title>` ~ title ~ `</title>`);
					}
					if (line.test(re_title3))
						if (title=="")
							title = strip(/*re_title2*/match.captures[1]);
					
					if (line.test(re_anchor_1h))
					{
						auto anchor = '#' ~ /*re_anchor*/match.captures[1];
						anchors[anchor] = true;
					}
					else
					if (line.test(re_anchor_2h))
					{
						auto anchor = '#' ~ /*re_anchor_2*/match.captures[1];
						anchors[anchor] = true;
					}

					if (line.contains(`<div id="navigation"`))
						innavblock = true;
					else
					if (line.contains(`<!--/navigation-->`))
						innavblock = false;
					if (line.contains(`<div id="toctop"`))
						intoctop = true;
					else
					if (intoctop && line.contains(`</div>`))
						intoctop = false;

					if (innavblock && !intoctop)
					{
						if (line.contains("<ul>"))
							navStack ~= null;
						else
						if (line.contains("</ul>"))
							navStack = navStack[0..$-1];

						void doLink(string title, string url)
						{
							if (url)
							{
								url = absoluteUrl(fileName, url);
								if (url == fileName)
									foundNav = true;
								url = url.movePath();
							}
							navStack[$-1] = navStack[$-2].findOrAdd(title, url);
						}

						if (line.test(re_heading_link))
							doLink(match.captures[4], match.captures[1]);
						else
						if (line.test(re_heading))
							doLink(match.captures[1], null);
						else
						if (line.test(re_nav_link))
							doLink(match.captures[4], match.captures[1]);
					}

					if (line.contains(`<dl>`))
						dl++;
					if (dl==1)
					{
						if (line.test(re_def))
						{
							auto anchor = /*re_def*/match.captures[2];
							while ("#"~anchor in anchors) anchor ~= '_';
							anchors["#"~anchor] = true;
							//line = match.pre ~ line.replace(re_def, `<dt><big>$1<u><a name="` ~ anchor ~ `">$2</a><`) ~ match.post;
							line = line.replace(re_def, `<dt><big>$1<u><a name="` ~ anchor ~ `">$2</a><`);
							//writeln("new line: ", line);
							addKeyword(/*re_def*/match.captures[2], fileName ~ "#" ~ anchor);
						}
					}
					if (line.contains(`</dl>`))
						dl--;

					if (line.test(re_anchor_1))
						addKeyword(/*re_anchor*/match.captures[3], fileName ~ "#" ~ /*re_anchor*/match.captures[1]);
					else
					if (line.test(re_anchor_2))
						addKeyword(/*re_anchor_2*/match.captures[3], fileName ~ "#" ~ /*re_anchor_2*/match.captures[1]);
					else
					if (line.test(re_anchor_1h))
						addKeyword(/*re_anchor*/match.captures[1], fileName ~ "#" ~ /*re_anchor*/match.captures[1]);
					else
					if (line.test(re_anchor_2h))
						addKeyword(/*re_anchor_2*/match.captures[1], fileName ~ "#" ~ /*re_anchor_2*/match.captures[1]);

					if (line.test(re_link))
						if (!/*re_link*/match.captures[1].startsWith("http://"))
							addKeyword(/*re_link*/match.captures[3], absoluteUrl(fileName, /*re_link*/match.captures[1]));
					
					// skip Google ads
					if (line.startsWith(`<!-- Google ad -->`))
						skip = nextSkip = true;
					if (line == `</script>`)
						nextSkip = false;

					// skip header / navigation bar
					if (line.contains(`<body`))
					{
						line = `<body class="chm">`;
						nextSkip = true;
					}
					if (line.contains(`<div id="content"`))
						skip = nextSkip = false;

					// skip "digg this"
					if (line.contains(`<script src="http://digg.com/tools/diggthis.js"`))
						skip = true;

					if (!skip)
						newlines ~= line;
					skip = nextSkip;
				}

				if (!foundNav)
					writeln("Warning: Page not found in navigation");

				src = join(newlines, newline[]);
				std.file.write(newFileName, src);
			}
			else
			if (fileName.endsWith(`.css`))
			{
				writeln("Processing "~fileName);
				src = readText(fileName);
				string[] lines = splitLines(src);
				string[] newlines = null;
				foreach (line;lines)
				{
					// skip #div.content positioning
					if (!line.test(re_css_margin))
						newlines ~= line;
				}
				src = join(newlines, newline[]);
				std.file.write(newFileName, src);
			}
			else
			{
				writeln("Copying "~fileName);
				copy(fileName, newFileName);
			}
		} 

	// ************************************************************

	// retreive keyword link titles
	foreach (keyNorm, urls; keywords)
		foreach (url, ref link; urls)
			if (url in pages)
				link.title = pages[url].title;

	// ************************************************************

	auto re_key_new  = regex(`<tt>(.*)</tt>`);
	auto re_key_link = regex(`^\* (.*)\[http://www\.digitalmars\.com/d/2\.0/([^ ]*) (.*)\]`);

	auto keywordLines = splitLines(keywordIndex);
	string keyword;
	foreach (line;keywordLines)
	{
		if (line.test(re_key_new))
			keyword = /*re_key_new*/match.captures[1];
		if (line.test(re_key_link))
		{
			string url = ROOT ~ `\` ~ /*re_key_link*/match.captures[2].backSlash();
			string file = removeAnchor(url);
			string anchor = getAnchor(url);
			backSlash(url);
			
			if (file in pages)
			{
				if (!(anchor in pages[file].anchors))
				{
					//string anchors; foreach (anch,b;pages[file].anchors) anchors~=anch~",";
					writeln("Invalid URL: " ~ url ~ " out of: " ~ anchor);
				}

				if (anchor=="" || anchor in pages[file].anchors)
				{
					addKeyword(keyword, file ~ anchor, /*re_key_link*/match.captures[1] ~ /*re_key_link*/match.captures[3]);
				//	writeln("Adding keyword " ~ keyword ~ " to " ~ file ~ anchor ~ " as " ~ /*re_key_link*/match.captures[1] ~ /*re_key_link*/match.captures[3]);
				}
				else
					writeln("Broken anchor link to keyword "~ keyword ~ " to " ~ /*re_key_link*/match.captures[2] ~ " as " ~ /*re_key_link*/match.captures[1] ~ /*re_key_link*/match.captures[3]);
			}
			else
				writeln("Unfound URL: " ~ url);
		}
	}

	// ************************************************************

	auto f = File("d.hhp", "wt");
	f.writeln(
`[OPTIONS]
Binary Index=No
Compatibility=1.1 or later
Compiled file=d.chm
Contents file=d.hhc
Default Window=main
Default topic=chm\index.html
Display compile progress=No
Full-text search=Yes
Index file=d.hhk
Language=0x409 English (United States)
Title=D

[WINDOWS]
main="D Programming Language","d.hhc","d.hhk","chm\index.html","chm\index.html",,,,,0x63520,,0x380e,[0,0,800,570],0x918f0000,,,,,,0

[FILES]`);
	string[] htmlList;
	foreach (page;pages)
		if (page.newFileName.endsWith(`.html`))
			htmlList ~= page.newFileName;
	htmlList.sort;
	foreach (s; htmlList)
		f.writeln(s);
	f.writeln(`
[INFOTYPES]`);
	f.close();

	// ************************************************************

	void dumpNav(Nav nav, int level=0)
	{
		if (nav.title)
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
	
	f.open("d.hhc", "wt");
	f.writeln(
`<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><HTML><BODY>
<OBJECT type="text/site properties"><param name="Window Styles" value="0x800025"></OBJECT>
<UL>`);
	dumpNav(nav);
	f.writeln(`</UL>
</BODY></HTML>`);
	f.close();

	// ************************************************************

	string[] keywordList;
	foreach (keyNorm,urlList;keywords)
		keywordList ~= keyNorm;
	//keywordList.sort;
	sort!q{icmp(a, b) < 0}(keywordList);

	f.open("d.hhk", "wt");
	f.writeln(
`<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><HTML><BODY>
<UL>`);
	foreach (keyNorm;keywordList)
	{
		auto urlList = keywords[keyNorm];
		f.writeln(
`	<LI> <OBJECT type="text/sitemap">
		<param name="Name" value="`, keyTable[keyNorm], `">`);
		foreach (url,link;urlList)
			if (url in pages)
			{
				f.writeln(
`		<param name="Name" value="`, link.title, `">
		<param name="Local" value="`, movePath(url), link.anchor, `">`);
			}
		f.writeln(
`		</OBJECT>`);
	}
	f.writeln(
`</UL>
</BODY></HTML>`);
	f.close();
}

// ********************************************************************

// Retrieved on 2011.12.12 from http://www.prowiki.org/wiki4d/wiki.cgi?LanguageSpecification/KeywordIndex2
const keywordIndex = `
A D 1.0 version of this page is available at LanguageSpecification/KeywordIndex.
----

<tt>abstract</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html#abstract Attributes]
<tt>alias</tt>
* [http://www.digitalmars.com/d/2.0/declaration.html#alias Declarations]
* template parameters: [http://www.digitalmars.com/d/2.0/template.html#aliasparameters Templates]
<tt>align</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html#align Attributes]
<tt>asm</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#asm Statements]
* x86 inline assembler:  [http://www.digitalmars.com/d/2.0/iasm.html Inline Assembler]
<tt>assert</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#AssertExpression Expressions]
* static assert:  [http://www.digitalmars.com/d/2.0/version.html#StaticAssert Conditional Compilation]

<tt>auto</tt>
* class attribute:  [http://www.digitalmars.com/d/2.0/class.html#auto Classes]
* RAII attribute:  [http://www.digitalmars.com/d/2.0/attribute.html#auto Attributes]
* type inference:  [http://www.digitalmars.com/d/2.0/declaration.html#AutoDeclaration Declarations]

----

<tt>body</tt>
* in function contract:  [http://www.digitalmars.com/d/2.0/dbc.html Contracts]

<tt>bool</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>break</tt>
* in switch:  [http://www.digitalmars.com/d/2.0/statement.html#SwitchStatement Statements]
* statement:  [http://www.digitalmars.com/d/2.0/statement.html#BreakStatement Statements]

<tt>byte</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

----

<tt>case</tt>
* in switch:  [http://www.digitalmars.com/d/2.0/statement.html#SwitchStatement Statements]

<tt>cast</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#CastExpression Expressions]

<tt>catch</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#TryStatement Statements]

<tt>cdouble</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* complex types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

<tt>cent</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>cfloat</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* complex types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

<tt>char</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>class</tt>
* [http://www.digitalmars.com/d/2.0/class.html Classes]
* properties of:  [http://www.digitalmars.com/d/2.0/property.html#classproperties Properties]

<tt>const</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html#const Attributes]

<tt>continue</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#ContinueStatement Statements]

<tt>creal</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* complex types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

----

<tt>dchar</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>debug</tt>
* [http://www.digitalmars.com/d/2.0/version.html#debug Conditional Compilation]

<tt>default</tt>
* in switch:  [http://www.digitalmars.com/d/2.0/statement.html#SwitchStatement Statements]

<tt>delegate</tt>
* as datatype and replacement for pointer-to-member-function:  [http://www.digitalmars.com/d/2.0/type.html#delegates Types]
* as dynamic closure:  [http://www.digitalmars.com/d/2.0/function.html#closures Functions]
* in function literal:  [http://www.digitalmars.com/d/2.0/expression.html#FunctionLiteral Expressions]

<tt>delete</tt>
* expression:  [http://www.digitalmars.com/d/2.0/expression.html#DeleteExpression Expressions]
* overloading:  [http://www.digitalmars.com/d/2.0/class.html#deallocators Classes]

<tt>deprecated</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html#deprecated Attributes]

<tt>do</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#DoStatement Statements]

<tt>double</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* floating point types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

----

<tt>else</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#IfStatement Statements]

<tt>enum</tt>
* [http://www.digitalmars.com/d/2.0/enum.html Enums]

<tt>export</tt>
* protection attribute:  [http://www.digitalmars.com/d/2.0/attribute.html Attributes]

<tt>extern</tt>
* linkage attribute:  [http://www.digitalmars.com/d/2.0/attribute.html#linkage Attributes]
* interfacing to C:  [http://www.digitalmars.com/d/2.0/interfaceToC.html Interfacing to C]
* in variable declaration:  [http://www.digitalmars.com/d/2.0/declaration.html#extern Declarations]

----

<tt>false</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#PrimaryExpression Expressions]

<tt>final</tt>
* [http://www.digitalmars.com/d/2.0/function.html Functions]

<tt>finally</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#TryStatement Statements]

<tt>float</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* floating point types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

<tt>for</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#ForStatement Statements]

<tt>foreach</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#ForeachStatement Statements]

<tt>foreach_reverse</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#ForeachStatement Statements]

<tt>function</tt>
* as datatype:  [http://www.digitalmars.com/d/2.0/type.html Types]
* in function literal:  [http://www.digitalmars.com/d/2.0/expression.html#FunctionLiteral Expressions]
* function pointers:  [http://www.digitalmars.com/d/2.0/function.html#closures Functions]


----


<tt>goto</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#GotoStatement Statements]


----


<tt>idouble</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* imaginary types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

<tt>if</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#IfStatement Statements]
* static if:  [http://www.digitalmars.com/d/2.0/version.html#staticif Conditional Compilation]

<tt>ifloat</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* imaginary types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

<tt>import</tt>
* [http://www.digitalmars.com/d/2.0/module.html#ImportDeclaration Modules]
* import expression:  [http://digitalmars.com/d/2.0/expression.html#ImportExpression Expressions]

<tt>in</tt>
* in pre contract:  [http://www.digitalmars.com/d/2.0/dbc.html Contracts]
* containment test:  [http://www.digitalmars.com/d/2.0/expression.html#InExpression Expressions]
* function parameter:  [http://www.digitalmars.com/d/2.0/function.html#parameters Functions]

<tt>inout</tt> ''(deprecated, use <tt>ref</tt> instead)''
* in foreach statement:  [http://www.digitalmars.com/d/2.0/statement.html#ForeachStatement Statements]
* function parameter:  [http://www.digitalmars.com/d/2.0/function.html#parameters Functions]

<tt>int</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>interface</tt>
* [http://www.digitalmars.com/d/2.0/interface.html Interfaces]

<tt>invariant</tt>
* [http://www.digitalmars.com/d/2.0/class.html#invariants Classes]

<tt>ireal</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* imaginary types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

<tt>is</tt>
* identity comparison:  [http://www.digitalmars.com/d/2.0/expression.html#EqualExpression Expressions]
* type comparison:  [http://www.digitalmars.com/d/2.0/expression.html#IsExpression Expressions]


----


<tt>lazy</tt>
* function parameter:  [http://www.digitalmars.com/d/2.0/function.html#parameters Functions]

<tt>long</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]


----

<tt>macro</tt>
* ''Reserved, not implemented yet.''

<tt>mixin</tt>
* [http://www.digitalmars.com/d/2.0/template-mixin.html Template Mixins]
* Mixin declarations:  [http://digitalmars.com/d/2.0/module.html#MixinDeclaration Modules]
* Mixin expressions:  [http://digitalmars.com/d/2.0/expression.html#MixinExpression Expressions]
* Mixin statements:  [http://digitalmars.com/d/2.0/statement.html#MixinStatement Statements]

<tt>module</tt>
* [http://www.digitalmars.com/d/2.0/module.html Modules]


----


<tt>new</tt>
* anonymous nested classes and:  [http://www.digitalmars.com/d/2.0/class.html#anonymous Classes]
* expression:  [http://www.digitalmars.com/d/2.0/expression.html#NewExpression Expressions]
* overloading:  [http://www.digitalmars.com/d/2.0/class.html#allocators Classes]

<tt>nothrow</tt>
* ''Reserved, not implemented yet.''

<tt>null</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#PrimaryExpression Expressions]


----


<tt>out</tt>
* in post contract:  [http://www.digitalmars.com/d/2.0/dbc.html Contracts]
* function parameter:  [http://www.digitalmars.com/d/2.0/function.html#parameters Functions]

<tt>override</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html#override Attributes]


----


<tt>package</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html Attributes]

<tt>pragma</tt>
* [http://www.digitalmars.com/d/2.0/pragma.html Pragmas]

<tt>private</tt>
* and import:  [http://www.digitalmars.com/d/2.0/module.html Modules]
* protection attribute:  [http://www.digitalmars.com/d/2.0/attribute.html Attributes]

<tt>protected</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html Attributes]

<tt>public</tt>
* [http://www.digitalmars.com/d/2.0/attribute.html Attributes]

<tt>pure</tt>
* ''Reserved, not implemented yet.''

----


<tt>real</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]
* floating point types:  [http://www.digitalmars.com/d/2.0/float.html Floating Point]

<tt>ref</tt>
* in foreach statement:  [http://www.digitalmars.com/d/2.0/statement.html#ForeachStatement Statements]
* function parameter:  [http://www.digitalmars.com/d/2.0/function.html#parameters Functions]

<tt>return</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#ReturnStatement Statements]


----


<tt>scope</tt>
* statement: [http://www.digitalmars.com/d/2.0/statement.html#ScopeGuardStatement Statements]
* RAII attribute:  [http://www.digitalmars.com/d/2.0/attribute.html#scope Attributes]

<tt>short</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>static</tt>
* attribute:  [http://www.digitalmars.com/d/2.0/attribute.html Attributes]
* constructors:  [http://www.digitalmars.com/d/2.0/class.html#StaticConstructor Classes]
* destructors:  [http://www.digitalmars.com/d/2.0/class.html#StaticDestructor Classes]
* order of static constructors and destructors:  [http://www.digitalmars.com/d/2.0/module.html#staticorder Modules]
* static assert:  [http://www.digitalmars.com/d/2.0/version.html#StaticAssert Conditional Compilation]
* static if:  [http://www.digitalmars.com/d/2.0/version.html#staticif Conditional Compilation]
* static import:  [http://www.digitalmars.com/d/2.0/module.html#ImportDeclaration Modules]

<tt>struct</tt>
* [http://www.digitalmars.com/d/2.0/struct.html Structs & Unions]
* properties of:  [http://www.digitalmars.com/d/2.0/property.html#classproperties Properties]

<tt>super</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#PrimaryExpression Expressions]
* as name of superclass constructor:  [http://www.digitalmars.com/d/2.0/class.html#constructors Classes]

<tt>switch</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#SwitchStatement Statements]

<tt>synchronized</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#SynchronizedStatement Statements]
* as storage class: [http://digitalmars.com/d/2.0/declaration.html Declarations]


----


<tt>template</tt>
* [http://www.digitalmars.com/d/2.0/template.html Templates]

<tt>this</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#PrimaryExpression Expressions]
* as constructor name:  [http://www.digitalmars.com/d/2.0/class.html#constructors Classes]
* with ~, as destructor name:  [http://www.digitalmars.com/d/2.0/class.html#destructors Classes]

<tt>throw</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#ThrowStatement Statements]

<tt>__traits</tt>
* [http://www.digitalmars.com/d/2.0/traits.html Traits]

<tt>true</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#PrimaryExpression Expressions]

<tt>try</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#TryStatement Statements]

<tt>typeid</tt>
* [http://www.digitalmars.com/d/2.0/expression.html#TypeidExpression Expressions]

<tt>typeof</tt>
* [http://www.digitalmars.com/d/2.0/declaration.html#typeof Declarations]


----


<tt>ubyte</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>ucent</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>uint</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>ulong</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>union</tt>
* [http://www.digitalmars.com/d/2.0/struct.html Structs & Unions]

<tt>unittest</tt>
* [http://www.digitalmars.com/d/2.0/unittest.html Unit Tests]

<tt>ushort</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]


----


<tt>version</tt>
* [http://www.digitalmars.com/d/2.0/version.html#version Conditional Compilation]

<tt>void</tt>
* as initializer:  [http://www.digitalmars.com/d/2.0/declaration.html Declarations]
* as type:  [http://www.digitalmars.com/d/2.0/type.html Types]


----


<tt>wchar</tt>
* [http://www.digitalmars.com/d/2.0/type.html Types]

<tt>while</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#WhileStatement Statements]

<tt>with</tt>
* [http://www.digitalmars.com/d/2.0/statement.html#WithStatement Statements]



----

Source: Kirk <n>McDonald</n>, http://216.190.88.10:8087/media/d_index.html (NG:digitalmars.D/38550)`;