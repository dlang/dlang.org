How to Fork and Build `dlang.org`
--

This guide is for Posix users (Unix variants, OSX).

Make sure you have these prerequisites working:

* A github account
* The `git` command line utility
* The `make` utility (GNU version)
* The C++ compiler for your platform (invokable as `gcc`)
* Optional: `latex` for building the pdf documentation
* Optional: `kindlegen` for building the Kindle documentation
* If you're running OSX, make sure you have some version of `libevent` installed

## Getting the code

Create a working directory for the D language, e.g. `~/code/d`. The remainder
of this document calls that directory henceforth `$R` from "Root". To get the
code:

```
cd $R
git clone https://github.com/D-Programming-Language/dlang.org
git clone https://github.com/D-Programming-Language/dmd
```

The `dmd` compiler is needed for processing the documentation.

## Building the main site

Now in `$R` there are two directories called `dmd` and `dlang.org`. To
build the main site, run this:

```
cd $R/dlang.org
make -f posix.mak html
```

This builds the `dmd` compiler itself first and then uses it to build the
website pages. You may see warnings while the compiler is built. After `make`
ended with error code 0, directory `$R/dlang.org/web` contains the produced HTML
files. Take a moment to open `$R/dlang.org/web/index.html` in a browser.

## Building the standard library documentation

Now that the main site is in place, the standard library documentation would be
a good next step.

There is a small complicating factor: the standard library has two versions to
build. One is the "release" version, i.e. the library for the currently released
version of D. The other is the "prerelease" version, i.e. the library that is
currently being worked on. The "release" version is built with the "release"
compiler, and the current version is built with the current compiler (which we
already have from the previous step).

### Building the release libraries

Fortunately there's no need to fumble with version numbers and git tags etc.;
all is automated. Run this command:

```
cd $R/dlang.org
make -f posix.mak druntime-release
make -f posix.mak phobos-release
make -f posix.mak apidocs-release
```

These commands tell you the release being build in their first line of output.
Then they proceed and clone the appropriate release for `dmd`, `druntime`, and
`phobos`. At the end of the command the following directories will be present in
`$R` (actual release number may be different from `2.083.2` but is the same  for
all three directories): `dlang.org`, `dmd`, `dmd-2.083.2`, `druntime-2.083.2`,
and `phobos-2.083.2`.

The output is in `$R/dlang.org/web/phobos` and `$R/dlang.org/web/library`.

### Building the prerelease libraries

The more interesting stuff to build is the prerelease libraries because in all
likelihood that's what need looking at and testing. To do that two more
repositories containing the core and standard libraries are needed: `druntime`
and `phobos`:

```
cd $R
git clone https://github.com/D-Programming-Language/druntime
git clone https://github.com/D-Programming-Language/phobos
```

With the new repos in tow this builds the prerelease libraries:

```
cd $R/dlang.org
make -f posix.mak druntime-prerelease
make -f posix.mak phobos-prerelease
make -f posix.mak apidocs-prerelease
```

The output is in `$R/dlang.org/web/phobos-prerelease` and
`$R/dlang.org/web/library-prerelease`.

To rebuild your changes, simply use:

```
make -f posix.mak all
```
