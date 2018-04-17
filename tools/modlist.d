#!/usr/bin/env rdmd
/**
 * Copyright: Martin Nowak 2015-.
 * License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: $(HTTP code.dawg.eu, Martin Nowak)
 */
import std.algorithm, std.file, std.getopt, std.path, std.stdio, std.string, std.range;

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
        writeln();
        writefln("$(MENU_W_SUBMENU %s)", name);
        writefln("$(ITEMIZE");
        dumpChildren([name]);
        writeln(")");
        writeln("$(MENU_W_SUBMENU_END)");
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
        assert(!tail.empty, part ~ " can't be found.");
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

alias I(alias X) = X;

int main(string[] args)
{
    string[] excludes, packages;

    auto prog = getopt(args,
        "ex", &excludes,
        "dump", &packages,
    );

    if (prog.helpWanted || args.length <= 1)
    {
        defaultGetoptPrinter("./modlist <dir1> <dir2> ... <dirN>", prog.options);
        return 1;
    }

    auto dirs = args[1 .. $];

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
    foreach (dir; dirs)
    {
        // search for common root folders (fallback to the root directory)
        ["source", "src", ""]
            .map!(f => buildPath(dir, f))
            .filter!exists
            .front      // no UFCS for local symbols
            .I!(name => add(name, tree));
    }

    tree.sort();

    writeln("MODULE_MENU=");
    foreach (part; packages)
    {
        // check whether it's a package or file
        auto subTree = tree[part];
        if (subTree.leaves.length)
            subTree.dumpRoot;
        else
            writefln("$(MENU %s.html, $(TT %1$s))", part);
    }
    writeln("_=");
    return 0;
}
