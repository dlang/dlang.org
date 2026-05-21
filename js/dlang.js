(function() {
    function ready(fn) {
        if (document.readyState !== 'loading') fn();
        else document.addEventListener('DOMContentLoaded', fn);
    }

    function closestMatching(el, selector) {
        while (el && el !== document) {
            if (el.matches && el.matches(selector)) return el;
            el = el.parentNode;
        }
        return null;
    }

    function parentsMatching(el, selector) {
        var result = [];
        var node = el.parentNode;
        while (node && node !== document) {
            if (node.matches && node.matches(selector)) result.push(node);
            node = node.parentNode;
        }
        return result;
    }

    ready(function() {
        if (typeof cssmenu_no_js === 'undefined') {
            // add subnav toggle
            document.querySelectorAll('.subnav').forEach(function(subnav) {
                subnav.classList.add('expand-container');
                var h2 = subnav.querySelector('h2');
                if (h2) {
                    var toggle = h2.cloneNode(true);
                    toggle.classList.add('expand-toggle');
                    subnav.insertBefore(toggle, subnav.firstChild);
                }
            });

            // highlight menu entry of the current page
            var href = window.location.href.split('#')[0];
            var current = null;
            var links = document.querySelectorAll('#top a, .subnav a');
            for (var i = 0; i < links.length; i++) {
                if (links[i].href == href) { current = links[i]; break; }
            }
            if (current) {
                // direct li parent containing the link
                var liParent = closestMatching(current.parentNode, 'li');
                if (liParent) liParent.classList.add('active');
                // topmost li parent, e.g. 'std'
                parentsMatching(current, '#top .expand-container').forEach(function(p) {
                    p.classList.add('active');
                });
                parentsMatching(current, '.subnav .expand-container').forEach(function(p) {
                    p.classList.add('open');
                });
            }

            var open_main_item = null;
            document.querySelectorAll('.expand-toggle').forEach(function(toggle) {
                toggle.addEventListener('click', function(e) {
                    var container = closestMatching(toggle.parentNode, '.expand-container');
                    if (!container) { e.preventDefault(); return false; }
                    container.classList.toggle('open');

                    if (open_main_item !== container && open_main_item !== null) {
                        open_main_item.classList.remove('open');
                    }
                    var clicking_main_bar = parentsMatching(container, '#top').length > 0;
                    var hamburger = document.querySelector('.hamburger');
                    var clicking_hamburger = toggle === hamburger;
                    if (clicking_main_bar && !clicking_hamburger) {
                        open_main_item = container.classList.contains('open') ? container : null;
                    }
                    e.preventDefault();
                    return false;
                });
            });

            document.querySelector('html').addEventListener('click', function(e) {
                var clicking_main_bar = parentsMatching(e.target, '#top').length > 0;
                if (clicking_main_bar) return;
                if (open_main_item !== null) {
                    open_main_item.classList.remove('open');
                }
                open_main_item = null;
            });
        }

        document.querySelectorAll('.search-container .expand-toggle').forEach(function(t) {
            t.addEventListener('click', function() {
                var input = document.querySelector('#search-query input');
                if (input) input.focus();
            });
        });

        // Insert the show/hide button if the contents section exists
        document.querySelectorAll('.page-contents-header').forEach(function(h) {
            var span = document.createElement('span');
            span.innerHTML = '<a href="javascript:void(0);">[hide]</a>';
            h.appendChild(span);
        });

        // Event to hide or show the "contents" section when the hide button is clicked
        document.querySelectorAll('.page-contents-header a').forEach(function(a) {
            a.addEventListener('click', function() {
                var elem = document.querySelector('.page-contents > ol');
                if (!elem) return;
                var visible = elem.offsetParent !== null && elem.style.display !== 'none';
                if (visible) {
                    a.textContent = '[show]';
                    elem.style.display = 'none';
                } else {
                    a.textContent = '[hide]';
                    elem.style.display = '';
                }
            });
        });
    });
})();
