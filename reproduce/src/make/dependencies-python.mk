# Build the project's Python dependencies.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2019 Raul Infante-Sainz <infantesainz@gmail.com>
# Copyright (C) 2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# Python enviroment
# -----------------
#
# The main Python environment variable is `PYTHONPATH'. However, so far we
# have found several other Python-related environment variables on some
# systems which might interfere. To be safe, we are removing all their
# values.
export PYTHONPATH             := $(installdir)/lib/python/site-packages
export PYTHONPATH2            := $(PYTHONPATH)
export PYTHONPATH3            := $(PYTHONPATH)
export _LMFILES_              :=
export LOADEDMODULES          :=
export MPI_PYTHON_SITEARCH    :=
export MPI_PYTHON2_SITEARCH   :=
export MPI_PYTHON3_SITEARCH   :=





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
pytarballs = $(foreach t, asn1crypto-$(asn1crypto-version).tar.gz         \
                        astroquery-$(astroquery-version).tar.gz           \
                        astropy-$(astropy-version).tar.gz                 \
                        beautifulsoup4-$(beautifulsoup4-version).tar.gz   \
                        certifi-$(certifi-version).tar.gz                 \
                        cffi-$(cffi-version).tar.gz                       \
                        chardet-$(chardet-version).tar.gz                 \
                        cryptography-$(cryptography-version).tar.gz       \
                        cycler-$(cycler-version).tar.gz                   \
                        cython-$(cython-version).tar.gz                   \
                        entrypoints-$(entrypoints-version).tar.gz         \
                        h5py-$(h5py-version).tar.gz                       \
                        html5lib-$(html5lib-version).tar.gz               \
                        idna-$(idna-version).tar.gz                       \
                        jeepney-$(jeepney-version).tar.gz                 \
                        kiwisolver-$(kiwisolver-version).tar.gz           \
                        keyring-$(keyring-version).tar.gz                 \
                        libffi-$(libffi-version).tar.gz                   \
                        matplotlib-$(matplotlib-version).tar.gz           \
                        mpi4py-$(mpi4py-version).tar.gz                   \
                        numpy-$(numpy-version).zip                        \
                        pkgconfig-$(pypkgconfig-version).tar.gz           \
                        pip-$(pip-version).tar.gz                         \
                        pycparser-$(pycparser-version).tar.gz             \
                        python-$(python-version).tar.gz                   \
                        python-dateutil-$(python-dateutil-version).tar.gz \
                        pyparsing-$(pyparsing-version).tar.gz             \
                        requests-$(requests-version).tar.gz               \
                        scipy-$(scipy-version).tar.gz                     \
                        secretstorage-$(secretstorage-version).tar.gz     \
                        setuptools-$(setuptools-version).zip              \
                        setuptools_scm-$(setuptools_scm-version).tar.gz   \
                        six-$(six-version).tar.gz                         \
                        soupsieve-$(soupsieve-version).tar.gz             \
                        urllib3-$(urllib3-version).tar.gz                 \
                        webencodings-$(webencodings-version).tar.gz       \
                        virtualenv-$(virtualenv-version).tar.gz           \
                      , $(tdir)/$(t) )
