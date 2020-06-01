# Build the project's Python dependencies.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./project configure' script. It
# is not included into the reproduction pipe after that.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2019-2020 Raul Infante-Sainz <infantesainz@gmail.com>
# Copyright (C) 2019-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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
# The main Python environment variable is `PYTHONPATH'. However, so far we
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
pytarballs = $(foreach t, asn1crypto-$(asn1crypto-version).tar.gz \
                        asteval-$(asteval-version).tar.gz \
                        astroquery-$(astroquery-version).tar.gz \
                        astropy-$(astropy-version).tar.gz \
                        beautifulsoup4-$(beautifulsoup4-version).tar.gz \
                        certifi-$(certifi-version).tar.gz \
                        cffi-$(cffi-version).tar.gz \
                        chardet-$(chardet-version).tar.gz \
                        corner-$(corner-version).tar.gz \
                        cryptography-$(cryptography-version).tar.gz \
                        cycler-$(cycler-version).tar.gz \
                        cython-$(cython-version).tar.gz \
                        eigency-$(eigency-version).tar.gz \
                        emcee-$(emcee-version).tar.gz \
                        esutil-$(esutil-version).tar.gz \
                        entrypoints-$(entrypoints-version).tar.gz \
                        flake8-$(flake8-version).tar.gz \
                        future-$(future-version).tar.gz \
                        galsim-$(galsim-version).tar.gz \
                        h5py-$(h5py-version).tar.gz \
                        html5lib-$(html5lib-version).tar.gz \
                        idna-$(idna-version).tar.gz \
                        jeepney-$(jeepney-version).tar.gz \
                        kiwisolver-$(kiwisolver-version).tar.gz \
                        keyring-$(keyring-version).tar.gz \
                        libffi-$(libffi-version).tar.gz \
                        lmfit-$(lmfit-version).tar.gz \
                        lsstdesccoord-$(lsstdesccoord-version).tar.gz \
                        matplotlib-$(matplotlib-version).tar.gz \
                        mpi4py-$(mpi4py-version).tar.gz \
                        mpmath-$(mpmath-version).tar.gz \
                        numpy-$(numpy-version).zip \
                        pkgconfig-$(pypkgconfig-version).tar.gz \
                        pip-$(pip-version).tar.gz \
                        pexpect-$(pexpect-version).tar.gz \
                        pybind11-$(pybind11-version).tar.gz \
                        pycodestyle-$(pycodestyle-version).tar.gz \
                        pycparser-$(pycparser-version).tar.gz \
                        pyflakes-$(pyflakes-version).tar.gz \
                        python-$(python-version).tar.gz \
                        python-dateutil-$(python-dateutil-version).tar.gz \
                        pyparsing-$(pyparsing-version).tar.gz \
                        pyyaml-$(pyyaml-version).tar.gz \
                        requests-$(requests-version).tar.gz \
                        scipy-$(scipy-version).tar.gz \
                        secretstorage-$(secretstorage-version).tar.gz \
                        setuptools-$(setuptools-version).zip \
                        setuptools_scm-$(setuptools_scm-version).tar.gz \
                        sip_tpv-$(sip_tpv-version).tar.gz \
                        six-$(six-version).tar.gz \
                        soupsieve-$(soupsieve-version).tar.gz \
                        sympy-$(sympy-version).tar.gz \
                        uncertainties-$(uncertainties-version).tar.gz \
                        urllib3-$(urllib3-version).tar.gz \
                        webencodings-$(webencodings-version).tar.gz \
                        virtualenv-$(virtualenv-version).tar.gz \
                      , $(tdir)/$(t) )
