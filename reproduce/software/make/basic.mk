# Build the VERY BASIC project software before higher-level ones. Assuming
# minimal/generic Make and Shell.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./project configure' script. It
# is not included into the project after that.
#
# This Makefile builds very low-level and basic tools like GNU Tar, GNU
# Bash, GNU Make, GCC and etc. Therefore this is the only Makefile in the
# project where you CANNOT assume that GNU Bash or GNU Make are used. After
# this Makefile (where GNU Bash and GNU Make are built), other Makefiles
# can safely assume the fixed version of all these software.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2018-2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Copyright (C) 2019 Raul Infante-Sainz <infantesainz@gmail.com>
#
# This Makefile is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This Makefile is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.


# Top level environment
include reproduce/software/make/build-rules.mk
include reproduce/software/config/installation/LOCAL.mk
include reproduce/software/config/installation/versions.mk
include reproduce/software/config/installation/checksums.mk

lockdir = $(BDIR)/locks
tdir    = $(BDIR)/software/tarballs
ddir    = $(BDIR)/software/build-tmp
idir    = $(BDIR)/software/installed
ibdir   = $(BDIR)/software/installed/bin
ildir   = $(BDIR)/software/installed/lib
ibidir  = $(BDIR)/software/installed/version-info/proglib

# We'll need the system's PATH for making links to low-level programs we
# won't be building ourselves.
syspath         := $(PATH)

# As we build more programs, we want to use this project's built programs
# and libraries, not the host's.
export CCACHE_DISABLE := 1
export PATH := $(ibdir):$(PATH)
export PKG_CONFIG_PATH := $(ildir)/pkgconfig
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig
export CPPFLAGS := -I$(idir)/include $(CPPFLAGS)
export LDFLAGS := $(rpath_command) -L$(ildir) $(LDFLAGS)
export LD_LIBRARY_PATH := $(shell echo $(LD_LIBRARY_PATH) \
                                  | sed -e's/::/:/g' -e's/^://' -e's/:$$//')

# RPATH is automatically written in macOS, so `DYLD_LIBRARY_PATH' is
# ultimately redundant. But on some systems, even having a single value
# causes crashs (see bug #56682). So we'll just give it no value at all.
export DYLD_LIBRARY_PATH :=

# Recipe startup script, see `reproduce/software/bash/bashrc.sh'.
export PROJECT_STATUS := configure_basic
export BASH_ENV := $(shell pwd)/reproduce/software/bash/bashrc.sh

# Define the top-level basic programs (that don't depend on any other).
top-level-programs = low-level-links gcc
all: $(foreach p, $(top-level-programs), $(ibidir)/$(p))