pytopurl=https://files.pythonhosted.org/packages
$(pytarballs): $(tdir)/%:
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then
	  cp $(DEPENDENCIES-DIR)/$* $@
	else

          # Convenience variable
          # --------------------
          #
          # `n' is just for convenience and to avoid having to repeat the
          # package tarball name in the conditional to find its URL.
          #
          # For some packages (for example `python-dateutil', or those with
          # a number or dash in their name), we need special consideration
          # because the tokenization above will produce `python' as the
          # first string.
	  if [ $* = python-dateutil-$(python-dateutil-version).tar.gz ]; then
	    n=dateutil
	  elif [ $* = h5py-$(h5py-version).tar.gz ]; then
	    n=h5py

          # elif [ $* = strange-tarball5name-version.tar.gz ]; then
          #  n=strange5-name
	  else
            # Remove all numbers, `-' and `.' from the tarball name so we can
            # search more easily only with the program name.
	    n=$$(echo $* | sed -e's/[0-9\-]/ /g' -e's/\./ /g'           \
	              | awk '{print $$1}')
	  fi

          # Set the top download link of the requested tarball. The ones
          # that have non-standard filenames (differing from our archived
          # tarball names) are treated first, then the standard ones.
	  mergenames=1
	  if [ $$n = cython         ]; then
	    mergenames=0
	    hash=36/da/fcb979fc8cb486a67a013d6aefefbb95a3e19e67e49dff8a35e014046c5e
	    h=$(pytopurl)/$$hash/Cython-$(cython-version).tar.gz
	  elif [ $$n = python           ]; then
	    mergenames=0
	    h=https://www.python.org/ftp/python/$(python-version)/Python-$(python-version).tgz
	  elif [ $$n = libffi         ]; then
	    mergenames=0
	    h=ftp://sourceware.org/pub/libffi/libffi-$(libffi-version).tar.gz
	  elif [ $$n = secretstorage  ]; then
	    mergenames=0
	    hash=a6/89/df343dbc2957a317127e7ff2983230dc5336273be34f2e1911519d85aeb5
	    h=$(pytopurl)/$$hash/SecretStorage-$(secretstorage-version).tar.gz
	  elif [ $$n = asn            ]; then h=fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4
	  elif [ $$n = astroquery     ]; then h=61/50/a7a08f9e54d7d9d97e69433cd88231e1ad2901811c9d1ae9ac7ccaef9396
	  elif [ $$n = astropy        ]; then h=eb/f7/1251bf6881861f24239efe0c24cbcfc4191ccdbb69ac3e9bb740d0c23352
	  elif [ $$n = beautifulsoup  ]; then h=80/f2/f6aca7f1b209bb9a7ef069d68813b091c8c3620642b568dac4eb0e507748
	  elif [ $$n = certifi        ]; then h=55/54/3ce77783acba5979ce16674fc98b1920d00b01d337cfaaf5db22543505ed
	  elif [ $$n = cffi           ]; then h=64/7c/27367b38e6cc3e1f49f193deb761fe75cda9f95da37b67b422e62281fcac
	  elif [ $$n = chardet        ]; then h=fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d
	  elif [ $$n = cryptography   ]; then h=07/ca/bc827c5e55918ad223d59d299fff92f3563476c3b00d0a9157d9c0217449
	  elif [ $$n = cycler         ]; then h=c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488
	  elif [ $$n = entrypoints    ]; then h=b4/ef/063484f1f9ba3081e920ec9972c96664e2edb9fdc3d8669b0e3b8fc0ad7c
	  elif [ $$n = h5py           ]; then h=43/27/a6e7dcb8ae20a4dbf3725321058923fec262b6f7835179d78ccc8d98deec
	  elif [ $$n = html           ]; then h=85/3e/cf449cf1b5004e87510b9368e7a5f1acd8831c2d6691edd3c62a0823f98f
	  elif [ $$n = idna           ]; then h=ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7
	  elif [ $$n = jeepney        ]; then h=16/1d/74adf3b164a8d19a60d0fcf706a751ffa2a1eaa8e5bbb1b6705c92a05263
	  elif [ $$n = keyring        ]; then h=15/88/c6ce9509438bc02d54cf214923cfba814412f90c31c95028af852b19f9b2
	  elif [ $$n = kiwisolver     ]; then h=31/60/494fcce70d60a598c32ee00e71542e52e27c978e5f8219fae0d4ac6e2864
	  elif [ $$n = matplotlib     ]; then h=89/0c/653aec68e9cfb775c4fbae8f71011206e5e7fe4d60fcf01ea1a9d3bc957f
	  elif [ $$n = mpi            ]; then h=55/a2/c827b196070e161357b49287fa46d69f25641930fd5f854722319d431843
	  elif [ $$n = numpy          ]; then h=cf/8d/6345b4f32b37945fedc1e027e83970005fc9c699068d2f566b82826515f2
	  elif [ $$n = pip            ]; then h=4c/4d/88bc9413da11702cbbace3ccc51350ae099bb351febae8acc85fec34f9af
	  elif [ $$n = pkgconfig      ]; then h=6e/a9/ff67ef67217dfdf2aca847685fe789f82b931a6957a3deac861297585db6
	  elif [ $$n = pycparser      ]; then h=68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a
	  elif [ $$n = pyparsing      ]; then h=b9/b8/6b32b3e84014148dcd60dd05795e35c2e7f4b72f918616c61fdce83d27fc
	  elif [ $$n = dateutil       ]; then h=ad/99/5b2e99737edeb28c71bcbec5b5dda19d0d9ef3ca3e92e3e925e7c0bb364c
	  elif [ $$n = requests       ]; then h=52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38
	  elif [ $$n = scipy          ]; then h=a9/b4/5598a706697d1e2929eaf7fe68898ef4bea76e4950b9efbe1ef396b8813a
	  elif [ $$n = secretstorage  ]; then h=a6/89/df343dbc2957a317127e7ff2983230dc5336273be34f2e1911519d85aeb5
	  elif [ $$n = setuptools     ]; then h=c2/f7/c7b501b783e5a74cf1768bc174ee4fb0a8a6ee5af6afa92274ff964703e0
	  elif [ $$n = setuptools_scm ]; then h=54/85/514ba3ca2a022bddd68819f187ae826986051d130ec5b972076e4f58a9f3
	  elif [ $$n = six            ]; then h=dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca
	  elif [ $$n = soupsieve      ]; then h=0c/52/e9088bb9b96e2d39fc3b33fcda5b4fde9d71473536ac660a1ca9a0958a2f
	  elif [ $$n = urllib         ]; then h=b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1
	  elif [ $$n = virtualenv     ]; then h=51/aa/c395a6e6eaaedfa5a04723b6446a1df783b16cca6fec66e671cede514688
	  elif [ $$n = webencodings   ]; then h=0b/02/ae6ceac1baeda530866a85075641cec12989bd8d31af6d5ab4a3e8c92f47
