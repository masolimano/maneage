# Build the VERY BASIC project software before higher-level ones. Assuming
# minimal/generic Make and Shell.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./project configure' script. It
# is not included into the project afterwards.
#
# This Makefile builds low-level and basic tools that are necessary in any
# project like like GNU Tar, GNU Bash, GNU Make, GCC and etc. But before
# control reaches here, the 'configure.sh' script has already built the
# extremely low-level tools: Lzip (a compressing program), GNU Make (to be
# able to run this Makefile with a fixed version), Dash (a minimalist
# POSIX-compatible shell) and Flock (to allow locking files, and
# serializing when necessary: downloading during the software building
# phase). Thanks to GNU Make and Dash, we can assume a fixed structure in
# this Makefile. However, the 'PATH's in this Makefile still include the
# host's paths because we will be using the hosts tools (gradually
# decreasing) to build our own tools.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Copyright (C) 2019-2020 Raul Infante-Sainz <infantesainz@gmail.com>
#
# This Makefile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This Makefile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this Makefile.  If not, see <http://www.gnu.org/licenses/>.

# Top level environment
include reproduce/software/config/LOCAL.conf
include reproduce/software/make/build-rules.mk
include reproduce/software/config/versions.conf
include reproduce/software/config/checksums.conf

# The optional URLs of software. Note that these may need the software
# version, so it is important that they be loaded after 'versions.conf'.
include reproduce/software/config/urls.conf

# Basic directories
lockdir = $(BDIR)/locks
tdir    = $(BDIR)/software/tarballs
ddir    = $(BDIR)/software/build-tmp
idir    = $(BDIR)/software/installed
ibdir   = $(BDIR)/software/installed/bin
ildir   = $(BDIR)/software/installed/lib
ibidir  = $(BDIR)/software/installed/version-info/proglib

# Ultimate Makefile target. GNU Nano (a simple and very light-weight text
# editor) is installed by default, it is recommended to have it in the
# 'basic.mk', so Maneaged projects can be edited on any system (even when
# there is no command-line text editor is available).
targets-proglib = low-level-links \
                  gcc-$(gcc-version) \
                  nano-$(nano-version)
all: $(foreach p, $(targets-proglib), $(ibidir)/$(p))

# Define the shell environment
# ----------------------------
#
# We build GNU Bash here in 'basic.mk'. So here we must must assume DASH
# shell that was built before calling this Makefile:
# http://gondor.apana.org.au/~herbert/dash. DASH is a minimalist POSIX
# shell, so it doesn't have startup options like '--noprofile --norc'. But
# from its manual, to load startup files, Dash actually requires that it be
# called with a '-' before it (for example '-dash'), so it shouldn't be
# loading any startup files if it was interpretted properly.
#
# As we build more programs, we want to use this project's built programs
# and libraries, not the host's, so in all PATH-related environments, our
# own build-directory comes first.
.ONESHELL:
.SHELLFLAGS := -e -c
export CCACHE_DISABLE := 1
export SHELL := $(ibdir)/dash
export PATH := $(ibdir):$(PATH)
export PKG_CONFIG_PATH := $(ildir)/pkgconfig
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig
export CPPFLAGS := -I$(idir)/include $(CPPFLAGS)
export LDFLAGS := $(rpath_command) -L$(ildir) $(LDFLAGS)

# This is the "basic" tools where we are relying on the host operating
# system, but are slowly populating our basic software envirnoment. To run
# (system or template) programs, `LD_LIBRARY_PATH' is necessary, so here,
# we'll first tell the programs to look into any possible pre-defined
# `LD_LIBRARY_PATH', then we'll add our own newly installed libraries.  We
# will also make sure that there is no "current directory" in it (by
# removing a starting or trailing `:' and any occurance of `::'.
export LD_LIBRARY_PATH := $(shell echo $(LD_LIBRARY_PATH):$(ildir) \
                                  | sed -e's/::/:/g' -e's/^://' -e's/:$$//')

# RPATH is automatically written in macOS, so `DYLD_LIBRARY_PATH' is
# ultimately redundant. But on some systems, even having a single value
# causes crashs (see bug #56682). So we'll just give it no value at all.
export DYLD_LIBRARY_PATH :=

# Servers to use as backup. Maneage already has some fixed servers that can
# be used to download software tarballs. They are in a configuation
# file. But we give precedence to the "user" backup servers.
#
# One important "user" server (which the user doesn't actually give, but is
# found at configuration time in 'configure.sh') is Zenodo (see the
# description in 'configure.sh' for more on why this depends on
# configuration time).
#
# Afer putting everything together, we use the first server as the
# reference for all software if their '-url' variable isn't defined (in
# 'reproduce/software/config/urls.conf').
downloadwrapper = ./reproduce/analysis/bash/download-multi-try
maneage_backup_urls := $(shell awk '!/^#/{printf "%s ", $$1}' \
                               reproduce/software/config/servers-backup.conf)
backupservers_all = $(user_backup_urls) $(maneage_backup_urls)
topbackupserver = $(word 1, $(backupservers_all))
backupservers = $(filter-out $(topbackupserver),$(backupservers_all))










# Low-level (not built) programs
# ------------------------------
#
# For the time being, some components of the project aren't being built on
# some systems (primarily on proprietary operating systems). So we are
# simply making a symbolic link to the system's programs/libraries in the
# build directory.
#
# The logical position of this rule is irrelevant in this Makefile (because
# programs being built here have full access to the system's PATH
# already). This is done for the high-level programs installed in
# 'high-level.mk', 'xorg.mk' or 'python.mk'. So this step is done after
# building our own GNU Grep (which is the highest-level program used in
# 'makelink') to have trustable elements.
#
# About ccache: ccache acts like a wrapper over the C compiler and is made
# to avoid/speed-up compiling of identical files in a system (it is
# commonly used on large servers). It actually makes `gcc' or `g++' a
# symbolic link to itself so it can control them internally. So, for our
# purpose here, it is very annoying and can cause many complications. We
# thus remove any part of PATH of that has `ccache' in it before making
# symbolic links to the programs we are not building ourselves.
#
# The double quotations after the starting 'export PATH' are necessary in
# case the user's PATH has space-characters in it.
#
# We use 'realpath' here (part of GNU Coreutils which is already installed
# by the time we use 'makelink') to avoid linking to a link (on the
# host). 'realpath' will follow a link (and possibly other links in the
# middle) to an actual file and return its address. When the location isn't
# a link, it will just return it.
syspath := $(PATH)
makelink = origpath="$$PATH"; \
	export PATH="$$(echo $(syspath) \
	                     | tr : '\n' \
	                     | grep -v ccache \
	                     | tr '\n' :)"; \
	if type $(1) > /dev/null 2> /dev/null; then \
	  if [ x$(3) = x ]; then \
	    ln -sf "$$(realpath $$(which $(1)))" $(ibdir)/$(1); \
	  else \
	    ln -sf "$$(realpath $$(which $(1)))" $(ibdir)/$(3); \
	  fi; \
	else \
	  if [ "x$(strip $(2))" = xmandatory ]; then \
	    echo "'$(1)' is necessary for higher-level tools."; \
	    echo "Please install it for the configuration to continue."; \
	    exit 1; \
	  fi; \
	fi; \
	export PATH="$$origpath"

$(ibdir) $(ildir):; mkdir $@
$(ibidir)/low-level-links: $(ibidir)/grep-$(grep-version) \
                           | $(ibdir) $(ildir)

        # Hardware specific
	$(call makelink,lp)    # For printing, necessary for R.
	$(call makelink,lpr)   # For printing, necessary for R.

        # Mac OS specific
	$(call makelink,mig)
	$(call makelink,xcrun)
	$(call makelink,sysctl)
	$(call makelink,sw_vers)
	$(call makelink,dsymutil)
	$(call makelink,install_name_tool)

        # On Mac OS, libtool is different compared to GNU Libtool. The
        # libtool we'll build in the high-level dependencies has the
        # executable name `glibtool'.
	$(call makelink,libtool)

        # Necessary libraries:
        #   Libdl (for dynamic loading libraries at runtime)
        #   POSIX Threads library for multi-threaded programs.
	for l in dl pthread; do
	  if [ -f /usr/lib/lib$$l.a ]; then
	    ln -sf /usr/lib/lib$$l.* $(ildir)/
	  fi
	done

        # We want this to be empty (so it doesn't interefere with the other
        # files in `ibidir'.
	touch $@










