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
ifeq ($(FOR-GROUP),yes)
user        = $(shell whoami)
texbdir     = $(texdir)/build-$(user)
final-paper = paper-$(user).pdf
else
texbdir     = $(texdir)/build
final-paper = paper.pdf
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
$(tikzdir): | $(texbdir); mkdir $@
$(texdir) $(lockdir): | $(BDIR); mkdir $@
$(mtexdir) $(texbdir): | $(texdir); mkdir $@





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
.PHONY: all clean distclean clean-mmap $(mtexdir)/initialize.tex
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





# Check the version of programs which write their version
# -------------------------------------------------------
pvcheck = prog="$(strip $(1))";                                          \
	  ver="$(strip $(2))";                                           \
	  name="$(strip $(3))";                                          \
	  macro="$(strip $(4))";                                         \
	  v=$$($$prog --version | awk '/'$$ver'/{print "y"; exit 0}');   \
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
	@echo "\newcommand{\bdir}{$(BDIR)}"       >> $@

        # Versions of programs (same order as 'dependency-versions.mk').
	$(call pvcheck, awk, $(gawk-version), GNU AWK, gawkversion)
	$(call pvcheck, bash, $(bash-version), GNU Bash, bashversion)
	$(call pvcheck, cmake, $(cmake-version), CMake, cmakeversion)
	$(call pvcheck, curl, $(curl-version), cURL, curlversion)
	$(call pvcheck, diff, $(diffutils-version), GNU Diffutils,     \
	                diffutilsversion)
	$(call pvcheck, find, $(findutils-version), GNU Findutils,     \
	                findutilsversion)
	$(call pvcheck, gs, $(ghostscript-version), GPL Ghostscript,   \
	                ghostscriptversion)
	$(call pvcheck, git, $(git-version), Git, gitversion)
	$(call pvcheck, grep, $(grep-version), GNU Grep, grepversion)
	$(call pvcheck, glibtool, $(libtool-version), GNU Libtool,     \
	                libtoolversion)
	$(call pvcheck, gzip, $(gzip-version), GNU Gzip, gzipversion)
	$(call pvcheck, ls, $(coreutils-version), GNU Coreutils,       \
	                coreutilsversion)
	$(call pvcheck, lzip, $(lzip-version), Lzip, lzipversion)
	$(call pvcheck, make, $(make-version), GNU Make, makeversion)

	$(call pvcheck, pkg-config, $(pkgconfig-version), pkg-config,  \
	                pkgconfigversion)
	$(call pvcheck, sed, $(sed-version), GNU SED, sedversion)
	$(call pvcheck, tar, $(tar-version), GNU Tar, tarversion)
	$(call pvcheck, wget, $(wget-version), GNU Wget, wgetversion)
	$(call pvcheck, which, $(which-version), GNU Which, whichversion)
	$(call pvcheck, xz, $(xz-version), XZ Utils, xzversion)

        # --------- Delete for no Gnuastro ---------
	$(call pvcheck, astnoisechisel, $(gnuastro-version), Gnuastro, \
                        gnuastroversion)
        # ------------------------------------------

        # Bzip2 prints its version in standard error, not standard output!
	echo "" | bzip2 --version &> $@_bzip2_ver;
	v=$$(awk 'NR==1 && /'$(bzip2-version)'/{print "y"; exit 0}' \
	         $@_bzip2_ver);
	if [ x$$v != xy ]; then
	  echo; echo "PIPELINE ERROR: Not running Bzip2 $(bzip2-version)";
	  echo; exit 1;
	fi;
	rm $@_bzip2_ver
	echo "\newcommand{\\bziptwoversion}{$(bzip2-version)}" >> $@

        # Unfortunately we couldn't find a way to retrieve the version of
        # the discoteq `flock' that we are using here. So we'll just repot
        # the version we downloaded and installed.
	echo "\newcommand{\\flockversion}{$(flock-version)}" >> $@





        # Versions of libraries.
	$(call lvcheck, fitsio.h, $(cfitsio-version), CFITSIO, cfitsioversion)
	$(call lvcheck, gsl/gsl_version.h, $(gsl-version),  \
	                GNU Scientific Library (GSL), gslversion)
        ########## libjpeg not  yet checked.
	$(call lvcheck, git2/version.h, $(libgit2-version), Libgit2, \
	                libgitwoversion)
	$(call lvcheck, openssl/opensslv.h, $(openssl-version), OpenSSL, \
	                opensslversion)
	$(call lvcheck, ncursesw/curses.h, $(ncurses-version), GNU NCURSES, \
	                ncursesversion)
	$(call lvcheck, readline/readline.h, $(readline-version), GNU Readline, \
	                readlineversion)
	$(call lvcheck, tiffvers.h, $(libtiff-version), Libtiff, \
	                libtiffversion)
	$(call lvcheck, wcslib/wcsconfig.h, $(wcslib-version), WCSLIB, \
	                wcslibversion)
	$(call lvcheck, zlib.h, $(zlib-version), zlib, zlibversion)

        # TeX package versions
	cat $(BDIR)/dependencies/texlive-versions.tex >> $@
