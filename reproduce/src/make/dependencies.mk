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
include reproduce/config/pipeline/dependency-texlive.mk
include reproduce/config/pipeline/dependency-versions.mk

ddir   = $(BDIR)/dependencies
tdir   = $(BDIR)/dependencies/tarballs
idir   = $(BDIR)/dependencies/installed
ibdir  = $(BDIR)/dependencies/installed/bin
ildir  = $(BDIR)/dependencies/installed/lib
ilidir = $(BDIR)/dependencies/installed/lib/built

# Define the top-level programs to build (installed in `.local/bin').
top-level-programs = gawk gs grep sed git astnoisechisel texlive-ready
all: $(foreach p, $(top-level-programs), $(ibdir)/$(p))

# Other basic environment settings: We are only including the host
# operating system's PATH environment variable (after our own!) for the
# compiler and linker. For the library binaries and headers, we are only
# using our internally built libraries.
.ONESHELL:
.SHELLFLAGS     := -ec
SHELL           := $(ibdir)/bash
PATH            := $(ibdir):$(PATH)
LDFLAGS         := -L$(ildir)
CPPFLAGS        := -I$(idir)/include
LD_LIBRARY_PATH := $(ildir)





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
tarballs = $(foreach t, cfitsio-$(cfitsio-version).tar.gz             \
                        cmake-$(cmake-version).tar.gz                 \
                        curl-$(curl-version).tar.gz                   \
	                gawk-$(gawk-version).tar.lz                   \
	                ghostscript-$(ghostscript-version).tar.gz     \
	                git-$(git-version).tar.xz                     \
	                gnuastro-$(gnuastro-version).tar.lz           \
	                grep-$(grep-version).tar.xz                   \
	                gsl-$(gsl-version).tar.gz                     \
	                jpegsrc.$(libjpeg-version).tar.gz             \
                        tiff-$(libtiff-version).tar.gz                \
                        libtool-$(libtool-version).tar.xz             \
                        libgit2-$(libgit2-version).tar.gz             \
	                sed-$(sed-version).tar.xz                     \
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
	  if [ $$n = cfitsio     ]; then
	    mergenames=0
	    v=$$(echo $(cfitsio-version) | sed -e's/\.//'             \
	              | awk '{l=length($1);                           \
	                      printf (l==4 ? "%d\n"                   \
	                              : (l==3 ? "%d0\n"               \
	                                 : (l==2 ? "%d00\n"           \
                                            : "%d000\n") ), $$1)}')
	    w=https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio$$v.tar.gz
	  elif [ $$n = cmake       ]; then w=https://cmake.org/files/v3.12
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
	  elif [ $$n = sed         ]; then w=http://ftp.gnu.org/gnu/sed
	  elif [ $$n = tiff        ]; then w=https://download.osgeo.org/libtiff
	  elif [ $$n = wcslib      ]; then w=ftp://ftp.atnf.csiro.au/pub/software/wcslib
	  elif [ $$n = zlib        ]; then w=http://www.zlib.net
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
$(ilidir): | $(ildir); mkdir -p $@
$(ilidir)/cfitsio: $(tdir)/cfitsio-$(cfitsio-version).tar.gz              \
                   $(ibdir)/curl | $(ilidir)
	$(call gbuild, $<,cfitsio, static, --enable-sse2 --enable-reentrant) \
	&& echo "CFITSIO is built" > $@


$(ilidir)/libgit2: $(tdir)/libgit2-$(libgit2-version).tar.gz              \
                   $(ibdir)/cmake                                         \
                   $(ibdir)/curl | $(ilidir)
	$(call cbuild, $<, libgit2-$(libgit2-version), static,            \
	              -DUSE_SSH=OFF -DUSE_OPENSSL=OFF -DBUILD_CLAR=OFF    \
	              -DTHREADSAFE=ON)                                    \
	&& echo "Libgit2 is built" > $@

$(ilidir)/gsl: $(tdir)/gsl-$(gsl-version).tar.gz | $(ilidir)
	$(call gbuild, $<, gsl-$(gsl-version), static)                    \
	&& echo "GNU Scientific Library is built" > $@

$(ilidir)/libjpeg: $(tdir)/jpegsrc.$(libjpeg-version).tar.gz | $(ilidir)
	$(call gbuild, $<, jpeg-9b, static) && echo "Libjpeg is built" > $@

$(ilidir)/libtiff: $(tdir)/tiff-$(libtiff-version).tar.gz | $(ilidir)
	$(call gbuild, $<, tiff-$(libtiff-version), static)               \
	&& echo "Libtiff is built" > $@

$(ilidir)/wcslib: $(tdir)/wcslib-$(wcslib-version).tar.bz2                \
	          $(ilidir)/cfitsio | $(ilidir)
        # Unfortunately WCSLIB forces the building of shared libraries. So
        # we'll allow it to finish, then remove the shared libraries
        # afterwards.
	$(call gbuild, $<, wcslib-$(wcslib-version), ,                     \
	              LIBS="-pthread -lcurl -lm" --without-pgplot          \
	              --disable-fortran)                                   \
	&& echo "WCSLIB is built" > $@

# Zlib: its `./configure' doesn't use Autoconf's configure script, it just
# accepts a direct `--static' option.
$(ilidir)/zlib: $(tdir)/zlib-$(zlib-version).tar.gz | $(ilidir)
ifeq ($(static_build),yes)
	$(call gbuild, $<, zlib-$(zlib-version), , --static) \
	&& echo "Zlib is built" > $@
else
	$(call gbuild, $<, zlib-$(zlib-version)) && echo "Zlib is built" > $@
endif





# Programs
# --------
#
# CMake can be built with its custom `./bootstrap' script.
$(ibdir)/cmake: $(tdir)/cmake-$(cmake-version).tar.gz
	cd $(ddir) && rm -rf cmake-$(cmake-version) &&                       \
	tar xf $< && cd cmake-$(cmake-version) &&                            \
	./bootstrap --prefix=$(idir) && make && make install &&              \
	cd ..&& rm -rf cmake-$(cmake-version)

$(ibdir)/curl: $(tdir)/curl-$(curl-version).tar.gz                           \
               $(ilidir)/zlib
	$(call gbuild, $<, curl-$(curl-version), static, --without-brotli)

$(ibdir)/gawk: $(tdir)/gawk-$(gawk-version).tar.lz
	$(call gbuild, $<, gawk-$(gawk-version), static)

$(ibdir)/sed: $(tdir)/sed-$(sed-version).tar.xz
	$(call gbuild, $<, sed-$(sed-version), static)

$(ibdir)/grep: $(tdir)/grep-$(grep-version).tar.xz
	$(call gbuild, $<, grep-$(grep-version), static)

$(ibdir)/libtool: $(tdir)/libtool-$(libtool-version).tar.xz
	$(call gbuild, $<, libtool-$(libtool-version), static)

$(ibdir)/gs: $(tdir)/ghostscript-$(ghostscript-version).tar.gz
	$(call gbuild, $<, ghostscript-$(ghostscript-version))

$(ibdir)/git: $(tdir)/git-$(git-version).tar.xz \
              $(ilidir)/zlib
	$(call gbuild, $<, git-$(git-version), static)

$(ibdir)/astnoisechisel: $(tdir)/gnuastro-$(gnuastro-version).tar.lz \
                         $(ibdir)/gs                                 \
                         $(ilidir)/gsl                               \
                         $(ilidir)/wcslib                            \
                         $(ibdir)/libtool                            \
                         $(ilidir)/libjpeg                           \
                         $(ilidir)/libtiff                           \
                         $(ilidir)/libgit2
ifeq ($(static_build),yes)
	$(call gbuild, $<, gnuastro-$(gnuastro-version), static,     \
	               --enable-static=yes --enable-shared=no, -j8,  \
	               make check -j8)
else
	$(call gbuild, $<, gnuastro-$(gnuastro-version), , , -j8,    \
	               make check -j8)
endif





# Since we want to avoid complicating the PATH, we are putting a symbolic
# link of all the TeX Live executables in $(ibdir). But symbolic links are
# hard to track for Make (as a target). So we'll make a simple ASCII file
# called `texlive-ready' when it is complete and use that as a target.
$(ibdir)/texlive-ready-tlmgr: reproduce/config/pipeline/texlive.conf

        # To work with TeX live installation, we'll need the internet.
	if ping -c1 ctan.org; then
          # Download the TeX Live installation tarball.
	  $(DOWNLOADER) $(tdir)/install-tl-unx.tar.gz \
	     http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

          # Unpack, enter the directory, and install based on the given
          # configuration (prerequisite of this rule).
	  topdir=$$(pwd)
	  cd $(ddir)
	  rm -rf install-tl-*
	  tar xf $(tdir)/install-tl-unx.tar.gz
	  cd install-tl-*
	  sed -e's|@installdir[@]|$(idir)|g' -e's|@topdir[@]|'"$$topdir"'|g' \
	      $$topdir/$< > texlive.conf
	  ./install-tl --profile=texlive.conf

          # Put a symbolic link of the TeX Live executables in `ibdir'. The
          # main problem is that the year and build system (for example
          # `x86_64-linux') are also in the directory names, making it hard
          # to be generic. We are using wildcards here, but only in this
          # Makefile, not in any other.
	  ln -fs $(idir)/texlive/20*/bin/*/* $(ibdir)/

          # Clean up and build the final target.
	  cd .. && rm -rf install-tl-* $(tdir)/install-tl-unx.tar.gz
	  echo "TeX Live is ready." > $@
	fi





# To keep things modular and simple, we'll break up the installation of TeX
# Live itself (only very basic TeX and LaTeX) and the installation of its
# necessary packages into two packages.
$(ibdir)/texlive-ready: reproduce/config/pipeline/dependency-texlive.mk \
	                $(ibdir)/texlive-ready-tlmgr

        # To work with TeX live installation, we'll need the internet.
	res=$(cat $(ibdir)/texlive-ready-tlmgr)
	if ping -c1 ctan.org                                            \
	   && [ -f $(ibdir)/texlive-ready-tlmgr ]                       \
           && [ x$$res != x"NOT" ]; then
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
	  echo "returned: $$?"; echo; echo;

          # Make a symbolic link of all the TeX Live executables in the bin
          # directory so we don't have to modify `PATH'.
	  ln -fs $(idir)/texlive/20*/bin/*/* $(ibdir)/

          # Get all the necessary versions.
	  tv=$(ddir)/texlive-versions.tex
	  texlive=$$(pdflatex --version | awk 'NR==1' | sed 's/.*(\(.*\))/\1/' \
	                      | awk '{print $$NF}');
	  echo "\newcommand{\\texliveversion}{$$texlive}" > $$tv

          # LaTeX Package versions.
	  tlmgr info $(texlive-packages) --only-installed | awk                \
	       '$$1=="package:" {version=0;                                    \
	                         if($$NF=="tex-gyre") name="texgyre";          \
	                         else                 name=$$NF}               \
	        $$1=="cat-version:" {version=$$NF}                             \
	        $$1=="cat-date:" {if(version==0) version=$$2;                  \
	                          printf("\\newcommand{\\tex%sversion}{%s}\n", \
	                          name, version)}' >> $$tv

          # Write the target if TeX live was actually installed.
	  echo "TeX Live's packages are also ready." > $@
	fi
