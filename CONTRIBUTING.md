Guidelines for Contributing
===========================

Welcome to the D community and thanks for your interest in contributing!

# [How to contribute pull requests?](http://wiki.dlang.org/Pull_Requests)

# More Links

* Fork [on Github](https://github.com/D-Programming-Language/dlang.org)
* Use our [Bugzilla bug tracker](https://issues.dlang.org/)
* Follow the [Styleguide](http://dlang.org/dstyle.html)
* Participate in [our forum](http://forum.dlang.org/)
* [Review Queue](http://wiki.dlang.org/Review_Queue).


Tips for Development
--------------------

Use the makefiles (either `posix.mak` or `win32.mak` based on your platform) to
build the HTML files. Example invocations:

    # Rebuild only the expression.html page
    $ make -f win32.mak expression.html

    # Build all the documentation
    $ make -f win32.mak

The above instructions assume you have cloned DMD, druntime, and other repositories along with dlang.org.  As an alternative, the following command will compile a single ddoc file to html

    # Rebuild only the expression.html page
    dmd -c -o- macros.ddoc doc.ddoc -Dfexpression.html expression.dd
