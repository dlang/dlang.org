Ddoc

$(DIV class="center-children",
$(D_S $(TITLE),

$(HTMLTAG3 img, src="$(STATIC images/dman-scared.jpg)")

$(P
If you think there should be something here, please $(LINK2 $(BUGZILLA_NEW_BUG_URL)$(AMP)bug_severity=normal, report a bug).
)))
$(RED Some text here)
Macros:
    TITLE=Oh No! Page Not Found
    EXTRA_HEADERS=$(T style,
        .center-children, h1 { text-align: center; }
        img { max-width: 100%; }
    )
