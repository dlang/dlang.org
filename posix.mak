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
DMD=dmd
DMD_DIR=../dmd
PHOBOS_DIR=../phobos
DRUNTIME_DIR=../druntime
DOC_OUTPUT_DIR=$(ROOT_DIR)/web

# Latest released version
ifeq (,${LATEST})
LATEST:=$(shell cd ${DMD_DIR} && \
  git fetch --tags ${GIT_HOME}/dmd && \
  git tag | grep '^v[0-9]\.[0-9]*$$' | sed 's/^v//' | sort -nr | head -n 1)
endif

ifeq (,${LATEST})
  $(error Could not fetch latest version)
endif
$(info Current release: ${LATEST})
ROOT_DIR=$(shell pwd)

# Documents

DDOC=macros.ddoc doc.ddoc ${LATEST}.ddoc $(NODATETIME)

IMAGES=favicon.ico $(addprefix images/, c1.gif cpp1.gif d002.ico		\
d3.gif d4.gif d5.gif debian_logo.png dlogo.png dmlogo.gif				\
dmlogo-smaller.gif download.png fedora_logo.png freebsd_logo.png		\
gentoo_logo.png github-ribbon.png gradient-green.jpg gradient-red.jpg	\
globe.gif linux_logo.png mac_logo.png opensuse_logo.png pen.gif			\
search-left.gif search-bg.gif search-button.gif tdpl.jpg				\
ubuntu_logo.png win32_logo.png)

JAVASCRIPT=$(addprefix js/, codemirror.js d.js hyphenate.js	\
run.js run-main-website.js)

STYLES=css/style.css css/print.css css/codemirror.css

PREMADE=appendices.html articles.html fetch-issue-cnt.php	\
howtos.html language-reference.html robots.txt process.php

# Language spec root filenames. They have extension .dd in the source
# and .html in the generated HTML. These are also used for the mobi
# book generation, for which reason the list is sorted by chapter.
SPEC_ROOT=spec lex module declaration type property attribute pragma	\
	expression statement arrays hash-map struct class interface enum	\
	const3 function operatoroverloading template template-mixin dbc		\
	version traits errors unittest garbage float iasm ddoc				\
	interfaceToC cpp_interface portability entity memory-safe-d abi		\
	simd

# Website root filenames. They have extension .dd in the source
# and .html in the generated HTML. Save for the expansion of
# $(SPEC_ROOT), the list is sorted alphabetically.
PAGES_ROOT=$(SPEC_ROOT) 32-64-portability acknowledgements				\
	ascii-table bugstats.php builtin changelog code_coverage concepts	\
	const-faq COM comparison cpptod ctod D1toD2 d-array-article			\
	d-floating-point deprecate dll dmd-freebsd dmd-linux dmd-osx		\
	dmd-windows download dstyle exception-safe faq features2 glossary	\
	gsoc2011 gsoc2012 gsoc2012-template 		\
	hijack howto-promote htod htomodule index intro intro-to-datetime	\
	lazy-evaluation memory migrate-to-shared mixin overview				\
	pdf-intro-cover pdf-spec-cover pdf-tools-cover pretod rationale		\
	rdmd regular-expression safed std_consolidated_header				\
	template-comparison templates-revisited tuple						\
	variadic-function-templates warnings wc windbg windows

TARGETS=$(addsuffix .html,$(PAGES_ROOT))

PDFINTRO=index.html overview.html wc.html warnings.html builtin.html	\
	ctod.html cpptod.html pretod.html template-comparison.html

PDFFEATURES=comparison.html features2.html

PDFFAQ=faq.html const-faq.html rationale.html

PDFSPEC=spec.html intro.html lex.html module.html declaration.html		\
	type.html property.html attribute.html pragma.html					\
	expression.html statement.html arrays.html hash-map.html			\
	struct.html class.html interface.html enum.html const3.html			\
	function.html operatoroverloading.html template.html				\
	template-mixin.html dbc.html version.html traits.html errors.html	\
	unittest.html garbage.html float.html iasm.html ddoc.html			\
	interfaceToC.html cpp_interface.html portability.html entity.html	\
	memory-safe-d.html abi.html simd.html

PDFHOWTOS=windows.html dll.html COM.html htomodule.html

PDFARTICLES=d-floating-point.html migrate-to-shared.html hijack.html	\
	const3.html memory.html exception-safe.html							\
	templates-revisited.html regular-expression.html					\
	lazy-evaluation.html variadic-function-templates.html tuple.html	\
	mixin.html safed.html intro-to-datetime.html d-array-article.html

PDFTOOLS=dmd-linux.html dmd-freebsd.html dmd-osx.html dmd-windows.html	\
	http://digitalmars.com/ctg/optlink.html								\
	http://digitalmars.com/ctg/trace.html code_coverage.html rdmd.html	\
	windbg.html htod.html

