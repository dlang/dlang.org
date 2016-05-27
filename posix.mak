# Makefile to build the entire dlang.org website
#
# To run:
#
# make -f posix.mak all
#
# To also upload to the website:
#
# make -f posix.mak rsync
#

# Externals
DMD_DIR=../dmd
PHOBOS_DIR=../phobos
DRUNTIME_DIR=../druntime
DUB_DIR=../dub-${DUB_VER}
DMD=$(DMD_DIR)/src/dmd
DMD_REL=$(DMD_DIR)-${LATEST}/src/dmd
DUB=${DUB_DIR}/bin/dub
DOC_OUTPUT_DIR:=$(shell pwd)/web
GIT_HOME=https://github.com/dlang
DPL_DOCS_PATH=dpl-docs
DPL_DOCS=$(DPL_DOCS_PATH)/dpl-docs
REMOTE_DIR=d-programming@digitalmars.com:data
GENERATED=.generated

# stable dub and dmd versions used to build dpl-docs
DUB_VER=0.9.25-alpha.1
STABLE_DMD_VER=2.069.2
STABLE_DMD_ROOT=/tmp/.stable_dmd-$(STABLE_DMD_VER)
STABLE_DMD_URL=http://downloads.dlang.org/releases/2.x/$(STABLE_DMD_VER)/dmd.$(STABLE_DMD_VER).$(OS).zip
STABLE_DMD=$(STABLE_DMD_ROOT)/dmd2/$(OS)/$(if $(filter $(OS),osx),bin,bin$(MODEL))/dmd
STABLE_DMD_CONF=$(STABLE_DMD).conf
STABLE_RDMD=$(STABLE_DMD_ROOT)/dmd2/$(OS)/$(if $(filter $(OS),osx),bin,bin$(MODEL))/rdmd \
	--compiler=$(STABLE_DMD) -conf=$(STABLE_DMD_CONF)

# exclude lists
MOD_EXCLUDES_PRERELEASE=$(addprefix --ex=, gc. rt. core.internal. core.stdc.config core.sys.	\
	std.c. std.algorithm.internal std.internal. std.regex.internal. 			\
	std.windows.iunknown std.windows.registry etc.linux.memoryerror std.stream std.cstream	\
	std.socketstream std.experimental.ndslice.internal)

MOD_EXCLUDES_RELEASE=$(MOD_EXCLUDES_PRERELEASE)

# rdmd must fetch the model, imports, and libs from the specified version
DFLAGS=-m$(MODEL) -I$(DRUNTIME_DIR)/import -I$(PHOBOS_DIR) -L-L$(PHOBOS_DIR)/generated/$(OS)/release/$(MODEL)
RDMD=rdmd --compiler=$(DMD) $(DFLAGS)

# Tools
REBASE = MYBRANCH=`git rev-parse --abbrev-ref HEAD` &&\
 git checkout master &&\
 git pull --ff-only git@github.com:dlang/$1.git master &&\
 git checkout $$MYBRANCH &&\
 git rebase master

CHANGE_SUFFIX = \
 for f in `find "$3" -iname '*.$1'`; do\
  mv $$f `dirname $$f`/`basename $$f .$1`.$2; done

# Set to 1 in the command line to minify css files
CSS_MINIFY=

# Latest released version
ifeq (,${LATEST})
LATEST:=$(shell cd ${DMD_DIR} && \
  git fetch --tags ${GIT_HOME}/dmd && \
  git tag | grep '^v[0-9][0-9.]*$$' | sed 's/^v//' | sort -nr | head -n 1)
$(info LATEST=${LATEST} <-- place in the command line to skip network traffic.)
endif
ifeq (,${LATEST})
  $(error Could not fetch latest version, place LATEST=2.xxx.y in the command line)
endif

# OS and MODEL
OS:=
uname_S:=$(shell uname -s)
ifeq (Darwin,$(uname_S))
    OS:=osx
endif
ifeq (Linux,$(uname_S))
    OS:=linux
endif
ifeq (FreeBSD,$(uname_S))
    OS:=freebsd
endif
ifeq (OpenBSD,$(uname_S))
    OS:=openbsd
endif
ifeq (Solaris,$(uname_S))
    OS:=solaris
endif
ifeq (SunOS,$(uname_S))
    OS:=solaris
endif
ifeq (,$(OS))
    $(error Unrecognized or unsupported OS for uname: $(uname_S))
endif

