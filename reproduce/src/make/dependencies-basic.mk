# Build the VERY BASIC reproduction pipeline dependencies before everything
# else using minimum Make and Shell.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
#
# This Makefile builds very low-level and basic tools like GNU Tar, and
# various compression programs, GNU Bash, and GNU Make. Therefore this is
# the only Makefile in the reproduction pipeline where you MUST NOT assume
# that modern GNU Bash or GNU Make are used. After this Makefile, other
# Makefiles can safely assume the fixed version of all these software.
#
# This Makefile is a very simplified version of `dependencies.mk' in the
# same directory. See there for more comments.
#
# ------------------------------------------------------------------------
#
# Original author:
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Contributing author(s):
#     Your name <your@email.address>
# Copyright (C) 2018, Your Name.
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
include reproduce/config/pipeline/LOCAL.mk
include reproduce/src/make/dependencies-build-rules.mk
include reproduce/config/pipeline/dependency-versions.mk

ddir  = $(BDIR)/dependencies
tdir  = $(BDIR)/dependencies/tarballs
idir  = $(BDIR)/dependencies/installed
ibdir = $(BDIR)/dependencies/installed/bin
ildir = $(BDIR)/dependencies/installed/lib
ilidir = $(BDIR)/dependencies/installed/lib/built

# We'll need the system's PATH for making links to low-level programs we
# won't be building ourselves.
syspath         := $(PATH)

# As we build more programs, we want to use our own pipeline's built
# programs and libraries, not the host's.
export PATH              := $(ibdir):$(PATH)
export PKG_CONFIG_PATH   := $(ildir)/pkgconfig
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig
export LDFLAGS           := $(rpath_command) -L$(ildir) $(LDFLAGS)
export CPPFLAGS          := -I$(idir)/include $(CPPFLAGS)
export LD_LIBRARY_PATH   := $(ildir):$(LD_LIBRARY_PATH)

top-level-programs = low-level-links ls sed gawk grep diff find \
                     bash wget which
all: $(foreach p, $(top-level-programs), $(ibdir)/$(p))





