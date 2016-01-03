# makefile to build html files for DMD

LATEST=prerelease

DMD=dmd
DPL_DOCS_PATH=dpl-docs
DPL_DOCS=dub run --root $(DPL_DOCS_PATH) --

SRC= $(SPECSRC) cpptod.dd ctod.dd pretod.dd cppcontracts.dd index.dd overview.dd	\
	mixin.dd memory.dd interface.dd windows.dd dll.dd htomodule.dd faq.dd	\
	dstyle.dd wc.dd \
	changelog\2.000.dd changelog\2.001.dd changelog\2.002.dd \
	changelog\2.003.dd changelog\2.004.dd changelog\2.005.dd \
	changelog\2.006.dd changelog\2.007.dd changelog\2.008.dd \
	changelog\2.009.dd changelog\2.010.dd changelog\2.011.dd \
	changelog\2.012.dd changelog\2.013.dd changelog\2.014.dd \
	changelog\2.015.dd changelog\2.016.dd changelog\2.017.dd \
	changelog\2.018.dd changelog\2.019.dd changelog\2.020.dd \
	changelog\2.021.dd changelog\2.022.dd changelog\2.023.dd \
	changelog\2.025.dd changelog\2.026.dd changelog\2.027.dd \
	changelog\2.028.dd changelog\2.029.dd changelog\2.030.dd \
	changelog\2.031.dd changelog\2.032.dd changelog\2.033.dd \
	changelog\2.034.dd changelog\2.035.dd changelog\2.036.dd \
	changelog\2.037.dd changelog\2.038.dd changelog\2.039.dd \
	changelog\2.040.dd changelog\2.041.dd changelog\2.042.dd \
	changelog\2.043.dd changelog\2.044.dd changelog\2.045.dd \
	changelog\2.046.dd changelog\2.047.dd changelog\2.048.dd \
	changelog\2.049.dd changelog\2.050.dd changelog\2.051.dd \
	changelog\2.052.dd changelog\2.053.dd changelog\2.054.dd \
	changelog\2.055.dd changelog\2.056.dd changelog\2.057.dd \
	changelog\2.058.dd changelog\2.059.dd changelog\2.060.dd \
	changelog\2.061.dd changelog\2.062.dd changelog\2.063.dd \
	changelog\2.064.dd changelog\2.065.0.dd \
	changelog\2.066.0.dd changelog\2.066.1.dd \
	changelog\2.067.0.dd changelog\2.067.1.dd \
	changelog\2.068.0.dd changelog\2.068.1.dd \
	changelog\2.068.2.dd changelog\2.069.0.dd changelog\2.069.1.dd \
	changelog\2.069.2_pre.dd \
	changelog\index.dd \
	glossary.dd acknowledgements.dd		\
	dcompiler.dd builtin.dd comparison.dd rationale.dd code_coverage.dd	\
	exception-safe.dd rdmd.dd templates-revisited.dd warnings.dd		\
	ascii-table.dd windbg.dd htod.dd regular-expression.dd			\
	lazy-evaluation.dd variadic-function-templates.dd howto-promote.dd	\
	tuple.dd template-comparison.dd COM.dd hijack.dd features2.dd safed.dd	\
	const-faq.dd concepts.dd d-floating-point.dd migrate-to-shared.dd	\
	D1toD2.dd intro-to-datetime.dd simd.dd deprecate.dd download.dd		\
	32-64-portability.dd dll-linux.dd bugstats.php.dd getstarted.dd \
	css\cssmenu.css.dd ctarguments.dd

SPECSRC=spec\spec.dd spec\intro.dd spec\lex.dd \
	spec\grammar.dd spec\module.dd spec\declaration.dd \
	spec\type.dd spec\property.dd spec\attribute.dd \
	spec\pragma.dd spec\expression.dd spec\statement.dd \
	spec\arrays.dd spec\hash-map.dd spec\struct.dd \
	spec\class.dd spec\interface.dd spec\enum.dd \
	spec\const3.dd spec\function.dd \
	spec\operatoroverloading.dd spec\template.dd \
	spec\template-mixin.dd spec\contracts.dd spec\version.dd \
	spec\traits.dd spec\errors.dd spec\unittest.dd \
	spec\garbage.dd spec\float.dd spec\iasm.dd \
	spec\ddoc.dd spec\interfaceToC.dd spec\cpp_interface.dd \
	spec\objc_interface.dd spec\portability.dd spec\entity.dd \
	spec\memory-safe-d.dd spec\abi.dd spec\simd.dd

