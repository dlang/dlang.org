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
GIT_HOME=https://github.com/D-Programming-Language
DPL_DOCS_PATH=dpl-docs
DPL_DOCS=$(DPL_DOCS_PATH)/dpl-docs
REMOTE_DIR=d-programming@digitalmars.com:data

# stable dub and dmd versions used to build dpl-docs
DUB_VER=0.9.22
STABLE_DMD_VER=2.066.1
STABLE_DMD_ROOT=/tmp/.stable_dmd-$(STABLE_DMD_VER)
STABLE_DMD_URL=http://downloads.dlang.org/releases/2014/dmd.$(STABLE_DMD_VER).$(OS).zip
STABLE_DMD=$(STABLE_DMD_ROOT)/dmd2/$(OS)/$(if $(filter $(OS),osx),bin,bin$(MODEL))/dmd

# rdmd must fetch the model, imports, and libs from the specified version
DFLAGS=-m$(MODEL) -I$(DRUNTIME_DIR)/import -I$(PHOBOS_DIR) -L-L$(PHOBOS_DIR)/generated/$(OS)/release/$(MODEL)
RDMD=rdmd --compiler=$(DMD) $(DFLAGS)

# Tools
REBASE = MYBRANCH=`git rev-parse --abbrev-ref HEAD` &&\
 git co master &&\
 git pull --ff-only upstream master &&\
 git co $$MYBRANCH &&\
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
endif
ifeq (,${LATEST})
  $(error Could not fetch latest version)
endif
$(info Current release: ${LATEST})

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

DDOC=$(addsuffix .ddoc, macros html dlang.org doc ${LATEST}) $(NODATETIME)
STD_DDOC=$(addsuffix .ddoc, macros html dlang.org ${LATEST} std std_navbar-$(LATEST))
STD_DDOC_PRE=$(addsuffix .ddoc, macros html dlang.org ${LATEST} std std_navbar-prerelease)

IMAGES=favicon.ico $(addprefix images/, \
	d002.ico icon_minus.svg icon_plus.svg \
	$(addsuffix .png, apple_logo centos_logo d3 debian_logo dlogo download \
		fedora_logo freebsd_logo opensuse_logo ubuntu_logo windows_logo \
		pattern github-ribbon \
		$(addprefix ddox/, alias class enum enummember function \
			inherited interface module package private property protected \
			struct template tree-item-closed tree-item-open variable)) \
	$(addsuffix .gif, c1 cpp1 d4 d5 dmlogo dmlogo-smaller globe \
		pen search-left search-bg search-button) \
	$(addsuffix .jpg, tdpl))

JAVASCRIPT=$(addsuffix .js, $(addprefix js/, \
	codemirror-compressed cssmenu ddox listanchors run run-main-website))

STYLES=$(addsuffix .css, $(addprefix css/, \
	style print codemirror ddox cssmenu))

PRETTIFY=prettify/prettify.css prettify/prettify.js

PREMADE=appendices.html articles.html fetch-issue-cnt.php	\
howtos.html language-reference.html robots.txt process.php

# Language spec root filenames. They have extension .dd in the source
# and .html in the generated HTML. These are also used for the mobi
# book generation, for which reason the list is sorted by chapter.
SPEC_ROOT=spec intro lex grammar module declaration type property attribute pragma	\
	expression statement arrays hash-map struct class interface enum	\
	const3 function operatoroverloading template template-mixin contracts		\
	version traits errors unittest garbage float iasm ddoc				\
	interfaceToC cpp_interface portability entity memory-safe-d abi		\
	simd

# Website root filenames. They have extension .dd in the source
# and .html in the generated HTML. Save for the expansion of
# $(SPEC_ROOT), the list is sorted alphabetically.
PAGES_ROOT=$(SPEC_ROOT) 32-64-portability acknowledgements ascii-table		\
	bugstats.php builtin changelog code_coverage concepts const-faq COM	\
	comparison cpptod ctod D1toD2 d-array-article d-floating-point		\
	deprecate dll dll-linux dmd-freebsd dmd-linux dmd-osx dmd-windows	\
	download dstyle exception-safe faq features2 glossary gsoc2011 gsoc2012	\
	gsoc2012-template hijack howto-promote htod htomodule index intro	\
	intro-to-datetime lazy-evaluation memory migrate-to-shared mixin	\
	overview pretod rationale rdmd regular-expression safed			\
	std_consolidated_header template-comparison templates-revisited tuple	\
	variadic-function-templates warnings wc windbg windows

