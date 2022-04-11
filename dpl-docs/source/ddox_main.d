// Copied from https://github.com/rejectedsoftware/ddox/blob/master/source/ddox/main.d
module ddox_main;

import ddox.ddoc;
import ddox.ddox;
import ddox.entities;
import ddox.htmlgenerator;
import ddox.htmlserver;
import ddox.parsers.dparse;
import ddox.parsers.jsonparser;

import vibe.core.core;
import vibe.core.file;
import vibe.data.json;
import vibe.inet.url;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;
import vibe.stream.operations;
import std.array;
import std.exception : enforce;
import std.file;
import std.getopt;
import std.stdio;
import std.string;


int ddoxMain(string[] args)
{
	bool help;
	getopt(args, config.passThrough, "h|help", &help);

	if( args.length < 2 || help ){
		showUsage(args);
		return help ? 0 : 1;
	}

	if( args[1] == "generate-html" && args.length >= 4 )
		return cmdGenerateHtml(args);
	if( args[1] == "serve-html" && args.length >= 3 )
		return cmdServeHtml(args);
	if( args[1] == "filter" && args.length >= 3 )
	{
        import assert_writeln_magic : assertWritelnBlock;
        import std.functional : toDelegate;
        FilterConfig config = {
            postUnittestSourceCode: (&assertWritelnBlock).toDelegate,
        };
		return cmdFilterDocs(args, config);
	}
	if( args[1] == "serve-test" && args.length >= 3 )
		return cmdServeTest(args);
	showUsage(args);
	return 1;
}

static import ddox.main;

alias cmdGenerateHtml = ddox.main.cmdGenerateHtml;
alias cmdServeHtml = ddox.main.cmdServeHtml;
alias cmdServeTest = ddox.main.cmdServeTest;
alias parseDocFile = ddox.main.parseDocFile;
alias setupGeneratorInput = ddox.main.setupGeneratorInput;
alias showUsage = ddox.main.showUsage;


/**
The following functions are copied from `ddox.main` with
https://github.com/rejectedsoftware/ddox/pull/199 applied.
Once #199 is merged at upstream, this can be removed.
*/
struct FilterConfig
{
	/**
	Custom delegate that is called after the unittest source code has been parsed
	Can be used to inject custom logic like an assert/writeln transformation.
	*/
	string delegate(string) postUnittestSourceCode;
}