DDOC=macros.ddoc html.ddoc dlang.org.ddoc windows.ddoc doc.ddoc $(NODATETIME)
LANGUAGE_DDOC=$(DDOC) spec\spec.ddoc

DDOC_STD=std.ddoc std_navbar-release.ddoc modlist-release.ddoc

CHANGELOG_DDOC=$(DDOC) changelog/changelog.ddoc
CHANGELOG_PRE_DDOC=$(CHANGELOG_DDOC) changelog/prerelease.ddoc

ASSETS=images\*.* css\*.*
IMG=dmlogo.gif cpp1.gif d002.ico c1.gif d3.png d4.gif d5.gif favicon.gif

PREMADE=dcompiler.html language-reference.html appendices.html howtos.html articles.html d-keyring.gpg

SPECTARGETS=spec\spec.html spec\intro.html spec\lex.html \
	spec\grammar.html spec\module.html spec\declaration.html \
	spec\type.html spec\property.html spec\attribute.html \
	spec\pragma.html spec\expression.html spec\statement.html \
	spec\arrays.html spec\hash-map.html spec\struct.html \
	spec\class.html spec\interface.html spec\enum.html \
	spec\const3.html spec\function.html \
	spec\operatoroverloading.html spec\template.html \
	spec\template-mixin.html spec\contracts.html spec\version.html \
	spec\traits.html spec\errors.html spec\unittest.html \
	spec\garbage.html spec\float.html spec\iasm.html \
	spec\ddoc.html spec\interfaceToC.html spec\cpp_interface.html \
	spec\objc_interface.html spec\portability.html spec\entity.html \
	spec\memory-safe-d.html spec\abi.html spec\simd.html

TARGETS= $(SPECTARGETS) cpptod.html ctod.html pretod.html cppcontracts.html index.html overview.html	\
	mixin.html memory.html windows.html \
	dll.html htomodule.html faq.html dstyle.html wc.html \
	changelog\2.000.html changelog\2.001.html changelog\2.002.html \
	changelog\2.003.html changelog\2.004.html changelog\2.005.html \
	changelog\2.006.html changelog\2.007.html changelog\2.008.html \
	changelog\2.009.html changelog\2.010.html changelog\2.011.html \
	changelog\2.012.html changelog\2.013.html changelog\2.014.html \
	changelog\2.015.html changelog\2.016.html changelog\2.017.html \
	changelog\2.018.html changelog\2.019.html changelog\2.020.html \
	changelog\2.021.html changelog\2.022.html changelog\2.023.html \
	changelog\2.025.html changelog\2.026.html changelog\2.027.html \
	changelog\2.028.html changelog\2.029.html changelog\2.030.html \
	changelog\2.031.html changelog\2.032.html changelog\2.033.html \
	changelog\2.034.html changelog\2.035.html changelog\2.036.html \
	changelog\2.037.html changelog\2.038.html changelog\2.039.html \
	changelog\2.040.html changelog\2.041.html changelog\2.042.html \
	changelog\2.043.html changelog\2.044.html changelog\2.045.html \
	changelog\2.046.html changelog\2.047.html changelog\2.048.html \
	changelog\2.049.html changelog\2.050.html changelog\2.051.html \
	changelog\2.052.html changelog\2.053.html changelog\2.054.html \
	changelog\2.055.html changelog\2.056.html changelog\2.057.html \
	changelog\2.058.html changelog\2.059.html changelog\2.060.html \
	changelog\2.061.html changelog\2.062.html changelog\2.063.html \
	changelog\2.064.html changelog\2.065.0.html \
	changelog\2.066.0.html changelog\2.066.1.html \
	changelog\2.067.0.html changelog\2.067.1.html \
	changelog\2.068.0.html changelog\2.068.1.html \
	changelog\2.068.2.html changelog\2.069.0.html changelog\2.069.1.html \
	changelog\index.html \
	glossary.html acknowledgements.html builtin.html \
	comparison.html rationale.html code_coverage.html \
	exception-safe.html rdmd.html templates-revisited.html warnings.html	\
	ascii-table.html windbg.html htod.html regular-expression.html		\
	lazy-evaluation.html variadic-function-templates.html			\
	howto-promote.html tuple.html template-comparison.html			\
	COM.html hijack.html \
	features2.html safed.html const-faq.html dmd-windows.html \
	dmd-linux.html dmd-osx.html dmd-freebsd.html concepts.html		\
	d-floating-point.html migrate-to-shared.html \
	D1toD2.html intro-to-datetime.html \
	deprecate.html download.html 32-64-portability.html \
	d-array-article.html dll-linux.html bugstats.php.html getstarted.html \
	gpg_keys.html forum-template.html css/cssmenu.css ctarguments.html

