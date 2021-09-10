#!/usr/bin/env rdmd
/**
 * Copyright: Martin Nowak 2015-.
 * License: $(HTTP boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: $(HTTP code.dawg.eu, Martin Nowak)
 */
import std.algorithm, std.exception, std.file, std.getopt, std.path, std.range, std.stdio, std.string, std.typecons;

alias I(alias X) = X;

int main(string[] args)
{
    string[] excludes, packages, internal;

    auto prog = getopt(args,
        "ex", &excludes,
        "dump", &packages, // specifies order and inclusions (negations of exclusions)
        "internal", &internal,
    );

    if (prog.helpWanted || args.length <= 1)
    {
        defaultGetoptPrinter("./modlist <dir1> <dir2> ... <dirN>", prog.options);
        return 64; // EX_USAGE
    }

    auto dirs = args[1 .. $];

    static struct Tree
    {
        bool exists;
        Tree[string] children;
    }
    Tree root;

    foreach (dir; dirs)
    {
        dirEntries(dir, "*.d", SpanMode.depth)
            .filter!(de => de.isFile)
            .map!(de => de.name.chompPrefix(dir).chompPrefix(dirSeparator)) // relative to path
            .map!(n => n.chomp(".d").replace(dirSeparator, ".")) // std/digest/sha.d => std.digest.sha
            .each!(mod => mod // convert to prefix tree
                .chomp(".package")
                .splitter(".")
                .fold!((subtree, name) => &subtree.children.require(name))(&root)
                .exists = true
            );
    }

    static struct TreeWriter
    {
        private string[] lastPackage;
        private bool firstChild = true;

        private void needPackage(string[] pkg)
        {
            while (!pkg.startsWith(lastPackage))
            {
                lastPackage = lastPackage[0 .. $-1];
                if (lastPackage.length == 0) // top-level
                {
                    writeln("\n)");
                    writeln("$(MENU_W_SUBMENU_END)");
                }
                else
                    writef("\n%s)", indent(lastPackage.length));
            }
            while (lastPackage.length < pkg.length)
            {
                lastPackage = pkg[0 .. lastPackage.length + 1];
                if (lastPackage.length == 1) // top-level
                {
                    writeln();
                    writefln("$(MENU_W_SUBMENU %s)", lastPackage[0]);
                    writef("$(ITEMIZE");
                }
                else
                    writef("%s\n%s$(PACKAGE $(PACKAGE_NAME %s),",
                        firstChild ? "" : ",", indent(lastPackage.length - 1), lastPackage[$-1]);
                firstChild = true;
            }
        }

        void put(string[] mod, bool hasChildren)
        {
            needPackage(mod[0 .. $-1]);
            writef("%s\n", firstChild ? "" : ",");
            firstChild = false;
            if (hasChildren)
            {
                writef("%s$(PACKAGE $(MODULE%s %-(%s, %))",
                    indent(mod.length - 1), mod.length, mod);
                lastPackage = mod;
            }
            else if (mod.length == 1) // top-level
                writefln("$(MENU %s.html, $(TT %1$s))", mod[0]);
            else
                writef("%s$(MODULE%s %-(%s, %))",
                    indent(mod.length - 1), mod.length, mod);
        }

        private static string indent(size_t len)
        {
            static immutable spaces = "                    ";
            return spaces[0 .. 2 * len];
        }

        @disable this(this);
        ~this() { needPackage(null); }
    }

    auto includedSet = packages.map!(pkg => tuple(pkg.split(".").assumeUnique, true)).assocArray;
    auto excludedSet = excludes.map!(pkg => tuple(pkg.split(".").assumeUnique, true)).assocArray;
    auto internalSet = internal.map!(pkg => tuple(pkg.split(".").assumeUnique, true)).assocArray;

    writeln("MODULE_MENU=");

    foreach (dumpingInternal; [false, true])
    {
        if (dumpingInternal)
            writeln("$(MENU_INTERNAL_SEPARATOR)");

        foreach (pkg; packages)
        {
            Tree modules; // filtered copy of tree

            void scan(ref Tree tree, string[] mod, bool inInternal, bool inIncluded)
            {
                inInternal = inInternal || mod in internalSet;
                inIncluded = mod in includedSet ? true : mod in excludedSet ? false : inIncluded;
                if (tree.exists && inInternal == dumpingInternal && inIncluded)
                    if (mod.length > 1 || !tree.children) // std/package.d is currently unreachable!
                        mod.fold!((subtree, name) => &subtree.children.require(name))(&modules).exists = true;
                foreach (child; tree.children.keys.sort)
                    scan(tree.children[child], mod ~ child, inInternal, inIncluded);
            }

            TreeWriter writer;
            void dump(ref Tree tree, string[] mod)
            {
                if (tree.exists)
                    writer.put(mod, tree.children !is null);
                foreach (child; tree.children.keys.sort)
                    dump(tree.children[child], mod ~ child);
            }

            auto subTree = pkg in root.children;
            if (subTree)
            {
                scan(*subTree, [pkg], false, false);
                dump(modules, null);
            }
        }
    }

    writeln("_=");
    return 0;
}
