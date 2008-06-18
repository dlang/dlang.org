# makefile to build html files for DMD

DMD=dmd

SRC= cpptod.dd ctod.dd pretod.dd cppstrings.dd cppcomplex.dd \
	cppdbc.dd index.dd overview.dd lex.dd module.dd dnews.dd \
	declaration.dd type.dd property.dd attribute.dd pragma.dd \
	expression.dd statement.dd arrays.dd struct.dd class.dd enum.dd \
	function.dd operatoroverloading.dd template.dd mixin.dd dbc.dd \
	version.dd errors.dd garbage.dd memory.dd float.dd iasm.dd \
	interface.dd portability.dd html.dd entity.dd \
	abi.dd windows.dd dll.dd htomodule.dd faq.dd \
	dstyle.dd wc.dd future.dd changelog.dd glossary.dd \
	acknowledgements.dd dcompiler.dd builtin.dd interfaceToC.dd \
	comparison.dd rationale.dd \
	ddoc.dd code_coverage.dd exception-safe.dd rdmd.dd \
	templates-revisited.dd warnings.dd ascii-table.dd \
	windbg.dd htod.dd \
	regular-expression.dd lazy-evaluation.dd \
	lisp-java-d.dd variadic-function-templates.dd howto-promote.dd \
	tuple.dd template-comparison.dd template-mixin.dd \
	final-const-invariant.dd const.dd traits.dd COM.dd cpp_interface.dd \
	hijack.dd const3.dd features2.dd safed.dd cpp0x.dd const-faq.dd

IMG=dmlogo.gif cpp1.gif d002.ico c1.gif d3.gif d4.gif d5.gif favicon.gif

TARGETS=cpptod.html ctod.html pretod.html cppstrings.html \
	cppcomplex.html cppdbc.html index.html overview.html lex.html \
	module.html dnews.html declaration.html type.html property.html \
	attribute.html pragma.html expression.html statement.html arrays.html \
	struct.html class.html enum.html function.html \
	operatoroverloading.html template.html mixin.html dbc.html \
	version.html errors.html garbage.html memory.html float.html iasm.html \
	interface.html portability.html html.html entity.html \
	abi.html windows.html dll.html htomodule.html faq.html \
	dstyle.html wc.html future.html changelog.html glossary.html \
	acknowledgements.html builtin.html interfaceToC.html \
	comparison.html rationale.html \
	ddoc.html code_coverage.html exception-safe.html rdmd.html \
	templates-revisited.html warnings.html ascii-table.html \
	windbg.html htod.html \
	regular-expression.html lazy-evaluation.html \
	lisp-java-d.html variadic-function-templates.html howto-promote.html \
	tuple.html template-comparison.html template-mixin.html \
	final-const-invariant.html const.html traits.html COM.html cpp_interface.html \
	hijack.html const3.html features2.html safed.html cpp0x.html const-faq.html \
	dmd-windows.html dmd-linux.html


target: $(TARGETS)

.d.html:
	$(DMD) -o- -c -D doc.ddoc $*.d

.dd.html:
	$(DMD) -o- -c -D doc.ddoc $*.dd

dmd-linux.html : doc.ddoc linux.ddoc dcompiler.dd
	$(DMD) -o- -c -D doc.ddoc linux.ddoc dcompiler.dd -Dfdmd-linux.html

dmd-windows.html : doc.ddoc windows.ddoc dcompiler.dd
	$(DMD) -o- -c -D doc.ddoc windows.ddoc dcompiler.dd -Dfdmd-windows.html

abi.html : doc.ddoc abi.dd

acknowledgements.html : doc.ddoc acknowledgements.dd

arrays.html : doc.ddoc arrays.dd

ascii-table.html : doc.ddoc ascii-table.dd

attribute.html : doc.ddoc attribute.dd

builtin.html : doc.ddoc builtin.dd

changelog.html : doc.ddoc changelog.dd

class.html : doc.ddoc class.dd

