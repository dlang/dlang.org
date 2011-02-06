# makefile to build html files for DMD

DMD=dmd

DDOC=macros.ddoc windows.ddoc doc.ddoc

IMAGES=$(addprefix images/, c1.gif d3.gif dmlogo.gif					\
gradient-green.jpg search-bg.gif Thumbs.db cpp1.gif d4.gif				\
dmlogo-smaller.gif gradient-red.jpg search-button.gif d002.ico d5.gif	\
globe.gif pen.gif search-left.gif)

STYLES=css/style.css css/print.css

PREMADE=download.html dcompiler.html language-reference.html	\
appendices.html howtos.html articles.html

DDOC=macros.ddoc windows.ddoc doc.ddoc

DOC_OUTPUT_DIR=../web

TARGETS=cpptod.html ctod.html pretod.html cppstrings.html				\
	cppcomplex.html cppdbc.html index.html overview.html lex.html		\
	module.html dnews.html declaration.html type.html property.html		\
	attribute.html pragma.html expression.html statement.html			\
	arrays.html struct.html class.html enum.html function.html			\
	operatoroverloading.html template.html mixin.html dbc.html			\
	version.html errors.html garbage.html memory.html float.html		\
	iasm.html interface.html portability.html html.html entity.html		\
	abi.html windows.html dll.html htomodule.html faq.html dstyle.html	\
	wc.html future.html changelog.html glossary.html					\
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
	pdf-spec-cover.html pdf-tools-cover.html
#TARGETS:=$(addprefix $(DOC_OUTPUT_DIR)/,$(TARGETS))

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
	mixin.html safed.html

PDFTOOLS=dmd-linux.html dmd-freebsd.html dmd-osx.html dmd-windows.html	\
	http://www.digitalmars.com/ctg/optlink.html							\
	http://www.digitalmars.com/ctg/trace.html code_coverage.html		\
	rdmd.html windbg.html htod.html

PDFAPPENDICES=dstyle.html glossary.html ascii-table.html	\
acknowledgements.html

PDFOPTIONS=--header-left [section] --header-right [page]			\
--header-spacing 3 --header-font-name Georgia --print-media-type	\
--outline

PDFTARGETS=d-intro.pdf d-spec.pdf d-tools.pdf

ALL_FILES_BUT_MAP = $(addprefix $(DOC_OUTPUT_DIR)/, $(TARGETS)	\
$(PREMADE) $(STYLES) $(IMAGES))

ALL_FILES = $(ALL_FILES_BUT_MAP) $(DOC_OUTPUT_DIR)/siteindex.html

# Pattern rulez

$(DOC_OUTPUT_DIR)/%.html : %.dd doc.ddoc
	$(DMD) -c -o- -Df$@ doc.ddoc $<

$(DOC_OUTPUT_DIR)/% : %
	@mkdir -p $(dir $@)
	cp $< $@

# Rulez

all : $(ALL_FILES)

all+pdf : $(ALL_FILES) $(PDFTARGETS)

$(DOC_OUTPUT_DIR)/siteindex.html : $(ALL_FILES_BUT_MAP)
	cp -f siteindex-template.dd siteindex.dd
	true $(foreach F, $(sort $(TARGETS) $(IMAGES)), \
	  && echo "<a href=$F>`sed -n 's/<title>\(.*\)<\/title>/\1/'p $(DOC_OUTPUT_DIR)/$F`" \
	     "</a><p>" >> siteindex.dd)
	$(DMD) -c -o- -Df$@ doc.ddoc siteindex.dd
	rm -rf siteindex.dd

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

rsync : all
	cd ../phobos && make -f posix.mak html -j 4
	rsync -avz $(DOC_OUTPUT_DIR)/ d-programming@digitalmars.com:data/

commit-phobos:
	ssh d-programming@digitalmars.com "rm -rf data/phobos/* && \
      cp -fr data/phobos-prerelease/* data/phobos/"