# Tarballs
# --------
#
# Prepare tarballs. Difference with that in `high-level.mk': `.ONESHELL' is
# not recognized by some versions of Make (even older GNU Makes). So we'll
# have to make sure the recipe doesn't break into multiple shell calls (so
# we can preserve the variables).
#
# Software with main webpage at our backup repository
# (http://akhlaghi.org/reproduce-software): As of our latest check their
# major release tarballs either crash or don't build on some systems (for
# example Make or Gzip), or they don't exist (for example Bzip2). So we are
# building them from their Git history (which builds properly) or host them
# directly.
#
# In the first case, we used their Git repo and bootstrapped them (just
# like Gnuastro) and built the most recent tarball off of that. In the case
# of Bzip2: its webpage has expired and doesn't host the data any more. It
# is available on the link below (archive.org):
#
# https://web.archive.org/web/20180624184806/http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
#
# However, downloading from this link is slow (because its just a link). So
# its easier to just keep a with the others.
$(lockdir): | $(BDIR); mkdir $@
downloadwrapper = ./reproduce/analysis/bash/download-multi-try
tarballs = $(foreach t, bash-$(bash-version).tar.lz \
                        binutils-$(binutils-version).tar.lz \
                        bzip2-$(bzip2-version).tar.gz \
                        cert.pem \
                        coreutils-$(coreutils-version).tar.xz \
                        curl-$(curl-version).tar.gz \
                        diffutils-$(diffutils-version).tar.xz \
                        file-$(file-version).tar.gz \
                        findutils-$(findutils-version).tar.xz \
                        gawk-$(gawk-version).tar.lz \
                        gcc-$(gcc-version).tar.xz \
                        git-$(git-version).tar.xz \
                        gmp-$(gmp-version).tar.lz \
                        grep-$(grep-version).tar.xz \
                        gzip-$(gzip-version).tar.gz \
                        isl-$(isl-version).tar.bz2 \
                        libbsd-$(libbsd-version).tar.xz	\
                        libiconv-$(libiconv-version).tar.gz \
                        libtool-$(libtool-version).tar.xz \
                        lzip-$(lzip-version).tar.gz \
                        m4-$(m4-version).tar.gz \
                        make-$(make-version).tar.gz \
                        metastore-$(metastore-version).tar.gz \
                        mpfr-$(mpfr-version).tar.xz \
                        mpc-$(mpc-version).tar.gz \
                        ncurses-$(ncurses-version).tar.gz \
                        openssl-$(openssl-version).tar.gz \
                        patchelf-$(patchelf-version).tar.gz \
                        perl-$(perl-version).tar.gz \
                        pkg-config-$(pkgconfig-version).tar.gz \
                        readline-$(readline-version).tar.gz \
                        sed-$(sed-version).tar.xz \
                        tar-$(tar-version).tar.gz \
                        texinfo-$(texinfo-version).tar.xz \
                        unzip-$(unzip-version).tar.gz \
                        wget-$(wget-version).tar.lz \
                        which-$(which-version).tar.gz \
                        xz-$(xz-version).tar.gz \
                        zip-$(zip-version).tar.gz \
                        zlib-$(zlib-version).tar.gz \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%: | $(lockdir)

	n=$$(echo $* | sed -e's/[0-9\-]/ /g' \
	                   -e's/\./ /g' \
	             | awk '{print $$1}' ); \
	                                    \
	mergenames=1; \
	if   [ $$n = bash      ]; then c=$(bash-checksum); w=http://akhlaghi.org/reproduce-software; \
	elif [ $$n = binutils  ]; then c=$(binutils-checksum); w=http://ftp.gnu.org/gnu/binutils; \
	elif [ $$n = bzip      ]; then c=$(bzip2-checksum); w=http://akhlaghi.org/reproduce-software; \
	elif [ $$n = cert      ]; then c=$(cert-checksum); w=http://akhlaghi.org/reproduce-software; \
	elif [ $$n = coreutils ]; then c=$(coreutils-checksum); w=http://ftp.gnu.org/gnu/coreutils;\
	elif [ $$n = curl      ]; then c=$(curl-checksum); w=https://curl.haxx.se/download; \
	elif [ $$n = diffutils ]; then c=$(diffutils-checksum); w=http://ftp.gnu.org/gnu/diffutils;\
	elif [ $$n = file      ]; then c=$(file-checksum); w=ftp://ftp.astron.com/pub/file; \
	elif [ $$n = findutils ]; then c=$(findutils-checksum); w=http://ftp.gnu.org/gnu/findutils; \
	elif [ $$n = gawk      ]; then c=$(gawk-checksum); w=http://ftp.gnu.org/gnu/gawk; \
	elif [ $$n = gcc       ]; then c=$(gcc-checksum); w=http://ftp.gnu.org/gnu/gcc/gcc-$(gcc-version); \
	elif [ $$n = git       ]; then c=$(git-checksum); w=http://mirrors.edge.kernel.org/pub/software/scm/git; \
	elif [ $$n = gmp       ]; then c=$(gmp-checksum); w=https://gmplib.org/download/gmp; \
	elif [ $$n = grep      ]; then c=$(grep-checksum); w=http://ftp.gnu.org/gnu/grep; \
	elif [ $$n = gzip      ]; then c=$(gzip-checksum); w=http://ftp.gnu.org/gnu/gzip; \
	elif [ $$n = isl       ]; then c=$(isl-checksum); w=ftp://gcc.gnu.org/pub/gcc/infrastructure; \
	elif [ $$n = libbsd    ]; then c=$(libbsd-checksum); w=http://libbsd.freedesktop.org/releases; \
	elif [ $$n = libiconv  ]; then c=$(libiconv-checksum); w=https://ftp.gnu.org/pub/gnu/libiconv; \
	elif [ $$n = libtool   ]; then c=$(libtool-checksum); w=http://ftp.gnu.org/gnu/libtool; \
	elif [ $$n = lzip      ]; then c=$(lzip-checksum); w=http://download.savannah.gnu.org/releases/lzip; \
	elif [ $$n = m         ]; then \
	  mergenames=0; \
	  c=$(m4-checksum); \
	  w=http://akhlaghi.org/reproduce-software/m4-1.4.18-patched.tar.gz; \
	elif [ $$n = make      ]; then c=$(make-checksum); w=https://alpha.gnu.org/gnu/make; \
	elif [ $$n = metastore ]; then c=$(metastore-checksum); w=http://akhlaghi.org/reproduce-software; \
	elif [ $$n = mpc       ]; then c=$(mpc-checksum); w=http://ftp.gnu.org/gnu/mpc; \
	elif [ $$n = mpfr      ]; then c=$(mpfr-checksum); w=http://www.mpfr.org/mpfr-current;\
	elif [ $$n = ncurses   ]; then c=$(ncurses-checksum); w=http://ftp.gnu.org/gnu/ncurses; \
	elif [ $$n = openssl   ]; then c=$(openssl-checksum); w=http://www.openssl.org/source; \
	elif [ $$n = patchelf  ]; then c=$(patchelf-checksum); w=http://nixos.org/releases/patchelf/patchelf-$(patchelf-version); \
	elif [ $$n = perl      ]; then \
	  c=$(perl-checksum); \
	  v=$$(echo $(perl-version) | sed -e's/\./ /g' | awk '{printf("%d.0", $$1)}'); \
	  w=https://www.cpan.org/src/$$v; \
	elif [ $$n = pkg       ]; then c=$(pkgconfig-checksum); w=http://pkg-config.freedesktop.org/releases; \
	elif [ $$n = readline  ]; then c=$(readline-checksum); w=http://ftp.gnu.org/gnu/readline; \
	elif [ $$n = sed       ]; then c=$(sed-checksum); w=http://ftp.gnu.org/gnu/sed; \
	elif [ $$n = tar       ]; then c=$(tar-checksum); w=http://ftp.gnu.org/gnu/tar; \
	elif [ $$n = texinfo   ]; then c=$(texinfo-checksum); w=http://ftp.gnu.org/gnu/texinfo; \
	elif [ $$n = unzip     ]; then \
	  c=$(unzip-checksum); \
	  mergenames=0; v=$$(echo $(unzip-version) | sed -e's/\.//'); \
	  w=ftp://ftp.info-zip.org/pub/infozip/src/unzip$$v.tgz; \
	elif [ $$n = wget      ]; then c=$(wget-checksum); w=http://ftp.gnu.org/gnu/wget; \
	elif [ $$n = which     ]; then c=$(which-checksum); w=http://ftp.gnu.org/gnu/which; \
	elif [ $$n = xz        ]; then c=$(xz-checksum); w=http://tukaani.org/xz; \
	elif [ $$n = zip       ]; then \
	  c=$(zip-checksum); \
	  mergenames=0; v=$$(echo $(zip-version) | sed -e's/\.//'); \
	  w=ftp://ftp.info-zip.org/pub/infozip/src/zip$$v.tgz; \
	elif [ $$n = zlib      ]; then c=$(zlib-checksum); w=http://www.zlib.net; \
	else \
	  echo; echo; echo; \
	  echo "'$$n' not recognized as a software tarball name to download."; \
	  echo; echo; echo; \
	  exit 1; \
	fi; \
	                                       \
	                                       \
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then \
	  cp $(DEPENDENCIES-DIR)/$* "$@.unchecked"; \
	else \
	  if [ $$mergenames = 1 ]; then  tarballurl=$$w/"$*"; \
	  else                           tarballurl=$$w; \
	  fi; \
	      \
	  echo "Downloading $$tarballurl"; \
	  if [ -f $(ibdir)/wget ]; then \
	    downloader="wget --no-use-server-timestamps -O"; \
	  else \
	    downloader="$(DOWNLOADER)"; \
	  fi; \
	      \
	  touch $(lockdir)/download; \
	  $(downloadwrapper) "$$downloader" $(lockdir)/download \
	                     $$tarballurl "$@.unchecked"; \
	fi; \
	                                                \
	                                                \
	if type sha512sum > /dev/null 2>/dev/null; then \
	  checksum=$$(sha512sum "$@.unchecked" | awk '{print $$1}'); \
	  echo "$*: should be '$$c', is '$$checksum'"; \
	  if [ x$$checksum = x$$c ]; then mv "$@.unchecked" "$@"; \
	  else echo "ERROR: Non-matching checksum for '$*'."; exit 1; \
	  fi; \
	else mv "$@.unchecked" "$@"; \
	fi;





# Low-level (not built) programs
# ------------------------------
#
# For the time being, we aren't building a local C compiler, but we'll use
# any C compiler that the system already has and just make a symbolic link
# to it.
#
# ccache: ccache acts like a wrapper over the C compiler and is made to
# avoid/speed-up compiling of identical files in a system (it is commonly
# used on large servers). It actually makes `gcc' or `g++' a symbolic link
# to itself so it can control them internally. So, for our purpose here, it
# is very annoying and can cause many complications. We thus remove any
# part of PATH of that has `ccache' in it before making symbolic links to
# the programs we are not building ourselves.
makelink = origpath="$$PATH"; \
	   export PATH=$$(echo $(syspath) \
	                       | tr : '\n' \
	                       | grep -v ccache \
	                       | tr '\n' :); \
	   a=$$(which $(1) 2> /dev/null); \
	   if [ -e $(ibdir)/$(1) ]; then rm $(ibdir)/$(1); fi; \
	   if [ x$$a = x ]; then \
	     if [ "x$(strip $(2))" = xmandatory ]; then \
	       echo "'$(1)' is necessary for higher-level tools."; \
	       echo "Please install it for the configuration to continue."; \
	       exit 1; \
	     fi; \
	   else \
	     ln -s $$a $(ibdir)/$(1); \
	   fi; \
	   export PATH="$$origpath"
$(ibdir) $(ildir):; mkdir $@
$(ibidir)/low-level-links: | $(ibdir) $(ildir)

        # Not-installed (but necessary in some cases) compilers.
        #  Clang is necessary for CMake.
	$(call makelink,clang)
	$(call makelink,clang++)

        # Mac OS specific
	$(call makelink,sysctl)
	$(call makelink,sw_vers)
	$(call makelink,dsymutil)
	$(call makelink,install_name_tool)

        # On Mac OS, libtool is different compared to GNU Libtool. The
        # libtool we'll build in the high-level dependencies has the
        # executable name `glibtool'.
	$(call makelink,libtool)

        # GNU Gettext (translate messages)
	$(call makelink,msgfmt)

        # Necessary libraries:
        #   Libdl (for dynamic loading libraries at runtime)
        #   POSIX Threads library for multi-threaded programs.
	for l in dl pthread; do \
          rm -f $(ildir)/lib$$l*; \
	  if [ -f /usr/lib/lib$$l.a ]; then \
	    ln -s /usr/lib/lib$$l.* $(ildir)/; \
	  fi; \
	done

        # We want this to be empty (so it doesn't interefere with the other
        # files in `ibidir'.
	touch $@










# Level 1 (MOST BASIC): Compression programs
# ------------------------------------------
#
# The first set of programs to be built are those that we need to unpack
# the source code tarballs of each program. First, we'll build the
# necessary programs, then we'll build GNU Tar.
$(ibidir)/gzip: | $(tdir)/gzip-$(gzip-version).tar.gz
	$(call gbuild, gzip-$(gzip-version), static, , V=1) \
	&& echo "GNU Gzip $(gzip-version)" > $@

# GNU Lzip: For a static build, the `-static' flag should be given to
# LDFLAGS on the command-line (not from the environment).
ifeq ($(static_build),yes)
lzipconf="LDFLAGS=-static"
else
lzipconf=
endif
$(ibidir)/lzip: | $(tdir)/lzip-$(lzip-version).tar.gz
	$(call gbuild, lzip-$(lzip-version), , $(lzipconf)) \
	&& echo "Lzip $(lzip-version)" > $@

$(ibidir)/xz: | $(tdir)/xz-$(xz-version).tar.gz
	$(call gbuild, xz-$(xz-version), static) \
	&& echo "XZ Utils $(xz-version)" > $@

$(ibidir)/bzip2: | $(tdir)/bzip2-$(bzip2-version).tar.gz
        # Bzip2 doesn't have a `./configure' script, and its Makefile
        # doesn't build a shared library. So we can't use the `gbuild'
        # function here and we need to take some extra steps (inspired
        # from the "Linux from Scratch" guide for Bzip2):
        #   1) The `sed' call is for relative installed symbolic links.
        #   2) The special Makefile-libbz2_so builds shared libraries.
        #
        # NOTE: the major version number appears in the final symbolic
        # link.
	tdir=bzip2-$(bzip2-version); \
	if [ $(static_build) = yes ]; then \
	  makecommand="make LDFLAGS=-static"; \
	  makeshared="echo no-shared"; \
	else \
	  makecommand="make"; \
	  if [ x$(on_mac_os) = xyes ]; then \
	    makeshared="echo no-shared"; \
	  else \
	    makeshared="make -f Makefile-libbz2_so"; \
	  fi; \
	fi; \
	cd $(ddir) && rm -rf $$tdir \
	&& tar xf $(word 1,$(filter $(tdir)/%,$|)) \
	&& cd $$tdir \
	&& sed -e 's@\(ln -s -f \)$$(PREFIX)/bin/@\1@' Makefile \
	       > Makefile.sed \
	&& mv Makefile.sed Makefile \
	&& $$makeshared \
	&& cp -a libbz2* $(ildir)/ \
	&& make clean \
	&& $$makecommand \
	&& make install PREFIX=$(idir) \
	&& cd .. \
	&& rm -rf $$tdir \
	&& cd $(ildir) \
	&& ln -fs libbz2.so.1.0 libbz2.so \
	&& echo "Bzip2 $(bzip2-version)" > $@

$(ibidir)/unzip: | $(tdir)/unzip-$(unzip-version).tar.gz
	v=$$(echo $(unzip-version) | sed -e's/\.//'); \
	$(call gbuild, unzip$$v, static,, \
	               -f unix/Makefile generic_gcc \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd, \
	               -f unix/Makefile \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 ) \
	&& echo "Unzip $(unzip-version)" > $@

$(ibidir)/zip: | $(tdir)/zip-$(zip-version).tar.gz
	v=$$(echo $(zip-version) | sed -e's/\.//'); \
	$(call gbuild, zip$$v, static,, \
	               -f unix/Makefile generic_gcc \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd, \
	               -f unix/Makefile \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 ) \
	&& echo "Zip $(zip-version)" > $@

# Some programs (like Wget and CMake) that use zlib need it to be dynamic
# so they use our custom build. So we won't force a static-only build.
#
# Note for a static-only build: Zlib's `./configure' doesn't use Autoconf's
# configure script, it just accepts a direct `--static' option.
$(ibidir)/zlib: | $(tdir)/zlib-$(zlib-version).tar.gz
	$(call gbuild, zlib-$(zlib-version)) \
	&& echo "Zlib $(zlib-version)" > $@

# GNU Tar: When built statically, tar gives a segmentation fault on
# unpacking Bash. So we'll build it dynamically. Note that technically, zip
# and unzip aren't dependencies of Tar, but for a clean build, we'll set
# Tar to be the last compression-related software (the first-set of
# software to be built).
$(ibidir)/tar: $(ibidir)/xz \
	       $(ibidir)/zip \
	       $(ibidir)/gzip \
	       $(ibidir)/lzip \
               $(ibidir)/zlib \
               $(ibidir)/bzip2 \
	       $(ibidir)/unzip \
               | $(tdir)/tar-$(tar-version).tar.gz
        # Since all later programs depend on Tar, the configuration will be
        # stuck here, only making Tar. So its more efficient to built it on
        # multiple threads (when the user's Make doesn't pass down the
        # number of threads).
	$(call gbuild, tar-$(tar-version), , , -j$(numthreads) V=1) \
	&& echo "GNU Tar $(tar-version)" > $@










# Level 2 (SECOND MOST BASIC): Bash and Make
# ------------------------------------------
#
# GNU Make and GNU Bash are the second layer that we'll need to build the
# basic dependencies.
#
# Unfortunately Make needs dynamic linking in two instances: when loading
# objects (dynamically linked libraries), or when using the `getpwnam'
# function (for tilde expansion). The first can be disabled with
# `--disable-load', but unfortunately I don't know any way to fix the
# second. So, we'll have to build it dynamically for now.
$(ibidir)/make: | $(ibidir)/tar \
                  $(tdir)/make-$(make-version).tar.gz
        # See Tar's comments for the `-j' option.
	$(call gbuild, make-$(make-version), , , -j$(numthreads)) \
	&& echo "GNU Make $(make-version)" > $@

$(ibidir)/ncurses: | $(ibidir)/make \
                     $(tdir)/ncurses-$(ncurses-version).tar.gz

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
        # This part is taken from the Arch Linux build script[1], then
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
	if [ x$(on_mac_os) = xyes ]; then so="dylib"; else so="so"; fi; \
	if [ -f $(ildir)/libncursesw.$$so ]; then \
	                                          \
	  sov=$$(ls -l $(ildir)/libncursesw* \
	               | awk '/^-/{print $$NF}' \
	               | sed -e's|'$(ildir)/libncursesw.'||'); \
	                                                       \
	  cd "$(ildir)"; \
	  for lib in ncurses ncurses++ form panel menu; do \
	    ln -fs lib$$lib"w".$$sov     lib$$lib.$$so; \
	    ln -fs $(ildir)/pkgconfig/"$$lib"w.pc pkgconfig/$$lib.pc; \
	  done; \
	  for lib in tic tinfo; do \
	    ln -fs libncursesw.$$sov     lib$$lib.$$so; \
	    ln -fs libncursesw.$$sov     lib$$lib.$$sov; \
	    ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/$$lib.pc; \
	  done; \
	  ln -fs libncursesw.$$sov libcurses.$$so; \
	  ln -fs libncursesw.$$sov libcursesw.$$sov; \
	  ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/curses.pc; \
	  ln -fs $(ildir)/pkgconfig/ncursesw.pc pkgconfig/cursesw.pc; \
	                                                              \
	  ln -fs $(idir)/include/ncursesw $(idir)/include/ncurses; \
	  echo "GNU NCURSES $(ncurses-version)" > $@; \
	else \
	  exit 1; \
	fi

$(ibidir)/readline: $(ibidir)/ncurses \
                    | $(tdir)/readline-$(readline-version).tar.gz
	$(call gbuild, readline-$(readline-version), static, \
	               --with-curses --disable-install-examples, \
	               SHLIB_LIBS="-lncursesw" -j$(numthreads)) \
	&& echo "GNU Readline $(readline-version)" > $@

# When we have a static C library, PatchELF will be built statically. This
# is because PatchELF links with the C++ standard library. But we need to
# run PatchELF later on `libstdc++'! This circular dependency can cause a
# crash, so when PatchELF can't be built statically, we won't build GCC
# either, see the `configure.sh' script where we define `good_static_libc'
# for more.
$(ibidir)/patchelf: | $(ibidir)/make \
                      $(tdir)/patchelf-$(patchelf-version).tar.gz
	if [ $(good_static_libc) = 1 ]; then \
	  export LDFLAGS="$$LDFLAGS -static"; \
	fi; \
	$(call gbuild, patchelf-$(patchelf-version), static) \
	&& echo "PatchELF $(patchelf-version)" > $@


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

ifeq ($(on_mac_os),yes)
needpatchelf =
else
needpatchelf = $(ibidir)/patchelf
endif
$(ibidir)/bash: $(ibidir)/readline \
                | $(needpatchelf) \
                  $(tdir)/bash-$(bash-version).tar.lz

        # Delete the (possibly) existing Bash executable.
	rm -f $(ibdir)/bash

        # Build Bash. Note that we aren't building Bash with
        # `--with-installed-readline'. This is because (as described above)
        # Bash needs the `LD_LIBRARY_PATH' set properly before it is
        # run. Within a recipe, things are fine (we do set
        # `LD_LIBRARY_PATH'). However, Make will also call the shell
        # outside of the recipe (for example in the `foreach' Make
        # function!). In such cases, our new `LD_LIBRARY_PATH' is not set.
        # This will cause a crash in the shell and thus the Makefile,
        # complaining that it can't find `libreadline'. Therefore, even
        # though we build readline below, we won't link Bash with an
        # external readline.
        #
        # Bash has many `--enable' features which are already enabled by
        # default. As described in the manual, they are mainly useful when
        # you disable them all with `--enable-minimal-config' and enable a
        # subset using the `--enable' options.
	if [ "x$(static_build)" = xyes ]; then stopt="--enable-static-link";\
	else                                   stopt=""; \
	fi; \
	$(call gbuild, bash-$(bash-version),, \
	               --with-installed-readline=$(ildir) $$stopt, \
                       -j$(numthreads))

        # Atleast on GNU/Linux systems, Bash doesn't include RPATH by
        # default. So, we have to manually include it, currently we are
        # only doing this on GNU/Linux systems (using the `patchelf'
        # program).
	if [ "x$(needpatchelf)" != x ]; then \
	  if [ -f $(ibdir)/bash ]; then \
	    $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/bash; fi \
	fi

        # To be generic, some systems use the `sh' command to call the
        # shell. By convention, `sh' is just a symbolic link to the
        # preferred shell executable. So we'll define `$(ibdir)/sh' as a
        # symbolic link to the Bash that we just built and installed.
        #
        # Just to be sure that the installation step above went well,
        # before making the link, we'll see if the file actually exists
        # there.
	if [ -f $(ibdir)/bash ]; then \
	  ln -fs $(ibdir)/bash $(ibdir)/sh; \
	  echo "GNU Bash $(bash-version)" > $@; \
	else \
	  echo "GNU Bash not built!"; exit 1; fi





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
$(ibidir)/coreutils: $(ibidir)/openssl \
	             | $(ibidir)/bash \
                       $(tdir)/coreutils-$(coreutils-version).tar.xz
	cd $(ddir) \
	&& rm -rf coreutils-$(coreutils-version) \
	&& if ! tar xf $(word 1,$(filter $(tdir)/%,$|)); then \
	      echo; echo "Tar error"; exit 1; \
	   fi \
	&& cd coreutils-$(coreutils-version) \
	&& sed -e's|\#\! /bin/sh|\#\! $(ibdir)/bash|' \
	       -e's|\#\!/bin/sh|\#\! $(ibdir)/bash|' \
	       configure > configure-tmp \
	&& mv configure-tmp configure \
	&& chmod +x configure \
	&& ./configure --prefix=$(idir) SHELL=$(ibdir)/bash  \
	               LDFLAGS="$(LDFLAGS)" CPPFLAGS="$(CPPFLAGS)" \
	               --disable-silent-rules --with-openssl=yes \
	&& make SHELL=$(ibdir)/bash -j$(numthreads) \
	&& make SHELL=$(ibdir)/bash install \
	&& if [ x$(on_mac_os) != xyes ]; then \
	     make SHELL=$(ibdir)/bash install DESTDIR=junkinst; \
	     instprogs=$$(ls junkinst/$(ibdir)); \
	     for f in $$instprogs; do \
	       $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/$$f; \
	     done; \
	     echo "PatchELF applied to all programs."; \
	   fi \
	&& cd .. \
	&& rm -rf coreutils-$(coreutils-version) \
	&& echo "GNU Coreutils $(coreutils-version)" > $@

# OpenSSL
#
# Some programs/libraries later need dynamic linking. So we'll build libssl
# (and libcrypto) dynamically also.
#
# Until we find a nice and generic way to create an updated CA file in the
# project, the certificates will be available in a file for this project
# along with the other tarballs.
#
# In case you do want a static OpenSSL and libcrypto, then uncomment the
# following conditional and put $(openssl-static) in the configure options.
#
#ifeq ($(static_build),yes)
#openssl-static = no-dso no-dynamic-engine no-shared
#endif
$(idir)/etc:; mkdir $@
$(ibidir)/openssl: $(tdir)/cert.pem \
                   | $(idir)/etc \
                     $(ibidir)/make  \
                     $(tdir)/openssl-$(openssl-version).tar.gz
        # According to OpenSSL's Wiki (link bellow), it can't automatically
        # detect Mac OS's structure. It will need some help. So we'll use
        # the `on_mac_os' Make variable that we defined in the configure
        # script and help it with some extra configuration options and an
        # environment variable.
        #
        # https://wiki.openssl.org/index.php/Compilation_and_Installation
	if [ x$(on_mac_os) = xyes ]; then \
	  export KERNEL_BITS=64; \
	  copt="shared no-ssl2 no-ssl3 enable-ec_nistp_64_gcc_128";  \
	fi; \
	$(call gbuild, openssl-$(openssl-version), , \
	               zlib \
	               $$copt \
	               $(rpath_command) \
	               --openssldir=$(idir)/etc/ssl \
	               --with-zlib-lib=$(ildir) \
	               --with-zlib-include=$(idir)/include, \
	               -j$(numthreads), , ./config ) \
	&& cp $(tdir)/cert.pem $(idir)/etc/ssl/cert.pem \
	&& if [ $$? = 0 ]; then \
	     if [ x$(on_mac_os) = xyes ]; then \
	       echo "No need to fix rpath in libssl"; \
	     else \
	       patchelf --set-rpath $(ildir) $(ildir)/libssl.so; \
	     fi; \
	     echo "OpenSSL $(openssl-version)" > $@; \
	   fi




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
$(ibidir)/curl: | $(ibidir)/coreutils \
                  $(tdir)/curl-$(curl-version).tar.gz
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
	               --without-nss, V=1) \
	&& if [ "x$(needpatchelf)" != x ]; then \
	     $(ibdir)/patchelf --set-rpath $(ildir) $(ildir)/libcurl.so; \
	   fi \
	&& echo "cURL $(curl-version)" > $@


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
$(ibidir)/wget: $(ibidir)/libiconv \
                | $(ibidir)/coreutils \
                  $(tdir)/wget-$(wget-version).tar.lz
        # We need to explicitly disable `libiconv', because of the
        # `pkg-config' and `libiconv' problem.
	libs="-pthread"; \
	if [ x$(needs_ldl) = xyes ]; then libs="$$libs -ldl"; fi; \
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
	               --disable-iri, V=1) \
	&& echo "GNU Wget $(wget-version)" > $@







