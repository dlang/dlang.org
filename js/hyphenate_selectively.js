// We need to enable hyphenation only on Chrome and Firefox - the others have bugs
var re = /(Chrome|Gecko)/;
if (re.test(navigator.userAgent)) {
    document.write('<script src="/js/hyphenate.js" type="text/javascript"></script>');
}
