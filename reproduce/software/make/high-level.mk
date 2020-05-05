# Build the project's dependencies (programs and libraries).
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./project configure' script. It
# is not included into the reproduction pipe after that.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Copyright (C) 2019-2020 Raul Infante-Sainz <infantesainz@gmail.com>
#
# This Makefile is part of Maneage. Maneage is free software: you can
# redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation, either
# version 3 of the License, or (at your option) any later version.
#
# Maneage is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details. See <http://www.gnu.org/licenses/>.



# Top level environment
include reproduce/software/config/LOCAL.conf
include reproduce/software/make/build-rules.mk
include reproduce/software/config/TARGETS.conf
include reproduce/software/config/versions.conf
include reproduce/software/config/checksums.conf
include reproduce/software/config/texlive-packages.conf

lockdir = $(BDIR)/locks
tdir    = $(BDIR)/software/tarballs
ddir    = $(BDIR)/software/build-tmp
idir    = $(BDIR)/software/installed
ibdir   = $(BDIR)/software/installed/bin
ildir   = $(BDIR)/software/installed/lib
iidir   = $(BDIR)/software/installed/include
dtexdir = $(shell pwd)/reproduce/software/bibtex
itidir  = $(BDIR)/software/installed/version-info/tex
ictdir  = $(BDIR)/software/installed/version-info/cite
ipydir  = $(BDIR)/software/installed/version-info/python
ibidir  = $(BDIR)/software/installed/version-info/proglib

# Set the top-level software to build.
all: $(foreach p, $(top-level-programs),  $(ibidir)/$(p)) \
     $(foreach p, $(top-level-python),    $(ipydir)/$(p)) \
     $(itidir)/texlive

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
.SHELLFLAGS := --noprofile --norc -ec
export CCACHE_DISABLE := 1
export PATH := $(ibdir)
export CC := $(ibdir)/gcc
export CXX := $(ibdir)/g++
export SHELL := $(ibdir)/bash
export F77 := $(ibdir)/gfortran
export LD_RUN_PATH := $(ildir):$(il64dir)
export PKG_CONFIG_PATH := $(ildir)/pkgconfig
export LD_LIBRARY_PATH := $(ildir):$(il64dir)
export PKG_CONFIG_LIBDIR := $(ildir)/pkgconfig

# Until we build our own C library, without this, our GCC won't be able to
# compile anything! Note that on most systems (in particular
# non-Debian-based), `sys_cpath' will be empty.
export CPATH := $(sys_cpath)

# RPATH is automatically written in macOS, so `DYLD_LIBRARY_PATH' is
# ultimately redundant. But on some systems, even having a single value
# causes crashs (see bug #56682). So we'll just give it no value at all.
export DYLD_LIBRARY_PATH :=

# On Debian-based OSs, the basic C libraries are in a target-specific
# location, not in standard places. Until we merge the building of the C
# library, it is thus necessary to include this location here. On systems
# that don't need it, `sys_library_path' is just empty. This is necessary
# for `ld'.
export LIBRARY_PATH := $(sys_library_path)

# Recipe startup script, see `reproduce/software/shell/bashrc.sh'.
export PROJECT_STATUS := configure_highlevel
export BASH_ENV := $(shell pwd)/reproduce/software/shell/bashrc.sh

# Servers to use as backup, later this should go in a file that is not
# under version control (the actual server that the tarbal comes from is
# irrelevant).
backupservers = http://akhlaghi.org/maneage-software

# Building flags:
#
# C++ flags: when we build GCC, the C++ standard library needs to link with
# libiconv. So it is necessary to generically include `-liconv' for all C++
# builds.
export CPPFLAGS          := -I$(idir)/include
export LDFLAGS           := $(rpath_command) -L$(ildir)
ifeq ($(host_cc),0)
export CXXFLAGS          := -liconv
endif





# We want the download to happen on a single thread. So we need to define a
# lock, and call a special script we have written for this job. These are
# placed here because we want them both in the `high-level.mk' and
# `python.mk'.
$(lockdir): | $(BDIR); mkdir $@
downloader="wget --no-use-server-timestamps -O";
downloadwrapper = ./reproduce/analysis/bash/download-multi-try





