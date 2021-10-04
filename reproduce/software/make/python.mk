# Build the project's Python dependencies.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be loaded into 'high-level.mk', which is called by the
# './project configure' script. It is not included into the project
# afterwards.
#
# This Makefile contains instructions to build all the Python-related
# software within the project.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2019-2022 Raul Infante-Sainz <infantesainz@gmail.com>
# Copyright (C) 2019-2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# Python enviroment
# -----------------
#
# The main Python environment variable is 'PYTHONPATH'. However, so far we
# have found several other Python-related environment variables on some
# systems which might interfere. To be safe, we are removing all their
# values.
export PYTHONPATH             := $(idir)/lib/python/site-packages
export PYTHONPATH2            := $(PYTHONPATH)
export PYTHONPATH3            := $(PYTHONPATH)
export _LMFILES_              :=
export LOADEDMODULES          :=
export MPI_PYTHON_SITEARCH    :=
export MPI_PYTHON2_SITEARCH   :=
export MPI_PYTHON3_SITEARCH   :=

# Python-specific installation directories.
python-major-version = $(shell echo $(python-version) | awk 'BEGIN{FS="."} \
	                            {printf "%d.%d\n", $$1, $$2}')





# Necessary programs and libraries
# --------------------------------
#
# While this Makefile is for Python programs, in some cases, we need
# certain programs (like Python itself), or libraries for the modules.
$(ibidir)/libffi-$(libffi-version):

#	Prepare the source.
	tarball=libffi-$(libffi-version).tar.lz
	$(call import-source, $(libffi-url), $(libffi-checksum))

#	Build libffi.
	$(call gbuild, libffi-$(libffi-version), , \
                       CFLAGS="-DNO_JAVA_RAW_API=1")

#	On some Fedora systems, libffi installs in 'lib64', not 'lib'. This
#	will cause problems when building setuptools later. To fix this
#	problem, we'll first check if this has indeed happened (it exists
#	under 'lib64', but not under 'lib'). If so, we'll put a copy of the
#	installed libffi libraries in 'lib'.
	if [ -f $(idir)/lib64/libffi.a ] && ! [ -f $(idir)/lib/libffi.a ]; then
	  cp $(idir)/lib64/libffi* $(ildir)/
	fi
	echo "Libffi $(libffi-version)" > $@

$(ibidir)/python-$(python-version): $(ibidir)/libffi-$(libffi-version)

#	Download the source.
	tarball=python-$(python-version).tar.lz
	$(call import-source, $(python-url), $(python-checksum))

#	On Mac systems, the build complains about 'clang' specific
#	features, so we can't use our own GCC build here.
	if [ x$(on_mac_os) = xyes ]; then
	  export CC=clang
	  export CXX=clang++
	fi
	$(call gbuild, python-$(python-version),, \
	       --without-ensurepip \
	       --with-system-ffi \
	       --enable-shared, -j$(numthreads))
	ln -sf $(ildir)/python$(python-major-version)  $(ildir)/python
	ln -sf $(ibdir)/python$(python-major-version)  $(ibdir)/python
	ln -sf $(iidir)/python$(python-major-version)m $(iidir)/python$(python-major-version)
	rm -rf $(ipydir)
	mkdir $(ipydir)
	echo "Python $(python-version)" > $@





# Non-PiP Python module installation
# ----------------------------------
#
# To build Python packages with direct access to a 'setup.py' (if no direct
# access to 'setup.py' is needed, pip can be used). Note that the
# software's packaged source code is the first prerequisite that is in the
# 'tdir' directory.
#
# Arguments of this function are the numbers
#   1) Unpack command
#   2) Unpacked directory name after unpacking the tarball
#   3) site.cfg file (optional).
#   4) Official software name (for paper).
#
# Hooks:
#   pyhook_before: optional steps before running 'python setup.py build'
#   pyhook_after: optional steps after running 'python setup.py install'
pybuild = cd $(ddir); rm -rf $(2); \
	if ! $(1) $(tdir)/$$tarball; then \
	  echo; echo "Tar error"; exit 1; \
	fi; \
	cd $(2); \
	if [ "x$(strip $(3))" != x ]; then \
	  sed -e 's|@LIBDIR[@]|'"$(ildir)"'|' \
	      -e 's|@INCDIR[@]|'"$(idir)/include"'|' \
	      $(3) > site.cfg; \
	fi; \
	if type pyhook_before &>/dev/null; then pyhook_before; fi; \
	python setup.py build; \
	python setup.py install; \
	if type pyhook_after &>/dev/null; then pyhook_after; fi; \
	cd ..; \
	rm -rf $(2); \
	echo "$(4)" > $@





