module app;

import ddox.main;
import std.getopt;
import std.process;
import vibe.core.log;

int main(string[] args)
{
	string git_target = "master";
	getopt(args, std.getopt.config.passThrough,
		"git-target", &git_target);
	environment["GIT_TARGET"] = git_target;
	setPlainLogging(true);
	return ddoxMain(args);
}