# Level 1 (MOST BASIC): Compression programs
# ------------------------------------------
#
# The first set of programs to be built are those that we need to unpack
# the source code tarballs of each program. We have already installed Lzip
# before calling 'basic.mk', so it is present and working. Hence we first
# build the Lzipped tarball of Gzip, then use our own Gzip to unpack the
# tarballs of the other compression programs. Once all the compression
# programs/libraries are complete, we build our own GNU Tar and continue
# with other software.
$(lockdir): | $(BDIR); mkdir $@
$(ibidir)/gzip-$(gzip-version): | $(ibdir) $(ildir) $(lockdir)
	tarball=gzip-$(gzip-version).tar.lz
	$(call import-source, $(gzip-url), $(gzip-checksum))
	$(call gbuild, gzip-$(gzip-version), static, , V=1)
	echo "GNU Gzip $(gzip-version)" > $@

$(ibidir)/xz-$(xz-version): $(ibidir)/gzip-$(gzip-version)
	tarball=xz-$(xz-version).tar.gz
	$(call import-source, $(xz-url), $(xz-checksum))
	$(call gbuild, xz-$(xz-version), static)
	echo "XZ Utils $(xz-version)" > $@

$(ibidir)/bzip2-$(bzip2-version): $(ibidir)/gzip-$(gzip-version)

        # Download the tarball.
	tarball=bzip2-$(bzip2-version).tar.gz
	$(call import-source, $(bzip2-url), $(bzip2-checksum))

        # Bzip2 doesn't have a `./configure' script, and its Makefile
        # doesn't build a shared library. So we can't use the `gbuild'
        # function here and we need to take some extra steps (inspired
        # from the GNU/Linux from Scratch (LFS) guide for Bzip2):
        #   1) The `sed' call is for relative installed symbolic links.
        #   2) The special Makefile-libbz2_so builds shared libraries.
        #
        # NOTE: the major version number appears in the final symbolic
        # link.
	tdir=bzip2-$(bzip2-version)
	if [ $(static_build) = yes ]; then
	  makecommand="make LDFLAGS=-static"
	  makeshared="echo no-shared"
	else
	  makecommand="make"
	  if [ x$(on_mac_os) = xyes ]; then
	    makeshared="echo no-shared"
	  else
	    makeshared="make -f Makefile-libbz2_so"
	  fi
	fi
	cd $(ddir)
	rm -rf $$tdir
	tar xf $(tdir)/$$tarball
	cd $$tdir
	sed -e 's@\(ln -s -f \)$$(PREFIX)/bin/@\1@' Makefile \
	    > Makefile.sed
	mv Makefile.sed Makefile
	$$makeshared CC=cc
	cp -a libbz2* $(ildir)/
	make clean
	$$makecommand CC=cc
	make install PREFIX=$(idir)
	cd ..
	rm -rf $$tdir
	cd $(ildir)
	ln -fs libbz2.so.1.0 libbz2.so
	echo "Bzip2 $(bzip2-version)" > $@

$(ibidir)/unzip-$(unzip-version): $(ibidir)/gzip-$(gzip-version)
	tarball=unzip-$(unzip-version).tar.gz
	v=$$(echo $(unzip-version) | sed -e's/\.//')
	$(call import-source, $(unzip-url), $(unzip-checksum))
	$(call gbuild, unzip$$v, static,, \
	               -f unix/Makefile generic \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd, \
	               -f unix/Makefile generic \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 )
	echo "Unzip $(unzip-version)" > $@

$(ibidir)/zip-$(zip-version): $(ibidir)/gzip-$(gzip-version)
	tarball=zip-$(zip-version).tar.gz
	v=$$(echo $(zip-version) | sed -e's/\.//')
	$(call import-source, $(zip-url), $(zip-checksum))
	$(call gbuild, zip$$v, static,, \
	               -f unix/Makefile generic \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd, \
	               -f unix/Makefile generic \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 )
	echo "Zip $(zip-version)" > $@

# Some programs (like Wget and CMake) that use zlib need it to be dynamic
# so they use our custom build. So we won't force a static-only build.
#
# Note for a static-only build: Zlib's `./configure' doesn't use Autoconf's
# configure script, it just accepts a direct `--static' option.
$(ibidir)/zlib-$(zlib-version): $(ibidir)/gzip-$(gzip-version)
	tarball=zlib-$(zlib-version).tar.gz
	$(call import-source, $(zlib-url), $(zlib-checksum))
	$(call gbuild, zlib-$(zlib-version))
	echo "Zlib $(zlib-version)" > $@

# GNU Tar: When built statically, tar gives a segmentation fault on
# unpacking Bash. So we'll build it dynamically. Note that technically, zip
# and unzip aren't dependencies of Tar, but for a clean build, we'll set
# Tar to be the last compression-related software (the first-set of
# software to be built).
$(ibidir)/tar-$(tar-version): \
              $(ibidir)/xz-$(xz-version) \
              $(ibidir)/zip-$(zip-version) \
              $(ibidir)/gzip-$(gzip-version) \
              $(ibidir)/zlib-$(zlib-version) \
              $(ibidir)/bzip2-$(bzip2-version) \
              $(ibidir)/unzip-$(unzip-version)
        # Since all later programs depend on Tar, the configuration will be
        # stuck here, only making Tar. So its more efficient to built it on
        # multiple threads (when the user's Make doesn't pass down the
        # number of threads).
	tarball=tar-$(tar-version).tar.gz
	$(call import-source, $(tar-url), $(tar-checksum))
	$(call gbuild, tar-$(tar-version), , , -j$(numthreads) V=1)
	echo "GNU Tar $(tar-version)" > $@










# Level 2 (necessary for linking)
#
# Patchelf is necessary for some software on GNU/Linux systems, its job is
# to manually insert RPATH into the dynamically-linked executable. Since
# all the other software depend on Pathelf, to avoid manually repeating as
# a prerequisite (and forgetting in others causing bugs), we'll put it as a
# dependancy of 'tar'.
$(ibidir)/patchelf-$(patchelf-version): $(ibidir)/tar-$(tar-version)
	tarball=patchelf-$(patchelf-version).tar.gz
	$(call import-source, $(patchelf-url), $(patchelf-checksum))
	if [ x$(on_mac_os) = xyes ]; then
	  echo "" > $@
	else
	  $(call gbuild, patchelf-$(patchelf-version))
	  echo "PatchELF $(patchelf-version)" > $@
	fi










