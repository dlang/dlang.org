(function($) {
    $(function() {
        if (typeof cssmenu_no_js === 'undefined') {
            // add subnav toggle
            $('.subnav').addClass('expand-container');
            $('.subnav').prepend(
                $('.subnav h2').clone().addClass('expand-toggle')
            );

            // highlight menu entry of the current page
            var href = window.location.href.split('#')[0];
            var current;
            var res = $('#top a, .subnav a').each(function (_, a) {
                if (a.href == href) {
                    current = a;
                    return false;
                }
            });
            current = $(current);
            // direct li parent containing the link
            current.parent('li').addClass('active');
            // topmost li parent, e.g. 'std'
            current.parents('#top .expand-container').addClass('active');
            current.parents('.subnav .expand-container')
                .addClass('open');

            var open_main_item = null;
            $('.expand-toggle').click(function(e) {
                var container = $(this).parent('.expand-container');
                container.toggleClass('open');

                /* In the main menu, let only one dropdown be open at a
                time. Also close any open main menu dropdown when clicking
                elsewhere. */
                if (open_main_item !== container && open_main_item !== null) {
                    open_main_item.removeClass("open");
                }
                var clicking_main_bar = container.parents("#top").length > 0;
                var clicking_hamburger = this === $('.hamburger')[0];
                if (clicking_main_bar && !clicking_hamburger) {
                    open_main_item = container.hasClass('open')
                        ? container : null;
                }
                return false;
            });

            $('html').click(function(e) {
                var clicking_main_bar = $(e.target).parents("#top").length > 0;
                if (clicking_main_bar) return;
                if (open_main_item !== null) {
                    open_main_item.removeClass('open');
                }
                open_main_item = null;
            });
        }

        $('.search-container .expand-toggle').click(function() {
            $('#search-query input').focus();
        });

        // Insert the show/hide button if the contents section exists
        $('.page-contents-header').append('<span><a href="javascript:void(0);">[hide]</a></span>');

        // Event to hide or show the "contents" section when the hide button
        // is clicked
        $(".page-contents-header a").click(function () {
            var elem = $('.page-contents > ol');

            if (elem.is(':visible')) {
                $(this).text("[show]");
                elem.hide();
            } else {
                $(this).text("[hide]");
                elem.show();
            }
        });

      var search = $("#q")
      search.attr("placeholder", "API Search");
      search.attr("autocomplete", "off");
      var onChange = function(){
        performChmgenSearch(80);
      };
      search.on("change", onChange);
      search.on("keypress", onChange);
      search.on("input", onChange);
    });
    jQuery.get("../js/d-tags-prerelease.json", function(d){
      chmgenSymbols = d;
    });
})(jQuery);

var chmgenSymbols = undefined;

function performChmgenSearch(maxlen)
{
  // not loaded yet
  if (!chmgenSymbols) return;
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
	for (var key in chmgenSymbols) {
		var sym = chmgenSymbols[key];
		var all_match = true;
		for (var j in terms)
			if (key.toLowerCase().indexOf(terms[j]) < 0) {
				all_match = false;
				break;
			}
		if (!all_match) continue;

    sym.forEach(function(e){
      results.push({
        name: key,
        href: e,
      });
		});
	}

  console.log(results);

	for (i = 0; i < results.length && i < 100; i++) {
			var sym = results[i];

			var el = $(document.createElement("li"));
			//el.addClass(sym.kind);
			//for (j in sym.attributes)
				//el.addClass(sym.attributes[j]);

			var name = sym.name;
			var shortname = sym.name;
			el.append('<a href="'+sym.href+'" title="'+name+'" tabindex="1001">'+shortname+'</a>');
			$('#symbolSearchResults').append(el);
		}

	if (results.length > 100) {
		$('#symbolSearchResults').append("<li>&hellip;"+(results.length-100)+" additional results</li>");
	}

	$('#symbolSearchResults').show();
}
