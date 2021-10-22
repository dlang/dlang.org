# dlang.org Makefile
# ==================
#
#  This Makefile is used to build the dlang.org website.
#  To build the entire dlang.org website run:
#
#   make -f posix.mak all
#
#  Build flavors
#  -------------
#
#  This makefile supports 3 flavors of documentation:
#
#   latest          Latest released version (by git tag)
#   prerelease      Master (uses the D repositories as they exist locally)
#   release         Documentation build that is shipped with the binary release
#
#  For `release` the LATEST version is not yet published at build time,
#  hence a few things differ from a `prerelease` build.
#
#  To build `latest` and `prerelease` docs:
#
#      make -f posix.mak all
#
#  To build `release` docs:
#
#      make -f posix.mak release
#
#  Individual documentation targets
#  --------------------------------
#
#  The entire documentation can be built with:
#
#      make -f posix.mak docs
#
#  This target is an alias for two targets:
#
#  A) `docs-prerelease` (aka master)
#
#    The respective local repositories are used.
#    This is very useful for testing local changes.
#    Individual targets include:
#
#        dmd-prerelease
#        druntime-prerelease
#        phobos-prerelease
#        apidocs-prerelease      Ddox documentation
#
#  B) `docs-latest` (aka stable)
#
#    Based on the last official release (git tag), the repositories are freshly cloned from GitHub.
#    Individual targets include:
#
#        dmd-latest
#        druntime-latest
#        phobos-latest
#        apidocs-latest          Ddox documentation
#
#  Documentation development Ddox web server
#  -----------------------------------------
#
#  A development Ddox webserver can be started:
#
#      make -f posix.mak apidocs-serve
#
#  This web server will regenerate requested documentation pages on-the-fly
#  and has the additional advantage that it doesn't need to build any
#  documentation pages during its startup.
#
#  Options
#  -------
#
#  Commonly used options include:
#
#       DIFFABLE=1          Removes inclusion of all dynamic content and timestamps
#       CSS_MINIFY=1        Minify the CSS via an online service
#       DOC_OUTPUT_DIR      Folder to build the documentation (default: `web`)
#
#  Other targets
#  -------------
#
#       html                    Builds all HTML files and static content
#       pending_changelog       Collects and assembles the changelog for the next version
#                               (This is based on references Bugzilla issues and files
#                               in the `/changelog` folders)
#       rebase                  Rebase all DLang repos to upstream/master
#       kindle                  Generates the D specification as an ebook (Amazon mobi)
#       verbatim                Copies the Ddoc plaintext files to .verbatim files
#                               (i.e. doesn't run Ddoc on them)
#       rsync                   Publishes the built website to dlang.org
#       test                    Runs several sanity checks
#       clean                   Removes the .generated folder
#       diffable-intermediaries Adds intermediary eBook files to the output, useful for diffing
#       dautotest               Special target called by the DAutoTestCI and deployment
#
#  Ddoc vs. Ddox
#  --------------
#
#  It's a long-lasting effort to transition from the Ddoc documentation build
#  to a Ddox documentation build of the D standard library.
#
#      https://dlang.org/phobos                Stable Ddoc build (`docs-latest`)
#      https://dlang.org/phobos-prerelease     Master Ddoc build (`docs-prerelease`)
#      https://dlang.org/library               Stable Ddox build (`apidocs-latest`)
#      https://dlang.org/library-release       Master Ddox build (`apidocs-prerelease`)
#
#  For more documentation on Ddox, see https://github.com/rejectedsoftware/ddox
#  For more information and current blocking points of the Ddoc -> Ddox tranisition,
#  see https://github.com/dlang/dlang.org/pull/1526
#
#  Assert -> writeln magic
#  -----------------------
#
#  There is a toolchain in place will allows to perform source code transformation.
#  At the moment this is used to beautify the code examples. For example:
#
#      assert(a == b)
#
#  Would be rewritten to:
#
#      writeln(a); // b
#
#  For this local copies of the respective DMD, DRuntime, and Phobos are stored
#  in the build folder `.generated`, s.t. Ddoc can be run on the modified sources.
#
#  See also: https://dlang.org/blog/2017/03/08/editable-and-runnable-doc-examples-on-dlang-org
#
#  Custom DDoc wrapper
#  -------------------
#
#  `ddoc.d` is a wrapper around Ddoc and allows expanding Ddoc macros dynamically
#  before actually running Ddoc.
#  Currently this is used for:
#    - TOC
#    - dynamic TOC generation
#    - GRAMMAR overview generation
#    - CHANGELOG menu generation
#    - assert -> writeln magic
PWD=$(shell pwd)
MAKEFILE=$(firstword $(MAKEFILE_LIST))
SHELL:=/bin/bash

# Latest released version
ifeq (,${LATEST})
 LATEST:=$(shell cat VERSION)
endif

# DLang directories
DMD_DIR=../dmd
PHOBOS_DIR=../phobos
DRUNTIME_DIR=../druntime
TOOLS_DIR=../tools
INSTALLER_DIR=../installer
DUB_DIR=../dub

# Auto-cloning missing directories
$(shell [ ! -d $(DMD_DIR) ] && git clone --depth=1 ${GIT_HOME}/dmd $(DMD_DIR))
include $(DMD_DIR)/src/osmodel.mak

# External binaries
DMD=$(DMD_DIR)/generated/$(OS)/release/$(MODEL)/dmd
PHOBOS_LIB=$(PHOBOS_DIR)/generated/$(OS)/release/$(MODEL)/dmd/libphobos2.a

# External directories
DOC_OUTPUT_DIR:=$(PWD)/web
W:=$(DOC_OUTPUT_DIR)
GIT_HOME=https://github.com/dlang
DPL_DOCS_PATH=dpl-docs
DPL_DOCS=$(DPL_DOCS_PATH)/dpl-docs
REMOTE_DIR=d-programming@digitalmars.com:data
TMP?=/tmp
GENERATED=.generated
G=$(GENERATED)

# Last released versions
DMD_LATEST_DIR=$G/dmd-${LATEST}
DMD_LATEST=$(DMD_LATEST_DIR)/generated/$(OS)/release/$(MODEL)/dmd
DRUNTIME_LATEST_DIR=$G/druntime-${LATEST}
PHOBOS_LATEST_DIR=$G/phobos-${LATEST}