# Level 3 (THIRD MOST BASIC): Bash
# --------------------------------
#
# GNU Make and GNU Bash are the second layer that we'll need to build the
# basic dependencies.
#
# Unfortunately Make needs dynamic linking in two instances: when loading
# objects (dynamically linked libraries), or when using the `getpwnam'
# function (for tilde expansion). The first can be disabled with
# `--disable-load', but unfortunately I don't know any way to fix the
# second. So, we'll have to build it dynamically for now.
$(ibidir)/ncurses-$(ncurses-version): $(ibidir)/patchelf-$(patchelf-version)
	tarball=ncurses-$(ncurses-version).tar.gz
	$(call import-source, $(ncurses-url), $(ncurses-checksum))

        # Delete the library that will be installed (so we can make sure
        # the build process completed afterwards and reset the links).
	rm -f $(ildir)/libncursesw*

        # Delete the (possibly existing) low-level programs that depend on
        # `readline', and thus `ncurses'. Since these programs are actually
        # used during the building of `ncurses', we need to delete them so
        # the build process doesn't use the project's Bash and AWK, but the
        # host's.
	rm -f $(ibdir)/bash* $(ibdir)/awk* $(ibdir)/gawk*

        # Standard build process.
	$(call gbuild, ncurses-$(ncurses-version), static, \
	               --with-shared --enable-rpath --without-normal \
	               --without-debug --with-cxx-binding \
	               --with-cxx-shared --enable-widec --enable-pc-files \
	               --with-pkg-config=$(ildir)/pkgconfig, -j$(numthreads))

        # Unfortunately there are many problems with `ncurses' using
        # "normal" (or 8-bit) characters. The standard way that will work
        # is to build it with wide character mode as you see above in the
        # configuration (or the `w' prefix you see below). Also, most
        # programs (and in particular Bash and AWK), first look for other
        # (mostly obsolete) libraries like tinfo, which define the same
        # symbols. The links below address both situations: we need to fool
        # higher-level packages to find this library even if they aren't
        # explicitly mentioning its name correctly (as a value to `-l' at
        # link time in their configure scripts).
        #
        # This part is taken from the Arch GNU/Linux build script[1], then
        # extended to Mac thanks to Homebrew's script [2].
        #
        # [1] https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/ncurses
        # [2] https://github.com/Homebrew/homebrew-core/blob/master/Formula/ncurses.rb
        #
        # Since we can't have comments, in the connected script, here is a
        # summary:
        #
        #   1. We find the actual suffix of the library, from the file that
        #      is not a symbolic link (starting with `-' in the output of
        #      `ls -l').
        #
        #   2. We make symbolic links to all the "ncurses", "ncurses++",
        #      "form", "panel" and "menu" libraries to point to their
        #      "wide" (character) library.
        #
        #   3. We make symbolic links to the "tic" and "tinfo" libraries to
        #      point to the same `libncursesw' library.
        #
        #   4. Some programs link with "curses" (not "ncurses", notice the
        #      starting "n"), so we'll also make links for these to point
        #      to the `libncursesw' library.
        #
        #   5. A link is made to also be able to include files from the
        #      `ncurses' headers.
	if [ x$(on_mac_os) = xyes ]; then so="dylib"; else so="so"; fi
	if [ -f $(ildir)/libncursesw.$$so ]; then

	  sov=$$(ls -l $(ildir)/libncursesw* \
	               | awk '/^-/{print $$NF}' \
	               | sed -e's|'$(ildir)/libncursesw.'||')

	  cd "$(ildir)"
	  for lib in ncurses ncurses++ form panel menu; do
	    ln -fs lib$$lib"w".$$sov     lib$$lib.$$so
	    ln -fs $(ildir)/pkgconfig/"$$lib"w.pc pkgconfig/$$lib.pc
	  done
	  for lib in tic tinfo; do
	    ln -fs libncursesw.$$sov     lib$$lib.$$so
	    ln -fs libncursesw.$$sov     lib$$lib.$$sov
	    ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/$$lib.pc
	  done
	  ln -fs libncursesw.$$sov libcurses.$$so
	  ln -fs libncursesw.$$sov libcursesw.$$sov
	  ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/curses.pc
	  ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/cursesw.pc

	  ln -fs $(idir)/include/ncursesw $(idir)/include/ncurses
	  echo "GNU NCURSES $(ncurses-version)" > $@
	else
	  exit 1
	fi

$(ibidir)/readline-$(readline-version): \
                   $(ibidir)/ncurses-$(ncurses-version)
	tarball=readline-$(readline-version).tar.gz
	$(call import-source, $(readline-url), $(readline-checksum))
	$(call gbuild, readline-$(readline-version), static, \
	               --with-curses --disable-install-examples, \
	               SHLIB_LIBS="-lncursesw" -j$(numthreads))
	echo "GNU Readline $(readline-version)" > $@


# IMPORTANT: Even though we have enabled `rpath', Bash doesn't write the
# absolute adddress of the libraries it depends on! Therefore, if we
# configure Bash with `--with-installed-readline' (so the installed version
# of Readline, that we build below as a prerequisite or AWK, is used) and
# you run `ldd $(ibdir)/bash' on the resulting binary, it will say that it
# is linking with the system's `readline'. But if you run that same command
# within a rule in this project, you'll see that it is indeed linking with
# our own built readline.
#
# Unfortunately Bash doesn't maintain a Git repository and minor fixes are
# released as patches. Therefore we'll need to make our own fully-working
# and updated tarball to build the proper version of Bash. You download and
# apply them to the original tarball and make a new one with the following
# series of commands (just replace `NUMBER' with the total number of
# patches that you want to apply).
#
#   $ number=NUMBER
#   $ tar xf bash-5.0.tar.gz
#   $ cd bash-5.0
#   $ for i in $(seq 1 $number); do \
#       pname=bash50-$(printf "%03d" $i); \
#       wget http://ftp.gnu.org/gnu/bash/bash-5.0-patches/$pname -O ../$pname;\
#       patch -p0 -i ../$pname; \
#     done
#   $ cd ..
#   $ mv bash-5.0 bash-5.0.$number
#   $ tar cf bash-5.0.$number.tar bash-5.0.$number
#   $ lzip --best bash-5.0.$number.tar
#   $ rm -rf bash50-* bash-5.0.$number bash-5.0.tar.gz
$(ibidir)/bash-$(bash-version): \
               $(ibidir)/gettext-$(gettext-version) \
               $(ibidir)/readline-$(readline-version)

        # Download the tarball.
	tarball=bash-$(bash-version).tar.lz
	$(call import-source, $(bash-url), $(bash-checksum))

        # Delete the (possibly) existing Bash executable in the project,
        # let it use the default shell of the host.
	rm -f $(ibdir)/bash

        # Bash has many `--enable' features which are already enabled by
        # default. As described in the manual, they are mainly useful when
        # you disable them all with `--enable-minimal-config' and enable a
        # subset using the `--enable' options.
	if [ "x$(static_build)" = xyes ]; then stopt="--enable-static-link"
	else                                   stopt=""
	fi;
	export CFLAGS="$$CFLAGS \
	               -DDEFAULT_PATH_VALUE='\"$(ibdir)\"' \
	               -DSTANDARD_UTILS_PATH='\"$(ibdir)\"'  \
	               -DSYS_BASHRC='\"$(BASH_ENV)\"' "
	$(call gbuild, bash-$(bash-version),, $$stopt \
	               --with-installed-readline=$(ildir) \
	               --with-curses=yes, \
	               -j$(numthreads))

        # Atleast on GNU/Linux systems, Bash doesn't include RPATH by
        # default. So, we have to manually include it, currently we are
        # only doing this on GNU/Linux systems (using the `patchelf'
        # program).
	if [ -f $(ibdir)/patchelf ]; then
	  $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/bash;
	fi

        # To be generic, some systems use the `sh' command to call the
        # shell. By convention, `sh' is just a symbolic link to the
        # preferred shell executable. So we'll define `$(ibdir)/sh' as a
        # symbolic link to the Bash that we just built and installed.
        #
        # Just to be sure that the installation step above went well,
        # before making the link, we'll see if the file actually exists
        # there.
	ln -fs $(ibdir)/bash $(ibdir)/sh
	echo "GNU Bash $(bash-version)" > $@










# Level 4: Most other programs
# ----------------------------

