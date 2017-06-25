/**
Picking the frontpage example after the page has loaded leads to reflows
and re-rendering. Hence, we pick the example as soon as possible

Copyright: 1999-2017 by D Language Foundation
License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0
*/

/**
Prepares the DOM layout of a runnable code example.
Sibling nodes for program arguments (.runnable-examples-args)
and stdin (.runnable-examples-stdin) are detected.
The parent node has usually the class runnable-examples.
pre = element containing the code example
*/
function buildRunnableExampleLayout(pre) {
    var parent = pre.parentNode;

    // helper method to construct a button in vanilla JavaScript
    function createButton(className, value) {
        var btn = document.createElement("input");
        btn.type = "button";
        btn.className = className;
        btn.value = value;
        return btn;
    }

    // helper method to construct an overlay in vanilla JavaScript
    // typically overlays are output, args, stdin and the editor instance
    function createOverlay(className, title, type, value) {
        var el = document.createElement("div");
        el.className = className;
        var titleEl = document.createElement("span");
        titleEl.className = "d_code_title";
        titleEl.innerText = title;
        el.appendChild(titleEl);
        el.appendChild(document.createElement("br"));
        var inner = document.createElement(type);
        inner.className = className;
        inner.value = value;
        el.appendChild(inner);
        return el;
    }

    // check whether args has been defined (RUNNABLE_EXAMPLE_ARGS macro in Ddoc)
    var args = findFirst(parent.children, function(e){ return e.className === "runnable-examples-args";});
    if (typeof args !== "undefined") { args = args.innerText; }

    // check whether stdin has been defined (RUNNABLE_EXAMPLE_STDIN macro in Ddoc)
    var stdin = findFirst(parent.children, function(e){ return e.className === "runnable-examples-stdin";});
    if (typeof stdin !== "undefined") { stdin = stdin.innerText; }

    // wraps the <pre> code box in a <div> element
    // this rewrapping is needed for the editor framework
    var dCode = document.createElement("div");
    dCode.className = "d_code";
    dCode.append(pre);

    // create the CodeMirror editor overlay
    var el = document.createElement("div");
    el.style.display = "block";
    el.className = "d_run_code";
    // code box (CodeMirror will be loaded into this element)
    var dCodeText = document.createElement("textarea");
    dCodeText.className = "d_code";
    dCodeText.style.display = "none";
    el.appendChild(dCodeText);

    // create optional stdin overlay
    if (stdin) { el.appendChild(createOverlay("d_code_stdin", "Input", "textarea", stdin)); }

    // create optional args overlay
    if (args) { el.appendChild(createOverlay("d_code_stdin", "Command line arguments", "textarea", args)); }

    // create main output overlay
    el.appendChild(createOverlay("d_code_output", "Application output", "pre", "Running..."));

    // user interaction buttons
    el.appendChild(createButton("editButton", "Edit"));
    if (stdin) { el.appendChild(createButton("inputButton", "Input")); }
    if (args) { el.appendChild(createButton("argsButton", "Args")); }
    el.appendChild(createButton("runButton", "Run"));
    el.appendChild(createButton("resetButton", "Reset"));

    // replace the <pre> element with its enhanced wrapper div
    var root = document.createElement("div");
    root.appendChild(dCode);
    root.appendChild(el);
    parent.appendChild(root);
    return root;
}
/**
Searches any object for the first hit.
Params:
    el = object to filter
    fn = function to be applied as filter
Returns: first hit, `undefined` otherwise
*/
function findFirst(el, fn) {
    return Array.prototype.filter.call(el, fn)[0];
}

(function() {
// randomly pick one example and bootstrap the runnable editor
var examples = document.getElementsByClassName('your-code-here-extra');
var rouletteIndex = Math.floor(Math.random() * examples.length);
var rouletteChild = examples[rouletteIndex];

// step 1: select the .runnable-example <div>
var rouletteChildNode = findFirst(rouletteChild.children, function(e) { return e.className.indexOf("runnable-example") != -1; });
// step 2: select the first <pre> element (of the .runnable-example <div>)
var el = findFirst(rouletteChildNode.children, function(e) { return e.nodeName == "PRE";});
// step 3: Construct runnable example layout within the <pre> element
buildRunnableExampleLayout(el);
rouletteChild.style.display = "block";
})();