PDFAPPENDICES=dstyle.html glossary.html ascii-table.html	\
acknowledgements.html

PDFOPTIONS=--header-left [section] --header-right [page]			\
--header-spacing 3 --header-font-name Georgia --print-media-type	\
--outline

PDFTARGETS=d-intro.pdf d-spec.pdf d-tools.pdf

ALL_FILES_BUT_SITEMAP = $(addprefix $(DOC_OUTPUT_DIR)/, $(TARGETS)	\
$(PREMADE) $(STYLES) $(IMAGES) $(JAVASCRIPT))

ALL_FILES = $(ALL_FILES_BUT_SITEMAP) $(DOC_OUTPUT_DIR)/sitemap.html

# Pattern rulez

$(DOC_OUTPUT_DIR)/%.html : %.dd $(DDOC)
	$(DMD) -c -o- -Df$@ $(DDOC) $<

$(DOC_OUTPUT_DIR)/%.php : %.php.dd $(DDOC)
	$(DMD) -c -o- -Df$@ $(DDOC) $<

$(DOC_OUTPUT_DIR)/% : %
	@mkdir -p $(dir $@)
	cp $< $@

$(DOC_OUTPUT_DIR)/dmd-%.html : %.ddoc dcompiler.dd $(DDOC)
	$(DMD) -c -o- -Df$@ $(DDOC) dcompiler.dd $<

################################################################################
# Rulez
################################################################################

all : phobos-prerelease druntime-prerelease druntime-release phobos-release \
	html ${DOC_OUTPUT_DIR}/dlangspec.mobi ${DOC_OUTPUT_DIR}/dlangspec.pdf

all+pdf : $(ALL_FILES) $(PDFTARGETS)

html : $(ALL_FILES)

$(DOC_OUTPUT_DIR)/sitemap.html : $(ALL_FILES_BUT_SITEMAP)
	cp -f sitemap-template.dd sitemap.dd
	(true $(foreach F, $(TARGETS), \
	  && echo \
        "$F\t`sed -n 's/<title>\(.*\) - D Programming Language.*<\/title>/\1/'p $(DOC_OUTPUT_DIR)/$F`")) \
	  | sort --ignore-case --key=2 | sed 's/^\([^	]*\)	\(.*\)/<a href="\1">\2<\/a><p>/' >> sitemap.dd
	$(DMD) -c -o- -Df$@ $(DDOC) sitemap.dd
	rm -rf sitemap.dd

${LATEST}.ddoc :
	echo "LATEST=${LATEST}" >$@

clean:
	rm -rf $(DOC_OUTPUT_DIR) ${LATEST}.ddoc
	rm -rf auto dlangspec-tex.d $(addprefix dlangspec,.aux .d .dvi .fdb_latexmk .fls .log .out .pdf .tex)
	@echo You should issue manually: rm -rf ${DMD_DIR}.${LATEST} ${DRUNTIME_DIR}.${LATEST} ${PHOBOS_DIR}.${LATEST}

rsync : all
	rsync -avz $(DOC_OUTPUT_DIR)/ d-programming@digitalmars.com:data/

rsync-only :
	rsync -avz $(DOC_OUTPUT_DIR)/ d-programming@digitalmars.com:data/

pdf : $(PDFTARGETS)

d-intro.pdf:
	wkhtmltopdf $(PDFOPTIONS) cover pdf-intro-cover.html toc			\
	  $(addprefix $(DOC_OUTPUT_DIR)/, $(PDFINTRO)) $(addprefix			\
	  $(DOC_OUTPUT_DIR)/, $(PDFFEATURES)) $(addprefix					\
	  $(DOC_OUTPUT_DIR)/, $(PDFFAQ)) $(addprefix $(DOC_OUTPUT_DIR)/,	\
	  $(PDFAPPENDICES)) $(DOC_OUTPUT_DIR)/d-intro.pdf

d-spec.pdf:
	wkhtmltopdf $(PDFOPTIONS) cover pdf-spec-cover.html toc		\
	  $(addprefix $(DOC_OUTPUT_DIR)/, $(PDFSPEC)) $(addprefix	\
	  $(DOC_OUTPUT_DIR)/, $(PDFAPPENDICES))						\
	  $(DOC_OUTPUT_DIR)/d-spec.pdf

d-tools.pdf:
	wkhtmltopdf $(PDFOPTIONS) cover pdf-tools-cover.html toc	\
	  $(addprefix $(DOC_OUTPUT_DIR)/, $(PDFTOOLS)) $(addprefix	\
	  $(DOC_OUTPUT_DIR)/, $(PDFHOWTOS)) $(addprefix				\
	  $(DOC_OUTPUT_DIR)/, $(PDFARTICLES)) $(addprefix			\
	  $(DOC_OUTPUT_DIR)/, $(PDFAPPENDICES))						\
	  $(DOC_OUTPUT_DIR)/d-tools.pdf