# exclude list
MOD_EXCLUDES_RELEASE=--ex=gc. --ex=rt. --ex=core.internal. --ex=core.stdc.config --ex=core.sys. \
	--ex=std.c. --ex=std.algorithm.internal --ex=std.internal. --ex=std.regex.internal. \
	--ex=std.typelist --ex=std.windows. --ex=etc.linux.memoryerror \
	--ex=core.stdc. --ex=std.stream --ex=std.cstream --ex=socketstream \
	--ex=std.experimental.ndslice.internal

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

acknowledgements.html : $(DDOC) acknowledgements.dd

ascii-table.html : $(DDOC) ascii-table.dd

bug-stats.php.html : $(DDOC) bug-stats.php.dd

builtin.html : $(DDOC) builtin.dd

changelog\2.000.html : $(CHANGELOG_DDOC) changelog\2.000.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.001.html : $(CHANGELOG_DDOC) changelog\2.001.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.002.html : $(CHANGELOG_DDOC) changelog\2.002.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.003.html : $(CHANGELOG_DDOC) changelog\2.003.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.004.html : $(CHANGELOG_DDOC) changelog\2.004.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.005.html : $(CHANGELOG_DDOC) changelog\2.005.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.006.html : $(CHANGELOG_DDOC) changelog\2.006.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.007.html : $(CHANGELOG_DDOC) changelog\2.007.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.008.html : $(CHANGELOG_DDOC) changelog\2.008.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.009.html : $(CHANGELOG_DDOC) changelog\2.009.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.010.html : $(CHANGELOG_DDOC) changelog\2.010.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.011.html : $(CHANGELOG_DDOC) changelog\2.011.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.012.html : $(CHANGELOG_DDOC) changelog\2.012.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.013.html : $(CHANGELOG_DDOC) changelog\2.013.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.014.html : $(CHANGELOG_DDOC) changelog\2.014.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.015.html : $(CHANGELOG_DDOC) changelog\2.015.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.016.html : $(CHANGELOG_DDOC) changelog\2.016.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.017.html : $(CHANGELOG_DDOC) changelog\2.017.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.018.html : $(CHANGELOG_DDOC) changelog\2.018.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.019.html : $(CHANGELOG_DDOC) changelog\2.019.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.020.html : $(CHANGELOG_DDOC) changelog\2.020.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.021.html : $(CHANGELOG_DDOC) changelog\2.021.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.022.html : $(CHANGELOG_DDOC) changelog\2.022.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.023.html : $(CHANGELOG_DDOC) changelog\2.023.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.025.html : $(CHANGELOG_DDOC) changelog\2.025.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.026.html : $(CHANGELOG_DDOC) changelog\2.026.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.027.html : $(CHANGELOG_DDOC) changelog\2.027.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.028.html : $(CHANGELOG_DDOC) changelog\2.028.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.029.html : $(CHANGELOG_DDOC) changelog\2.029.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.030.html : $(CHANGELOG_DDOC) changelog\2.030.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.031.html : $(CHANGELOG_DDOC) changelog\2.031.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.032.html : $(CHANGELOG_DDOC) changelog\2.032.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.033.html : $(CHANGELOG_DDOC) changelog\2.033.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.034.html : $(CHANGELOG_DDOC) changelog\2.034.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.035.html : $(CHANGELOG_DDOC) changelog\2.035.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.036.html : $(CHANGELOG_DDOC) changelog\2.036.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.037.html : $(CHANGELOG_DDOC) changelog\2.037.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.038.html : $(CHANGELOG_DDOC) changelog\2.038.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.039.html : $(CHANGELOG_DDOC) changelog\2.039.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.040.html : $(CHANGELOG_DDOC) changelog\2.040.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.041.html : $(CHANGELOG_DDOC) changelog\2.041.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.042.html : $(CHANGELOG_DDOC) changelog\2.042.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.043.html : $(CHANGELOG_DDOC) changelog\2.043.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.044.html : $(CHANGELOG_DDOC) changelog\2.044.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.045.html : $(CHANGELOG_DDOC) changelog\2.045.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.046.html : $(CHANGELOG_DDOC) changelog\2.046.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.047.html : $(CHANGELOG_DDOC) changelog\2.047.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.048.html : $(CHANGELOG_DDOC) changelog\2.048.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.049.html : $(CHANGELOG_DDOC) changelog\2.049.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.050.html : $(CHANGELOG_DDOC) changelog\2.050.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.051.html : $(CHANGELOG_DDOC) changelog\2.051.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.052.html : $(CHANGELOG_DDOC) changelog\2.052.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.053.html : $(CHANGELOG_DDOC) changelog\2.053.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.054.html : $(CHANGELOG_DDOC) changelog\2.054.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.055.html : $(CHANGELOG_DDOC) changelog\2.055.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.056.html : $(CHANGELOG_DDOC) changelog\2.056.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.057.html : $(CHANGELOG_DDOC) changelog\2.057.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.058.html : $(CHANGELOG_DDOC) changelog\2.058.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.059.html : $(CHANGELOG_DDOC) changelog\2.059.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.060.html : $(CHANGELOG_DDOC) changelog\2.060.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.061.html : $(CHANGELOG_DDOC) changelog\2.061.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.062.html : $(CHANGELOG_DDOC) changelog\2.062.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.063.html : $(CHANGELOG_DDOC) changelog\2.063.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.064.html : $(CHANGELOG_DDOC) changelog\2.064.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.065.0.html : $(CHANGELOG_DDOC) changelog\2.065.0.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.066.0.html : $(CHANGELOG_DDOC) changelog\2.066.0.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.066.1.html : $(CHANGELOG_DDOC) changelog\2.066.1.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.067.0.html : $(CHANGELOG_DDOC) changelog\2.067.0.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.067.1.html : $(CHANGELOG_DDOC) changelog\2.067.1.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.068.0.html : $(CHANGELOG_DDOC) changelog\2.068.0.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.068.1.html : $(CHANGELOG_DDOC) changelog\2.068.1.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.068.2.html : $(CHANGELOG_DDOC) changelog\2.068.2.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.069.0.html : $(CHANGELOG_DDOC) changelog\2.069.0.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.069.1.html : $(CHANGELOG_DDOC) changelog\2.069.1.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd
changelog\2.069.2.html : $(CHANGELOG_DDOC) changelog\2.069.2_pre.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_PRE_DDOC) $*.dd
changelog\index.html : $(CHANGELOG_DDOC) changelog\index.dd
	$(DMD) -o- -c -D -Df$*.html $(CHANGELOG_DDOC) $*.dd