pytopurl=https://files.pythonhosted.org/packages
$(pytarballs): $(tdir)/%:

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
	@if [ $* = python-dateutil-$(python-dateutil-version).tar.gz ]; then
	  n=dateutil

        # elif [ $* = strange-tarball5name-version.tar.gz ]; then
        #  n=strange5-name
	else
          # Remove the version numbers and suffix from the tarball name so
          # we can search more easily only with the program name. This
          # requires the first character of the version to be a digit:
          # packages such as `foo' and `foo-3' will not be distinguished,
          # but `foo' and `foo2' will be distinguished.
	  n=$$(echo $* | sed -e's/-[0-9]/ /' -e's/\./ /g' \
	               | awk '{print $$1}' )

	fi

        # Set the top download link of the requested tarball. The ones
        # that have non-standard filenames (differing from our archived
        # tarball names) are treated first, then the standard ones.
	mergenames=1
	if [ $$n = cython ]; then
	  mergenames=0
	  c=$(cython-checksum)
	  hash=36/da/fcb979fc8cb486a67a013d6aefefbb95a3e19e67e49dff8a35e014046c5e
	  h=$(pytopurl)/$$hash/Cython-$(cython-version).tar.gz
	elif [ $$n = galsim ]; then
	  mergenames=0
	  c=$(galsim-checksum)
	  hash=8f/3b/bbc7cff7590d3624d528564f08745f071e316c67fce154ad38210833c103
	  h=$(pytopurl)/$$hash/GalSim-$(galsim-version).tar.gz
	elif [ $$n = lsstdesccoord ]; then
	  mergenames=0
	  c=$(lsstdesccoord-checksum)
	  hash=9d/39/ad17697571c9aed36d20ed9ae0a135e3a734fb7f15a8605f92bf27c3b02c
	  h=$(pytopurl)/$$hash/LSSTDESC.Coord-$(lsstdesccoord-version).tar.gz
	elif [ $$n = python ]; then
	  mergenames=0
	  c=$(python-checksum)
	  h=https://www.python.org/ftp/python/$(python-version)/Python-$(python-version).tgz
	elif [ $$n = pyyaml ]; then
	  mergenames=0
	  c=$(pyyaml-checksum)
	  hash=9f/2c/9417b5c774792634834e730932745bc09a7d36754ca00acf1ccd1ac2594d
	  h=$(pytopurl)/$$hash/PyYAML-$(pyyaml-version).tar.gz
	elif [ $$n = libffi ]; then
	  mergenames=0
	  c=$(libffi-checksum)
	  h=ftp://sourceware.org/pub/libffi/libffi-$(libffi-version).tar.gz
	elif [ $$n = secretstorage  ]; then
	  mergenames=0
	  c=$(secretstorage-checksum)
	  hash=a6/89/df343dbc2957a317127e7ff2983230dc5336273be34f2e1911519d85aeb5
	  h=$(pytopurl)/$$hash/SecretStorage-$(secretstorage-version).tar.gz
	elif [ $$n = asn1crypto     ]; then h=fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4; c=$(asn1crypto-checksum)
	elif [ $$n = asteval        ]; then h=50/3f/29b7935c6dc09ee96dc347edc66c57e8ef68d595dd35b763a36a117acc8c; c=$(asteval-checksum)
	elif [ $$n = astroquery     ]; then h=e2/af/a3cd3b30745832a0e81f5f13327234099aaf5d03b7979ac947a888e68e91; c=$(astroquery-checksum)
	elif [ $$n = astropy        ]; then h=de/96/7feaca4b9be134128838395a9d924ea0b389ed4381702dcd9d11ae31789f; c=$(astropy-checksum)
	elif [ $$n = beautifulsoup4 ]; then h=80/f2/f6aca7f1b209bb9a7ef069d68813b091c8c3620642b568dac4eb0e507748; c=$(beautifulsoup4-checksum)
	elif [ $$n = certifi        ]; then h=55/54/3ce77783acba5979ce16674fc98b1920d00b01d337cfaaf5db22543505ed; c=$(certifi-checksum)
	elif [ $$n = cffi           ]; then h=64/7c/27367b38e6cc3e1f49f193deb761fe75cda9f95da37b67b422e62281fcac; c=$(cffi-checksum)
	elif [ $$n = chardet        ]; then h=fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d; c=$(chardet-checksum)
	elif [ $$n = corner         ]; then h=65/af/a7ba022f2d5787f51db91b5550cbe8e8c40a6eebd8f15119e743a09a9c19; c=$(corner-checksum)
	elif [ $$n = cryptography   ]; then h=07/ca/bc827c5e55918ad223d59d299fff92f3563476c3b00d0a9157d9c0217449; c=$(cryptography-checksum)
	elif [ $$n = cycler         ]; then h=c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488; c=$(cycler-checksum)
	elif [ $$n = eigency        ]; then h=fb/6e/bc4359fbfb0bb0b588ec328251b0d0836bdd7c0a4c568959ea06df023e18; c=$(eigency-checksum)
	elif [ $$n = emcee          ]; then h=f0/c0/cd433f2aedeef9b1e5ed7d236c82564f7518fe7fe2238fa141ea9ce08e73; c=$(emcee-checksum)
	elif [ $$n = entrypoints    ]; then h=b4/ef/063484f1f9ba3081e920ec9972c96664e2edb9fdc3d8669b0e3b8fc0ad7c; c=$(entrypoints-checksum)
	elif [ $$n = esutil         ]; then h=5b/91/77e38282fd3d47b55e351544ab179eb209b309a8d2d40f8cdb6241beda00; c=$(esutil-checksum)
	elif [ $$n = flake8         ]; then h=8d/a7/99222c9200af533c1ecb1120d99adbd1c033b57296ac5cb39d121db007a8; c=$(flake8-checksum)
	elif [ $$n = future         ]; then h=3f/bf/57733d44afd0cf67580658507bd11d3ec629612d5e0e432beb4b8f6fbb04; c=$(future-checksum)
	elif [ $$n = h5py           ]; then h=43/27/a6e7dcb8ae20a4dbf3725321058923fec262b6f7835179d78ccc8d98deec; c=$(h5py-checksum)
	elif [ $$n = html5lib       ]; then h=85/3e/cf449cf1b5004e87510b9368e7a5f1acd8831c2d6691edd3c62a0823f98f; c=$(html5lib-checksum)
	elif [ $$n = idna           ]; then h=ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7; c=$(idna-checksum)
	elif [ $$n = jeepney        ]; then h=16/1d/74adf3b164a8d19a60d0fcf706a751ffa2a1eaa8e5bbb1b6705c92a05263; c=$(jeepney-checksum)
	elif [ $$n = keyring        ]; then h=15/88/c6ce9509438bc02d54cf214923cfba814412f90c31c95028af852b19f9b2; c=$(keyring-checksum)
	elif [ $$n = kiwisolver     ]; then h=31/60/494fcce70d60a598c32ee00e71542e52e27c978e5f8219fae0d4ac6e2864; c=$(kiwisolver-checksum)
	elif [ $$n = lmfit          ]; then h=59/6e/117794cf85b7345361877e49245870490ae438f1981dea3c6af1316b30e7; c=$(lmfit-checksum)
	elif [ $$n = matplotlib     ]; then h=12/d1/7b12cd79c791348cb0c78ce6e7d16bd72992f13c9f1e8e43d2725a6d8adf; c=$(matplotlib-checksum)
	elif [ $$n = mpi4py         ]; then h=04/f5/a615603ce4ab7f40b65dba63759455e3da610d9a155d4d4cece1d8fd6706; c=$(mpi4py-checksum)
	elif [ $$n = mpmath         ]; then h=ca/63/3384ebb3b51af9610086b23ea976e6d27d6d97bf140a76a365bd77a3eb32; c=$(mpmath-checksum)
	elif [ $$n = numpy          ]; then h=ac/36/325b27ef698684c38b1fe2e546e2e7ef9cecd7037bcdb35c87efec4356af; c=$(numpy-checksum)
	elif [ $$n = pexpect        ]; then h=1c/b1/362a0d4235496cb42c33d1d8732b5e2c607b0129ad5fdd76f5a583b9fcb3; c=$(pexpect-checksum)
	elif [ $$n = pip            ]; then h=4c/4d/88bc9413da11702cbbace3ccc51350ae099bb351febae8acc85fec34f9af; c=$(pip-checksum)
	elif [ $$n = pkgconfig      ]; then h=6e/a9/ff67ef67217dfdf2aca847685fe789f82b931a6957a3deac861297585db6; c=$(pypkgconfig-checksum)
	elif [ $$n = pybind11       ]; then h=aa/91/deb6743e79e22ab01502296570b39b8404f10cc507a6692d612a7fee8d51; c=$(pybind11-checksum)
	elif [ $$n = pycodestyle    ]; then h=1c/d1/41294da5915f4cae7f4b388cea6c2cd0d6cd53039788635f6875dfe8c72f; c=$(pycodestyle-checksum)
	elif [ $$n = pycparser      ]; then h=68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a; c=$(pycparser-checksum)
	elif [ $$n = pyflakes       ]; then h=52/64/87303747635c2988fcaef18af54bfdec925b6ea3b80bcd28aaca5ba41c9e; c=$(pyflakes-checksum)
	elif [ $$n = pyparsing      ]; then h=b9/b8/6b32b3e84014148dcd60dd05795e35c2e7f4b72f918616c61fdce83d27fc; c=$(pyparsing-checksum)
	elif [ $$n = dateutil       ]; then h=ad/99/5b2e99737edeb28c71bcbec5b5dda19d0d9ef3ca3e92e3e925e7c0bb364c; c=$(python-dateutil-checksum)
	elif [ $$n = requests       ]; then h=52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38; c=$(requests-checksum)
	elif [ $$n = scipy          ]; then h=ee/5b/5afcd1c46f97b3c2ac3489dbc95d6ca28eacf8e3634e51f495da68d97f0f; c=$(scipy-checksum)
	elif [ $$n = secretstorage  ]; then h=a6/89/df343dbc2957a317127e7ff2983230dc5336273be34f2e1911519d85aeb5; c=$(secretstorage-checksum)
	elif [ $$n = setuptools     ]; then h=11/0a/7f13ef5cd932a107cd4c0f3ebc9d831d9b78e1a0e8c98a098ca17b1d7d97; c=$(setuptools-checksum)
	elif [ $$n = setuptools_scm ]; then h=83/44/53cad68ce686585d12222e6769682c4bdb9686808d2739671f9175e2938b; c=$(setuptools_scm-checksum)
	elif [ $$n = six            ]; then h=dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca; c=$(six-checksum)
	elif [ $$n = sip_tpv        ]; then h=27/93/a973aab2a3bf0c12cb385611819710921e13b090304c6bd015026cf9c502; c=$(sip_tpv-checksum)
	elif [ $$n = soupsieve      ]; then h=0c/52/e9088bb9b96e2d39fc3b33fcda5b4fde9d71473536ac660a1ca9a0958a2f; c=$(soupsieve-checksum)
	elif [ $$n = sympy          ]; then h=54/2e/6adb11fe599d4cfb7e8833753350ac51aa2c0603c226b36f9051cc9d2425; c=$(sympy-checksum)
	elif [ $$n = uncertainties  ]; then h=2a/c2/babbe5b16141859dd799ed31c03987100a7b6d0ca7c0ed4429c96ce60fdf; c=$(uncertainties-checksum)
	elif [ $$n = urllib3        ]; then h=b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1; c=$(urllib3-checksum)
	elif [ $$n = virtualenv     ]; then h=51/aa/c395a6e6eaaedfa5a04723b6446a1df783b16cca6fec66e671cede514688; c=$(virtualenv-checksum)
	elif [ $$n = webencodings   ]; then h=0b/02/ae6ceac1baeda530866a85075641cec12989bd8d31af6d5ab4a3e8c92f47; c=$(webencodings-checksum)
