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
texdir = $(BDIR)/tex
lockdir = $(BDIR)/locks
bdirsym = reproduce/build
mtexdir = $(texdir)/macros
pconfdir = reproduce/config/pipeline





# Make the high-level level directories
# ------------------------------
#
# These are just the top-level directories for all the separate steps. The
# directories (or possible sub-directories) for individual steps will be
# defined and added within their own Makefiles.
$(BDIR):; mkdir $@;
$(mtexdir): | $(texdir); mkdir $@
$(texdir) $(lockdir): | $(BDIR); mkdir $@





# High-level Makefile management
# ------------------------------
#
# About `.PHONY': these are targets that must be built even if a file with
# their name exists. Most don't correspond to a file, but those that do are
# included here ensure that the file is always built in every run: for
# example the pipeline versions may change within two separate runs, so we
# want it to be rebuilt every time.
.PHONY: all clean clean-mmap $(mtexdir)/initialize.tex
clean-mmap:; rm -f reproduce/config/gnuastro/mmap*
clean:
	rm -rf $(BDIR) $(bdirsym) *.pdf *.log *.out *.aux *.auxlock \
               reproduce/config/gnuastro/mmap*





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

        # Version of Gnuastro.
	@v=$$(astnoisechisel --version | awk 'NR==1{print $$NF}'); \
	echo "\newcommand{\gnuastroversion}{$$v}" >> $@

        # Location of the build directory (for LaTeX inputs).
	echo "\newcommand{\bdir}{$(BDIR)}"        >> $@





# Symbolic link to build directory
# --------------------------------
#
# Besides $(BDIR), we are also making a symbolic link to it if $(bdirsym)
# is not empty. In case this symbolic link is not needed, simply remove its
# value from the definitions above. In that case, it will be read as a
# blank (non-existant).
#
# Note that $(BDIR) might not be an absolute path and this will complicate
# the symbolic link creation. To be generic, we'll first call `readlink' to
# make sure we have an absolute address, then we'll make a symbolic link to
# that.
ifneq ($(bdirsym),)
$(bdirsym): | $(BDIR)
	absbdir=$$(readlink -f $(BDIR));                        \
	ln -s $$absbdir $(bdirsym)
endif
