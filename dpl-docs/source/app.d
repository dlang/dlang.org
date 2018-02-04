module app;

import ddox_main;
import std.getopt;
import std.process;
import vibe.core.log;

bool noExactSourceCodeLinks;

int main(string[] args)
{
	string git_target = "master";
	getopt(args, std.getopt.config.passThrough,
		"git-target", &git_target,
		"no-exact-source-links", &noExactSourceCodeLinks);
	environment["GIT_TARGET"] = git_target;
	environment["NO_EXACT_SOURCE_CODE_LINKS"] = noExactSourceCodeLinks ? "1" : "0";
	setLogFormat(FileLogger.Format.plain);
	if (args.length > 1 && args[1] != "filter")
	    args ~= "--html-style=pretty";
	return ddoxMain(args);
}