#	elif [ $$n = strange5-name  ]; then h=XXXXX; c=$(XXXXX-checksum)
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
	rm -f "$@.unchecked"
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then
	  cp $(DEPENDENCIES-DIR)/$* "$@.unchecked"
	else
	  if [ $$mergenames = 1 ]; then  tarballurl=$(pytopurl)/$$h/"$*"
	  else                           tarballurl=$$h
	  fi

          # Download using the script specially defined for this job.
	  touch $(lockdir)/download
	  downloader="wget --no-use-server-timestamps -O"
	  $(downloadwrapper) "$$downloader" $(lockdir)/download \
	                     $$tarballurl "$@.unchecked" "$(backupservers)"
	fi

        # Make sure this is the expected tarball. Note that we now have a
        # controlled `sha512sum' build (as part of GNU Coreutils). So we
        # don't need to check its existance like `basic.mk'.
	checksum=$$(sha512sum "$@.unchecked" | awk '{print $$1}')
	if [ x"$$checksum" = x"$$c" ]; then
	  mv "$@.unchecked" "$@"
	else
	  echo "ERROR: Non-matching checksum for '$*'."
	  echo "Checksum should be: $$c"
	  echo "Checksum is:        $$checksum"
	  exit 1
	fi





# Necessary programs and libraries
# --------------------------------
#
# While this Makefile is for Python programs, in some cases, we need
# certain programs (like Python itself), or libraries for the modules.
$(ibidir)/libffi: $(tdir)/libffi-$(libffi-version).tar.gz

        # On some Fedora systems, libffi installs in `lib64', not
        # `lib'. This will cause problems when building setuptools
        # later. To fix this problem, we'll first check if this has indeed
        # happened (it exists under `lib64', but not under `lib'). If so,
        # we'll put a copy of the installed libffi libraries in `lib'.
	$(call gbuild, libffi-$(libffi-version), , \
                       CFLAGS="-DNO_JAVA_RAW_API=1") \
	&& if [ -f $(idir)/lib64/libffi.a ] \
	      && ! [ -f $(idir)/lib/libffi.a ]; then \
	        cp $(idir)/lib64/libffi* $(ildir)/; \
	   fi \
	&& echo "Libffi $(libffi-version)" > $@