# In Perl, The `-shared' flag will cause problems while building on macOS,
# so we'll only use this configuration option when we are GNU/Linux
# systems. However, since the whole option must be used (which includes `='
# and empty space), its easier to define the variable as a Make variable
# outside the recipe, not as a shell variable inside it.
ifeq ($(on_mac_os),yes)
perl-conflddlflags =
else
perl-conflddlflags = -Dlddlflags="-shared $$LDFLAGS"
endif
$(ibidir)/perl-$(perl-version): $(ibidir)/patchelf-$(patchelf-version)
	tarball=perl-$(perl-version).tar.gz
	$(call import-source, $(perl-url), $(perl-checksum))
	major_version=$$(echo $(perl-version) \
	                     | sed -e's/\./ /g' \
	                     | awk '{printf("%d", $$1)}')
	base_version=$$(echo $(perl-version) \
	                     | sed -e's/\./ /g' \
	                     | awk '{printf("%d.%d", $$1, $$2)}')
	cd $(ddir)
	rm -rf perl-$(perl-version)
	tar xf $(tdir)/$$tarball
	cd perl-$(perl-version)
	./Configure -des \
	            -Dusethreads \
	            -Duseshrplib \
	            -Dprefix=$(idir) \
	            -Dvendorprefix=$(idir) \
	            -Dprivlib=$(idir)/share/perl$$major_version/core_perl \
	            -Darchlib=$(idir)/lib/perl$$major_version/$$base_version/core_perl \
	            -Dsitelib=$(idir)/share/perl$$major_version/site_perl \
	            -Dsitearch=$(idir)/lib/perl$$major_version/$$basever/site_perl \
	            -Dvendorlib=$(idir)/share/perl$$major_version/vendor_perl \
	            -Dvendorarch=$(idir)/lib/perl$$major_version/$$base_version/vendor_perl \
	            -Dscriptdir=$(idir)/bin/core_perl \
	            -Dsitescript=$(idir)/bin/site_perl \
	            -Dvendorscript=$(idir)/bin/vendor_perl \
	            -Dinc_version_list=none \
	            -Dman1ext=1perl \
	            -Dman3ext=3perl \
	            -Dcccdlflags='-fPIC' \
	            $(perl-conflddlflags) \
	            -Dldflags="$$LDFLAGS"
	make -j$(numthreads)
	make install
	cd ..
	rm -rf perl-$(perl-version)
	cd $$topdir
	echo "Perl $(perl-version)" > $@





# Coreutils
# ---------
#
# For some reason, Coreutils doesn't include `rpath' in its installed
# executables (even though it says that by default its included and that
# even when calling `--enable-rpath=yes'). So we have to manually add
# `rpath' to Coreutils' executables after the standard build is
# complete.
#
# One problem is that Coreutils installs many very basic executables which
# might be in used by other programs. So we must make sure that when
# Coreutils is being built, no other program is being built in
# parallel. The solution to the many executables it installs is to make a
# fake installation (with `DESTDIR'), and get a list of the contents of the
# directory to find the names.
#
# The echo after the PatchELF loop is to avoid a crash if the last
# file that PatchELF encounters is not usable (and it returns with
# an error).
#
# Coreutils uses Perl to create man pages!
$(ibidir)/coreutils-$(coreutils-version): \
                    $(ibidir)/bash-$(bash-version) \
                    $(ibidir)/perl-$(perl-version) \
                    $(ibidir)/openssl-$(openssl-version)

        # Import, unpack and enter the source directory.
	tarball=coreutils-$(coreutils-version).tar.xz
	$(call import-source, $(coreutils-url), $(coreutils-checksum))
	cd $(ddir)
	rm -rf coreutils-$(coreutils-version)
	tar xf $(tdir)/$$tarball
	cd coreutils-$(coreutils-version)

        # Set the configure script to use our shell, note that we can't
        # assume GNU SED here yet (it installs after Coreutils).
	sed -e's|\#\! /bin/sh|\#\! $(ibdir)/bash|' \
	    -e's|\#\!/bin/sh|\#\! $(ibdir)/bash|' \
	    configure > configure-tmp
	mv configure-tmp configure
	chmod +x configure

        # Configure, build and install Coreutils.
	./configure --prefix=$(idir) SHELL=$(ibdir)/bash  \
	            LDFLAGS="$(LDFLAGS)" CPPFLAGS="$(CPPFLAGS)" \
	            --disable-silent-rules --with-openssl=yes
	make SHELL=$(ibdir)/bash -j$(numthreads)
	make SHELL=$(ibdir)/bash install

        # Fix RPATH if necessary.
	if [ -f $(ibdir)/patchelf ]; then
	  make SHELL=$(ibdir)/bash install DESTDIR=junkinst
	  instprogs=$$(ls junkinst/$(ibdir))
	  for f in $$instprogs; do
	    $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/$$f
	  done
	  echo "PatchELF applied to all programs."
	fi

        # Come back up to the unpacking directory, delete the source
        # directory and write the final target.
	cd ..
	rm -rf coreutils-$(coreutils-version)
	echo "GNU Coreutils $(coreutils-version)" > $@

# OpenSSL
#
# Until we find a nice and generic way to create an updated CA file in the
# project, the certificates will be available in a file for this project
# along with the other tarballs.
$(idir)/etc:; mkdir $@
$(idir)/etc/ssl: | $(idir)/etc; mkdir $@
$(ibidir)/openssl-$(openssl-version): $(ibidir)/perl-$(perl-version) \
                  | $(idir)/etc/ssl

        # First download the certificates and copy them into the
        # installation directory.
	tarball=cert.pem
	$(call import-source, $(cert-url), $(cert-checksum))
	cp $(tdir)/cert.pem $(idir)/etc/ssl/cert.pem

        # Now download the OpenSSL tarball.
	tarball=openssl-$(openssl-version).tar.gz
	$(call import-source, $(openssl-url), $(openssl-checksum))

        # According to OpenSSL's Wiki (link bellow), it can't automatically
        # detect Mac OS's structure. It will need some help. So we'll use
        # the `on_mac_os' Make variable that we defined in the configure
        # script and help it with some extra configuration options and an
        # environment variable.
        #
        # https://wiki.openssl.org/index.php/Compilation_and_Installation
	if [ x$(on_mac_os) = xyes ]; then
	  export KERNEL_BITS=64
	  copt="shared no-ssl2 no-ssl3 enable-ec_nistp_64_gcc_128"
	fi
	$(call gbuild, openssl-$(openssl-version), , \
	               zlib \
	               $$copt \
	               $(rpath_command) \
	               --openssldir=$(idir)/etc/ssl \
	               --with-zlib-lib=$(ildir) \
	               --with-zlib-include=$(idir)/include, \
	               -j$(numthreads), , ./config )

        # Manually insert RPATH inside the OpenSSL library.
	if [ -f $(ibdir)/patchelf ]; then
	   patchelf --set-rpath $(ildir) $(ildir)/libssl.so; \
	fi

        # Bug 58263 (https://savannah.nongnu.org/bugs/?58263): In OpenSSL
        # Version 1.1.1a (also checked in 1.1.1g), `openssl/ec.h' fails to
        # include `openssl/openconf.h' on some OSs. The SED hack below
        # inserts a hardwired element of `openssl/openconf.h' that is
        # needed to include sections of code `f` that are deprecated in
        # 1.2.0, but not yet in 1.1.1. This problem may be solved in
        # version 1.2.x, so please check again in that bug.
	mv -v $(idir)/include/openssl/ec.h $(idir)/include/openssl/ec.h.orig
	sed -e 's,\(# include .openssl/opensslconf\.h.\),\1\n#ifndef DEPRECATEDIN_1_2_0\n#define DEPRECATEDIN_1_2_0(f)   f;\n#endif\n,' \
	   $(idir)/include/openssl/ec.h.orig > $(idir)/include/openssl/ec.h

        # Build the final target.
	echo "OpenSSL $(openssl-version)" > $@




# Downloaders
# -----------