code_coverage.html : doc.ddoc code_coverage.dd

COM.html : doc.ddoc COM.dd

comparison.html : doc.ddoc comparison.dd

const.html : doc.ddoc const.dd

const3.html : doc.ddoc const3.dd

const-faq.html : doc.ddoc const-faq.dd

cpp_interface.html : doc.ddoc cpp_interface.dd

cppdbc.html : doc.ddoc cppdbc.dd

cppcomplex.html : doc.ddoc cppcomplex.dd

cpp0x.html : doc.ddoc cpp0x.dd

cppstrings.html : doc.ddoc cppstrings.dd

cpptod.html : doc.ddoc cpptod.dd

ctod.html : doc.ddoc ctod.dd

dbc.html : doc.ddoc dbc.dd

ddoc.html : doc.ddoc ddoc.dd

declaration.html : doc.ddoc declaration.dd

dll.html : doc.ddoc dll.dd

dnews.html : doc.ddoc dnews.dd

dstyle.html : doc.ddoc dstyle.dd

entity.html : doc.ddoc entity.dd

enum.html : doc.ddoc enum.dd

errors.html : doc.ddoc errors.dd

exception-safe.html : doc.ddoc exception-safe.dd

expression.html : doc.ddoc expression.dd

faq.html : doc.ddoc faq.dd

features2.html : doc.ddoc features2.dd

final-const-invariant.html : doc.ddoc final-const-invariant.dd

float.html : doc.ddoc float.dd

function.html : doc.ddoc function.dd

future.html : doc.ddoc future.dd

garbage.html : doc.ddoc garbage.dd

glossary.html : doc.ddoc glossary.dd

hijack.html : doc.ddoc hijack.dd

howto-promote.html : doc.ddoc howto-promote.dd

html.html : doc.ddoc html.dd

htod.html : doc.ddoc htod.dd

htomodule.html : doc.ddoc htomodule.dd

iasm.html : doc.ddoc iasm.dd

interface.html : doc.ddoc interface.dd

interfaceToC.html : doc.ddoc interfaceToC.dd

index.html : doc.ddoc index.dd

lazy-evaluation.html : doc.ddoc lazy-evaluation.dd

lex.html : doc.ddoc lex.dd

lisp-java-d.html : doc.ddoc lisp-java-d.dd

memory.html : doc.ddoc memory.dd

mixin.html : doc.ddoc mixin.dd

module.html : doc.ddoc module.dd

operatoroverloading.html : doc.ddoc operatoroverloading.dd

overview.html : doc.ddoc overview.dd

portability.html : doc.ddoc portability.dd

pragma.html : doc.ddoc pragma.dd

pretod.html : doc.ddoc pretod.dd

property.html : doc.ddoc property.dd

rationale.html : doc.ddoc rationale.dd

rdmd.html : doc.ddoc rdmd.dd

regular-expression.html : doc.ddoc regular-expression.dd

safed.html : doc.ddoc safed.dd

statement.html : doc.ddoc statement.dd

struct.html : doc.ddoc struct.dd

template.html : doc.ddoc template.dd

template-comparison.html : doc.ddoc template-comparison.dd

template-mixin.html : doc.ddoc template-mixin.dd

templates-revisited.html : doc.ddoc templates-revisited.dd

traits.html : doc.ddoc traits.dd

tuple.html : doc.ddoc tuple.dd

type.html : doc.ddoc type.dd

variadic-function-templates.html : doc.ddoc variadic-function-templates.dd

version.html : doc.ddoc version.dd

warnings.html : doc.ddoc warnings.dd

wc.html : doc.ddoc wc.dd

windbg.html : doc.ddoc windbg.dd

windows.html : doc.ddoc windows.dd

zip:
	del doc.zip
	zip32 doc win32.mak style.css print.css doc.ddoc windows.ddoc linux.ddoc
	zip32 doc $(SRC) download.html dcompiler.html
	zip32 doc $(IMG)

clean:
	del $(TARGETS)

