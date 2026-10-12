/**
Runnable examples functionality.

Replaces <pre class="d_code"> blocks from DDOC example sections with an
interactive form: an editor (CodeMirror), optional stdin/args inputs,
and a Run button that submits to tour.dlang.org.

Copyright: 2012 by Digital Mars
License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0
Authors:   Andrei Alexandrescu, Damian Ziemba
*/

function childMatching(el, selector) {
    for (var i = 0; i < el.children.length; i++) {
        if (el.children[i].matches(selector)) return el.children[i];
    }
    return null;
}
function childrenMatching(el, selector) {
    var out = [];
    for (var i = 0; i < el.children.length; i++) {
        if (el.children[i].matches(selector)) out.push(el.children[i]);
    }
    return out;
}
function isVisible(el) {
    return !!el && getComputedStyle(el).display !== 'none' && el.offsetParent !== null;
}
function setText(el, t) { if (el) el.textContent = t; }
function runReady(fn) {
    if (document.readyState !== 'loading') fn();
    else document.addEventListener('DOMContentLoaded', fn);
}

// compile the examples on the prerelease pages with dmd-nightly
var dmdCompilerBranch = location.href.indexOf("-prerelease/") >= 0 ? "dmd-nightly" : "dmd";

// POST a tour.dlang.org run request and render the result.
// JSON is sent as text/plain to avoid a preflight OPTIONS request; see
// https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS#Preflighted_requests
function runOnTour(data, opts, output, outputTitle) {
    var req = {
        source: data.code,
        // always execute unittests and main for backwards compatibility with examples
        args: "-unittest -main",
        runtimeArgs: "--DRT-testmode=run-main",
        compiler: dmdCompilerBranch,
    };
    if (data.stdin) req.stdin = data.stdin;
    if (data.args) req.args = data.args;
    var body = JSON.stringify(req);
    return fetch("https://tour.dlang.org/api/v1/run", {
        method: 'POST',
        headers: { 'Content-Type': 'text/plain; charset=UTF-8' },
        body: body,
    })
    .then(function(resp) {
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        return resp.json();
    })
    .then(function(res) {
        var success = !(res.errors && res.errors.length > 0);
        if (!success) {
            setText(outputTitle, "Compilation output");
            setText(output, res.output);
        } else {
            setText(outputTitle, "Application output");
            setText(output, res.output || opts.defaultOutput);
        }
    });
}

// wraps a unittest into a runnable script
function wrapIntoMain(code, compile) {
    // dynamically wrap into main if needed
    if (compile || code.indexOf("void main") >= 0 || code.indexOf("int main") >= 0) {
        return code;
    }
    else {
        var codeOut = "void main()\n{\n";
        codeOut += "    import std.stdio: write, writeln, writef, writefln;\n    ";
        codeOut += "#line 1\n";
        codeOut += code.split("\n").join("\n    ");
        codeOut += "\n}";
        return codeOut;
    }
}