# Basic command-line tools and their dependencies
# -----------------------------------------------
#
# These are basic programs which are commonly necessary in the build
# process of the higher-level programs and libraries. Note that during the
# building of those higher-level programs (after this Makefile finishes),
# there is no access to the system's PATH.
$(ibidir)/diffutils: | $(ibidir)/coreutils \
                       $(tdir)/diffutils-$(diffutils-version).tar.xz
	$(call gbuild, diffutils-$(diffutils-version), static, , V=1) \
	&& echo "GNU Diffutils $(diffutils-version)" > $@

$(ibidir)/file: | $(ibidir)/coreutils \
                  $(tdir)/file-$(file-version).tar.gz
	$(call gbuild, file-$(file-version), static) \
	&& echo "File $(file-version)" > $@

$(ibidir)/findutils: | $(ibidir)/coreutils \
                       $(tdir)/findutils-$(findutils-version).tar.xz
	$(call gbuild, findutils-$(findutils-version), static, , V=1) \
	&& echo "GNU Findutils $(findutils-version)" > $@

$(ibidir)/gawk: $(ibidir)/gmp \
                $(ibidir)/mpfr \
                | $(ibidir)/coreutils \
                  $(tdir)/gawk-$(gawk-version).tar.lz
        # AWK doesn't include RPATH by default, so we'll have to manually
        # include it using the `patchelf' program (which was a dependency
        # of Bash). Just note that AWK produces two executables (for
        # example `gawk-4.2.1' and `gawk') and a symbolic link `awk' to one
        # of those executables.
	$(call gbuild, gawk-$(gawk-version), static, \
	               --with-readline=$(idir)) \
	&& if [ "x$(needpatchelf)" != x ]; then \
	     if [ -f $(ibdir)/gawk ]; then \
	       $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/gawk; \
	     fi; \
	     if [ -f $(ibdir)/gawk-$(gawk-version) ]; then \
	       $(ibdir)/patchelf --set-rpath $(ildir) \
	                         $(ibdir)/gawk-$(gawk-version); \
	    fi; \
	   fi \
	&& echo "GNU AWK $(gawk-version)" > $@

