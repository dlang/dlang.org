#!/usr/bin/rdmd --shebang
/*
	Rewrites old DDOX based Phobos documentation URLs to the new file name style.

	Previously, the symbol names have been directly translated to the
	file name: boyerMooreFinder -> boyedMooreFinder.html
	To avoid name clashes on case insensitive file systems, the new scheme
	is to use lower case letters and underscores: boyer_moore_finder.html
	Similar symbols are then aggregated on the same page (e.g.
	BoyerMooreFinder).

	Full example:
	  OLD: http://dlang.org/library/std/algorithm/BoyerMooreFinder.html
	  NEW: http://dlang.org/library/std/algorithm/boyer_moore_finder.html

	This script expects the URLs to be passed on STDIN line-by-line without the
	server/schema part:
	  /library/std/algorithm/BoyerMooreFinder.html
	  /library/std/algorithm/find.html
	  ...
*/

import std.algorithm;
import std.array;
import std.stdio;
import std.string;
import std.utf;

enum s_urlPrefix = "/library/";
enum s_urlSuffix = ".html";

void main()
{
	foreach (url; stdin.byLine) {
		if (!url.startsWith(s_urlPrefix) || !url.endsWith(s_urlSuffix)) {
			writeln(url);
			continue;
		}

		// extract just the file name portion
		auto last_slash = url.lastIndexOf('/');
		auto name = url[last_slash+1 .. $-s_urlSuffix.length];
		auto adjname = name.splitter('.').map!adjustStyle.join(".");

		// write back the URL with adjusted file name style
		writefln("%s%s%s", url[0 .. last_slash+1], adjname, s_urlSuffix);
	}
}


string adjustStyle(const(char)[] name)
{
	auto ret = appender!string;
	size_t start = 0, i = 0;
	while (i < name.length) {
		// skip acronyms
		while (i < name.length && (i+1 >= name.length || (name[i+1] >= 'A' && name[i+1] <= 'Z'))) {
			std.utf.decode(name, i);
		}

		// skip the main (lowercase) part of a word
		while (i < name.length && !(name[i] >= 'A' && name[i] <= 'Z')) {
			std.utf.decode(name, i);
		}

		// add a single word
		if( ret.data.length > 0 ) {
			ret ~= "_";
		}
		ret ~= name[start .. i];

		// quick skip the capital and remember the start of the next word
		start = i;
		if (i < name.length) {
			std.utf.decode(name, i);
		}
	}
	if (i < name.length) {
		ret ~= "_" ~ name[start .. $];
	}
	return std.string.toLower(ret.data);
}
