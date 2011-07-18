# makefile to build html files for DMD

# Externals
DMD=dmd
PHOBOS=../phobos
DRUNTIME=../druntime
DOC_OUTPUT_DIR=../web

# Documents

DDOC=macros.ddoc windows.ddoc doc.ddoc

IMAGES=favicon.ico $(addprefix images/, c1.gif d3.gif dlogo.png			\
dmlogo.gif gradient-green.jpg search-bg.gif Thumbs.db cpp1.gif d4.gif	\
dmlogo-smaller.gif gradient-red.jpg search-button.gif d002.ico d5.gif	\
globe.gif pen.gif search-left.gif tdpl.jpg)

STYLES=css/style.css css/print.css

PREMADE=download.html dcompiler.html language-reference.html	\
appendices.html howtos.html articles.html

DDOC=macros.ddoc windows.ddoc doc.ddoc

TARGETS=cpptod.html ctod.html pretod.html cppstrings.html				\
	cppcomplex.html cppdbc.html gsoc2011.html index.html overview.html	\
	lex.html module.html dnews.html declaration.html type.html			\
	property.html attribute.html pragma.html expression.html			\
	statement.html arrays.html struct.html class.html enum.html			\
	function.html operatoroverloading.html template.html mixin.html		\
	dbc.html version.html errors.html garbage.html memory.html			\
	float.html iasm.html interface.html portability.html html.html		\
	entity.html abi.html windows.html dll.html htomodule.html faq.html	\
	dstyle.html wc.html future.html changelog.html glossary.html		\
	acknowledgements.html builtin.html interfaceToC.html				\
	comparison.html rationale.html ddoc.html code_coverage.html			\
	exception-safe.html rdmd.html templates-revisited.html				\
	warnings.html ascii-table.html windbg.html htod.html				\
	regular-expression.html lazy-evaluation.html lisp-java-d.html		\
	variadic-function-templates.html howto-promote.html tuple.html		\
	template-comparison.html template-mixin.html						\
	final-const-invariant.html const.html traits.html COM.html			\
	cpp_interface.html hijack.html const3.html features2.html			\
	safed.html cpp0x.html const-faq.html dmd-windows.html				\
	dmd-linux.html dmd-osx.html dmd-freebsd.html concepts.html			\
	memory-safe-d.html d-floating-point.html migrate-to-shared.html		\
	D1toD2.html unittest.html hash-map.html pdf-intro-cover.html		\
	pdf-spec-cover.html pdf-tools-cover.html intro-to-datetime.html std_consolidated_header.html

PDFINTRO=index.html overview.html wc.html warnings.html builtin.html	\
	ctod.html cpptod.html pretod.html template-comparison.html			\
	cppstrings.html cppcomplex.html cppdbc.html lisp-java-d.html		\
	cpp0x.html

PDFFEATURES=comparison.html features2.html

PDFFAQ=faq.html const-faq.html rationale.html future.html

PDFSPEC=lex.html module.html declaration.html type.html property.html	\
	attribute.html pragma.html expression.html statement.html			\
	arrays.html hash-map.html struct.html class.html interface.html		\
	enum.html const3.html function.html operatoroverloading.html		\
	template.html template-mixin.html dbc.html version.html				\
	traits.html errors.html unittest.html garbage.html float.html		\
	iasm.html ddoc.html interfaceToC.html cpp_interface.html			\
	portability.html html.html entity.html memory-safe-d.html abi.html

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

$(DOC_OUTPUT_DIR)/%.html : %.dd doc.ddoc
	$(DMD) -c -o- -Df$@ doc.ddoc $<

$(DOC_OUTPUT_DIR)/% : %
	@mkdir -p $(dir $@)
	cp $< $@

# Rulez

all : $(ALL_FILES) phobos druntime phobos-last-release druntime-last-release

all+pdf : $(ALL_FILES) $(PDFTARGETS)

$(DOC_OUTPUT_DIR)/sitemap.html : $(ALL_FILES_BUT_SITEMAP)
	cp -f sitemap-template.dd sitemap.dd
	true $(foreach F, $(sort $(TARGETS) $(IMAGES)), \
	  && echo "<a href=$F>`sed -n 's/<title>\(.*\)<\/title>/\1/'p $(DOC_OUTPUT_DIR)/$F`" \
	     "</a><p>" >> sitemap.dd)
	$(DMD) -c -o- -Df$@ doc.ddoc sitemap.dd
	rm -rf sitemap.dd

zip:
	rm doc.zip
	zip32 doc win32.mak style.css doc.ddoc
	zip32 doc $(SRC) download.html
	zip32 doc $(IMG)

clean:
	rm -rf $(DOC_OUTPUT_DIR)

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

phobos:
	cd ${PHOBOS} && make -f posix.mak \
		DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos-prerelease html -j 4

phobos-last-release:
	export TAG=$$(cd ${PHOBOS} && git tag | grep '^v' | sed 's/^v//' | sort -nr | head -n 1) && \
	  echo "Buidling Phobos version $$TAG in ${PHOBOS}-$$TAG" && \
	  if [ ! -d ${PHOBOS}-$$TAG ]; then \
	    mkdir ${PHOBOS}-$$TAG && \
	    cd ${PHOBOS}-$$TAG && \
	    git clone git@github.com:D-Programming-Language/phobos . ; \
	  else \
	    cd ${PHOBOS}-$$TAG ; \
	  fi && \
	  git checkout v$$TAG && \
	  make -f posix.mak \
		DOC_OUTPUT_DIR=${DOC_OUTPUT_DIR}/phobos html -j 4

druntime:
	cd ${DRUNTIME} && make -f posix.mak \
		DOCDIR=${DOC_OUTPUT_DIR}/phobos-prerelease \
		DOCFMT=../d-programming-language.org/std.ddoc \
		doc -j 4

druntime-last-release:
	cd ${DRUNTIME} && \
	  TAG=$$(git tag | sed 's/druntime.*-//' | sort -nr | head -n 1) && \
	  git checkout master && \
	  (git branch -D last-release || true) && \
	  git checkout -b last-release druntime-$$TAG && \
	  make -f posix.mak \
		DOCDIR=${DOC_OUTPUT_DIR}/phobos \
	    DOCFMT=../d-programming-language.org/std.ddoc doc -j 4 && \
	  git checkout master

rsync : all
	rsync -avz $(DOC_OUTPUT_DIR)/ d-programming@digitalmars.com:data/
