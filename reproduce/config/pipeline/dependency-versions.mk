# Versions of the various dependnecies

# Programs
bash-version               = 5.0
binutils-version           = 2.31.1
bzip2-version              = 1.0.6
cmake-version              = 3.12.4
coreutils-version          = 8.30
diffutils-version          = 3.7
findutils-version          = 4.6.0.199-e3fc
flock-version              = 0.2.3
gawk-version               = 4.2.1
gcc-version                = 8.2.0
ghostscript-version        = 9.26
git-version                = 2.20.1
gmp-version                = 6.1.2
gnuastro-version           = 0.8
grep-version               = 3.3
gzip-version               = 1.10
isl-version                = 0.18
libtool-version            = 2.4.6
libbsd-version             = 0.9.1
lzip-version               = 1.20
make-version               = 4.2.90
metastore-version          = 1.1.2-23-fa9170b
mpfr-version               = 4.0.1
mpc-version                = 1.1.0
ncurses-version            = 6.1
openssl-version            = 1.1.1a
patchelf-version           = 0.9
pkgconfig-version          = 0.29.2
python-version             = 3.6.8
readline-version           = 8.0
sed-version                = 4.7
tar-version                = 1.31
unzip-version              = 6.0
wget-version               = 1.20.1
which-version              = 2.21
xz-version                 = 5.2.4
zip-version                = 3.0

# Libraries
cfitsio-version            = 3.45
curl-version               = 7.63.0
gsl-version                = 2.5
libjpeg-version            = v9b
libtiff-version            = 4.0.10
zlib-version               = 1.2.11

# Python packages
# ---------------
#
# IMPORTANT: Fix url in `reproduce/src/make/dependencies.mk'
# if changing the version
astroquery-version         = 0.3.9
astropy-version            = 3.1.1
beautifulsoup4-version     = 4.7.1
certifi-version            = 2018.11.29
chardet-version            = 3.0.4
entrypoints-version        = 0.3
html5lib-version           = 1.0.1
idna-version               = 2.8
keyring-version            = 18.0.0
numpy-version              = 1.16.1
pip-version                = 19.0.2
requests-version           = 2.21.0
setuptools-version         = 40.8.0
setuptools_scm-version     = 3.2.0
six-version                = 1.12.0
soupsieve-version          = 1.8
urllib3-version            = 1.24.1
virtualenv-version         = 16.4.0
webencodings-version       = 0.5.1

# Special libraries
# -----------------
#
# The shared library name of the following libraries is explicity mentioned
# the software build Makefiles (`reproduce/src/make/dependencies*.mk'). If
# you change their version, also please change the explicit shared library
# names also.
libgit2-version            = 0.26.0
wcslib-version             = 6.2
