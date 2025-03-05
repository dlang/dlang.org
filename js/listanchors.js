/**
Generates 'Jump to' links.

Copyright: 1999-2016 by Digital Mars

License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0

Authors:   Andrei Alexandrescu, Nick Treleaven
*/

function lastName(a) {
    var pos = a.lastIndexOf('.');
    return a.slice(pos + 1);
}

// adds a anchor link to every documented declaration
function addAnchors()
{
    var items = document.getElementsByClassName('d_decl');
    if(!items) return;
    for (var i = 0; i < items.length; i++)
    {
        // we link to the first children
        var da = items[i].querySelector('span.def-anchor');
        if(!da) continue;
        var permLink = document.createElement("a");
        permLink.setAttribute('href', '#' + da.id);
        permLink.className = "fa fa-anchor decl_anchor";
        items[i].insertBefore(permLink, items[i].firstChild);
    }
}

// Add a version selector button
function addVersionSelector() {
  // Latest version offered by the archive builds
  // This needs to be manually updated after new versions have been archived
  var currentArchivedVersion = 110;
  // build URLs for dlang.org: DDoc + Dox
  var ddocModuleURL = document.body.id.replace(/[.]/g, "_") + ".html";
  var ddoxModuleURL = document.body.id.replace(/[.]/g, "/") + ".html";
  var root = "phobos/";

  var isSpec = window.location.pathname.indexOf("/spec/") >= 0;
  if (isSpec) {
    root = "spec/";
    var uriParts = window.location.pathname.split("/");
    ddocModuleURL = uriParts[uriParts.length - 1];
    // these versions use a different layout
    var plainSpecVersions = ["2.066", "2.067", "2.068", "2.069"];
  }

  // build list of versions available in the docarchives
  var archivedVersions = [];
  while (currentArchivedVersion >= 66) {
    if (currentArchivedVersion < 100) {
      archivedVersions.push("2.0" + currentArchivedVersion--);
    } else {
      archivedVersions.push("2." + currentArchivedVersion--);
    }
  }
  archivedVersions = archivedVersions.map(function(e) {
      var currentRoot = root;
      if (isSpec && plainSpecVersions.indexOf(e) >= 0) {
        currentRoot = "";
      }
      return {
        name: e,
        url: "https://docarchives.dlang.io/v" + e + ".0/" + currentRoot + ddocModuleURL,
      };
  });

  var onlineVersions;
  if (isSpec) {
    onlineVersions = [{
      name: "master",
      url: "https://dlang.org/spec/" + ddocModuleURL,
    }];
  } else {
    onlineVersions = [{
      name: "master",
      url: "https://dlang.org/phobos-prerelease/" + ddocModuleURL,
    },{
      name: "master (ddox)",
      url: "https://dlang.org/library-prerelease/" + ddoxModuleURL,
    },{
      name: "stable",
      url: "https://dlang.org/phobos/" + ddocModuleURL,
    },{
      name: "stable (ddox)",
      url: "https://dlang.org/library/" + ddoxModuleURL,
    }];
  }

  // set the current URL as selected
  var currentURL = location.href.split(/[#?]/)[0];
  var versions = onlineVersions.concat(archivedVersions);
  versions.forEach(function(v, i) {
    versions[i].selected = v.url === currentURL;
  });
  // Don't show the option chooser if the page hasn't been recognized
  // For example, Ddox symbol pages are currently not supported
  if (versions.filter(function(v){return v.selected}).length === 0)
    return;

  // build select box of all versions and append to current DOM
  var options = versions.map(function(e, i){
    return "<option value='" + i + "'" + (e.selected ? "selected" : "") + ">" + e.name + "</option>";
  });
  $("h1").after("<div class='version-changer-container fa-select'><select id='version-changer'>" + options.join("") + "</select></div>");
  // attach event listener to select box -> change URL
  $("#version-changer").change(function(){
    var selected = parseInt($(this).find("option:selected").val());
    var option = versions[selected];
    if (!option.selected) {
      window.location.href = option.url;
    }
  });
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

    addAnchors();
    addVersionSelector();
}