TARGETS=$(addsuffix .html,$(PAGES_ROOT))

ALL_FILES_BUT_SITEMAP = $(addprefix $(DOC_OUTPUT_DIR)/, $(TARGETS)	\
$(PREMADE) $(STYLES) $(IMAGES) $(JAVASCRIPT) $(PRETTIFY))

ALL_FILES = $(ALL_FILES_BUT_SITEMAP) $(DOC_OUTPUT_DIR)/sitemap.html

# Pattern rulez

$(DOC_OUTPUT_DIR)/%.html : %.dd $(DDOC) $(DMD)
	$(DMD) -c -o- -Df$@ $(DDOC) $<

$(DOC_OUTPUT_DIR)/%.verbatim : %.dd verbatim.ddoc $(DMD)
	$(DMD) -c -o- -Df$@ verbatim.ddoc $<

$(DOC_OUTPUT_DIR)/%.php : %.php.dd $(DDOC) $(DMD)
	$(DMD) -c -o- -Df$@ $(DDOC) $<

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
	$(DMD) -c -o- -Df$@ $(DDOC) dcompiler.dd $<

$(DOC_OUTPUT_DIR)/dmd-%.verbatim : %.ddoc dcompiler.dd verbatim.ddoc $(DMD)
	$(DMD) -c -o- -Df$@ verbatim.ddoc dcompiler.dd $<

################################################################################
# Rulez
################################################################################

all : docs html

docs : phobos-prerelease druntime-prerelease druntime-release phobos-release	\
	apidocs-release apidocs-prerelease

html : $(ALL_FILES)

verbatim : $(addprefix $(DOC_OUTPUT_DIR)/, $(addsuffix .verbatim,$(PAGES_ROOT))) phobos-prerelease-verbatim

kindle : ${DOC_OUTPUT_DIR}/dlangspec.mobi

pdf : ${DOC_OUTPUT_DIR}/dlangspec.pdf

$(DOC_OUTPUT_DIR)/sitemap.html : $(ALL_FILES_BUT_SITEMAP) $(DMD)
	cp -f sitemap-template.dd sitemap.dd
	(true $(foreach F, $(TARGETS), \
	  && echo \
        "$F\t`sed -n 's/<title>\(.*\) - D Programming Language.*<\/title>/\1/'p $(DOC_OUTPUT_DIR)/$F`")) \
	  | sort --ignore-case --key=2 | sed 's/^\([^	]*\)	\(.*\)/<a href="\1">\2<\/a><p>/' >> sitemap.dd
	$(DMD) -c -o- -Df$@ $(DDOC) sitemap.dd
	rm -rf sitemap.dd

${LATEST}.ddoc :
	echo "LATEST=${LATEST}" >$@

# Run "make -j rebase" for rebasing all dox in parallel!
rebase: rebase-dlang rebase-dmd rebase-druntime rebase-phobos
rebase-dlang: ; $(REBASE)
rebase-dmd: ; cd $(DMD_DIR) && $(REBASE)
rebase-druntime: ; cd $(DRUNTIME_DIR) && $(REBASE)
rebase-phobos: ; cd $(PHOBOS_DIR) && $(REBASE)

clean:
	rm -rf $(DOC_OUTPUT_DIR) ${LATEST}.ddoc dpl-docs/.dub
	rm -rf auto dlangspec-consolidated.d $(addprefix dlangspec,.aux .d .dvi .fdb_latexmk .fls .log .out .pdf .tex .txt .verbatim.txt)
	rm -f docs.json docs-prerelease.json dpl-docs/dpl-docs 
	@echo You should issue manually: rm -rf ${DMD_DIR}-${LATEST} ${DRUNTIME_DIR}-${LATEST} ${PHOBOS_DIR}-${LATEST} ${STABLE_DMD_ROOT} ${DUB_DIR}

