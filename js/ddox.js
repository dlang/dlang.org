function getParameterByName(name, url) {
		if (!url) url = window.location.href;
		name = name.replace(/[\[\]]/g, "\\$&");
		var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
				results = regex.exec(url);
		if (!results) return '';
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function setupDdox()
{
	$(".tree-view").children(".package").click(toggleTree);
	$(".tree-view.collapsed").children("ul").hide();
	$("#symbolSearch").attr("tabindex", "1000");

	updateSearchBox();
	$('#sitesearch').change(updateSearchBox);

	var searchParam = getParameterByName("q");
	if (searchParam.length > 0) {
		$("#symbolSearch").val(searchParam)
		performSymbolSearch(40);
	}
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

var closeButton = undefined;

function performSymbolSearch(maxlen)
{
	if (maxlen === 'undefined') maxlen = 26;

	var searchstring = $("#symbolSearch").val().toLowerCase();

	if (searchstring.length === 0) {
		$('.container').show();
		return;
	}

	if (searchstring == lastSearchString) return;
	lastSearchString = searchstring;

	var scnt = ++searchCounter;
	$('#symbolSearchResultsContainer').hide();
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

	if (closeButton === undefined) {
		console.log("foo");
		closeButton = $("<div id='symbolSearchCloseButton'><i class='fa fa-times big-icon'></i></div>");
		closeButton.on("click", function() {
			$('#symbolSearchResultsContainer').hide();
			$('.container').show();
		});
		$('#symbolSearchResultsContainer').prepend(closeButton);
	}

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

			el.append('<a href="'+symbolSearchRootDir+sym.path+'" title="'+name+'" tabindex="1001">'+shortname+'</a>');
			$('#symbolSearchResults').append(el);
		}

	if (results.length > 100) {
		$('#symbolSearchResults').append("<li>&hellip;"+(results.length-100)+" additional results</li>");
	}

	$('#symbolSearchResults').show();
	$('#symbolSearchResultsContainer').show();
	$('.container').hide();
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
