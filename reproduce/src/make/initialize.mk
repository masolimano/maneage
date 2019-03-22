# Initialize the reproduction pipeline.
#
# Original author:
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Contributing author(s):
#     Your name <your@email.address>
# Copyright (C) 2018-2019, Your Name.
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





# High-level directory definitions
# --------------------------------
#
# Basic directories that are used throughout the whole pipeline.
#
# Locks are used to make sure that an operation is done in series not in
# parallel (even if Make is run in parallel with the `-j' option). The most
# common case is downloads which are better done in series and not in
# parallel. Also, some programs may not be thread-safe, therefore it will
# be necessary to put a lock on them. This pipeline uses the `flock'
# program to achieve this.
texdir      = $(BDIR)/tex
srcdir      = reproduce/src
lockdir     = $(BDIR)/locks
indir       = $(BDIR)/inputs
mtexdir     = $(texdir)/macros
pconfdir    = reproduce/config/pipeline
installdir  = $(BDIR)/dependencies/installed
# --------- Delete for no Gnuastro ---------
gconfdir    = reproduce/config/gnuastro
# ------------------------------------------





# TeX build directory
# ------------------
#
# In scenarios where multiple users are working on the pipeline
# simultaneously, they can't all build the final paper together, there will
# be conflicts! It is possible to manage the working on the analysis, so no
# conflict is caused in that phase, but it would be very slow to only let
# one of the project members to build the paper at every instance
# (independent parts of the paper can be added to it independently). To fix
# this problem, when we are in a group setting, we'll use the user's ID to
# create a separate LaTeX build directory for each user.
#
# The same logic applies to the final paper PDF: each user will create a
# separte final PDF (for example `paper-user1.pdf' and `paper-user2.pdf')
# and no `paper.pdf' will be built. This isn't a problem because
# `initialize.tex' is a .PHONY prerequisite, so the rule to build the final
# paper is always executed (even if it is present and nothing has
# changed). So in terms of over-all efficiency and processing steps, this
# doesn't change anything.
ifeq (x$(GROUP-NAME),x)
texbdir     = $(texdir)/build
final-paper = paper.pdf
else
user        = $(shell whoami)
texbdir     = $(texdir)/build-$(user)
final-paper = paper-$(user).pdf
endif
tikzdir     = $(texbdir)/tikz





# Original system environment
# ---------------------------
#
# Before defining the local sub-environment here, we'll need to save the
# system's environment for some scenarios (for example after `clean'ing the
# built programs).
sys-path := $(PATH)
sys-rm   := $(shell which rm)
curdir   := $(shell echo $$(pwd))





# High level environment
# ----------------------
#
# We want the full recipe to be executed in one call to the shell. Also we
# want Make to run the specific version of Bash that we have installed
# during `./configure' time.
#
# Regarding the directories, this pipeline builds its major dependencies
# itself and doesn't use the local system's default tools. With these
# environment variables, we are setting it to prefer the software we have
# build here.
.ONESHELL:
.SHELLFLAGS             = -ec
export CCACHE_DISABLE  := 1
export PATH            := $(installdir)/bin
export LD_LIBRARY_PATH := $(installdir)/lib
export LDFLAGS         := -L$(installdir)/lib
export SHELL           := $(installdir)/bin/bash
export CPPFLAGS        := -I$(installdir)/include





# Python enviroment
# -----------------
#
# The main Python environment variable is `PYTHONPATH'. However, so far we
# have found several other Python-related environment variables on some
# systems which might interfere. To be safe, we are removing all their
# values.
export PYTHONPATH             := $(installdir)/lib/python/site-packages
export PYTHONPATH3            := $(PYTHONPATH)
export _LMFILES_              :=
export PYTHONPATH2            :=
export LOADEDMODULES          :=
export MPI_PYTHON_SITEARCH    :=
export MPI_PYTHON2_SITEARCH   :=
export MPI_PYTHON3_SITEARCH   :=





