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
top-level-programs = ls gawk gs grep libtool sed astnoisechisel
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
tarballs = $(foreach t, bash-$(bash-version).tar.gz                 \
	                cfitsio$(cfitsio-version).tar.gz            \
                        coreutils-$(coreutils-version).tar.xz       \
	                gawk-$(gawk-version).tar.gz                 \
	                ghostscript-$(ghostscript-version).tar.gz   \
	                gnuastro-$(gnuastro-version).tar.gz         \
	                grep-$(grep-version).tar.xz                 \
	                gsl-$(gsl-version).tar.gz                   \
	                jpegsrc.$(libjpeg-version).tar.gz           \
	                libtool-$(libtool-version).tar.gz           \
                        libgit2-$(libgit2-version).tar.gz           \
	                sed-$(sed-version).tar.xz                   \
	                make-$(make-version).tar.gz                 \
	                wcslib-$(wcslib-version).tar.bz2            \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%:
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then
	  cp $(DEPENDENCIES-DIR)/$* $@
	else
          # Remove all numbers, `-' and `.' from the tarball name so we can
          # search more easily only with the program name.
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g' -e's/\./ /g'         \
	               | awk '{print $$1}' )

          # Set the top download link of the requested tarball.
	  if   [ $$n = bash        ]; then w=http://ftp.gnu.org/gnu/bash
	  elif [ $$n = cfitsio     ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = coreutils   ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = gawk        ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = ghostscript ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = gnuastro    ]; then w=http://akhlaghi.org
	  elif [ $$n = grep        ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = gsl         ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = jpegsrc     ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = libtool     ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = libgit      ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = sed         ]; then w=WWWWWWWWWWWWWWWW
	  elif [ $$n = make        ]; then w=http://akhlaghi.org
	  elif [ $$n = wcslib      ]; then w=WWWWWWWWWWWWWWWW
	  else
	    echo; echo; echo;
	    echo "'$$n' not recognized as a dependency name to download."
	    echo; echo; echo;
	    exit 1
	  fi

          # Download the requested tarball.
	  $(DOWNLOADER) $@ $$w/$*
	fi





# Customized build
# ----------------
#
# Programs that need some customization on their build.
# For CFITSIO we'll need to intervene manually to remove the check on
# libcurl (which can be real trouble in this controlled environment).
$(ildir)/libcfitsio.a: $(ibdir)/ls                              \
                          $(tdir)/cfitsio$(cfitsio-version).tar.gz
        # Same as before
	cd $(ddir)
	tar xf $(tdir)/cfitsio$(cfitsio-version).tar.gz
	cd cfitsio

        # Remove the part that checks for the CURL library, so it assumes
        # that the CURL library wasn't found.
	awk 'NR<4785 || NR>4847' configure > new_configure
	mv new_configure configure
	chmod +x configure

        # Do the standard configuring and building
	./configure CFLAGS=--static --disable-shared --prefix=$(idir)
	make; make install;
	cd ..; rm -rf cfitsio


# Why not shared: Gnuastro's configure can't link with it in static mode.
$(ildir)/libgit2.a: $(tdir)/libgit2-$(libgit2-version).tar.gz
	cd $(ddir)
	tar xf $(tdir)/libgit2-$(libgit2-version).tar.gz
	cd libgit2-$(libgit2-version)
	mkdir build
	cd build
	export CFLAGS="--static $$CFLAGS"
	cmake .. -DUSE_SSH=OFF -DUSE_OPENSSL=OFF -DBUILD_SHARED_LIBS=OFF \
                 -DBUILD_CLAR=OFF -DTHREADSAFE=ON
	cmake --build .
	cmake .. -DCMAKE_INSTALL_PREFIX=$(idir)
	cmake --build . --target install
	cd ../..
	rm -rf libgit2-$(libgit2-version)





# GNU Build system programs
# -------------------------
#
# Programs that use the basic GNU build system.
gbuild = cd $(ddir); tar xf $(tdir)/$(1); cd $(2);               \
         if [ $(3)x = staticx ]; then                            \
         opts="CFLAGS=--static --disable-shared";                \
         fi;                                                     \
         ./configure $$opts $(4) --prefix=$(idir); make $(5);    \
         check="$(6)"; if [ x"$$check" != x ]; then $$check; fi; \
         make install; cd ..; rm -rf $(2)

$(ibdir)/bash: $(tdir)/bash-$(bash-version).tar.gz
	$(call gbuild,$(subst $(tdir),,$<), bash-$(bash-version), static)


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


$(ildir)/libgsl.a: $(tdir)/gsl-$(gsl-version).tar.gz \
                   $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), gsl-$(gsl-version), static)


$(ildir)/libwcs.a: $(tdir)/wcslib-$(wcslib-version).tar.bz2 \
	           $(ildir)/libcfitsio.a
	$(call gbuild,$(subst $(tdir),,$<), wcslib-$(wcslib-version), , \
                      LIBS="-pthread -lcurl -lm" --without-pgplot       \
                         --disable-fortran)


$(ibdir)/gs: $(tdir)/ghostscript-$(ghostscript-version).tar.gz \
             $(ibdir)/ls
	$(call gbuild,$(subst $(tdir),,$<), ghostscript-$(ghostscript-version))


$(ildir)/libjpeg.a: $(tdir)/jpegsrc.$(libjpeg-version).tar.gz
	$(call gbuild,$(subst $(tdir),,$<), jpeg-9b, static)


$(ibdir)/astnoisechisel: $(tdir)/gnuastro-$(gnuastro-version).tar.gz \
                         $(ildir)/libgsl.a                           \
                         $(ildir)/libcfitsio.a                       \
                         $(ildir)/libwcs.a                           \
                         $(ibdir)/gs                                 \
                         $(ildir)/libjpeg.a                          \
                         $(ildir)/libgit2.a                          \

	$(call gbuild,$(subst $(tdir),,$<), gnuastro-$(gnuastro-version), \
                      static, , -j8, make check -j8)
