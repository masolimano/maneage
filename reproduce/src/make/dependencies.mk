# Build the reproduction pipeline dependencies (programs and libraries).
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
#
# This Makefile also builds GNU Bash and GNU Make. Therefore this is the
# only Makefile in the reproduction pipeline where you MUST NOT assume that
# GNU Bash or GNU Make are to be used.
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
include reproduce/config/pipeline/dependency-versions.mk

ddir  = $(BDIR)/dependencies
tdir  = $(BDIR)/dependencies/tarballs
idir  = $(BDIR)/dependencies/installed
ibdir = $(BDIR)/dependencies/installed/bin
ildir = $(BDIR)/dependencies/installed/lib

# Define the top-level programs to build (installed in `.local/bin', so for
# Coreutils, only one of its executables is enough).
top-level-programs = ls gawk gs grep libtool sed git astnoisechisel
all: $(foreach p, $(top-level-programs), $(ibdir)/$(p))

# This Makefile will be called to also build Bash locally. So when we don't
# have it yet, we'll have to use the system's bash.
ifeq ($(USE_LOCAL_BASH),yes)
SHELL := $(ibdir)/bash
else
SHELL := /bin/sh
endif

# Other basic environment settings.
.ONESHELL:
.SHELLFLAGS      = -ec
PATH            := $(ibdir):$(PATH)
LDFLAGS         := -L$(ildir) $(LDFLAGS)
CPPFLAGS        := -I$(idir)/include $(CPPFLAGS)
LD_LIBRARY_PATH := $(ildir):$(LD_LIBRARY_PATH)





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
tarballs = $(foreach t, bash-$(bash-version).tar.gz                   \
	                cfitsio-$(cfitsio-version).tar.gz             \
                        cmake-$(cmake-version).tar.gz                 \
                        coreutils-$(coreutils-version).tar.xz         \
                        curl-$(curl-version).tar.gz                   \
	                gawk-$(gawk-version).tar.gz                   \
	                ghostscript-$(ghostscript-version).tar.gz     \
	                git-$(git-version).tar.xz                     \
	                gnuastro-$(gnuastro-version).tar.lz           \
	                grep-$(grep-version).tar.xz                   \
	                gsl-$(gsl-version).tar.gz                     \
	                jpegsrc.$(libjpeg-version).tar.gz             \
                        tiff-$(libtiff-version).tar.gz                \
	                libtool-$(libtool-version).tar.gz             \
                        libgit2-$(libgit2-version).tar.gz             \
	                sed-$(sed-version).tar.xz                     \
	                make-$(make-version).tar.gz                   \
	                wcslib-$(wcslib-version).tar.bz2              \
                        zlib-$(zlib-version).tar.gz                   \
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
	  if   [ $$n = bash        ]; then w=http://ftp.gnu.org/gnu/bash
	  elif [ $$n = cfitsio     ]; then
	    mergenames=0
	    v=$$(echo $(cfitsio-version) | sed -e's/\.//'             \
	              | awk '{l=length($1);                           \
	                      printf (l==4 ? "%d\n"                   \
	                              : (l==3 ? "%d0\n"               \
	                                 : (l==2 ? "%d00\n"           \
                                            : "%d000\n") ), $$1)}')
	    w=https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio$$v.tar.gz
	  elif [ $$n = cmake       ]; then w=https://cmake.org/files/v3.12
	  elif [ $$n = coreutils   ]; then w=http://ftp.gnu.org/gnu/coreutils
	  elif [ $$n = curl        ]; then w=https://curl.haxx.se/download
	  elif [ $$n = gawk        ]; then w=http://ftp.gnu.org/gnu/gawk
	  elif [ $$n = ghostscript ]; then w=https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs925
	  elif [ $$n = git         ]; then w=https://mirrors.edge.kernel.org/pub/software/scm/git
	  elif [ $$n = gnuastro    ]; then w=http://akhlaghi.org/src
	  elif [ $$n = grep        ]; then w=http://ftp.gnu.org/gnu/grep
	  elif [ $$n = gsl         ]; then w=http://ftp.gnu.org/gnu/gsl
	  elif [ $$n = jpegsrc     ]; then w=http://ijg.org/files
	  elif [ $$n = libtool     ]; then w=ftp://ftp.gnu.org/gnu/libtool
	  elif [ $$n = libgit      ]; then
	    mergenames=0
	    w=https://github.com/libgit2/libgit2/archive/v$(libgit2-version).tar.gz
	  elif [ $$n = make        ]; then w=http://akhlaghi.org/src
	  elif [ $$n = sed         ]; then w=http://ftp.gnu.org/gnu/sed
	  elif [ $$n = tiff        ]; then w=https://download.osgeo.org/libtiff
	  elif [ $$n = wcslib      ]; then w=ftp://ftp.atnf.csiro.au/pub/software/wcslib
	  elif [ $$n = zlib        ]; then w=https://www.zlib.net
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
	  echo "Downloading $$tarballurl"
	  $(DOWNLOADER) $@ $$tarballurl
	fi





# Build system rules
# ------------------
gbuild = cd $(ddir); rm -rf $(2); tar xf $(tdir)/$(1); cd $(2);      \
         if [ $(3)x = staticx ]; then                                \
         opts="CFLAGS=--static --disable-shared";                    \
         fi;                                                         \
         ./configure $$opts $(4) --prefix=$(idir); make $(5);        \
         check="$(6)"; if [ x"$$check" != x ]; then $$check; fi;     \
         make install; cd ..; rm -rf $(2)


cbuild = cd $(ddir); rm -rf $(2); tar xf $(tdir)/$(1); cd $(2);      \
	 rm -rf my-build; mkdir my-build; cd my-build; opts="";      \
	 if [ $(3)x = staticx ]; then                                \
	   export CFLAGS="--static $$CFLAGS";                        \
	   opts="-DBUILD_SHARED_LIBS=OFF";                           \
	 fi;                                                         \
	 cmake .. $$opts $(4);                                       \
	 cmake --build .;                                            \
	 cmake .. -DCMAKE_INSTALL_PREFIX=$(idir);                    \
	 cmake --build . --target install; cd ../..; rm -rf $(2)





# Libraries
# ---------
$(ildir)/libcfitsio.a: $(tdir)/cfitsio-$(cfitsio-version).tar.gz         \
                       $(ildir)/libcurl.a                               \
                       $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), cfitsio, static,            \
                      --enable-sse2 --enable-reentrant)

