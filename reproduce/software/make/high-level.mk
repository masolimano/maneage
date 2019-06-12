# Build the project's dependencies (programs and libraries).
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
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
include reproduce/software/config/installation/TARGETS.mk
include reproduce/software/config/installation/texlive.mk
include reproduce/software/config/installation/versions.mk

lockdir = $(BDIR)/locks
tdir    = $(BDIR)/software/tarballs
ddir    = $(BDIR)/software/build-tmp
idir    = $(BDIR)/software/installed
ibdir   = $(BDIR)/software/installed/bin
ildir   = $(BDIR)/software/installed/lib
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


# We want the download to happen on a single thread. So we need to define a
# lock, and call a special script we have written for this job. These are
# placed here because we want them both in the `high-level.mk' and
# `python.mk'.
$(lockdir): | $(BDIR); mkdir $@
downloader="wget --no-use-server-timestamps -O";
downloadwrapper = ./reproduce/analysis/bash/download-multi-try





# Python packages
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
tarballs = $(foreach t, astrometry.net-$(astrometrynet-version).tar.gz \
                        atlas-$(atlas-version).tar.bz2 \
                        cairo-$(cairo-version).tar.xz \
                        cdsclient-$(cdsclient-version).tar.gz \
                        cfitsio-$(cfitsio-version).tar.gz \
                        cmake-$(cmake-version).tar.gz \
                        freetype-$(freetype-version).tar.gz \
                        fftw-$(fftw-version).tar.gz \
                        ghostscript-$(ghostscript-version).tar.gz \
                        gnuastro-$(gnuastro-version).tar.lz \
                        gsl-$(gsl-version).tar.gz \
                        hdf5-$(hdf5-version).tar.gz \
                        imagemagick-$(imagemagick-version).tar.xz \
                        imfit-$(imfit-version).tar.gz \
                        install-tl-unx.tar.gz \
                        jpegsrc.$(libjpeg-version).tar.gz \
                        lapack-$(lapack-version).tar.gz \
                        libpng-$(libpng-version).tar.xz \
                        libgit2-$(libgit2-version).tar.gz \
                        libxml2-$(libxml2-version).tar.gz \
                        netpbm-$(netpbm-version).tar.gz \
                        openmpi-$(openmpi-version).tar.gz \
                        openblas-$(openblas-version).tar.gz \
                        pixman-$(pixman-version).tar.gz \
                        scamp-$(scamp-version).tar.lz \
                        scons-$(scons-version).tar.gz \
                        sextractor-$(sextractor-version).tar.lz \
                        swarp-$(swarp-version).tar.gz \
                        swig-$(swig-version).tar.gz \
                        tiff-$(libtiff-version).tar.gz \
                        wcslib-$(wcslib-version).tar.bz2 \
                        yaml-$(yaml-version).tar.gz \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%: | $(lockdir)
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then
	  cp $(DEPENDENCIES-DIR)/$* $@
	else
	  # Remove all numbers, `-' and `.' from the tarball name so we can
	  # search more easily only with the program name.
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g' -e's/\./ /g' \
	               | awk '{print $$1}' )

	  # Set the top download link of the requested tarball.
	  mergenames=1
	  if   [ $$n = astrometry  ]; then w=http://astrometry.net/downloads
	  elif [ $$n = atlas       ]; then
	    mergenames=0
	    w=https://sourceforge.net/projects/math-atlas/files/Stable/$(atlas-version)/atlas$(atlas-version).tar.bz2/download
	  elif [ $$n = cairo       ]; then w=https://www.cairographics.org/releases
	  elif [ $$n = cdsclient   ]; then w=http://cdsarc.u-strasbg.fr/ftp/pub/sw
	  elif [ $$n = cfitsio     ]; then w=https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c
	  elif [ $$n = cmake       ]; then
	    mergenames=0
	    majv=$$(echo $(cmake-version) \
	                 | sed -e's/\./ /' \
	                 | awk '{printf("%d.%d", $$1, $$2)}')
	    w=https://cmake.org/files/v$$majv/cmake-$(cmake-version).tar.gz
	  elif [ $$n = fftw        ]; then w=ftp://ftp.fftw.org/pub/fftw
	  elif [ $$n = freetype    ]; then w=https://download.savannah.gnu.org/releases/freetype
	  elif [ $$n = hdf         ]; then
	    mergenames=0
	    majorver=$$(echo $(hdf5-version) | sed -e 's/\./ /g' | awk '{printf("%d.%d", $$1, $$2)}')
	    w=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$$majorver/hdf5-$(hdf5-version)/src/$*
	  elif [ $$n = ghostscript ]; then w=https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs926
	  elif [ $$n = gnuastro    ]; then w=http://ftp.gnu.org/gnu/gnuastro
	  elif [ $$n = gsl         ]; then w=http://ftp.gnu.org/gnu/gsl
	  elif [ $$n = imagemagick ]; then
	    mergenames=0
	    w=https://www.imagemagick.org/download/releases/ImageMagick-$(imagemagick-version).tar.xz
	  elif [ $$n = imfit       ]; then
	    mergenames=0
	    w=http://www.mpe.mpg.de/~erwin/resources/imfit/imfit-$(imfit-version)-source.tar.gz
	  elif [ $$n = install     ]; then w=http://mirror.ctan.org/systems/texlive/tlnet
	  elif [ $$n = jpegsrc     ]; then w=http://ijg.org/files
	  elif [ $$n = lapack      ]; then w=http://www.netlib.org/lapack
	  elif [ $$n = libpng      ]; then w=https://download.sourceforge.net/libpng
	  elif [ $$n = libgit      ]; then
	    mergenames=0
	    w=https://github.com/libgit2/libgit2/archive/v$(libgit2-version).tar.gz
	  elif [ $$n = libxml      ]; then w=ftp://xmlsoft.org/libxml2
	  elif [ $$n = netpbm      ]; then w=http://akhlaghi.org/src
	  elif [ $$n = openblas    ]; then
	    mergenames=0
	    w=https://github.com/xianyi/OpenBLAS/archive/v$(openblas-version).tar.gz
	  elif [ $$n = openmpi     ]; then
	    mergenames=0
	    majorver=$$(echo $(openmpi-version) | sed -e 's/\./ /g' | awk '{printf("%d.%d", $$1, $$2)}')
	    w=https://download.open-mpi.org/release/open-mpi/v$$majorver/$*
	  elif [ $$n = pixman      ]; then w=https://www.cairographics.org/releases
	  elif [ $$n = scamp       ]; then w=http://akhlaghi.org/src
	  elif [ $$n = scons       ]; then
	    mergenames=0
	    w=https://sourceforge.net/projects/scons/files/scons/$(scons-version)/scons-$(scons-version).tar.gz/download
	  elif [ $$n = sextractor  ]; then w=http://akhlaghi.org/src
	  elif [ $$n = swarp       ]; then w=https://www.astromatic.net/download/swarp
	  elif [ $$n = swig        ]; then w=https://sourceforge.net/projects/swig/files/swig/swig-$(swig-version)
	  elif [ $$n = tiff        ]; then w=https://download.osgeo.org/libtiff
	  elif [ $$n = wcslib      ]; then w=ftp://ftp.atnf.csiro.au/pub/software/wcslib
	  elif [ $$n = yaml        ]; then w=pyyaml.org/download/libyaml
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

          # Download using the script specially defined for this job.
	  touch $(lockdir)/download
	  downloader="wget --no-use-server-timestamps -O"
	  $(downloadwrapper) "$$downloader" $(lockdir)/download \
	                     $$tarballurl $@
	fi





# Libraries
# ---------
#
# We would prefer to build static libraries, but some compilers like LLVM
# don't have static capabilities, so they'll only build dynamic/shared
# libraries. Therefore, we can't use the easy `.a' suffix for static
# libraries as targets and there are different conventions for shared
# library names.
$(ibidir)/cfitsio: $(tdir)/cfitsio-$(cfitsio-version).tar.gz \
                   $(ibidir)/curl

        # CFITSIO hard-codes '@rpath' inside the shared library on
        # Mac systems. So we need to change it to our library
        # installation path. It doesn't affect GNU/Linux, so we'll
        # just do it in any case to keep things clean.
	topdir=$(pwd); cd $(ddir); tar xf $<
	customtar=cfitsio-$(cfitsio-version)-custom.tar.gz
	cd cfitsio-$(cfitsio-version)
	sed configure -e's|@rpath|$(ildir)|g' > configure_tmp
	mv configure_tmp configure
	chmod +x configure
	cd ..
	tar cf $$customtar cfitsio-$(cfitsio-version)
	cd $$topdir

        # Continue the standard build on the customized tarball.
	$(call gbuild, $$customtar, cfitsio-$(cfitsio-version), , \
	               --enable-sse2 --enable-reentrant \
	               --with-bzip2=$(idir), , make shared) \
	&& rm $$customtar \
	&& echo "CFITSIO $(cfitsio-version)" > $@

$(ibidir)/cairo: $(tdir)/cairo-$(cairo-version).tar.xz \
                 $(ibidir)/freetype \
                 $(ibidir)/libpng \
                 $(ibidir)/pixman
	$(call gbuild, $<, cairo-$(cairo-version), static, \
	               --with-x=no) \
	&& echo "Cairo $(cairo-version)" > $@

$(ibidir)/gsl: $(tdir)/gsl-$(gsl-version).tar.gz
	$(call gbuild, $<, gsl-$(gsl-version), static) \
	&& echo "GNU Scientific Library $(gsl-version)" > $@

$(ibidir)/fftw: $(tdir)/fftw-$(fftw-version).tar.gz
        # In order to build single and double precission libraries of
        # `fftw', installation of `fftw' is done twice. First time is to
        # build single precission float libraries and second time is for
        # building the default double precission float libraries
	$(call gbuild, $<, fftw-$(fftw-version), static, \
	               --enable-shared enable-threads \
		       --enable-single --enable-type-prefix) \
	&& $(call gbuild, $<, fftw-$(fftw-version), static, \
	               --enable-shared --enable-threads \
		       --enable-type-prefix) \
	&& cp $(dtexdir)/fftw.tex $(ictdir)/ \
	&& echo "FFTW $(fftw-version) \citep{fftw}" > $@

# Freetype is necessary to install matplotlib
$(ibidir)/freetype: $(tdir)/freetype-$(freetype-version).tar.gz \
	                $(ibidir)/libpng
	$(call gbuild, $<, freetype-$(freetype-version), static) \
	&& echo "FreeType $(freetype-version)" > $@

$(ibidir)/hdf5: $(tdir)/hdf5-$(hdf5-version).tar.gz  \
                $(ibidir)/openmpi
	export CC=mpicc; \
	export FC=mpif90; \
	$(call gbuild, $<, hdf5-$(hdf5-version), static, \
	               --enable-parallel \
	               --enable-fortran, -j$(numthreads) V=1) \
	&& echo "HDF5 library $(hdf5-version)" > $@

$(ibidir)/libjpeg: $(tdir)/jpegsrc.$(libjpeg-version).tar.gz
	$(call gbuild, $<, jpeg-9b, static) \
	&& echo "Libjpeg $(libjpeg-version)" > $@

$(ibidir)/libpng: $(tdir)/libpng-$(libpng-version).tar.xz
	$(call gbuild, $<, libpng-$(libpng-version), static) \
	&& echo "Libpng $(libpng-version)" > $@

$(ibidir)/libxml2: $(tdir)/libxml2-$(libxml2-version).tar.gz
       # The libxml2 tarball also contains Python bindings which are built and
       # installed to a system directory by default. If you don't need the Python
       # bindings, the easiest solution is to compile without Python support:
       # ./configure --without-python
       # If you really need the Python bindings, try the
       # --with-python-install-dir=DIR option
	$(call gbuild, $<, libxml2-$(libxml2-version), static, \
	               --without-python)                       \
	&& echo "Libxml2 $(libxml2-version)" > $@

$(ibidir)/pixman: $(tdir)/pixman-$(pixman-version).tar.gz
	$(call gbuild, $<, pixman-$(pixman-version), static) \
	&& echo "Pixman $(pixman-version)" > $@

$(ibidir)/libtiff: $(tdir)/tiff-$(libtiff-version).tar.gz \
                   $(ibidir)/libjpeg
	$(call gbuild, $<, tiff-$(libtiff-version), static, \
	               --disable-webp --disable-zstd) \
	&& echo "Libtiff $(libtiff-version)" > $@

$(ibidir)/openmpi: $(tdir)/openmpi-$(openmpi-version).tar.gz
	$(call gbuild, $<, openmpi-$(openmpi-version), static, , \
	               -j$(numthreads) V=1) \
	&& echo "Open MPI $(openmpi-version)" > $@

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
	&& tar xf $< \
	&& cd ATLAS \
	&& rm -rf build \
	&& mkdir build \
	&& cd build \
	&& ../configure -b 64 -D c -DPentiumCPS=$$core \
	             --with-netlib-lapack-tarfile=$(word 2, $^) \
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

$(ibidir)/openblas: $(tdir)/openblas-$(openblas-version).tar.gz
	if [ x$(on_mac_os) = xyes ]; then \
	  export CC=clang; \
	fi; \
	cd $(ddir) \
	&& tar xf $< \
	&& cd OpenBLAS-$(openblas-version) \
	&& make \
	&& make PREFIX=$(idir) install \
	&& cd .. \
	&& rm -rf OpenBLAS-$(openblas-version) \
	&& echo "OpenBLAS $(openblas-version)" > $@

$(ibidir)/yaml: $(tdir)/yaml-$(yaml-version).tar.gz
	$(call gbuild, $<, yaml-$(yaml-version), static) \
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
$(ibidir)/libgit2: $(tdir)/libgit2-$(libgit2-version).tar.gz \
                   $(ibidir)/cmake \
                   $(ibidir)/curl
        # Build and install the library.
	$(call cbuild, $<, libgit2-$(libgit2-version), static, \
	              -DUSE_SSH=OFF -DBUILD_CLAR=OFF \
	              -DTHREADSAFE=ON )

        # Correct the shared library absolute address on Mac systems.
	if [ x$(on_mac_os) = xyes ]; then
	  install_name_tool -id $(ildir)/libgit2.26.dylib \
	                        $(ildir)/libgit2.26.dylib
	fi

        # Write the target file.
	echo "Libgit2 $(libgit2-version)" > $@

$(ibidir)/wcslib: $(tdir)/wcslib-$(wcslib-version).tar.bz2 \
                  $(ibidir)/cfitsio
        # Build and install the library.
	$(call gbuild, $<, wcslib-$(wcslib-version), , \
	               LIBS="-pthread -lcurl -lm" \
                       --with-cfitsiolib=$(ildir) \
                       --with-cfitsioinc=$(idir)/include \
                       --without-pgplot --disable-fortran)

        # Correct the shared library absolute address if necessary.
	if [ x$(on_mac_os) = xyes ]; then
	  install_name_tool -id $(ildir)/libwcs.6.2.dylib \
	                        $(ildir)/libwcs.6.2.dylib;
	fi

        # Write the target file.
	echo "WCSLIB $(wcslib-version)" > $@





# Programs
# --------
#
# Astrometry-net contains a lot of programs. We need to specify the
# installation directory and the Python executable (by default it will look
# for /usr/bin/python)
$(ibidir)/astrometrynet: $(tdir)/astrometry.net-$(astrometrynet-version).tar.gz \
                         $(ibidir)/cfitsio \
                         $(ibidir)/libjpeg \
                         $(ibidir)/libpng \
                         $(ibidir)/netpbm \
                         $(ibidir)/python \
                         $(ibidir)/wcslib \
                         $(ibidir)/cairo \
                         $(ipydir)/numpy \
                         $(ibidir)/swig \
                         $(ibidir)/gsl
        # We are modifying the Makefile in two steps because on Mac OS
        # system we do not have `/proc/cpuinfo' nor `free'. Since this is
        # only for the `report.txt', this changes do not causes problems in
        # running `astrometrynet'
	cd $(ddir) \
	&& rm -rf astrometry.net-$(astrometrynet-version) \
	&& if ! tar xf $<; then echo; echo "Tar error"; exit 1; fi \
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

# cdsclient is a set of software written in c to interact with astronomical
# database servers. It is a dependency of `scamp' to be able to download
# reference catalogues.
# NOTE: we do not use a convencional `gbuild' installation because the
# programs are scripts and we need to touch them before installing.
# Otherwise this software will be re-built each time the configure step is
# invoked.
$(ibidir)/cdsclient: $(tdir)/cdsclient-$(cdsclient-version).tar.gz
	cd $(ddir) \
	&& tar xf $< \
	&& cd cdsclient-$(cdsclient-version) \
	&& touch * \
	&& ./configure --prefix=$(idir) \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -rf cdsclient-$(cdsclient-version) \
	&& echo "cdsclient $(cdsclient-version)" > $@

# CMake can be built with its custom `./bootstrap' script.
$(ibidir)/cmake: $(tdir)/cmake-$(cmake-version).tar.gz \
                 $(ibidir)/curl
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
	&& tar xf $< \
	&& cd cmake-$(cmake-version) \
	&& ./bootstrap --prefix=$(idir) --system-curl --system-zlib \
	               --system-bzip2 --system-liblzma --no-qt-gui \
	&& make -j$(numthreads) LIBS="$$LIBS -lssl -lcrypto -lz" VERBOSE=1  \
	&& make install \
	&& cd .. \
	&& rm -rf cmake-$(cmake-version) \
	&& echo "CMake $(cmake-version)" > $@

$(ibidir)/ghostscript: $(tdir)/ghostscript-$(ghostscript-version).tar.gz
	$(call gbuild, $<, ghostscript-$(ghostscript-version)) \
	&& echo "GPL Ghostscript $(ghostscript-version)" > $@

# The order of dependencies is based on how long they take to build (how
# large they are): Libgit2 depends on CMake which takes a VERY long time to
# build. Also, Ghostscript and GSL are relatively large packages. So when
# building in parallel, its better to have these packages start building
# early.
$(ibidir)/gnuastro: $(tdir)/gnuastro-$(gnuastro-version).tar.lz \
                    $(ibidir)/ghostscript \
                    $(ibidir)/libjpeg \
                    $(ibidir)/libtiff \
                    $(ibidir)/libgit2 \
                    $(ibidir)/wcslib \
                    $(ibidir)/gsl
ifeq ($(static_build),yes)
	staticopts="--enable-static=yes --enable-shared=no";
endif
	$(call gbuild, $<, gnuastro-$(gnuastro-version), static, \
	               $$staticopts, -j$(numthreads), \
	               make check -j$(numthreads)) \
	&& cp $(dtexdir)/gnuastro.tex $(ictdir)/ \
	&& echo "GNU Astronomy Utilities $(gnuastro-version) \citep{gnuastro}" > $@

$(ibidir)/imagemagick: $(tdir)/imagemagick-$(imagemagick-version).tar.xz \
                       $(ibidir)/libjpeg \
                       $(ibidir)/libtiff \
                       $(ibidir)/zlib
	$(call gbuild, $<, ImageMagick-$(imagemagick-version), static, \
		       --without-x --disable-openmp, V=1) \
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
$(ibidir)/imfit: $(tdir)/imfit-$(imfit-version).tar.gz \
                 $(ibidir)/cfitsio \
                 $(ibidir)/scons \
                 $(ibidir)/fftw \
                 $(ibidir)/gsl
	cd $(ddir) \
	&& unpackdir=imfit-$(imfit-version) \
	&& rm -rf $$unpackdir \
	&& if ! tar xf $<; then echo; echo "Tar error"; exit 1; fi \
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

# Netpbm is a prerequisite of Astrometry-net, it contains a lot of programs.
# This program has a crazy dialogue installation which is override using the
# printf statment. Each `\n' is a new question that the installation process
# ask to the user. We give all answers with a pipe to the scripts (configure
# and install). The questions are different depending on the system (tested
# on GNU/Linux and Mac OS).
$(ibidir)/netpbm: $(tdir)/netpbm-$(netpbm-version).tar.gz \
                  $(ibidir)/libjpeg \
                  $(ibidir)/libtiff \
                  $(ibidir)/libxml2 \
                  $(ibidir)/libpng \
                  $(ibidir)/unzip
	if [ x$(on_mac_os) = xyes ]; then \
	  answers='\n\n$(ildir)\n\n\n\n\n\n$(ildir)/include\n\n$(ildir)/include\n\n$(ildir)/include\nnone\n\n'; \
	else \
	  answers='\n\n\n\n\n\n\n\n\n\n\n\n\nnone\n\n\n'; \
	fi; \
	cd $(ddir) \
	&& unpackdir=netpbm-$(netpbm-version) \
	&& rm -rf $$unpackdir \
	&& if ! tar xf $<; then echo; echo "Tar error"; exit 1; fi \
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

# SCAMP documentation says ATLAS is a mandatory prerequisite for using
# SCAMP. We have ATLAS into the project but there are some problems with the
# libraries that are not yet solved. However, we tried to install it with
# the option --enable-openblas and it worked (same issue happened with
# `sextractor'.
$(ibidir)/scamp: $(tdir)/scamp-$(scamp-version).tar.lz \
                 $(ibidir)/cdsclient \
                 $(ibidir)/openblas \
                 $(ibidir)/fftw
	$(call gbuild, $<, scamp-$(scamp-version), static, \
                   --enable-threads --enable-openblas \
                   --with-fftw-libdir=$(idir) \
                   --with-fftw-incdir=$(idir)/include \
                   --with-openblas-libdir=$(ildir) \
                   --with-openblas-incdir=$(idir)/include) \
	&& cp $(dtexdir)/scamp.tex $(ictdir)/ \
	&& echo "SCAMP $(scamp-version) \citep{scamp}" > $@

# Since `scons' doesn't use the traditional GNU installation with
# `configure' and `make' it is installed manually using `python'.
$(ibidir)/scons: $(tdir)/scons-$(scons-version).tar.gz \
                 $(ibidir)/python
	cd $(ddir) \
	&& unpackdir=scons-$(scons-version) \
	&& rm -rf $$unpackdir \
	&& if ! tar xf $<; then echo; echo "Tar error"; exit 1; fi \
	&& cd $$unpackdir \
	&& python setup.py install \
	&& echo "SCons $(scons-version)" > $@

# Sextractor crashes complaining about not linking with some ATLAS
# libraries. But we can override this issue since we have Openblas
# installed, it is just necessary to explicity tell sextractor to use it in
# the configuration step.
$(ibidir)/sextractor: $(tdir)/sextractor-$(sextractor-version).tar.lz \
                      $(ibidir)/openblas \
                      $(ibidir)/fftw
	$(call gbuild, $<, sextractor-$(sextractor-version), static, \
	               --enable-threads --enable-openblas \
	               --with-openblas-libdir=$(ildir) \
	               --with-openblas-incdir=$(idir)/include) \
	&& ln -fs $(ibdir)/sex $(ibdir)/sextractor \
	&& cp $(dtexdir)/sextractor.tex $(ictdir)/ \
	&& echo "Sextractor $(sextractor-version) \citep{sextractor}" > $@

$(ibidir)/swarp: $(tdir)/swarp-$(swarp-version).tar.gz \
                 $(ibidir)/fftw
	$(call gbuild, $<, swarp-$(swarp-version), static, \
                       --enable-threads) \
	&& cp $(dtexdir)/swarp.tex $(ictdir)/ \
	&& echo "SWarp $(swarp-version) \citep{swarp}" > $@

$(ibidir)/swig: $(tdir)/swig-$(swig-version).tar.gz
        # Option --without-pcre was a suggestion once the configure step
        # was tried and it failed. It was not recommended but it works!
        # pcr is a dependency of swig
	$(call gbuild, $<, swig-$(swig-version), static, --without-pcre) \
	&& echo "Swig $(swig-version)" > $@









# Since we want to avoid complicating the PATH, we are putting a symbolic
# link of all the TeX Live executables in $(ibdir). But symbolic links are
# hard to track for Make (as a target). Also, TeX in general is optional
# for the project (the processing is the main target, not the generation of
# the final PDF). So we'll make a simple ASCII file called
# `texlive-ready-tlmgr' and use its contents to mark if we can use it or
# not.
$(itidir)/texlive-ready-tlmgr: $(tdir)/install-tl-unx.tar.gz \
                    reproduce/software/config/installation/texlive.conf

        # Unpack, enter the directory, and install based on the given
        # configuration (prerequisite of this rule).
	@topdir=$$(pwd)
	cd $(ddir)
	rm -rf install-tl-*
	tar xf $(tdir)/install-tl-unx.tar.gz
	cd install-tl-*
	sed -e's|@installdir[@]|$(idir)|g' \
	    $$topdir/reproduce/software/config/installation/texlive.conf \
	    > texlive.conf

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
$(itidir)/texlive: reproduce/software/config/installation/texlive.mk \
                   $(itidir)/texlive-ready-tlmgr

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
	  tlmgr update --self

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
	  ln -fs $(idir)/texlive/20*/bin/*/* $(ibdir)/

          # Get all the necessary versions.
	  texlive=$$(pdflatex --version | awk 'NR==1' | sed 's/.*(\(.*\))/\1/' \
	                      | awk '{print $$NF}');

          # Package names and versions.
	  rm -f $@
	  tlmgr info $(texlive-packages) --only-installed | awk \
	       '$$1=="package:" {version=0; \
	                         if($$NF=="tex-gyre") name="texgyre"; \
	                         else                 name=$$NF} \
	        $$1=="cat-version:" {version=$$NF} \
	        $$1=="cat-date:" {if(version==0) version=$$2; \
	                          printf("%s %s\n", name, version)}' >> $@
	fi