#	  elif [ $$n = strange5-name  ]; then h=XXXXX
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
	  if [ $$mergenames = 1 ]; then  tarballurl=$(pytopurl)/$$h/"$*"
	  else                           tarballurl=$$h
	  fi

          # Download using the script specially defined for this job.
	  touch $(lockdir)/download
	  downloader="wget --no-use-server-timestamps -O"
	  $(downloadwrapper) "$$downloader" $(lockdir)/download \
	                     $$tarballurl $@
	fi





# Necessary programs and libraries
# --------------------------------
#
# While this Makefile is for Python programs, in some cases, we need
# certain programs (like Python itself), or libraries for the modules.
$(ilidir)/libffi: $(tdir)/libffi-$(libffi-version).tar.gz
	$(call gbuild, $<, libffi-$(libffi-version))        \
	echo "Libffi $(libffi-version)" > $@

$(ibidir)/python3: $(tdir)/python-$(python-version).tar.gz \
                   $(ilidir)/libffi
        # On Mac systems, the build complains about `clang' specific
        # features, so we can't use our own GCC build here.
	if [ x$(on_mac_os) = xyes ]; then                   \
	  export CC=clang;                                  \
	  export CXX=clang++;                               \
	fi;                                                 \
	$(call gbuild, $<, Python-$(python-version),,       \
	       --without-ensurepip                          \
	       --with-system-ffi                            \
	       --enable-shared)                             \
	&& v=$$(echo $(python-version) | awk 'BEGIN{FS="."} \
	    {printf "%d.%d\n", $$1, $$2}')                  \
	&& ln -s $(ildir)/python$$v $(ildir)/python         \
	&& rm -rf $(ipydir)                                 \
	&& mkdir $(ipydir)                                  \
	&& echo "Python $(python-version)" > $@





# Non-PiP Python module installation
# ----------------------------------
#
# To build Python packages with direct access to a `setup.py' (if no direct
# access to `setup.py' is needed, pip can be used).
# Arguments of this function are the numbers
#   1) Unpack command
#   2) Package name
#   3) Unpacked directory name after unpacking the tarball
#   4) site.cfg file (optional)
#   5) Official software name.(for paper).
pybuild = cd $(ddir); rm -rf $(3);                            \
	 if ! $(1) $(2); then echo; echo "Tar error"; exit 1; fi; \
	 cd $(3);                                                 \
	 if [ "x$(strip $(4))" != x ]; then                       \
	   sed -e 's|@LIBDIR[@]|'"$(ildir)"'|'                    \
	       -e 's|@INCDIR[@]|'"$(idir)/include"'|'             \
	       $(4) > site.cfg;                                   \
	 fi;                                                      \
	 python3 setup.py build                                   \
	 && python3 setup.py install                              \
	 && cd ..                                                 \
	 && rm -rf $(3)                                           \
	 && echo "$(5)" > $@





