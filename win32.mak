# makefile to build html files for DMD

DMD=dmd

SRC= $(SPECSRC) cpptod.dd ctod.dd pretod.dd cppdbc.dd index.dd			\
	overview.dd mixin.dd memory.dd interface.dd windows.dd				\
	dll.dd htomodule.dd faq.dd dstyle.dd wc.dd changelog.dd				\
	glossary.dd acknowledgements.dd dcompiler.dd builtin.dd				\
	comparison.dd rationale.dd code_coverage.dd exception-safe.dd		\
	rdmd.dd templates-revisited.dd warnings.dd ascii-table.dd			\
	windbg.dd htod.dd regular-expression.dd lazy-evaluation.dd			\
	variadic-function-templates.dd howto-promote.dd tuple.dd			\
	template-comparison.dd COM.dd hijack.dd features2.dd safed.dd		\
	const-faq.dd concepts.dd d-floating-point.dd migrate-to-shared.dd	\
	D1toD2.dd pdf-intro-cover.dd pdf-spec-cover.dd pdf-tools-cover.dd	\
	intro-to-datetime.dd simd.dd deprecate.dd download.dd				\
	32-64-portability.dd dll-linux.dd

SPECSRC=spec.dd lex.dd module.dd declaration.dd type.dd property.dd		\
	attribute.dd pragma.dd expression.dd statement.dd arrays.dd			\
	hash-map.dd struct.dd class.dd interface.dd enum.dd const3.dd		\
	function.dd operatoroverloading.dd template.dd template-mixin.dd	\
	dbc.dd version.dd traits.dd errors.dd unittest.dd garbage.dd		\
	float.dd iasm.dd ddoc.dd interfaceToC.dd cpp_interface.dd			\
	portability.dd entity.dd memory-safe-d.dd abi.dd simd.dd

DDOC=macros.ddoc windows.ddoc doc.ddoc $(NODATETIME)

ASSETS=images\*.* css\*.*
IMG=dmlogo.gif cpp1.gif d002.ico c1.gif d3.png d4.gif d5.gif favicon.gif

PREMADE=dcompiler.html language-reference.html appendices.html howtos.html articles.html

TARGETS=cpptod.html ctod.html pretod.html cppdbc.html index.html		\
	overview.html lex.html module.html declaration.html					\
	type.html property.html attribute.html pragma.html					\
	expression.html statement.html arrays.html struct.html class.html	\
	enum.html function.html operatoroverloading.html template.html		\
	mixin.html dbc.html version.html errors.html garbage.html			\
	memory.html float.html iasm.html interface.html portability.html	\
	entity.html abi.html windows.html dll.html htomodule.html			\
	faq.html dstyle.html wc.html changelog.html glossary.html			\
	acknowledgements.html builtin.html interfaceToC.html				\
	comparison.html rationale.html ddoc.html code_coverage.html			\
	exception-safe.html rdmd.html templates-revisited.html				\
	warnings.html ascii-table.html windbg.html htod.html				\
	regular-expression.html lazy-evaluation.html						\
	variadic-function-templates.html howto-promote.html tuple.html		\
	template-comparison.html template-mixin.html traits.html COM.html	\
	cpp_interface.html hijack.html const3.html features2.html			\
	safed.html const-faq.html dmd-windows.html dmd-linux.html			\
	dmd-osx.html dmd-freebsd.html concepts.html memory-safe-d.html		\
	d-floating-point.html migrate-to-shared.html D1toD2.html			\
	unittest.html hash-map.html pdf-intro-cover.html					\
	pdf-spec-cover.html pdf-tools-cover.html intro-to-datetime.html		\
	simd.html deprecate.html download.html 32-64-portability.html \
        d-array-article.html dll-linux.html


PDFINTRO=index.html overview.html wc.html warnings.html builtin.html	\
	ctod.html cpptod.html pretod.html template-comparison.html			\
	cppdbc.html

PDFFEATURES=comparison.html features2.html

PDFFAQ=faq.html const-faq.html rationale.html

PDFSPEC=lex.html module.html declaration.html type.html property.html	\
	attribute.html pragma.html expression.html statement.html			\
	arrays.html hash-map.html struct.html class.html interface.html		\
	enum.html const3.html function.html operatoroverloading.html		\
	template.html template-mixin.html dbc.html version.html				\
	traits.html errors.html unittest.html garbage.html float.html		\
	iasm.html ddoc.html interfaceToC.html cpp_interface.html			\
	portability.html entity.html memory-safe-d.html abi.html simd.html

PDFHOWTOS=windows.html dll.html COM.html htomodule.html dll-linux.html

PDFARTICLES=d-floating-point.html migrate-to-shared.html hijack.html const3.html \
	memory.html exception-safe.html templates-revisited.html regular-expression.html \
	lazy-evaluation.html variadic-function-templates.html tuple.html mixin.html \
	safed.html intro-to-datetime.html d-array-article.html

PDFTOOLS=dmd-linux.html dmd-freebsd.html dmd-osx.html dmd-windows.html \
	http://www.digitalmars.com/ctg/optlink.html http://www.digitalmars.com/ctg/trace.html \
	code_coverage.html rdmd.html windbg.html htod.html

PDFAPPENDICES=dstyle.html glossary.html ascii-table.html acknowledgements.html

PDFOPTIONS=--header-left [section] --header-right [page] --header-spacing 3 --header-font-name Georgia --print-media-type --outline

PDFTARGETS=d-intro.pdf d-spec.pdf d-tools.pdf

CHMTARGETS=d.hhp d.hhc d.hhk d.chm

HHC=$(ProgramFiles)\HTML Help Workshop\hhc.exe

target: $(TARGETS)

.dd.html:
	$(DMD) -o- -c -D $(DDOC) $*.dd

.d.html:
	$(DMD) -o- -c -D $(DDOC) $*.d

dmd-linux.html : $(DDOC) linux.ddoc dcompiler.dd
	$(DMD) -o- -c -D $(DDOC) linux.ddoc dcompiler.dd -Dfdmd-linux.html

dmd-freebsd.html : $(DDOC) freebsd.ddoc dcompiler.dd
	$(DMD) -o- -c -D $(DDOC) freebsd.ddoc dcompiler.dd -Dfdmd-freebsd.html

dmd-osx.html : $(DDOC) osx.ddoc dcompiler.dd
	$(DMD) -o- -c -D $(DDOC) osx.ddoc dcompiler.dd -Dfdmd-osx.html

dmd-windows.html : $(DDOC) windows.ddoc dcompiler.dd
	$(DMD) -o- -c -D $(DDOC) windows.ddoc dcompiler.dd -Dfdmd-windows.html

32-64-portability.html : $(DDOC) 32-64-portability.dd

abi.html : $(DDOC) abi.dd

acknowledgements.html : $(DDOC) acknowledgements.dd

arrays.html : $(DDOC) arrays.dd

ascii-table.html : $(DDOC) ascii-table.dd

attribute.html : $(DDOC) attribute.dd

builtin.html : $(DDOC) builtin.dd

changelog.html : $(DDOC) changelog.dd

class.html : $(DDOC) class.dd

code_coverage.html : $(DDOC) code_coverage.dd

COM.html : $(DDOC) COM.dd

comparison.html : $(DDOC) comparison.dd

concepts.html : $(DDOC) concepts.dd

const3.html : $(DDOC) const3.dd

const-faq.html : $(DDOC) const-faq.dd

cpp_interface.html : $(DDOC) cpp_interface.dd

cppdbc.html : $(DDOC) cppdbc.dd

cpptod.html : $(DDOC) cpptod.dd

ctod.html : $(DDOC) ctod.dd

D1toD2.html : $(DDOC) D1toD2.dd

d-floating-point.html : $(DDOC) d-floating-point.dd

dbc.html : $(DDOC) dbc.dd

ddoc.html : $(DDOC) ddoc.dd

declaration.html : $(DDOC) declaration.dd

deprecate.html : $(DDOC) deprecate.dd

dll.html : $(DDOC) dll.dd

dll-linux.html : $(DDOC) dll-linux.dd

download.html : $(DDOC) download.dd

dstyle.html : $(DDOC) dstyle.dd

entity.html : $(DDOC) entity.dd

enum.html : $(DDOC) enum.dd

errors.html : $(DDOC) errors.dd

exception-safe.html : $(DDOC) exception-safe.dd

expression.html : $(DDOC) expression.dd

faq.html : $(DDOC) faq.dd

features2.html : $(DDOC) features2.dd

float.html : $(DDOC) float.dd

function.html : $(DDOC) function.dd

garbage.html : $(DDOC) garbage.dd

glossary.html : $(DDOC) glossary.dd

hash-map.html : $(DDOC) hash-map.dd

hijack.html : $(DDOC) hijack.dd

howto-promote.html : $(DDOC) howto-promote.dd

htod.html : $(DDOC) htod.dd

htomodule.html : $(DDOC) htomodule.dd

iasm.html : $(DDOC) iasm.dd

interface.html : $(DDOC) interface.dd

interfaceToC.html : $(DDOC) interfaceToC.dd

index.html : $(DDOC) index.dd

intro-to-datetime.html : $(DDOC) intro-to-datetime.dd

lazy-evaluation.html : $(DDOC) lazy-evaluation.dd

lex.html : $(DDOC) lex.dd

memory.html : $(DDOC) memory.dd

memory-safe-d.html : $(DDOC) memory-safe-d.dd

migrate-to-shared.html : $(DDOC) migrate-to-shared.dd

mixin.html : $(DDOC) mixin.dd

module.html : $(DDOC) module.dd

operatoroverloading.html : $(DDOC) operatoroverloading.dd

overview.html : $(DDOC) overview.dd

pdf-intro-cover.html : $(DDOC) pdf-intro-cover.dd

pdf-spec-cover.html : $(DDOC) pdf-spec-cover.dd

pdf-tools-cover.html : $(DDOC) pdf-tools-cover.dd

portability.html : $(DDOC) portability.dd

pragma.html : $(DDOC) pragma.dd

pretod.html : $(DDOC) pretod.dd

property.html : $(DDOC) property.dd

rationale.html : $(DDOC) rationale.dd

rdmd.html : $(DDOC) rdmd.dd

regular-expression.html : $(DDOC) regular-expression.dd

safed.html : $(DDOC) safed.dd

simd.html : $(DDOC) simd.dd

statement.html : $(DDOC) statement.dd

struct.html : $(DDOC) struct.dd

template.html : $(DDOC) template.dd

template-comparison.html : $(DDOC) template-comparison.dd

template-mixin.html : $(DDOC) template-mixin.dd

templates-revisited.html : $(DDOC) templates-revisited.dd

traits.html : $(DDOC) traits.dd

tuple.html : $(DDOC) tuple.dd

type.html : $(DDOC) type.dd

unittest.html : $(DDOC) unittest.dd

variadic-function-templates.html : $(DDOC) variadic-function-templates.dd

version.html : $(DDOC) version.dd

warnings.html : $(DDOC) warnings.dd

wc.html : $(DDOC) wc.dd

windbg.html : $(DDOC) windows.ddoc windbg.dd

windows.html : $(DDOC) windows.ddoc windows.dd

################ Ebook ########################

dlangspec.d : $(SPECSRC) win32.mak
	catdoc -o=dlangspec.d $(SPECSRC)

dlangspec.html : $(DDOC) ebook.ddoc dlangspec.d
	$(DMD) $(DDOC) ebook.ddoc dlangspec.d

dlangspec.zip : dlangspec.html ebook.css win32.mak
	del dlangspec.zip
	zip32 dlangspec dlangspec.html ebook.css

dlangspec.mobi : dlangspec.opf dlangspec.html dlangspec.png dlangspec.ncx ebook.css win32.mak
	del dlangspec.mobi
	kindlegen dlangspec.opf

################# Pdf #########################

pdf : $(PDFTARGETS)

d-intro.pdf:
	wkhtmltopdf $(PDFOPTIONS) cover pdf-intro-cover.html toc $(PDFINTRO) $(PDFFEATURES) $(PDFFAQ) $(PDFAPPENDICES) d-intro.pdf

d-spec.pdf:
	wkhtmltopdf $(PDFOPTIONS) cover pdf-spec-cover.html toc $(PDFSPEC) $(PDFAPPENDICES) d-spec.pdf

d-tools.pdf:
	wkhtmltopdf $(PDFOPTIONS) cover pdf-tools-cover.html toc $(PDFTOOLS) $(PDFHOWTOS) $(PDFARTICLES) $(PDFAPPENDICES) d-tools.pdf

################# CHM #########################

chm : d.chm

chmgen.exe : chmgen.d
	$(DMD) chmgen

d.hhp d.hhc d.hhk : chmgen.exe $(TARGETS)
	chmgen

d.chm : d.hhp d.hhc d.hhk
	cmd /C ""$(HHC)" d.hhp"

################# Other #########################

zip:
	del doc.zip
	zip32 doc win32.mak $(DDOC) windows.ddoc linux.ddoc osx.ddoc freebsd.ddoc ebook.ddoc
	zip32 doc $(SRC) $(PREMADE)
	zip32 doc $(ASSETS)
	zip32 doc ebook.css dlangspec.opf dlangspec.ncx dlangspec.png

clean:
	del $(TARGETS)
	del $(PDFTARGETS)
	del $(CHMTARGETS)
	del chmgen.obj chmgen.exe
	if exist chm rmdir /S /Q chm

