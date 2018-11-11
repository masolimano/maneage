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
SHELL           := .local/bin/bash
PATH            := .local/bin:$(PATH)
LDFLAGS         := -L.local/lib $(LDFLAGS)
CPPFLAGS        := -I.local/include $(CPPFLAGS)
LD_LIBRARY_PATH := .local/lib:$(LD_LIBRARY_PATH)





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
	rm -rf $(BDIR)
	rm -f reproduce/build *.pdf *.log *.out *.aux *.auxlock
distclean: clean
	rm -f Makefile $(pconfdir)/LOCAL.mk .gnuastro




# Pipeline initialization results
# -------------------------------
#
# This file will store some basic info about the pipeline that is necessary
# for the final PDF. Since these are not version controlled, it must be
# calculated everytime the pipeline is run. So even though this file
# actually exists, it is also aded as a `.PHONY' target above.
$(mtexdir)/initialize.tex: | $(mtexdir)

        # Version of the pipeline.
	@v=$$(git describe --dirty --always);
	echo "\newcommand{\pipelineversion}{$$v}"  > $@

# --------- Delete for no Gnuastro ---------
        # Version of Gnuastro.
	@v=$$(astnoisechisel --version | awk 'NR==1{print $$NF}');
	echo "\newcommand{\gnuastroversion}{$$v}" >> $@
# ------------------------------------------

        # Location of the build directory (for LaTeX inputs).
	@echo "\newcommand{\bdir}{$(BDIR)}"       >> $@