ifeq (,$(MODEL))
    uname_M:=$(shell uname -m)
    ifneq (,$(findstring $(uname_M),x86_64 amd64))
        MODEL:=64
    endif
    ifneq (,$(findstring $(uname_M),i386 i586 i686))
        MODEL:=32
    endif
    ifeq (,$(MODEL))
        $(error Cannot figure 32/64 model from uname -m: $(uname_M))
    endif
endif

# Documents

DDOC=$(addsuffix .ddoc, macros html dlang.org doc ${GENERATED}/${LATEST}) $(NODATETIME)
STD_DDOC=$(addsuffix .ddoc, macros html dlang.org ${GENERATED}/${LATEST} std std_navbar-release ${GENERATED}/modlist-${LATEST}) $(NODATETIME)
STD_DDOC_PRE=$(addsuffix .ddoc, macros html dlang.org ${GENERATED}/${LATEST} std std_navbar-prerelease ${GENERATED}/modlist-prerelease) $(NODATETIME)
SPEC_DDOC=${DDOC} spec/spec.ddoc
CHANGELOG_DDOC=${DDOC} changelog/changelog.ddoc $(NODATETIME)
CHANGELOG_PRE_DDOC=${CHANGELOG_DDOC} changelog/prerelease.ddoc

ORGS_USING_D=$(wildcard images/orgs-using-d/*)
IMAGES=favicon.ico $(ORGS_USING_D) $(addprefix images/, \
	d002.ico \
	$(addprefix compiler-, dmd.png gdc.svg ldc.png) \
	$(addsuffix .svg, icon_minus icon_plus hamburger dlogo faster-aa-1 faster-gc-1) \
	$(addsuffix .png, archlinux_logo apple_logo centos_logo chocolatey_logo \
		d3 debian_logo dlogo fedora_logo freebsd_logo gentoo_logo homebrew_logo \
		opensuse_logo ubuntu_logo windows_logo pattern github-ribbon \
		$(addprefix ddox/, alias class enum enummember function \
			inherited interface module package private property protected \
			struct template variable)) \
	$(addsuffix .gif, c1 cpp1 d4 d5 dmlogo dmlogo-smaller globe \
		pen) \
	$(addsuffix .jpg, tdpl))

JAVASCRIPT=$(addsuffix .js, $(addprefix js/, \
	codemirror-compressed dlang ddox listanchors run run-main-website jquery-1.7.2.min))

STYLES=$(addsuffix .css, $(addprefix css/, \
	style print codemirror ddox))

PREMADE=appendices.html articles.html fetch-issue-cnt.php howtos.html	\
language-reference.html robots.txt .htaccess .dpl_rewrite_map.txt	\
d-keyring.gpg

# Language spec root filenames. They have extension .dd in the source
# and .html in the generated HTML. These are also used for the mobi
# book generation, for which reason the list is sorted by chapter.
SPEC_ROOT=$(addprefix spec/, \
	spec intro lex grammar module declaration type property attribute pragma	\
	expression statement arrays hash-map struct class interface enum	\
	const3 function operatoroverloading template template-mixin contracts		\
	version traits errors unittest garbage float iasm ddoc				\
	interfaceToC cpp_interface objc_interface portability entity memory-safe-d \
	abi simd)
SPEC_DD=$(addsuffix .dd,$(SPEC_ROOT))

CHANGELOG_FILES=$(basename $(subst _pre.dd,.dd,$(wildcard changelog/*.dd)))

# Website root filenames. They have extension .dd in the source
# and .html in the generated HTML. Save for the expansion of
# $(SPEC_ROOT), the list is sorted alphabetically.
PAGES_ROOT=$(SPEC_ROOT) 32-64-portability acknowledgements articles ascii-table	\
	bugstats.php builtin \
	$(CHANGELOG_FILES) code_coverage COM community comparison concepts \
	const-faq cpptod ctarguments ctod \
	D1toD2 d-array-article d-floating-point deprecate dll dll-linux \
	dmd-freebsd dmd-linux dmd-osx dmd-windows documentation download dstyle \
	exception-safe faq forum-template foundation gpg_keys getstarted glossary \
	gsoc2011 gsoc2012 gsoc2012-template hijack howto-promote htod htomodule index \
	intro-to-datetime lazy-evaluation memory menu migrate-to-shared mixin	\
	orgs-using-d overview pretod rationale rdmd regular-expression resources safed \
	search template-comparison templates-revisited tools tuple	\
	variadic-function-templates warnings wc windbg windows

TARGETS=$(addsuffix .html,$(PAGES_ROOT))

ALL_FILES_BUT_SITEMAP = $(addprefix $(DOC_OUTPUT_DIR)/, $(TARGETS)	\
$(PREMADE) $(STYLES) $(IMAGES) $(JAVASCRIPT))

ALL_FILES = $(ALL_FILES_BUT_SITEMAP) $(DOC_OUTPUT_DIR)/sitemap.html

# Pattern rulez

# NOTE: Depending on the version of make, order matters here. Therefore, put
# sub-directories before their parents.

$(DOC_OUTPUT_DIR)/changelog/%.html : changelog/%.dd $(CHANGELOG_DDOC) $(DMD)
	$(DMD) -conf= -c -o- -Df$@ $(CHANGELOG_DDOC) $<

$(DOC_OUTPUT_DIR)/changelog/%.html : changelog/%_pre.dd $(CHANGELOG_PRE_DDOC) $(DMD)
	$(DMD) -conf= -c -o- -Df$@ $(CHANGELOG_PRE_DDOC) $<

$(DOC_OUTPUT_DIR)/spec/%.html : spec/%.dd $(SPEC_DDOC) $(DMD)
	$(DMD) -c -o- -Df$@ $(SPEC_DDOC) $<

$(DOC_OUTPUT_DIR)/%.html : %.dd $(DDOC) $(DMD)
	$(DMD) -conf= -c -o- -Df$@ $(DDOC) $<

$(DOC_OUTPUT_DIR)/%.verbatim : %.dd verbatim.ddoc $(DMD)
	$(DMD) -c -o- -Df$@ verbatim.ddoc $<

$(DOC_OUTPUT_DIR)/%.verbatim : %_pre.dd verbatim.ddoc $(DMD)
	$(DMD) -c -o- -Df$@ verbatim.ddoc $<

$(DOC_OUTPUT_DIR)/%.php : %.php.dd $(DDOC) $(DMD)
	$(DMD) -conf= -c -o- -Df$@ $(DDOC) $<

$(DOC_OUTPUT_DIR)/css/% : css/%
	@mkdir -p $(dir $@)
ifeq (1,$(CSS_MINIFY))
	curl -X POST -fsS --data-urlencode 'input@$<' http://cssminifier.com/raw >$@
else
	cp $< $@
endif

$(DOC_OUTPUT_DIR)/%.css : %.css.dd $(DMD)
	$(DMD) -c -o- -Df$@ $<

$(DOC_OUTPUT_DIR)/% : %
	@mkdir -p $(dir $@)
	cp $< $@

$(DOC_OUTPUT_DIR)/dmd-%.html : %.ddoc dcompiler.dd $(DDOC) $(DMD)
	$(DMD) -conf= -c -o- -Df$@ $(DDOC) dcompiler.dd $<

$(DOC_OUTPUT_DIR)/dmd-%.verbatim : %.ddoc dcompiler.dd verbatim.ddoc $(DMD)
	$(DMD) -c -o- -Df$@ verbatim.ddoc dcompiler.dd $<

################################################################################
# Rulez
################################################################################

all : docs html

docs : dmd-prerelease phobos-prerelease druntime-prerelease druntime-release \
  phobos-release apidocs-release apidocs-prerelease

html : $(ALL_FILES)

verbatim : $(addprefix $(DOC_OUTPUT_DIR)/, $(addsuffix .verbatim,$(PAGES_ROOT))) phobos-prerelease-verbatim

kindle : ${DOC_OUTPUT_DIR}/dlangspec.mobi

pdf : ${DOC_OUTPUT_DIR}/dlangspec.pdf

$(DOC_OUTPUT_DIR)/sitemap.html : $(ALL_FILES_BUT_SITEMAP) $(DMD)
	cp -f sitemap-template.dd sitemap.dd
	(true $(foreach F, $(TARGETS), \
	  && echo \
	    "$F	`sed -n 's/<title>\(.*\) - D Programming Language.*<\/title>/\1/'p $(DOC_OUTPUT_DIR)/$F`")) \
	  | sort --ignore-case --key=2 | sed 's/^\([^	]*\)	\(.*\)/<a href="\1">\2<\/a><br>/' >> sitemap.dd
	$(DMD) -conf= -c -o- -Df$@ $(DDOC) sitemap.dd
	rm sitemap.dd

${GENERATED}/${LATEST}.ddoc :
	mkdir -p $(dir $@)
	echo "LATEST=${LATEST}" >$@

${GENERATED}/modlist-${LATEST}.ddoc : modlist.d ${STABLE_DMD} $(DRUNTIME_DIR)-$(LATEST) $(PHOBOS_DIR)-$(LATEST)
	mkdir -p $(dir $@)
	$(STABLE_RDMD) modlist.d $(DRUNTIME_DIR)-$(LATEST) $(PHOBOS_DIR)-$(LATEST) $(MOD_EXCLUDES_RELEASE) >$@

${GENERATED}/modlist-prerelease.ddoc : modlist.d ${STABLE_DMD} $(DRUNTIME_DIR) $(PHOBOS_DIR)
	mkdir -p $(dir $@)
	$(STABLE_RDMD) modlist.d $(DRUNTIME_DIR) $(PHOBOS_DIR) $(MOD_EXCLUDES_PRERELEASE) >$@

# Run "make -j rebase" for rebasing all dox in parallel!
rebase: rebase-dlang rebase-dmd rebase-druntime rebase-phobos
rebase-dlang: ; $(call REBASE,dlang.org)
rebase-dmd: ; cd $(DMD_DIR) && $(call REBASE,dmd)
rebase-druntime: ; cd $(DRUNTIME_DIR) && $(call REBASE,druntime)
rebase-phobos: ; cd $(PHOBOS_DIR) && $(call REBASE,phobos)

clean:
	rm -rf $(DOC_OUTPUT_DIR) ${GENERATED} dpl-docs/.dub
	rm -rf auto dlangspec-consolidated.d $(addprefix dlangspec,.aux .d .dvi .fdb_latexmk .fls .log .out .pdf .tex .txt .verbatim.txt)
	rm -f docs.json docs-prerelease.json dpl-docs/dpl-docs
	@echo You should issue manually: rm -rf ${DMD_DIR}-${LATEST} ${DRUNTIME_DIR}-${LATEST} ${PHOBOS_DIR}-${LATEST} ${STABLE_DMD_ROOT} ${DUB_DIR}

RSYNC_FILTER=-f 'P /Usage' -f 'P /.dpl_rewrite*' -f 'P /install.sh*'

rsync : all kindle pdf
	rsync -avzO --chmod=u=rwX,g=rwX,o=rX --delete $(RSYNC_FILTER) $(DOC_OUTPUT_DIR)/ $(REMOTE_DIR)/

rsync-only :
	rsync -avzO --chmod=u=rwX,g=rwX,o=rX --delete $(RSYNC_FILTER) $(DOC_OUTPUT_DIR)/ $(REMOTE_DIR)/

################################################################################
# Ebook
################################################################################

dlangspec.d : $(SPEC_DD) ${STABLE_DMD}
	$(STABLE_RDMD) ../tools/catdoc.d -o$@ $(SPEC_DD)

dlangspec.html : $(DDOC) ebook.ddoc dlangspec.d $(DMD)
	$(DMD) -conf= $(DDOC) ebook.ddoc dlangspec.d

dlangspec.zip : dlangspec.html ebook.css
	rm -f $@
	zip $@ dlangspec.html ebook.css

$(DOC_OUTPUT_DIR)/dlangspec.mobi : \
		dlangspec.opf dlangspec.html dlangspec.png dlangspec.ncx ebook.css
	rm -f $@ dlangspec.mobi
# kindlegen has warnings, ignore them for now
	-kindlegen dlangspec.opf
	mv dlangspec.mobi $@

################################################################################
# LaTeX
################################################################################

dlangspec-consolidated.d : $(SPEC_DD) ${STABLE_DMD}
	$(STABLE_RDMD) --force ../tools/catdoc.d -o$@ $(SPEC_DD)

dlangspec.tex : $(DMD) $(DDOC) latex.ddoc dlangspec-consolidated.d
	$(DMD) -conf= -Df$@ $(DDOC) latex.ddoc dlangspec-consolidated.d

# Run twice to fix multipage tables and \ref uses
$(DOC_OUTPUT_DIR)/dlangspec.pdf : dlangspec.tex
	mkdir -p .tmp
	pdflatex -draftmode $^
	pdflatex -output-directory=.tmp $^
	mv .tmp/dlangspec.pdf $@
	rm -rf .tmp

################################################################################
# Plaintext/verbatim generation - not part of the build, demo purposes only
################################################################################

dlangspec.txt : $(DMD) macros.ddoc plaintext.ddoc dlangspec-consolidated.d
	$(DMD) -conf= -Df$@ macros.ddoc plaintext.ddoc dlangspec-consolidated.d

dlangspec.verbatim.txt : $(DMD) verbatim.ddoc dlangspec-consolidated.d
	$(DMD) -conf= -Df$@ verbatim.ddoc dlangspec-consolidated.d

################################################################################
# Git rules
################################################################################

../%-${LATEST} :
	git clone -b v${LATEST} --depth=1 ${GIT_HOME}/$* $@

../%-${DUB_VER} :
	git clone --depth=1 -b v${DUB_VER} ${GIT_HOME}/$* $@

${DMD_DIR} ${DRUNTIME_DIR} ${PHOBOS_DIR} :
	git clone --depth=1 ${GIT_HOME}/$(@F) $@

################################################################################
# dmd compiler, latest released build and current build
################################################################################

$(DMD) : ${DMD_DIR}
	${MAKE} --directory=${DMD_DIR}/src -f posix.mak -j 4

$(DMD_REL) : ${DMD_DIR}-${LATEST}
	${MAKE} --directory=${DMD_DIR}-${LATEST}/src -f posix.mak -j 4

dmd-prerelease : $(STD_DDOC_PRE) $(DMD_DIR) $(DMD)
	$(MAKE) --directory=$(DMD_DIR) -f posix.mak html \
		DOCDIR=${DOC_OUTPUT_DIR}/dmd-prerelease \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC_PRE))"

################################################################################
# druntime, latest released build and current build
################################################################################

druntime-prerelease : ${DRUNTIME_DIR} $(DMD) $(STD_DDOC_PRE)
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak -j 4 target doc \
		DOCDIR=${DOC_OUTPUT_DIR}/phobos-prerelease \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC_PRE))"

druntime-release : ${DRUNTIME_DIR}-${LATEST} $(DMD_REL) $(STD_DDOC)
	${MAKE} --directory=${DRUNTIME_DIR}-${LATEST} -f posix.mak target doc \
	  DMD=$(DMD_REL) \
	  DOCDIR=${DOC_OUTPUT_DIR}/phobos \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC))"

druntime-prerelease-verbatim : ${DRUNTIME_DIR} \
		${DOC_OUTPUT_DIR}/phobos-prerelease/object.verbatim
${DOC_OUTPUT_DIR}/phobos-prerelease/object.verbatim : $(DMD)
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak -j 4 target doc \
		DOCDIR=${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim \
		DOCFMT="`pwd`/verbatim.ddoc"
	mkdir -p $(dir $@)
	$(call CHANGE_SUFFIX,html,verbatim,${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim)
	mv ${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim/* $(dir $@)
	rm -r ${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim

################################################################################
# phobos, latest released build and current build
################################################################################

.PHONY: phobos-prerelease
phobos-prerelease : ${PHOBOS_DIR} $(STD_DDOC_PRE) druntime-prerelease
	${MAKE} --directory=${PHOBOS_DIR} -f posix.mak \
	  STDDOC="$(addprefix `pwd`/, $(STD_DDOC_PRE))" \
	  DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos-prerelease html -j 4

phobos-release : ${PHOBOS_DIR}-${LATEST} $(DMD_REL) $(STD_DDOC) \
		druntime-release
	${MAKE} --directory=${PHOBOS_DIR}-${LATEST} -f posix.mak -j 4 \
	  html \
	  DMD=$(DMD_REL) \
	  DRUNTIME_PATH=${DRUNTIME_DIR}-${LATEST} \
	  DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos \
	  STDDOC="$(addprefix `pwd`/, $(STD_DDOC))"

phobos-prerelease-verbatim : ${PHOBOS_DIR} ${DOC_OUTPUT_DIR}/phobos-prerelease/index.verbatim
${DOC_OUTPUT_DIR}/phobos-prerelease/index.verbatim : verbatim.ddoc \
	    ${DOC_OUTPUT_DIR}/phobos-prerelease/object.verbatim
	${MAKE} --directory=${PHOBOS_DIR} -f posix.mak \
	    STDDOC="`pwd`/verbatim.ddoc" \
	    DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim html -j 4
	$(call CHANGE_SUFFIX,html,verbatim,${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim)
	mv ${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim/* $(dir $@)
	rm -r ${DOC_OUTPUT_DIR}/phobos-prerelease-verbatim

################################################################################
# phobos and druntime, latest released build and current build (DDOX version)
################################################################################

apidocs-prerelease : ${DOC_OUTPUT_DIR}/library-prerelease/sitemap.xml ${DOC_OUTPUT_DIR}/library-prerelease/.htaccess
apidocs-release : ${DOC_OUTPUT_DIR}/library/sitemap.xml ${DOC_OUTPUT_DIR}/library/.htaccess
apidocs-serve : docs-prerelease.json
	${DPL_DOCS} serve-html --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc \
	  --override-macros=std-ddox-override.ddoc --package-order=std \
	  --git-target=master --web-file-dir=. docs-prerelease.json

${DOC_OUTPUT_DIR}/library-prerelease/sitemap.xml : docs-prerelease.json
	@mkdir -p $(dir $@)
	${DPL_DOCS} generate-html --file-name-style=lowerUnderscored --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc \
	  --override-macros=std-ddox-override.ddoc --package-order=std \
	  --git-target=master docs-prerelease.json ${DOC_OUTPUT_DIR}/library-prerelease

${DOC_OUTPUT_DIR}/library/sitemap.xml : docs.json
	@mkdir -p $(dir $@)
	${DPL_DOCS} generate-html --file-name-style=lowerUnderscored --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc \
	  --override-macros=std-ddox-override.ddoc --package-order=std \
	  --git-target=v${LATEST} docs.json ${DOC_OUTPUT_DIR}/library

${DOC_OUTPUT_DIR}/library/.htaccess : dpl_release_htaccess
	@mkdir -p $(dir $@)
	cp $< $@

${DOC_OUTPUT_DIR}/library-prerelease/.htaccess : dpl_prerelease_htaccess
	@mkdir -p $(dir $@)
	cp $< $@

docs.json : ${DMD_REL} ${DRUNTIME_DIR}-${LATEST} \
		${PHOBOS_DIR}-${LATEST} | dpl-docs
	find ${DRUNTIME_DIR}-${LATEST}/src -name '*.d' | \
	  sed -e /unittest.d/d -e /gcstub/d > .release-files.txt
	find ${PHOBOS_DIR}-${LATEST} -name '*.d' | \
	  sed -e /unittest.d/d -e /windows/d >> .release-files.txt
	${DMD_REL} -c -o- -version=CoreDdoc -version=StdDdoc -Df.release-dummy.html \
	  -Xfdocs.json -I${PHOBOS_DIR}-${LATEST} @.release-files.txt
	${DPL_DOCS} filter docs.json --min-protection=Protected \
	  --only-documented $(MOD_EXCLUDES_PRERELEASE)
	rm .release-files.txt .release-dummy.html

docs-prerelease.json : ${DMD} ${DRUNTIME_DIR} \
		${PHOBOS_DIR} | dpl-docs
	find ${DRUNTIME_DIR}/src -name '*.d' | sed -e '/gcstub/d' \
	  -e /unittest/d > .prerelease-files.txt
	find ${PHOBOS_DIR} -name '*.d' | sed -e /unittest.d/d \
	  -e /windows/d >> .prerelease-files.txt
	${DMD} -c -o- -version=CoreDdoc -version=StdDdoc -Df.prerelease-dummy.html \
	  -Xfdocs-prerelease.json -I${PHOBOS_DIR} @.prerelease-files.txt
	${DPL_DOCS} filter docs-prerelease.json --min-protection=Protected \
	  --only-documented $(MOD_EXCLUDES_RELEASE)
	rm .prerelease-files.txt .prerelease-dummy.html

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
	DFLAGS="$(DPL_DOCS_DFLAGS)" ${DUB} build --root=${DPL_DOCS_PATH} \
		--compiler=${STABLE_DMD}

${STABLE_DMD}:
	mkdir -p ${STABLE_DMD_ROOT}
	TMPFILE=$$(mktemp deleteme.XXXXXXXX) && curl -fsSL ${STABLE_DMD_URL} > $${TMPFILE}.zip && \
		unzip -qd ${STABLE_DMD_ROOT} $${TMPFILE}.zip && rm $${TMPFILE}.zip

${DUB}: ${DUB_DIR} ${STABLE_DMD}
	cd ${DUB_DIR} && DC="$(abspath ${STABLE_DMD}) -conf=$(abspath ${STABLE_DMD_CONF})" ./build.sh

################################################################################
# Dman tags
################################################################################

d.tag : chmgen.d $(STABLE_DMD) $(ALL_FILES) phobos-release druntime-release
	$(STABLE_RDMD) chmgen.d --root=$(DOC_OUTPUT_DIR) --only-tags

.DELETE_ON_ERROR: # GNU Make directive (delete output files on error)
