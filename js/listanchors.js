/**
Generates 'Jump to' links.

Copyright: 1999-2014 by Digital Mars

License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0

Authors:   Andrei Alexandrescu, Nick Treleaven
*/

/* Symbol definition */
var lastSymbolDefined = '';
var values = [];
//
function lastName(a) {
    var pos = a.lastIndexOf('.');
    return a.slice(pos + 1);
}
//
function defineSymbol(sym) {
  // ignore ditto overloads
  if (sym == lastSymbolDefined) return;
  // ignore foo.bar, foo.bar.2, but show foo, foo.2
  var pos = sym.indexOf('.');
  if (pos >= 0 && (sym.lastIndexOf('.') != pos || isNaN(lastName(sym)))) return;
  lastSymbolDefined = sym;
  values.push(sym);
}
//
function listanchors()
{
    if (typeof inhibitQuickIndex !== 'undefined') return;
    var a = document.getElementById("quickindex");
    if (!a) return;

    values.sort();

    var newText = "";
    for (var i = 0; i < values.length; i++) {
        var a = values[i];
        var text = a;
        if (i != 0) newText += " &middot;"; 
        newText += ' <a class="jumpto" href="#.' + a +
            '"><span class="notranslate donthyphenate">' + text + '</span></a>';
    }
    values = null; // unreference memory
    if (newText != "") newText = "<p><b>Jump to:</b>" + newText + "</p>";
    var a = document.getElementById("quickindex");
    a.innerHTML = newText;
}