# Python modules
# ---------------
#
# All the necessary Python modules go here.
$(ipydir)/asn1crypto: $(tdir)/asn1crypto-$(asn1crypto-version).tar.gz \
                      $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, asn1crypto-$(asn1crypto-version), , \
	                Asn1crypto $(asn1crypto-version))

$(ipydir)/astroquery: $(tdir)/astroquery-$(astroquery-version).tar.gz  \
                      $(ipydir)/beautifulsoup4                         \
                      $(ipydir)/html5lib                               \
                      $(ipydir)/requests                               \
                      $(ipydir)/astropy                                \
                      $(ipydir)/keyring                                \
                      $(ipydir)/numpy
	$(call pybuild, tar xf, $<, astroquery-$(astroquery-version), ,\
	                Astroquery $(astroquery-version))

$(ipydir)/astropy: $(tdir)/astropy-$(astropy-version).tar.gz \
                   $(ipydir)/h5py                            \
                   $(ipydir)/numpy                           \
                   $(ipydir)/scipy
	$(call pybuild, tar xf, $<, astropy-$(astropy-version)) \
	&& cp $(dtexdir)/astropy.tex $(ictdir)/                 \
	&& echo "Astropy $(astropy-version) \citep{astropy2013,astropy2018}" > $@

$(ipydir)/beautifulsoup4: $(tdir)/beautifulsoup4-$(beautifulsoup4-version).tar.gz \
                          $(ipydir)/soupsieve
	$(call pybuild, tar xf, $<, beautifulsoup4-$(beautifulsoup4-version), ,\
	                BeautifulSoup $(beautifulsoup4-version))

$(ipydir)/certifi: $(tdir)/certifi-$(certifi-version).tar.gz \
                   $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, certifi-$(certifi-version), ,\
	                Certifi $(certifi-version))

$(ipydir)/cffi: $(tdir)/cffi-$(cffi-version).tar.gz \
                $(ilidir)/libffi                    \
                $(ipydir)/pycparser
	$(call pybuild, tar xf, $<, cffi-$(cffi-version), ,\
	                cffi $(cffi-version))

$(ipydir)/chardet: $(tdir)/chardet-$(chardet-version).tar.gz \
                   $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, chardet-$(chardet-version), ,\
	                Chardet $(chardet-version))

$(ipydir)/cryptography: $(tdir)/cryptography-$(cryptography-version).tar.gz \
                        $(ipydir)/asn1crypto                                \
                        $(ipydir)/cffi
	$(call pybuild, tar xf, $<, cryptography-$(cryptography-version), ,\
	                Cryptography $(cryptography-version))

$(ipydir)/cycler: $(tdir)/cycler-$(cycler-version).tar.gz \
                  $(ipydir)/six
	$(call pybuild, tar xf, $<, cycler-$(cycler-version), ,\
	                Cycler $(cycler-version))

$(ipydir)/cython: $(tdir)/cython-$(cython-version).tar.gz \
                  $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, Cython-$(cython-version)) \
	&& cp $(dtexdir)/cython.tex $(ictdir)/                \
	&& echo "Cython $(cython-version) \citep{cython2011}" > $@

$(ipydir)/entrypoints: $(tdir)/entrypoints-$(entrypoints-version).tar.gz \
                       $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, entrypoints-$(entrypoints-version), ,\
	                EntryPoints $(entrypoints-version))