################################################################################
# Ebook
################################################################################

dlangspec.d : $(addsuffix .dd,$(SPEC_ROOT))
	rdmd ../tools/catdoc.d -o=$@ $^

dlangspec.html : $(DDOC) ebook.ddoc dlangspec.d
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

dlangspec-tex.d : $(addsuffix .dd,$(SPEC_ROOT))
	rdmd --force ../tools/catdoc.d -o=$@ $^

dlangspec.tex : $(DDOC) latex.ddoc dlangspec-tex.d
	$(DMD) -Df$@ $^

# Run twice to fix multipage tables and \ref uses
dlangspec.dvi : dlangspec.tex
	latex $^
	latex $^

$(DOC_OUTPUT_DIR)/dlangspec.pdf : dlangspec.dvi
	dvipdf $^ $@

################################################################################
# dmd compiler, latest released build and current build
################################################################################

${DMD_DIR}.${LATEST}/src/dmd :
	[ -d ${DMD_DIR}.${LATEST} ] || \
	  git clone ${GIT_HOME}/dmd ${DMD_DIR}.${LATEST}/
	cd ${DMD_DIR}.${LATEST} && git checkout v${LATEST}
	${MAKE} --directory=${DMD_DIR}.${LATEST}/src -f posix.mak clean
	${MAKE} --directory=${DMD_DIR}.${LATEST}/src -f posix.mak -j 4

${DMD_DIR}/src/dmd :
	[ -d ${DMD_DIR} ] || git clone ${GIT_HOME}/dmd ${DMD_DIR}/
	${MAKE} --directory=${DMD_DIR}/src -f posix.mak clean
	${MAKE} --directory=${DMD_DIR}/src -f posix.mak -j 4

################################################################################
# druntime, latest released build and current build
################################################################################

druntime-prerelease : ${DOC_OUTPUT_DIR}/phobos-prerelease/object.html
${DOC_OUTPUT_DIR}/phobos-prerelease/object.html : ${DMD_DIR}/src/dmd
	rm -f $@
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak -j 4 \
		DOCDIR=${DOC_OUTPUT_DIR}/phobos-prerelease \
		DOCFMT=../d-programming-language.org/std.ddoc

druntime-release : ${DOC_OUTPUT_DIR}/phobos/object.html
${DOC_OUTPUT_DIR}/phobos/object.html : ${DMD_DIR}.${LATEST}/src/dmd
	rm -f $@
	[ -d ${DRUNTIME_DIR}.${LATEST} ] || \
	  git clone ${GIT_HOME}/druntime ${DRUNTIME_DIR}.${LATEST}/
	cd ${DRUNTIME_DIR}.${LATEST} && git checkout v${LATEST}
	${MAKE} --directory=${DRUNTIME_DIR}.${LATEST} -f posix.mak clean
	${MAKE} --directory=${DRUNTIME_DIR}.${LATEST} -f posix.mak \
	  DMD=${DMD_DIR}.${LATEST}/src/dmd \
	  DOCDIR=${DOC_OUTPUT_DIR}/phobos \
	  DOCFMT=../d-programming-language.org/std.ddoc -j 4

################################################################################
# phobos, latest released build and current build
################################################################################

phobos-prerelease : ${DOC_OUTPUT_DIR}/phobos-prerelease/index.html
${DOC_OUTPUT_DIR}/phobos-prerelease/index.html : \
	    ${DOC_OUTPUT_DIR}/phobos-prerelease/object.html
	${MAKE} --directory=${PHOBOS_DIR} -f posix.mak \
	  DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos-prerelease html -j 4

phobos-release: ${DOC_OUTPUT_DIR}/phobos/index.html
${DOC_OUTPUT_DIR}/phobos/index.html : \
	    ${DOC_OUTPUT_DIR}/phobos/object.html
	[ -d ${PHOBOS_DIR}.${LATEST} ] || \
	  git clone ${GIT_HOME}/phobos ${PHOBOS_DIR}.${LATEST}/
	cd ${PHOBOS_DIR}.${LATEST} && git checkout v${LATEST}
	${MAKE} --directory=${PHOBOS_DIR}.${LATEST} -f posix.mak -j 4 \
	  release html \
	  DMD=${DMD_DIR}.${LATEST}/src/dmd \
	  DDOC=${DMD_DIR}.${LATEST}/src/dmd \
	  DRUNTIME_PATH=${DRUNTIME_DIR}.${LATEST} \
	  DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos
