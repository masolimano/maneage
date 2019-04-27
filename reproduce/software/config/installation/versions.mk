# Versions of the various dependencies
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





# Basic/low-level programs and libraires (installed in any case)
# --------------------------------------------------------------
bash-version               = 5.0.7
binutils-version           = 2.32
coreutils-version          = 8.31
curl-version               = 7.63.0
diffutils-version          = 3.7
file-version               = 5.36
findutils-version          = 4.6.0.199-e3fc
gawk-version               = 5.0.0
gcc-version                = 8.3.0
git-version                = 2.21.0
gmp-version                = 6.1.2
grep-version               = 3.3
gzip-version               = 1.10
isl-version                = 0.18
libbsd-version             = 0.9.1
lzip-version               = 1.20
m4-version                 = 1.4.18
make-version               = 4.2.90
metastore-version          = 1.1.2-23-fa9170b
mpfr-version               = 4.0.2
mpc-version                = 1.1.0
ncurses-version            = 6.1
openssl-version            = 1.1.1a
patchelf-version           = 0.9
pkgconfig-version          = 0.29.2
readline-version           = 8.0
sed-version                = 4.7
tar-version                = 1.32
unzip-version              = 6.0
wget-version               = 1.20.3
which-version              = 2.21
xz-version                 = 5.2.4
zip-version                = 3.0
zlib-version               = 1.2.11





# Optional/high-level programs and libraries
# ------------------------------------------
#
# These are programs and libraries that are optional, The ones in
# `reproduce/software/config/installation/TARGETS.mk' will be built as part
# of a project. To specify a software there, just remove the `-version'
# suffix from the list below.
astrometrynet-version      = 0.77
atlas-version              = 3.10.3
cairo-version              = 1.16.0
cdsclient-version          = 3.84
cfitsio-version            = 3.45
cmake-version              = 3.14.2
fftw-version               = 3.3.8
flock-version              = 0.2.3
freetype-version           = 2.9
ghostscript-version        = 9.26
gnuastro-version           = 0.9
gsl-version                = 2.5
hdf5-version               = 1.10.5
libffi-version             = 3.2.1
libjpeg-version            = v9b
libtiff-version            = 4.0.10
libtool-version            = 2.4.6
libxml2-version            = 2.9.9
openblas-version           = 0.3.5
openmpi-version            = 4.0.1
pixman-version             = 0.38.0
python-version             = 3.7.3
scamp-version              = 2.6.7
sextractor-version         = 2.25.0
swarp-version              = 2.38.0
swig-version               = 3.0.12





# Python packages
# ---------------
#
# Similar to optional programs and libraries above.
#
# IMPORTANT: If you intend to change the version of any of the Python
# modules/libraries below, please fix the hash strings of the respective
# URL in `reproduce/software/make/python.mk'.
asn1crypto-version         = 0.24.0
astroquery-version         = 0.3.9
astropy-version            = 3.1.1
beautifulsoup4-version     = 4.7.1
certifi-version            = 2018.11.29
cffi-version               = 1.12.2
chardet-version            = 3.0.4
cryptography-version       = 2.6.1
cycler-version             = 0.10.0
cython-version             = 0.29.6
entrypoints-version        = 0.3
h5py-version               = 2.9.0
html5lib-version           = 1.0.1
idna-version               = 2.8
jeepney-version            = 0.4
kiwisolver-version         = 1.0.1
keyring-version            = 18.0.0
matplotlib-version         = 3.0.2
mpi4py-version             = 3.0.1
mpmath-version             = 1.1.0
numpy-version              = 1.16.2
pip-version                = 19.0.2
pycparser-version          = 2.19
pyparsing-version          = 2.3.1
pypkgconfig-version        = 1.5.1
python-dateutil-version    = 2.8.0
requests-version           = 2.21.0
scipy-version              = 1.2.1
secretstorage-version      = 3.1.1
setuptools-version         = 40.8.0
setuptools_scm-version     = 3.2.0
sip_tpv-version            = 1.1
six-version                = 1.12.0
soupsieve-version          = 1.8
sympy-version              = 1.4
urllib3-version            = 1.24.1
virtualenv-version         = 16.4.0
webencodings-version       = 0.5.1





# Special programs and libraries
# ------------------------------
#
# When updating the version of these libraries, please look into the build
# rule first: In one way or another, the version string becomes necessary
# during their build and must be accounted for.
#
# Special notes:
#   - `libpng' is downgraded: the current installation of `netpbm' requires
#   a version less than 1.5.
#   - `netpbm' questions in the configure steps maybe change with different
#   or new versions.

# Basic/low-level
bzip2-version              = 1.0.6

# Optional/high-level
lapack-version             = 3.8.0
libgit2-version            = 0.26.0
libpng-version             = 1.4.22
netpbm-version             = 10.86.99
wcslib-version             = 6.2