# stable dub and dmd versions used to build dpl-docs
STABLE_DMD_VER=2.088.0
STABLE_DMD_VER_SUFFIX=
STABLE_DMD_VER_PREFIX=
STABLE_DMD_ROOT=$(GENERATED)/stable_dmd-$(STABLE_DMD_VER)$(STABLE_DMD_VER_SUFFIX)
STABLE_DMD_URL=http://downloads.dlang.org/$(STABLE_DMD_VER_PREFIX)releases/2.x/$(STABLE_DMD_VER)/dmd.$(STABLE_DMD_VER)$(STABLE_DMD_VER_SUFFIX).$(OS).zip
STABLE_DMD_BIN_ROOT=$(STABLE_DMD_ROOT)/dmd2/$(OS)/$(if $(filter $(OS),osx),bin,bin$(MODEL))
STABLE_DMD=$(STABLE_DMD_BIN_ROOT)/dmd
STABLE_DMD_CONF=$(STABLE_DMD).conf
STABLE_RDMD=$(STABLE_DMD_BIN_ROOT)/rdmd --compiler=$(STABLE_DMD) -conf=$(STABLE_DMD_CONF)
DUB=$(STABLE_DMD_BIN_ROOT)/dub

# exclude lists
MOD_EXCLUDES_PRERELEASE=$(addprefix --ex=, \
	core.internal core.stdc.config core.sys \
	std.algorithm.internal std.c std.internal std.regex.internal \
	std.digest.digest \
	std.windows.registry etc.linux.memoryerror \
	std.typetuple \
	msvc_dmc msvc_lib \
	dmd.libmach dmd.libmscoff \
	dmd.scanmach dmd.scanmscoff \
	dmd.libmach dmd.libmscoff \
	dmd.scanmach dmd.scanmscoff)

MOD_EXCLUDES_LATEST=$(MOD_EXCLUDES_PRERELEASE)
MOD_EXCLUDES_RELEASE=$(MOD_EXCLUDES_PRERELEASE)

# rdmd must fetch the model, imports, and libs from the specified version
DFLAGS=-m$(MODEL) -I$(DRUNTIME_DIR)/import -I$(PHOBOS_DIR) -L-L$(PHOBOS_DIR)/generated/$(OS)/release/$(MODEL)
RDMD=rdmd --compiler=$(DMD) $(DFLAGS)

# Tools
REBASE=MYBRANCH=`git rev-parse --abbrev-ref HEAD` && \
	git checkout master && \
	git pull --ff-only git@github.com:dlang/$1.git master && \
	git checkout $$MYBRANCH && \
	git rebase master

CHANGE_SUFFIX = \
	for f in `find "$3" -iname '*.$1'`; do \
		mv $$f `dirname $$f`/`basename $$f .$1`.$2 ; \
	done

# Disable all dynamic content that could potentially have an unrelated impact
# on a diff
ifeq (1,$(DIFFABLE))
 NODATETIME := nodatetime.ddoc
 DPL_DOCS_PATH_RUN_FLAGS := --no-exact-source-links
else
 CHANGELOG_VERSION_MASTER := "v${LATEST}..upstream/master"
 CHANGELOG_VERSION_STABLE := "v${LATEST}..upstream/stable"
endif

################################################################################
# Ddoc build variables
################################################################################
DDOC_VARS_LATEST_HTML= \
	DOC_OUTPUT_DIR="$W/phobos" \
	STDDOC="$(addprefix $(PWD)/, $(STD_DDOC_LATEST))" \
	DMD="$(abspath $(DMD_LATEST))" \
	DMD_DIR="$(abspath ${DMD_LATEST_DIR})" \
	DRUNTIME_PATH="$(abspath ${DRUNTIME_LATEST_DIR})" \
	DOCSRC="$(PWD)" \
	VERSION="$(abspath ${DMD_DIR}/VERSION)"

DDOC_VARS_RELEASE_HTML= \
	DOC_OUTPUT_DIR="$W/phobos" \
	STDDOC="$(addprefix $(PWD)/, $(STD_DDOC_RELEASE))" \
	DMD="$(abspath $(DMD))" \
	DMD_DIR="$(abspath ${DMD_DIR})" \
	DRUNTIME_PATH="$(abspath ${DRUNTIME_DIR})" \
	DOCSRC="$(PWD)" \
	VERSION="$(abspath ${DMD_DIR}/VERSION)"

DDOC_VARS_PRERELEASE= \
	DMD="$(abspath ${DMD})" \
	DMD_DIR="$(abspath ${DMD_DIR})" \
	DRUNTIME_PATH="$(abspath ${DRUNTIME_DIR})" \
	DOCSRC="$(PWD)" \
	VERSION="$(abspath $G/changelog/next-version)"

DDOC_VARS_PRERELEASE_HTML=$(DDOC_VARS_PRERELEASE) \
	DOC_OUTPUT_DIR="$W/phobos-prerelease" \
	STDDOC="$(addprefix $(PWD)/, $(STD_DDOC_PRERELEASE))"

DDOC_VARS_PRERELEASE_VERBATIM=$(DDOC_VARS_PRERELEASE) \
	DOC_OUTPUT_DIR="$W/phobos-prerelease-verbatim" \
	STDDOC="$(PWD)/verbatim.ddoc"

DDOCFLAGS=-c -o-

################################################################################
# Ddoc binaries
################################################################################

DDOC_BIN:=$G/ddoc_preprocessor
DDOC_BIN_DMD:=$(DDOC_BIN) --compiler=$(DMD)

################################################################################
# Resources
################################################################################

# Set to 1 in the command line to minify css files
CSS_MINIFY=

