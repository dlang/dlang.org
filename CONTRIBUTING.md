How to Fork and Build `dlang.org`
--

This guide is for Posix users (Unix variants, OSX).

Make sure you have these prerequisites working:

* A github account
* The `git` command line utility
* The `make` utility (GNU version)
* The C++ compiler for your platform (invokable as `gcc`)
* Optional: `kindlegen` for building the Kindle documentation

## Getting the code

If you already have a [working directory for the D language](https://wiki.dlang.org/Building_under_Posix#Fetch_repositories_from_GitHub),
e.g. `~/dlang`, change to it.

To get the code, run:

```
git clone https://github.com/dlang/dlang.org
cd dlang.org
```

The remainder of this document assumes that is your current working directory.

## Building the main site

To build the main site, run:

```
make -f posix.mak html
```

This builds the `dmd` compiler itself first and then uses it to build the
website pages. You may see warnings while the compiler is built. After `make`
ends with error code 0, directory `web` should contain the produced HTML
files. Take a moment to open `web/index.html` in a browser.

## Building the standard library documentation

Now that the main site is in place, the standard library documentation would be
a good next step.

There is a small complicating factor: the standard library has two versions to
build. One is the "release" version, i.e. the library for the currently released
version of D. The other is the "prerelease" version, i.e. the library that is
currently being worked on. The "release" version is built with the "release"
compiler, and the current version is built with the current compiler (which we
already have from the previous step).

### Building the `prerelease` libraries

The more interesting stuff to build is the prerelease libraries because in all
likelihood that's what needs looking at and testing.

```
make -f posix.mak docs-prerelease
```

If you only want to build a specific part (e.g. Phobos), run:

```
make -f posix.mak phobos-prerelease
```

(`docs-prerelease` is a shorthand for `dmd-prerelease`, `druntime-prerelease`, `phobos-releas` and `apidocs-prerelease`)

The output is in `web/phobos-prerelease` and `library-prerelease`.

### Building the `latest` release libraries

Fortunately there's no need to fumble with version numbers and git tags etc.;
all is automated. Run this command:

```
make -f posix.mak docs-latest
```

If you only want to build a specific part (e.g. Phobos), run:

```
make -f posix.mak phobos-latest
```

(`docs-latest` is a shorthand for `dmd-latest`, `druntime-latest`, `phobos-latest` and `apidocs-latest`)

These commands tell you the release being built in their first line of output.
Then they proceed and clone the appropriate release for `dmd`, `druntime`, and
`phobos`. After all commands have been executed, the following directories will
be present in `$R`: `dlang.org`, `dmd`, `dmd-2.083.2`, `druntime-2.083.2`, and
`phobos-2.083.2`. Note that the actual release number may not be `2.083.2`, but
should be the same for all three directories.

The output is in `web/phobos` and `web/library`.

### Avoid building dmd

By default, the dlang.org build downloads a stable DMD compiler which is used to build the documentation pages.
If you prefer to use an installed `dmd` binary, set `STABLE_DMD` and `STABLE_DMD_CONF`:

```
make -f posix.mak html -j4 STABLE_DMD=dmd STABLE_DMD_CONF=/etc/dmd.conf
```

### Learning more about DDoc

Please see the [Ddoc fundamentals](https://wiki.dlang.org/Contributing_to_dlang.org).
