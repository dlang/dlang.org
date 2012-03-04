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
GIT_HOME=git@github.com:D-Programming-Language

# Latest released version
LATEST:=$(shell cd ${DMD_DIR} && git fetch --tags && \
git tag | grep '^v[0-9]\.[0-9]*$$' | sed 's/^v//' | sort -nr | head -n 1)
$(info Current release: ${LATEST})
ROOT_DIR=$(shell pwd)

# Documents

DDOC=macros.ddoc doc.ddoc ${LATEST}.ddoc

IMAGES=favicon.ico $(addprefix images/, c1.gif cpp1.gif d002.ico		\
d3.gif d4.gif d5.gif debian_logo.png dlogo.png dmlogo.gif				\
dmlogo-smaller.gif download.png fedora_logo.png freebsd_logo.png		\
github-ribbon.png gradient-green.jpg gradient-red.jpg globe.gif			\
linux_logo.png mac_logo.png opensuse_logo.png pen.gif search-left.gif	\
search-bg.gif search-button.gif tdpl.jpg ubuntu_logo.png				\
win32_logo.png)

STYLES=css/style.css css/print.css

PREMADE=dcompiler.html language-reference.html appendices.html	\
howtos.html articles.html fetch-issue-cnt.php robots.txt

TARGETS=32-64-portability.html cpptod.html ctod.html download.html		\
	pretod.html gsoc2011.html index.html overview.html spec.html		\
	intro.html lex.html module.html declaration.html type.html			\
	property.html attribute.html pragma.html expression.html			\
	statement.html arrays.html struct.html class.html enum.html			\
	function.html operatoroverloading.html template.html mixin.html		\
	dbc.html version.html errors.html garbage.html memory.html			\
	float.html iasm.html interface.html portability.html entity.html	\
	abi.html windows.html dll.html htomodule.html faq.html				\
	dstyle.html wc.html changelog.html glossary.html					\
	acknowledgements.html builtin.html interfaceToC.html				\
	comparison.html rationale.html ddoc.html code_coverage.html			\
	exception-safe.html rdmd.html templates-revisited.html				\
	warnings.html ascii-table.html windbg.html htod.html				\
	regular-expression.html lazy-evaluation.html						\
	variadic-function-templates.html howto-promote.html tuple.html		\
	template-comparison.html template-mixin.html traits.html COM.html	\
	cpp_interface.html hijack.html const3.html features2.html			\
	safed.html const-faq.html concepts.html memory-safe-d.html			\
	d-floating-point.html migrate-to-shared.html D1toD2.html			\
	unittest.html hash-map.html pdf-intro-cover.html					\
	pdf-spec-cover.html pdf-tools-cover.html intro-to-datetime.html		\
	std_consolidated_header.html simd.html dmd-windows.html				\
	dmd-linux.html dmd-freebsd.html dmd-osx.html bugstats.php

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
	mixin.html safed.html intro-to-datetime.html

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
$(PREMADE) $(STYLES) $(IMAGES))

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

all : html phobos-prerelease druntime-prerelease druntime-release phobos-release

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

zip:
	rm doc.zip
	zip32 doc win32.mak style.css $(DDOC)
	zip32 doc $(SRC) download.html
	zip32 doc $(IMAGES) $(STYLES)

clean:
	rm -rf $(DOC_OUTPUT_DIR) ${LATEST}.ddoc
	@echo You should issue manually: rm -rf ${DMD_DIR}.${LATEST} ${DRUNTIME_DIR}.${LATEST} ${PHOBOS_DIR}.${LATEST}

rsync : all
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
	${MAKE} --directory=${DRUNTIME_DIR} -f posix.mak \
		DOCDIR=${DOC_OUTPUT_DIR}/phobos-prerelease \
		DOCFMT=../d-programming-language.org/std.ddoc \
		doc -j 4

druntime-release : ${DOC_OUTPUT_DIR}/phobos/object.html
${DOC_OUTPUT_DIR}/phobos/object.html : ${DMD_DIR}.${LATEST}/src/dmd
	[ -d ${DRUNTIME_DIR}.${LATEST} ] || \
	  git clone ${GIT_HOME}/druntime ${DRUNTIME_DIR}.${LATEST}/
	cd ${DRUNTIME_DIR}.${LATEST} && git checkout v${LATEST}
	${MAKE} --directory=${DRUNTIME_DIR}.${LATEST} -f posix.mak clean
	${MAKE} --directory=${DRUNTIME_DIR}.${LATEST} -f posix.mak \
	  DMD=${DMD_DIR}.${LATEST}/src/dmd \
	  DOCDIR=${DOC_OUTPUT_DIR}/phobos \
	  DOCFMT=../d-programming-language.org/std.ddoc doc -j 4

################################################################################
# phobos, latest released build and current build
################################################################################

phobos-prerelease : ${DOC_OUTPUT_DIR}/phobos-prerelease/index.html
${DOC_OUTPUT_DIR}/phobos-prerelease/index.html : \
	    ${DOC_OUTPUT_DIR}/phobos-prerelease/object.html
	cd ${PHOBOS_DIR} && ${MAKE} -f posix.mak \
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