$(ibidir)/python: $(ibidir)/libffi \
                  $(tdir)/python-$(python-version).tar.gz
        # On Mac systems, the build complains about `clang' specific
        # features, so we can't use our own GCC build here.
	if [ x$(on_mac_os) = xyes ]; then \
	  export CC=clang; \
	  export CXX=clang++; \
	fi; \
	$(call gbuild, Python-$(python-version),, \
	       --without-ensurepip \
	       --with-system-ffi \
	       --enable-shared) \
	&& ln -sf $(ildir)/python$(python-major-version)  $(ildir)/python \
	&& ln -sf $(ibdir)/python$(python-major-version)  $(ibdir)/python \
	&& ln -sf $(iidir)/python$(python-major-version)m $(iidir)/python$(python-major-version) \
	&& rm -rf $(ipydir) \
	&& mkdir $(ipydir) \
	&& echo "Python $(python-version)" > $@





# Non-PiP Python module installation
# ----------------------------------
#
# To build Python packages with direct access to a `setup.py' (if no direct
# access to `setup.py' is needed, pip can be used). Note that the
# software's packaged source code is the first prerequisite that is in the
# `tdir' directory.
#
# Arguments of this function are the numbers
#   1) Unpack command
#   2) Unpacked directory name after unpacking the tarball
#   3) site.cfg file (optional).
#   4) Official software name (for paper).
#
# Hooks:
#   pyhook_before: optional steps before running `python setup.py build'
#   pyhook_after: optional steps after running `python setup.py install'
pybuild = cd $(ddir); rm -rf $(2); \
	 if ! $(1) $(word 1,$(filter $(tdir)/%,$^)); then \
	   echo; echo "Tar error"; exit 1; \
	 fi; \
	 cd $(2); \
	 if [ "x$(strip $(3))" != x ]; then \
	   sed -e 's|@LIBDIR[@]|'"$(ildir)"'|' \
	       -e 's|@INCDIR[@]|'"$(idir)/include"'|' \
	       $(3) > site.cfg; \
	 fi; \
	 if type pyhook_before &>/dev/null; then pyhook_before; fi \
	 && python setup.py build \
	 && python setup.py install \
	 && if type pyhook_after &>/dev/null; then pyhook_after; fi \
	 && cd .. \
	 && rm -rf $(2) \
	 && echo "$(4)" > $@





