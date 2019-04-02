# Build the reproduction pipeline dependencies (programs and libraries).
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
#
# ------------------------------------------------------------------------
#
# Original author:
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Contributing author(s):
#     Your name <your@email.address>
# Copyright (C) 2018-2019, Your Name.
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
include reproduce/config/pipeline/dependency-texlive.mk
include reproduce/config/pipeline/dependency-versions.mk

ddir   = $(BDIR)/dependencies
tdir   = $(BDIR)/dependencies/tarballs
idir   = $(BDIR)/dependencies/installed
ibdir  = $(BDIR)/dependencies/installed/bin
ildir  = $(BDIR)/dependencies/installed/lib
ilidir = $(BDIR)/dependencies/installed/lib/built

# Define the top-level programs to build (installed in `.local/bin').
#
# About ATLAS: currently the core pipeline does not depend on ATLAS but many
# high level software depend on it. The current rule for ATLAS is tested
# successfully on Mac (only static) and GNU/Linux (shared and static). But,
# since it takes a few hours to build, it is not currently a target.
top-level-programs  = astnoisechisel flock metastore unzip zip
top-level-libraries = freetype openblas fftw  # atlas
all: $(ddir)/texlive-versions.tex                       \
     $(foreach p, $(top-level-programs), $(ibdir)/$(p)) \
     $(foreach p, $(top-level-libraries), $(ilidir)/$(p))

# Other basic environment settings: We are only including the host
# operating system's PATH environment variable (after our own!) for the
# compiler and linker. For the library binaries and headers, we are only
# using our internally built libraries.
#
# To investigate:
#
#    1) Set SHELL to `$(ibdir)/env - NAME=VALUE $(ibdir)/bash' and set all
#       the parameters defined bellow as `NAME=VALUE' statements before
#       calling Bash. This will enable us to completely ignore the user's
#       native environment.
#
#    2) Add `--noprofile --norc' to `.SHELLFLAGS' so doesn't load the
#       user's environment.
.ONESHELL:
.SHELLFLAGS              := --noprofile --norc -ec
export CCACHE_DISABLE    := 1
export PATH              := $(ibdir)
export SHELL             := $(ibdir)/bash
export CPPFLAGS          := -I$(idir)/include
export PKG_CONFIG_PATH   := $(ildir)/pkgconfig
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig
export LD_RUN_PATH       := $(ildir):$(il64dir)
export LD_LIBRARY_PATH   := $(ildir):$(il64dir)
export LDFLAGS           := $(rpath_command) -L$(ildir)





