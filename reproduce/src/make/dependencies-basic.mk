# Build the VERY BASIC reproduction pipeline dependencies (programs and
# libraries).
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run by the initial `./configure' script. It is not
# included into the reproduction pipe after that.
#
# This Makefile builds very low-level and basic tools like GNU Bash and GNU
# Make. Therefore this is the only Makefile in the reproduction pipeline
# where you MUST NOT assume that modern GNU Bash or GNU Make are used.
#
# This Makefile is a very simplified version of `dependencies.mk' in the
# same directory. See there for more comments.
#
# ------------------------------------------------------------------------
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


# Top level environment
include reproduce/config/pipeline/LOCAL.mk
include reproduce/src/make/dependencies-build-rules.mk
include reproduce/config/pipeline/dependency-versions.mk

ddir  = $(BDIR)/dependencies
tdir  = $(BDIR)/dependencies/tarballs
idir  = $(BDIR)/dependencies/installed
ibdir = $(BDIR)/dependencies/installed/bin
ildir = $(BDIR)/dependencies/installed/lib

# As we build more programs, we want to use our own pipeline's built
# programs, not the systems.
PATH := $(ibdir):$(PATH)

top-level-programs = bash
all: $(foreach p, $(top-level-programs), $(ibdir)/$(p))





# Tarballs
# --------
#
# Prepare tarballs. Difference with that in `dependencies.mk': `.ONESHELL'
# is not recognized by some versions of Make (even older GNU Makes). So
# we'll have to make sure the recipe doesn't break into multiple shell
# calls (so we can preserve the variables).
tarballs = $(foreach t, bash-$(bash-version).tar.gz                         \
                        lzip-$(lzip-version).tar.gz                         \
	                make-$(make-version).tar.gz                         \
	                tar-$(tar-version).tar.gz                           \
                      , $(tdir)/$(t) )
$(tarballs): $(tdir)/%:
	if [ -f $(DEPENDENCIES-DIR)/$* ]; then                              \
	  cp $(DEPENDENCIES-DIR)/$* $@;                                     \
	else                                                                \
	  n=$$(echo $* | sed -e's/[0-9\-]/ /g'                              \
	                     -e's/\./ /g'                                   \
	               | awk '{print $$1}' );                               \
	                                                                    \
	  mergenames=1;                                                     \
	  if   [ $$n = bash ]; then w=http://ftp.gnu.org/gnu/bash;          \
	  elif [ $$n = lzip ]; then w=http://download.savannah.gnu.org/releases/lzip; \
	  elif [ $$n = make ]; then w=http://akhlaghi.org/src;              \
	  elif [ $$n = tar  ]; then w=http://ftp.gnu.org/gnu/tar;           \
	  else                                                              \
	    echo; echo; echo;                                               \
	    echo "'$$n' not a dependency name (for downloading)."           \
	    echo; echo; echo;                                               \
	    exit 1;                                                         \
	  fi;                                                               \
	                                                                    \
	  if [ $$mergenames = 1 ]; then  tarballurl=$$w/"$*";               \
	  else                           tarballurl=$$w;                    \
	  fi;                                                               \
	  echo "Downloading $$tarballurl";                                  \
	  $(DOWNLOADER) $@ $$tarballurl;                                    \
	fi





# Basic programs (sorted alphabetically), see prerequisites for which one
# will be built first.
$(ibdir)/bash: $(tdir)/bash-$(bash-version).tar.gz \
	       $(ibdir)/make
	$(call gbuild,$(subst $(tdir)/,,$<), bash-$(bash-version), static)

$(ibdir)/lzip: $(tdir)/lzip-$(lzip-version).tar.gz
	$(call gbuild,$(subst $(tdir)/,,$<), lzip-$(lzip-version), static)

# Unfortunately GNU Make needs dynamic linking in two instances: when
# loading objects (dynamically linked libraries), or when using the
# `getpwnam' function (for tilde expansion). The first can be disabled with
# `--disable-load', but unfortunately I don't know any way to fix the
# second. So, we'll have to build it dynamically for now.
$(ibdir)/make: $(tdir)/make-$(make-version).tar.gz \
               $(ibdir)/tar
	$(call gbuild,$(subst $(tdir)/,,$<), make-$(make-version), , , ,)

# When built statically, tar gives a segmentation fault on unpacking
# Bash. So we'll build it dynamically.
$(ibdir)/tar: $(tdir)/tar-$(tar-version).tar.gz \
              $(ibdir)/lzip
	$(call gbuild,$(subst $(tdir)/,,$<), tar-$(tar-version))
