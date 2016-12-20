/**
 * Run all unittest examples
 *
 * Copyright 2016 by D Language Foundation
 *
 * License: http://boost.org/LICENSE_1_0.txt, Boost License 1.0
 */

// turns asserts into writeln
function reformatExample(code) {
    return code.replace(/(<span class="d_keyword">assert<\/span>\((.*)==(.*)\);)+/g, function(match, text, left, right) {
        return "writeln(" + left.trim() + "); "
            + "<span class='d_comment'>// " + right.trim() + "</span>";
    });
}

// wraps a unittest into a runnable script
function wrapIntoMain(code) {
    var currentPackage = $('body')[0].id;
    var codeOut = "";

    // dynamically wrap into main if needed
    if (code.indexOf("void main") >= 0) {
        codeOut = "import " + currentPackage + "; ";
        codeOut += code;
    }
    else {
        var codeOut = "void main(){ ";
        codeOut += "import " + currentPackage + "; ";
        // writing to the stdout is probably often used
        codeOut += "import std.stdio: write, writeln, writef, writefln; ";
        codeOut += code;
        codeOut += "\n}";
    }
    return codeOut;
}

$(document).ready(function()
{
    if ($('body')[0].id == "Home")
        return;

    // only for std at the moment
    if (!$('body').hasClass("std"))
        return;

    // only enable for pre-release version
    if (location.pathname.indexOf("prerelease") < 0)
        return;

    // ignore not yet compatible modules
    // copied from Phobos posix.mak
    var ignoredModulesList = "allocator/allocator_list.d,allocator/building_blocks/allocator_list.d,allocator/building_blocks/free_list.d,allocator/building_blocks/quantizer,allocator/building_blocks/quantizer,allocator/building_blocks/stats_collector.d,base64.d,bitmanip.d,concurrency.d,conv.d,csv.d,datetime.d,digest/hmac.d,digest/sha.d,file.d,index.d,isemail.d,logger/core.d,logger/nulllogger.d,math.d,ndslice/selection.d,ndslice/slice.d,numeric.d,stdio.d,traits.d,typecons.d,uni.d,utf.d,uuid.d".split(",")
    var currentModulePath = $('body')[0].id.replace('.', '/') + '.d';
    if (ignoredModulesList.filter(function(x) { currentModulePath.indexOf(x) >= 0 }).length > 0) {
        return;
    }

    $('pre[class~=d_code]').each(function(index)
    {
        var currentExample = $(this);
        var orig = currentExample.html();

        orig = reformatExample(orig);

        // check whether it is from a ddoced unittest
        // manual created tests most likely can't be run without modifications
        if (!$(this).parent().parent().prev().hasClass("dlang_runnable"))
            return;

        currentExample.replaceWith(
                '<div>'
                    + '<div class="d_example_buttons">'
                        + '<input type="button" class="editButton" value="Edit">'
                        + '<input type="button" class="runButton" value="Run">'
                        + '<input type="button" class="resetButton" value="Reset">'
                    + '</div>'
                    + '<div class="d_code">'
                        + '<pre class="d_code">'+orig+'</pre>'
                    + '</div>'
                    + '<div class="d_run_code" style="display: block">'
                        + '<textarea class="d_code" style="display: none;"></textarea>'
                    + '</div>'
                    + '<div class="d_code_output"><span class="d_code_title">Application output</span><br><textarea class="d_code_output" readonly>Running...</textarea>'
                + '</div>'
        );
    });

    $('textarea[class=d_code]').each(function(index) {
        var parent = $(this).parent();
        var btnParent = parent.parent().children(".d_example_buttons");
        var outputDiv = parent.parent().children(".d_code_output");
      setupTextarea(this,  {
        parent: btnParent,
        outputDiv: outputDiv,
        stdin: false,
        args: false,
        transformOutput: wrapIntoMain,
        defaultOutput: "All tests passed",
        keepCode: true,
        outputHeight: "auto"
      });
    });
});
