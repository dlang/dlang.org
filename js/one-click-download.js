(function() {
    var platform = navigator.platform.toLowerCase();

    var Arch = {unknown: "unknown", x86: "x86", x86_64: "x86_64"};
        // poor man's enum
    var arch = Arch.unknown;
    if (platform.match('x86_64|amd64'))
    {
        arch = Arch.x86_64;
    }
    else if (platform.match('i.86'))
    {
        arch = Arch.x86;
    }

    var name = '';
    var file = '';

    if (platform.match('win'))
    {
        name = 'Windows';
        file = 'dmd-' + LATEST + '.exe';
    }
    else if (platform.match('mac'))
    {
        name = 'OS X';
        file = 'dmd.' + LATEST + '.dmg';
    }
    else if (platform.match('linux'))
    {
        name = 'Linux';
        file = 'dmd.' + LATEST + '.linux.tar.xz';

        // See if the linux distribution is one for which we have a special package.
        var ua = navigator.userAgent.toLowerCase();
        if (ua.match('ubuntu|debian'))
        {
            if (arch === Arch.x86)
            {
                name = 'Ubuntu/Debian i386';
                file = 'dmd_' + LATEST + '-0_i386.deb';
            }
            else if (arch == Arch.x86_64)
            {
                name = 'Ubuntu/Debian x86_64';
                file = 'dmd_' + LATEST + '-0_amd64.deb';
            }
        }
        else if (ua.match('fedora|centos'))
        {
            if (arch === Arch.x86)
            {
                name = 'Fedora/CentOS i386';
                file = 'dmd-' + LATEST + '-0.fedora.i386.rpm';
            }
            else if (arch == Arch.x86_64)
            {
                name = 'Fedora/CentOS x86_64';
                file = 'dmd-' + LATEST + '-0.fedora.x86_64.rpm';
            }
        }
        else if (ua.match('suse'))
        {
            if (arch === Arch.x86)
            {
                name = 'openSUSE i386';
                file = 'dmd-' + LATEST + '-0.openSUSE.i386.rpm';
            }
            else if (arch == Arch.x86_64)
            {
                name = 'openSUSE x86_64';
                file = 'dmd-' + LATEST + '-0.openSUSE.x86_64.rpm';
            }
        }
    }
    else if (platform.match('freebsd'))
    {
        if (arch === Arch.x86)
        {
            name = 'FreeBSD i386';
            file = 'dmd.' + LATEST + '.freebsd-32.tar.xz';
        }
        else if (arch == Arch.x86_64)
        {
            name = 'FreeBSD x86_64';
            file = 'dmd.' + LATEST + '.freebsd-64.tar.xz';
        }
    }

    if (file !== "")
    {
        var url = 'http://downloads.dlang.org/releases/2.x/' + LATEST  + '/' +
            file;
        $('.notice.download a.download').attr('href', url);
        $('.notice.download a.download').append(' for ' + name);
        $('.notice.download')
            .append(' &middot; ')
            .append($('<a>')
                .attr('href', 'download.html')
                .text('Other Downloads'));
    }
})();
