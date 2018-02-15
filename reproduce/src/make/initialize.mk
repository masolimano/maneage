# Initialize the reproduction pipeline.
#
# Original author:
#     Your name <your@email.address>
# Contributing author(s):
# Copyright (C) YYYY, Your Name.
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
mtexdir     = $(texdir)/macros
gconfdir    = reproduce/config/gnuastro
pconfdir    = reproduce/config/pipeline





# Sanity check
# ------------
#
# We need to make sure that the `./configure' command has already been
# run. The output of `./configure' is the `$(pconfdir)/LOCAL.mk' file and
# this is the non-time-stamp prerequisite of $(BDIR), see below.
#
# There is one problem however: if the user hasn't run `./configure' yet,
# then `BDIR' isn't defined (will just evaluate to blank space). Therefore
# it won't appear in the prerequisites and the pipeline will try to build
# the other directories in the top root directory (`/'). To solve this
# problem, when `BDIR' isn't defined, we'll define it with a place-holder
# name ((only so it won't evaluate to blank space). Note that this
# directory will never be built.
ifeq ($(BDIR),)
configure-run = no
BDIR = reproduce/BDIR
else
configure-run = yes
endif
$(pconfdir)/LOCAL.mk:
	@echo
	@echo "================================================================"
	@echo "For the pipeline's local settings, please run this command first"
	@echo "(P.S. this local configuration is only necessary one time)"
	@echo
	@echo "    $$ ./configure"
	@echo "================================================================"
	@echo
	@exit 1





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
$(mtexdir): | $(texdir); mkdir $@
$(BDIR): | $(pconfdir)/LOCAL.mk; mkdir $@
$(texdir) $(lockdir): | $(BDIR); mkdir $@





# Symbolic link to build directory
# --------------------------------
#
# Besides $(BDIR), we are also making a symbolic link to it for easy
# access. Recall that it is recommended that the actual build directory be
# in a completely separate part of the file system (a place that may easily
# be completely deleted).
#
# Note that $(BDIR) might not be an absolute path and this will complicate
# the symbolic link creation. To be generic, we'll first call `readlink' to
# make sure we have an absolute address, then we'll make a symbolic link to
# that.
reproduce/build: | $(BDIR)
	absbdir=$$(readlink -f $(BDIR));                        \
	ln -s $$absbdir $@





# High-level Makefile management
# ------------------------------
#
# About `.PHONY': these are targets that must be built even if a file with
# their name exists. Most don't correspond to a file, but those that do are
# included here ensure that the file is always built in every run: for
# example the pipeline versions may change within two separate runs, so we
# want it to be rebuilt every time.
.PHONY: all clean distclean clean-mmap $(mtexdir)/initialize.tex
distclean: clean; rm -f $(pconfdir)/LOCAL.mk
# --------- Delete for no Gnuastro ---------
clean-mmap:; rm -f reproduce/config/gnuastro/mmap*
# ------------------------------------------
clean: clean-mmap
ifeq ($(configure-run),yes)
	rm -rf $(BDIR)
endif
	rm -f reproduce/build *.pdf *.log *.out *.aux *.auxlock





# Pipeline initialization results
# -------------------------------
#
# This file will store some basic info about the pipeline that is necessary
# for the final PDF. Since these are not version controlled, it must be
# calculated everytime the pipeline is run. So even though this file
# actually exists, it is also aded as a `.PHONY' target above.
$(mtexdir)/initialize.tex: | $(mtexdir)

        # Version of the pipeline.
	@v=$$(git describe --dirty --always);                      \
	echo "\newcommand{\pipelineversion}{$$v}"  > $@

# --------- Delete for no Gnuastro ---------
        # Version of Gnuastro.
	@v=$$(astnoisechisel --version | awk 'NR==1{print $$NF}'); \
	echo "\newcommand{\gnuastroversion}{$$v}" >> $@
# ------------------------------------------

        # Location of the build directory (for LaTeX inputs).
	@echo "\newcommand{\bdir}{$(BDIR)}"       >> $@