# cURL
#
# cURL can optionally link with many different network-related libraries on
# the host system that we are not yet building in the template. Many of
# these are not relevant to most science projects, so we are explicitly
# using `--without-XXX' or `--disable-XXX' so cURL doesn't link with
# them. Note that if it does link with them, the configuration will crash
# when the library is updated/changed by the host, and the whole purpose of
# this project is avoid dependency on the host as much as possible.
$(ibidir)/curl-$(curl-version): $(ibidir)/coreutils-$(coreutils-version)

	tarball=curl-$(curl-version).tar.gz
	$(call import-source, $(curl-url), $(curl-checksum))

	$(call gbuild, curl-$(curl-version), , \
	               LIBS="-pthread" \
	               --with-zlib=$(ildir) \
	               --with-ssl=$(idir) \
	               --without-mesalink \
	               --with-ca-fallback \
	               --without-librtmp \
	               --without-libidn2 \
	               --without-wolfssl \
	               --without-brotli \
	               --without-gnutls \
	               --without-cyassl \
	               --without-libpsl \
	               --without-axtls \
	               --disable-ldaps \
	               --disable-ldap \
	               --without-nss, V=1)

	if [ -f $(ibdir)/patchelf ]; then
	   $(ibdir)/patchelf --set-rpath $(ildir) $(ildir)/libcurl.so
	fi
	echo "cURL $(curl-version)" > $@


# GNU Wget
#
# Note that on some systems (for example GNU/Linux) Wget needs to explicity
# link with `libdl', but on others (for example Mac OS) it doesn't. We
# check this at configure time and define the `needs_ldl' variable.
#
# Also note that since Wget needs to load outside libraries dynamically, it
# gives a segmentation fault when built statically.
#
# There are many network related libraries that we are currently not
# building as part of this project. So to avoid too much dependency on the
# host system (especially a crash when these libraries are updated on the
# host), they are disabled here.
$(ibidir)/wget-$(wget-version): \
               $(ibidir)/libiconv-$(libiconv-version) \
               $(ibidir)/coreutils-$(coreutils-version)

        # Download the tarball.
	tarball=wget-$(wget-version).tar.lz
	$(call import-source, $(wget-url), $(wget-checksum))

        # We need to explicitly disable `libiconv', because of the
        # `pkg-config' and `libiconv' problem.
	libs="-pthread"
	if [ x$(needs_ldl) = xyes ]; then libs="$$libs -ldl"; fi
	$(call gbuild, wget-$(wget-version), , \
	               LIBS="$$LIBS $$libs" \
	               --with-libssl-prefix=$(idir) \
	               --without-libiconv-prefix \
	               --with-ssl=openssl \
	               --with-openssl=yes \
	               --without-metalink \
	               --without-libuuid \
	               --without-libpsl \
	               --without-libidn \
	               --disable-pcre2 \
	               --disable-pcre \
	               --disable-iri, V=1 -j$(numthreads))
	echo "GNU Wget $(wget-version)" > $@







# Basic command-line tools and their dependencies
# -----------------------------------------------
#
# These are basic programs which are commonly necessary in the build
# process of the higher-level programs and libraries. Note that during the
# building of those higher-level programs (after this Makefile finishes),
# there is no access to the system's PATH.
$(ibidir)/diffutils-$(diffutils-version): \
                    $(ibidir)/coreutils-$(coreutils-version)
	tarball=diffutils-$(diffutils-version).tar.xz
	$(call import-source, $(diffutils-url), $(diffutils-checksum))
	$(call gbuild, diffutils-$(diffutils-version), static,,V=1)
	echo "GNU Diffutils $(diffutils-version)" > $@

$(ibidir)/file-$(file-version): $(ibidir)/coreutils-$(coreutils-version)
	tarball=file-$(file-version).tar.gz
	$(call import-source, $(file-url), $(file-checksum))
	$(call gbuild, file-$(file-version), static, \
	               --disable-libseccomp, V=1)
	echo "File $(file-version)" > $@

$(ibidir)/findutils-$(findutils-version): \
                    $(ibidir)/coreutils-$(coreutils-version)
	tarball=findutils-$(findutils-version).tar.xz
	$(call import-source, $(findutils-url), $(findutils-checksum))
	$(call gbuild, findutils-$(findutils-version), static,,V=1)
	echo "GNU Findutils $(findutils-version)" > $@

$(ibidir)/gawk-$(gawk-version): \
               $(ibidir)/gmp-$(gmp-version) \
               $(ibidir)/mpfr-$(mpfr-version) \
               $(ibidir)/coreutils-$(coreutils-version)

        # Download the tarball.
	tarball=gawk-$(gawk-version).tar.lz
	$(call import-source, $(gawk-url), $(gawk-checksum))

        # AWK doesn't include RPATH by default, so we'll have to manually
        # include it using the `patchelf' program (which was a dependency
        # of Bash). Just note that AWK produces two executables (for
        # example `gawk-4.2.1' and `gawk') and a symbolic link `awk' to one
        # of those executables.
	$(call gbuild, gawk-$(gawk-version), static, \
	               --with-readline=$(idir))

        # Correct the RPATH on systems that have installed patchelf.
	if [ -f $(ibdir)/patchelf ]; then
	  if [ -f $(ibdir)/gawk ]; then
	    $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/gawk
	  fi
	  if [ -f $(ibdir)/gawk-$(gawk-version) ]; then
	    $(ibdir)/patchelf --set-rpath $(ildir) \
	                      $(ibdir)/gawk-$(gawk-version);
	  fi
	fi

        # Build final target.
	echo "GNU AWK $(gawk-version)" > $@

$(ibidir)/libiconv-$(libiconv-version): \
                   $(ibidir)/pkg-config-$(pkgconfig-version)
	tarball=libiconv-$(libiconv-version).tar.gz
	$(call import-source, $(libiconv-url), $(libiconv-checksum))
	$(call gbuild, libiconv-$(libiconv-version), static)
	echo "GNU libiconv $(libiconv-version)" > $@

$(ibidir)/libunistring-$(libunistring-version): \
                       $(ibidir)/libiconv-$(libiconv-version)
	tarball=libunistring-$(libunistring-version).tar.xz
	$(call import-source, $(libunistring-url), $(libunistring-checksum))
	$(call gbuild, libunistring-$(libunistring-version), static,, \
	               -j$(numthreads))
	echo "GNU libunistring $(libunistring-version)" > $@

$(ibidir)/libxml2-$(libxml2-version): $(ibidir)/patchelf-$(patchelf-version)
        # The libxml2 tarball also contains Python bindings which are built
        # and installed to a system directory by default. If you don't need
        # the Python bindings, the easiest solution is to compile without
        # Python support: `./configure --without-python'. If you really need
        # the Python bindings, use `--with-python-install-dir=DIR' instead.
	tarball=libxml2-$(libxml2-version).tar.gz
	$(call import-source, $(libxml2-url), $(libxml2-checksum))
	$(call gbuild, libxml2-$(libxml2-version), static, \
	               --without-python, V=1)
	echo "Libxml2 $(libxml2-version)" > $@

$(ibidir)/gettext-$(gettext-version): \
                  $(ibidir)/m4-$(m4-version) \
                  $(ibidir)/libxml2-$(libxml2-version) \
                  $(ibidir)/ncurses-$(ncurses-version) \
                  $(ibidir)/libiconv-$(libiconv-version) \
                  $(ibidir)/libunistring-$(libunistring-version)
	tarball=gettext-$(gettext-version).tar.lz
	$(call import-source, $(gettext-url), $(gettext-checksum))
	$(call gbuild, gettext-$(gettext-version), static,, \
	               V=1 -j$(numthreads))
	echo "GNU gettext $(gettext-version)" > $@

$(ibidir)/git-$(git-version): \
              $(ibidir)/curl-$(curl-version) \
              $(ibidir)/gettext-$(gettext-version) \
              $(ibidir)/libiconv-$(libiconv-version)
	tarball=git-$(git-version).tar.xz
	if [ x$(on_mac_os) = xyes ]; then
	  export LDFLAGS="$$LDFLAGS -lcharset"
	fi
	$(call import-source, $(git-url), $(git-checksum))
	$(call gbuild, git-$(git-version), static, \
	               --without-tcltk --with-shell=$(ibdir)/bash \
	               --with-iconv=$(idir), V=1 -j$(numthreads))
	echo "Git $(git-version)" > $@

