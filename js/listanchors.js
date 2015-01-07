/**
Generates 'Jump to' links.

Copyright: 1999-2014 by Digital Mars

License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0

Authors:   Andrei Alexandrescu, Nick Treleaven
*/

function lastName(a) {
    var pos = a.lastIndexOf('.');
    return a.slice(pos + 1);
}

function listanchors()
{
    var hideTop = (typeof inhibitQuickIndex !== 'undefined');
    var a = document.getElementById("quickindex");
    if (!a) return;

    // build hash of parent anchor names -> array of child anchor names
    var parentNames = [];
    var lastAnchor = '';
    var items = document.getElementsByClassName('quickindex');
    for (var i = 0; i < items.length; i++)
    {
        var text = items[i].id;
        // ignore top-level quickindex
        var pos = text.indexOf('.');
        if (pos < 0) continue;
        // skip 'quickindex'
        text = text.slice(pos);
        // ignore any ditto overloads (which have the same anchor name)
        if (text == lastAnchor) continue;
        lastAnchor = text;
        
        var pos = text.lastIndexOf('.');
        if (hideTop && pos == 0) continue;
        var parent = (pos == 0) ? '' : text.slice(0, pos);
        
        if (!parentNames[parent])
            parentNames[parent] = [text];
        else
            parentNames[parent].push(text);
    }
    // populate quickindex elements
    for (var key in parentNames)
    {
        var arr = parentNames[key];
        // we won't display the qualifying names to save space, so sort by last name
        arr.sort(function(a,b){
            var aa = lastName(a).toLowerCase();
            var bb = lastName(b).toLowerCase();
            return aa == bb ? 0 : (aa < bb ? -1 : 1);
        });
        var newText = "";
        for (var i = 0; i < arr.length; i++) {
            var a = arr[i];
            var text = lastName(a);
            if (i != 0) newText += " &middot;"; 
            newText += ' <a href="#' + a +
                '">' + text + '</a>';
        }
        if (newText != "")
        {
            newText = '<p><b>Jump to:</b><span class="jumpto notranslate donthyphenate">' +
                newText + '</span></p>';
        }
        var id = 'quickindex';
        id += key;
        var e = document.getElementById(id);
        e.innerHTML = newText;
    }
}