runReady(function()
{
    setUpExamples();

    document.querySelectorAll('.runnable-examples').forEach(function(root) {
        var el = childMatching(root, 'pre');
        if (!el) return;

        var stdinNode = childMatching(root, '.runnable-examples-stdin');
        var argsNode = childMatching(root, '.runnable-examples-args');
        var stdin = stdinNode ? stdinNode.textContent : '';
        var args = argsNode ? argsNode.textContent : '';

        if (stdin.length > 0)
        {
            stdin = '<div class="d_code_stdin"><span class="d_code_title">Standard input</span><br>'
                  + '<textarea class="d_code_stdin">'+stdin+'</textarea></div>';
        }
        if (args.length > 0)
        {
            args = '<div class="d_code_args"><span class="d_code_title">Command line arguments</span><br>'
                + '<textarea class="d_code_args">'+args+'</textarea></div>';
        }

        var compile = el.parentNode.hasAttribute('data-compile');
        var runAttrs = 'value="' + (compile ? 'Compile' : 'Run') + '"';
        if (!compile)
            runAttrs += ' title="Note: Wraps code in `main` automatically if `main` is missing'
                + ' & imports std.stdio.write[f][ln]"';
        var orig = el.innerHTML;

        var html =
            '<div class="d_code"><pre class="d_code">'+orig+'</pre></div>'
            + '<div class="d_run_code">'
            + '<textarea class="d_code" style="display: none;"></textarea>'
            + stdin + args
            + '<div class="d_code_output"><span class="d_code_title">Application output</span><br><pre class="d_code_output" readonly>Running...</pre></div>'
            + '<input type="button" class="editButton" value="Edit">'
            + (args.length > 0 ? '<input type="button" class="argsButton" value="Args">' : '')
            + (stdin.length > 0 ? '<input type="button" class="inputButton" value="Input">' : '')
            + '<input type="button" class="runButton" ' + runAttrs + '>'
            + '<input type="button" class="resetButton" value="Reset">'
            + '<input type="button" class="openInEditorButton" value="Open in IDE"></div>';

        var tmp = document.createElement('div');
        tmp.innerHTML = html;
        var parent = el.parentNode;
        while (tmp.firstChild) {
            parent.insertBefore(tmp.firstChild, el);
        }
        parent.removeChild(el);
    });

    document.querySelectorAll('textarea.d_code').forEach(function(ta) {
        if (ta.className !== 'd_code') return; // jQuery's [class=d_code] = exact match
        var parent = ta.parentNode;
        var outputDiv = childMatching(parent, 'div.d_code_output');
        var hasStdin = childrenMatching(parent, '.inputButton').length > 0;
        var hasArgs  = childrenMatching(parent, '.argsButton').length > 0;
        var compile = parent.parentNode.hasAttribute('data-compile');
        setupTextarea(ta, {
          parent: parent,
          outputDiv: outputDiv,
          stdin: hasStdin,
          args: hasArgs,
          compile: compile,
          defaultOutput: "Succeed without output.",
          transformOutput: wrapIntoMain,
        });
    });
});