$(ibidir)/gmp-$(gmp-version): \
              $(ibidir)/m4-$(m4-version) \
              $(ibidir)/coreutils-$(coreutils-version)
	tarball=gmp-$(gmp-version).tar.lz
	$(call import-source, $(gmp-url), $(gmp-checksum))
	$(call gbuild, gmp-$(gmp-version), static, \
	               --enable-cxx --enable-fat, \
	               -j$(numthreads) ,make check)
	echo "GNU Multiple Precision Arithmetic Library $(gmp-version)" > $@

# On Mac OS, libtool does different things, so to avoid confusion, we'll
# prefix GNU's libtool executables with `glibtool'.
$(ibidir)/libtool-$(libtool-version): $(ibidir)/m4-$(m4-version)
	tarball=libtool-$(libtool-version).tar.xz
	$(call import-source, $(libtool-url), $(libtool-checksum))
	$(call gbuild, libtool-$(libtool-version), static, \
                       --program-prefix=g, V=1 -j$(numthreads))
	ln -sf $(ibdir)/glibtoolize $(ibdir)/libtoolize
	echo "GNU Libtool $(libtool-version)" > $@

$(ibidir)/grep-$(grep-version): $(ibidir)/coreutils-$(coreutils-version)
	tarball=grep-$(grep-version).tar.xz
	$(call import-source, $(grep-url), $(grep-checksum))
	$(call gbuild, grep-$(grep-version), static,,V=1)
	echo "GNU Grep $(grep-version)" > $@

$(ibidir)/libbsd-$(libbsd-version): $(ibidir)/coreutils-$(coreutils-version)
	tarball=libbsd-$(libbsd-version).tar.xz
	$(call import-source, $(libbsd-url), $(libbsd-checksum))
	if [ x$(on_mac_os) = xyes ]; then
	  echo "" > $@
	else
	  $(call gbuild, libbsd-$(libbsd-version), static,,V=1)
	  echo "Libbsd $(libbsd-version)" > $@
	fi

# We need to apply a patch to the M4 source to be used properly on macOS.
# The patch [1] was inspired by Homebrew's build instructions [1].
#
# [1] https://raw.githubusercontent.com/macports/macports-ports/edf0ee1e2cf/devel/m4/files/secure_snprintf.patch
# [2] https://github.com/Homebrew/homebrew-core/blob/master/Formula/m4.rb
#
# M4 doesn't depend on PatchELF, but just to be consistent with the
# levels/phases introduced here (where the compressors are level 1,
# PatchELF is level 2, and ...), we'll set it as a dependency.
$(ibidir)/m4-$(m4-version): $(ibidir)/patchelf-$(patchelf-version)
	tarball=m4-$(m4-version).tar.gz
	$(call import-source, $(m4-url), $(m4-checksum))
	cd $(ddir)
	unpackdir=m4-$(m4-version)
	rm -rf $$unpackdir
	tar xf $(tdir)/$$tarball
	mv m4-* $$unpackdir
	cd $$unpackdir
	if [ x$(on_mac_os) = xyes ]; then
	   sed 's|if !(((__GLIBC__ > 2|if !defined(__APPLE__) \&\& !(((__GLIBC__ > 2|' \
	       lib/vasnprintf.c > lib/vasnprintf_edited.c
	   mv lib/vasnprintf_edited.c lib/vasnprintf.c
	fi
	./configure --prefix=$(idir) LDFLAGS="$(LDFLAGS)" \
	            CPPFLAGS="$(CPPFLAGS)"
	make V=1 -j$(numthreads)
	make V=1 install
	cd ..
	rm -rf $$unpackdir
	echo "GNU M4 $(m4-version)" > $@

# Metastore is used (through a Git hook) to restore the source modification
# dates of files after a Git checkout. Another Git hook saves all file
# metadata just before a commit (to allow restoration after a
# checkout). Since this project is managed in Makefiles, file modification
# dates are critical to not having to redo the whole analysis after
# checking out between branches.
#
# Note that we aren't using the standard version of Metastore, but a fork
# of it that is maintained in this repository:
#    https://gitlab.com/makhlaghi/metastore-fork
#
# Note that the prerequisites `coreutils', `gawk' and `sed' are not
# metastore oficial dependencies, but they are necessaries to run our steps
# before and after the installation.
#
# Libbsd is not necessary on macOS systems, because macOS is already a
# BSD-based distribution. But on GNU/Linux systems, it is necessary.
$(ibidir)/metastore-$(metastore-version): \
                    $(ibidir)/sed-$(sed-version) \
                    $(ibidir)/git-$(git-version) \
                    $(ibidir)/gawk-$(gawk-version) \
                    $(ibidir)/libbsd-$(libbsd-version) \
                    $(ibidir)/coreutils-$(coreutils-version)

        # Download the tarball.
	tarball=metastore-$(metastore-version).tar.gz
	$(call import-source, $(metastore-url), $(metastore-checksum))

        # Metastore doesn't have any `./configure' script. So we'll just
        # call `pwd' as a place-holder for the `./configure' command.
        #
        # File attributes are also not available on some systems, since the
        # main purpose here is modification dates (and not attributes),
        # we'll also set the `NO_XATTR' flag.
        #
        # After installing Metastore, write the relevant hooks into this
        # system's Git hooks, while setting the system-specific
        # directories/files.
        #
        # Note that the metastore -O and -G options used in this template
        # are currently only available in a fork of `metastore' hosted at:
        # https://github.com/mohammad-akhlaghi/metastore
        #
        # Checking for presence of `.git'. When the project source is
        # downloaded from a non-Git source (for example from arXiv), there
        # is no `.git' directory to work with. So until we find a better
        # solution, avoid the step to to add the Git hooks.
	current_dir=$$(pwd); \
	$(call gbuild, metastore-$(metastore-version), static,, \
	               NO_XATTR=1 V=1,,pwd,PREFIX=$(idir))

        # Correct RPATH when necessary.
	if [ -f $(ibdir)/patchelf ]; then
	  $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/metastore
	fi

        # If this project is being built in a directory version controlled
        # by Git, copy the hooks into the Git configuation.
	if [ -f $(ibdir)/metastore ]; then
	  if [ -d .git ]; then
	    user=$$(whoami)
	    group=$$(groups | awk '{print $$1}')
	    cd $$current_dir
	    for f in pre-commit post-checkout; do
	       sed -e's|@USER[@]|'$$user'|g' \
	           -e's|@GROUP[@]|'$$group'|g' \
	           -e's|@BINDIR[@]|$(ibdir)|g' \
	           -e's|@TOP_PROJECT_DIR[@]|'$$current_dir'|g' \
	           reproduce/software/shell/git-$$f > .git/hooks/$$f
	       chmod +x .git/hooks/$$f
	    done
	  fi
	  echo "Metastore (forked) $(metastore-version)" > $@
	else
	  echo; echo; echo
	  echo "*****************"
	  echo "metastore couldn't be installed!"
	  echo
	  echo "Its used for preserving timestamps on Git commits."
	  echo "Its useful for development, not simple running of "
	  echo "the project. So we won't stop the configuration "
	  echo "because it wasn't built."
	  echo "*****************"
	  echo "" > $@
	fi

$(ibidir)/mpfr-$(mpfr-version): $(ibidir)/gmp-$(gmp-version)
	tarball=mpfr-$(mpfr-version).tar.xz
	$(call import-source, $(mpfr-url), $(mpfr-checksum))
	$(call gbuild, mpfr-$(mpfr-version), static, , , make check)
	echo "GNU Multiple Precision Floating-Point Reliably $(mpfr-version)" > $@