# Python modules
# ---------------
#
# All the necessary Python modules go here.
$(ipydir)/asn1crypto: $(ipydir)/setuptools \
                      $(tdir)/asn1crypto-$(asn1crypto-version).tar.gz
	$(call pybuild, tar xf, asn1crypto-$(asn1crypto-version), , \
	                Asn1crypto $(asn1crypto-version))

$(ipydir)/asteval: $(ipydir)/numpy \
                   $(tdir)/asteval-$(asteval-version).tar.gz
	$(call pybuild, tar xf, asteval-$(asteval-version), , \
	                ASTEVAL $(asteval-version))

$(ipydir)/astroquery: $(ipydir)/astropy \
                      $(ipydir)/keyring \
                      $(ipydir)/requests \
                      $(tdir)/astroquery-$(astroquery-version).tar.gz
	$(call pybuild, tar xf, astroquery-$(astroquery-version), ,\
	                Astroquery $(astroquery-version))

$(ipydir)/astropy: $(ipydir)/h5py \
                   $(ibidir)/expat \
                   $(ipydir)/scipy \
                   $(ipydir)/numpy \
                   $(ipydir)/pyyaml \
                   $(ipydir)/html5lib \
                   $(ipydir)/beautifulsoup4 \
                   $(tdir)/astropy-$(astropy-version).tar.gz
        # Currently, when the Expat library is already built in a project
        # (for example as a dependency of another program), Astropy's
        # internal building of Expat will conflict with the project's. So
        # we have added Expat as a dependency of Astropy (so it is always
        # built before it, and we tell Astropy to use the project's
        # libexpat.
	pyhook_before () {
	  echo ""                   >> setup.cfg
	  echo "[build]"            >> setup.cfg
	  echo "use_system_expat=1" >> setup.cfg
	}
	$(call pybuild, tar xf, astropy-$(astropy-version)) \
	&& cp $(dtexdir)/astropy.tex $(ictdir)/ \
	&& echo "Astropy $(astropy-version) \citep{astropy2013,astropy2018}" > $@

$(ipydir)/beautifulsoup4: $(ipydir)/soupsieve \
                          $(tdir)/beautifulsoup4-$(beautifulsoup4-version).tar.gz
	$(call pybuild, tar xf, beautifulsoup4-$(beautifulsoup4-version), ,\
	                BeautifulSoup $(beautifulsoup4-version))

$(ipydir)/certifi: $(ipydir)/setuptools \
                   $(tdir)/certifi-$(certifi-version).tar.gz
	$(call pybuild, tar xf, certifi-$(certifi-version), ,\
	                Certifi $(certifi-version))

$(ipydir)/cffi: $(ibidir)/libffi \
                $(ipydir)/pycparser \
                $(tdir)/cffi-$(cffi-version).tar.gz
	$(call pybuild, tar xf, cffi-$(cffi-version), ,\
	                cffi $(cffi-version))

$(ipydir)/chardet: $(ipydir)/setuptools \
                   $(tdir)/chardet-$(chardet-version).tar.gz
	$(call pybuild, tar xf, chardet-$(chardet-version), ,\
	                Chardet $(chardet-version))

$(ipydir)/corner: $(ipydir)/matplotlib \
                  $(tdir)/corner-$(corner-version).tar.gz
	$(call pybuild, tar xf, corner-$(corner-version), ,\
	                Corner $(corner-version)) \
	&& cp $(dtexdir)/corner.tex $(ictdir)/ \
	&& echo "Corner $(corner-version) \citep{corner}" > $@

$(ipydir)/cryptography: $(ipydir)/cffi \
                        $(ipydir)/asn1crypto \
                        $(tdir)/cryptography-$(cryptography-version).tar.gz
	$(call pybuild, tar xf, cryptography-$(cryptography-version), ,\
	                Cryptography $(cryptography-version))

$(ipydir)/cycler: $(ipydir)/six \
                  $(tdir)/cycler-$(cycler-version).tar.gz
	$(call pybuild, tar xf, cycler-$(cycler-version), ,\
	                Cycler $(cycler-version))

$(ipydir)/cython: $(ipydir)/setuptools \
                  $(tdir)/cython-$(cython-version).tar.gz
	$(call pybuild, tar xf, Cython-$(cython-version)) \
	&& cp $(dtexdir)/cython.tex $(ictdir)/ \
	&& echo "Cython $(cython-version) \citep{cython2011}" > $@

$(ipydir)/esutil: $(ipydir)/numpy \
                  $(tdir)/esutil-$(esutil-version).tar.gz
	$(call pybuild, tar xf, esutil-$(esutil-version), ,\
	                esutil $(esutil-version))