$(ibidir)/libiconv: | $(ibidir)/pkg-config \
                      $(tdir)/libiconv-$(libiconv-version).tar.gz
	$(call gbuild, libiconv-$(libiconv-version), static) \
	&& echo "GNU libiconv $(libiconv-version)" > $@

$(ibidir)/git: $(ibidir)/curl \
               $(ibidir)/libiconv \
               | $(tdir)/git-$(git-version).tar.xz
	if [ x$(on_mac_os) = xyes ]; then \
	  export LDFLAGS="$$LDFLAGS -lcharset"; \
	fi; \
	$(call gbuild, git-$(git-version), static, \
	               --without-tcltk --with-shell=$(ibdir)/bash \
	               --with-iconv=$(idir), V=1) \
	&& echo "Git $(git-version)" > $@

$(ibidir)/gmp: | $(ibidir)/m4 \
                 $(ibidir)/coreutils \
                 $(tdir)/gmp-$(gmp-version).tar.lz
	$(call gbuild, gmp-$(gmp-version), static, \
	               --enable-cxx --enable-fat, ,make check)  \
	&& echo "GNU Multiple Precision Arithmetic Library $(gmp-version)" > $@

# On Mac OS, libtool does different things, so to avoid confusion, we'll
# prefix GNU's libtool executables with `glibtool'.
$(ibidir)/glibtool: | $(ibidir)/m4 \
                      $(tdir)/libtool-$(libtool-version).tar.xz
	$(call gbuild, libtool-$(libtool-version), static, \
                       --program-prefix=g) \
	&& ln -s $(ibdir)/glibtoolize $(ibdir)/libtoolize \
	&& echo "GNU Libtool $(libtool-version)" > $@