code_coverage.html : $(DDOC) code_coverage.dd

COM.html : $(DDOC) COM.dd

comparison.html : $(DDOC) comparison.dd

concepts.html : $(DDOC) concepts.dd

const-faq.html : $(DDOC) const-faq.dd

cppcontracts.html : $(DDOC) cppcontracts.dd

cpptod.html : $(DDOC) cpptod.dd

ctarguments.html : $(DDOC) ctarguments.dd

ctod.html : $(DDOC) ctod.dd

D1toD2.html : $(DDOC) D1toD2.dd

d-floating-point.html : $(DDOC) d-floating-point.dd

deprecate.html : $(DDOC) deprecate.dd

dll.html : $(DDOC) dll.dd

dll-linux.html : $(DDOC) dll-linux.dd

download.html : $(DDOC) download.dd

dstyle.html : $(DDOC) dstyle.dd

faq.html : $(DDOC) faq.dd

features2.html : $(DDOC) features2.dd

getstarted.html : $(DDOC) getstarted.dd

glossary.html : $(DDOC) glossary.dd

exception-safe.html : $(DDOC) exception-safe.dd

hijack.html : $(DDOC) hijack.dd

howto-promote.html : $(DDOC) howto-promote.dd

htod.html : $(DDOC) htod.dd

