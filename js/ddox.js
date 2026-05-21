function ddoxReady(fn) {
	if (document.readyState !== 'loading') fn();
	else document.addEventListener('DOMContentLoaded', fn);
}

function setupDdox()
{
	document.querySelectorAll('.tree-view').forEach(function(tv) {
		Array.prototype.filter.call(tv.children, function(c) { return c.classList.contains('package'); })
			.forEach(function(pkg) { pkg.addEventListener('click', toggleTree); });
	});
	document.querySelectorAll('.tree-view.collapsed').forEach(function(tv) {
		Array.prototype.filter.call(tv.children, function(c) { return c.tagName === 'UL'; })
			.forEach(function(ul) { ul.style.display = 'none'; });
	});
	var sym = document.getElementById('symbolSearch');
	if (sym) sym.setAttribute('tabindex', '1000');

	updateSearchBox();
	var siteSearch = document.getElementById('sitesearch');
	if (siteSearch) siteSearch.addEventListener('change', updateSearchBox);
}

function updateSearchBox()
{
	var siteSearch = document.getElementById('sitesearch');
	if (!siteSearch) return;
	var ddox = siteSearch.value == "dlang.org/library";
	var q = document.getElementById('q');
	var sym = document.getElementById('symbolSearch');
	if (q) q.style.display = ddox ? 'none' : '';
	if (sym) sym.style.display = ddox ? '' : 'none';
}

function toggleTree()
{
	var node = this.parentNode;
	node.classList.toggle('collapsed');
	var uls = Array.prototype.filter.call(node.children, function(c) { return c.tagName === 'UL'; });
	if (node.classList.contains('collapsed')) {
		uls.forEach(function(ul) { ul.style.display = 'none'; });
	} else {
		uls.forEach(function(ul) { ul.style.display = ''; });
	}
	return false;
}

var searchCounter = 0;
var lastSearchString = "";

function performSymbolSearch(maxlen)
{
	if (maxlen === 'undefined') maxlen = 26;

	var symInput = document.getElementById('symbolSearch');
	if (!symInput) return;
	var searchstring = symInput.value.toLowerCase();

	if (searchstring == lastSearchString) return;
	lastSearchString = searchstring;

	var scnt = ++searchCounter;
	var results_el = document.getElementById('symbolSearchResults');
	if (results_el) {
		results_el.style.display = 'none';
		while (results_el.firstChild) results_el.removeChild(results_el.firstChild);
	}

	var terms = searchstring.replace(/^\s+|\s+$/g, '').split(/\s+/);
	if (terms.length == 0 || (terms.length == 1 && terms[0].length < 2)) return;

	var results = [];
	for (var i in symbols) {
		var sym = symbols[i];
		var all_match = true;
		for (var j in terms)
			if (sym.name.toLowerCase().indexOf(terms[j]) < 0) {
				all_match = false;
				break;
			}
		if (!all_match) continue;

		results.push(sym);
	}

	function compare(a, b) {
		var adep = a.attributes.indexOf("deprecated") >= 0;
		var bdep = b.attributes.indexOf("deprecated") >= 0;
		if (adep != bdep) return adep - bdep;

		var aname = a.name.toLowerCase();
		var bname = b.name.toLowerCase();

		var anameparts = aname.split(".");
		var bnameparts = bname.split(".");

		var asname = anameparts[anameparts.length-1];
		var bsname = bnameparts[bnameparts.length-1];

		var aexact = terms.indexOf(asname) >= 0;
		var bexact = terms.indexOf(bsname) >= 0;
		if (aexact != bexact) return bexact - aexact;

		if (anameparts.length < bnameparts.length) return -1;
		if (anameparts.length > bnameparts.length) return 1;

		if (asname.length < bsname.length) return -1;
		if (asname.length > bsname.length) return 1;

		if (aname < bname) return -1;
		if (aname > bname) return 1;
		return 0;
	}

	results.sort(compare);

	for (var i = 0; i < results.length && i < 100; i++) {
			var sym = results[i];

			var el = document.createElement('li');
			el.classList.add(sym.kind);
			for (var j in sym.attributes)
				el.classList.add(sym.attributes[j]);

			var name = sym.name;

			var nameparts = name.split(".");
			var np = nameparts.length-1;
			var shortname = "." + nameparts[np];
			while (np > 0 && nameparts[np-1].length + shortname.length <= maxlen) {
				np--;
				shortname = "." + nameparts[np] + shortname;
			}
			if (np > 0) shortname = ".." + shortname;
			else shortname = shortname.substr(1);

			var a = document.createElement('a');
			a.href = symbolSearchRootDir + sym.path;
			a.title = name;
			a.setAttribute('tabindex', '1001');
			a.textContent = shortname;
			el.appendChild(a);
			if (results_el) results_el.appendChild(el);
		}

	if (results.length > 100 && results_el) {
		var more = document.createElement('li');
		more.innerHTML = '&hellip;' + (results.length - 100) + ' additional results';
		results_el.appendChild(more);
	}

	if (results_el) results_el.style.display = '';
}

ddoxReady(function(){
  var form = document.querySelector('#search-box form');
  if (!form) return;
  form.addEventListener('submit', function(e) {
    var results_el = document.getElementById('symbolSearchResults');
    if (!results_el) return;
    var first = results_el.firstElementChild;
    if (first) {
      var link = first.querySelector('a');
      if (link) {
        window.location = link.getAttribute('href');
        e.preventDefault();
      }
    }
  });
});