$(ibidir)/grep: | $(ibidir)/coreutils \
                  $(tdir)/grep-$(grep-version).tar.xz
	$(call gbuild, grep-$(grep-version), static) \
	&& echo "GNU Grep $(grep-version)" > $@

$(ibidir)/libbsd: | $(ibidir)/coreutils \
                    $(tdir)/libbsd-$(libbsd-version).tar.xz
	$(call gbuild, libbsd-$(libbsd-version), static,,V=1) \
	&& echo "Libbsd $(libbsd-version)" > $@

$(ibidir)/m4: | $(ibidir)/coreutils \
                $(ibidir)/texinfo \
                $(tdir)/m4-$(m4-version).tar.gz
	$(call gbuild, m4-$(m4-version), static) \
	&& echo "GNU M4 $(m4-version)" > $@

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
ifeq ($(on_mac_os),yes)
needlibbsd =
else
needlibbsd = $(ibidir)/libbsd
endif
$(ibidir)/metastore: $(needlibbsd) \
                     | $(ibidir)/sed \
                       $(ibidir)/git \
                       $(ibidir)/gawk \
                       $(ibidir)/coreutils \
                       $(tdir)/metastore-$(metastore-version).tar.gz

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
        # We want to inform the user if Metastore isn't built, so we don't
        # continue the call to `gbuild' with an `&&'.
        #
        # Checking for presence of `.git'. When the project source is
        # downloaded from a non-Git source (for example from arXiv), there
        # is no `.git' directory to work with. So until we find a better
        # solution, avoid the step to to add the Git hooks.
	current_dir=$$(pwd); \
	$(call gbuild, metastore-$(metastore-version), static,, \
	               NO_XATTR=1 V=1,,pwd,PREFIX=$(idir)); \
	if [ -f $(ibdir)/metastore ]; then \
	  if [ "x$(needpatchelf)" != x ]; then \
	    $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/metastore; \
	  fi; \
	  if [ -d .git ]; then \
	    user=$$(whoami); \
	    group=$$(groups | awk '{print $$1}'); \
	    cd $$current_dir; \
	    for f in pre-commit post-checkout; do \
	       sed -e's|@USER[@]|'$$user'|g' \
	           -e's|@GROUP[@]|'$$group'|g' \
	           -e's|@BINDIR[@]|$(ibdir)|g' \
	           -e's|@TOP_PROJECT_DIR[@]|'$$current_dir'|g' \
	           reproduce/software/bash/git-$$f > .git/hooks/$$f \
	       && chmod +x .git/hooks/$$f; \
	    done; \
	  fi \
	  && echo "Metastore (forked) $(metastore-version)" > $@; \
	else \
	  echo; echo; echo; \
	  echo "*****************"; \
	  echo "metastore couldn't be installed!"; \
	  echo; \
	  echo "Its used for preserving timestamps on Git commits."; \
	  echo "Its useful for development, not simple running of "; \
	  echo "the project. So we won't stop the configuration "; \
	  echo "because it wasn't built."; \
	  echo "*****************"; \
	fi