# High-level level directories
# ----------------------------
#
# These are just the top-level directories for all the separate steps. The
# directories (or possible sub-directories) for individual steps will be
# defined and added within their own Makefiles.
#
# IMPORTANT NOTE for $(BDIR)'s dependency: it only depends on the existance
# (not the time-stamp) of `$(pconfdir)/LOCAL.mk'. So the user can make any
# changes within that file and if they don't affect the pipeline. For
# example a change of the top $(BDIR) name, while the contents are the same
# as before.
#
# The `.SUFFIXES' rule with no prerequisite is defined to eliminate all the
# default implicit rules. The default implicit rules are to do with
# programming (for example converting `.c' files to `.o' files). The
# problem they cause is when you want to debug the make command with `-d'
# option: they add too many extra checks that make it hard to find what you
# are looking for in this pipeline.
.SUFFIXES:
$(texdir) $(lockdir): | $(BDIR); mkdir $@
$(mtexdir) $(texbdir): | $(texdir); mkdir $@
$(tikzdir): | $(texbdir); mkdir $@ && ln -s $(tikzdir) tex/tikz





# High-level Makefile management
# ------------------------------
#
# About `.PHONY': these are targets that must be built even if a file with
# their name exists.
#
# Only `$(mtexdir)/initialize.tex' corresponds to a file. This is because
# we want to ensure that the file is always built in every run: it contains
# the pipeline version which may change between two separate runs, even
# when no file actually differs.
packagebasename := $(shell echo paper-$$(git describe --dirty --always))
packagecontents = $(texdir)/$(packagebasename)
.PHONY: all clean dist dist-zip distclean clean-mmap $(packagecontents) \
        $(mtexdir)/initialize.tex

# --------- Delete for no Gnuastro ---------
clean-mmap:; rm -f reproduce/config/gnuastro/mmap*
# ------------------------------------------

clean: clean-mmap
        # Delete the top-level PDF file.
	rm -f *.pdf

        # Delete all the built outputs except the dependency
        # programs. We'll use Bash's extended options builtin (`shopt') to
        # enable "extended glob" (for listing of files). It allows extended
        # features like ignoring the listing of a file with `!()' that we
        # are using afterwards.
	shopt -s extglob
	rm -rf $(BDIR)/!(dependencies)

distclean: clean
        # We'll be deleting the built environent programs and just need the
        # `rm' program. So for this recipe, we'll use the host system's
        # `rm', not our own.
	$(sys-rm) -rf $(BDIR) reproduce/build
	$(sys-rm) -f Makefile .gnuastro .local
	$(sys-rm) -f $(pconfdir)/LOCAL.mk $(gconfdir)/gnuastro-local.conf





