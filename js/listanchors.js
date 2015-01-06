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
  // Note: empty comment avoids ddoc macro definition
  /**/ lastSymbolDefined = sym;
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
        newText += ' \x3Ca class="jumpto" href="\x23.' + a +
            '"\x3E\x3Cspan class="notranslate donthyphenate"\x3E' + text + '\x3C/span\x3E\x3C/a\x3E';
    }
    /**/ values = null; // unreference memory
    if (newText != "") newText = "\x3Cp\x3E\x3Cb\x3EJump to:\x3C/b\x3E" + newText + "\x3C/p\x3E";
    var a = document.getElementById("quickindex");
    a.innerHTML = newText;
}