# Tarballs
# --------
#
# All the necessary tarballs are defined and prepared with this rule.
#
# Note that we want the tarballs to follow the convention of NAME-VERSION
# before the `tar.XX' prefix. For those programs that don't follow this
# convention, but include the name/version in their tarball names with
# another format, we'll do the modification before the download so the
# downloaded file has our desired format.
tarballs = $(foreach t, cfitsio-$(cfitsio-version).tar.gz                  \
                        atlas-$(atlas-version).tar.bz2                     \
                        cmake-$(cmake-version).tar.gz                      \
                        curl-$(curl-version).tar.gz                        \
                        flock-$(flock-version).tar.xz                      \
                        freetype-$(freetype-version).tar.gz                \
                        fftw-$(fftw-version).tar.gz                        \
                        ghostscript-$(ghostscript-version).tar.gz          \
                        git-$(git-version).tar.xz                          \
                        gnuastro-$(gnuastro-version).tar.lz                \
                        gsl-$(gsl-version).tar.gz                          \
                        install-tl-unx.tar.gz                              \
                        jpegsrc.$(libjpeg-version).tar.gz                  \
                        lapack-$(lapack-version).tar.gz                    \
                        libbsd-$(libbsd-version).tar.xz                    \
                        libpng-$(libpng-version).tar.xz                    \
                        libtool-$(libtool-version).tar.xz                  \
                        libgit2-$(libgit2-version).tar.gz                  \
                        metastore-$(metastore-version).tar.gz              \
                        unzip-$(unzip-version).tar.gz                      \
                        openblas-$(openblas-version).tar.gz                \
                        tiff-$(libtiff-version).tar.gz                     \
                        wcslib-$(wcslib-version).tar.bz2                   \
                        zip-$(zip-version).tar.gz                          \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%:
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then
	  cp $(DEPENDENCIES-DIR)/$* $@
	else
          # Remove all numbers, `-' and `.' from the tarball name so we can
          # search more easily only with the program name.
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g' -e's/\./ /g'           \
	               | awk '{print $$1}' )

          # Set the top download link of the requested tarball.
	  mergenames=1
	  if [ $$n = cfitsio     ]; then
	    mergenames=0
	    v=$$(echo $(cfitsio-version) | sed -e's/\.//'             \
	              | awk '{l=length($$1);                          \
	                      printf (l==4 ? "%d\n"                   \
	                              : (l==3 ? "%d0\n"               \
	                                 : (l==2 ? "%d00\n"           \
                                            : "%d000\n") ), $$1)}')
	    w=https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio$$v.tar.gz
	  elif [ $$n = atlas       ]; then
	    mergenames=0
	    w=https://sourceforge.net/projects/math-atlas/files/Stable/$(atlas-version)/atlas$(atlas-version).tar.bz2/download
	  elif [ $$n = cmake       ]; then w=https://cmake.org/files/v3.12
	  elif [ $$n = curl        ]; then w=https://curl.haxx.se/download
	  elif [ $$n = flock       ]; then w=https://github.com/discoteq/flock/releases/download/v$(flock-version)
	  elif [ $$n = fftw        ]; then w=ftp://ftp.fftw.org/pub/fftw
	  elif [ $$n = freetype    ]; then w=https://download.savannah.gnu.org/releases/freetype
	  elif [ $$n = ghostscript ]; then w=https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs926
	  elif [ $$n = git         ]; then w=http://mirrors.edge.kernel.org/pub/software/scm/git
	  elif [ $$n = gnuastro    ]; then w=http://ftpmirror.gnu.org/gnu/gnuastro
	  elif [ $$n = gsl         ]; then w=http://ftpmirror.gnu.org/gnu/gsl
	  elif [ $$n = install     ]; then w=http://mirror.ctan.org/systems/texlive/tlnet
	  elif [ $$n = jpegsrc     ]; then w=http://ijg.org/files
	  elif [ $$n = lapack      ]; then w=http://www.netlib.org/lapack
	  elif [ $$n = libbsd      ]; then w=http://libbsd.freedesktop.org/releases
	  elif [ $$n = libpng      ]; then w=https://download.sourceforge.net/libpng
	  elif [ $$n = libtool     ]; then w=http://ftpmirror.gnu.org/gnu/libtool
	  elif [ $$n = libgit      ]; then
	    mergenames=0
	    w=https://github.com/libgit2/libgit2/archive/v$(libgit2-version).tar.gz
	  elif [ $$n = metastore   ]; then w=http://akhlaghi.org/src
	  elif [ $$n = openblas    ]; then
	    mergenames=0
	    w=https://github.com/xianyi/OpenBLAS/archive/v$(openblas-version).tar.gz
	  elif [ $$n = tiff        ]; then w=https://download.osgeo.org/libtiff
	  elif [ $$n = unzip       ]; then w=ftp://ftp.info-zip.org/pub/infozip/src
	    mergenames=0; v=$$(echo $(unzip-version) | sed -e's/\.//')
	    w=ftp://ftp.info-zip.org/pub/infozip/src/unzip$$v.tgz
	  elif [ $$n = wcslib      ]; then w=ftp://ftp.atnf.csiro.au/pub/software/wcslib
	  elif [ $$n = zip         ]; then
	    mergenames=0; v=$$(echo $(zip-version) | sed -e's/\.//')
	    w=ftp://ftp.info-zip.org/pub/infozip/src/zip$$v.tgz
	  else
	    echo; echo; echo;
	    echo "'$$n' not recognized as a dependency name to download."
	    echo; echo; echo;
	    exit 1
	  fi

          # Download the requested tarball. Note that some packages may not
          # follow our naming convention (where the package name is merged
          # with its version number). In such cases, `w' will be the full
          # address, not just the top directory address. But since we are
          # storing all the tarballs in one directory, we want it to have
          # the same naming convention, so we'll download it to a temporary
          # name, then rename that.
	  if [ $$mergenames = 1 ]; then  tarballurl=$$w/"$*"
	  else                           tarballurl=$$w
	  fi

          # If the download fails, Wget will write the error message in the
          # target file, so Make will think that its done! To avoid this
          # problem, we'll rename the output.
	  echo "Downloading $$tarballurl"
	  if ! wget --no-use-server-timestamps -O$@ $$tarballurl; then
	     rm -f $@
	     echo; echo "DOWNLOAD FAILED: $$tarballurl"; echo; exit 1
	  fi
	fi





# Libraries
# ---------
#
# We would prefer to build static libraries, but some compilers like LLVM
# don't have static capabilities, so they'll only build dynamic/shared
# libraries. Therefore, we can't use the easy `.a' suffix for static
# libraries as targets and there are different conventions for shared
# library names.
#
# For the actual build, the same compiler that built the library will build
# the programs, so exact knowledge of the suffix is ultimately irrelevant
# for us here. So, we'll make an `$(ildir)/built' directory and make a
# simple plain text file in it with the basic library name (an no prefix)
# and create/write into it when the library is successfully built.
$(ilidir)/cfitsio: $(tdir)/cfitsio-$(cfitsio-version).tar.gz \
                   $(ibdir)/curl

        # CFITSIO hard-codes the absolute address of cURL's `curl-config'
        # program (which gives the necessary header and linking
        # information) into the configure script. So we'll have to modify
        # it manually before doing the standard build.
	topdir=$(pwd); cd $(ddir); tar xf $<
	customtar=cfitsio-$(cfitsio-version)-custom.tar.gz
	sed cfitsio/configure                                 \
	    -e's|/usr/bin/curl-config|$(ibdir)/curl-config|g' \
	    > cfitsio/configure_tmp
	mv cfitsio/configure_tmp cfitsio/configure
	chmod +x cfitsio/configure
	tar cf $$customtar cfitsio
	cd $$topdir

        # Continue the standard build on the customized tarball.
	$(call gbuild, $$customtar, cfitsio, static,     \
	               --enable-sse2 --enable-reentrant) \
	&& rm $$customtar                                \
	&& echo "CFITSIO is built" > $@

$(ilidir)/gsl: $(tdir)/gsl-$(gsl-version).tar.gz
	$(call gbuild, $<, gsl-$(gsl-version), static) \
	&& echo "GNU Scientific Library is built" > $@

$(ilidir)/fftw: $(tdir)/fftw-$(fftw-version).tar.gz
	$(call gbuild, $<, fftw-$(fftw-version), static,  \
	               --enable-shared)                   \
	&& echo "FFTW is built" > $@

# Freetype is necessary to install matplotlib
$(ilidir)/freetype: $(tdir)/freetype-$(freetype-version).tar.gz \
	                $(ilidir)/libpng
	$(call gbuild, $<, freetype-$(freetype-version), static) \
	&& echo "freetype is built" > $@

$(ilidir)/libbsd: $(tdir)/libbsd-$(libbsd-version).tar.xz
	$(call gbuild, $<, libbsd-$(libbsd-version), static,,V=1) \
	&& echo "libbsd is built" > $@

$(ilidir)/libjpeg: $(tdir)/jpegsrc.$(libjpeg-version).tar.gz
	$(call gbuild, $<, jpeg-9b, static) && echo "Libjpeg is built" > $@

$(ilidir)/libpng: $(tdir)/libpng-$(libpng-version).tar.xz
	$(call gbuild, $<, libpng-$(libpng-version), static) \
	&& echo "Libpng is built" > $@

$(ilidir)/libtiff: $(tdir)/tiff-$(libtiff-version).tar.gz \
                   $(ilidir)/libjpeg
	$(call gbuild, $<, tiff-$(libtiff-version), static, \
	               --disable-webp --disable-zstd) \
	&& echo "Libtiff is built" > $@

$(ilidir)/atlas: $(tdir)/atlas-$(atlas-version).tar.bz2 \
	         $(tdir)/lapack-$(lapack-version).tar.gz

        # Get the operating system specific features (how to get
        # CPU frequency and the library suffixes). To make the steps
        # more readable, the different library version suffixes are
        # named with a single character: `s' for no version in the
        # name, `m' for the major version suffix, and `f' for the
        # full version suffix.
        # GCC in Mac OS doesn't work. To work around this issue, on Mac
        # systems we force ATLAS to use `clang' instead of `gcc'.
	if [ x$(on_mac_os) = xyes ]; then
	  s=dylib
	  m=3.dylib
	  f=3.6.1.dylib
	  core=$$(sysctl hw.cpufrequency | awk '{print $$2/1000000}')
	  clangflag="--force-clang=$(ibdir)/clang"
	else
	  s=so
	  m=so.3
	  f=so.3.6.1
	  clangflag=
	  core=$$(cat /proc/cpuinfo | grep "cpu MHz" \
	              | head -n 1                    \
	              | sed "s/.*: \([0-9.]*\).*/\1/")
	fi

        # See if the shared libraries should be build for a single CPU
        # thread or multiple threads.
	N=$$(nproc)
	srcdir=$$(pwd)/reproduce/src/make
	if [ $$N = 1 ]; then
	  sharedmk=$$srcdir/dependencies-atlas-single.mk
	else
	  sharedmk=$$srcdir/dependencies-atlas-multiple.mk
	fi

        # The linking step here doesn't recognize the `-Wl' in the
        # `rpath_command'.
	export LDFLAGS=-L$(ildir)
	cd $(ddir)                                                \
	&& tar xf $<                                              \
	&& cd ATLAS                                               \
	&& rm -rf build                                           \
	&& mkdir build                                            \
	&& cd build                                               \
	&& ../configure -b 64 -D c -DPentiumCPS=$$core            \
	             --with-netlib-lapack-tarfile=$(word 2, $^)   \
	             --cripple-atlas-performance                  \
	             -Fa alg -fPIC --shared $$clangflag           \
	             --prefix=$(idir)                             \
	&& make                                                   \
	&& if [ "x$(on_mac_os)" != xyes ]; then                   \
	     cd lib && make -f $$sharedmk && cd ..                \
	     && for l in lib/*.$$s*; do                           \
	          patchelf --set-rpath $(ildir) $$l; done         \
	     && cp -d lib/*.$$s* $(ildir)                         \
	     && ln -fs $(ildir)/libblas.$$s  $(ildir)/libblas.$$m \
	     && ln -fs $(ildir)/libf77blas.$$s $(ildir)/libf77blas.$$m \
	     && ln -fs $(ildir)/liblapack.$$f  $(ildir)/liblapack.$$s \
	     && ln -fs $(ildir)/liblapack.$$f  $(ildir)/liblapack.$$m; \
	   fi                                                     \
	&& make install

        # We need to check the existance of `libptlapack.a', but we can't
        # do this in the `&&' steps above (it will conflict). So we'll do
        # the check after seeing if `libtatlas.so' is installed, then we'll
        # finalize the build (delete the untarred directory).
	if [ "x$(on_mac_os)" != xyes ]; then                       \
	  [ -e lib/libptlapack.a ] && cp lib/libptlapack.a $(ildir); \
	  cd $(ddir);                                              \
	  rm -rf ATLAS;                                            \
	fi

        # We'll check the full installation with the static library (not
        # currently building shared library on Mac.
	if [ -f $(ildir)/libatlas.a ]; then echo "Atlas is built" > $@; fi

$(ilidir)/openblas: $(tdir)/openblas-$(openblas-version).tar.gz
	if [ x$(on_mac_os) = xyes ]; then                           \
	  export CC=clang                                           \
	fi;                                                         \
	cd $(ddir)                                                  \
	&& tar xf $<                                                \
	&& cd OpenBLAS-$(openblas-version)                          \
	&& make                                                     \
	&& make PREFIX=$(idir) install                              \
	&& cd ..                                                    \
	&& rm -rf OpenBLAS-$(openblas-version)                      \
	&& echo "Libtiff is built" > $@




# Libraries with special attention on Mac OS
# ------------------------------------------
#
# Libgit2 and WCSLIB don't set their installation path, or don't do it
# properly, in their finally installed shared libraries. But since we are
# linking everything (including OpenSSL and its dependencies) dynamically,
# we need to also make a shared libraries and can't use static
# libraries. So for Mac OS systems we have to correct their addresses
# manually.
#
# For example, Libgit2 page recommends doing a static build, especially for
# Mac systems (with `-DBUILD_SHARED_LIBS=OFF'): "It’s highly recommended
# that you build libgit2 as a static library for Xcode projects. This
# simplifies distribution significantly, as the resolution of dynamic
# libraries at runtime can be extremely problematic.". This is a major
# problem we have been having so far with Mac systems:
# https://libgit2.org/docs/guides/build-and-link
$(ilidir)/libgit2: $(tdir)/libgit2-$(libgit2-version).tar.gz \
                   $(ibdir)/cmake                            \
                   $(ibdir)/curl
        # Build and install the library.
	$(call cbuild, $<, libgit2-$(libgit2-version), static,  \
	              -DUSE_SSH=OFF -DBUILD_CLAR=OFF            \
	              -DTHREADSAFE=ON )

        # Correct the shared library absolute address if necessary.
	if [ x$(on_mac_os) = xyes ]; then
	  install_name_tool -id $(ildir)/libgit2.26.dylib \
	                        $(ildir)/libgit2.26.dylib
	fi

        # Write the target file.
	echo "Libgit2 is built" > $@

$(ilidir)/wcslib: $(tdir)/wcslib-$(wcslib-version).tar.bz2 \
                  $(ilidir)/cfitsio
        # Build and install the library.
	$(call gbuild, $<, wcslib-$(wcslib-version), ,               \
	               LIBS="-pthread -lcurl -lm"                    \
                       --with-cfitsiolib=$(ildir)                    \
                       --with-cfitsioinc=$(idir)/include             \
                       --without-pgplot --disable-fortran)

        # Correct the shared library absolute address if necessary.
	if [ x$(on_mac_os) = xyes ]; then
	  install_name_tool -id $(ildir)/libwcs.6.2.dylib \
	                        $(ildir)/libwcs.6.2.dylib;
	fi

        # Write the target file.
	echo "WCSLIB is built" > $@





# Programs
# --------
#
# CMake can be built with its custom `./bootstrap' script.
$(ibdir)/cmake: $(tdir)/cmake-$(cmake-version).tar.gz \
                $(ibdir)/curl
        # After searching in `bootstrap', I couldn't find `LIBS', only
        # `LDFLAGS'. So the extra libraries are being added to `LDFLAGS',
        # not `LIBS'.
        #
        # On Mac systems, the build complains about `clang' specific
        # features, so we can't use our own GCC build here.
	if [ x$(on_mac_os) = xyes ]; then                          \
	  export CC=clang;                                         \
	  export CXX=clang++;                                      \
	fi;                                                        \
	cd $(ddir) && rm -rf cmake-$(cmake-version) &&             \
	tar xf $< && cd cmake-$(cmake-version) &&                  \
	./bootstrap --prefix=$(idir) --system-curl --system-zlib   \
	            --system-bzip2 --system-liblzma --no-qt-gui && \
	make LIBS="$$LIBS -lssl -lcrypto -lz" VERBOSE=1 &&         \
	make install &&                                            \
	cd ..&& rm -rf cmake-$(cmake-version)

# cURL (and its library, which is needed by several programs here) can
# optionally link with many different network-related libraries on the host
# system that we are not yet building in the pipeline. Many of these are
# not relevant to most science projects, so we are explicitly using
# `--without-XXX' or `--disable-XXX' so cURL doesn't link with them. Note
# that if it does link with them, the pipeline will crash when the library
# is updated/changed by the host, and the whole purpose of this pipeline is
# avoid dependency on the host as much as possible.
$(ibdir)/curl: $(tdir)/curl-$(curl-version).tar.gz
	$(call gbuild, $<, curl-$(curl-version), ,       \
	               LIBS="-pthread"                   \
	               --with-zlib=$(ildir)              \
	               --with-ssl=$(idir)                \
	               --without-mesalink                \
	               --with-ca-fallback                \
	               --without-librtmp                 \
	               --without-libidn2                 \
	               --without-wolfssl                 \
	               --without-brotli                  \
	               --without-gnutls                  \
	               --without-cyassl                  \
	               --without-libpsl                  \
	               --without-axtls                   \
	               --disable-ldaps                   \
	               --disable-ldap                    \
	               --without-nss, V=1)

# On Mac OS, libtool does different things, so to avoid confusion, we'll
# prefix GNU's libtool executables with `glibtool'.
$(ibdir)/glibtool: $(tdir)/libtool-$(libtool-version).tar.xz
	$(call gbuild, $<, libtool-$(libtool-version), static, \
                       --program-prefix=g)

$(ibdir)/gs: $(tdir)/ghostscript-$(ghostscript-version).tar.gz
	$(call gbuild, $<, ghostscript-$(ghostscript-version))

$(ibdir)/flock: $(tdir)/flock-$(flock-version).tar.xz
	$(call gbuild, $<, flock-$(flock-version), static)

$(ibdir)/git: $(tdir)/git-$(git-version).tar.xz \
              $(ibdir)/curl
	$(call gbuild, $<, git-$(git-version), static,             \
                       --without-tcltk --with-shell=$(ibdir)/bash, \
	               V=1)

# Metastore is used (through a Git hook) to restore the source modification
# dates of files after a Git checkout. Another Git hook saves all file
# metadata just before a commit (to allow restoration after a
# checkout). Since this pipeline is managed in Makefiles, file modification
# dates are critical to not having to redo the whole analysis after
# checking out between branches.
#
# Note that we aren't using the standard version of Metastore, but a fork
# of it that is maintained in this repository:
#    https://gitlab.com/makhlaghi/metastore-fork
#
# Libbsd is not necessary on macOS systems, because macOS is already a
# BSD-based distribution. But on GNU/Linux systems, it is necessary.
ifeq ($(on_mac_os),yes)
needlibbsd =
else
needlibbsd = $(ilidir)/libbsd
endif
$(ibdir)/metastore: $(tdir)/metastore-$(metastore-version).tar.gz \
                    $(needlibbsd)                                 \
                    $(ibdir)/git

        # The build command below will change the current directory of this
        # build, so we'll fix its value here.
	current_dir=$$(pwd)

        # Metastore doesn't have any `./configure' script. So we'll just
        # call `pwd' as a place-holder for the `./configure' command.
        #
        # File attributes are also not available on some systems, since the
        # main purpose here is modification dates (and not attributes),
        # we'll also set the `NO_XATTR' flag.
	$(call gbuild, $<, metastore-$(metastore-version), static,, \
	               NO_XATTR=1 V=1,,pwd,PREFIX=$(idir))

        # Write the relevant hooks into this system's Git hooks, so Git
        # calls metastore properly on every commit and every checkout.
        #
        # Note that the -O and -G options used here are currently only in a
        # fork of `metastore' currently hosted at:
        # https://github.com/mohammad-akhlaghi/metastore
	user=$$(whoami)
	group=$$(groups | awk '{print $$1}')
	cd $$current_dir
	if [ -f $@ ]; then
	  for f in pre-commit post-checkout; do
	    sed -e's|@USER[@]|'$$user'|g'                         \
	        -e's|@GROUP[@]|'$$group'|g'                       \
	        -e's|@BINDIR[@]|$(ibdir)|g'                       \
	        -e's|@TOP_PROJECT_DIR[@]|'$$current_dir'|g'       \
	        reproduce/src/bash/git-$$f > .git/hooks/$$f
	    chmod +x .git/hooks/$$f
	  done
	else
	  echo; echo; echo;
	  echo "*****************"
	  echo "metastore couldn't be installed!"
	  echo
	  echo "Its used for preserving timestamps on Git commits."
	  echo "Its useful for development, not simple running of the pipeline."
	  echo "So we won't stop the pipeline because it wasn't built."
	  echo "*****************"
	fi

# The order of dependencies is based on how long they take to build (how
# large they are): Libgit2 depends on CMake which takes a VERY long time to
# build. Also, Ghostscript and GSL are relatively large packages. So when
# building in parallel, its better to have these packages start building
# early.
$(ibdir)/astnoisechisel: $(tdir)/gnuastro-$(gnuastro-version).tar.lz \
                         $(ilidir)/libgit2 \
                         $(ibdir)/gs       \
                         $(ilidir)/gsl     \
                         $(ibdir)/glibtool \
                         $(ilidir)/libjpeg \
                         $(ilidir)/libtiff \
                         $(ilidir)/wcslib
ifeq ($(static_build),yes)
	staticopts="--enable-static=yes --enable-shared=no";
endif
	$(call gbuild, $<, gnuastro-$(gnuastro-version), static,     \
	               $$staticopts, -j$(numthreads),                \
	               make check -j$(numthreads))

$(ibdir)/unzip: $(tdir)/unzip-$(unzip-version).tar.gz
	v=$$(echo $(unzip-version) | sed -e's/\.//')
	$(call gbuild, $<, unzip$$v, static,,          \
	               -f unix/Makefile generic_gcc    \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd, \
	               -f unix/Makefile                \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 )

$(ibdir)/zip: $(tdir)/zip-$(zip-version).tar.gz
	v=$$(echo $(zip-version) | sed -e's/\.//')
	$(call gbuild, $<, zip$$v, static,,            \
	               -f unix/Makefile generic_gcc    \
	               CFLAGS="-DBIG_MEM -DMMAP",,pwd, \
	               -f unix/Makefile                \
	               BINDIR=$(ibdir) MANDIR=$(idir)/man/man1 )





# Since we want to avoid complicating the PATH, we are putting a symbolic
# link of all the TeX Live executables in $(ibdir). But symbolic links are
# hard to track for Make (as a target). Also, TeX in general is optional
# for the pipeline (the processing is the main target, not the generation
# of the final PDF). So we'll make a simple ASCII file called
# `texlive-ready-tlmgr' and use its contents to mark if we can use it or
# not.
$(ibdir)/texlive-ready-tlmgr: $(tdir)/install-tl-unx.tar.gz \
                              reproduce/config/pipeline/texlive.conf

        # Unpack, enter the directory, and install based on the given
        # configuration (prerequisite of this rule).
	@topdir=$$(pwd)
	cd $(ddir)
	rm -rf install-tl-*
	tar xf $(tdir)/install-tl-unx.tar.gz
	cd install-tl-*
	sed -e's|@installdir[@]|$(idir)|g' -e's|@topdir[@]|'"$$topdir"'|g' \
	    $$topdir/reproduce/config/pipeline/texlive.conf > texlive.conf

        # TeX Live's installation may fail due to any reason. But TeX Live
        # is optional (only necessary for building the final PDF). So we
        # don't want the configure script to fail if it can't run.
	if ./install-tl --profile=texlive.conf; then

          # Put a symbolic link of the TeX Live executables in `ibdir'. The
          # main problem is that the year and build system (for example
          # `x86_64-linux') are also in the directory names, making it hard
          # to be generic. We are using wildcards here, but only in this
          # Makefile, not in any other.
	  ln -fs $(idir)/texlive/20*/bin/*/* $(ibdir)/

          # Register that the build was successful.
	  echo "TeX Live is ready." > $@
	else
	  echo "NOT!" > $@
	fi

        # Clean up
	cd ..
	rm -rf install-tl-*





# To keep things modular and simple, we'll break up the installation of TeX
# Live itself (only very basic TeX and LaTeX) and the installation of its
# necessary packages into two packages.
$(ddir)/texlive-versions.tex: reproduce/config/pipeline/dependency-texlive.mk \
	                      $(ibdir)/texlive-ready-tlmgr

        # To work with TeX live installation, we'll need the internet.
	@res=$$(cat $(ibdir)/texlive-ready-tlmgr)
	if [ x"$$res" = x"NOT!" ]; then
	  echo "" > $@
	else
          # The current directory is necessary later.
	  topdir=$$(pwd)

          # Install all the extra necessary packages. If LaTeX complains
          # about not finding a command/file/what-ever/XXXXXX, simply run
          # the following command to find which package its in, then add it
          # to the `texlive-packages' variable of the first prerequisite.
          #
          #     ./.local/bin/tlmgr info XXXXXX
          #
          # We are putting a notice, because if there is no internet,
          # `tlmgr' just hangs waiting.
	  echo; echo; echo "Downloading necessary TeX packages..."; echo;
	  tlmgr install $(texlive-packages)

          # Make a symbolic link of all the TeX Live executables in the bin
          # directory so we don't have to modify `PATH'.
	  ln -fs $(idir)/texlive/20*/bin/*/* $(ibdir)/

          # Get all the necessary versions.
	  texlive=$$(pdflatex --version | awk 'NR==1' | sed 's/.*(\(.*\))/\1/' \
	                      | awk '{print $$NF}');
	  echo "\newcommand{\\texliveversion}{$$texlive}" > $@

          # LaTeX Package versions.
	  tlmgr info $(texlive-packages) --only-installed | awk                \
	       '$$1=="package:" {version=0;                                    \
	                         if($$NF=="tex-gyre") name="texgyre";          \
	                         else                 name=$$NF}               \
	        $$1=="cat-version:" {version=$$NF}                             \
	        $$1=="cat-date:" {if(version==0) version=$$2;                  \
	                          printf("\\newcommand{\\tex%sversion}{%s}\n", \
	                          name, version)}' >> $@
	fi
