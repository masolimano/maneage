# Download all the necessary inputs if they are not already present.
#
# Since most systems only have one input/connection into the network,
# downloading is essentially a serial (not parallel) operation. so the
# recipes in this Makefile all use a single file lock to have one download
# script running at every instant.
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
# Public License for more details. See <http://www.gnu.org/licenses/>.





# Download input data
# --------------------
#
# The input dataset properties are defined in `$(pconfdir)/INPUTS.mk'. For
# this template pipeline we only have one dataset to enable easy
# processing, so all the extra checks in this rule may seem redundant.
#
# In a real project, you will need more than one dataset. In that case,
# just add them to the target list and add an `elif' statement to define it
# in the recipe.
#
# Files in a server usually have very long names, which are mainly designed
# for helping in data-base management and being generic. Since Make uses
# file names to identify which rule to execute, and the scope of this
# research pipeline is much less than the generic survey/dataset, it is
# easier to have a simple/short name for the input dataset and work with
# that. In the first condition of the recipe below, we connect the short
# name with the raw database name of the dataset.
#
# Download lock file: Most systems have a single connection to the
# internet, therefore downloading is inherently done in series. As a
# result, when more than one dataset is necessary for download, if they are
# done in parallel, the speed will be slower than downloading them in
# series. We thus use the `flock' program to tie/lock the downloading
# process with a file and make sure that only one downloading event is in
# progress at every moment.
$(indir):; mkdir $@
inputdatasets = $(foreach i, wfpc2, $(indir)/$(i).fits)
$(inputdatasets): $(indir)/%.fits: | $(indir) $(lockdir)

        # Set the necessary parameters for this input file.
	if   [ $* = wfpc2 ]; then
	  origname=$(WFPC2IMAGE); url=$(WFPC2URL); mdf=$(WFPC2MD5);
	else
	echo; echo; echo "Not recognized input dataset: '$*.fits'."
	echo; echo; exit 1
	fi

        # Download (or make the link to) the input dataset.
	if [ -f $(INDIR)/$$origname ]; then
	  ln -s $(INDIR)/$$origname $@
	else
	  touch $(lockdir)/download
	  flock $(lockdir)/download $(DOWNLOADER) $@ $$url/$$origname
	fi

        # Check the md5 sum to see if this is the proper dataset.
	sum=$$(md5sum $@ | awk '{print $$1}')
	if [ $$sum != $$mdf ]; then
	  wrongname=$(dir $@)/wrong-$(notdir $@)
	  mv $@ $$wrongname
	  echo; echo; echo "Wrong MD5 checksum for '$$origname' in $$wrongname"
	  echo; echo; exit 1
	fi





# Final TeX macro
# ---------------
#
# It is very important to mention the address where the data were
# downloaded in the final report.
$(mtexdir)/download.tex: $(pconfdir)/INPUTS.mk | $(mtexdir)
	echo "\\newcommand{\\wfpctwourl}{$(WFPC2URL)}" > $@
