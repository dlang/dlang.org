#!/usr/bin/env rdmd
/**
 * Copyright: Martin Nowak 2015-.
 * License: $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: $(WEB code.dawg.eu, Martin Nowak)
 */
import std.algorithm, std.file, std.path, std.stdio, std.string, std.range;

struct Tree
{
    ref Tree insert(R)(R parts)
    {
        if (parts.front == "package")
        {
            pkgMod = true;
            return this;
        }

        auto tail = leaves.find!((tr, pkg) => tr.name == pkg)(parts.front);
        if (tail.empty)
        {
            leaves ~= Tree(parts.front);
            tail = leaves[$-1 .. $];
        }
        parts.popFront();
        return parts.empty ? this : tail.front.insert(parts);
    }

    void sort()
    {
        leaves = leaves.sort!((a, b) => a.name < b.name).release;
        foreach (ref l; leaves)
            l.sort();
    }

    void dumpRoot()
    {
        writefln("$(MENU_W_SUBMENU $(TT %s))", name);
        writefln("$(ITEMIZE");
        dumpChildren([name]);
        writeln(")");
    }

    void dumpChildren(string[] pkgs)
    {
        foreach (i, ref l; leaves)
        {
            l.dump(pkgs);
            writeln(i + 1 == leaves.length ? "" : ",");
        }
    }

    void dump(string[] pkgs)
    {
        if (leaves.empty)
        {
            writef("%s$(MODULE%s %-(%s, %), %s)", indent(pkgs.length), pkgs.length + 1, pkgs, name);
        }
        else
        {
            if (pkgMod)
                writefln("%s$(PACKAGE $(MODULE%s %-(%s, %), %s),", indent(pkgs.length), pkgs.length + 1, pkgs, name);
            else
                writefln("%s$(PACKAGE $(PACKAGE_NAME %s),", indent(pkgs.length), name);
            dumpChildren(pkgs ~ name);
            writef("%s)", indent(pkgs.length));
        }
    }

    ref Tree opIndex(string part)
    {
        auto tail = leaves.find!((tr, pkg) => tr.name == pkg)(part);
        return tail.front;
    }

    static string indent(size_t len)
    {
        static immutable spaces = "                    ";
        return spaces[0 .. 2 * len];
    }

    string name;
    bool pkgMod;
    Tree[] leaves;
}

int main(string[] args)
{
    if (args.length < 3)
    {
        stderr.writeln("usage: ./modlist <druntime-dir> <phobos-dir> [--ex=std.internal.] [--ex=core.sys.]");
        return 1;
    }

    auto druntime = args[1];
    auto phobos = args[2];
    auto excludes = args[3 .. $].map!(ex => ex.chompPrefix("--ex=")).array;

    bool included(string mod)
    {
        return !excludes.canFind!(e => mod.startsWith(e));
    }

    void add(string path, ref Tree tree)
    {
        auto files = dirEntries(path, "*.d", SpanMode.depth)
            .filter!(de => de.isFile)
            .map!(de => de.name.chompPrefix(path).chompPrefix(dirSeparator)) // relative to path
            .map!(n => n.chomp(".d").replace(dirSeparator, ".")) // std/digest/sha.d => std.digest.sha
            .filter!included;

        foreach (string name; files)
            tree.insert(name.splitter("."));
    }
    Tree tree;
    add(phobos, tree);
    add(buildPath(druntime, "src"), tree);
    tree.sort();

    writeln("MODULE_MENU=");
    writeln("$(MENU object.html, $(TT object))");
    tree["std"].dumpRoot();
    tree["etc"].dumpRoot();
    tree["core"].dumpRoot();
    writeln("_=");
    return 0;
}
