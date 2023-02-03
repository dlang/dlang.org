(function() {
    var script = document.currentScript;
    if (!script) { // polyfill for IE
        var scripts = document.getElementsByTag('script');
        script = scripts[scripts.length - 1]; // depends on synchronous load
    }
    var latest = script.dataset.latest,
        platform = navigator.platform.toLowerCase();

    var model = 64;
    if (platform.match('i.86'))
        model = 32;

    var files;
    if (platform.indexOf('win') != -1)
        files = [{name: 'dmd-' + latest, suffix: '.exe', text: 'Windows Installer'}];
    else if (platform.indexOf('mac') != -1)
        files = [{name: 'dmd.' + latest, suffix: '.dmg', text: 'DMG File'}];
    else if (model == null) // platforms with multiple archs follow
        return;
    else if (platform.indexOf('linux') != -1)
        files = [{name: 'dmd_' + latest + '-0_' + (model == 64 ? 'amd64' : 'i386'), suffix: '.deb', text: 'DEB File'},
                 {name: 'dmd-' + latest + '-0.fedora.' + (model == 64 ? 'x86_64' : 'i386'), suffix: '.rpm', text: 'RPM File'}
        ];
    else if (platform.indexOf('freebsd') != -1)
        files = [{name: 'dmd.' + latest + '.freebsd-' + model.toString(), suffix: '.tar.xz', text: 'Compressed Archive'}];
    else
        return;

    var html = '';
    for (var i = 0; i < files.length; ++i) {
        var f = files[i];
        var url = 'https://downloads.dlang.org/releases/2.x/' + latest + '/' + f.name + f.suffix;
        html += '<a href="' + url + '" class="btn action">Download ' + f.text + '</a>';
    }
    if (files.length > 1) {
        html = '<div class="hbox">' + html + '</div>';
    }

    var btn = $('.download a.btn');
    btn.before(html);
    btn.text('Other Downloads');
})();
