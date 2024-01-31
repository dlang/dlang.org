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
    return $('.tip.smallprint a[href*="package.d"]').length > 0;
}

$(document).ready(function()
{
    // only for library documentation
    if (!$('body').hasClass("std"))
        return;

    // for index modules (package.d), we want to display all contributors of the package
    var modulePath = document.body.id.replace(/[.]/g, '/');
    if (!isPackage())
       modulePath += '.d';

    // enable only for std, etc and core
    var repo;
    if (modulePath.indexOf("core") == 0 || modulePath.indexOf("object") == 0)
    {
        repo = "dmd";
        modulePath = "druntime/src/" + modulePath;
    }
    else if (modulePath.indexOf("std") == 0 || modulePath.indexOf("etc") == 0)
    {
        repo = "phobos";
    }
    else
    {
        return;
    }

    $.getJSON( "https://contribs.dlang.io/contributors/file/dlang/" + repo + "?file=" + modulePath, function(contributors)
    {

        var posToInsert = $('#copyright');
        var contentNode = $("<div id='contributors-github'></div>");

        var totalContributors = contributors.length;
        // ignore invalid files
        if (totalContributors == 0)
            return;

        contentNode.append("<h3>" + totalContributors + " Contributors</h3>");

        // list contributors with github avatar
        $.each(contributors, function(i, contributor)
        {
            var contributorDiv = '<a href=' + contributor.html_url +' target="_blank">';
            contributorDiv += '<img src="'+ contributor.avatar_url +'&size=40" height="40" width=40" alt="' + contributor.login + '"/>';
            contributorDiv += "</a>";
            contentNode.append(contributorDiv);
        });
        contentNode.insertBefore(posToInsert);
    });
});