# Python modules
# ---------------
#
# All the necessary Python modules go here.
$(ipydir)/asn1crypto-$(asn1crypto-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=asn1crypto-$(asn1crypto-version).tar.gz
	$(call import-source, $(asn1crypto-url), $(asn1crypto-checksum))
	$(call pybuild, tar -xf, asn1crypto-$(asn1crypto-version), , \
	                Asn1crypto $(asn1crypto-version))

$(ipydir)/asteval-$(asteval-version): $(ipydir)/numpy-$(numpy-version)
	tarball=asteval-$(asteval-version).tar.gz
	$(call import-source, $(asteval-url), $(asteval-checksum))
	$(call pybuild, tar -xf, asteval-$(asteval-version), , \
	                ASTEVAL $(asteval-version))

$(ipydir)/astroquery-$(astroquery-version): \
                     $(ipydir)/astropy-$(astropy-version) \
                     $(ipydir)/keyring-$(keyring-version) \
                     $(ipydir)/requests-$(requests-version)
	tarball=astroquery-$(astroquery-version).tar.gz
	$(call import-source, $(astroquery-url), $(astroquery-checksum))
	$(call pybuild, tar -xf, astroquery-$(astroquery-version), , \
	                Astroquery $(astroquery-version))

$(ipydir)/astropy-$(astropy-version): \
                  $(ipydir)/h5py-$(h5py-version) \
                  $(ibidir)/expat-$(expat-version) \
                  $(ipydir)/scipy-$(scipy-version) \
                  $(ipydir)/numpy-$(numpy-version) \
                  $(ipydir)/pyyaml-$(pyyaml-version) \
                  $(ipydir)/jinja2-$(jinja2-version) \
                  $(ipydir)/pyerfa-$(pyerfa-version) \
                  $(ipydir)/html5lib-$(html5lib-version) \
                  $(ipydir)/beautifulsoup4-$(beautifulsoup4-version) \
                  $(ipydir)/extension-helpers-$(extension-helpers-version)
	tarball=astropy-$(astropy-version).tar.lz
	$(call import-source, $(astropy-url), $(astropy-checksum))
	$(call pybuild, tar -xf, astropy-$(astropy-version))
	cp $(dtexdir)/astropy.tex $(ictdir)/
	echo "Astropy $(astropy-version) \citep{astropy2013,astropy2018}" > $@

$(ipydir)/beautifulsoup4-$(beautifulsoup4-version): \
                         $(ipydir)/soupsieve-$(soupsieve-version)
	tarball=beautifulsoup4-$(beautifulsoup4-version).tar.lz
	$(call import-source, $(beautifulsoup4-url), $(beautifulsoup4-checksum))
	$(call pybuild, tar -xf, beautifulsoup4-$(beautifulsoup4-version), , \
	                BeautifulSoup $(beautifulsoup4-version))

$(ipydir)/beniget-$(beniget-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=beniget-$(beniget-version).tar.lz
	$(call import-source, $(beniget-url), $(beniget-checksum))
	$(call pybuild, tar -xf, beniget-$(beniget-version), , \
	                Beniget $(beniget-version))

$(ipydir)/certifi-$(certifi-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=certifi-$(certifi-version).tar.gz
	$(call import-source, $(certifi-url), $(certifi-checksum))
	$(call pybuild, tar -xf, certifi-$(certifi-version), , \
	                Certifi $(certifi-version))

$(ipydir)/cffi-$(cffi-version): \
               $(ibidir)/libffi-$(libffi-version) \
               $(ipydir)/pycparser-$(pycparser-version)
	tarball=cffi-$(cffi-version).tar.lz
	$(call import-source, $(cffi-url), $(cffi-checksum))
	$(call pybuild, tar -xf, cffi-$(cffi-version), ,cffi $(cffi-version))

$(ipydir)/chardet-$(chardet-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=chardet-$(chardet-version).tar.gz
	$(call import-source, $(chardet-url), $(chardet-checksum))
	$(call pybuild, tar -xf, chardet-$(chardet-version), , \
	                Chardet $(chardet-version))

$(ipydir)/corner-$(corner-version): $(ipydir)/matplotlib-$(matplotlib-version)
	tarball=corner-$(corner-version).tar.gz
	$(call import-source, $(corner-url), $(corner-checksum))
	$(call pybuild, tar -xf, corner-$(corner-version), , \
	                Corner $(corner-version))
	cp $(dtexdir)/corner.tex $(ictdir)/
	echo "Corner $(corner-version) \citep{corner}" > $@

$(ipydir)/cryptography-$(cryptography-version): \
                       $(ipydir)/cffi-$(cffi-version) \
                       $(ipydir)/asn1crypto-$(asn1crypto-version) \
                       $(ipydir)/setuptools-rust-$(setuptools-rust-version)
	tarball=cryptography-$(cryptography-version).tar.lz
	$(call import-source, $(cryptography-url), $(cryptography-checksum))
	$(call pybuild, tar -xf, cryptography-$(cryptography-version), , \
	                Cryptography $(cryptography-version))

$(ipydir)/cycler-$(cycler-version): $(ipydir)/six-$(six-version)
	tarball=cycler-$(cycler-version).tar.lz
	$(call import-source, $(cycler-url), $(cycler-checksum))
	$(call pybuild, tar -xf, cycler-$(cycler-version), , \
	                Cycler $(cycler-version))

$(ipydir)/cython-$(cython-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=Cython-$(cython-version).tar.lz
	$(call import-source, $(cython-url), $(cython-checksum))
	$(call pybuild, tar -xf, Cython-$(cython-version))
	cp $(dtexdir)/cython.tex $(ictdir)/
	echo "Cython $(cython-version) \citep{cython2011}" > $@

$(ipydir)/esutil-$(esutil-version): $(ipydir)/numpy-$(numpy-version)
	export CFLAGS="-std=c++14 $$CFLAGS"
	tarball=esutil-$(esutil-version).tar.lz
	$(call import-source, $(esutil-url), $(esutil-checksum))
	$(call pybuild, tar -xf, esutil-$(esutil-version), , \
	                esutil $(esutil-version))

$(ipydir)/eigency-$(eigency-version): \
                  $(ipydir)/numpy-$(numpy-version) \
                  $(ibidir)/eigen-$(eigen-version) \
                  $(ipydir)/cython-$(cython-version)
	tarball=eigency-$(eigency-version).tar.gz
	$(call import-source, $(eigency-url), $(eigency-checksum))
	$(call pybuild, tar -xf, eigency-$(eigency-version), , \
	                eigency $(eigency-version))

$(ipydir)/emcee-$(emcee-version): \
                $(ipydir)/numpy-$(numpy-version) \
                $(ipydir)/setuptools_scm-$(setuptools_scm-version)
	tarball=emcee-$(emcee-version).tar.gz
	$(call import-source, $(emcee-url), $(emcee-checksum))
	$(call pybuild, tar -xf, emcee-$(emcee-version), , \
	                emcee $(emcee-version))

$(ipydir)/entrypoints-$(entrypoints-version): \
                      $(ipydir)/setuptools-$(setuptools-version)
	tarball=entrypoints-$(entrypoints-version).tar.gz
	$(call import-source, $(entrypoints-url), $(entrypoints-checksum))
	$(call pybuild, tar -xf, entrypoints-$(entrypoints-version), , \
	                EntryPoints $(entrypoints-version))

$(ipydir)/extension-helpers-$(extension-helpers-version): \
                    $(ipydir)/setuptools-$(setuptools-version)
	tarball=extension-helpers-$(extension-helpers-version).tar.lz
	$(call import-source, $(extension-helpers-url), $(extension-helpers-checksum))
	$(call pybuild, tar -xf, extension-helpers-$(extension-helpers-version), , \
	                Extension-Helpers $(extension-helpers-version))

$(ipydir)/flake8-$(flake8-version): \
                 $(ipydir)/pyflakes-$(pyflakes-version) \
                 $(ipydir)/pycodestyle-$(pycodestyle-version)
	tarball=flake8-$(flake8-version).tar.gz
	$(call import-source, $(flake8-url), $(flake8-checksum))
	$(call pybuild, tar -xf, flake8-$(flake8-version), , \
	                Flake8 $(flake8-version))

$(ipydir)/future-$(future-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=future-$(future-version).tar.gz
	$(call import-source, $(future-url), $(future-checksum))
	$(call pybuild, tar -xf, future-$(future-version), , \
	                Future $(future-version))

$(ipydir)/galsim-$(galsim-version): \
                 $(ipydir)/future-$(future-version) \
                 $(ipydir)/astropy-$(astropy-version) \
                 $(ipydir)/eigency-$(eigency-version) \
                 $(ipydir)/pybind11-$(pybind11-version) \
                 $(ipydir)/lsstdesccoord-$(lsstdesccoord-version)
	tarball=galsim-$(galsim-version).tar.lz
	$(call import-source, $(galsim-url), $(galsim-checksum))
	$(call pybuild, tar -xf, galsim-$(galsim-version))
	cp $(dtexdir)/galsim.tex $(ictdir)/
	echo "Galsim $(galsim-version) \citep{galsim}" > $@

$(ipydir)/gast-$(gast-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=gast-$(gast-version).tar.lz
	$(call import-source, $(gast-url), $(gast-checksum))
	$(call pybuild, tar -xf, gast-$(gast-version), , \
	                Gast $(gast-version))

$(ipydir)/h5py-$(h5py-version): \
               $(ipydir)/six-$(six-version) \
               $(ibidir)/hdf5-$(hdf5-version) \
               $(ipydir)/numpy-$(numpy-version) \
               $(ipydir)/cython-$(cython-version) \
               $(ipydir)/mpi4py-$(mpi4py-version) \
               $(ipydir)/pypkgconfig-$(pypkgconfig-version)
	export HDF5_MPI=ON
	export HDF5_DIR=$(ildir)
	tarball=h5py-$(h5py-version).tar.gz
	$(call import-source, $(h5py-url), $(h5py-checksum))
	$(call pybuild, tar -xf, h5py-$(h5py-version), , \
	                h5py $(h5py-version))

# 'healpy' is actually installed as part of the HEALPix package. It will be
# installed with its C/C++ libraries if any other Python library is
# requested with HEALPix. So actually calling for 'healpix' (when 'healpix'
# is requested) is not necessary. But some users might not know about this
# and just ask for 'healpy'. To avoid confusion in such cases, we'll just
# set 'healpy' to be dependent on 'healpix' and not download any tarball
# for it, or write anything in the final target.
$(ipydir)/healpy-$(healpy-version): $(ibidir)/healpix-$(healpix-version)
	touch $@

$(ipydir)/html5lib-$(html5lib-version): \
                   $(ipydir)/six-$(six-version) \
                   $(ipydir)/webencodings-$(webencodings-version)
	tarball=html5lib-$(html5lib-version).tar.gz
	$(call import-source, $(html5lib-url), $(html5lib-checksum))
	$(call pybuild, tar -xf, html5lib-$(html5lib-version), , \
	                HTML5lib $(html5lib-version))

$(ipydir)/idna-$(idna-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=idna-$(idna-version).tar.gz
	$(call import-source, $(idna-url), $(idna-checksum))
	$(call pybuild, tar -xf, idna-$(idna-version), , \
	       idna $(idna-version))

$(ipydir)/jeepney-$(jeepney-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=jeepney-$(jeepney-version).tar.gz
	$(call import-source, $(jeepney-url), $(jeepney-checksum))
	$(call pybuild, tar -xf, jeepney-$(jeepney-version), , \
	                Jeepney $(jeepney-version))

$(ipydir)/jinja2-$(jinja2-version): $(ipydir)/markupsafe-$(markupsafe-version)
	tarball=jinja2-$(jinja2-version).tar.lz
	$(call import-source, $(jinja2-url), $(jinja2-checksum))
	$(call pybuild, tar -xf, jinja2-$(jinja2-version), , \
	                Jinja2 $(jinja2-version))

$(ipydir)/keyring-$(keyring-version): \
                  $(ipydir)/entrypoints-$(entrypoints-version) \
                  $(ipydir)/secretstorage-$(secretstorage-version) \
                  $(ipydir)/setuptools_scm-$(setuptools_scm-version)
	tarball=keyring-$(keyring-version).tar.gz
	$(call import-source, $(keyring-url), $(keyring-checksum))
	$(call pybuild, tar -xf, keyring-$(keyring-version), , \
	                Keyring $(keyring-version))

$(ipydir)/kiwisolver-$(kiwisolver-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=kiwisolver-$(kiwisolver-version).tar.lz
	$(call import-source, $(kiwisolver-url), $(kiwisolver-checksum))
	$(call pybuild, tar -xf, kiwisolver-$(kiwisolver-version), , \
	                Kiwisolver $(kiwisolver-version))

$(ipydir)/lmfit-$(lmfit-version): \
                $(ipydir)/six-$(six-version) \
                $(ipydir)/scipy-$(scipy-version) \
                $(ipydir)/emcee-$(emcee-version) \
                $(ipydir)/corner-$(corner-version) \
                $(ipydir)/asteval-$(asteval-version) \
                $(ipydir)/matplotlib-$(matplotlib-version) \
                $(ipydir)/uncertainties-$(uncertainties-version)
	tarball=lmfit-$(lmfit-version).tar.gz
	$(call import-source, $(lmfit-url), $(lmfit-checksum))
	$(call pybuild, tar -xf, lmfit-$(lmfit-version), , \
	                LMFIT $(lmfit-version))

$(ipydir)/lsstdesccoord-$(lsstdesccoord-version): \
                        $(ipydir)/cython-$(cython-version)
	tarball=lsstdesccoord-$(lsstdesccoord-version).tar.gz
	$(call import-source, $(lsstdesccoord-url), $(lsstdesccoord-checksum))
	$(call pybuild, tar -xf, LSSTDESC.Coord-$(lsstdesccoord-version), , \
	                LSSTDESC.Coord $(lsstdesccoord-version))

$(ipydir)/markupsafe-$(markupsafe-version): \
                     $(ipydir)/setuptools-$(setuptools-version)
	tarball=markupsafe-$(markupsafe-version).tar.lz
	$(call import-source, $(markupsafe-url), $(markupsafe-checksum))
	$(call pybuild, tar -xf, markupsafe-$(markupsafe-version), , \
	                MarkupSafe $(markupsafe-version))

$(ipydir)/matplotlib-$(matplotlib-version): \
                     $(itidir)/texlive \
                     $(ipydir)/numpy-$(numpy-version) \
                     $(ipydir)/cycler-$(cycler-version) \
                     $(ipydir)/pillow-$(pillow-version) \
                     $(ibidir)/freetype-$(freetype-version) \
                     $(ipydir)/pyparsing-$(pyparsing-version) \
                     $(ipydir)/kiwisolver-$(kiwisolver-version) \
                     $(ibidir)/ghostscript-$(ghostscript-version) \
                     $(ibidir)/imagemagick-$(imagemagick-version) \
                     $(ipydir)/python-dateutil-$(python-dateutil-version)

#	Prepare the source.
	tarball=matplotlib-$(matplotlib-version).tar.lz
	$(call import-source, $(matplotlib-url), $(matplotlib-checksum))

#	On Mac systems, the build complains about 'clang' specific
#	features, so we can't use our own GCC build here.
	if [ x$(on_mac_os) = xyes ]; then
	  export CC=clang
	  export CXX=clang++
	fi
	$(call pybuild, tar -xf, matplotlib-$(matplotlib-version))
	cp $(dtexdir)/matplotlib.tex $(ictdir)/
	echo "Matplotlib $(matplotlib-version) \citep{matplotlib2007}" > $@

$(ipydir)/mpi4py-$(mpi4py-version): \
                 $(ibidir)/openmpi-$(openmpi-version) \
                 $(ipydir)/setuptools-$(setuptools-version)
	tarball=mpi4py-$(mpi4py-version).tar.lz
	$(call import-source, $(mpi4py-url), $(mpi4py-checksum))
	$(call pybuild, tar -xf, mpi4py-$(mpi4py-version))
	cp $(dtexdir)/mpi4py.tex $(ictdir)/
	echo "mpi4py $(mpi4py-version) \citep{mpi4py2011}" > $@

$(ipydir)/mpmath-$(mpmath-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=mpmath-$(mpmath-version).tar.gz
	$(call import-source, $(mpmath-url), $(mpmath-checksum))
	$(call pybuild, tar -xf, mpmath-$(mpmath-version), , \
	                mpmath $(mpmath-version))

$(ipydir)/numpy-$(numpy-version): \
                $(ibidir)/unzip-$(unzip-version) \
                $(ipydir)/cython-$(cython-version) \
                $(ibidir)/openblas-$(openblas-version) \
                $(ipydir)/setuptools-$(setuptools-version)
	tarball=numpy-$(numpy-version).tar.lz
	$(call import-source, $(numpy-url), $(numpy-checksum))
	if [ x$(on_mac_os) = xyes ]; then
	  export LDFLAGS="$(LDFLAGS) -undefined dynamic_lookup -bundle"
	else
	  export LDFLAGS="$(LDFLAGS) -shared"
	fi
	export CFLAGS="--std=c99 $$CFLAGS"
	conf="$$(pwd)/reproduce/software/config/numpy-scipy.cfg"
	$(call pybuild, tar -xf, numpy-$(numpy-version),$$conf, \
	                Numpy $(numpy-version))
	cp $(dtexdir)/numpy.tex $(ictdir)/
	echo "Numpy $(numpy-version) \citep{numpy2011}" > $@

$(ipydir)/packaging-$(packaging-version): \
                    $(ipydir)/pyparsing-$(pyparsing-version)
	tarball=packaging-$(packaging-version).tar.lz
	$(call import-source, $(packaging-url), $(packaging-checksum))
	$(call pybuild, tar -xf, packaging-$(packaging-version), , \
	                Packaging $(packaging-version))

$(ipydir)/pexpect-$(pexpect-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=pexpect-$(pexpect-version).tar.gz
	$(call import-source, $(pexpect-url), $(pexpect-checksum))
	$(call pybuild, tar -xf, pexpect-$(pexpect-version), , \
	                Pexpect $(pexpect-version))

$(ipydir)/pillow-$(pillow-version): $(ibidir)/libjpeg-$(libjpeg-version) \
                 $(ipydir)/setuptools-$(setuptools-version)
	tarball=Pillow-$(pillow-version).tar.lz
	$(call import-source, $(pillow-url), $(pillow-checksum))
	$(call pybuild, tar -xf, Pillow-$(pillow-version), , \
	                Pillow $(pillow-version))

$(ipydir)/pip-$(pip-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=pip-$(pip-version).tar.gz
	$(call import-source, $(pip-url), $(pip-checksum))
	$(call pybuild, tar -xf, pip-$(pip-version), , \
	                PiP $(pip-version))

$(ipydir)/ply-$(ply-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=ply-$(ply-version).tar.lz
	$(call import-source, $(ply-url), $(ply-checksum))
	$(call pybuild, tar -xf, ply-$(ply-version), , \
	                ply $(ply-version))

$(ipydir)/pycodestyle-$(pycodestyle-version): \
                      $(ipydir)/setuptools-$(setuptools-version)
	tarball=pycodestyle-$(pycodestyle-version).tar.gz
	$(call import-source, $(pycodestyle-url), $(pycodestyle-checksum))
	$(call pybuild, tar -xf, pycodestyle-$(pycodestyle-version), , \
	                pycodestyle $(pycodestyle-version))

$(ipydir)/pybind11-$(pybind11-version): \
                   $(ibidir)/eigen-$(eigen-version) \
                   $(ibidir)/boost-$(boost-version) \
                   $(ipydir)/setuptools-$(setuptools-version)
	tarball=pybind11-$(pybind11-version).tar.gz
	$(call import-source, $(pybind11-url), $(pybind11-checksum))
	pyhook_after() {
	  cp -r include/pybind11 $(iidir)/python$(python-major-version)m/
	}
	$(call pybuild, tar -xf, pybind11-$(pybind11-version), , \
	                pybind11 $(pybind11-version))

$(ipydir)/pycparser-$(pycparser-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=pycparser-$(pycparser-version).tar.gz
	$(call import-source, $(pycparser-url), $(pycparser-checksum))
	$(call pybuild, tar -xf, pycparser-$(pycparser-version), , \
	                pycparser $(pycparser-version))

$(ipydir)/pyerfa-$(pyerfa-version): \
                 $(ipydir)/numpy-$(numpy-version) \
                 $(ipydir)/packaging-$(packaging-version)
	tarball=pyerfa-$(pyerfa-version).tar.lz
	$(call import-source, $(pyerfa-url), $(pyerfa-checksum))
	$(call pybuild, tar -xf, pyerfa-$(pyerfa-version), , \
	                PyERFA $(pyerfa-version))

$(ipydir)/pyflakes-$(pyflakes-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=pyflakes-$(pyflakes-version).tar.gz
	$(call import-source, $(pyflakes-url), $(pyflakes-checksum))
	$(call pybuild, tar -xf, pyflakes-$(pyflakes-version), , \
	                pyflakes $(pyflakes-version))

$(ipydir)/pyparsing-$(pyparsing-version): \
                    $(ipydir)/setuptools-$(setuptools-version)
	tarball=pyparsing-$(pyparsing-version).tar.lz
	$(call import-source, $(pyparsing-url), $(pyparsing-checksum))
	$(call pybuild, tar -xf, pyparsing-$(pyparsing-version), , \
	                PyParsing $(pyparsing-version))

$(ipydir)/pypkgconfig-$(pypkgconfig-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=pkgconfig-$(pypkgconfig-version).tar.gz
	$(call import-source, $(pypkgconfig-url), $(pypkgconfig-checksum))
	$(call pybuild, tar -xf, pkgconfig-$(pypkgconfig-version), ,
	                pkgconfig $(pypkgconfig-version))

$(ipydir)/python-dateutil-$(python-dateutil-version): \
                          $(ipydir)/six-$(six-version) \
                          $(ipydir)/setuptools_scm-$(setuptools_scm-version)
	tarball=python-dateutil-$(python-dateutil-version).tar.gz
	$(call import-source, $(python-dateutil-url), $(python-dateutil-checksum))
	$(call pybuild, tar -xf, python-dateutil-$(python-dateutil-version), , \
	                python-dateutil $(python-dateutil-version))

$(ipydir)/pythran-$(pythran-version): \
                  $(ipydir)/ply-$(ply-version) \
                  $(ipydir)/gast-$(gast-version) \
                  $(ibidir)/boost-$(boost-version) \
                  $(ipydir)/beniget-$(beniget-version) \
                  $(ipydir)/setuptools_scm-$(setuptools_scm-version)
	tarball=pythran-$(pythran-version).tar.lz
	$(call import-source, $(pythran-url), $(pythran-checksum))
	$(call pybuild, tar -xf, pythran-$(pythran-version), , \
	                pythran $(pythran-version))

$(ipydir)/pyyaml-$(pyyaml-version): \
                 $(ibidir)/yaml-$(yaml-version) \
                 $(ipydir)/cython-$(cython-version)
	tarball=pyyaml-$(pyyaml-version).tar.gz
	$(call import-source, $(pyyaml-url), $(pyyaml-checksum))
	$(call pybuild, tar -xf, PyYAML-$(pyyaml-version), , \
	                PyYAML $(pyyaml-version))

$(ipydir)/requests-$(requests-version): $(ipydir)/idna-$(idna-version) \
                    $(ipydir)/numpy-$(numpy-version) \
                    $(ipydir)/certifi-$(certifi-version) \
                    $(ipydir)/chardet-$(chardet-version) \
                    $(ipydir)/urllib3-$(urllib3-version)
	tarball=requests-$(requests-version).tar.gz
	$(call import-source, $(requests-url), $(requests-checksum))
	$(call pybuild, tar -xf, requests-$(requests-version), , \
	                Requests $(requests-version))

$(ipydir)/scipy-$(scipy-version): \
                  $(ipydir)/numpy-$(numpy-version) \
                  $(ipydir)/pythran-$(pythran-version) \
                  $(ipydir)/pybind11-$(pybind11-version)
	tarball=scipy-$(scipy-version).tar.lz
	$(call import-source, $(scipy-url), $(scipy-checksum))
	if [ x$(on_mac_os) = xyes ]; then
	  export LDFLAGS="$(LDFLAGS) -undefined dynamic_lookup -bundle"
	else
	  export LDFLAGS="$(LDFLAGS) -shared"
	fi
	conf="$$(pwd)/reproduce/software/config/numpy-scipy.cfg"
	$(call pybuild, tar -xf, scipy-$(scipy-version),$$conf)
	cp $(dtexdir)/scipy.tex $(ictdir)/
	echo "Scipy $(scipy-version) \citep{scipy2007,scipy2011}" > $@

$(ipydir)/secretstorage-$(secretstorage-version): \
                        $(ipydir)/jeepney-$(jeepney-version) \
                        $(ipydir)/cryptography-$(cryptography-version)
	tarball=secretstorage-$(secretstorage-version).tar.gz
	$(call import-source, $(secretstorage-url), $(secretstorage-checksum))
	$(call pybuild, tar -xf, SecretStorage-$(secretstorage-version), , \
	                SecretStorage $(secretstorage-version))

$(ipydir)/setuptools-$(setuptools-version): \
                     $(ibidir)/unzip-$(unzip-version) \
                     $(ibidir)/python-$(python-version)
	tarball=setuptools-$(setuptools-version).tar.lz
	$(call import-source, $(setuptools-url), $(setuptools-checksum))
	$(call pybuild, tar -xf, setuptools-$(setuptools-version), , \
	                Setuptools $(setuptools-version))

$(ipydir)/setuptools_scm-$(setuptools_scm-version): \
                         $(ipydir)/setuptools-$(setuptools-version)
	tarball=setuptools_scm-$(setuptools_scm-version).tar.gz
	$(call import-source, $(setuptools_scm-url), $(setuptools_scm-checksum))
	$(call pybuild, tar -xf, setuptools_scm-$(setuptools_scm-version), , \
	                Setuptools-scm $(setuptools_scm-version))

$(ipydir)/setuptools-rust-$(setuptools-rust-version): \
                          $(ipydir)/setuptools-$(setuptools-version)
	tarball=setuptools-rust-$(setuptools-rust-version).tar.lz
	$(call import-source, $(setuptools-rust-url), $(setuptools-rust-checksum))
	$(call pybuild, tar -xf, setuptools-rust-$(setuptools-rust-version), , \
	                Setuptools-scm $(setuptools-rust-version))

$(ipydir)/sip_tpv-$(sip_tpv-version): \
                  $(ipydir)/sympy-$(sympy-version) \
                  $(ipydir)/astropy-$(astropy-version)
	tarball=sip_tpv-$(sip_tpv-version).tar.gz
	$(call import-source, $(sip_tpv-url), $(sip_tpv-checksum))
	$(call pybuild, tar -xf, sip_tpv-$(sip_tpv-version), ,)
	cp $(dtexdir)/sip_tpv.tex $(ictdir)/
	echo "sip_tpv $(sip_tpv-version) \citep{sip-tpv}" > $@


$(ipydir)/six-$(six-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=six-$(six-version).tar.lz
	$(call import-source, $(six-url), $(six-checksum))
	$(call pybuild, tar -xf, six-$(six-version), , \
	                Six $(six-version))

$(ipydir)/soupsieve-$(soupsieve-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=soupsieve-$(soupsieve-version).tar.gz
	$(call import-source, $(soupsieve-url), $(soupsieve-checksum))
	$(call pybuild, tar -xf, soupsieve-$(soupsieve-version), , \
	                SoupSieve $(soupsieve-version))

$(ipydir)/sympy-$(sympy-version): $(ipydir)/mpmath-$(mpmath-version)
	tarball=sympy-$(sympy-version).tar.gz
	$(call import-source, $(sympy-url), $(sympy-checksum))
	$(call pybuild, tar -xf, sympy-$(sympy-version), ,)
	cp $(dtexdir)/sympy.tex $(ictdir)/
	echo "SymPy $(sympy-version) \citep{sympy}" > $@

$(ipydir)/uncertainties-$(uncertainties-version): $(ipydir)/numpy-$(numpy-version)
	tarball=uncertainties-$(uncertainties-version).tar.lz
	$(call import-source, $(uncertainties-url), $(uncertainties-checksum))
	$(call pybuild, tar -xf, uncertainties-$(uncertainties-version), , \
	                uncertainties $(uncertainties-version))

$(ipydir)/urllib3-$(urllib3-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=urllib3-$(urllib3-version).tar.gz
	$(call import-source, $(urllib3-url), $(urllib3-checksum))
	$(call pybuild, tar -xf, urllib3-$(urllib3-version), , \
	                Urllib3 $(urllib3-version))

$(ipydir)/webencodings-$(webencodings-version): \
                       $(ipydir)/setuptools-$(setuptools-version)
	tarball=webencodings-$(webencodings-version).tar.gz
	$(call import-source, $(webencodings-url), $(webencodings-checksum))
	$(call pybuild, tar -xf, webencodings-$(webencodings-version), , \
	                Webencodings $(webencodings-version))

$(ipydir)/wheel-$(wheel-version): $(ipydir)/setuptools-$(setuptools-version)
	tarball=wheel-$(wheel-version).tar.lz
	$(call import-source, $(wheel-url), $(wheel-checksum))
	$(call pybuild, tar -xf, wheel-$(wheel-version), , \
	                Wheel $(wheel-version))