# Packaging rules
# ---------------
#
# With the rules in this section, you can package the project in a state
# that is ready for building the final PDF with LaTeX. This is useful for
# collaborators who only want to contribute to the text of your project,
# without having to worry about the technicalities of the analysis.
$(packagecontents): | $(texdir)

        # Set up the output directory, delete it if it exists and remake it
        # to fill with new contents.
	dir=$(texdir)/$(packagebasename)
	rm -rf $$dir
	mkdir $$dir

        # Build a small Makefile to help in automatizing the paper building
        # (including the bibliography).
	m=$$dir/Makefile
	echo   "paper.pdf: paper.tex paper.bbl"                   > $$m
	printf "\tpdflatex -shell-escape -halt-on-error paper\n" >> $$m
	echo   "paper.bbl: tex/src/references.tex"               >> $$m
	printf "\tpdflatex -shell-escape -halt-on-error paper\n" >> $$m
	printf "\tbiber paper\n"                                 >> $$m
	echo   ".PHONY: clean"                                   >> $$m
	echo   "clean:"                                          >> $$m
	printf "\trm -f *.aux *.auxlock *.bbl *.bcf\n"           >> $$m
	printf "\trm -f *.blg *.log *.out *.run.xml\n"           >> $$m

        # Copy the top-level contents into it.
	cp configure COPYING for-group README.md README-hacking.md $$dir/

        # Build the top-level directories.
	mkdir $$dir/reproduce $$dir/tex $$dir/tex/tikz $$dir/tex/pipeline

        # Copy all the `reproduce' contents except for the `build' symbolic
        # link.
	shopt -s extglob
	cp -r tex/src                            $$dir/tex/src
	cp tex/tikz/*.pdf                        $$dir/tex/tikz
	cp -r reproduce/!(build)                 $$dir/reproduce
	cp -r tex/pipeline/!($(packagebasename)) $$dir/tex/pipeline

        # Clean up un-necessary/local files: 1) the $(texdir)/build*
        # directories (when building in a group structure, there will be
        # `build-user1', `build-user2' and etc), are just temporary LaTeX
        # build files and don't have any relevant/hand-written files in
        # them. 2) The `LOCAL.mk' and `gnuastro-local.conf' files just have
        # this machine's local settings and are irrelevant for anyone else.
	rm -rf $$dir/tex/pipeline/build*
	rm $$dir/reproduce/config/pipeline/LOCAL.mk
	rm $$dir/reproduce/config/gnuastro/gnuastro-local.conf

        # PIPELINE SPECIFIC: under this comment, copy any other file for
        # packaging, or remove any of the copied files above to suite your
        # project.

        # Since the packaging is mainly intended for high-level building of
        # the PDF with LaTeX, we'll comment the `makepdf' LaTeX macro in
        # the paper.
	sed -e's|\\newcommand{\\makepdf}{}|%\\newcommand{\\makepdf}{}|' \
	    paper.tex > $$dir/paper.tex

        # Just in case the package users want to rebuild some of the
        # figures (manually un-comments the `makepdf' command we commented
        # above), correct the TikZ external directory, so the figures can
        # be rebuilt.
	pgfsettings="$$dir/tex/src/preamble-pgfplots.tex"
	sed -e's|{tikz/}|{tex/tikz/}|' $$pgfsettings > $$pgfsettings.new
	mv $$pgfsettings.new $$pgfsettings

        # Clean temporary (currently those ending in `~') files.
	cd $(texdir)
	find $(packagebasename) -name \*~ -delete

# Package into `.tar.gz'.
dist: $(packagecontents)
	curdir=$$(pwd)
	cd $(texdir)
	tar -cf $(packagebasename).tar $(packagebasename)
	gzip -f --best $(packagebasename).tar
	cd $$curdir
	mv $(texdir)/$(packagebasename).tar.gz ./

# Package into `.zip'.
dist-zip: $(packagecontents)
	curdir=$$(pwd)
	cd $(texdir)
	zip -q -r $(packagebasename).zip $(packagebasename)
	cd $$curdir
	mv $(texdir)/$(packagebasename).zip ./





# Check the version of programs which write their version
# -------------------------------------------------------
pvcheck = prog="$(strip $(1))";                                          \
	  ver="$(strip $(2))";                                           \
	  name="$(strip $(3))";                                          \
	  macro="$(strip $(4))";                                         \
	  verop="$(strip $(5))";                                         \
	  if [ "x$$verop" = x ]; then V="--version"; else V=$$verop; fi; \
	  v=$$($$prog $$V | awk '/'$$ver'/{print "y"; exit 0}');         \
	  if [ x$$v != xy ]; then                                        \
	    echo; echo "PIPELINE ERROR: Not running $$name $$ver"; echo; \
	    exit 1;                                                      \
	  fi;                                                            \
	  echo "\newcommand{\\$$macro}{$$ver}" >> $@

lvcheck = idir=$(BDIR)/dependencies/installed/include;                   \
	  f="$$idir/$(strip $(1))";                                      \
	  ver="$(strip $(2))";                                           \
	  name="$(strip $(3))";                                          \
	  macro="$(strip $(4))";                                         \
	  v=$$(awk '/^\#/&&/define/&&/'$$ver'/{print "y";exit 0}' $$f);  \
	  if [ x$$v != xy ]; then                                        \
	    echo; echo "PIPELINE ERROR: Not linking with $$name $$ver";  \
	    echo; exit 1;                                                \
	  fi;                                                            \
	  echo "\newcommand{\\$$macro}{$$ver}" >> $@




# Pipeline initialization results
# -------------------------------
#
# This file will store some basic info about the pipeline that is necessary
# for the final PDF. Since these are not version controlled, it must be
# calculated everytime the pipeline is run. So even though this file
# actually exists, it is also aded as a `.PHONY' target above.
$(mtexdir)/initialize.tex: | $(mtexdir)

        # Version of the pipeline and build directory (for LaTeX inputs).
	@v=$$(git describe --dirty --always);
	echo "\newcommand{\pipelineversion}{$$v}"  > $@

        # Versions of programs (same order as 'dependency-versions.mk'),
        # ordered alphabetically (by their executable name).
	echo "\newcommand{\\bashversion}{$(bash-version)}"              >> $@
#	echo "\newcommand{\\bashversion}{$(binutils-version)}"          >> $@
	echo "\newcommand{\\bziptwoversion}{$(bzip2-version)}"          >> $@
	echo "\newcommand{\\cmakeversion}{$(cmake-version)}"            >> $@
	echo "\newcommand{\\coreutilsversion}{$(coreutils-version)}"    >> $@
	echo "\newcommand{\\diffutilsversion}{$(diffutils-version)}"    >> $@
	echo "\newcommand{\\findutilsversion}{$(findutils-version)}"    >> $@
	echo "\newcommand{\\flockversion}{$(flock-version)}"            >> $@
	echo "\newcommand{\\freetypeversion}{$(freetype-version)}"      >> $@
	echo "\newcommand{\\gawkversion}{$(gawk-version)}"              >> $@
	echo "\newcommand{\\gccversion}{$(gcc-version)}"                >> $@
	echo "\newcommand{\\ghostscriptversion}{$(ghostscript-version)}" >> $@
	echo "\newcommand{\\gitversion}{$(git-version)}"                >> $@
	echo "\newcommand{\\gmpversion}{$(gmp-version)}"                >> $@
	echo "\newcommand{\\gnuastroversion}{$(gnuastro-version)}"      >> $@
	echo "\newcommand{\\grepversion}{$(grep-version)}"              >> $@
	echo "\newcommand{\\gzipversion}{$(gzip-version)}"              >> $@
	echo "\newcommand{\\islversion}{$(isl-version)}"                >> $@
	echo "\newcommand{\\lzipversion}{$(lzip-version)}"              >> $@
	echo "\newcommand{\\makeversion}{$(make-version)}"              >> $@
	echo "\newcommand{\\metastoreversion}{$(metastore-version)}"    >> $@
	echo "\newcommand{\\mpfrversion}{$(mpfr-version)}"              >> $@
	echo "\newcommand{\\mpcversion}{$(mpc-version)}"                >> $@
	echo "\newcommand{\\ncursesversion}{$(ncurses-version)}"        >> $@
	echo "\newcommand{\\opensslversion}{$(openssl-version)}"        >> $@
	echo "\newcommand{\\patchelfversion}{$(patchelf-version)}"      >> $@
	echo "\newcommand{\\pkgconfigversion}{$(pkgconfig-version)}"    >> $@
	echo "\newcommand{\\pythonversion}{$(python-version)}"          >> $@
	echo "\newcommand{\\readlineversion}{$(readline-version)}"      >> $@
	echo "\newcommand{\\sedversion}{$(sed-version)}"                >> $@
	echo "\newcommand{\\swarpversion}{$(swarp-version)}"            >> $@
	echo "\newcommand{\\tarversion}{$(tar-version)}"                >> $@
	echo "\newcommand{\\unzipversion}{$(unzip-version)}"            >> $@
	echo "\newcommand{\\wgetversion}{$(wget-version)}"              >> $@
	echo "\newcommand{\\whichversion}{$(which-version)}"            >> $@
	echo "\newcommand{\\xzversion}{$(xz-version)}"                  >> $@
	echo "\newcommand{\\zipversion}{$(zip-version)}"                >> $@

        # Libraries.
	echo "\newcommand{\\atlasversion}{$(cfitsio-version)}"          >> $@
	echo "\newcommand{\\cfitsioversion}{$(cfitsio-version)}"        >> $@
	echo "\newcommand{\\curlversion}{$(curl-version)}"              >> $@
	echo "\newcommand{\\gslversion}{$(gsl-version)}"                >> $@
	echo "\newcommand{\\lapack}{$(lapack-version)}"                 >> $@
	echo "\newcommand{\\libbsdversion}{$(libbsd-version)}"          >> $@
	echo "\newcommand{\\libffiversion}{$(libffi-version)}"          >> $@
	echo "\newcommand{\\libgittwoversion}{$(libgit2-version)}"      >> $@
	echo "\newcommand{\\libjpegversion}{$(libjpeg-version)}"        >> $@
	echo "\newcommand{\\libpngversion}{$(libpng-version)}"          >> $@
	echo "\newcommand{\\libtiffversion}{$(libtiff-version)}"        >> $@
	echo "\newcommand{\\libtoolversion}{$(libtool-version)}"        >> $@
	echo "\newcommand{\\wcslibversion}{$(wcslib-version)}"          >> $@
	echo "\newcommand{\\zlibversion}{$(zlib-version)}"              >> $@

        # Python modules.
	echo "\newcommand{\\asncryptoversion}{$(asn1crypto-version)}"   >> $@
	echo "\newcommand{\\astroqueryversion}{$(astroquery-version)}"  >> $@
	echo "\newcommand{\\astropyversion}{$(astropy-version)}"        >> $@
	echo "\newcommand{\\beautifulsoupversion}{$(beautifulsoup4-version)}" >> $@
	echo "\newcommand{\\certifiversion}{$(certifi-version)}"        >> $@
	echo "\newcommand{\\cffiversion}{$(cffi-version)}"              >> $@
	echo "\newcommand{\\chardetversion}{$(chardet-version)}"        >> $@
	echo "\newcommand{\\cryptographyversion}{$(cryptography-version)}" >> $@
	echo "\newcommand{\\cyclerversion}{$(cycler-version)}"          >> $@
	echo "\newcommand{\\entrypointsversion}{$(entrypoints-version)}" >> $@
	echo "\newcommand{\\hpyversion}{$(h5py-version)}"               >> $@
	echo "\newcommand{\\htmlfivelibversion}{$(html5lib-version)}"   >> $@
	echo "\newcommand{\\idaversion}{$(idna-version)}"               >> $@
	echo "\newcommand{\\jeepneyversion}{$(jeepney-version)}"        >> $@
	echo "\newcommand{\\kiwisolverversion}{$(kiwisolver-version)}"  >> $@
	echo "\newcommand{\\keyringversion}{$(keyring-version)}"        >> $@
	echo "\newcommand{\\matplotlibversion}{$(matplotlib-version)}"  >> $@
	echo "\newcommand{\\numpyversion}{$(numpy-version)}"            >> $@
#	echo "\newcommand{\\pipversion}{$(pip-version)}"                >> $@
	echo "\newcommand{\\pycparserversion}{$(pycparser-version)}"    >> $@
	echo "\newcommand{\\pyparsingversion}{$(pyparsing-version)}"    >> $@
	echo "\newcommand{\\pythondateutilversion}{$(python-dateutil-version)}" >> $@
	echo "\newcommand{\\requestsversion}{$(requests-version)}"      >> $@
	echo "\newcommand{\\scipyversion}{$(scipy-version)}"            >> $@
	echo "\newcommand{\\screenstorageversion}{$(secretstorage-version)}" >> $@
	echo "\newcommand{\\setuptoolsversion}{$(setuptools-version)}"  >> $@
	echo "\newcommand{\\setuptoolsscmversion}{$(setuptools_scm-version)}"  >> $@
	echo "\newcommand{\\sixversion}{$(six-version)}"                >> $@
	echo "\newcommand{\\soupsieveversion}{$(soupsieve-version)}"    >> $@
	echo "\newcommand{\\urllibthreeversion}{$(urllib3-version)}"    >> $@
#	echo "\newcommand{\\virtualenvversion}{$(virtualenv-version)}"  >> $@
	echo "\newcommand{\\webencodingsversion}{$(webencodings-version)}" >> $@

        # TeX package versions
	cat $(BDIR)/dependencies/texlive-versions.tex >> $@