$(ipydir)/eigency: $(ibidir)/eigen \
                   $(tdir)/eigency-$(eigency-version).tar.gz
	$(call pybuild, tar xf, eigency-$(eigency-version), ,\
	                eigency $(eigency-version))

$(ipydir)/emcee: $(ipydir)/numpy \
                 $(ipydir)/setuptools_scm \
                 $(tdir)/emcee-$(emcee-version).tar.gz
	$(call pybuild, tar xf, emcee-$(emcee-version), ,\
	                emcee $(emcee-version))

$(ipydir)/entrypoints: $(ipydir)/setuptools \
                       $(tdir)/entrypoints-$(entrypoints-version).tar.gz
	$(call pybuild, tar xf, entrypoints-$(entrypoints-version), ,\
	                EntryPoints $(entrypoints-version))

$(ipydir)/flake8: $(ipydir)/pyflakes \
                  $(ipydir)/pycodestyle \
                  $(tdir)/flake8-$(flake8-version).tar.gz
	$(call pybuild, tar xf, flake8-$(flake8-version), ,\
	                Flake8 $(flake8-version))

$(ipydir)/future: $(ipydir)/setuptools \
                  $(tdir)/future-$(future-version).tar.gz
	$(call pybuild, tar xf, future-$(future-version), ,\
	                Future $(future-version))

$(ipydir)/galsim: $(ipydir)/future \
                  $(ipydir)/astropy \
                  $(ipydir)/eigency \
                  $(ipydir)/pybind11 \
                  $(ipydir)/lsstdesccoord \
                  $(tdir)/galsim-$(galsim-version).tar.gz
	$(call pybuild, tar xf, GalSim-$(galsim-version)) \
	&& cp $(dtexdir)/galsim.tex $(ictdir)/ \
	&& echo "Galsim $(galsim-version) \citep{galsim}" > $@

$(ipydir)/h5py: $(ipydir)/six \
                $(ibidir)/hdf5 \
                $(ipydir)/numpy \
                $(ipydir)/cython \
                $(ipydir)/mpi4py \
                $(ipydir)/pypkgconfig \
                $(tdir)/h5py-$(h5py-version).tar.gz
	export HDF5_MPI=ON; \
	export HDF5_DIR=$(ildir); \
	$(call pybuild, tar xf, h5py-$(h5py-version), ,\
	                h5py $(h5py-version))

# `healpy' is actually installed as part of the HEALPix package. It will be
# installed with its C/C++ libraries if any other Python library is
# requested with HEALPix. So actually calling for `healpix' (when `healpix'
# is requested) is not necessary. But some users might not know about this
# and just ask for `healpy'. To avoid confusion in such cases, we'll just
# set `healpy' to be dependent on `healpix' and not download any tarball
# for it, or write anything in the final target.
$(ipydir)/healpy: $(ibidir)/healpix
	touch $@

$(ipydir)/html5lib: $(ipydir)/six \
                    $(ipydir)/webencodings \
                    $(tdir)/html5lib-$(html5lib-version).tar.gz
	$(call pybuild, tar xf, html5lib-$(html5lib-version), ,\
	                HTML5lib $(html5lib-version))

$(ipydir)/idna: $(ipydir)/setuptools \
                $(tdir)/idna-$(idna-version).tar.gz
	$(call pybuild, tar xf, idna-$(idna-version), ,\
	       idna $(idna-version))

$(ipydir)/jeepney: $(ipydir)/setuptools \
                   $(tdir)/jeepney-$(jeepney-version).tar.gz
	$(call pybuild, tar xf, jeepney-$(jeepney-version), ,\
	                Jeepney $(jeepney-version))

$(ipydir)/keyring: $(ipydir)/entrypoints \
                   $(ipydir)/secretstorage \
                   $(ipydir)/setuptools_scm \
                   $(tdir)/keyring-$(keyring-version).tar.gz
	$(call pybuild, tar xf, keyring-$(keyring-version), ,\
	                Keyring $(keyring-version))

$(ipydir)/kiwisolver: $(ipydir)/setuptools \
                      $(tdir)/kiwisolver-$(kiwisolver-version).tar.gz
	$(call pybuild, tar xf, kiwisolver-$(kiwisolver-version), ,\
	                Kiwisolver $(kiwisolver-version))

$(ipydir)/lmfit: $(ipydir)/six \
                 $(ipydir)/scipy \
                 $(ipydir)/emcee \
                 $(ipydir)/corner \
                 $(ipydir)/asteval \
                 $(ipydir)/matplotlib \
                 $(ipydir)/uncertainties \
                 $(tdir)/lmfit-$(lmfit-version).tar.gz
	$(call pybuild, tar xf, lmfit-$(lmfit-version), ,\
	                LMFIT $(lmfit-version))

