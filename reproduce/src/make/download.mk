# Download all the necessary inputs if they are not already present.
#
# Since most systems only have one input/connection into the network,
# downloading is essentially a serial (not parallel) operation. so the
# recipes in this Makefile all use a single file lock to have one download
# script running at every instant.
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
# Public License for more details. See <http://www.gnu.org/licenses/>.





# Identify the downloader tool
# ----------------------------
#
# If cURL is already present, that will be used, otherwise, we'll use
# Wget. Since the options specifying the output filename are different
# between the two, we'll also specify the output option within the
# `downloader' variable. So it is important to first give the output
# filename after calling `downloader', then the web address.
downloader := $(shell if type curl > /dev/null; then downloader="curl -o";  \
	              else                           downloader="wget -O";  \
	              fi; echo "$$downloader";                               )





# Download SURVEY data
# --------------------
#
# Data from a survey (for example an imaging survey) usually have a special
# file-name format which should be set here in the `foreach' loop. Note
# that the `foreach' function needs the backslash (`\') at the end of the
# line when it is broken into multiple lines.
all-survey = $(foreach f, $(filters-survey),                                 \
                          $(SURVEY)/a-special-format-$(f).fits               \
                          $(SURVEY)/a-possibly-additional-$(f)-format.fits )
$(SURVEY):; mkdir $@
$(all-survey): $(SURVEY)/%: | $(SURVEY) $(lockdir)
	flock $(lockdir)/download -c "$(downloader) $@ $(web-survey)/$*"






# Final TeX macro
# ---------------
#
# It is very important to mention the address where the data were
# downloaded in the final report.
$(mtexdir)/download.tex: $(pconfdir)/web.mk | $(mtexdir)
	@echo "\\newcommand{\\websurvey}{$(web-survey)}" > $@
