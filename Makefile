# A ONE-LINE DESCRIPTION OF THE WHOLE PIPELINE
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





# Ultimate target of this pipeline
# --------------------------------
#
# The final paper (in PDF format) is the main target of this whole
# reproduction pipeline. So as defined in the Make paradigm, we are
# defining it as the first target.
#
# Note that if you don't have LaTeX to build the PDF or generally are just
# interested in the processing, you can avoid the skip to create the final
# PDF, see `reproduce/config/pipeline/pdf.mk'.
all: paper.pdf





# Include specific Makefiles
# --------------------------
#
# To keep things clean, managable and readable, each set of operations is
# (and must be) classified (modularized) by context into separate
# Makefiles: the more the better. They are included in this top-level
# Makefile through the command below.
#
# To further help in readability, it is best to avoid including Makefiles
# within any other Makefile. So in short, it is best that the `foreach'
# loop below contains all the `reproduce/src/make/*.mk' files.
#
# IMPORTANT NOTE: order matters in the inclusion of the processing
# Makefiles. As the pipeline grows, some Makefiles will probably define
# variables/dependencies that others need. Therefore unlike the
# `reproduce/config/pipeline/*.mk' Makefiles which only define low-level
# variables (not dependent on other variables and contain no rules), the
# high-level processing Makefiles are included through the `foreach' loop
# below by explicitly requesting them in a specific order here.
include reproduce/config/pipeline/*.mk
include $(foreach f, initialize download paper, reproduce/src/make/$(f).mk)





# LaTeX macros for paper
# ----------------------
#
# The final report's PDF (final target of this reproduction pipeline) takes
# variable strings from the pipeline. Those variables are defined as LaTeX
# macros in `tex/pipeline.tex'. This file is thus the interface between the
# pipeline scripts and the final PDF.
#
# Each of the pipeline steps will save their macros into their own `.tex'
# file in the `$(mtexdir)' directory. Those individual macros are the
# pre-requisite to `tex/pipeline.txt'. `tex/pipeline.tex' is thus a
# high-level output and is defined in this top-most Makefile (and not
# `reproduce/src/make/paper.mk'). This enables a clear demonstration of the
# top-level dependencies clearly.
#
# The symbolic link to the build directory (`bdirsym') is also placed here
# as a dependency if the pipeline is to be created. It is very important
# that it be an "order-only prerequisite" (after a `|', otherwise, it will
# try to be remade on every call and `ln' will complain and abort).
#
# Note that if you don't want the final PDF and just want the processing
# and file outputs, you can remove the value of the `BUILD-FINAL-PDF'
# variable in `reproduce/config/LOCAL.mk'.
tex/pipeline.tex: $(foreach f, initialize download, $(mtexdir)/$(f).tex)   \
                  | $(bdirsym)

        # If no PDF is requested, then just exit here.
ifeq ($(BUILD-FINAL-PDF),)
	@echo;
	@echo "Everything is OK until this point, but not building PDF."
	@echo "To do so, give a value to the 'BUILD-FINAL-PDF' variable."
	@echo "It is defined in 'reproduce/config/pipeline/LOCAL.mk'."
	@echo;
	@exit 1
endif

        # Read all the separate files and put them into the final TeX
        # macros file. Since `bdirsym' maybe empty, we can't use the
        # `filter-out' function generically. We'll have to check `bdirsym'
        # first.
ifeq ($(bdirsym),)
	cat $^ > $@
else
	cat $(filter-out $(bdirsym),$^) > $@
endif