$(ibidir)/mpfr: $(ibidir)/gmp \
                | $(tdir)/mpfr-$(mpfr-version).tar.xz
	$(call gbuild, mpfr-$(mpfr-version), static, , , make check)  \
	&& echo "GNU Multiple Precision Floating-Point Reliably $(mpfr-version)" > $@

$(ibidir)/perl: | $(ibidir)/coreutils \
                  $(tdir)/perl-$(perl-version).tar.gz
	major_version=$$(echo $(perl-version) \
	                     | sed -e's/\./ /g' \
	                     | awk '{printf("%d", $$1)}'); \
	base_version=$$(echo $(perl-version) \
	                     | sed -e's/\./ /g' \
	                     | awk '{printf("%d.%d", $$1, $$2)}'); \
	cd $(ddir) \
	&& rm -rf perl-$(perl-version) \
	&& if ! tar xf $(word 1,$(filter $(tdir)/%,$|)); then \
	      echo; echo "Tar error"; exit 1; \
	   fi \
	&& cd perl-$(perl-version) \
	&& sed -e's|\#\! /bin/sh|\#\! $(ibdir)/bash|' \
	       -e's|\#\!/bin/sh|\#\! $(ibdir)/bash|' \
	       Configure > Configure-tmp \
	&& mv -f Configure-tmp Configure \
	&& chmod +x Configure \
	&& ./Configure -des \
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
	               -Dlddlflags="-shared $$LDFLAGS" \
	               -Dldflags="$$LDFLAGS" \
	&& make SHELL=$(ibdir)/bash -j$(numthreads) \
	&& make SHELL=$(ibdir)/bash install \
	&& cd .. \
	&& rm -rf perl-$(perl-version) \
	&& cd $$topdir \
	&& echo "Perl $(perl-version)" > $@


