# Building dlang.org on Windows is no longer supported.
# Please use a Posix-like System, Bash under Windows or
# simply use the dlang.org preview DAutoTest automatically adds to every PR

LATEST=prerelease

DMD=dmd
DDOC=macros.ddoc html.ddoc dlang.org.ddoc windows.ddoc doc.ddoc $(NODATETIME)
W=web

CHMTARGETS=d.hhp d.hhc d.hhk d.chm
HHC=$(ProgramFiles)\HTML Help Workshop\hhc.exe

################# CHM #########################

chm : d.chm

chmgen.exe : tools\chmgen.d
	$(DMD) -g chmgen

chm\d.hhp chm\d.hhc chm\d.hhk : chmgen.exe chm-nav-release.json $(TARGETS)
	chmgen --root=$W --target release

chm\d.chm : chm\d.hhp chm\d.hhc chm\d.hhk
	-cmd /C "cd chm && "$(HHC)" d.hhp"

d.chm : chm\d.chm
	copy /Y chm\d.chm d.chm

chm-nav-release.json : $(DDOC) std.ddoc spec\spec.ddoc modlist-release.ddoc changelog\changelog.ddoc chm-nav.dd
	$(DMD) -o- -c -Df$@ $**

modlist-release.ddoc : tools\modlist.d
# need + to run as sub-cmd, redirect doesn't work otherwise
	+$(DMD) -run modlist.d ..\druntime ..\phobos $(MOD_EXCLUDES_RELEASE) >$@

################# Other #########################

clean:
	del $(CHMTARGETS)
	del chmgen.obj chmgen.exe
	if exist chm rmdir /S /Q chm