$(ibidir)/pkg-config-$(pkgconfig-version): $(ibidir)/patchelf-$(patchelf-version)

        # Download the tarball.
	tarball=pkg-config-$(pkgconfig-version).tar.gz
	$(call import-source, $(pkgconfig-url), $(pkgconfig-checksum))

        # An existing `libiconv' can cause a conflict with `pkg-config',
        # this is why `libiconv' depends on `pkg-config'. On a clean build,
        # `pkg-config' is built first. But when we don't have a clean build
        # (and `libiconv' exists) there will be a problem. So before
        # re-building `pkg-config', we'll remove any installation of
        # `libiconv'.
	rm -f $(ildir)/libiconv* $(idir)/include/iconv.h

        # Some Mac OS systems may have a version of the GNU C Compiler
        # (GCC) installed that doesn't support some necessary features of
        # building Glib (as part of pkg-config). So to be safe, for Mac
        # systems, we'll make sure it will use LLVM's Clang.
	if [ x$(on_mac_os) = xyes ]; then export compiler="CC=clang"
	else                              export compiler=""
	fi
	$(call gbuild, pkg-config-$(pkgconfig-version), static, \
	               $$compiler --with-internal-glib \
	               --with-pc-path=$(ildir)/pkgconfig, V=1)
	echo "pkg-config $(pkgconfig-version)" > $@

$(ibidir)/sed-$(sed-version): $(ibidir)/coreutils-$(coreutils-version)
	tarball=sed-$(sed-version).tar.xz
	$(call import-source, $(sed-url), $(sed-checksum))
	$(call gbuild, sed-$(sed-version), static,,V=1)
	echo "GNU Sed $(sed-version)" > $@

$(ibidir)/texinfo-$(texinfo-version): \
                  $(ibidir)/perl-$(perl-version) \
                  $(ibidir)/gettext-$(gettext-version)
	tarball=texinfo-$(texinfo-version).tar.xz
	$(call import-source, $(texinfo-url), $(texinfo-checksum))
	$(call gbuild, texinfo-$(texinfo-version), static)
	if [ -f $(ibdir)/patchelf ]; then
	  $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/info
	  $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/install-info
	fi
	echo "GNU Texinfo $(texinfo-version)" > $@

$(ibidir)/which-$(which-version): $(ibidir)/coreutils-$(coreutils-version)
	tarball=which-$(which-version).tar.gz
	$(call import-source, $(which-url), $(which-checksum))
	$(call gbuild, which-$(which-version), static)
	echo "GNU Which $(which-version)" > $@

# GNU ISL is necessary to build GCC.
$(ibidir)/isl-$(isl-version): $(ibidir)/gmp-$(gmp-version)
	tarball=isl-$(isl-version).tar.bz2
	$(call import-source, $(isl-url), $(isl-checksum))
	if [ $(host_cc) = 1 ]; then
	  echo "" > $@
	else
	  $(call gbuild, isl-$(isl-version), static, , \
	                 V=1 -j$(numthreads))
	  echo "GNU Integer Set Library $(isl-version)" > $@
	fi

# GNU MPC is necessary to build GCC.
$(ibidir)/mpc-$(mpc-version): $(ibidir)/mpfr-$(mpfr-version)
	tarball=mpc-$(mpc-version).tar.gz
	$(call import-source, $(mpc-url), $(mpc-checksum))
	if [ $(host_cc) = 1 ]; then
	  echo "" > $@
	else
	  $(call gbuild, mpc-$(mpc-version), static, , \
	                 -j$(numthreads), make check)
	  echo "GNU Multiple Precision Complex library" > $@
	fi