rsync : all kindle pdf
	rsync -avz $(DOC_OUTPUT_DIR)/ $(REMOTE_DIR)/

rsync-only :
	rsync -avz $(DOC_OUTPUT_DIR)/ $(REMOTE_DIR)/

################################################################################
# Ebook
################################################################################

dlangspec.d : $(addsuffix .dd,$(SPEC_ROOT))
	$(RDMD) ../tools/catdoc.d -o$@ $^

dlangspec.html : $(DDOC) ebook.ddoc dlangspec.d $(DMD)
	$(DMD) $(DDOC) ebook.ddoc dlangspec.d

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

dlangspec-consolidated.d : $(addsuffix .dd,$(SPEC_ROOT))
	$(RDMD) --force ../tools/catdoc.d -o$@ $^

dlangspec.tex : $(DMD) $(DDOC) latex.ddoc dlangspec-consolidated.d
	$(DMD) -Df$@ $(DDOC) latex.ddoc dlangspec-consolidated.d

# Run twice to fix multipage tables and \ref uses
dlangspec.dvi : dlangspec.tex
	latex $^
	latex $^

$(DOC_OUTPUT_DIR)/dlangspec.pdf : dlangspec.dvi
	dvipdf $^ $@

################################################################################
# Plaintext/verbatim generation - not part of the build, demo purposes only
################################################################################

dlangspec.txt : $(DMD) macros.ddoc plaintext.ddoc dlangspec-consolidated.d
	$(DMD) -Df$@ macros.ddoc plaintext.ddoc dlangspec-consolidated.d

dlangspec.verbatim.txt : $(DMD) verbatim.ddoc dlangspec-consolidated.d
	$(DMD) -Df$@ verbatim.ddoc dlangspec-consolidated.d

################################################################################
# Git rules
################################################################################

../%-${LATEST}/.cloned :
	[ -d $(@D) ] || git clone -b v${LATEST} --depth=1 ${GIT_HOME}/$* $(@D)/
	touch $@

../%-${DUB_VER}/.cloned :
	[ -d $(@D) ] || git clone -b v${DUB_VER} --depth=1 ${GIT_HOME}/$* $(@D)/
	touch $@

../%/.cloned :
	[ -d $(@D) ] || git clone --depth=1 ${GIT_HOME}/$* $(@D)/
	touch $@

################################################################################
# dmd compiler, latest released build and current build
################################################################################

$(DMD) : ${DMD_DIR}/.cloned
	${MAKE} --directory=${DMD_DIR}/src -f posix.mak -j 4

$(DMD_REL) : ${DMD_DIR}-${LATEST}/.cloned
	${MAKE} --directory=${DMD_DIR}-${LATEST}/src -f posix.mak -j 4

################################################################################
# druntime, latest released build and current build
################################################################################

druntime-prerelease : ${DRUNTIME_DIR}/.cloned ${DOC_OUTPUT_DIR}/phobos-prerelease/object.html $(STD_DDOC_PRE)
${DOC_OUTPUT_DIR}/phobos-prerelease/object.html : $(DMD)
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak -j 4 target doc \
		DOCDIR=${DOC_OUTPUT_DIR}/phobos-prerelease \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC_PRE))"

druntime-release : ${DRUNTIME_DIR}-${LATEST}/.cloned ${DOC_OUTPUT_DIR}/phobos/object.html $(STD_DDOC)
${DOC_OUTPUT_DIR}/phobos/object.html : $(DMD_REL)
	${MAKE} --directory=${DRUNTIME_DIR}-${LATEST} -f posix.mak target doc \
	  DMD=$(DMD_REL) \
	  DOCDIR=${DOC_OUTPUT_DIR}/phobos \
		DOCFMT="$(addprefix `pwd`/, $(STD_DDOC))"