htomodule.html : $(DDOC) htomodule.dd

index.html : $(DDOC) index.dd

intro-to-datetime.html : $(DDOC) intro-to-datetime.dd

gpg_keys.html : $(DDOC) gpg_keys.dd

spec\abi.html : $(LANGUAGE_DDOC) spec\abi.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\arrays.html : $(LANGUAGE_DDOC) spec\arrays.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd


spec\attribute.html : $(LANGUAGE_DDOC) spec\attribute.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\class.html : $(LANGUAGE_DDOC) spec\class.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\const3.html : $(LANGUAGE_DDOC) spec\const3.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\contracts.html : $(LANGUAGE_DDOC) spec\contracts.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\cpp_interface.html : $(LANGUAGE_DDOC) spec\cpp_interface.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\ddoc.html : $(LANGUAGE_DDOC) spec\ddoc.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\declaration.html : $(LANGUAGE_DDOC) spec\declaration.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\entity.html : $(LANGUAGE_DDOC) spec\entity.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\enum.html : $(LANGUAGE_DDOC) spec\enum.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\errors.html : $(LANGUAGE_DDOC) spec\errors.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\expression.html : $(LANGUAGE_DDOC) spec\expression.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\float.html : $(LANGUAGE_DDOC) spec\float.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\function.html : $(LANGUAGE_DDOC) spec\function.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\garbage.html : $(LANGUAGE_DDOC) spec\garbage.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\grammar.html : $(LANGUAGE_DDOC) spec\grammar.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\hash-map.html : $(LANGUAGE_DDOC) spec\hash-map.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\iasm.html : $(LANGUAGE_DDOC) spec\iasm.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\interface.html : $(LANGUAGE_DDOC) spec\interface.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\interfaceToC.html : $(LANGUAGE_DDOC) spec\interfaceToC.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\intro.html : $(LANGUAGE_DDOC) spec\intro.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\objc_interface.html : $(LANGUAGE_DDOC) spec\objc_interface.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\lex.html : $(LANGUAGE_DDOC) spec\lex.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\memory-safe-d.html : $(LANGUAGE_DDOC) spec\memory-safe-d.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\module.html : $(LANGUAGE_DDOC) spec\module.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\operatoroverloading.html : $(LANGUAGE_DDOC) spec\operatoroverloading.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\portability.html : $(LANGUAGE_LANGUAGE_DDOC) spec\portability.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\pragma.html : $(LANGUAGE_DDOC) spec\pragma.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\property.html : $(LANGUAGE_DDOC) spec\property.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\simd.html : $(LANGUAGE_DDOC) spec\simd.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\spec.html : $(LANGUAGE_DDOC) spec\spec.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\statement.html : $(LANGUAGE_DDOC) spec\statement.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\struct.html : $(LANGUAGE_DDOC) spec\struct.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\template-mixin.html : $(LANGUAGE_DDOC) spec\template-mixin.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\template.html : $(LANGUAGE_DDOC) spec\template.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\traits.html : $(LANGUAGE_DDOC) spec\traits.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\type.html : $(LANGUAGE_DDOC) spec\type.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\unittest.html : $(LANGUAGE_DDOC) spec\unittest.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

spec\version.html : $(LANGUAGE_DDOC) spec\version.dd
	$(DMD) -o- -c -D -Df$*.html $(LANGUAGE_DDOC) $*.dd

lazy-evaluation.html : $(DDOC) lazy-evaluation.dd

memory.html : $(DDOC) memory.dd

migrate-to-shared.html : $(DDOC) migrate-to-shared.dd

mixin.html : $(DDOC) mixin.dd

overview.html : $(DDOC) overview.dd

pretod.html : $(DDOC) pretod.dd

rationale.html : $(DDOC) rationale.dd

rdmd.html : $(DDOC) rdmd.dd

regular-expression.html : $(DDOC) regular-expression.dd

safed.html : $(DDOC) safed.dd

template-comparison.html : $(DDOC) template-comparison.dd

templates-revisited.html : $(DDOC) templates-revisited.dd

tuple.html : $(DDOC) tuple.dd