# Level 5: Binutils & GCC
# -----------------------
#
# The installation of Binutils can cause problems during the build of other
# programs (http://savannah.nongnu.org/bugs/?56294), but its necessary for
# GCC. Therefore, we'll set all other basic programs as Binutils
# prerequisite and GCC (the final basic target) ultimately just depends on
# Binutils.
$(ibidir)/binutils-$(binutils-version): \
                   $(ibidir)/sed-$(sed-version) \
                   $(ibidir)/isl-$(isl-version) \
                   $(ibidir)/mpc-$(mpc-version) \
                   $(ibidir)/wget-$(wget-version) \
                   $(ibidir)/grep-$(grep-version) \
                   $(ibidir)/file-$(file-version) \
                   $(ibidir)/gawk-$(gawk-version) \
                   $(ibidir)/which-$(which-version) \
                   $(ibidir)/texinfo-$(texinfo-version) \
                   $(ibidir)/libtool-$(libtool-version) \
                   $(ibidir)/metastore-$(metastore-version) \
                   $(ibidir)/findutils-$(findutils-version) \
                   $(ibidir)/diffutils-$(diffutils-version) \
                   $(ibidir)/coreutils-$(coreutils-version)

        # Download the tarball.
	tarball=binutils-$(binutils-version).tar.lz
	$(call import-source, $(binutils-url), $(binutils-checksum))

        # Binutils' assembler (`as') and linker (`ld') will conflict with
        # other compilers. So if we don't build our own compiler, we'll use
        # the host opertating system's equivalents by just making links.
	if [ x$(on_mac_os) = xyes ]; then
	  $(call makelink,as)
	  $(call makelink,ar)
	  $(call makelink,ld)
	  $(call makelink,nm)
	  $(call makelink,ps)
	  $(call makelink,strip)
	  $(call makelink,ranlib)
	  echo "" > $@
	else

          # Build binutils with the standard 'gbuild' function.
	  $(call gbuild, binutils-$(binutils-version), static, \
	                 --with-lib-path=$(sys_library_path), \
	                 -j$(numthreads) )

          # The `ld' linker of Binutils needs several `*crt*.o' files from
          # the host's GNU C Library to run. On some systems these object
          # files aren't installed in standard places. We defined
          # `LIBRARY_PATH' and that fixed the problem for many
          # systems. However, some software (for example ImageMagick)
          # over-write `LIBRARY_PATH', therefore there is no other way than
          # to put a link to these necessary files in our local build
          # directory. IMPORTANT NOTE: later, when we build the GNU C
          # Library in the project, we should remove this step.
	  if ! [ x"$(sys_library_path)" = x ]; then
	    for f in $(sys_library_path)/*crt*.o; do
	      b=$$($(ibdir)/basename $$f)
	      ln -s $$f $(ildir)/$$b
	    done
	  fi

          # Write the final target.
	  echo "GNU Binutils $(binutils-version)" > $@
	fi

# We are having issues with `libiberty' (part of GCC) on Mac. So for now,
# GCC won't be built there. Since almost no natural science paper's
# processing depends so strongly on the compiler used, for now, this isn't
# a bad assumption, but we are indeed searching for a solution.
#
# Based on the GCC manual, the GCC build can benefit from a GNU
# environment. So, we'll build GCC after building all the basic tools that
# are often used in a configure and build scripts of GCC components.
#
# Objective C and Objective C++ is necessary for installing `matplotlib'.
#
# We are currently having problems installing GCC on macOS, so for the time
# being, if the project is being run on a macOS, we'll just set a link.
$(ibidir)/gcc-$(gcc-version): $(ibidir)/binutils-$(binutils-version)

        # Function to let the users know what to do if build fails.
	error_message() {
	    echo; echo
	    echo "_________________________________________________"
	    echo "!!!!!!!!       Warning from Maneage      !!!!!!!!"
	    echo
	    echo "Unfortunately building of GCC failed on this system!"
	    echo "Can you please copy the last ~500 lines above and post it"
	    echo "as a bug here (as an attached file):"
	    echo "  https://sv.nongnu.org/support/?func=additem&group=reproduce"
	    echo
	    echo "In the meantime, please re-configure Maneage with '--host-cc'"
	    echo "like below so it uses your own C compiler for building the"
	    echo "high-level software ('-e' is to use the existing configuration):"
	    echo
	    echo "  ./project configure -e --host-cc"
	    echo
	    echo "__________ SEE NOTE FROM MANEAGE ABOVE __________"
	    echo; exit 1
	}

        # Download the tarball.
	tarball=gcc-$(gcc-version).tar.xz
	$(call import-source, $(gcc-url), $(gcc-checksum))

        # To avoid any previous build in '.local/bin' causing problems in
        # this build/links of this GCC, we'll first delete all the possibly
        # built/existing compilers in this project. Note that GCC also
        # installs several executables like this 'x86_64-pc-linux-gnu-gcc',
        # 'x86_64-pc-linux-gnu-gcc-ar' or 'x86_64-pc-linux-gnu-g++'.
	rm -f $(ibdir)/*g++ $(ibdir)/cpp $(ibdir)/gfortran
	rm -rf $(ildir)/gcc $(ildir)/libcc* $(ildir)/libgcc*
	rm -f $(ibdir)/*gcc* $(ibdir)/gcov* $(ibdir)/cc $(ibdir)/c++
	rm -rf $(ildir)/libgfortran* $(ildir)/libstdc* rm $(idir)/x86_64*

        # GCC builds is own libraries in '$(idir)/lib64'. But all other
        # libraries are in '$(idir)/lib'. Since this project is only for a
        # single architecture, we can trick GCC into building its libraries
        # in '$(idir)/lib' by defining the '$(idir)/lib64' as a symbolic
        # link to '$(idir)/lib'.
	if [ $(host_cc) = 1 ]; then

          # Put links to the host's tools in '.local/bin'. Note that some
          # macOS systems have both a native clang *and* a GNU C Compiler
          # (note that this is different from the "normal" macOS situation
          # where 'gcc' actually points to clang, here we mean when 'gcc'
          # is actually the GNU C Compiler).
          #
          # In such cases, the GCC isn't complete and using it will cause
          # problems when building high-level tools (for example openBLAS,
          # rpcsvc-proto, CMake, xlsxio, Python or Matplotlib among
          # others). To avoid such situations macOSs are configured like
          # this: we'll simply set 'gcc' to point to 'clang' and won't set
          # 'gcc' to point to the system's 'gcc'.
          #
          # Also, note that LLVM's clang doesn't have a C Pre-Processor. So
          # we will only put a link to the host's 'cpp' if the system is
          # not macOS. On macOS systems that have a real GCC installed,
          # having GNU CPP in the project build directory is known to cause
          # problems with 'libX11'.
	  $(call makelink,gfortran)
	  if [ x$(on_mac_os) = xyes ]; then
	    $(call makelink,clang)
	    $(call makelink,clang++)
	    $(call makelink,clang,,gcc)
	    $(call makelink,clang++,,g++)
	  else
	    $(call makelink,cpp)
	    $(call makelink,gcc)
	    $(call makelink,g++)
	  fi

          # We also want to have the two 'cc' and 'c++' in the build
          # directory that point to the selected compiler. With the checks
          # above, 'gcc' and 'g++' will point to the proper compiler, so
          # we'll use them to define 'cc' and 'c++'.
	  $(call makelink,gcc,,cc)
	  $(call makelink,g++,,c++)

          # Get the first line of the compiler's '--version' output and put
          # that into the target (so we know want compiler was used).
	  ccinfo=$$(gcc --version | awk 'NR==1')
	  echo "C compiler (""$$ccinfo"")" > $@

	else

          # Mark the current directory.
	  current_dir=$$(pwd)

          # We don't want '.local/lib' and '.local/lib64' to be separate.
	  ln -fs $(ildir) $(idir)/lib64

          # By default we'll build GCC in the RAM to avoid building so many
          # files and possibly harming the hard-drive or SSD. But if the
          # RAM doesn't have enough space, we can't use it.
	  in_ram=$$(df $(ddir) \
	               | awk 'NR==2{print ($$4>10000000) ? "yes" : "no"}'); \
	  if [ $$in_ram = "yes" ]; then odir=$(ddir)
	  else
	    odir=$(BDIR)/software/build-tmp-gcc
	    if [ -d $$odir ]; then rm -rf $$odir; fi
	    mkdir $$odir
	  fi

          # Go into the proper directory, unpack GCC and prepare the
          # 'build' directory inside it for all the built files.
	  cd $$odir
	  rm -rf gcc-$(gcc-version)
	  tar xf $(tdir)/$$tarball
	  if [ $$odir != $(ddir) ]; then
	    ln -s $$odir/gcc-$(gcc-version) $(ddir)/gcc-$(gcc-version)
	  fi
	  cd gcc-$(gcc-version)
	  mkdir build
	  cd build

          # Configure, build and install GCC, if any of three steps fails,
          # the error message will be printed.
	  if ! ../configure SHELL=$(ibdir)/bash \
	                    --prefix=$(idir) \
	                    --with-mpc=$(idir) \
	                    --with-gmp=$(idir) \
	                    --with-isl=$(idir) \
	                    --with-mpfr=$(idir) \
	                    --with-local-prefix=$(idir) \
	                    --with-build-time-tools=$(idir) \
	                    --enable-lto \
	                    --enable-shared \
	                    --enable-cet=auto \
	                    --enable-default-pie \
	                    --enable-default-ssp \
	                    --enable-decimal-float \
	                    --enable-threads=posix \
	                    --enable-languages=c,c++,fortran,objc,obj-c++ \
	                    --disable-nls \
	                    --disable-libada \
	                    --disable-multilib \
	                    --disable-multiarch; then error_message; fi
	  if ! make SHELL=$(ibdir)/bash -j$(numthreads); then error_message; fi
	  if ! make SHELL=$(ibdir)/bash install; then error_message; fi

          # We need to manually fix the RPATH inside GCC's libraries, the
          # programs built by GCC already have RPATH.
	  tempname=$$odir/gcc-$(gcc-version)/build/rpath-temp-copy
	  if [ -f $(ibdir)/patchelf ]; then

            # Go over all the installed GCC libraries (its executables are
            # fine!).
	    for f in $$(find $(idir)/libexec/gcc -type f) $(ildir)/libstdc++*; do

              # Make sure this is a static library, copy it to a temporary
              # name (to avoid any possible usage of the file while it is
              # being corrected), and add RPATH inside of it and put the
              # corrected file back in its place. In the case of the
              # standard C++ library, we also need to manually insert a
              # linking to libiconv.
	      if file $$f | grep -q "dynamically linked"; then
	        cp $$f $$tempname
	        patchelf --set-rpath $(ildir) $$tempname
	        echo "$$f: added rpath"
	        if echo $$f | grep -q "libstdc++"; then
	          patchelf --add-needed $(ildir)/libiconv.so $$tempname
	          echo "$$f: linked with libiconv"
	        fi
	        mv $$tempname $$f
	      fi
	    done
	  fi

          # Come back up to the un-packing directory and delete the GCC
          # source directory.
	  cd ../..
	  rm -rf gcc-$(gcc-version)
	  cd $$current_dir
	  if [ "$$odir" != "$(ddir)" ]; then
	    rm -rf $$odir;
	    rm $(ddir)/gcc-$(gcc-version);
	  fi

          # Set 'cc' to point to 'gcc'.
	  ln -sf $(ibdir)/gcc $(ibdir)/cc
	  ln -sf $(ibdir)/g++ $(ibdir)/c++

          # Write the final target.
	  echo "GNU Compiler Collection (GCC) $(gcc-version)" > $@
	fi










# Level 6: Basic text editor
# --------------------------
#
# If the project is built in a minimal environment, there is no text
# editor, making it hard to work on the project. By default a minimal
# (relatively user-friendly: GNU Nano) text editor will thus also be built
# at the end of the "basic" tools. More advanced editors are available as
# optional high-level programs. GNU Nano is a very light-weight and small
# command-line text editor (around 3.5 Mb after installation!).
#
# The editor is a top-level target in the basic tools (given to
# 'targets-proglib' above). Hence nothing depends on it, and it just
# depends on GCC. This is done because some projects may choose to not have
# nano (and use their own optional high-level text editor). To do this,
# they just have to manually remove 'nano' from 'targets-proglib' above and
# add their optional text editor in 'TARGETS.conf'.
$(ibidir)/nano-$(nano-version): $(ibidir)/gcc-$(gcc-version)
	tarball=nano-$(nano-version).tar.xz
	$(call import-source, $(nano-url), $(nano-checksum))
	$(call gbuild, nano-$(nano-version), static)
	echo "GNU Nano $(nano-version)" > $@
