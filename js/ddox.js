function setupDdox()
{
	$(".tree-view").children(".package").click(toggleTree);
	$(".tree-view.collapsed").children("ul").hide();
	$("#symbolSearch").attr("tabindex", "1000");

	updateSearchBox();
	$('#sitesearch').change(updateSearchBox);
}

function updateSearchBox()
{
	var ddox = $('#sitesearch').val() == "dlang.org/library";
	$('#q').toggle(!ddox);
	$('#symbolSearch').toggle(ddox);
}

function toggleTree()
{
	node = $(this).parent();
	node.toggleClass("collapsed");
	if( node.hasClass("collapsed") ){
		node.children("ul").hide();
	} else {
		node.children("ul").show();
	}
	return false;
}

var searchCounter = 0;
var lastSearchString = "";

function performSymbolSearch(maxlen)
{
	if (maxlen === 'undefined') maxlen = 26;

	var el = $("#symbolSearch");
	if (el.length  === 0) el = $("#q");

	var searchstring = el.val().toLowerCase();

	if (searchstring == lastSearchString) return;
	lastSearchString = searchstring;

	var scnt = ++searchCounter;
	$('#symbolSearchResults').hide();
	$('#symbolSearchResults').empty();

	var terms = $.trim(searchstring).split(/\s+/);
	if (terms.length == 0 || (terms.length == 1 && terms[0].length < 2)) return;

	var results = [];
	for (i in symbols) {
		var sym = symbols[i];
		var all_match = true;
		for (j in terms)
			if (sym.name.toLowerCase().indexOf(terms[j]) < 0) {
				all_match = false;
				break;
			}
		if (!all_match) continue;

		results.push(sym);
	}

	function compare(a, b) {
		// prefer non-deprecated matches
		var adep = a.attributes.indexOf("deprecated") >= 0;
		var bdep = b.attributes.indexOf("deprecated") >= 0;
		if (adep != bdep) return adep - bdep;

		// normalize the names
		var aname = a.name.toLowerCase();
		var bname = b.name.toLowerCase();

		var anameparts = aname.split(".");
		var bnameparts = bname.split(".");

		var asname = anameparts[anameparts.length-1];
		var bsname = bnameparts[bnameparts.length-1];

		// prefer exact matches
		var aexact = terms.indexOf(asname) >= 0;
		var bexact = terms.indexOf(bsname) >= 0;
		if (aexact != bexact) return bexact - aexact;

		// prefer elements with less nesting
		if (anameparts.length < bnameparts.length) return -1;
		if (anameparts.length > bnameparts.length) return 1;

		// prefer matches with a shorter name
		if (asname.length < bsname.length) return -1;
		if (asname.length > bsname.length) return 1;

		// sort the rest alphabetically
		if (aname < bname) return -1;
		if (aname > bname) return 1;
		return 0;
	}

	results.sort(compare);

	for (i = 0; i < results.length && i < 100; i++) {
			var sym = results[i];

			var el = $(document.createElement("li"));
			el.addClass(sym.kind);
			for (j in sym.attributes)
				el.addClass(sym.attributes[j]);

			var name = sym.name;

			// compute a length limited representation of the full name
			var nameparts = name.split(".");
			var np = nameparts.length-1;
			var shortname = "." + nameparts[np];
			while (np > 0 && nameparts[np-1].length + shortname.length <= maxlen) {
				np--;
				shortname = "." + nameparts[np] + shortname;
			}
			if (np > 0) shortname = ".." + shortname;
			else shortname = shortname.substr(1);

			if (typeof(symbolSearchRootDir) === "undefined") {
				// translate ddox path into ddoc path -  this is a big messy
				var module = ddoxSymbolToDdocModule(sym);
				var path;
				if (sym.kind === "module") {
					path = module;
				} else {
					var symbol = ddoxSymbolToDdocSymbol(sym);
					path = module + "#" + symbol; // combine module + symbol, e.g. core_atomic.html#testCAS
				}
				el.append('<a href="'+path+'" title="'+name+'" tabindex="1001">'+shortname+'</a>');
			} else {
				el.append('<a href="'+symbolSearchRootDir+sym.path+'" title="'+name+'" tabindex="1001">'+shortname+'</a>');
			}
			$('#symbolSearchResults').append(el);
		}

	if (results.length > 100) {
		$('#symbolSearchResults').append("<li>&hellip;"+(results.length-100)+" additional results</li>");
	}

	$('#symbolSearchResults').show();
}

function ddoxSymbolToDdocModule(sym)
{
	// sym.path: ./core/atomic/test_cas.html
	// ddoc has an individual page for each top-level symbol, so we need to go one level higher to get the actual module name
	if (sym.kind === "module")
		return sym.name.split(".").join("_") + ".html";

	var path = sym.path.slice(0, -5); // strip the html extension from the path, e.g. ./core/atomic/test_cas
	path = path.replace(/(.*)\/(.*)$/g, "$1.html"); // the module is one level higher, e.g. ./core/atomic.html
	path = path.replace(/\//g, "_"); // ddoc uses _ to divide modules, e.g. ._core_atomic.html
	path = path.replace("._", ""); // remove the beginning excess, e.g. core_atomic.html
	return path;
}

function ddoxSymbolToDdocSymbol(sym)
{
	var pathBaseName = sym.path.replace(/.*?([^\/]*)[.]html(.*)/g, "$1$2"); // the basename on the HTML, e.g. socket_option_level.html#IP
	if (sym.path.indexOf("#") >= 0 || pathBaseName.indexOf(".") >= 0) {
		// sym.name: std.socket.SocketOptionLevel.IP, sym.path: "./std/socket/socket_option_level.html#IP -> SocketOptionLevel.IP
		// this is the difficult case where the symbol is nested
		// strategy: take the last two portions of the package name and hope for the best
		var parts = sym.name.split(".").slice(-2);
		if (parts[0] === parts[1]) {
			// an eponymous template
			return parts[0];
		} else {
		return "." + parts.join(".");
		}
	} else {
		// sym.name: core.atomic.testCAS
		return sym.name.replace(/(.*)[.](.*)$/g, "$2") // testCAS
	}
}

$(function(){
  $("#search-box form").on("submit", function(e) {
    var searchResults = $('#symbolSearchResults').children();
    if (searchResults.length > 0) {
      window.location = searchResults.first().find("a").attr("href");
      e.preventDefault();
    }
  });
});