variadic-function-templates.html : $(DDOC) variadic-function-templates.dd

warnings.html : $(DDOC) warnings.dd

wc.html : $(DDOC) wc.dd

windbg.html : $(DDOC) windows.ddoc windbg.dd

windows.html : $(DDOC) windows.ddoc windows.dd

forum-template.html : $(DDOC) forum-template.dd

css/cssmenu.css : $(DDOC) css/cssmenu.css.dd
	$(DMD) -o- -c -Df$@ $(DDOC) css/cssmenu.css.dd

modlist-release.ddoc : modlist.d
# need + to run as sub-cmd, redirect doesn't work otherwise
	+$(DMD) -run modlist.d ..\druntime ..\phobos $(MOD_EXCLUDES_RELEASE) >$@

################ Ebook ########################

dlangspec.d : $(SPECSRC) win32.mak
	catdoc -odlangspec.d $(SPECSRC)

dlangspec.html : $(LANGUAGE_DDOC) ebook.ddoc dlangspec.d
	$(DMD) $(LANGUAGE_DDOC) ebook.ddoc dlangspec.d

dlangspec.zip : dlangspec.html ebook.css win32.mak
	del dlangspec.zip
	zip32 dlangspec dlangspec.html ebook.css

dlangspec.mobi : dlangspec.opf dlangspec.html dlangspec.png dlangspec.ncx ebook.css win32.mak
	del dlangspec.mobi
	kindlegen dlangspec.opf

################# CHM #########################

chm : d.chm

chmgen.exe : chmgen.d
	$(DMD) -g chmgen

chm\d.hhp chm\d.hhc chm\d.hhk : chmgen.exe chm-nav-doc.json chm-nav-std.json $(TARGETS)
	chmgen

d.chm : chm\d.hhp chm\d.hhc chm\d.hhk
	-cmd /C "cd chm && "$(HHC)" d.hhp"
	copy /Y chm\d.chm d.chm

chm-nav-doc.json : $(DDOC) chm-nav.dd
	$(DMD) -o- -c -Df$@ $(DDOC) chm-nav.dd

chm-nav-std.json : $(DDOC) $(DDOC_STD) chm-nav.dd
	$(DMD) -o- -c -Df$@ $(DDOC) $(DDOC_STD) chm-nav.dd

d.tag : chmgen.exe $(TARGETS)
	chmgen --only-tags

################# Other #########################

zip:
	del doc.zip
	zip32 doc win32.mak $(LANGUAGE_DDOC) windows.ddoc linux.ddoc osx.ddoc freebsd.ddoc ebook.ddoc
	zip32 doc $(SRC) $(PREMADE)
	zip32 doc $(ASSETS)
	zip32 doc ebook.css dlangspec.opf dlangspec.ncx dlangspec.png

clean:
	del $(TARGETS)
	del $(CHMTARGETS)
	del chmgen.obj chmgen.exe
	del docs.json
	if exist chm rmdir /S /Q chm
	if exist phobos rmdir /S /Q phobos
	-+dub clean --root=$(DPL_DOCS_PATH)

################# DDOX based API docs #########################

apidocs: docs.json
	$(DPL_DOCS) generate-html --file-name-style=lowerUnderscored --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc --override-macros=std-ddox-override.ddoc --package-order=std --git-target=master docs.json library

apidocs-serve: docs.json
	$(DPL_DOCS) serve-html --std-macros=html.ddoc --std-macros=dlang.org.ddoc --std-macros=std.ddoc --std-macros=macros.ddoc --std-macros=std-ddox.ddoc --override-macros=std-ddox-override.ddoc --package-order=std --git-target=master --web-file-dir=. docs.json

docs.json:
	mkdir .tmp
	dir /s /b /a-d ..\druntime\src\*.d | findstr /V "unittest.d gcstub" > .tmp/files.txt
	dir /s /b /a-d ..\phobos\*.d | findstr /V "unittest.d linux osx" >> .tmp/files.txt
	dmd -c -o- -version=CoreDdoc -version=StdDdoc -Df.tmp/dummy.html -Xfdocs.json @.tmp/files.txt
	$(DPL_DOCS) filter docs.json --min-protection=Protected --only-documented $(MOD_EXCLUDES_RELEASE)
	rmdir /s /q .tmp