druntime-prerelease-verbatim : ${DRUNTIME_DIR}/.cloned \
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
phobos-prerelease : ${PHOBOS_DIR}/.cloned ${DOC_OUTPUT_DIR}/phobos-prerelease/index.html
${DOC_OUTPUT_DIR}/phobos-prerelease/index.html : $(STD_DDOC_PRE) \
	    ${DOC_OUTPUT_DIR}/phobos-prerelease/object.html
	${MAKE} --directory=${PHOBOS_DIR} -f posix.mak \
	  STDDOC="$(addprefix `pwd`/, $(STD_DDOC_PRE))" \
	  DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos-prerelease html -j 4

phobos-release : ${PHOBOS_DIR}-${LATEST}/.cloned ${DOC_OUTPUT_DIR}/phobos/index.html
${DOC_OUTPUT_DIR}/phobos/index.html : $(DMD_REL) $(STD_DDOC) \
	    ${DOC_OUTPUT_DIR}/phobos/object.html
	${MAKE} --directory=${PHOBOS_DIR}-${LATEST} -f posix.mak -j 4 \
	  html \
	  DMD=$(DMD_REL) \
	  DRUNTIME_PATH=${DRUNTIME_DIR}-${LATEST} \
	  DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos \
	  STDDOC="$(addprefix `pwd`/, $(STD_DDOC))"

phobos-prerelease-verbatim : ${PHOBOS_DIR}/.cloned ${DOC_OUTPUT_DIR}/phobos-prerelease/index.verbatim
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

apidocs-prerelease : ${DOC_OUTPUT_DIR}/library-prerelease/sitemap.xml
apidocs-release : ${DOC_OUTPUT_DIR}/library/sitemap.xml
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

docs.json : ${DMD_REL} ${DRUNTIME_DIR}-${LATEST}/.cloned \
		${PHOBOS_DIR}-${LATEST}/.cloned | dpl-docs
	find ${DRUNTIME_DIR}-${LATEST}/src -name '*.d' | \
	  sed -e /unittest.d/d -e /gcstub/d > .release-files.txt
	find ${PHOBOS_DIR}-${LATEST} -name '*.d' | \
	  sed -e /unittest.d/d -e /format/d -e /windows/d >> .release-files.txt
	${DMD_REL} -c -o- -version=CoreDdoc -version=StdDdoc -Df.release-dummy.html \
	  -Xfdocs.json -I${PHOBOS_DIR}-${LATEST} @.release-files.txt
	${DPL_DOCS} filter docs.json --min-protection=Protected --only-documented \
	  --ex=gc. --ex=rt. --ex=core.internal. --ex=std.internal.
	rm .release-files.txt .release-dummy.html

docs-prerelease.json : ${DMD} ${DRUNTIME_DIR}/.cloned \
		${PHOBOS_DIR}/.cloned | dpl-docs
	find ${DRUNTIME_DIR}/src -name '*.d' | sed -e '/gcstub/d' \
	  -e /unittest/d > .prerelease-files.txt
	find ${PHOBOS_DIR} -name '*.d' | sed -e /unittest.d/d -e /format/d \
	  -e /windows/d >> .prerelease-files.txt
	${DMD} -c -o- -version=CoreDdoc -version=StdDdoc -Df.prerelease-dummy.html \
	  -Xfdocs-prerelease.json -I${PHOBOS_DIR} @.prerelease-files.txt
	${DPL_DOCS} filter docs-prerelease.json --min-protection=Protected \
	  --only-documented --ex=gc. --ex=rt. --ex=core.internal. --ex=std.internal.
	rm .prerelease-files.txt .prerelease-dummy.html

################################################################################
# binary targets for DDOX
################################################################################

.PHONY: dpl-docs
dpl-docs: ${DUB} ${STABLE_DMD}
	${DUB} build --root=${DPL_DOCS_PATH} --compiler=${STABLE_DMD}

${STABLE_DMD}:
	mkdir -p ${STABLE_DMD_ROOT}
	TMPFILE=$$(mktemp deleteme.XXXXXXXX) && curl -fsSL ${STABLE_DMD_URL} > $${TMPFILE}.zip && \
		unzip -qd ${STABLE_DMD_ROOT} $${TMPFILE}.zip && rm $${TMPFILE}.zip

${DUB}: ${DUB_DIR}/.cloned ${STABLE_DMD}
	cd ${DUB_DIR}; DC=$(abspath ${STABLE_DMD}) ./build.sh