$(ibidir)/pkg-config: | $(ibidir)/coreutils \
                        $(tdir)/pkg-config-$(pkgconfig-version).tar.gz
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
	if [ x$(on_mac_os) = xyes ]; then export compiler="CC=clang"; \
	else                              export compiler=""; \
	fi; \
	$(call gbuild, pkg-config-$(pkgconfig-version), static, \
	               $$compiler --with-internal-glib \
	               --with-pc-path=$(ildir)/pkgconfig, V=1) \
	&& echo "pkg-config $(pkgconfig-version)" > $@

$(ibidir)/sed: | $(ibidir)/coreutils \
                 $(tdir)/sed-$(sed-version).tar.xz
	$(call gbuild, sed-$(sed-version), static) \
	&& echo "GNU Sed $(sed-version)" > $@

$(ibidir)/texinfo: | $(ibidir)/perl \
                     $(tdir)/texinfo-$(texinfo-version).tar.xz
	$(call gbuild, texinfo-$(texinfo-version), static) \
	&& if [ "x$(needpatchelf)" != x ]; then \
	     $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/info; \
	     $(ibdir)/patchelf --set-rpath $(ildir) $(ibdir)/install-info; \
	   fi \
	&& echo "GNU Texinfo $(sed-version)" > $@

$(ibidir)/which: | $(ibidir)/coreutils \
                   $(tdir)/which-$(which-version).tar.gz
	$(call gbuild, which-$(which-version), static) \
	&& echo "GNU Which $(which-version)" > $@










