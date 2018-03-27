#!/usr/bin/env rdmd
/*
 * Extracts the newest articles from dlang.org's XML site and
 * converts them to Ddoc macros.
 *
 * Copyright (C) 2018 by D Language Foundation
 *
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE_1_0.txt or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
*/
// Written in the D programming language.

import std.format : format;
import std.datetime;

// crude representation of an article at the DBlog
struct Article
{
    string title;
    string link;
    SysTime date;
    string author;
}

auto toDdoc(const ref Article article, string suffix)
{
    import std.xml : encode;
    string text;
with(article)
{
    auto prettyMonth = ["January", "February", "March", "April", "May", "June", "July",
        "August", "September", "October", "November", "December"][date.month - 1];
    auto prettyDate = "%s %d, %d".format(prettyMonth, date.day, date.year);
    text =
`DBLOG_LATEST_TITLE%5$s=%1$s
DBLOG_LATEST_LINK%5$s=%2$s
DBLOG_LATEST_DATE%5$s=%3$s
DBLOG_LATEST_AUTHOR%5$s=%4$s`.format(title.encode, link, prettyDate, author.encode, suffix);
}
    return text;
}

int main(string[] args)
{
    import std.algorithm, std.exception, std.file, std.getopt, std.range, std.stdio, std.xml;

    string inputFile, outputFile;
    auto help = getopt(args,
        config.required,
        "i|input", &inputFile,
        config.required,
        "o|output", &outputFile,
    );
    if (help.helpWanted || !inputFile.exists)
    {
        defaultGetoptPrinter("./dblog_xml_extractor", help.options);
        return 1;
    }

    auto text = inputFile.readText;

    Article[] articles;

    // check and parse XML
    text.check;
    auto doc = new DocumentParser(text);
    doc.onStartTag["item"] = (ElementParser xml)
    {
        Article article;
        scope(exit)
        {
            xml.parse;
            articles ~= article;
        }

        xml.onEndTag["title"] = (const Element e) { article.title = e.text; };
        xml.onEndTag["link"] = (const Element e) { article.link = e.text; };

        // <pubDate>Wed, 07 Feb 2018 13:07:26 +0000</pubDate>
        // -> Wed, 07 Feb 2018
        xml.onEndTag["pubDate"] = (const Element e) { article.date = e.text.parseRFC822DateTime; };

        // ugly std.xml way to extract CData
        string lastCData;
        xml.onEndTag["dc:creator"] = (const Element e) {
            article.author = lastCData;
        };
        xml.onCData = (string s){
            lastCData = s;
        };
    };
    doc.parse;

    // output the latest two article in Ddoc
    with(File(outputFile, "w"))
    foreach (i, el; articles.take(2).enumerate(1))
        writeln(el.toDdoc("_%s".format(i)));

    return 0;
}