# Tarballs
# --------
#
# Prepare tarballs. Difference with that in `dependencies.mk': `.ONESHELL'
# is not recognized by some versions of Make (even older GNU Makes). So
# we'll have to make sure the recipe doesn't break into multiple shell
# calls (so we can preserve the variables).
#
# Software hosted at akhlaghi.org/src: As of our latest check (November
# 2018) their major release tarballs either crash or don't build on some
# systems (for example Make or Gzip), or they don't exist (for example
# Bzip2).
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
tarballs = $(foreach t, bash-$(bash-version).tar.gz                         \
                        binutils-$(binutils-version).tar.lz                 \
                        bzip2-$(bzip2-version).tar.gz                       \
                        cert.pem                                            \
                        coreutils-$(coreutils-version).tar.xz               \
                        diffutils-$(diffutils-version).tar.xz               \
                        findutils-$(findutils-version).tar.lz               \
                        gawk-$(gawk-version).tar.lz                         \
                        gcc-$(gcc-version).tar.xz                           \
                        gmp-$(gmp-version).tar.lz                           \
                        grep-$(grep-version).tar.xz                         \
                        gzip-$(gzip-version).tar.gz                         \
                        isl-$(isl-version).tar.bz2                          \
                        lzip-$(lzip-version).tar.gz                         \
                        make-$(make-version).tar.lz                         \
                        mpfr-$(mpfr-version).tar.xz                         \
                        mpc-$(mpc-version).tar.gz                           \
                        openssl-$(openssl-version).tar.gz                   \
                        pkg-config-$(pkgconfig-version).tar.gz              \
                        sed-$(sed-version).tar.xz                           \
                        tar-$(tar-version).tar.gz                           \
                        wget-$(wget-version).tar.lz                         \
                        which-$(which-version).tar.gz                       \
                        xz-$(xz-version).tar.gz                             \
                        zlib-$(zlib-version).tar.gz                         \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%:
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then                              \
	  cp $(DEPENDENCIES-DIR)/$* $@;                                     \
	else                                                                \
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g'                              \
	                     -e's/\./ /g'                                   \
	               | awk '{print $$1}' );                               \
	                                                                    \
	  mergenames=1;                                                     \
          if   [ $$n = bash      ]; then w=http://ftpmirror.gnu.org/gnu/bash; \
          elif [ $$n = binutils  ]; then w=http://ftpmirror.gnu.org/gnu/binutils; \
          elif [ $$n = bzip      ]; then w=http://akhlaghi.org/src;         \
          elif [ $$n = cert      ]; then w=http://akhlaghi.org/src;         \
          elif [ $$n = coreutils ]; then w=http://ftpmirror.gnu.org/gnu/coreutils;\
          elif [ $$n = diffutils ]; then w=http://ftpmirror.gnu.org/gnu/diffutils;\
          elif [ $$n = findutils ]; then w=http://akhlaghi.org/src;         \
          elif [ $$n = gawk      ]; then w=http://ftpmirror.gnu.org/gnu/gawk; \
          elif [ $$n = gcc       ]; then w=http://ftpmirror.gnu.org/gcc/gcc-$(gcc-version); \
          elif [ $$n = gmp       ]; then w=https://gmplib.org/download/gmp; \
          elif [ $$n = grep      ]; then w=http://ftpmirror.gnu.org/gnu/grep; \
          elif [ $$n = gzip      ]; then w=http://akhlaghi.org/src;         \
          elif [ $$n = isl       ]; then w=ftp://gcc.gnu.org/pub/gcc/infrastructure; \
          elif [ $$n = lzip      ]; then w=http://download.savannah.gnu.org/releases/lzip; \
          elif [ $$n = make      ]; then w=http://akhlaghi.org/src;         \
          elif [ $$n = mpfr      ]; then w=http://www.mpfr.org/mpfr-current;\
          elif [ $$n = mpc       ]; then w=http://ftpmirror.gnu.org/gnu/mpc;\
          elif [ $$n = openssl   ]; then w=http://www.openssl.org/source;   \
          elif [ $$n = pkg       ]; then w=http://pkg-config.freedesktop.org/releases; \
          elif [ $$n = sed       ]; then w=http://ftpmirror.gnu.org/gnu/sed;\
          elif [ $$n = tar       ]; then w=http://ftpmirror.gnu.org/gnu/tar;\
          elif [ $$n = wget      ]; then w=http://ftpmirror.gnu.org/gnu/wget;\
          elif [ $$n = which     ]; then w=http://ftpmirror.gnu.org/gnu/which;\
          elif [ $$n = xz        ]; then w=http://tukaani.org/xz;           \
          elif [ $$n = zlib      ]; then w=http://www.zlib.net;             \
          else                                                              \
            echo; echo; echo;                                               \
            echo "'$$n' not a basic dependency name (for downloading)."     \
            echo; echo; echo;                                               \
            exit 1;                                                         \
          fi;                                                               \
	                                                                    \
	  if [ $$mergenames = 1 ]; then  tarballurl=$$w/"$*";               \
	  else                           tarballurl=$$w;                    \
	  fi;                                                               \
                                                                            \
	  echo "Downloading $$tarballurl";                                  \
	  if [ -f $(ibdir)/wget ]; then                                     \
	    downloader="wget --no-use-server-timestamps -O";                \
	  else                                                              \
	    downloader="$(DOWNLOADER)";                                     \
	  fi;                                                               \
                                                                            \
	  if ! $$downloader $@ $$tarballurl; then                           \
	     rm -f $@;                                                      \
	     echo; echo "DOWNLOAD FAILED: $$tarballurl"; echo; exit 1;      \
	  fi;                                                               \
	fi





# Low-level (not built) programs
# ------------------------------
#
# For the time being, we aren't building a local C compiler, but we'll use
# any C compiler that the system already has and just make a symbolic link
# to it.
makelink = export PATH=$(syspath); a=$$(which $(1) 2> /dev/null); \
	   if [ -f $(ibdir)/$(1) ]; then rm $(ibdir)/$(1); fi;    \
	   if [ x$$a != x ]; then ln -s $$a $(ibdir)/$(1); fi
$(ibdir) $(ildir):; mkdir $@
$(ibdir)/low-level-links: | $(ibdir) $(ildir)
        # The Assembler
	$(call makelink,as)

        # The compiler
	$(call makelink,clang)
	$(call makelink,gcc)
	$(call makelink,g++)
	$(call makelink,cc)

        # The linker
	$(call makelink,ar)
	$(call makelink,ld)
	$(call makelink,nm)
	$(call makelink,ps)
	$(call makelink,ranlib)

        # Mac OS specific
	$(call makelink,sw_vers)
	$(call makelink,install_name_tool)

        # On Mac OS, libtool is different compared to GNU Libtool. The
        # libtool we'll build in the high-level dependencies has the
        # executable name `glibtool'.
	$(call makelink,libtool)

        # GNU Gettext (translate messages)
	$(call makelink,msgfmt)

        # GNU M4 (for managing building macros)
	$(call makelink,m4)

        # Needed by TeXLive specifically.
	$(call makelink,perl)

        # Necessary libraries:
        #   Libdl (for dynamic loading libraries at runtime)
        #   POSIX Threads library for multi-threaded programs.
	for l in dl pthread; do                    \
          rm -f $(ildir)/lib$$l*;                  \
	  if [ -f /usr/lib/lib$$l.a ]; then        \
	    ln -s /usr/lib/lib$$l.* $(ildir)/;     \
	  fi;                                      \
	done

	echo "Low-level symbolic links are setup" > $@





# Compression programs
# --------------------
#
# The first set of programs to be built are those that we need to unpack
# the source code tarballs of each program. First, we'll build the
# necessary programs, then we'll build GNU Tar.
$(ibdir)/gzip: $(tdir)/gzip-$(gzip-version).tar.gz
	$(call gbuild, $<, gzip-$(gzip-version), static)

# GNU Lzip: For a static build, the `-static' flag should be given to
# LDFLAGS on the command-line (not from the environment).
$(ibdir)/lzip: $(tdir)/lzip-$(lzip-version).tar.gz
ifeq ($(static_build),yes)
	$(call gbuild, $<, lzip-$(lzip-version), , LDFLAGS="-static")
else
	$(call gbuild, $<, lzip-$(lzip-version))
endif

$(ibdir)/xz: $(tdir)/xz-$(xz-version).tar.gz
	$(call gbuild, $<, xz-$(xz-version), static)

$(ibdir)/bzip2: $(tdir)/bzip2-$(bzip2-version).tar.gz
	 tdir=bzip2-$(bzip2-version);                                  \
	 if [ $(static_build) = yes ]; then                            \
	   makecommand="make LDFLAGS=-static";                         \
	 else                                                          \
	   makecommand="make";                                         \
	 fi;                                                           \
	 cd $(ddir) && rm -rf $$tdir && tar xf $< && cd $$tdir &&      \
	 $$makecommand && make install PREFIX=$(idir) &&               \
	 cd .. && rm -rf $$tdir

# GNU Tar: When built statically, tar gives a segmentation fault on
# unpacking Bash. So we'll build it dynamically.
$(ibdir)/tar: $(tdir)/tar-$(tar-version).tar.gz \
	      $(ibdir)/bzip2                    \
	      $(ibdir)/lzip                     \
	      $(ibdir)/gzip                     \
	      $(ibdir)/xz
	$(call gbuild, $<, tar-$(tar-version))





# GNU Make
# --------
#
# GNU Make is the second layer that we'll need to build the basic
# dependencies.
#
# Unfortunately it needs dynamic linking in two instances: when loading
# objects (dynamically linked libraries), or when using the `getpwnam'
# function (for tilde expansion). The first can be disabled with
# `--disable-load', but unfortunately I don't know any way to fix the
# second. So, we'll have to build it dynamically for now.
$(ibdir)/make: $(tdir)/make-$(make-version).tar.lz \
               $(ibdir)/tar
	$(call gbuild, $<, make-$(make-version))





# Downloader
# ----------
#
# Some programs (like Wget and CMake) that use zlib need it to be dynamic
# so they use our custom build. So we won't force a static-only build.
#
# Note for a static-only build: Zlib's `./configure' doesn't use Autoconf's
# configure script, it just accepts a direct `--static' option.
$(idir)/etc:; mkdir $@
$(ilidir): | $(ildir); mkdir $@
$(ilidir)/zlib: $(tdir)/zlib-$(zlib-version).tar.gz \
                $(ibdir)/make | $(ilidir)
	$(call gbuild, $<, zlib-$(zlib-version)) && echo "Zlib is built" > $@

# OpenSSL: Some programs/libraries later need dynamic linking. So we'll
# build libssl (and libcrypto) dynamically also.
#
# Until we find a nice and generic way to create an updated CA file in the
# pipeline, the certificates will be available in a file for this pipeline
# along with the other tarballs.
#
# In case you do want a static OpenSSL and libcrypto, then uncomment the
# following conditional and put $(openssl-static) in the configure options.
#
#ifeq ($(static_build),yes)
#openssl-static = no-dso no-dynamic-engine no-shared
#endif
$(ilidir)/openssl: $(tdir)/openssl-$(openssl-version).tar.gz         \
                   $(tdir)/cert.pem                                  \
                   $(ilidir)/zlib | $(idir)/etc
        # According to OpenSSL's Wiki (link bellow), it can't automatically
        # detect Mac OS's structure. It will need some help. So we'll use
        # the `on_mac_os' Make variable that we defined in the configure
        # script and help it with some extra configuration options and an
        # environment variable.
        #
        # https://wiki.openssl.org/index.php/Compilation_and_Installation
	if [ x$(on_mac_os) = xyes ]; then                            \
	  export KERNEL_BITS=64;                                     \
	  copt="shared no-ssl2 no-ssl3 enable-ec_nistp_64_gcc_128";  \
	fi;                                                          \
	$(call gbuild, $<, openssl-$(openssl-version), ,             \
                       zlib                                          \
	               $$copt                                        \
                       $(rpath_command)                              \
                       --openssldir=$(idir)/etc/ssl                  \
	               --with-zlib-lib=$(ildir)                      \
                       --with-zlib-include=$(idir)/include, , ,      \
	               ./config ) &&                                 \
	cp $(tdir)/cert.pem $(idir)/etc/ssl/cert.pem &&              \
	echo "OpenSSL is built and ready" > $@

# GNU Wget
#
# Note that on some systems (for example GNU/Linux) Wget needs to explicity
# link with `libdl', but on others (for example Mac OS) it doesn't. We
# check this at configure time and define the `needs_ldl' variable.
#
# Also note that since Wget needs to load outside libraries dynamically, it
# gives a segmentation fault when built statically.
$(ibdir)/wget: $(tdir)/wget-$(wget-version).tar.lz \
	       $(ibdir)/pkg-config                 \
               $(ilidir)/openssl
	libs="-pthread";                                                 \
	if [ x$(needs_ldl) = xyes ]; then libs="$$libs -ldl"; fi;        \
	$(call gbuild, $<, wget-$(wget-version), ,                       \
                       LIBS="$$LIBS $$libs" --with-ssl=openssl           \
	               --with-openssl=yes --with-libssl-prefix=$(idir))





# Basic command-line programs necessary in build process of the
# higher-level dependencies: Note that during the building of those
# programs, there is no access to the system's PATH.
$(ibdir)/diff: $(tdir)/diffutils-$(diffutils-version).tar.xz \
               $(ibdir)/make
	$(call gbuild, $<, diffutils-$(diffutils-version), static)

$(ibdir)/find: $(tdir)/findutils-$(findutils-version).tar.lz \
               $(ibdir)/make
	$(call gbuild, $<, findutils-$(findutils-version), static)

$(ibdir)/gawk: $(tdir)/gawk-$(gawk-version).tar.lz \
               $(ibdir)/make
	$(call gbuild, $<, gawk-$(gawk-version), static)

$(ibdir)/grep: $(tdir)/grep-$(grep-version).tar.xz \
               $(ibdir)/make
	$(call gbuild, $<, grep-$(grep-version), static)

$(ibdir)/ls: $(tdir)/coreutils-$(coreutils-version).tar.xz \
             $(ilidir)/openssl
        # Coreutils will use the hashing features of OpenSSL's `libcrypto'.
	$(call gbuild, $<, coreutils-$(coreutils-version), static, \
	               LDFLAGS="$(LDFLAGS)" CPPFLAGS="$(CPPFLAGS)" \
	               --enable-rpath --disable-silent-rules --with-openssl)

$(ibdir)/pkg-config: $(tdir)/pkg-config-$(pkgconfig-version).tar.gz \
                     $(ibdir)/make
	$(call gbuild, $<, pkg-config-$(pkgconfig-version), static, \
                       --with-internal-glib)

$(ibdir)/sed: $(tdir)/sed-$(sed-version).tar.xz \
              $(ibdir)/make
	$(call gbuild, $<, sed-$(sed-version), static)

$(ibdir)/which: $(tdir)/which-$(which-version).tar.gz \
                $(ibdir)/make
	$(call gbuild, $<, which-$(which-version), static)





# GNU Bash
$(ibdir)/bash: $(tdir)/bash-$(bash-version).tar.gz \
               $(ibdir)/make

        # Delete any possibly existing output
	if [ -f $@ ]; then rm $@; fi;

        # Build Bash.
ifeq ($(static_build),yes)
	$(call gbuild, $<, bash-$(bash-version), , --enable-static-link)
else
	$(call gbuild, $<, bash-$(bash-version))
endif

        # To be generic, some systems use the `sh' command to call the
        # shell. By convention, `sh' is just a symbolic link to the
        # preferred shell executable. So we'll define `$(ibdir)/sh' as a
        # symbolic link to the Bash that we just built and installed.
        #
        # Just to be sure that the installation step above went well,
        # before making the link, we'll see if the file actually exists
        # there.
	if [ -f $@ ]; then ln -s $@ $(ibdir)/sh; fi





# (CURRENTLY IGNORED) GCC prerequisites
# -------------------------------------
$(ilidir)/gmp: $(tdir)/gmp-$(gmp-version).tar.lz \
               $(ibdir)/make | $(ilidir)
	$(call gbuild, $<, gmp-$(gmp-version), static, , , make check)  \
	&& echo "GNU multiple precision arithmetic library is built" > $@

$(ilidir)/mpfr: $(tdir)/mpfr-$(mpfr-version).tar.xz \
                $(ilidir)/gmp
	$(call gbuild, $<, mpfr-$(mpfr-version), static, , , make check)  \
	&& echo "GNU MPFR library is built" > $@

$(ilidir)/mpc: $(tdir)/mpc-$(mpc-version).tar.gz \
               $(ilidir)/mpfr
	$(call gbuild, $<, mpc-$(mpc-version), static, , , make check)  \
	&& echo "GNU MPC library is built" > $@

$(ilidir)/isl: $(tdir)/isl-$(isl-version).tar.bz2 \
               $(ilidir)/gmp
	$(call gbuild, $<, isl-$(isl-version), static)  \
	&& echo "GCC's ISL library is built" > $@

# On non-GNU systems, the default linker is different and we don't want our
# new linker to be mixed with that during the building of libraries and
# programs before GCC.
$(ibdir)/ld: $(tdir)/binutils-$(binutils-version).tar.lz \
             $(ibdir)/ls                                 \
             $(ibdir)/sed                                \
             $(ilidir)/isl                               \
             $(ilidir)/mpc                               \
             $(ibdir)/gawk                               \
             $(ibdir)/grep                               \
             $(ibdir)/diff                               \
             $(ibdir)/find                               \
             $(ibdir)/bash                               \
             $(ibdir)/which
	$(call gbuild, $<, binutils-$(binutils-version), static)





# (CURRENTLY IGNORED) Build GCC
# -----------------------------
#
# The building is currently ignored because GNU Binutils currently doesn't
# install critical components of building a compiler on Mac systems. So we
# can install and use the GNU C compiler, but we're still going to have the
# crazy issues with linking on a Mac OS. Since almost no natural science
# paper's processing depends so strongly on the compiler used, for now,
# we'll just use the host operating system's C library, compiler, and
# linker.
#
# We want to build GCC after building all the basic tools that are often
# used in a configure script to enable GCC's configure script to work as
# smoothly/robustly as possible.
$(ibdir)/gcc: $(tdir)/gcc-$(gcc-version).tar.xz \
              $(ibdir)/ld

        # Un-pack all the necessary tools in the top building directory
	cd $(ddir);                                                     \
	rm -rf gcc-build gcc-$(gcc-version);                            \
	tar xf $< &&                                                    \
	mkdir $(ddir)/gcc-build &&                                      \
	cd $(ddir)/gcc-build &&                                         \
	../gcc-$(gcc-version)/configure SHELL=$(ibdir)/bash             \
	                                --prefix=$(idir)                \
	                                --with-mpc=$(idir)              \
	                                --with-mpfr=$(idir)             \
	                                --with-gmp=$(idir)              \
	                                --with-isl=$(idir)              \
	                                --with-build-time-tools=$(idir) \
	                                --enable-shared                 \
	                                --disable-multilib              \
	                                --disable-multiarch             \
	                                --enable-threads=posix          \
	                                --enable-libmpx                 \
	                                --with-local-prefix=$(idir)     \
	                                --enable-linker-build-id        \
	                                --with-gnu-as                   \
	                                --with-gnu-ld                   \
	                                --enable-lto                    \
	                                --with-linker-hash-style=gnu    \
	                                --enable-languages=c,c++        \
	                                --disable-libada                \
	                                --disable-nls                   \
	                                --enable-default-pie            \
	                                --enable-default-ssp            \
	                                --enable-cet=auto               \
	                                --enable-decimal-float &&       \
	make SHELL=$(ibdir)/bash -j$$(nproc) &&                         \
	make SHELL=$(ibdir)/bash install &&                             \
	cd .. &&                                                        \
	rm -rf gcc-build gcc-$(gcc-version)