IMAGES=favicon.ico images/d002.ico $(filter-out $(wildcard images/*_hq.*) images/dlogo_2015.svg, \
			$(wildcard images/*.jpg images/*.png images/*.svg images/*.gif)) \
		$(wildcard images/ddox/*) \
		$(filter-out $(wildcard images/orgs-using-d/*_hq.*), $(wildcard images/orgs-using-d/*))

JAVASCRIPT=$(addsuffix .js, $(addprefix js/, \
	codemirror-compressed dlang ddox listanchors platform-downloads run \
	run_examples show_contributors jquery-1.7.2.min))

STYLES=$(addsuffix .css, $(addprefix css/, \
	style print codemirror ddox))

################################################################################
# HTML Files
################################################################################

DDOC=$(addsuffix .ddoc, macros html dlang.org doc ${GENERATED}/${LATEST}) $(NODATETIME) $G/dblog_latest.ddoc
STD_DDOC_LATEST=$(addsuffix .ddoc, macros html dlang.org ${GENERATED}/${LATEST} std std_navbar-release ${GENERATED}/modlist-${LATEST}) $(NODATETIME)
STD_DDOC_RELEASE=$(addsuffix .ddoc, macros html dlang.org ${GENERATED}/${LATEST} std std_navbar-release ${GENERATED}/modlist-release) $(NODATETIME)
STD_DDOC_PRERELEASE=$(addsuffix .ddoc, macros html dlang.org ${GENERATED}/${LATEST} std std_navbar-prerelease ${GENERATED}/modlist-prerelease) $(NODATETIME)
SPEC_DDOC=${DDOC} spec/spec.ddoc
CHANGELOG_DDOC=${DDOC} changelog/changelog.ddoc $(NODATETIME)
CHANGELOG_PRE_DDOC=${CHANGELOG_DDOC} changelog/prerelease.ddoc
CHANGELOG_PENDING_DDOC=${CHANGELOG_DDOC} changelog/pending.ddoc

PREMADE=fetch-issue-cnt.php robots.txt .htaccess .dpl_rewrite_map.txt \
		d-keyring.gpg d-keyring.gpg.sig d-security.asc

# Language spec root filenames. They have extension .dd in the source
# and .html in the generated HTML. These are also used for the mobi
# book generation, for which reason the list is sorted by chapter.
SPEC_ROOT=$(addprefix spec/, \
	spec intro lex grammar module declaration type property attribute pragma \
	expression statement arrays hash-map struct class interface enum \
	const3 function operatoroverloading template template-mixin contracts \
	version traits errors unittest garbage float iasm ddoc \
	interfaceToC cpp_interface objc_interface portability entity memory-safe-d \
	abi simd betterc importc ob)
SPEC_DD=$(addsuffix .dd,$(SPEC_ROOT))

CHANGELOG_FILES:=$(basename $(subst _pre.dd,.dd,$(wildcard changelog/*.dd)))
ifneq (1,$(ENABLE_RELEASE))
 CHANGELOG_FILES+=changelog/pending
endif

MAN_PAGE=docs/man/man1/dmd.1

ARTICLE_FILES=$(addprefix articles/, index builtin code_coverage const-faq \
		cpptod ctarguments ctod d-array-article d-floating-point \
		exception-safe faq hijack intro-to-datetime lazy-evaluation \
		migrate-to-shared mixin pretod rationale regular-expression \
		safed templates-revisited variadic-function-templates warnings \
		cppcontracts template-comparison dll-linux \
	)

# Website root filenames. They have extension .dd in the source
# and .html in the generated HTML. Save for the expansion of
# $(SPEC_ROOT), the list is sorted alphabetically.
PAGES_ROOT=$(SPEC_ROOT) 404 acknowledgements areas-of-d-usage $(ARTICLE_FILES) \
	ascii-table bugstats $(CHANGELOG_FILES) calendar community comparison concepts \
	deprecate dmd dmd-freebsd dmd-linux dmd-osx dmd-windows \
	documentation download dstyle forum-template gpg_keys glossary \
	gsoc2011 gsoc2012 gsoc2012-template gsoc2013 gsoc2013-template \
	howto-promote htod index install \
	menu orgs-using-d overview rdmd resources search security tuple wc windbg \
	$(addprefix foundation/, index about donate prman sponsors upb-scholarship)

# The contributors listing is dynamically generated
ifneq (1,$(DIFFABLE))
ifneq (1,$(ENABLE_RELEASE))
 PAGES_ROOT+=foundation/contributors
endif
endif

TARGETS=$(addsuffix .html,$(PAGES_ROOT))

ALL_FILES_BUT_SITEMAP = $(addprefix $W/, $(TARGETS) \
$(PREMADE) $(STYLES) $(IMAGES) $(JAVASCRIPT) $(MAN_PAGE))

ALL_FILES = $(ALL_FILES_BUT_SITEMAP) $W/sitemap.html

################################################################################
# Rulez
################################################################################

all : docs html

ifneq (1,$(ENABLE_RELEASE))
release :
	$(MAKE) -f $(MAKEFILE) ENABLE_RELEASE=1 release
else
release : html dmd-release druntime-release phobos-release d-release.tag
endif

docs-latest: dmd-latest druntime-latest phobos-latest apidocs-latest
docs-prerelease: dmd-prerelease druntime-prerelease phobos-prerelease apidocs-prerelease

docs : docs-latest docs-prerelease

html : $(ALL_FILES) makebook

makebook:
	(cd book && rdmd build.d 6)
html-verbatim: $(addprefix $W/, $(addsuffix .verbatim,$(PAGES_ROOT)))

verbatim : html-verbatim phobos-prerelease-verbatim

kindle : $W/dlangspec.mobi

diffable-intermediaries : $W/dlangspec.html

$W/sitemap.html : $(ALL_FILES_BUT_SITEMAP) $(DMD)
	cp -f sitemap-template.dd $G/sitemap.dd
	(true $(foreach F, $(TARGETS), \
		&& echo \
			"$F	`sed -n 's/<title>\(.*\) - D Programming Language.*<\/title>/\1/'p $W/$F`")) \
		| sort --ignore-case --key=2 | sed 's/^\([^	]*\)	\([^\n\r]*\)/<a href="\1">\2<\/a><br>/' >> $G/sitemap.dd
	$(DMD) -conf= $(DDOCFLAGS) -Df$@ $(DDOC) $G/sitemap.dd
	rm $G/sitemap.dd

${GENERATED}/${LATEST}.ddoc :
	mkdir -p $(dir $@)
	echo "LATEST=${LATEST}" >$@

${GENERATED}/modlist-${LATEST}.ddoc : tools/modlist.d ${STABLE_DMD} $(DRUNTIME_LATEST_DIR) $(PHOBOS_LATEST_DIR) $(DMD_LATEST_DIR)
	mkdir -p $(dir $@)
	$(STABLE_RDMD) $< $(DRUNTIME_LATEST_DIR)/src $(PHOBOS_LATEST_DIR) $(DMD_LATEST_DIR)/src $(MOD_EXCLUDES_LATEST) \
		$(addprefix --internal=, dmd rt core.internal) \
		$(addprefix --dump , object std etc core dmd rt core.internal.array core.internal.util) >$@

${GENERATED}/modlist-release.ddoc : tools/modlist.d ${STABLE_DMD} $(DRUNTIME_DIR) $(PHOBOS_DIR) $(DMD_DIR)
	mkdir -p $(dir $@)
	$(STABLE_RDMD) $< $(DRUNTIME_DIR)/src $(PHOBOS_DIR) $(DMD_DIR)/src $(MOD_EXCLUDES_RELEASE) \
		$(addprefix --internal=, dmd rt core.internal) \
		$(addprefix --dump , object std etc core dmd rt core.internal.array core.internal.util) >$@

${GENERATED}/modlist-prerelease.ddoc : tools/modlist.d ${STABLE_DMD} $(DRUNTIME_DIR) $(PHOBOS_DIR) $(DMD_DIR)
	mkdir -p $(dir $@)
	$(STABLE_RDMD) $< $(DRUNTIME_DIR)/src $(PHOBOS_DIR) $(DMD_DIR)/src $(MOD_EXCLUDES_PRERELEASE) \
		$(addprefix --internal=, dmd rt core.internal) \
		$(addprefix --dump , object std etc core dmd rt core.internal.array core.internal.util) >$@

# Run "make -j rebase" for rebasing all dox in parallel!
rebase: rebase-dlang rebase-dmd rebase-druntime rebase-phobos
rebase-dlang: ; $(call REBASE,dlang.org)
rebase-dmd: ; cd $(DMD_DIR) && $(call REBASE,dmd)
rebase-druntime: ; cd $(DRUNTIME_DIR) && $(call REBASE,druntime)
rebase-phobos: ; cd $(PHOBOS_DIR) && $(call REBASE,phobos)

clean:
	rm -rf $W ${GENERATED} $(DPL_DOCS_PATH)/.dub $(DPL_DOCS)

RSYNC_FILTER=-f 'P /Usage' -f 'P /.dpl_rewrite*' -f 'P /install.sh*'

rsync : all kindle
	rsync -avzO --chmod=u=rwX,g=rwX,o=rX --delete $(RSYNC_FILTER) $W/ $(REMOTE_DIR)/

rsync-only :
	rsync -avzO --chmod=u=rwX,g=rwX,o=rX --delete $(RSYNC_FILTER) $W/ $(REMOTE_DIR)/

dautotest: all verbatim diffable-intermediaries d-latest.tag d-prerelease.tag

################################################################################
# Pattern rulez
################################################################################

# NOTE: Depending on the version of make, order matters here. Therefore, put
# sub-directories before their parents.

$W/changelog/%.html : changelog/%_pre.dd $(CHANGELOG_PRE_DDOC) $(DDOC_BIN) | $(DMD)
	$(DDOC_BIN_DMD) -conf= $(DDOCFLAGS) -Df$@ $(CHANGELOG_PRE_DDOC) $<

$W/changelog/pending.html : changelog/pending.dd $(CHANGELOG_PENDING_DDOC) $(DDOC_BIN) | $(DMD)
	$(DDOC_BIN_DMD) -conf= $(DDOCFLAGS) -Df$@ $(CHANGELOG_PENDING_DDOC) $<

$W/changelog/%.html : changelog/%.dd $(CHANGELOG_DDOC) $(DDOC_BIN) | $(DMD)
	$(DDOC_BIN_DMD) -conf= $(DDOCFLAGS) -Df$@ $(CHANGELOG_DDOC) $<

$W/spec/%.html : spec/%.dd $(SPEC_DDOC) $(DMD) $(DDOC_BIN)
	$(DDOC_BIN_DMD) -Df$@ $(SPEC_DDOC) $<

$W/404.html : 404.dd $(DDOC) $(DMD)
	$(DMD) -conf= $(DDOCFLAGS) -Df$@ $(DDOC) errorpage.ddoc $<

$(DOC_OUTPUT_DIR)/foundation/contributors.html: foundation/contributors.dd \
		$G/contributors_list.ddoc foundation/foundation.ddoc $(DDOC) $(DMD)
	$(DMD) -conf= $(DDOCFLAGS) -Df$@ $(DDOC) $(word 2, $^) $(word 3, $^) $<

$W/articles/%.html : articles/%.dd $(DDOC) $(DMD) $(DDOC_BIN) articles/articles.ddoc
	$(DDOC_BIN_DMD) -conf= $(DDOCFLAGS) -Df$@ $(DDOC) $< articles/articles.ddoc

$W/foundation/%.html : foundation/%.dd $(DDOC) $(DMD) $(DDOC_BIN) foundation/foundation.ddoc
	$(DDOC_BIN_DMD) -conf= $(DDOCFLAGS) -Df$@ $(DDOC) $< foundation/foundation.ddoc

$W/%.html : %.dd $(DDOC) $(DMD) $(DDOC_BIN)
	$(DDOC_BIN_DMD) -conf= $(DDOCFLAGS) -Df$@ $(DDOC) $<

$W/%.verbatim : %_pre.dd verbatim.ddoc $(DDOC_BIN)
	$(DDOC_BIN_DMD) $(DDOCFLAGS) -Df$@ verbatim.ddoc $<

$W/%.verbatim : %.dd verbatim.ddoc $(DDOC_BIN)
	$(DDOC_BIN_DMD) $(DDOCFLAGS) -Df$@ verbatim.ddoc $<

$W/%.php : %.php.dd $(DDOC) $(DMD)
	$(DMD) -conf= $(DDOCFLAGS) -Df$@ $(DDOC) $<

$W/css/% : css/%
	@mkdir -p $(dir $@)
ifeq (1,$(CSS_MINIFY))
	curl -X POST -fsS --data-urlencode 'input@$<' http://cssminifier.com/raw >$@
else
	cp $< $@
endif

$W/%.css : %.css.dd $(DMD)
	$(DMD) $(DDOCFLAGS) -Df$@ $<

$W/% : %
	@mkdir -p $(dir $@)
	cp $< $@

$W/dmd-%.html : %.ddoc dcompiler.dd $(DDOC) $(DDOC_BIN)
	$(DDOC_BIN_DMD) -Df$@ $(DDOC) dcompiler.dd $<

$W/dmd-%.verbatim : %.ddoc dcompiler.dd verbatim.ddoc $(DMD)
	$(DMD) $(DDOCFLAGS) -Df$@ verbatim.ddoc dcompiler.dd $<

$W:
	mkdir -p $@

################################################################################
# Ebook
################################################################################

$G/dlangspec.d : $(SPEC_DD) ${STABLE_DMD}
	$(STABLE_RDMD) $(TOOLS_DIR)/catdoc.d -o$@ $(SPEC_DD)

$G/dlangspec.html : $(DDOC) ebook.ddoc $G/dlangspec.d $(DMD) $(DDOC_BIN)
	$(DDOC_BIN_DMD) -conf= -Df$@ $(DDOC) ebook.ddoc $G/dlangspec.d

$G/dlangspec.zip : $G/dlangspec.html ebook.css
	rm -f $@
	zip --junk-paths $@ $G/dlangspec.html ebook.css

$W/dlangspec.mobi : \
		dlangspec.opf dlangspec.ncx dlangspec.png $G/dlangspec.html  ebook.css
	rm -f $@ $G/dlangspec.mobi dlangspec.html
	# kindlegen has warnings, ignore them for now
	-cp -f $G/dlangspec.html dlangspec.html; \
		trap "rm -f dlangspec.html" EXIT; \
		kindlegen dlangspec.opf
	mv dlangspec.mobi $@

$W/dlangspec.html: $G/dlangspec.html | $W
	cp $< $@

################################################################################
# Plaintext/verbatim generation - not part of the build, demo purposes only
################################################################################

$G/dlangspec.txt : $G/dlangspec-consolidated.d $(DDOC_BIN) macros.ddoc plaintext.ddoc
	$(DDOC_BIN_DMD) -conf= -Df$@ macros.ddoc plaintext.ddoc $<

$G/dlangspec.verbatim.txt : $G/dlangspec-consolidated.d $(DDOC_BIN) verbatim.ddoc
	$(DDOC_BIN_DMD) -conf= -Df$@ verbatim.ddoc $<

################################################################################
# Fetch the latest article from the official D blog
################################################################################

ifeq (1,$(DIFFABLE))
$G/dblog_latest.xml: dblog_feed_example.xml
	@echo "Create a dummy DBlog XML stream due to DIFFABLE=1"
	cp $< $@
else
$G/dblog_latest.xml:
	@echo "Receiving the latest DBlog article. Disable with DIFFABLE=1"
	curl -s --fail --retry 3 --retry-delay 5 -L http://feeds.feedburner.com/OfficialDBlog -o $@
endif

$G/dblog_latest.ddoc: $G/dblog_latest.xml $(STABLE_DMD) tools/ddoc_xml_extractor.d
	$(STABLE_RDMD) tools/ddoc_xml_extractor.d -i $< -o $@

################################################################################
# Git rules
################################################################################

# Clone snapshots of the latest official release of all main D repositories
$G/%-${LATEST} :
	git clone -b v${LATEST} --depth=1 ${GIT_HOME}/$(notdir $*) $@

# Clone all main D repositories
${DMD_DIR} ${DRUNTIME_DIR} ${PHOBOS_DIR} ${TOOLS_DIR} ${INSTALLER_DIR} ${DUB_DIR}:
	git clone ${GIT_HOME}/$(notdir $(@F)) $@

${DMD_DIR}/VERSION : ${DMD_DIR}

################################################################################
# dmd compiler, latest released build and current build
################################################################################

$(DMD) : ${DMD_DIR}
	${MAKE} --directory=${DMD_DIR}/src -f posix.mak AUTO_BOOTSTRAP=1

$(DMD_LATEST) : ${DMD_LATEST_DIR}
	${MAKE} --directory=${DMD_LATEST_DIR}/src -f posix.mak AUTO_BOOTSTRAP=1
	sed -i -e "s|../druntime/import |../druntime-${LATEST}/import |" -e "s|../phobos |../phobos-${LATEST} |" $@.conf

dmd-prerelease : $(STD_DDOC_PRERELEASE) druntime-target $G/changelog/next-version
	$(MAKE) AUTO_BOOTSTRAP=1 --directory=$(DMD_DIR) -f posix.mak html $(DDOC_VARS_PRERELEASE_HTML)

dmd-release : $(STD_DDOC_RELEASE) druntime-target
	$(MAKE) AUTO_BOOTSTRAP=1 --directory=$(DMD_DIR) -f posix.mak html $(DDOC_VARS_RELEASE_HTML)

dmd-latest : $(STD_DDOC_LATEST) druntime-latest-target
	$(MAKE) AUTO_BOOTSTRAP=1 --directory=$(DMD_LATEST_DIR) -f posix.mak html $(DDOC_VARS_LATEST_HTML)

dmd-prerelease-verbatim : $W/phobos-prerelease/mars.verbatim
$W/phobos-prerelease/mars.verbatim: $(STD_DDOC_PRERELEASE) druntime-target \
		verbatim.ddoc $G/changelog/next-version
	mkdir -p $(dir $@)
	$(MAKE) AUTO_BOOTSTRAP=1 --directory=$(DMD_DIR) -f posix.mak html $(DDOC_VARS_PRERELEASE_VERBATIM)
	$(call CHANGE_SUFFIX,html,verbatim,$W/phobos-prerelease-verbatim)
	mv $W/phobos-prerelease-verbatim/* $(dir $@)
	rm -r $W/phobos-prerelease-verbatim

################################################################################
# druntime, latest released build and current build
# TODO: remove DOCDIR and DOCFMT once they have been removed at Druntime
################################################################################

druntime-target: ${DRUNTIME_DIR} ${DMD}
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak target ${DDOC_VARS_PRERELEASE_HTML}

druntime-latest-target: ${DRUNTIME_LATEST_DIR} ${DMD_LATEST}
	${MAKE} --directory=${DRUNTIME_LATEST_DIR} -f posix.mak target ${DDOC_VARS_LATEST_HTML}

druntime-prerelease : druntime-target $(STD_DDOC_PRERELEASE) $G/changelog/next-version
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak doc $(DDOC_VARS_PRERELEASE_HTML) \
		DOCDIR=$W/phobos-prerelease \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC_PRERELEASE))"

druntime-release : druntime-target $(STD_DDOC_RELEASE)
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak doc $(DDOC_VARS_RELEASE_HTML) \
		DOCDIR=$W/phobos \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC_RELEASE))"

druntime-latest : druntime-latest-target $(STD_DDOC_LATEST)
	${MAKE} --directory=${DRUNTIME_LATEST_DIR} -f posix.mak doc $(DDOC_VARS_LATEST_HTML) \
		DOCDIR=$W/phobos \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC_LATEST))"

druntime-prerelease-verbatim : $W/phobos-prerelease/object.verbatim
$W/phobos-prerelease/object.verbatim : $(DMD) druntime-target $G/changelog/next-version
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak target doc $(DDOC_VARS_PRERELEASE_VERBATIM) \
		DOCDIR=$W/phobos-prerelease-verbatim \
		DOCFMT="`pwd`/verbatim.ddoc"
	mkdir -p $(dir $@)
	$(call CHANGE_SUFFIX,html,verbatim,$W/phobos-prerelease-verbatim)
	mv $W/phobos-prerelease-verbatim/* $(dir $@)
	rm -r $W/phobos-prerelease-verbatim

################################################################################
# phobos, latest released build and current build
################################################################################

.PHONY: phobos-prerelease
phobos-prerelease : druntime-target $(STD_DDOC_PRERELEASE) $(DDOC_BIN) $(DMD) \
					$G/changelog/next-version
	$(MAKE) --directory=$(PHOBOS_DIR) -f posix.mak html $(DDOC_VARS_PRERELEASE_HTML) \
		DMD="$(abspath $(DDOC_BIN)) --compiler=$(abspath $(DMD))"

phobos-release : druntime-target $(STD_DDOC_RELEASE) $(DDOC_BIN) $(DMD)
	$(MAKE) --directory=$(PHOBOS_DIR) -f posix.mak html $(DDOC_VARS_RELEASE_HTML) \
		DMD="$(abspath $(DDOC_BIN)) --compiler=$(abspath $(DMD))"

phobos-latest : druntime-latest-target $(STD_DDOC_LATEST) $(DDOC_BIN) $(DMD_LATEST)
	$(MAKE) --directory=$(PHOBOS_LATEST_DIR) -f posix.mak html $(DDOC_VARS_LATEST_HTML) \
		DMD="$(abspath $(DDOC_BIN)) --compiler=$(abspath $(DMD_LATEST))"

phobos-prerelease-verbatim : $W/phobos-prerelease/index.verbatim
$W/phobos-prerelease/index.verbatim : druntime-target verbatim.ddoc \
		$W/phobos-prerelease/object.verbatim \
		$W/phobos-prerelease/mars.verbatim $G/changelog/next-version $(DMD) $(DDOC_BIN)
	${MAKE} --directory=${PHOBOS_DIR} -f posix.mak html $(DDOC_VARS_PRERELEASE_VERBATIM) \
	  DOC_OUTPUT_DIR=$W/phobos-prerelease-verbatim DMD="$(abspath $(DDOC_BIN)) --compiler=$(abspath $(DMD))"
	$(call CHANGE_SUFFIX,html,verbatim,$W/phobos-prerelease-verbatim)
	mv $W/phobos-prerelease-verbatim/* $(dir $@)
	rm -r $W/phobos-prerelease-verbatim

$(PHOBOS_LIB): $(DMD)
	${MAKE} --directory=${PHOBOS_DIR} -f posix.mak lib

################################################################################
# phobos and druntime, latest released build and current build (DDOX version)
################################################################################

apidocs-prerelease : $W/library-prerelease/sitemap.xml $W/library-prerelease/.htaccess
apidocs-latest : $W/library/sitemap.xml $W/library/.htaccess
apidocs-serve : $G/docs-prerelease.json
	${DPL_DOCS} serve-html --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc \
		--override-macros=std-ddox-override.ddoc --package-order=std \
		--git-target=master --web-file-dir=. $<

$W/library-prerelease/sitemap.xml : $G/docs-prerelease.json
	@mkdir -p $(dir $@)
	${DPL_DOCS} generate-html --file-name-style=lowerUnderscored --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc \
		--override-macros=std-ddox-override.ddoc --package-order=std \
		--git-target=master $(DPL_DOCS_PATH_RUN_FLAGS) \
		$< $W/library-prerelease

$W/library/sitemap.xml : $G/docs-latest.json
	@mkdir -p $(dir $@)
	${DPL_DOCS} generate-html --file-name-style=lowerUnderscored --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc \
		--override-macros=std-ddox-override.ddoc --package-order=std \
		--git-target=v${LATEST} $(DPL_DOCS_PATH_RUN_FLAGS) \
		$< $W/library

$W/library/.htaccess : dpl_latest_htaccess
	@mkdir -p $(dir $@)
	cp $< $@

$W/library-prerelease/.htaccess : dpl_prerelease_htaccess
	@mkdir -p $(dir $@)
	cp $< $@

$G/docs-latest.json : ${DMD_LATEST} ${DMD_LATEST_DIR} \
			${DRUNTIME_LATEST_DIR} | dpl-docs
	find ${DMD_LATEST_DIR}/src -name '*.d' -o -name '*.di' | sort -r | \
		gawk '!n[gensub(/\.di?$$/, "", 1)]++' > $G/.latest-files.txt
	find ${DRUNTIME_LATEST_DIR}/src -name '*.d' | \
		sed -e /unittest.d/d -e /gcstub/d >> $G/.latest-files.txt
	find ${PHOBOS_LATEST_DIR}/etc ${PHOBOS_LATEST_DIR}/std -name '*.d' | \
		sed -e /unittest.d/d | sort >> $G/.latest-files.txt
	${DMD_LATEST} -J$(DMD_LATEST_DIR)/src/dmd/res -J$(dir $(DMD_LATEST)) -c -o- -version=CoreDdoc \
		-version=MARS -version=CoreDdoc -version=StdDdoc -Df$G/.latest-dummy.html \
		-Xf$@ -I${PHOBOS_LATEST_DIR} @$G/.latest-files.txt
	${DPL_DOCS} filter $@ --min-protection=Protected \
		--only-documented $(MOD_EXCLUDES_LATEST)
	rm -f $G/.latest-files.txt $G/.latest-dummy.html

$G/docs-prerelease.json : ${DMD} ${DMD_DIR} ${DRUNTIME_DIR} | dpl-docs
	find ${DMD_DIR}/src -name '*.d' -o -name '*.di' | sort -r | \
		gawk '!n[gensub(/\.di?$$/, "", 1)]++' > $G/.prerelease-files.txt
	find ${DRUNTIME_DIR}/src -name '*.d' | \
		sed -e /unittest/d >> $G/.prerelease-files.txt
	find ${PHOBOS_DIR}/etc ${PHOBOS_DIR}/std -name '*.d' | \
		sed -e /unittest.d/d | sort >> $G/.prerelease-files.txt
	${DMD} -J$(DMD_DIR)/res -J$(DMD_DIR)/src/dmd/res -J$(dir $(DMD)) -c -o- -version=MARS -version=CoreDdoc \
		-version=StdDdoc -Df$G/.prerelease-dummy.html \
		-Xf$@ -I${PHOBOS_DIR} @$G/.prerelease-files.txt
	${DPL_DOCS} filter $@ --min-protection=Protected \
		--only-documented $(MOD_EXCLUDES_PRERELEASE)
	rm -f $G/.prerelease-files.txt $G/.prerelease-dummy.html

################################################################################
# binary targets for DDOX
################################################################################

# workardound Issue 15574
ifneq (osx,$(OS))
 DPL_DOCS_DFLAGS=-conf=$(abspath ${STABLE_DMD_CONF}) -L--no-as-needed
else
 DPL_DOCS_DFLAGS=-conf=$(abspath ${STABLE_DMD_CONF})
endif

.PHONY: dpl-docs
dpl-docs: ${DUB} ${STABLE_DMD}
	DFLAGS="$(DPL_DOCS_DFLAGS)" ${DUB} -v build --root=${DPL_DOCS_PATH} \
		--compiler=${STABLE_DMD}

# .tar.xz's archives are smaller (and don't need a temporary dir) -> prefer if available
${STABLE_DMD_ROOT}/.downloaded:
	@mkdir -p $(dir $@)
	@if command -v xz >/dev/null 2>&1 ; then \
		curl -fSL --retry 3 $(subst .zip,.tar.xz,$(STABLE_DMD_URL)) | tar -Jxf - -C $(dir $@); \
	else \
		TMPFILE=$$(mktemp deleteme.XXXXXXXX) && curl -fsSL ${STABLE_DMD_URL} > ${TMP}/$${TMPFILE}.zip && \
			unzip -qd ${STABLE_DMD_ROOT} ${TMP}/$${TMPFILE}.zip && rm ${TMP}/$${TMPFILE}.zip; \
	fi
	@touch $@

${STABLE_DMD} ${STABLE_RDMD} ${DUB}: ${STABLE_DMD_ROOT}/.downloaded

################################################################################
# chm help files
################################################################################

# testing menu generation
chm-nav-latest.json : $(DDOC) std.ddoc spec/spec.ddoc ${GENERATED}/modlist-${LATEST}.ddoc changelog/changelog.ddoc chm-nav.dd $(DMD) $(DDOC_BIN)
	$(DDOC_BIN_DMD) -conf= -c -o- -Df$@ $(filter-out $(DMD) $(DDOC_BIN),$^)

chm-nav-release.json : $(DDOC) std.ddoc spec/spec.ddoc ${GENERATED}/modlist-release.ddoc changelog/changelog.ddoc chm-nav.dd $(DMD) $(DDOC_BIN)
	$(DDOC_BIN_DMD) -conf= -c -o- -Df$@ $(filter-out $(DMD) $(DDOC_BIN),$^)

chm-nav-prerelease.json : $(DDOC) std.ddoc spec/spec.ddoc ${GENERATED}/modlist-prerelease.ddoc changelog/changelog.ddoc chm-nav.dd $(DMD) $(DDOC_BIN)
	$(DDOC_BIN_DMD) -conf= -c -o- -Df$@ $(filter-out $(DMD) $(DDOC_BIN),$^)

################################################################################
# Dman tags
################################################################################

d-latest.tag d-tags-latest.json : tools/chmgen.d $(STABLE_DMD) $(ALL_FILES) phobos-latest druntime-latest chm-nav-latest.json
	$(STABLE_RDMD) $< --root=$W --target latest

d-release.tag d-tags-release.json : tools/chmgen.d $(STABLE_DMD) $(ALL_FILES) phobos-release druntime-release chm-nav-release.json
	$(STABLE_RDMD) $< --root=$W --target release

d-prerelease.tag d-tags-prerelease.json : tools/chmgen.d $(STABLE_DMD) $(ALL_FILES) phobos-prerelease druntime-prerelease chm-nav-prerelease.json
	$(STABLE_RDMD) $< --root=$W --target prerelease

################################################################################
# Style tests
################################################################################

test_dspec: tools/dspec_tester.d $(DMD) $(PHOBOS_LIB)
	@echo "Test the D Language specification"
	$(DMD) -run $< --compiler=$(DMD)

.PHONY:
test: test_dspec test/next_version.sh all | $(STABLE_DMD) $(DUB)
	@echo "Searching for trailing whitespace"
	@grep -n '[[:blank:]]$$' $$(find . -type f -name "*.dd" | grep -v .generated) ; test $$? -eq 1
	@echo "Searching for tabs"
	@grep -n -P "\t" $$(find . -type f -name "*.dd" | grep -v .generated) ; test $$? -eq 1
	@echo "Checking DDoc's output"
	$(STABLE_RDMD) -main -unittest tools/check_ddoc.d
	$(STABLE_RDMD) tools/check_ddoc.d $$(find $W -type f -name "*.html" -not -path "$W/phobos/*")
	@echo "Executing ddoc_preprocessor tests"
	$(DUB) test --compiler=${STABLE_DMD} --root ddoc
	@echo "Executing next_version tests"
	test/next_version.sh

################################################################################
# Changelog generation
# --------------------
#
# The changelog generation consists of two parts:
#
# 1) Closed Bugzilla issues since the latest release
#  - The git log messages after the ${LATEST} release are parsed
#  - From these git commit messages, referenced Bugzilla issues are extracted
#  - The status of these issues is checked against the Bugzilla instance (https://issues.dlang.org)
#
#  See also: https://github.com/dlang-bots/dlang-bot#bugzilla
#
# 2) Full-text messages
#  - In all dlang repos, a `changelog` folder exists and can be used to add
#    small, detailed changelog messages (see e.g. https://github.com/dlang/phobos/tree/master/changelog)
#  - The changelog generation script searches for all Ddoc files within the `changelog` folders
#    and adds them to the generated changelog
#
#  The changelog script is at https://github.com/dlang/tools/blob/master/changed.d
#
# Changelog targets
# -----------------
#
# The changelog generation has two targets:
#
# a) Preview upcoming changes
#
#     make -f posix.mak pending_changelog
#
#  This will look at changes up to `upstream/master` and can be used to
#  preview the changelog locally.
#
# b) Generate the changelog for an upcoming release
#
#     make -f posix.mak prerelease_changelog
#
#  This will look at changes to upstream/stable and is run by the release manager.
################################################################################
LOOSE_CHANGELOG_FILES:=$(wildcard $(DMD_DIR)/changelog/*.dd) \
				$(wildcard $(DRUNTIME_DIR)/changelog/*.dd) \
				$(wildcard $(PHOBOS_DIR)/changelog/*.dd) \
				$(wildcard $(TOOLS_DIR)/changelog/*.dd) \
				$(wildcard $(INSTALLER_DIR)/changelog/*.dd) \
				$(wildcard $(DUB_DIR)/changelog/*.dd)

$G/changelog/next-version: ${DMD_DIR}/VERSION
	$(eval NEXT_VERSION:=$(shell changelog/next_version.sh ${DMD_DIR}/VERSION))
	@mkdir -p $(dir $@)
	@echo $(NEXT_VERSION) > $@

changelog/prerelease.dd: $G/changelog/next-version $(LOOSE_CHANGELOG_FILES) | \
							${STABLE_DMD} $(TOOLS_DIR) $(INSTALLER_DIR) $(DUB_DIR)
	$(STABLE_RDMD) -version=Contributors_Lib $(TOOLS_DIR)/changed.d \
		$(CHANGELOG_VERSION_STABLE) -o $@ --version "${NEXT_VERSION}" \
		--prev-version="${LATEST}" --date "To be released"

changelog/pending.dd: $G/changelog/next-version $(LOOSE_CHANGELOG_FILES) | \
							${STABLE_DMD} $(TOOLS_DIR) $(INSTALLER_DIR) $(DUB_DIR)
	$(STABLE_RDMD) -version=Contributors_Lib $(TOOLS_DIR)/changed.d \
		$(CHANGELOG_VERSION_MASTER) -o $@ --version "${NEXT_VERSION}" \
		--prev-version="${LATEST}" --date "To be released"

pending_changelog: changelog/pending.dd html
	@echo "Please open file:///$(shell pwd)/web/changelog/pending.html in your browser"

prerelease_changelog: changelog/prerelease.dd html
	@echo "Please open file:///$(shell pwd)/web/changelog/prerelease.html in your browser"
	@echo "To proceed, rename $@ to changelog/${NEXT_VERSION}_pre.dd"

################################################################################
# Contributors listing: A list of all the awesome who made D possible
################################################################################

$G/contributors_list.ddoc:  | $(STABLE_RDMD) $(TOOLS_DIR) $(INSTALLER_DIR)
	$(STABLE_RDMD) $(TOOLS_DIR)/contributors.d --format=ddoc "master" > $G/contributors_list.tmp
	echo "NR_D_CONTRIBUTORS=$$(wc -l < $G/contributors_list.tmp)" > $@
	echo "D_CONTRIBUTORS=" >> $@
	cat $G/contributors_list.tmp >> $@

################################################################################
# Custom DDoc wrapper
# ------------------
#
# This allows extending Ddoc files and D source code files dynamically on-the-fly.
################################################################################

$(DDOC_BIN): ddoc/source/preprocessor.d ddoc/source/assert_writeln_magic.d | $(STABLE_DMD)
	$(STABLE_DMD_BIN_ROOT)/dub build --compiler=$(STABLE_DMD) --root=ddoc && \
		mv ddoc/ddoc_preprocessor $@

################################################################################
# Build and render the DMD man page
# ---------------------------------
#
# This allows previewing changes to the automatically generated DMD man page
################################################################################

$(DMD_DIR)/generated/$(MAN_PAGE): $(DMD_DIR)/docs/gen_man.d $(DMD_DIR)/src/dmd/cli.d | ${STABLE_DMD}
	${MAKE} -C $(DMD_DIR)/docs DMD=$(abspath $(STABLE_DMD)) DIFFABLE=$(DIFFABLE) build

$W/$(MAN_PAGE): $(DMD_DIR)/generated/$(MAN_PAGE) | ${STABLE_DMD}
	mkdir -p $(dir $@)
	cp $< $@
	# CircleCi + nightlies.dlang.org might not have `man` installed
	if [ $(OS) != "osx" ] -a [ command -v man > /dev/null ] ; then \
		${MAKE} -s -C $(DMD_DIR)/docs DMD=$(abspath $(STABLE_DMD)) DIFFABLE=$(DIFFABLE) preview > $(dir $@)dmd.txt; \
	fi

man: $W/$(MAN_PAGE)

.DELETE_ON_ERROR: # GNU Make directive (delete output files on error)