# GCC and its prerequisites
# -------------------------

$(ibidir)/isl: $(ibidir)/gmp \
               | $(tdir)/isl-$(isl-version).tar.bz2
	$(call gbuild, isl-$(isl-version), static, , V=1)  \
	&& echo "GNU Integer Set Library $(isl-version)" > $@

$(ibidir)/mpc: $(ibidir)/mpfr \
               | $(tdir)/mpc-$(mpc-version).tar.gz
	$(call gbuild, mpc-$(mpc-version), static, , , make check)  \
	&& echo "GNU Multiple Precision Complex library" > $@

# Binutils' assembler (`as') and linker (`ld') will conflict with other
# compilers. So until then, on Mac systems we'll use the host opertating
# system's Binutils equivalents by just making links.

ifeq ($(host_cc),1)
gcc-prerequisites =
else
gcc-prerequisites = $(ibidir)/isl \
                    $(ibidir)/mpc
endif

ifeq ($(on_mac_os),yes)
binutils-tarball =
else
binutils-tarball = $(tdir)/binutils-$(binutils-version).tar.lz
endif

# The installation of Binutils can cause problems during the build of other
# programs (http://savannah.nongnu.org/bugs/?56294). Therefore, we'll set
# all other basic programs as Binutils prerequisite and GCC (the final
# basic target) ultimately just depends on Binutils.
$(ibidir)/binutils: | $(ibidir)/sed \
                      $(ibidir)/wget \
                      $(ibidir)/grep \
                      $(ibidir)/file \
                      $(ibidir)/gawk \
                      $(ibidir)/which \
                      $(ibidir)/glibtool \
                      $(binutils-tarball) \
                      $(ibidir)/metastore \
                      $(ibidir)/findutils \
                      $(ibidir)/diffutils \
                      $(ibidir)/coreutils \
                      $(gcc-prerequisites)
	if [ x$(on_mac_os) = xyes ]; then \
	  $(call makelink,as); \
	  $(call makelink,ar); \
	  $(call makelink,ld); \
	  $(call makelink,nm); \
	  $(call makelink,ps); \
	  $(call makelink,ranlib); \
          echo "" > $@; \
	else \
	  $(call gbuild, binutils-$(binutils-version), static) \
	  && echo "GNU Binutils $(binutils-version)" > $@; \
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
ifeq ($(host_cc),1)
gcc-tarball =
else
gcc-tarball = $(tdir)/gcc-$(gcc-version).tar.xz
endif
$(ibidir)/gcc: | $(ibidir)/binutils \
                 $(gcc-tarball)

        # GCC builds is own libraries in '$(idir)/lib64'. But all other
        # libraries are in '$(idir)/lib'. Since this project is only for a
        # single architecture, we can trick GCC into building its libraries
        # in '$(idir)/lib' by defining the '$(idir)/lib64' as a symbolic
        # link to '$(idir)/lib'.
	if [ $(host_cc) = 1 ]; then \
	  $(call makelink,gcc); \
	  $(call makelink,g++,mandatory); \
	  $(call makelink,gfortran,mandatory); \
	  $(call makelink,strip,mandatory); \
	  ln -sf $$(which gcc) $(ibdir)/cc; \
	  ccinfo=$$(gcc --version | awk 'NR==1'); \
	  echo "C compiler (""$$ccinfo"")" > $@; \
	else \
	  rm -f $(ibdir)/gcc* $(ibdir)/g++ $(ibdir)/gfortran $(ibdir)/gcov*;\
	  rm -rf $(ildir)/gcc $(ildir)/libcc* $(ildir)/libgcc*; \
	  rm -rf $(ildir)/libgfortran* $(ildir)/libstdc* rm $(idir)/x86_64*;\
	                                 \
	  ln -fs $(ildir) $(idir)/lib64; \
	                                 \
	  cd $(ddir); \
	  rm -rf gcc-$(gcc-version); \
	  tar xf $(word 1,$(filter $(tdir)/%,$|)) \
	  && cd gcc-$(gcc-version) \
	  && mkdir build \
	  && cd build \
	  && ../configure SHELL=$(ibdir)/bash \
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
	                  --disable-multiarch \
	  && make SHELL=$(ibdir)/bash -j$(numthreads) \
	  && make SHELL=$(ibdir)/bash install \
	  && cd ../.. \
	  && rm -rf gcc-$(gcc-version) \
	  && if [ "x$(on_mac_os)" != xyes ]; then \
	       patchelf --add-needed $(ildir)/libiconv.so $(ildir)/libstdc++.so; \
	       for f in $$(find $(idir)/libexec/gcc) $(ildir)/libstdc++*; do \
	         if ldd $$f &> /dev/null; then \
	           patchelf --set-rpath $(ildir) $$f; \
	         fi; \
	       done; \
	     fi \
	  && ln -sf $(ibdir)/gcc $(ibdir)/cc \
	  && echo "GNU Compiler Collection (GCC) $(gcc-version)" > $@; \
	fi