$(ildir)/libcurl.a: $(tdir)/curl-$(curl-version).tar.gz \
                    $(ildir)/libz.a                     \
                    $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), curl-$(curl-version), static, \
                      --without-brotli)

$(ildir)/libgit2.a: $(tdir)/libgit2-$(libgit2-version).tar.gz             \
                    $(ildir)/libcurl.a                                    \
                    $(ibdir)/cmake
	$(call cbuild,$(subst $(tdir),,$<), libgit2-$(libgit2-version),   \
	              static, -DUSE_SSH=OFF -DUSE_OPENSSL=OFF             \
                      -DBUILD_CLAR=OFF -DTHREADSAFE=ON, )

$(ildir)/libgsl.a: $(tdir)/gsl-$(gsl-version).tar.gz \
                   $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), gsl-$(gsl-version), static)

$(ildir)/libjpeg.a: $(tdir)/jpegsrc.$(libjpeg-version).tar.gz
	$(call gbuild,$(subst $(tdir),,$<), jpeg-9b, static)

$(ildir)/libtiff.a: $(tdir)/tiff-$(libtiff-version).tar.gz \
                   $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), tiff-$(libtiff-version), static)

$(ildir)/libwcs.a: $(tdir)/wcslib-$(wcslib-version).tar.bz2 \
	           $(ildir)/libcfitsio.a
	$(call gbuild,$(subst $(tdir),,$<), wcslib-$(wcslib-version),     \
                      static, LIBS="-pthread -lcurl -lm" --without-pgplot \
                         --disable-fortran)

# Zlib's `./configure' doesn't use Autoconf's configure script, it just
# accepts a direct `--static' option.
$(ildir)/libz.a: $(tdir)/zlib-$(zlib-version).tar.gz
	$(call gbuild,$(subst $(tdir),,$<), zlib-$(zlib-version), , \
                      --static)





# Programs
# --------
$(ibdir)/bash: $(tdir)/bash-$(bash-version).tar.gz
	$(call gbuild,$(subst $(tdir),,$<), bash-$(bash-version), static)

$(ibdir)/cmake: $(tdir)/cmake-$(cmake-version).tar.gz \
                $(ibdir)/ls
	$(call cbuild,$(subst $(tdir),,$<), cmake-$(cmake-version))

# Unfortunately GNU Make needs dynamic linking in two instances: when
# loading objects (dynamically linked libraries), or when using the
# `getpwnam' function (for tilde expansion). The first can be disabled with
# `--disable-load', but unfortunately I don't know any way to fix the
# second. So, we'll have to build it dynamically for now.
$(ibdir)/make: $(tdir)/make-$(make-version).tar.gz
	$(call gbuild,$(subst $(tdir),,$<), make-$(make-version))

$(ibdir)/ls: $(tdir)/coreutils-$(coreutils-version).tar.xz
	$(call gbuild,$(subst $(tdir),,$<), coreutils-$(coreutils-version), \
                      static)

$(ibdir)/gawk: $(tdir)/gawk-$(gawk-version).tar.gz \
               $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), gawk-$(gawk-version), static)

$(ibdir)/sed: $(tdir)/sed-$(sed-version).tar.xz \
              $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), sed-$(sed-version), static)

$(ibdir)/grep: $(tdir)/grep-$(grep-version).tar.xz \
               $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), grep-$(grep-version), static)

$(ibdir)/libtool: $(tdir)/libtool-$(libtool-version).tar.gz \
                  $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), libtool-$(libtool-version), static)

$(ibdir)/gs: $(tdir)/ghostscript-$(ghostscript-version).tar.gz \
             $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), ghostscript-$(ghostscript-version))

$(ibdir)/git: $(tdir)/git-$(git-version).tar.xz \
             $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), git-$(git-version), static)

$(ibdir)/astnoisechisel: $(tdir)/gnuastro-$(gnuastro-version).tar.lz \
                         $(ildir)/libgsl.a                           \
                         $(ildir)/libcfitsio.a                       \
                         $(ildir)/libwcs.a                           \
                         $(ibdir)/gs                                 \
                         $(ildir)/libjpeg.a                          \
                         $(ildir)/libtiff.a                          \
                         $(ildir)/libgit2.a                          \

	$(call gbuild,$(subst $(tdir),,$<), gnuastro-$(gnuastro-version), \
                      static, , -j8, make check -j8)