int cmdFilterDocs(string[] args, FilterConfig filterConfig = FilterConfig.init)
{
	string[] excluded, included;
	Protection minprot = Protection.Private;
	bool keeputests = false;
	bool keepinternals = false;
	bool unittestexamples = true;
	bool nounittestexamples = false;
	bool justdoc = false;
	getopt(args,
		//config.passThrough,
		"ex", &excluded,
		"in", &included,
		"min-protection", &minprot,
		"only-documented", &justdoc,
		"keep-unittests", &keeputests,
		"keep-internals", &keepinternals,
		"unittest-examples", &unittestexamples, // deprecated, kept to not break existing scripts
		"no-unittest-examples", &nounittestexamples);

	if (keeputests) keepinternals = true;
	if (nounittestexamples) unittestexamples = false;

	string jsonfile;
	if( args.length < 3 ){
		showUsage(args);
		return 1;
	}

	Json filterProt(Json json, Json parent, Json last_decl, Json mod)
	{
		if (last_decl.type == Json.Type.undefined) last_decl = parent;

		string templateName(Json j){
			auto n = j["name"].opt!string();
			auto idx = n.indexOf('(');
			if( idx >= 0 ) return n[0 .. idx];
			return n;
		}

		if( json.type == Json.Type.Object ){
			auto comment = json["comment"].opt!string;
			if( justdoc && comment.empty ){
				if( parent.type != Json.Type.Object || parent["kind"].opt!string() != "template" || templateName(parent) != json["name"].opt!string() )
					return Json.undefined;
			}

			Protection prot = Protection.Public;
			if( auto p = "protection" in json ){
				switch(p.get!string){
					default: break;
					case "private": prot = Protection.Private; break;
					case "package": prot = Protection.Package; break;
					case "protected": prot = Protection.Protected; break;
				}
			}
			if( comment.strip == "private" ) prot = Protection.Private;
			if( prot < minprot ) return Json.undefined;

			auto name = json["name"].opt!string();
			bool is_internal = name.startsWith("__");
			bool is_unittest = name.startsWith("__unittest");
			if (name.startsWith("_staticCtor") || name.startsWith("_staticDtor")) is_internal = true;
			else if (name.startsWith("_sharedStaticCtor") || name.startsWith("_sharedStaticDtor")) is_internal = true;

			if (unittestexamples && is_unittest && !comment.empty) {
				assert(last_decl.type == Json.Type.object, "Don't have a last_decl context.");
				try {
					string source = extractUnittestSourceCode(json, mod);
					if (last_decl["comment"].opt!string.empty) {
						writefln("Warning: Cannot add documented unit test %s to %s, which is not documented.", name, last_decl["name"].opt!string);
					} else {
						if (filterConfig.postUnittestSourceCode !is null)
							source = filterConfig.postUnittestSourceCode(source);
						last_decl["comment"] ~= format("Example:\n%s$(DDOX_UNITTEST_HEADER %s)\n---\n%s\n---\n$(DDOX_UNITTEST_FOOTER %s)\n", comment.strip, name, source, name);
					}
				} catch (Exception e) {
					writefln("Failed to add documented unit test %s:%s as example: %s",
						mod["file"].get!string(), json["line"].get!long, e.msg);
					return Json.undefined;
				}
			}

			if (!keepinternals && is_internal) return Json.undefined;

			if (!keeputests && is_unittest) return Json.undefined;

			if (auto mem = "members" in json)
				json["members"] = filterProt(*mem, json, Json.undefined, mod);
		} else if( json.type == Json.Type.Array ){
			auto last_child_decl = Json.undefined;
			Json[] newmem;
			foreach (m; json) {
				auto mf = filterProt(m, parent, last_child_decl, mod);
				if (mf.type == Json.Type.undefined) continue;
				if (mf.type == Json.Type.object && !mf["name"].opt!string.startsWith("__unittest") && icmp(mf["comment"].opt!string.strip, "ditto") != 0)
					last_child_decl = mf;
				newmem ~= mf;
			}
			return Json(newmem);
		}
		return json;
	}

	writefln("Reading doc file...");
	auto text = readText(args[2]);
	int line = 1;
	writefln("Parsing JSON...");
	auto json = parseJson(text, &line);

	writefln("Filtering modules...");
	Json[] dst;
	foreach (m; json) {
		if ("name" !in m) {
			writefln("No name for module %s - ignoring", m["file"].opt!string);
			continue;
		}
		auto n = m["name"].get!string;
		bool include = true;
		foreach (ex; excluded)
			if (n == ex || n.startsWith(ex ~ ".")) {
				include = false;
				break;
			}
		foreach (inc; included)
			if (n == inc || n.startsWith(inc ~ ".")) {
				include = true;
				break;
			}
		if (include) {
			auto doc = filterProt(m, Json.undefined, Json.undefined, m);
			if (doc.type != Json.Type.undefined)
				dst ~= doc;
                }
	}

	writefln("Writing filtered docs...");
	auto buf = appender!string();
	writePrettyJsonString(buf, Json(dst));
	std.file.write(args[2], buf.data());

	return 0;
}

// from ddox
private string extractUnittestSourceCode(Json decl, Json mod)
{
	auto filename = mod["file"].get!string();
	enforce("line" in decl && "endline" in decl, "Missing line/endline fields.");
	auto from = decl["line"].get!long;
	auto to = decl["endline"].get!long;

	// read the matching lines out of the file
	auto app = appender!string();
	long lc = 1;
	foreach (str; File(filename).byLine) {
		if (lc >= from) {
			app.put(str);
			app.put('\n');
		}
		if (++lc > to) break;
	}
	auto ret = app.data;

	// strip the "unittest { .. }" surroundings
	auto idx = ret.indexOf("unittest");
	enforce(idx >= 0, format("Missing 'unittest' for unit test at %s:%s.", filename, from));
	ret = ret[idx .. $];

	idx = ret.indexOf("{");
	enforce(idx >= 0, format("Missing opening '{' for unit test at %s:%s.", filename, from));
	ret = ret[idx+1 .. $];

	idx = ret.lastIndexOf("}");
	enforce(idx >= 0, format("Missing closing '}' for unit test at %s:%s.", filename, from));
	ret = ret[0 .. idx];

	// unindent lines according to the indentation of the first line
	app = appender!string();
	string indent;
	foreach (i, ln; ret.splitLines) {
		if (i == 1) {
			foreach (j; 0 .. ln.length)
				if (ln[j] != ' ' && ln[j] != '\t') {
					indent = ln[0 .. j];
					break;
				}
		}
		if (i > 0 || ln.strip.length > 0) {
			size_t j = 0;
			while (j < indent.length && !ln.empty) {
				if (ln.front != indent[j]) break;
				ln.popFront();
				j++;
			}
			app.put(ln);
			app.put('\n');
		}
	}
	return app.data;
}