function setupTextarea(el, opts)
{
    opts = opts || {};
    opts = Object.assign({}, {
        stdin: false,
        args: false,
        transformOutput: function(out) { return out }
    }, opts);

    var parent = opts.parent;
    var outputDiv = opts.outputDiv;
    parent.style.display = 'block';

    var siblingCodeDiv = childMatching(parent.parentNode, 'div.d_code');
    var orgSrc = siblingCodeDiv ? childMatching(siblingCodeDiv, 'pre.d_code') : null;

    var prepareForMain = function() {
        return orgSrc ? orgSrc.textContent + "\n" : "";
    };

    var editor;
    var code; // wrapper element produced by CodeMirror
    function initializeEditor(){
      if (typeof editor !== "undefined") return;
      editor = CodeMirror.fromTextArea(el, {
          lineNumbers: true,
          tabSize: 4,
          indentUnit: 4,
          indentWithTabs: true,
          mode: "text/x-d",
          lineWrapping: true,
          theme: "eclipse",
          readOnly: false,
          matchBrackets: true
      });
      editor.setValue(prepareForMain());
      code = editor.getWrapperElement();
      code.style.display = 'none';
    }

    var height = function(diff) {
        var par = code != null ? code : childMatching(parent.parentNode, 'div.d_code');
        if (!par) return '0px';
        return (parseInt(getComputedStyle(par).height) - diff) + 'px';
    };

    var runBtn = childMatching(parent, '.runButton');
    var editBtn = childMatching(parent, '.editButton');
    var resetBtn = childMatching(parent, '.resetButton');
    var openInEditorBtn = childMatching(parent, '.openInEditorButton');

    var plainSourceCode = childMatching(parent.parentNode, 'div.d_code');

    var output = childMatching(outputDiv, 'pre.d_code_output');
    var outputTitle = childMatching(outputDiv, 'span.d_code_title');
    var argsBtn, argsDiv, argsArea, orgArgs;
    var inputBtn, stdinDiv, stdinArea, orgStdin;
    if (opts.args) {
        argsBtn = childMatching(parent, 'input.argsButton');
        argsDiv = childMatching(parent, 'div.d_code_args');
        argsArea = argsDiv ? childMatching(argsDiv, 'textarea.d_code_args') : null;
        orgArgs = argsArea ? argsArea.value : '';
    }
    if (opts.stdin) {
        inputBtn = childMatching(parent, 'input.inputButton');
        stdinDiv = childMatching(parent, 'div.d_code_stdin');
        stdinArea = stdinDiv ? childMatching(stdinDiv, 'textarea.d_code_stdin') : null;
        orgStdin = stdinArea ? stdinArea.value : '';
    }

    var hideAllWindows = function(optArguments)
    {
        optArguments = optArguments || {};
        if (opts.stdin && stdinDiv) stdinDiv.style.display = 'none';
        if (opts.args && argsDiv) argsDiv.style.display = 'none';
        outputDiv.style.display = 'none';
        if (!optArguments.keepPlainSourceCode && plainSourceCode) {
            plainSourceCode.style.display = 'none';
        }
        if (!optArguments.keepCode && code) {
            code.style.display = 'none';
        }
    };

    if (opts.args && argsBtn) {
        argsBtn.addEventListener('click', function(){
            resetBtn.style.display = 'inline-block';
            if (argsArea) argsArea.style.height = height(31);
            hideAllWindows();
            argsDiv.style.display = 'block';
            if (argsArea) argsArea.focus();
        });
    }

    if (opts.stdin && inputBtn) {
        inputBtn.addEventListener('click', function(){
            resetBtn.style.display = 'inline-block';
            if (stdinArea) stdinArea.style.height = height(31);
            hideAllWindows();
            stdinDiv.style.display = 'block';
            if (stdinArea) stdinArea.focus();
        });
    }

    editBtn.addEventListener('click', function(){
        initializeEditor();
        resetBtn.style.display = 'inline-block';
        hideAllWindows();
        code.style.display = 'block';
        editor.refresh();
        editor.focus();
    });
    resetBtn.addEventListener('click', function(){
        resetBtn.style.display = 'none';
        editor.setValue(prepareForMain());
        if (opts.args && argsArea) argsArea.value = orgArgs;
        if (opts.stdin && stdinArea) stdinArea.value = orgStdin;
        hideAllWindows();
        if (plainSourceCode) plainSourceCode.style.display = 'block';
    });
    runBtn.addEventListener('click', function(){
        initializeEditor();
        resetBtn.style.display = 'inline-block';
        runBtn.disabled = true;
        var optArguments = {};
        if (opts.keepCode) {
            optArguments.keepCode = isVisible(code);
            optArguments.keepPlainSourceCode = isVisible(plainSourceCode);
        }
        hideAllWindows(optArguments);
        if (output) output.style.height = opts.outputHeight || height(31);
        outputDiv.style.display = 'block';
        setText(outputTitle, 'Application output');
        if (output) output.innerHTML = 'Running...';
        if (output) output.focus();

        var data = {
            code: opts.transformOutput(editor.getValue(), opts.compile),
            stdin: opts.stdin && stdinArea ? stdinArea.value : "",
            args: opts.args && argsArea ? argsArea.value : "",
        };
        runOnTour(data, opts, output, outputTitle)
            .catch(function(err) {
                if (output) output.innerHTML = 'Temporarily unavailable';
                console.log(String(err));
            })
            .then(function() { runBtn.disabled = false; });
    });
    openInEditorBtn.addEventListener('click', function(){
        var text = (editor && editor.getValue()) || prepareForMain();
        var url = "https://run.dlang.io?compiler=" + dmdCompilerBranch + "&args=-unittest&source=" + encodeURIComponent(opts.transformOutput(text));
        window.open(url, "_blank");
    });
    return editor;
}


function setUpExamples()
{
    /* Sets up expandable example boxes.
     * max-height and CSS transitions are used to animate the closing and opening for smooth animations even on less powerful devices
     */
    document.querySelectorAll('.example-box').forEach(function(box) {
        var boxId = box.id;
        var control = document.getElementById(boxId + '-control');
        if (!control) return;
        control.setAttribute('aria-controls', boxId);
        var showLabel = '<span>Show example <i class="fa fa-caret-down"></i></span>';
        var hideLabel = '<span>Hide example <i class="fa fa-caret-up"></i></span>';
        function toggle() {
            if (box.getAttribute('aria-hidden') === 'true') {
                box.setAttribute('aria-hidden', 'false');
                control.setAttribute('aria-expanded', 'true');
                control.innerHTML = hideLabel;
                box.style.maxHeight = box.scrollHeight + 'px';
            } else {
                box.setAttribute('aria-hidden', 'true');
                control.setAttribute('aria-expanded', 'false');
                control.innerHTML = showLabel;
                box.style.maxHeight = '0';
            }
            return false;
        }
        control.addEventListener('click', function(e) { toggle(); e.preventDefault(); });
        toggle();
    });
    // NB: href needed for browsers to include the controls in the (keyboard) tab order
    document.querySelectorAll('.example-control').forEach(function(c) {
        c.setAttribute('href', '#');
    });
}
