# A ONE-LINE DESCRIPTION OF THE WHOLE PIPELINE
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





# Load the local configuration (created after running `./configure').
include reproduce/config/pipeline/LOCAL.mk





# Ultimate target of this pipeline
# --------------------------------
#
# The final paper/report (`paper.pdf') is the main target of this whole
# reproduction pipeline. So as defined in the Make paradigm, it is the
# first target that we define (immediately after loading the local
# configuration settings, necessary for a group building scenario mentioned
# next).
#
# Group build
# -----------
#
# This pipeline can also be configured to have a shared build directory
# between multiple users. In this scenario, many users (on a server) can
# have their own/separate version controlled pipeline source of the
# pipeline, but share the same build outputs (in a common directory). This
# will allow a group to work separately, on parallel parts of the analysis.
# It is thus very useful in cases were special storage requirements or CPU
# power is necessary and its not possible/efficient for each user to have a
# fully separate copy of the build directory.
#
#   `FOR-GROUP': from `LOCAL.mk' (which was built by `./configure').
#   `reproducible_paper_for_group': from the `./for-group' script.
#
# The final paper is only built when both have a value of `yes', or when
# `FOR-GROUP' is no and `./for-group' wasn't called (if `./for-group' is
# called before `make', then `reproducible_paper_for_group==yes').
#
# Only processing, no LaTeX PDF
# -----------------------------
#
# If you are just interested in the processing and don't want to build the
# PDF, you can skip the creatation of the final PDF by removing the value
# of `pdf-build-final' in `reproduce/config/pipeline/pdf-build.mk'.
ifeq ($(good-group-configuration),yes)
all: paper.pdf
else
all:
	@if [ "x$(reproducible_paper_for_group)" = xyes ]; then     \
	  echo "Pipeline is NOT configured for groups, please run"; \
	  echo "   $$ .local/bin/make";                             \
	else                                                        \
	  echo "Pipeline is configured for groups, please run";     \
	  echo "   $$ ./for-group make";                            \
	fi
endif





# Define source Makefiles
# -----------------------
#
# To keep things clean, managable and readable, each set of operations
# is (and must be) classified (modularized) by context into separate
# Makefiles: the more the better. These modular steps are then
# included in this top-level Makefile through the `include' command of
# the next step. Each Makefile should also produce a LaTeX macro file
# with the same fixed name (used to keep all the parameters and
# relevant outputs of the steps in it for the final paper).
#
# In the rare case that no special LaTeX macros are necessary in a
# workhorse Makefile, you can simply make an empty file with `touch
# $@'. This will not add any lines to the final combined LaTeX macros
# file, but will create the file that is a prerequisite to the final
# paper generation.
#
# To (significantly) help in readability, this top-level Makefile should be
# the only one in charge of including Makefiles. So if you care about easy
# maintainence and understandability (even for your self, in one year! It
# is VERY IMPORTANT and as a scientist, you MUST care about it!), do not
# include Makefiles from any other Makefile.
#
# IMPORTANT NOTE: order matters in the inclusion of the processing
# Makefiles. As the pipeline grows, some Makefiles will define
# variables/dependencies that later Makefiles need. Therefore we are using
# a `foreach' loop in the next step to explicitly request loading them in
# the same order that they are defined here (we aren't just using a
# wild-card like the configuration Makefiles).
makesrc = initialize                    \
          download                      \
          delete-me                     \
          paper





# Include all Makefiles
# ---------------------
#
# We have two classes of Makefiles, separated by context and their location:
#
#   1) First, we'll include all the configuration-Makefiles. These
#      Makefiles only define variables with no rules or order. We just
#      won't include `LOCAL.mk' because it has already been included
#      above.
#
#   2) Then, we'll import the workhorse-Makefiles which contain rules to
#      actually do the processing of this pipeline.
include $(filter-out %LOCAL.mk, reproduce/config/pipeline/*.mk)
include $(foreach s,$(makesrc), reproduce/src/make/$(s).mk)
