// CSS hyphens is supported by IE10+, Firefox 6+, and Safari 5.1+ so only
// use hyphenator.js for Chrome where support is still missing completely (as
// of Chrome 29) and Opera (which now uses Chrome's rendering engine Blink).
var re = /(Chrome|Opera)/;
if (re.test(navigator.userAgent)) {
    document.write('<script src="/js/hyphenate.js" type="text/javascript"></script>');
}