$(ipydir)/lsstdesccoord: $(ipydir)/setuptools \
                         $(tdir)/lsstdesccoord-$(lsstdesccoord-version).tar.gz
	$(call pybuild, tar xf, LSSTDESC.Coord-$(lsstdesccoord-version), ,\
	                LSSTDESC.Coord $(lsstdesccoord-version))

$(ipydir)/matplotlib: $(ipydir)/numpy \
                      $(ipydir)/cycler \
                      $(itidir)/texlive \
                      $(ibidir)/freetype \
                      $(ipydir)/pyparsing \
                      $(ipydir)/kiwisolver \
                      $(ibidir)/ghostscript \
                      $(ibidir)/imagemagick \
                      $(ipydir)/python-dateutil \
                      $(tdir)/matplotlib-$(matplotlib-version).tar.gz
        # On Mac systems, the build complains about `clang' specific
        # features, so we can't use our own GCC build here.
	if [ x$(on_mac_os) = xyes ]; then \
	  export CC=clang; \
	  export CXX=clang++; \
	fi; \
	$(call pybuild, tar xf, matplotlib-$(matplotlib-version)) \
	&& cp $(dtexdir)/matplotlib.tex $(ictdir)/ \
	&& echo "Matplotlib $(matplotlib-version) \citep{matplotlib2007}" > $@

$(ipydir)/mpi4py: $(ibidir)/openmpi \
                  $(ipydir)/setuptools \
                  $(tdir)/mpi4py-$(mpi4py-version).tar.gz
	$(call pybuild, tar xf, mpi4py-$(mpi4py-version)) \
	&& cp $(dtexdir)/mpi4py.tex $(ictdir)/ \
	&& echo "mpi4py $(mpi4py-version) \citep{mpi4py2011}" > $@

$(ipydir)/mpmath: $(ipydir)/setuptools \
                  $(tdir)/mpmath-$(mpmath-version).tar.gz
	$(call pybuild, tar xf, mpmath-$(mpmath-version), ,\
	                mpmath $(mpmath-version))

$(ipydir)/numpy: $(ibidir)/unzip \
                 $(ibidir)/openblas \
                 $(ipydir)/setuptools \
                 $(tdir)/numpy-$(numpy-version).zip
	if [ x$(on_mac_os) = xyes ]; then \
	  export LDFLAGS="$(LDFLAGS) -undefined dynamic_lookup -bundle"; \
	else \
	  export LDFLAGS="$(LDFLAGS) -shared"; \
	fi; \
	export CFLAGS="--std=c99 $$CFLAGS"; \
	conf="$$(pwd)/reproduce/software/config/numpy-scipy.cfg"; \
	$(call pybuild, unzip, numpy-$(numpy-version),$$conf, \
	                Numpy $(numpy-version)) \
	&& cp $(dtexdir)/numpy.tex $(ictdir)/ \
	&& echo "Numpy $(numpy-version) \citep{numpy2011}" > $@

$(ipydir)/pexpect: $(ipydir)/setuptools \
                   $(tdir)/pexpect-$(pexpect-version).tar.gz
	$(call pybuild, tar xf, pexpect-$(pexpect-version), ,\
	                Pexpect $(pexpect-version))

$(ibidir)/pip3: $(ipydir)/setuptools \
                $(tdir)/pip-$(pip-version).tar.gz
	$(call pybuild, tar xf, pip-$(pip-version), ,\
	                PiP $(pip-version))

$(ipydir)/pycodestyle: $(ipydir)/setuptools \
                       $(tdir)/pycodestyle-$(pycodestyle-version).tar.gz
	$(call pybuild, tar xf, pycodestyle-$(pycodestyle-version), ,\
	                pycodestyle $(pycodestyle-version))

$(ipydir)/pybind11: $(ibidir)/eigen \
                    $(ibidir)/boost \
                    $(ipydir)/setuptools \
                    $(tdir)/pybind11-$(pybind11-version).tar.gz
	pyhook_after() {
	  cp -r include/pybind11 $(iidir)/python$(python-major-version)m/
	}
	$(call pybuild, tar xf, pybind11-$(pybind11-version), ,\
	                pybind11 $(pybind11-version))

$(ipydir)/pycparser: $(ipydir)/setuptools \
                     $(tdir)/pycparser-$(pycparser-version).tar.gz
	$(call pybuild, tar xf, pycparser-$(pycparser-version), ,\
	                pycparser $(pycparser-version))

$(ipydir)/pyflakes: $(ipydir)/setuptools \
                    $(tdir)/pyflakes-$(pyflakes-version).tar.gz
	$(call pybuild, tar xf, pyflakes-$(pyflakes-version), ,\
	                pyflakes $(pyflakes-version))

$(ipydir)/pyparsing: $(ipydir)/setuptools \
                     $(tdir)/pyparsing-$(pyparsing-version).tar.gz
	$(call pybuild, tar xf, pyparsing-$(pyparsing-version), ,\
	                PyParsing $(pyparsing-version))