# Mini-environment software
include reproduce/software/make/python.mk





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
tarballs = $(foreach t, apachelog4cxx-$(apachelog4cxx-version).tar.lz \
                        apr-$(apr-version).tar.gz \
                        apr-util-$(apr-util-version).tar.gz \
                        astrometry.net-$(astrometrynet-version).tar.gz \
                        atlas-$(atlas-version).tar.bz2 \
                        autoconf-$(autoconf-version).tar.lz \
                        automake-$(automake-version).tar.gz \
                        bison-$(bison-version).tar.xz \
                        boost-$(boost-version).tar.gz \
                        cairo-$(cairo-version).tar.xz \
                        cdsclient-$(cdsclient-version).tar.gz \
                        cfitsio-$(cfitsio-version).tar.gz \
                        cmake-$(cmake-version).tar.gz \
                        eigen-$(eigen-version).tar.gz \
                        expat-$(expat-version).tar.lz \
                        fftw-$(fftw-version).tar.gz \
                        flex-$(flex-version).tar.gz \
                        freetype-$(freetype-version).tar.gz \
                        gdb-$(gdb-version).tar.gz \
                        ghostscript-$(ghostscript-version).tar.gz \
                        gnuastro-$(gnuastro-version).tar.lz \
                        gsl-$(gsl-version).tar.gz \
                        hdf5-$(hdf5-version).tar.gz \
                        healpix-$(healpix-version).tar.gz \
                        help2man-$(help2man-version).tar.xz \
                        imagemagick-$(imagemagick-version).tar.xz \
                        imfit-$(imfit-version).tar.gz \
                        install-tl-unx.tar.gz \
                        jpegsrc.$(libjpeg-version).tar.gz \
                        lapack-$(lapack-version).tar.gz \
                        libgit2-$(libgit2-version).tar.gz \
                        libnsl-$(libnsl-version).tar.gz \
                        libpng-$(libpng-version).tar.xz \
                        libtirpc-$(libtirpc-version).tar.bz2 \
                        libxml2-$(libxml2-version).tar.gz \
                        missfits-$(missfits-version).tar.gz \
                        netpbm-$(netpbm-version).tar.gz \
                        openblas-$(openblas-version).tar.gz \
                        openmpi-$(openmpi-version).tar.gz \
                        openssh-$(openssh-version).tar.gz \
                        pixman-$(pixman-version).tar.gz \
                        R-$(R-version).tar.gz \
                        scamp-$(scamp-version).tar.lz \
                        scons-$(scons-version).tar.gz \
                        sextractor-$(sextractor-version).tar.lz \
                        swarp-$(swarp-version).tar.gz \
                        swig-$(swig-version).tar.gz \
                        rpcsvc-proto-$(rpcsvc-proto-version).tar.xz \
                        tides-$(tides-version).tar.gz \
                        tiff-$(libtiff-version).tar.gz \
                        wcslib-$(wcslib-version).tar.bz2 \
                        xlsxio-$(xlsxio-version).tar.gz \
                        yaml-$(yaml-version).tar.gz \
                        zlib-$(zlib-version).tar.gz \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%: | $(lockdir)

        # Remove the version numbers and suffix from the tarball name so we
        # can search more easily only with the program name. This requires
        # the first character of the version to be a digit: packages such
        # as `foo' and `foo-3' will not be distinguished, but `foo' and
        # `foo2' will be distinguished.
	@n=$$(echo $* | sed -e's/-[0-9]/ /' -e's/\./ /g' \
	              | awk '{print $$1}' )

        # Set the top download link of the requested tarball.
	mergenames=1
	if   [ $$n = apachelog4cxx ]; then c=$(apachelog4cxx-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = apr         ]; then c=$(apr-checksum); w=https://www-us.apache.org/dist/apr
	elif [ $$n = apr-util    ]; then c=$(apr-util-checksum); w=https://www-us.apache.org/dist/apr
	elif [ $$n = astrometry  ]; then c=$(astrometrynet-checksum); w=http://astrometry.net/downloads
	elif [ $$n = atlas       ]; then
	  mergenames=0
	  c=$(atlas-checksum)
	  w=https://sourceforge.net/projects/math-atlas/files/Stable/$(atlas-version)/atlas$(atlas-version).tar.bz2/download
	elif [ $$n = autoconf    ]; then c=$(autoconf-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = automake    ]; then c=$(automake-checksum); w=http://ftp.gnu.org/gnu/automake
	elif [ $$n = bison       ]; then c=$(bison-checksum); w=http://ftp.gnu.org/gnu/bison
	elif [ $$n = boost       ]; then
	  mergenames=0
	  c=$(boost-checksum)
	  vstr=$$(echo $(boost-version) | sed -e's/\./_/g')
	  w=https://dl.bintray.com/boostorg/release/$(boost-version)/source/boost_$$vstr.tar.gz
	elif [ $$n = cairo       ]; then c=$(cairo-checksum); w=https://www.cairographics.org/releases
	elif [ $$n = cdsclient   ]; then c=$(cdsclient-checksum); w=http://cdsarc.u-strasbg.fr/ftp/pub/sw
	elif [ $$n = cfitsio     ]; then c=$(cfitsio-checksum); w=https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c
	elif [ $$n = cmake       ]; then
	  mergenames=0
	  c=$(cmake-checksum)
	  majv=$$(echo $(cmake-version) \
	               | sed -e's/\./ /' \
	               | awk '{printf("%d.%d", $$1, $$2)}')
	  w=https://cmake.org/files/v$$majv/cmake-$(cmake-version).tar.gz
	elif [ $$n = eigen       ]; then
	  mergenames=0
	  c=$(eigen-checksum);
	  w=http://bitbucket.org/eigen/eigen/get/$(eigen-version).tar.gz
	elif [ $$n = expat    ]; then
	  mergenames=0
	  c=$(expat-checksum)
	  vstr=$$(echo $(expat-version) | sed -e's/\./_/g')
	  w=https://github.com/libexpat/libexpat/releases/download/R_$$vstr/expat-$(expat-version).tar.lz
	elif [ $$n = fftw        ]; then c=$(fftw-checksum); w=ftp://ftp.fftw.org/pub/fftw
	elif [ $$n = flex        ]; then c=$(flex-checksum); w=https://github.com/westes/flex/files/981163
	elif [ $$n = freetype    ]; then c=$(freetype-checksum); w=https://download.savannah.gnu.org/releases/freetype
	elif [ $$n = gdb         ]; then c=$(gdb-checksum); w=http://ftp.gnu.org/gnu/gdb
	elif [ $$n = ghostscript ]; then
	  c=$(ghostscript-checksum)
	  v=$$(echo $(ghostscript-version) | sed -e's/\.//')
	  w=https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs$$v
	elif [ $$n = gnuastro    ]; then c=$(gnuastro-checksum); w=http://ftp.gnu.org/gnu/gnuastro
	elif [ $$n = gsl         ]; then c=$(gsl-checksum); w=http://ftp.gnu.org/gnu/gsl
	elif [ $$n = hdf5        ]; then
	  mergenames=0
	  c=$(hdf5-checksum)
	  majorver=$$(echo $(hdf5-version) | sed -e 's/\./ /g' | awk '{printf("%d.%d", $$1, $$2)}')
	  w=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$$majorver/hdf5-$(hdf5-version)/src/$*
	elif [ $$n = healpix     ]; then c=$(healpix-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = help2man    ]; then c=$(help2man-checksum); w=http://ftp.gnu.org/gnu/help2man
	elif [ $$n = imagemagick ]; then c=$(imagemagick-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = imfit       ]; then
	  mergenames=0
	  c=$(imfit-checksum)
	  w=http://www.mpe.mpg.de/~erwin/resources/imfit/imfit-$(imfit-version)-source.tar.gz
	elif [ $$n = install-tl-unx ]; then c=NO-CHECK-SUM; w=http://mirror.ctan.org/systems/texlive/tlnet
	elif [ $$n = jpegsrc     ]; then c=$(libjpeg-checksum); w=http://ijg.org/files
	elif [ $$n = lapack      ]; then c=$(lapack-checksum); w=http://www.netlib.org/lapack
	elif [ $$n = libnsl      ]; then c=$(libnsl-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = libpng      ]; then c=$(libpng-checksum); w=https://download.sourceforge.net/libpng
	elif [ $$n = libgit2     ]; then
	  mergenames=0
	  c=$(libgit2-checksum)
	  w=https://github.com/libgit2/libgit2/archive/v$(libgit2-version).tar.gz
	elif [ $$n = libtirpc    ]; then c=$(libtirpc-checksum); w=https://downloads.sourceforge.net/libtirpc
	elif [ $$n = libxml2     ]; then c=$(libxml2-checksum); w=ftp://xmlsoft.org/libxml2
	elif [ $$n = missfits    ]; then c=$(missfits-checksum); w=https://www.astromatic.net/download/missfits
	elif [ $$n = netpbm      ]; then c=$(netpbm-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = openblas    ]; then
	  mergenames=0
	  c=$(openblas-checksum)
	  w=https://github.com/xianyi/OpenBLAS/archive/v$(openblas-version).tar.gz
	elif [ $$n = openmpi     ]; then
	  mergenames=0
	  c=$(openmpi-checksum)
	  majorver=$$(echo $(openmpi-version) | sed -e 's/\./ /g' | awk '{printf("%d.%d", $$1, $$2)}')
	  w=https://download.open-mpi.org/release/open-mpi/v$$majorver/$*
	elif [ $$n = openssh     ]; then c=$(openssh-checksum); w=https://artfiles.org/openbsd/OpenSSH/portable
	elif [ $$n = pixman      ]; then c=$(pixman-checksum); w=https://www.cairographics.org/releases
	elif [ $$n = R           ]; then c=$(R-checksum);
	  majver=$$(echo $(R-version) | sed -e's/\./ /g' | awk '{print $$1}')
	  w=https://cran.r-project.org/src/base/R-$$majver
	elif [ $$n = rpcsvc-proto ]; then c=$(rpcsvc-proto-checksum); w=https://github.com/thkukuk/rpcsvc-proto/releases/download/v$(rpcsvc-proto-version)
	elif [ $$n = scamp       ]; then c=$(scamp-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = scons       ]; then
	  mergenames=0
	  c=$(scons-checksum)
	  w=https://sourceforge.net/projects/scons/files/scons/$(scons-version)/scons-$(scons-version).tar.gz/download
	elif [ $$n = sextractor  ]; then c=$(sextractor-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = swarp       ]; then c=$(swarp-checksum); w=https://www.astromatic.net/download/swarp
	elif [ $$n = swig        ]; then c=$(swig-checksum); w=https://sourceforge.net/projects/swig/files/swig/swig-$(swig-version)
	elif [ $$n = tides       ]; then c=$(tides-checksum); w=http://akhlaghi.org/maneage-software
	elif [ $$n = tiff        ]; then c=$(libtiff-checksum); w=https://download.osgeo.org/libtiff
	elif [ $$n = wcslib      ]; then c=$(wcslib-checksum); w=ftp://ftp.atnf.csiro.au/pub/software/wcslib
	elif [ $$n = xlsxio      ]; then
	  mergenames=0
	  c=$(xlsxio-checksum);
	  w=https://github.com/brechtsanders/xlsxio/archive/$(xlsxio-version).tar.gz
	elif [ $$n = yaml        ]; then c=$(yaml-checksum); w=pyyaml.org/download/libyaml
	elif [ $$n = zlib        ]; then c=$(zlib-checksum); w=https://zlib.net
	else
	  echo; echo; echo;
	  echo "'$$n' not recognized as a software tarball name to download."
	  echo; echo; echo;
	  exit 1
	fi

        # Download the requested tarball. Note that some packages may not
        # follow our naming convention (where the package name is merged
        # with its version number). In such cases, `w' will be the full
        # address, not just the top directory address. But since we are
        # storing all the tarballs in one directory, we want it to have the
        # same naming convention, so we'll download it to a temporary name,
        # then rename that.
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then
	  cp $(DEPENDENCIES-DIR)/$* "$@.unchecked"
	else
	  if [ $$mergenames = 1 ]; then  tarballurl=$$w/"$*"
	  else                           tarballurl=$$w
	  fi

          # Download using the script specially defined for this job.
	  touch $(lockdir)/download
	  downloader="wget --no-use-server-timestamps -O"
	  $(downloadwrapper) "$$downloader" $(lockdir)/download \
	                     $$tarballurl "$@.unchecked" "$(backupservers)"
	fi

        # Make sure this is the expected tarball. Note that we now have a
        # controlled `sha512sum' build (as part of GNU Coreutils). So we
        # don't need to check its existance like `basic.mk'. But for LaTeX,
        # we need to ignore a checksum (it downloads the binaries).
	if [ x"$$c" == x"NO-CHECK-SUM" ]; then
	  mv "$@.unchecked" "$@"
	else
	  checksum=$$(sha512sum "$@.unchecked" | awk '{print $$1}')
	  if [ x"$$checksum" = x"$$c" ]; then
	    mv "$@.unchecked" "$@"
	  else
	    echo "ERROR: Non-matching checksum for '$*'."
	    echo "Checksum should be: $$c"
	    echo "Checksum is:        $$checksum"
	    exit 1
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

# Until version 0.11.0 is released, we are using the version corresponding
# to commit 014954db (603 commits after version 0.10.0, most recent when
# first importing log4cxx into this project).
#
# Note that after cloning the project, the following changes are necessary
# in `configure.ac'.
#  - Update the final name of the tarball and its version (from `git
#  - describe') by modifying the `AC_INIT' line:
#        AC_INIT([apachelog4cxx], [0.10.0-603-014954db])
#  - Because of the long file names in the project, some files will not be
#    packaged by default, so pass the `tar-ustar' option to Automake (the
#    `AM_INIT_AUTOMAKE' line of `configure.ac':
#        AM_INIT_AUTOMAKE([foreign subdir-objects -Wall tar-ustar])
#
# You can then simply bootstrap the project and make the distribution
# tarball like this:
#        ./autogen.sh && ./configure && make -j8 && make dist-lzip
#
# Unfortunately we have to re-run the `autogen.sh' script on the tarball to
# build it because it will complain about the version of libtool, so until
# the version 0.11.0 of log4cxx, we'll have to run `autogen.sh' on the
# unpacked source also.
$(ibidir)/apachelog4cxx: $(ibidir)/automake \
                         $(tdir)/apachelog4cxx-$(apachelog4cxx-version).tar.lz

	pdir=apachelog4cxx-$(apachelog4cxx-version)
	rm -rf $(ddir)/$$pdir
	topdir=$(pwd)
	cd $(ddir)
	tar xf $(word 1,$(filter $(tdir)/%,$^))
	cd $$pdir
	./autogen.sh \
	&& ./configure SHELL=$(ibdir)/bash --prefix=$(idir) \
	&& make -j$(numthreads) SHELL=$(ibdir)/bash \
	&& make install \
	&& cd .. \
	&& rm -rf $$pdir \
	&& cd $$topdir \
	&& echo "Apache log4cxx $(apachelog4cxx-version)" > $@

$(ibidir)/apr: $(tdir)/apr-$(apr-version).tar.gz
	$(call gbuild, apr-$(apr-version), ,--disable-static) \
	&& echo "Apache Portable Runtime $(apr-version)" > $@

$(ibidir)/apr-util: $(ibidir)/apr \
                    $(tdir)/apr-util-$(apr-util-version).tar.gz
	$(call gbuild, apr-util-$(apr-util-version), , \
	               --disable-static \
	               --with-apr=$(idir) \
	               --with-openssl=$(idir) \
	               --with-crypto ) \
	&& echo "Apache Portable Runtime Utility $(apr-util-version)" > $@

$(ibidir)/atlas: $(tdir)/atlas-$(atlas-version).tar.bz2 \
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
	cd $(ddir) \
	&& tar xf $(tdir)/atlas-$(atlas-version).tar.bz2 \
	&& cd ATLAS \
	&& rm -rf build \
	&& mkdir build \
	&& cd build \
	&& ../configure -b 64 -D c -DPentiumCPS=$$core \
	             --with-netlib-lapack-tarfile=$(tdir)/lapack-$(lapack-version).tar.gz \
	             --cripple-atlas-performance \
	             -Fa alg -fPIC --shared $$clangflag \
	             --prefix=$(idir) \
	&& make \
	&& if [ "x$(on_mac_os)" != xyes ]; then \
	     cd lib && make -f $$sharedmk && cd .. \
	     && for l in lib/*.$$s*; do \
	          patchelf --set-rpath $(ildir) $$l; done \
	     && cp -d lib/*.$$s* $(ildir) \
	     && ln -fs $(ildir)/libblas.$$s  $(ildir)/libblas.$$m \
	     && ln -fs $(ildir)/libf77blas.$$s $(ildir)/libf77blas.$$m \
	     && ln -fs $(ildir)/liblapack.$$f  $(ildir)/liblapack.$$s \
	     && ln -fs $(ildir)/liblapack.$$f  $(ildir)/liblapack.$$m; \
	   fi \
	&& make install

        # We need to check the existance of `libptlapack.a', but we can't
        # do this in the `&&' steps above (it will conflict). So we'll do
        # the check after seeing if `libtatlas.so' is installed, then we'll
        # finalize the build (delete the untarred directory).
	if [ "x$(on_mac_os)" != xyes ]; then \
	  [ -e lib/libptlapack.a ] && cp lib/libptlapack.a $(ildir); \
	  cd $(ddir); \
	  rm -rf ATLAS; \
	fi

        # We'll check the full installation with the static library (not
        # currently building shared library on Mac.
	if [ -f $(ildir)/libatlas.a ]; then \
	  echo "ATLAS $(atlas-version)" > $@; \
	fi

# Boost doesn't use the standard GNU Build System.
$(ibidir)/boost: $(ibidir)/openmpi \
                 $(ibidir)/python \
                 $(tdir)/boost-$(boost-version).tar.gz
	vstr=$$(echo $(boost-version) | sed -e's/\./_/g')
	rm -rf $(ddir)/boost_$$vstr
	topdir=$(pwd); cd $(ddir);
	tar xf $(word 1,$(filter $(tdir)/%,$^)) \
	&& cd boost_$$vstr \
	&& ./bootstrap.sh --prefix=$(idir) --with-libraries=all \
	                  --with-python=python3 \
	&& echo "using mpi ;" > project-config.jam \
	&& ./b2 stage threading=multi link=shared --prefix=$(idir) -j$(numthreads) \
	&& ./b2 install threading=multi link=shared --prefix=$(idir) -j$(numthreads) \
	&& cd $$topdir \
	&& rm -rf $(ddir)/boost_$$vstr \
	&& echo "Boost $(boost-version)" > $@

$(ibidir)/cfitsio: $(ibidir)/curl \
                   $(tdir)/cfitsio-$(cfitsio-version).tar.gz

        # CFITSIO hard-codes '@rpath' inside the shared library on
        # Mac systems. So we need to change it to our library
        # installation path. It doesn't affect GNU/Linux, so we'll
        # just do it in any case to keep things clean.
	topdir=$(pwd); cd $(ddir); tar xf $(word 1,$(filter $(tdir)/%,$^))
	customtar=cfitsio-$(cfitsio-version)-custom.tar.gz
	cd cfitsio-$(cfitsio-version)
	sed configure -e's|@rpath|$(ildir)|g' > configure_tmp
	mv configure_tmp configure
	chmod +x configure
	cd ..
	tar cf $$customtar cfitsio-$(cfitsio-version)
	cd $$topdir

        # Continue the standard build on the customized tarball. Note that
        # with the installation of CFITSIO, `fpack' and `funpack' are not
        # installed by default. Because of that, they are added explicity.
	export gbuild_tar=$$customtar
	$(call gbuild, cfitsio-$(cfitsio-version), , \
	               --enable-sse2 --enable-reentrant \
	               --with-bzip2=$(idir), , make shared fpack funpack) \
	&& rm $$customtar \
	&& echo "CFITSIO $(cfitsio-version)" > $@

$(ibidir)/cairo: $(ibidir)/freetype \
                 $(ibidir)/libpng \
                 $(ibidir)/pixman \
                 $(tdir)/cairo-$(cairo-version).tar.xz
	$(call gbuild, cairo-$(cairo-version), static, \
	               --with-x=no, -j$(numthreads) V=1) \
	&& echo "Cairo $(cairo-version)" > $@

# Eigen is just headers! So it doesn't need to be compiled. Once unpacked
# it has a checksum after `eigen-eigen', so we'll just use a `*' to choose
# the unpacked directory.
$(ibidir)/eigen: $(tdir)/eigen-$(eigen-version).tar.gz
	rm -rf $(ddir)/eigen-eigen-*
	topdir=$(pwd); cd $(ddir); tar xf $(word 1,$(filter $(tdir)/%,$^))
	cd eigen-eigen-*
	cp -r Eigen $(iidir)/eigen3 \
	&& cd $$topdir \
	&& rm -rf $(ddir)/eigen-eigen-* \
	&& echo "Eigen $(eigen-version)" > $@

$(ibidir)/expat: $(tdir)/expat-$(expat-version).tar.lz
	$(call gbuild, expat-$(expat-version), static) \
	&& echo "Expat $(expat-version)" > $@

$(ibidir)/fftw: $(tdir)/fftw-$(fftw-version).tar.gz
        # FFTW's single and double precission libraries must be built
        # independently: for the the single-precision library, we need to
        # add the `--enable-float' option. We will build this first, then
        # the default double-precision library.
	confop="--enable-shared --enable-threads --enable-avx --enable-sse2"
	$(call gbuild, fftw-$(fftw-version), static, \
	               $$confop --enable-float) \
	&& $(call gbuild, fftw-$(fftw-version), static, \
	               $$confop) \
	&& cp $(dtexdir)/fftw.tex $(ictdir)/ \
	&& echo "FFTW $(fftw-version) \citep{fftw}" > $@

# Freetype is necessary to install matplotlib
$(ibidir)/freetype: $(ibidir)/libpng \
                    $(tdir)/freetype-$(freetype-version).tar.gz
	$(call gbuild, freetype-$(freetype-version), static) \
	&& echo "FreeType $(freetype-version)" > $@

$(ibidir)/gsl: $(tdir)/gsl-$(gsl-version).tar.gz
	$(call gbuild, gsl-$(gsl-version), static) \
	&& echo "GNU Scientific Library $(gsl-version)" > $@

$(ibidir)/hdf5: $(ibidir)/openmpi \
                $(tdir)/hdf5-$(hdf5-version).tar.gz
	export CC=mpicc; \
	export FC=mpif90; \
	$(call gbuild, hdf5-$(hdf5-version), static, \
	               --enable-parallel \
	               --enable-fortran, -j$(numthreads) V=1) \
	&& echo "HDF5 library $(hdf5-version)" > $@

# HEALPix includes the source of its C, C++, Python (and several other
# languages) libraries within one tarball. We will include the Python
# installation only when any other Python module is requested (in
# `TARGETS.conf').
#
# Note that the default `./configure' script is an interactive script which
# is hard to automate. So we need to go into the `autotools' directory of
# the `C' and `cxx' directories and configure the GNU Build System (with
# `autoreconf', which uses `autoconf' and `automake') to easily build the
# HEALPix C/C++ libraries in batch mode.
ifeq ($(strip $(top-level-python)),)
healpix-python-dep =
else
healpix-python-dep = $(ipydir)/matplotlib $(ipydir)/astropy
endif
$(ibidir)/healpix: $(ibidir)/cfitsio \
                   $(ibidir)/autoconf \
                   $(ibidir)/automake \
                   $(healpix-python-dep) \
                   $(tdir)/healpix-$(healpix-version).tar.gz
	if [ x"$(healpix-python-dep)" = x ]; then
	   pycommand1="echo no-healpy-because-no-other-python"
	   pycommand2="echo no-healpy-because-no-other-python"
	else
	   pycommand1="python setup.py build"
	   pycommand2="python setup.py install"
	fi
	rm -rf $(ddir)/Healpix_$(healpix-version)
	topdir=$(pwd); cd $(ddir);
	tar xf $(word 1,$(filter $(tdir)/%,$^))
	&& cd Healpix_$(healpix-version)/src/C/autotools/ \
	&& autoreconf --install \
	&& ./configure --prefix=$(idir) \
	&& make V=1 -j$(numthreads) SHELL=$(ibdir)/bash \
	&& make install \
	&& cd ../../cxx/autotools/ \
	&& autoreconf --install \
	&& ./configure --prefix=$(idir) \
	&& make V=1 -j$(numthreads) SHELL=$(ibdir)/bash \
	&& make install \
	&& cd ../../healpy \
	&& $$pycommand1 \
	&& $$pycommand2 \
	&& cd $$topdir \
	&& rm -rf $(ddir)/Healpix_$(healpix-version) \
	&& cp $(dtexdir)/healpix.tex $(ictdir)/ \
	&& echo "HEALPix $(healpix-version) \citep{healpix}" > $@

$(ibidir)/libjpeg: $(tdir)/jpegsrc.$(libjpeg-version).tar.gz
	$(call gbuild, jpeg-9b, static,,V=1) \
	&& echo "Libjpeg $(libjpeg-version)" > $@

$(ibidir)/libnsl: $(ibidir)/libtirpc \
                  $(ibidir)/rpcsvc-proto \
                  $(tdir)/libnsl-$(libnsl-version).tar.gz
	$(call gbuild, libnsl-$(libnsl-version), static, \
	               --sysconfdir=$(idir)/etc) \
	&& echo "Libnsl $(libnsl-version)" > $@

$(ibidir)/libpng: $(tdir)/libpng-$(libpng-version).tar.xz
	$(call gbuild, libpng-$(libpng-version), static) \
	&& echo "Libpng $(libpng-version)" > $@

$(ibidir)/libtiff: $(ibidir)/libjpeg \
                   $(tdir)/tiff-$(libtiff-version).tar.gz
	$(call gbuild, tiff-$(libtiff-version), static, \
	               --disable-jbig \
	               --disable-webp \
	               --disable-zstd) \
	&& echo "Libtiff $(libtiff-version)" > $@

$(ibidir)/libtirpc: $(tdir)/libtirpc-$(libtirpc-version).tar.bz2
	$(call gbuild, libtirpc-$(libtirpc-version), static, \
	               --disable-gssapi, V=1) \
	echo "libtirpc $(libtirpc-version)" > $@

$(ibidir)/libxml2: | $(tdir)/libxml2-$(libxml2-version).tar.gz
       # The libxml2 tarball also contains Python bindings which are built and
       # installed to a system directory by default. If you don't need the Python
       # bindings, the easiest solution is to compile without Python support:
       # ./configure --without-python
       # If you really need the Python bindings, try the
       # --with-python-install-dir=DIR option
	$(call gbuild, libxml2-$(libxml2-version), static, \
	               --without-python)                       \
	&& echo "Libxml2 $(libxml2-version)" > $@

$(ibidir)/openblas: $(tdir)/openblas-$(openblas-version).tar.gz
	if [ x$(on_mac_os) = xyes ]; then \
	  export CC=clang; \
	fi; \
	cd $(ddir) \
	&& tar xf $(word 1,$(filter $(tdir)/%,$^)) \
	&& cd OpenBLAS-$(openblas-version) \
	&& make \
	&& make PREFIX=$(idir) install \
	&& cd .. \
	&& rm -rf OpenBLAS-$(openblas-version) \
	&& echo "OpenBLAS $(openblas-version)" > $@

$(ibidir)/openmpi: $(tdir)/openmpi-$(openmpi-version).tar.gz
	$(call gbuild, openmpi-$(openmpi-version), static, , \
	               -j$(numthreads) V=1) \
	&& echo "Open MPI $(openmpi-version)" > $@

# IMPORTANT NOTE: The build instructions for OpenSSH are defined here, but
# it is best that it not be prerequisite of any program and thus not built
# within the project because of all the security issues it may cause. Only
# enable/build it in a project with caution, and if there is no other
# solution (for example to disable SSH in a program that may ask for it.
$(ibidir)/openssh: $(tdir)/openssh-$(openssh-version).tar.gz
	$(call gbuild, openssh-$(openssh-version), static, \
	               --with-privsep-path=$(ibdir)/.ssh_privsep \
	               --with-privsep-user=nobody \
	               --with-md5-passwords \
	               --with-ssl-engine \
	               , -j$(numthreads) V=1) \
	&& echo "OpenSSH $(openssh-version)" > $@

$(ibidir)/pixman: $(tdir)/pixman-$(pixman-version).tar.gz
	$(call gbuild, pixman-$(pixman-version), static, , \
	                   -j$(numthreads) V=1) \
	&& echo "Pixman $(pixman-version)" > $@

$(ibidir)/rpcsvc-proto: $(tdir)/rpcsvc-proto-$(rpcsvc-proto-version).tar.xz
	$(call gbuild, rpcsvc-proto-$(rpcsvc-proto-version), static) \
	&& echo "rpcsvc $(rpcsvc-proto-version)" > $@

$(ibidir)/tides: $(tdir)/tides-$(tides-version).tar.gz
	$(call gbuild, tides-$(tides-version), static,\
	               --with-gmp=$(idir) --with-mpfr=$(idir)) \
	&& cp $(dtexdir)/tides.tex $(ictdir)/ \
	&& echo "TIDES $(tides-version) \citep{tides}" > $@

$(ibidir)/yaml: $(tdir)/yaml-$(yaml-version).tar.gz
	$(call gbuild, yaml-$(yaml-version), static) \
	&& echo "LibYAML $(yaml-version)" > $@





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
# On macOS system, `libgit2' complains about not finding `_iconv*'
# functions! But apparently `libgit2' has its own implementation of libiconv
# that it uses if it can't find libiconv on macOS. So, to fix this problem
# it is necessary to use the option `-DUSE_ICONV=OFF` in the configure step.
$(ibidir)/libgit2: $(ibidir)/curl \
                   $(ibidir)/cmake \
                   $(tdir)/libgit2-$(libgit2-version).tar.gz
	$(call cbuild, libgit2-$(libgit2-version), static, \
	              -DUSE_SSH=OFF -DBUILD_CLAR=OFF \
	              -DTHREADSAFE=ON -DUSE_ICONV=OFF ) \
	&& if [ x$(on_mac_os) = xyes ]; then \
	     install_name_tool -id $(ildir)/libgit2.28.dylib \
	                           $(ildir)/libgit2.28.dylib; \
	   fi \
	&& echo "Libgit2 $(libgit2-version)" > $@

$(ibidir)/wcslib: $(ibidir)/cfitsio \
                  $(tdir)/wcslib-$(wcslib-version).tar.bz2
	$(call gbuild, wcslib-$(wcslib-version), , \
	               LIBS="-pthread -lcurl -lm" \
                       --with-cfitsiolib=$(ildir) \
                       --with-cfitsioinc=$(idir)/include \
                       --without-pgplot) \
	&& if [ x$(on_mac_os) = xyes ]; then \
	     install_name_tool -id $(ildir)/libwcs.6.4.dylib \
	                           $(ildir)/libwcs.6.4.dylib; \
	   fi \
	&& echo "WCSLIB $(wcslib-version)" > $@










# Programs
# --------
#
# Astrometry-net contains a lot of programs. We need to specify the
# installation directory and the Python executable (by default it will look
# for /usr/bin/python)
$(ibidir)/astrometrynet: $(ibidir)/gsl \
                         $(ibidir)/swig \
                         $(ipydir)/numpy \
                         $(ibidir)/cairo \
                         $(ibidir)/libpng \
                         $(ibidir)/netpbm \
                         $(ibidir)/wcslib \
                         $(ibidir)/cfitsio \
                         $(ibidir)/libjpeg \
                         $(tdir)/astrometry.net-$(astrometrynet-version).tar.gz
        # We are modifying the Makefile in two steps because on Mac OS
        # system we do not have `/proc/cpuinfo' nor `free'. Since this is
        # only for the `report.txt', this changes do not causes problems in
        # running `astrometrynet'
	cd $(ddir) \
	&& rm -rf astrometry.net-$(astrometrynet-version) \
	&& if ! tar xf $(word 1,$(filter $(tdir)/%,$^)); then \
	      echo; echo "Tar error"; exit 1; \
	   fi \
	&& cd astrometry.net-$(astrometrynet-version) \
	&& sed -e 's|cat /proc/cpuinfo|echo "Ignoring CPU info"|' \
	       -e 's|-free|echo "Ignoring RAM info"|' Makefile > Makefile.tmp \
	&& mv Makefile.tmp Makefile \
	&& make \
	&& make py \
	&& make extra \
	&& make install INSTALL_DIR=$(idir) PYTHON_SCRIPT="$(ibdir)/python" \
	&& cd .. \
	&& rm -rf astrometry.net-$(astrometrynet-version) \
	&& cp $(dtexdir)/astrometrynet.tex $(ictdir)/ \
	&& echo "Astrometry.net $(astrometrynet-version) \citep{astrometrynet}" > $@

$(ibidir)/autoconf: $(tdir)/autoconf-$(autoconf-version).tar.lz
	$(call gbuild, autoconf-$(autoconf-version), static, ,V=1) \
	&& echo "GNU Autoconf $(autoconf-version)" > $@

$(ibidir)/automake: $(ibidir)/autoconf \
                    $(tdir)/automake-$(automake-version).tar.gz
	$(call gbuild, automake-$(automake-version), static, ,V=1) \
	&& echo "GNU Automake $(automake-version)" > $@

$(ibidir)/bison: $(ibidir)/help2man \
                 $(tdir)/bison-$(bison-version).tar.xz
	$(call gbuild, bison-$(bison-version), static, ,V=1) \
	&& echo "GNU Bison $(bison-version)" > $@

# cdsclient is a set of software written in c to interact with astronomical
# database servers. It is a dependency of `scamp' to be able to download
# reference catalogues.
# NOTE: we do not use a convencional `gbuild' installation because the
# programs are scripts and we need to touch them before installing.
# Otherwise this software will be re-built each time the configure step is
# invoked.
$(ibidir)/cdsclient: $(tdir)/cdsclient-$(cdsclient-version).tar.gz
	cd $(ddir) \
	&& tar xf $(word 1,$(filter $(tdir)/%,$^)) \
	&& cd cdsclient-$(cdsclient-version) \
	&& touch * \
	&& ./configure --prefix=$(idir) \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -rf cdsclient-$(cdsclient-version) \
	&& echo "cdsclient $(cdsclient-version)" > $@

# CMake can be built with its custom `./bootstrap' script.
$(ibidir)/cmake: $(ibidir)/curl \
                 $(tdir)/cmake-$(cmake-version).tar.gz
        # After searching in `bootstrap', I couldn't find `LIBS', only
        # `LDFLAGS'. So the extra libraries are being added to `LDFLAGS',
        # not `LIBS'.
        #
        # On Mac systems, the build complains about `clang' specific
        # features, so we can't use our own GCC build here.
	if [ x$(on_mac_os) = xyes ]; then \
	  export CC=clang; \
	  export CXX=clang++; \
	fi; \
	cd $(ddir) \
	&& rm -rf cmake-$(cmake-version) \
	&& tar xf $(word 1,$(filter $(tdir)/%,$^)) \
	&& cd cmake-$(cmake-version) \
	&& ./bootstrap --prefix=$(idir) --system-curl --system-zlib \
	               --system-bzip2 --system-liblzma --no-qt-gui \
	               --parallel=$(numthreads) \
	&& make -j$(numthreads) LIBS="$$LIBS -lssl -lcrypto -lz" VERBOSE=1  \
	&& make install \
	&& cd .. \
	&& rm -rf cmake-$(cmake-version) \
	&& echo "CMake $(cmake-version)" > $@

$(ibidir)/flex: $(ibidir)/bison \
                $(tdir)/flex-$(flex-version).tar.gz
	$(call gbuild, flex-$(flex-version), static, ,V=1) \
	&& echo "Flex $(flex-version)" > $@

$(ibidir)/gdb: $(ibidir)/python \
               $(tdir)/gdb-$(gdb-version).tar.gz
	$(call gbuild, gdb-$(gdb-version),,,V=1) \
	&& echo "GNU Project Debugger (GDB) $(gdb-version)" > $@

$(ibidir)/ghostscript: $(ibidir)/libpng \
                       $(ibidir)/libtiff \
                       $(tdir)/ghostscript-$(ghostscript-version).tar.gz
        # First we need to make sure some necessary X11 libraries that we
        # don't yet install in this template are present on the host
        # system, see https://savannah.nongnu.org/task/?15481 .
        # Adding `-L/opt/X11/lib' to LDFLAGS is necessary for macOS systems
        # because X11 libraries used to be installed there.
	echo;
	echo "Template: testing necessary X11 libraries for ghostscript"
	echo "---------------------------------------------------------"
	oprog=$(ddir)/libXext-test-for-ghostscript
	cprog=$(ddir)/libXext-test-for-ghostscript.c
	echo "#include <stdio.h>"          > $$cprog
	echo "int main(void) {return 0;}" >> $$cprog
	export LDFLAGS="$$LDFLAGS -L/opt/X11/lib"
	if $$CC $$LDFLAGS $$cprog -o$$oprog -lXt -lSM -lICE -lXext; then
	  echo "Necessary X11 libraries are present. Proceeding to the build."
	  rm $$cprog $$oprog
	else
	  rm $$cprog
	  echo ""
	  echo "Problem in building Ghostscript"
	  echo "-------------------------------"
	  echo "Some necessary X11 libraries (that we don't yet install"
	  echo "within the template) couldn't be found on your system, see"
	  echo "the 'ld' error message above. Please install them manually"
	  echo "so Ghostscript can be built."
	  echo
	  echo "For example if you use Debian-based OSs, run this command:"
	  echo "  sudo apt install libxext-dev libxt-dev libsm-dev libice-dev ghostscript"
	  echo ""
	  echo "This notice will be removed once these packages are built"
	  echo "within the project (Task #15481)."
	  echo "-------------------------------"
	  exit 1
	fi

        # If they were present, go onto building Ghostscript.
	$(call gbuild, ghostscript-$(ghostscript-version)) \
	&& echo "GPL Ghostscript $(ghostscript-version)" > $@

$(ibidir)/gnuastro: $(ibidir)/gsl \
                    $(ibidir)/wcslib \
                    $(ibidir)/libjpeg \
                    $(ibidir)/libtiff \
                    $(ibidir)/libgit2 \
                    $(ibidir)/ghostscript \
                    $(tdir)/gnuastro-$(gnuastro-version).tar.lz
ifeq ($(static_build),yes)
	staticopts="--enable-static=yes --enable-shared=no";
endif
	$(call gbuild, gnuastro-$(gnuastro-version), static, \
	               $$staticopts, -j$(numthreads)) \
	&& cp $(dtexdir)/gnuastro.tex $(ictdir)/ \
	&& echo "GNU Astronomy Utilities $(gnuastro-version) \citep{gnuastro}" > $@

$(ibidir)/help2man: $(tdir)/help2man-$(help2man-version).tar.xz
	$(call gbuild, help2man-$(help2man-version), static, ,V=1) \
	&& echo "Help2man $(Help2man-version)" > $@

$(ibidir)/imagemagick: $(ibidir)/zlib \
                       $(ibidir)/libjpeg \
                       $(ibidir)/libtiff \
                       $(tdir)/imagemagick-$(imagemagick-version).tar.xz
	$(call gbuild, ImageMagick-$(imagemagick-version), static, \
		       --without-x --disable-openmp, V=1 -j$(numthreads)) \
	&& echo "ImageMagick $(imagemagick-version)" > $@

# `imfit' doesn't use the traditional `configure' and `make' to install
# itself.  Instead of that, it uses `scons'. As a consequence, the
# installation is manually done by decompressing the tarball, and running
# `scons' with the necessary flags. Despite of that, it is necessary to
# replace the default searching paths in this script by our installation
# paths. This is done with `sed', replacing each ocurrence of `/usr/local'
# by `$(idir)'. After that, each compiled program (`imfit', `imfit-mcmc'
# and `makeimage') is copied into the installation directory and an `rpath'
# is added.
$(ibidir)/imfit: $(ibidir)/gsl \
                 $(ibidir)/fftw \
                 $(ibidir)/scons \
                 $(ibidir)/cfitsio \
                 $(tdir)/imfit-$(imfit-version).tar.gz
	cd $(ddir) \
	&& unpackdir=imfit-$(imfit-version) \
	&& rm -rf $$unpackdir \
	&& if ! tar xf $(word 1,$(filter $(tdir)/%,$^)); then \
	      echo; echo "Tar error"; exit 1; \
	   fi \
	&& cd $$unpackdir \
	&& sed -i 's|/usr/local|$(idir)|g' SConstruct \
	&& sed -i 's|/usr/include|$(idir)/include|g' SConstruct \
	&& sed -i 's|.append(|.insert(0,|g' SConstruct \
	&& scons --no-openmp  --no-nlopt \
	         --cc=$(ibdir)/gcc --cpp=$(ibdir)/g++ \
	         --header-path=$(idir)/include --lib-path=$(idir)/lib imfit \
	&& cp imfit $(ibdir) \
	&& scons --no-openmp  --no-nlopt\
	         --cc=$(ibdir)/gcc --cpp=$(ibdir)/g++ \
	         --header-path=$(idir)/include --lib-path=$(idir)/lib \
                 imfit-mcmc \
	&& cp imfit-mcmc $(ibdir) \
	&& scons --no-openmp  --no-nlopt\
	         --cc=$(ibdir)/gcc --cpp=$(ibdir)/g++ \
	         --header-path=$(idir)/include --lib-path=$(idir)/lib \
                 makeimage \
	&& cp makeimage $(ibdir) \
	&& cp $(dtexdir)/imfit.tex $(ictdir)/ \
	&& if [ "x$(on_mac_os)" != xyes ]; then \
	     for p in imfit imfit-mcmc makeimage; do \
	         patchelf --set-rpath $(ildir) $(ibdir)/$$p; \
	     done; \
	   fi \
	&& echo "Imfit $(imfit-version) \citep{imfit2015}" > $@

# Minizip 1.x is actually distributed within zlib. It doesn't have its own
# independent tarball. So we need a custom build, which include the GNU
# Autotools (Autoconf and Automake). Note that Minizip 2.x isn't like this
# any more and has its own independent tarball, but currently the programs
# that depend on Minizip need Minizip 1.x. The instructions to build
# minizip were taken from ArchLinux.
#
# About deleting the final crypt.h file after installation, see
# https://bugzilla.redhat.com/show_bug.cgi?id=1424609
$(ibidir)/minizip: $(ibidir)/automake \
                   $(tdir)/zlib-$(zlib-version).tar.gz
	cd $(ddir) \
	&& unpackdir=minizip-$(minizip-version) \
	&& rm -rf $$unpackdir \
	&& mkdir $$unpackdir \
	&& if ! tar xf $(word 1,$(filter $(tdir)/%,$^)) \
	            -C$$unpackdir --strip-components=1; then \
	      echo; echo "Tar error"; exit 1; \
	   fi \
	&& cd $$unpackdir\
	&& ./configure --prefix=$(idir) \
	&& make \
	&& cd contrib/minizip \
	&& cp Makefile Makefile.orig \
	&& cp ../README.contrib readme.txt \
	&& autoreconf --install \
	&& ./configure --prefix=$(idir) \
	&& make \
	&& cd ../../ \
	&& make test \
	&& cd contrib/minizip \
	&& make -f Makefile.orig test \
	&& make install \
	&& rm $(iidir)/minizip/crypt.h \
	&& cd ../../.. \
	&& rm -rf $$unpackdir \
	&& echo "Minizip $(minizip-version)" > $@

$(ibidir)/missfits: $(tdir)/missfits-$(missfits-version).tar.gz
	$(call gbuild, missfits-$(missfits-version), static) \
	&& cp $(dtexdir)/missfits.tex $(ictdir)/ \
	&& echo "MissFITS $(missfits-version) \citep{missfits}" > $@

# Netpbm is a prerequisite of Astrometry-net, it contains a lot of programs.
# This program has a crazy dialogue installation which is override using the
# printf statment. Each `\n' is a new question that the installation process
# ask to the user. We give all answers with a pipe to the scripts (configure
# and install). The questions are different depending on the system (tested
# on GNU/Linux and Mac OS).
$(ibidir)/netpbm: $(ibidir)/unzip \
                  $(ibidir)/libpng \
                  $(ibidir)/libjpeg \
                  $(ibidir)/libtiff \
                  $(ibidir)/libxml2 \
                  $(tdir)/netpbm-$(netpbm-version).tar.gz
	if [ x$(on_mac_os) = xyes ]; then \
	  answers='\n\n$(ildir)\n\n\n\n\n\n$(ildir)/include\n\n$(ildir)/include\n\n$(ildir)/include\nnone\n\n'; \
	else \
	  answers='\n\n\n\n\n\n\n\n\n\n\n\n\nnone\n\n\n'; \
	fi; \
	cd $(ddir) \
	&& unpackdir=netpbm-$(netpbm-version) \
	&& rm -rf $$unpackdir \
	&& if ! tar xf $(word 1,$(filter $(tdir)/%,$^)); then \
	      echo; echo "Tar error"; exit 1; \
	   fi \
	&& cd $$unpackdir \
	&& printf "$$answers" | ./configure \
	&& make \
	&& rm -rf $(ddir)/$$unpackdir/install \
	&& make package pkgdir=$(ddir)/$$unpackdir/install \
	&& printf "$(ddir)/$$unpackdir/install\n$(idir)\n\n\nN\n\n\n\n\nN\n\n" \
	          | ./installnetpbm \
	&& cd .. \
	&& rm -rf $$unpackdir \
	&& echo "Netpbm $(netpbm-version)" > $@

# R programming language
$(ibidir)/R: $(ibidir)/libpng \
             $(ibidir)/libjpeg \
             $(ibidir)/libtiff \
             $(tdir)/R-$(R-version).tar.gz
	export R_SHELL=$(SHELL); \
	$(call gbuild, R-$(R-version), static, \
                       --without-x --with-readline \
	               --disable-openmp) \
	&& echo "R $(R-version)" > $@

# SCAMP documentation says ATLAS is a mandatory prerequisite for using
# SCAMP. We have ATLAS into the project but there are some problems with the
# libraries that are not yet solved. However, we tried to install it with
# the option --enable-openblas and it worked (same issue happened with
# `sextractor'.
$(ibidir)/scamp: $(ibidir)/fftw \
                 $(ibidir)/openblas \
                 $(ibidir)/cdsclient \
                 $(tdir)/scamp-$(scamp-version).tar.lz
	$(call gbuild, scamp-$(scamp-version), static, \
                   --enable-threads --enable-openblas \
                   --with-fftw-libdir=$(idir) \
                   --with-fftw-incdir=$(idir)/include \
                   --with-openblas-libdir=$(ildir) \
                   --with-openblas-incdir=$(idir)/include) \
	&& cp $(dtexdir)/scamp.tex $(ictdir)/ \
	&& echo "SCAMP $(scamp-version) \citep{scamp}" > $@

# Since `scons' doesn't use the traditional GNU installation with
# `configure' and `make' it is installed manually using `python'.
$(ibidir)/scons: $(ibidir)/python \
                 $(tdir)/scons-$(scons-version).tar.gz
	cd $(ddir) \
	&& unpackdir=scons-$(scons-version) \
	&& rm -rf $$unpackdir \
	&& if ! tar xf $(word 1,$(filter $(tdir)/%,$^)); then \
	      echo; echo "Tar error"; exit 1; \
	   fi \
	&& cd $$unpackdir \
	&& python setup.py install \
	&& echo "SCons $(scons-version)" > $@

# Sextractor crashes complaining about not linking with some ATLAS
# libraries. But we can override this issue since we have Openblas
# installed, it is just necessary to explicity tell sextractor to use it in
# the configuration step.
$(ibidir)/sextractor: $(ibidir)/fftw \
                      $(ibidir)/openblas \
                      $(tdir)/sextractor-$(sextractor-version).tar.lz
	$(call gbuild, sextractor-$(sextractor-version), static, \
	               --enable-threads --enable-openblas \
	               --with-openblas-libdir=$(ildir) \
	               --with-openblas-incdir=$(idir)/include) \
	&& ln -fs $(ibdir)/sex $(ibdir)/sextractor \
	&& cp $(dtexdir)/sextractor.tex $(ictdir)/ \
	&& echo "SExtractor $(sextractor-version) \citep{sextractor}" > $@

$(ibidir)/swarp: $(ibidir)/fftw \
                 $(tdir)/swarp-$(swarp-version).tar.gz
	$(call gbuild, swarp-$(swarp-version), static, \
                       --enable-threads) \
	&& cp $(dtexdir)/swarp.tex $(ictdir)/ \
	&& echo "SWarp $(swarp-version) \citep{swarp}" > $@

$(ibidir)/swig: $(tdir)/swig-$(swig-version).tar.gz
        # Option --without-pcre was a suggestion once the configure step
        # was tried and it failed. It was not recommended but it works!
        # pcr is a dependency of swig
	$(call gbuild, swig-$(swig-version), static, --without-pcre) \
	&& echo "Swig $(swig-version)" > $@

$(ibidir)/xlsxio: $(ibidir)/cmake \
                  $(ibidir)/expat \
                  $(ibidir)/minizip \
                  $(tdir)/xlsxio-$(xlsxio-version).tar.gz
	if [ x$(on_mac_os) = xyes ]; then \
	  export CC=clang; \
	  export CXX=clang++; \
	  export LDFLAGS="-lbz2"; \
	else \
	  export LDFLAGS="-lbz2 -lbsd"; \
	fi; \
	$(call cbuild, xlsxio-$(xlsxio-version), static, \
	       -DMINIZIP_DIR:PATH=$(idir) \
	       -DMINIZIP_LIBRARIES=$(idir) \
	       -DMINIZIP_INCLUDE_DIRS=$(iidir)) \
	&& echo "Correcting internal linking of XLSX I/O executables..." \
	&& if [ "x$(on_mac_os)" = xyes ]; then \
	     for f in $(ibdir)/xlsxio_* $(ildir)/libxlsxio_*.dylib; do \
	       install_name_tool -change  libxlsxio_read.dylib \
	                         $(ildir)/libxlsxio_read.dylib $$f; \
	       install_name_tool -change  libxlsxio_write.dylib \
	                         $(ildir)/libxlsxio_write.dylib $$f; \
	     done; \
	   else \
	     for f in $(ibdir)/xlsxio_* $(ildir)/libxlsxio_*.so; do \
	       patchelf --set-rpath $(ildir) $$f; \
	     done; \
	   fi \
	&& echo "Deleting XLSX I/O example files..." \
	&& rm $(ibdir)/example_xlsxio_* \
	&& echo "XLSX I/O $(xlsxio-version)" > $@








# Since we want to avoid complicating the PATH, we are putting a symbolic
# link of all the TeX Live executables in $(ibdir). But symbolic links are
# hard to track for Make (as a target). Also, TeX in general is optional
# for the project (the processing is the main target, not the generation of
# the final PDF). So we'll make a simple ASCII file called
# `texlive-ready-tlmgr' and use its contents to mark if we can use it or
# not.

# TeX Live mirror
# ---------------
#
# The automatic mirror finding fails sometimes. So we'll manually set it to
# use a fixed mirror. I first tried the LaTeX root webpage
# (`ftp.dante.de'), however, it is far too slow (when I tested it). The
# `rit.edu' server seems to be a good alternative (given the importance of
# NY on the internet infrastructure).
tlmirror=http://mirrors.rit.edu/CTAN/systems/texlive/tlnet

# The core TeX Live system.
$(itidir)/texlive-ready-tlmgr: reproduce/software/config/texlive.conf \
                               $(tdir)/install-tl-unx.tar.gz

        # Unpack, enter the directory, and install based on the given
        # configuration (prerequisite of this rule).
	@topdir=$$(pwd)
	cd $(ddir)
	rm -rf install-tl-*
	tar xf $(tdir)/install-tl-unx.tar.gz
	cd install-tl-*
	sed -e's|@installdir[@]|$(idir)|g' \
	    $$topdir/reproduce/software/config/texlive.conf \
	    > texlive.conf

        # TeX Live's installation may fail due to any reason. But TeX Live
        # is optional (only necessary for building the final PDF). So we
        # don't want the configure script to fail if it can't run.
	if ./install-tl --profile=texlive.conf -repository $(tlmirror); then

          # Put a symbolic link of the TeX Live executables in `ibdir' to
          # avoid all the complexities of its sub-directories and additions
          # to PATH.
	  ln -fs $(idir)/texlive/maneage/bin/*/* $(ibdir)/

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
#
# Note that Biber needs to link with libraries like libnsl. However, we
# don't currently build biber from source. So we can't choose the library
# version. But we have the source and build instructions for the `nsl'
# library. When we later build biber from source, we can easily use them.
#
#ifeq ($(on_mac_os),yes)
#forbiber =
#else
#forbiber = $(ibidir)/libnsl
#endif
$(itidir)/texlive: reproduce/software/config/texlive-packages.conf \
                   $(itidir)/texlive-ready-tlmgr \
                   $(forbiber)

        # To work with TeX live installation, we'll need the internet.
	@res=$$(cat $(itidir)/texlive-ready-tlmgr)
	if [ x"$$res" = x"NOT!" ]; then
	  echo "" > $@
	else
          # To update itself, tlmgr needs a backup directory.
	  backupdir=$(idir)/texlive/backups
	  mkdir -p $$backupdir

          # Before checking LaTeX packages, update tlmgr itself.
	  tlmgr option backupdir $$backupdir
	  tlmgr -repository $(tlmirror) update --self

          # Install all the extra necessary packages. If LaTeX complains
          # about not finding a command/file/what-ever/XXXXXX, simply run
          # the following command to find which package its in, then add it
          # to the `texlive-packages' variable of the first prerequisite.
          #
          #     ./.local/bin/tlmgr info XXXXXX
          #
          # We are putting a notice, because if there is no internet,
          # `tlmgr' just hangs waiting.
	  tlmgr install $(texlive-packages)

          # Make a symbolic link of all the TeX Live executables in the bin
          # directory so we don't have to modify `PATH'.
	  ln -fs $(idir)/texlive/maneage/bin/*/* $(ibdir)/

          # Get all the necessary versions.
	  texlive=$$(pdflatex --version \
	                      | awk 'NR==1' \
	                      | sed 's/.*(\(.*\))/\1/' \
	                      | awk '{print $$NF}');

          # Package names and versions. Note that all TeXLive packages
          # don't have a version unfortunately! So we need to also read the
          # `revision' and `cat-date' elements and print them incase
          # version isn't available.
	  tlmgr info $(texlive-packages) --only-installed | awk \
	       '$$1=="package:" { \
	           if(name!=0) \
	             {  \
	               if(version=="") \
	                 { \
	                   if(revision=="") \
	                     { \
	                       if(date="") printf("%s (no version)\n", name); \
	                       else printf("%s %s (date)\n", name, date); \
	                     } \
	                   else
	                     printf("%s %s (revision)\n", name, revision); \
	                 } \
	               else \
	                 printf("%s %s\n", name, version); \
	             } \
	           name=""; version=""; revision=""; date=""; \
	           if($$NF=="tex-gyre") name="texgyre"; \
	           else                 name=$$NF \
	        } \
	        $$1=="cat-date:"    {date=$$NF} \
	        $$1=="cat-version:" {version=$$NF} \
	        $$1=="revision:"    {revision=$$NF}' > $@
	fi
