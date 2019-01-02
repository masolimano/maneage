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





# Ultimate target of this pipeline
# --------------------------------
#
# The final paper (in PDF format) is the main target of this whole
# reproduction pipeline. So as defined in the Make paradigm, we are
# defining it here.
#
# Note that if you don't have LaTeX to build the PDF, or generally are just
# interested in the processing, you can skip create the final PDF creation
# with `pdf-build-final' of `reproduce/config/pipeline/pdf-build.mk'.
all: paper.pdf





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





# Include necessary Makefiles
# ---------------------------
#
# First, we'll include all the configuration-Makefiles (only defining
# variables with no rules or order), then the workhorse Makefiles which
# contain rules and order matters for them.
include reproduce/config/pipeline/*.mk
include $(foreach s,$(makesrc), reproduce/src/make/$(s).mk)
