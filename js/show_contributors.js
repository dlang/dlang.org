/**
Shows a list of the contributors to a Phobos module
It queries the backend contribs.dlang.io
Backend source: https://github.com/wilzbach/phobos-contribs

License:   http://boost.org/LICENSE_1_0.txt, Boost License 1.0

Authors:   Sebastian Wilzbach
*/

// find out whether the current page is a module or package
function isPackage()
{
    return document.querySelectorAll('.tip.smallprint a[href*="package.d"]').length > 0;
}

(function() {
    function ready(fn) {
        if (document.readyState !== 'loading') fn();
        else document.addEventListener('DOMContentLoaded', fn);
    }

    ready(function() {
        // only for library documentation
        if (!document.body.classList.contains("std")) return;

        // for index modules (package.d), display all contributors of the package
        var modulePath = document.body.id.replace(/[.]/g, '/');
        if (!isPackage()) modulePath += '.d';

        // enable only for std, etc and core
        var repo;
        if (modulePath.indexOf("core") == 0 || modulePath.indexOf("object") == 0) {
            repo = "dmd";
            modulePath = "druntime/src/" + modulePath;
        } else if (modulePath.indexOf("std") == 0 || modulePath.indexOf("etc") == 0) {
            repo = "phobos";
        } else {
            return;
        }

        fetch("https://contribs.dlang.io/contributors/file/dlang/" + repo + "?file=" + modulePath)
            .then(function(resp) { return resp.json(); })
            .then(function(contributors) {
                var posToInsert = document.getElementById('copyright');
                if (!posToInsert) return;
                var contentNode = document.createElement('div');
                contentNode.id = 'contributors-github';

                var totalContributors = contributors.length;
                if (totalContributors == 0) return;

                var h3 = document.createElement('h3');
                h3.textContent = totalContributors + ' Contributors';
                contentNode.appendChild(h3);

                contributors.forEach(function(contributor) {
                    var a = document.createElement('a');
                    a.href = contributor.html_url;
                    a.target = '_blank';
                    var img = document.createElement('img');
                    img.src = contributor.avatar_url + '&size=40';
                    img.height = 40;
                    img.width = 40;
                    img.alt = contributor.login;
                    a.appendChild(img);
                    contentNode.appendChild(a);
                });
                posToInsert.parentNode.insertBefore(contentNode, posToInsert);
            })
            .catch(function() { /* silent */ });
    });
})();