$(ipydir)/h5py: $(tdir)/h5py-$(h5py-version).tar.gz \
                $(ilidir)/hdf5                      \
                $(ipydir)/cython                    \
                $(ipydir)/pypkgconfig               \
                $(ipydir)/setuptools
                #$(ipydir)/mpi4py # AFTER its problem is fixed.
	#export HDF5_MPI=ON;       # AFTER its problem is fixed.
	export HDF5_DIR=$(ildir);                          \
	$(call pybuild, tar xf, $<, h5py-$(h5py-version), ,\
	                h5py $(h5py-version))

$(ipydir)/html5lib: $(tdir)/html5lib-$(html5lib-version).tar.gz  \
                    $(ipydir)/six                                \
                    $(ipydir)/webencodings
	$(call pybuild, tar xf, $<, html5lib-$(html5lib-version), ,\
	                HTML5lib $(html5lib-version))

$(ipydir)/idna: $(tdir)/idna-$(idna-version).tar.gz \
                $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, idna-$(idna-version), ,\
	       idna $(idna-version))

$(ipydir)/jeepney: $(tdir)/jeepney-$(jeepney-version).tar.gz \
                   $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, jeepney-$(jeepney-version), ,\
	                Jeepney $(jeepney-version))

$(ipydir)/keyring: $(tdir)/keyring-$(keyring-version).tar.gz    \
                   $(ipydir)/entrypoints                        \
                   $(ipydir)/secretstorage                      \
                   $(ipydir)/setuptools_scm
	$(call pybuild, tar xf, $<, keyring-$(keyring-version), ,\
	                Keyring $(keyring-version))

$(ipydir)/kiwisolver: $(tdir)/kiwisolver-$(kiwisolver-version).tar.gz    \
                      $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, kiwisolver-$(kiwisolver-version), ,\
	                Kiwisolver $(kiwisolver-version))

$(ipydir)/matplotlib: $(tdir)/matplotlib-$(matplotlib-version).tar.gz   \
                      $(ipydir)/cycler                                  \
                      $(ilidir)/freetype                                \
                      $(ipydir)/kiwisolver                              \
                      $(ipydir)/numpy                                   \
                      $(ipydir)/pyparsing                               \
                      $(ipydir)/python-dateutil
	$(call pybuild, tar xf, $<, matplotlib-$(matplotlib-version)) \
	&& cp $(dtexdir)/matplotlib.tex $(ictdir)/                    \
	&& echo "Matplotlib $(matplotlib-version) \citep{matplotlib2007}" > $@

# Currently mpi4py doesn't build because of some conflict with OpenMPI:
#
#  In file included from src/mpi4py.MPI.c:591,
#                  from src/MPI.c:4:
#  src/mpi4py.MPI.c: In function '__pyx_f_6mpi4py_3MPI_del_Datatype':
#  src/mpi4py.MPI.c:15094:36: error: expected expression before '_Static_assert'
#  __pyx_t_1 = (((__pyx_v_ob[0]) == MPI_UB) != 0);
#
# But atleast on my system it fails.
$(ipydir)/mpi4py: $(tdir)/mpi4py-$(mpi4py-version).tar.gz    \
                  $(ipydir)/setuptools                       \
                  $(ilidir)/openmpi
	$(call pybuild, tar xf, $<, mpi4py-$(mpi4py-version)) \
	&& cp $(dtexdir)/mpi4py.tex $(ictdir)/                \
	&& echo "mpi4py $(mpi4py-version) \citep{mpi4py2011}" > $@

$(ipydir)/numpy: $(tdir)/numpy-$(numpy-version).zip \
                 $(ipydir)/setuptools               \
                 $(ilidir)/openblas                 \
                 $(ilidir)/fftw                     \
                 $(ibidir)/unzip
	if [ x$(on_mac_os) = xyes ]; then                                    \
	  export LDFLAGS="$(LDFLAGS) -undefined dynamic_lookup -bundle";     \
	else                                                                 \
	  export LDFLAGS="$(LDFLAGS) -shared";                               \
	fi;                                                                  \
	conf="$$(pwd)/reproduce/config/pipeline/dependency-numpy-scipy.cfg"; \
	$(call pybuild, unzip, $<, numpy-$(numpy-version),$$conf,            \
	                Numpy $(numpy-version))                              \
	&& cp $(dtexdir)/numpy.tex $(ictdir)/                                \
	&& echo "Numpy $(numpy-version) \citep{numpy2011}" > $@

