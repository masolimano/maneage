# Initialize the reproduction pipeline.
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
texbdir     = $(texdir)/build
tikzdir     = $(texbdir)/tikz
mtexdir     = $(texdir)/macros
gconfdir    = reproduce/config/gnuastro
pconfdir    = reproduce/config/pipeline





# System's environment
# --------------------
#
# Before defining the local sub-environment here, we'll need to save the
# system's environment for some scenarios (for example after `clean'ing the
# built programs).
sys-path := $(PATH)
sys-rm   := $(shell which rm)



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
.SHELLFLAGS      = -ec
LD_LIBRARY_PATH := .local/lib
PATH            := .local/bin
LDFLAGS         := -L.local/lib
SHELL           := .local/bin/bash
CPPFLAGS        := -I.local/include





# Make the high-level level directories
# -------------------------------------
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
	$(sys-rm) -f Makefile $(pconfdir)/LOCAL.mk .gnuastro .local





# Check the version of programs which write their version
# -------------------------------------------------------
vercheck = prog="$(strip $(1))";                                          \
	   ver="$(strip $(2))";                                           \
	   name="$(strip $(3))";                                          \
	   macro="$(strip $(4))";                                         \
	   v=$$($$prog --version | awk '/'$$ver'/{print "y"}');           \
	   if [ x$$v != xy ]; then                                        \
	     echo; echo "PIPELINE ERROR: Not running $$name $$ver"; echo; \
	     exit 1;                                                      \
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

        # Versions of programs (same order as `dependency-versions.mk').
	$(call vercheck, bash, $(bash-version), GNU Bash, bashversion)
	$(call vercheck, cmake, $(cmake-version), CMake, cmakeversion)
	$(call vercheck, ls, $(coreutils-version), GNU Coreutils,       \
                         coreutilsversion)
	$(call vercheck, awk, $(gawk-version), GNU AWK, gawkversion)
	$(call vercheck, gs, $(ghostscript-version), GPL Ghostscript,   \
	                 ghostscriptversion)
	$(call vercheck, git, $(git-version), Git, gitversion)
	$(call vercheck, astnoisechisel, $(gnuastro-version), Gnuastro, \
                         gnuastroversion)
	$(call vercheck, grep, $(grep-version), GNU Grep, grepversion)
	$(call vercheck, make, $(make-version), GNU Make, makeversion)
	$(call vercheck, sed, $(sed-version), GNU SED, sedversion)
