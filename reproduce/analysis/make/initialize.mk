# Project initialization.
#
# Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# High-level directory definitions
# --------------------------------
#
# Basic directories that are used throughout the project.
#
# Locks are used to make sure that an operation is done in series not in
# parallel (even if Make is run in parallel with the `-j' option). The most
# common case is downloads which are better done in series and not in
# parallel. Also, some programs may not be thread-safe, therefore it will
# be necessary to put a lock on them. This project uses the `flock' program
# to achieve this.
texdir      = $(BDIR)/tex
lockdir     = $(BDIR)/locks
indir       = $(BDIR)/inputs
prepdir     = $(BDIR)/prepare
mtexdir     = $(texdir)/macros
bashdir     = reproduce/analysis/bash
pconfdir    = reproduce/analysis/config
installdir  = $(BDIR)/software/installed
# --------- Delete for no Gnuastro ---------
gconfdir    = reproduce/analysis/config/gnuastro
# ------------------------------------------





# Preparation phase
# -----------------
#
# This Makefile is loaded both for the `prepare' phase and the `make'
# phase. But the preparation files should be dealt with differently
# (depending on the phase). In the `prepare' phase, the main directory
# should be created, and in the `make' phase, its contents should be
# loaded.
#
# If you don't need any preparation, please simply comment these lines.
ifeq (x$(project-phase),xprepare)
$(prepdir):; mkdir $@
else
include $(BDIR)/software/preparation-done.mk
ifeq (x$(include-prepare-results),xyes)
include $(prepdir)/*.mk
endif
endif





# TeX build directory
# ------------------
#
# In scenarios where multiple users are working on the project
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
texbtopdir  = build
final-paper = paper.pdf
else
user        = $(shell whoami)
texbtopdir  = build-$(user)
final-paper = paper-$(user).pdf
endif
texbdir     = $(texdir)/$(texbtopdir)
tikzdir     = $(texbdir)/tikz





# Original system environment
# ---------------------------
#
# Before defining the local sub-environment here, we'll need to save the
# system's environment for some scenarios (for example after `clean'ing the
# built programs).
curdir   := $(shell echo $$(pwd))





# High level environment
# ----------------------
#
# We want the full recipe to be executed in one call to the shell. Also we
# want Make to run the specific version of Bash that we have installed
# during `./project configure' time.
#
# Regarding the directories, this project builds its major dependencies
# itself and doesn't use the local system's default tools. With these
# environment variables, we are setting it to prefer the software we have
# build here.
#
# `TEXINPUTS': we have to remove all possible user-specified directories to
# avoid conflicts with existing TeX Live solutions. Later (in `paper.mk'),
# we are also going to overwrite `TEXINPUTS' just before `pdflatex'.
.ONESHELL:
.SHELLFLAGS = -ec
export TEXINPUTS :=
export CCACHE_DISABLE := 1
export PATH := $(installdir)/bin
export LDFLAGS := -L$(installdir)/lib
export SHELL := $(installdir)/bin/bash
export CPPFLAGS := -I$(installdir)/include
export LD_LIBRARY_PATH := $(installdir)/lib

# Until we build our own C library, without this, the project's GCC won't
# be able to compile anything if the host C library isn't in a standard
# place: in particular Debian-based operatings sytems. On other systems, it
# will be empty.
export CPATH := $(SYS_CPATH)

# RPATH is automatically written in macOS, so `DYLD_LIBRARY_PATH' is
# ultimately redundant. But on some systems, even having a single value
# causes crashs (see bug #56682). So we'll just give it no value at all.
export DYLD_LIBRARY_PATH :=

# OpenMPI can depend on an existing `ssh' or `rsh' binary. However, because
# of security reasons, its best to not install them, disable any
# remote-shell accesss through this environment variable.
export OMPI_MCA_plm_rsh_agent=/bin/false

# Recipe startup script.
export PROJECT_STATUS := make
export BASH_ENV := $(shell pwd)/reproduce/software/shell/bashrc.sh



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
# The `.SUFFIXES' rule with no prerequisite is defined to eliminate all the
# default implicit rules. The default implicit rules are to do with
# programming (for example converting `.c' files to `.o' files). The
# problem they cause is when you want to debug the make command with `-d'
# option: they add too many extra checks that make it hard to find what you
# are looking for in the outputs.
.SUFFIXES:
$(lockdir): | $(BDIR); mkdir $@





# Version and distribution tarball definitions
project-commit-hash := $(shell if [ -d .git ]; then \
    echo $$(git describe --dirty --always --long); else echo NOGIT; fi)
project-package-name := maneaged-$(project-commit-hash)
project-package-contents = $(texdir)/$(project-package-name)





# High-level Makefile management
# ------------------------------
#
# About `.PHONY': these are targets that must be built even if a file with
# their name exists.
#
# Only `$(mtexdir)/initialize.tex' corresponds to a file. This is because
# we want to ensure that the file is always built in every run: it contains
# the project version which may change between two separate runs, even when
# no file actually differs.
.PHONY: all clean dist dist-zip dist-lzip distclean clean-mmap \
        $(project-package-contents) $(mtexdir)/initialize.tex

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
	rm -rf $(BDIR)/tex/macros/!(dependencies.tex|dependencies-bib.tex)
	rm -rf $(BDIR)/!(software|tex) $(BDIR)/tex/!(macros|$(texbtopdir))
	rm -rf $(BDIR)/tex/build/!(tikz) $(BDIR)/tex/build/tikz/*
	rm -rf $(BDIR)/software/preparation-done.mk

distclean: clean
        #  Without cleaning the Git hooks, we won't be able to easily
        #  commit or checkout after this task is done. So we'll remove them
        #  first.
	rm -f .git/hooks/post-checkout .git/hooks/pre-commit

        # We'll be deleting the built environent programs and just need the
        # `rm' program. So for this recipe, we'll use the host system's
        # `rm', not our own.
	$$sys_rm -rf $(BDIR)
	$$sys_rm -f Makefile .gnuastro .local .build
	$$sys_rm -f $(pconfdir)/LOCAL.conf $(gconfdir)/gnuastro-local.conf





# Packaging rules
# ---------------
#
# With the rules in this section, you can package the project in a state
# that is ready for building the final PDF with LaTeX. This is useful for
# collaborators who only want to contribute to the text of your project,
# without having to worry about the technicalities of the analysis.
$(project-package-contents): paper.pdf | $(texdir)

        # Set up the output directory, delete it if it exists and remake it
        # to fill with new contents.
	dir=$@
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

        # Copy the top-level contents (see next step for `paper.tex').
	cp COPYING project README.md README-hacking.md $$dir/

        # Since the packaging is mainly intended for high-level building of
        # the PDF with LaTeX, we'll comment the `makepdf' LaTeX macro in
        # the paper. This will disable usage of TiKZ.
	sed -e's|\\newcommand{\\makepdf}{}|%\\newcommand{\\makepdf}{}|' \
	    paper.tex > $$dir/paper.tex

        # Build the top-level directories.
	mkdir $$dir/reproduce $$dir/tex $$dir/tex/tikz $$dir/tex/build

        # Copy all the necessary `reproduce' and `tex' contents.
	shopt -s extglob
	cp -r tex/src                            $$dir/tex/src
	cp -r reproduce/*                        $$dir/reproduce
	cp -r tex/build/!($(project-package-name)) $$dir/tex/build

        # If the project has any PDFs in its 'tex/tikz' directory (TiKZ or
        # PGFPlots was used to generate them), copy them too.
	if ls tex/tikz/*.pdf &> /dev/null; then
	  cp tex/tikz/*.pdf $$dir/tex/tikz
	fi

        # Clean up un-necessary/local files: 1) the $(texdir)/build*
        # directories (when building in a group structure, there will be
        # `build-user1', `build-user2' and etc), are just temporary LaTeX
        # build files and don't have any relevant/hand-written files in
        # them. 2) The `LOCAL.conf' and `gnuastro-local.conf' files just
        # have this machine's local settings and are irrelevant for anyone
        # else.
	rm -rf $$dir/tex/build/build*
	rm $$dir/reproduce/software/config/LOCAL.conf
	rm $$dir/reproduce/analysis/config/gnuastro/gnuastro-local.conf

        # When submitting to places like arXiv, they will just run LaTeX
        # once and won't run `biber'. So we need to also keep the `.bbl'
        # file into the distributing tarball. However, BibLaTeX is
        # particularly sensitive to versioning (a `.bbl' file has to be
        # read by the same BibLaTeX version that created it). This is hard
        # to do with non-up-to-date places like arXiv. Therefore, we thus
        # just copy the whole of BibLaTeX's source (the version we are
        # using) into the top tarball directory. In this way, arXiv's LaTeX
        # engine will use the same BibLaTeX version to interpret the `.bbl'
        # file. TIP: you can use the same strategy for other LaTeX packages
        # that may cause problems on the arXiv server.
	cp tex/build/build/paper.bbl $$dir/
	tltopdir=.local/texlive/maneage/texmf-dist/tex/latex
	find $$tltopdir/biblatex/ -maxdepth 1 -type f -print0 \
	     | xargs -0 cp -t $$dir

        # Just in case the package users want to rebuild some of the
        # figures (manually un-comment the `makepdf' command we commented
        # above), correct the TikZ external directory, so the figures can
        # be rebuilt.
	pgfsettings="$$dir/tex/src/preamble-pgfplots.tex"
	sed -e's|{tikz/}|{tex/tikz/}|' $$pgfsettings > $$pgfsettings.new
	mv $$pgfsettings.new $$pgfsettings

        # Clean temporary (currently those ending in `~') files.
	cd $(texdir)
	find $(project-package-name) -name \*~ -delete
	find $(project-package-name) -name \*.swp -delete

        # PROJECT SPECIFIC
        # ----------------
        # Put any project specific distribution steps here.
        # ----------------

# Package into `.tar.gz' or '.tar.lz'.
dist dist-lzip: $(project-package-contents)
	curdir=$$(pwd)
	cd $(texdir)
	tar -cf $(project-package-name).tar $(project-package-name)
	if [ $@ = dist ]; then
	  suffix=gz
	  gzip -f --best $(project-package-name).tar
	elif [ $@ = dist-lzip ]; then
	  suffix=lz
	  lzip -f --best $(project-package-name).tar
	fi
	rm -rf $(project-package-name)
	cd $$curdir
	mv $(texdir)/$(project-package-name).tar.$$suffix ./

# Package into `.zip'.
dist-zip: $(project-package-contents)
	curdir=$$(pwd)
	cd $(texdir)
	zip -q -r $(project-package-name).zip $(project-package-name)
	rm -rf $(project-package-name)
	cd $$curdir
	mv $(texdir)/$(project-package-name).zip ./

# Package the software tarballs.
dist-software:
	curdir=$$(pwd)
	dirname=software-$(project-commit-hash)
	cd $(BDIR)
	mkdir $$dirname
	cp -L software/tarballs/* $$dirname/
	tar -cf $$dirname.tar $$dirname
	gzip -f --best $$dirname.tar
	rm -rf $$dirname
	cd $$curdir
	mv $(BDIR)/$$dirname.tar.gz ./





# Directory containing to-be-published datasets
# ---------------------------------------------
#
# Its good practice (so you don't forget in the last moment!) to have all
# the plot/figure/table data that you ultimately want to publish in a
# single directory.
#
# There are two types of to-publish data in the project.
#
#  1. Those data that also go into LaTeX (for example to give to LateX's
#     PGFPlots package to create the plot internally) should be under the
#     '$(BDIR)/tex' directory (because other LaTeX producers may also need
#     it for example when using './project make dist'). The contents of
#     this directory are directly taken into the tarball.
#
#  2. The data that aren't included directly in the LaTeX run of the paper,
#     can be seen as supplements. A good place to keep them is under your
#     build-directory.
#
# RECOMMENDATION: don't put the figure/plot/table number in the names of
# your to-be-published datasets! Given them a descriptive/short name that
# would be clear to anyone who has read the paper. Later, in the caption
# (or paper's tex/appendix), you will put links to the dataset on servers
# like Zenodo (see the "Publication checklist" in 'README-hacking.md').
tex-publish-dir = $(texdir)/to-publish
data-publish-dir = $(BDIR)/data-to-publish
$(tex-publish-dir):; mkdir $@
$(data-publish-dir):; mkdir $@





# Print Copyright statement
# -------------------------
#
# This statement can be used in published datasets that are in plain-text
# format. It assumes you have already put the data-specific statements in
# its first argument, it will supplement them with general project links.
print-copyright = \
	echo "\# Project title: $(metadata-title)" >> $(1); \
	echo "\# Git commit (that produced this dataset): $(project-commit-hash)" >> $(1); \
	echo "\# Project's Git repository: $(metadata-git-repository)" >> $(1); \
	if [ x$(metadata-arxiv) != x ]; then \
	  echo "\# Pre-print server: https://arxiv.org/abs/$(metadata-arxiv)" >> $(1); fi; \
	if [ x$(metadata-doi-journal) != x ]; then \
	  echo "\# DOI (Journal): $(metadata-doi-journal)" >> $(1); fi; \
	if [ x$(metadata-doi-zenodo) != x ]; then \
	echo "\# DOI (Zenodo): $(metadata-doi-zenodo)" >> $(1); fi; \
	echo "\#" >> $(1); \
	echo "\# Copyright (C) $$(date +%Y) $(metadata-copyright-owner)" >> $(1); \
	echo "\# Dataset is available under $(metadata-copyright)." >> $(1); \
	echo "\# License URL: $(metadata-copyright-url)" >> $(1);





# Project initialization results
# ------------------------------
#
# This file will store some basic info about the project that is necessary
# for the final PDF. Since these are not version controlled, it must be
# calculated everytime the project is run. So even though this file
# actually exists, it is also aded as a `.PHONY' target above.
$(mtexdir)/initialize.tex: | $(mtexdir)

        # Version and title of project.
	echo "\newcommand{\projecttitle}{$(metadata-title)}" > $@
	echo "\newcommand{\projectversion}{$(project-commit-hash)}" >> $@

        # Calculate the latest Maneage commit used to build this
        # project. Note that the '--dirty' option isn't applicable to
        # "commit-ishes" (direct quote from Git's error message!).
	v=$$(git describe --always --long maneage)
	echo "\newcommand{\maneageversion}{$$v}" >> $@
