/**
 * Run all unittest examples
 *
 * Copyright 2016 by D Language Foundation
 *
 * License: http://boost.org/LICENSE_1_0.txt, Boost License 1.0
 */

// turns asserts into writeln
function reformatExample(code) {
    return code.replace(/(<span class="(?:d_keyword|kwd)">assert<\/span>(?:<span class="pun">)?\((.*)==(.*)\);)+/g, function(match, text, left, right) {
        return "writeln(" + left.trim() + "); "
            + "<span class='d_comment'>// " + right.trim() + "</span>";
    });
}

// wraps a unittest into a runnable script
function wrapIntoMain(code) {
    var currentPackage = document.body.id;
    var codeOut = "";

    // dynamically wrap into main if needed
    if (code.indexOf("void main") >= 0) {
        codeOut = "import " + currentPackage + "; ";
        codeOut += "#line 1\n";
        codeOut += code;
    }
    else {
        codeOut = "void main()\n{\n";
        codeOut += "    import " + currentPackage + ";\n";
        // writing to the stdout is probably often used
        codeOut += (currentPackage == "std.file") ? "    import std.stdio: writeln, writef, writefln;\n    " : "    import std.stdio: write, writeln, writef, writefln;\n    ";
        codeOut += "#line 1\n";
        codeOut += code.split("\n").join("\n    ");
        codeOut += "\n}";
    }
    return codeOut;
}

(function() {
    function ready(fn) {
        if (document.readyState !== 'loading') fn();
        else document.addEventListener('DOMContentLoaded', fn);
    }

    function childMatching(el, selector) {
        for (var i = 0; i < el.children.length; i++) {
            if (el.children[i].matches(selector)) return el.children[i];
        }
        return null;
    }

    ready(function() {
        if (document.body.id == 'Home') return;

        // only for std at the moment
        if (!document.body.classList.contains('std')) return;

        // first selector is for ddoc - second for ddox
        var codeBlocks = document.querySelectorAll('pre.d_code, pre.code');
        codeBlocks.forEach(function(currentExample) {
            var orig = currentExample.innerHTML;

            // disable regex assert -> writeln rewrite logic (for now)
            //orig = reformatExample(orig);

            // check whether it is from a ddoced unittest
            // 1) check is for ddoc, 2) for ddox
            var p1 = currentExample.parentNode && currentExample.parentNode.parentNode;
            var prev1 = p1 ? p1.previousElementSibling : null;
            var prev2 = currentExample.previousElementSibling;
            var lastChildPrev2 = prev2 ? prev2.lastElementChild : null;
            var isRunnable = (prev1 && prev1.classList.contains('dlang_runnable'))
                || (lastChildPrev2 && lastChildPrev2.classList.contains('dlang_runnable'));
            if (!isRunnable) return;

            var html =
                '<div class="unittest_examples">'
                    + '<div class="d_code">'
                        + '<pre class="d_code">'+orig+'</pre>'
                    + '</div>'
                    + '<div class="d_run_code" style="display: block">'
                        + '<textarea class="d_code" style="display: none;"></textarea>'
                    + '</div>'
                    + '<div class="d_example_buttons">'
                        + '<div class="editButton"><i class="fa fa-edit" aria-hidden="true"></i> Edit</div>'
                        + '<div class="runButton"><i class="fa fa-play" aria-hidden="true"></i> Run</div>'
                        + '<div class="resetButton" style="display:none"><i class="fa fa-undo " aria-hidden="true"></i> Reset</div>'
                        + '<div class="openInEditorButton" title="Open in an external editor"><i class="fa fa-external-link" aria-hidden="true"></i>Open in IDE</div>'
                    + '</div>'
                    + '<div class="d_code_output"><span class="d_code_title">Application output</span><br><pre class="d_code_output" readonly>Running...</pre>'
                + '</div>';

            var tmp = document.createElement('div');
            tmp.innerHTML = html;
            var p = currentExample.parentNode;
            while (tmp.firstChild) p.insertBefore(tmp.firstChild, currentExample);
            p.removeChild(currentExample);
        });

        document.querySelectorAll('textarea.d_code').forEach(function(ta) {
            if (ta.className !== 'd_code') return; // exact class match
            var parent = ta.parentNode;
            var btnParent = childMatching(parent.parentNode, '.d_example_buttons');
            var outputDiv = childMatching(parent.parentNode, '.d_code_output');
            setupTextarea(ta, {
                parent: btnParent,
                outputDiv: outputDiv,
                stdin: false,
                args: false,
                transformOutput: wrapIntoMain,
                defaultOutput: "All tests passed",
                keepCode: true,
                outputHeight: "auto",
                backend: "tour"
            });
        });
    });
})();