$(ibidir)/pip3: $(tdir)/pip-$(pip-version).tar.gz \
                $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, pip-$(pip-version), ,\
	                PiP $(pip-version))

$(ipydir)/pypkgconfig: $(tdir)/pkgconfig-$(pypkgconfig-version).tar.gz \
                       $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, pkgconfig-$(pypkgconfig-version), ,
	                pkgconfig $(pypkgconfig-version))

$(ipydir)/pycparser: $(tdir)/pycparser-$(pycparser-version).tar.gz \
                     $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, pycparser-$(pycparser-version), ,\
	                pycparser $(pycparser-version))

$(ipydir)/pyparsing: $(tdir)/pyparsing-$(pyparsing-version).tar.gz \
                     $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, pyparsing-$(pyparsing-version), ,\
	                PyParsing $(pyparsing-version))

$(ipydir)/python-dateutil: $(tdir)/python-dateutil-$(python-dateutil-version).tar.gz  \
                           $(ipydir)/setuptools_scm                                   \
                           $(ipydir)/six
	$(call pybuild, tar xf, $<, python-dateutil-$(python-dateutil-version), ,\
	                python-dateutil $(python-dateutil-version))

$(ipydir)/requests: $(tdir)/requests-$(requests-version).tar.gz   \
                    $(ipydir)/certifi                             \
                    $(ipydir)/chardet                             \
                    $(ipydir)/idna                                \
                    $(ipydir)/numpy                               \
                    $(ipydir)/urllib3
	$(call pybuild, tar xf, $<, requests-$(requests-version), ,\
	                Requests $(requests-version))

$(ipydir)/scipy: $(tdir)/scipy-$(scipy-version).tar.gz \
                 $(ipydir)/numpy
	if [ x$(on_mac_os) = xyes ]; then                                    \
	  export LDFLAGS="$(LDFLAGS) -undefined dynamic_lookup -bundle";     \
	else                                                                 \
	  export LDFLAGS="$(LDFLAGS) -shared";                               \
	fi;                                                                  \
	conf="$$(pwd)/reproduce/config/pipeline/dependency-numpy-scipy.cfg"; \
	$(call pybuild, tar xf, $<, scipy-$(scipy-version),$$conf)           \
	&& cp $(dtexdir)/scipy.tex $(ictdir)/                                \
	&& echo "Scipy $(scipy-version) \citep{scipy2007,scipy2011}" > $@

$(ipydir)/secretstorage: $(tdir)/secretstorage-$(secretstorage-version).tar.gz \
                         $(ipydir)/cryptography                                \
                         $(ipydir)/jeepney
	$(call pybuild, tar xf, $<, SecretStorage-$(secretstorage-version), ,\
	                SecretStorage $(secretstorage-version))

$(ipydir)/setuptools: $(tdir)/setuptools-$(setuptools-version).zip \
                      $(ibidir)/python3                            \
                      $(ibidir)/unzip
	$(call pybuild, unzip, $<, setuptools-$(setuptools-version), ,\
	                Setuptools $(setuptools-version))

$(ipydir)/setuptools_scm: $(tdir)/setuptools_scm-$(setuptools_scm-version).tar.gz \
                          $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, setuptools_scm-$(setuptools_scm-version), ,\
	                Setuptools-scm $(setuptools_scm-version))

$(ipydir)/six: $(tdir)/six-$(six-version).tar.gz \
               $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, six-$(six-version), ,\
	                Six $(six-version))

$(ipydir)/soupsieve: $(tdir)/soupsieve-$(soupsieve-version).tar.gz \
                     $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, soupsieve-$(soupsieve-version), ,\
	                SoupSieve $(soupsieve-version))

$(ipydir)/urllib3: $(tdir)/urllib3-$(urllib3-version).tar.gz \
                   $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, urllib3-$(urllib3-version), ,\
	                Urllib3 $(urllib3-version))

$(ipydir)/webencodings: $(tdir)/webencodings-$(webencodings-version).tar.gz \
                        $(ipydir)/setuptools
	$(call pybuild, tar xf, $<, webencodings-$(webencodings-version), ,\
	                Webencodings $(webencodings-version))
