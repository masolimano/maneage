# Download all the necessary inputs if they are not already present.
#
# Since most systems only have one input/connection into the network,
# downloading is essentially a serial (not parallel) operation. so the
# recipes in this Makefile all use a single file lock to have one download
# script running at every instant.
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





# Download input data
# --------------------
#
# The input dataset properties are defined in
# `$(pconfdir)/INPUTS.conf'. For this template we only have one dataset to
# enable easy processing, so all the extra checks in this rule may seem
# redundant.
#
# In a real project, you will need more than one dataset. In that case,
# just add them to the target list and add an `elif' statement to define it
# in the recipe.
#
# Files in a server usually have very long names, which are mainly designed
# for helping in data-base management and being generic. Since Make uses
# file names to identify which rule to execute, and the scope of this
# research project is much less than the generic survey/dataset, it is
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
downloadwrapper = $(bashdir)/download-multi-try
inputdatasets = $(foreach i, wfpc2, $(indir)/$(i).fits)
$(inputdatasets): $(indir)/%.fits: | $(indir) $(lockdir)

        # Set the necessary parameters for this input file.
	if   [ $* = wfpc2 ]; then
	  localname=$(DEMO-DATA); url=$(DEMO-URL); mdf=$(DEMO-MD5);
	else
	echo; echo; echo "Not recognized input dataset: '$*.fits'."
	echo; echo; exit 1
	fi

        # Download (or make the link to) the input dataset. If the file
        # exists in `INDIR', it may be a symbolic link to some other place
        # in the filesystem. To avoid too many links when using these files
        # during processing, we'll use `readlink -f' so the link we make
        # here points to the final file directly (note that `readlink' is
        # part of GNU Coreutils). If its not a link, the `readlink' part
        # has no effect.
	unchecked=$@.unchecked
	if [ -f $(INDIR)/$$localname ]; then
	  ln -fs $$(readlink -f $(INDIR)/$$localname) $$unchecked
	else
	  touch $(lockdir)/download
	  $(downloadwrapper) "wget --no-use-server-timestamps -O" \
	                     $(lockdir)/download $$url $$unchecked
	fi

        # Check the md5 sum to see if this is the proper dataset.
	sum=$$(md5sum $$unchecked | awk '{print $$1}')
	if [ $$sum = $$mdf ]; then
	  mv $$unchecked $@
	  echo "Integrity confirmed, using $@ in this project."
	else
	  echo; echo;
	  echo "Wrong MD5 checksum for input file '$$localname':"
	  echo "  Expected MD5 checksum:   $$mdf"; \
	  echo "  Calculated MD5 checksum: $$sum"; \
	  echo; exit 1
	fi





# Final TeX macro
# ---------------
#
# It is very important to mention the address where the data were
# downloaded in the final report.
$(mtexdir)/download.tex: $(pconfdir)/INPUTS.conf | $(mtexdir)
	echo "\\newcommand{\\wfpctwourl}{$(DEMO-URL)}" > $@