$(ipydir)/pypkgconfig: $(ipydir)/setuptools \
                       $(tdir)/pkgconfig-$(pypkgconfig-version).tar.gz
	$(call pybuild, tar xf, pkgconfig-$(pypkgconfig-version), ,
	                pkgconfig $(pypkgconfig-version))

$(ipydir)/python-dateutil: $(ipydir)/six \
                           $(ipydir)/setuptools_scm \
                           $(tdir)/python-dateutil-$(python-dateutil-version).tar.gz
	$(call pybuild, tar xf, python-dateutil-$(python-dateutil-version), ,\
	                python-dateutil $(python-dateutil-version))

$(ipydir)/pyyaml: $(ibidir)/yaml \
                  $(ipydir)/cython \
                  $(tdir)/pyyaml-$(pyyaml-version).tar.gz
	$(call pybuild, tar xf, PyYAML-$(pyyaml-version), ,\
	                PyYAML $(pyyaml-version))

$(ipydir)/requests: $(ipydir)/idna \
                    $(ipydir)/numpy \
                    $(ipydir)/certifi \
                    $(ipydir)/chardet \
                    $(ipydir)/urllib3 \
                    $(tdir)/requests-$(requests-version).tar.gz
	$(call pybuild, tar xf, requests-$(requests-version), ,\
	                Requests $(requests-version))

$(ipydir)/scipy: $(ipydir)/numpy \
                 $(tdir)/scipy-$(scipy-version).tar.gz
	if [ x$(on_mac_os) = xyes ]; then \
	  export LDFLAGS="$(LDFLAGS) -undefined dynamic_lookup -bundle"; \
	else \
	  export LDFLAGS="$(LDFLAGS) -shared"; \
	fi; \
	conf="$$(pwd)/reproduce/software/config/numpy-scipy.cfg"; \
	$(call pybuild, tar xf, scipy-$(scipy-version),$$conf) \
	&& cp $(dtexdir)/scipy.tex $(ictdir)/ \
	&& echo "Scipy $(scipy-version) \citep{scipy2007,scipy2011}" > $@

$(ipydir)/secretstorage: $(ipydir)/jeepney \
                         $(ipydir)/cryptography \
                         $(tdir)/secretstorage-$(secretstorage-version).tar.gz
	$(call pybuild, tar xf, SecretStorage-$(secretstorage-version), ,\
	                SecretStorage $(secretstorage-version))

$(ipydir)/setuptools: $(ibidir)/unzip \
                      $(ibidir)/python \
                      $(tdir)/setuptools-$(setuptools-version).zip
	$(call pybuild, unzip, setuptools-$(setuptools-version), ,\
	                Setuptools $(setuptools-version))

$(ipydir)/setuptools_scm: $(ipydir)/setuptools \
                          $(tdir)/setuptools_scm-$(setuptools_scm-version).tar.gz
	$(call pybuild, tar xf, setuptools_scm-$(setuptools_scm-version), ,\
	                Setuptools-scm $(setuptools_scm-version))

$(ipydir)/sip_tpv: $(ipydir)/sympy \
                   $(ipydir)/astropy \
                   $(tdir)/sip_tpv-$(sip_tpv-version).tar.gz
	$(call pybuild, tar xf, sip_tpv-$(sip_tpv-version), ,) \
	&& cp $(dtexdir)/sip_tpv.tex $(ictdir)/ \
	&& echo "sip_tpv $(sip_tpv-version) \citep{sip-tpv}" > $@


$(ipydir)/six: $(ipydir)/setuptools \
               $(tdir)/six-$(six-version).tar.gz
	$(call pybuild, tar xf, six-$(six-version), ,\
	                Six $(six-version))

$(ipydir)/soupsieve: $(ipydir)/setuptools \
                     $(tdir)/soupsieve-$(soupsieve-version).tar.gz
	$(call pybuild, tar xf, soupsieve-$(soupsieve-version), ,\
	                SoupSieve $(soupsieve-version))

$(ipydir)/sympy: $(ipydir)/mpmath \
                 $(tdir)/sympy-$(sympy-version).tar.gz
	$(call pybuild, tar xf, sympy-$(sympy-version), ,) \
	&& cp $(dtexdir)/sympy.tex $(ictdir)/ \
	&& echo "SymPy $(sympy-version) \citep{sympy}" > $@

$(ipydir)/uncertainties: $(ipydir)/numpy \
                         $(tdir)/uncertainties-$(uncertainties-version).tar.gz
	$(call pybuild, tar xf, uncertainties-$(uncertainties-version), ,\
	                uncertainties $(uncertainties-version))

$(ipydir)/urllib3: $(ipydir)/setuptools \
                   $(tdir)/urllib3-$(urllib3-version).tar.gz
	$(call pybuild, tar xf, urllib3-$(urllib3-version), ,\
	                Urllib3 $(urllib3-version))

$(ipydir)/webencodings: $(ipydir)/setuptools \
                        $(tdir)/webencodings-$(webencodings-version).tar.gz
	$(call pybuild, tar xf, webencodings-$(webencodings-version), ,\
	                Webencodings $(webencodings-version))
