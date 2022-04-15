# Download all the necessary inputs if they are not already present.
#
# Since most systems only have one input/connection into the network,
# downloading is essentially a serial (not parallel) operation. so the
# recipes in this Makefile all use a single file lock to have one download
# script running at every instant.
#
# Copyright (C) 2018-2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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
# 'reproduce/analysis/config/INPUTS.conf' contains the input dataset
# properties. In most cases, you will not need to edit this rule (or
# file!). Simply follow the instructions of 'INPUTS.conf' and set the
# variables names according to the described standards.
#
# TECHNICAL NOTE on the '$(foreach, n ...)' loop of 'inputdatasets': we are
# using several (relatively complex!) features particular to Make: In GNU
# Make, '.VARIABLES' "... expands to a list of the names of all global
# variables defined so far" (from the "Other Special Variables" section of
# the GNU Make manual). Assuming that the pattern 'INPUT-%-sha256' is only
# used for input files, we find all the variables that contain the input
# file name (the '%' is the filename). Finally, using the
# pattern-substitution function ('patsubst'), we remove the fixed string at
# the start and end of the variable name.
#
# Download lock file: Most systems have a single connection to the
# internet, therefore downloading is inherently done in series. As a
# result, when more than one dataset is necessary for download, if they are
# done in parallel, the speed will be slower than downloading them in
# series. We thus use the 'flock' program to tie/lock the downloading
# process with a file and make sure that only one downloading event is in
# progress at every moment.
$(indir):; mkdir $@
downloadwrapper = $(bashdir)/download-multi-try
inputdatasets = $(foreach i, \
                  $(patsubst INPUT-%-sha256,%, \
                    $(filter INPUT-%-sha256,$(.VARIABLES))), \
                  $(indir)/$(i))
$(inputdatasets): $(indir)/%: | $(indir) $(lockdir)

#	Set the necessary parameters for this input file as shell variables
#	(to help in readability).
	url=$(INPUT-$*-url)
	sha=$(INPUT-$*-sha256)

#	Download (or make the link to) the input dataset. If the file
#	exists in 'INDIR', it may be a symbolic link to some other place in
#	the filesystem. To avoid too many links when using these files
#	during processing, we'll use 'readlink -f' so the link we make here
#	points to the final file directly (note that 'readlink' is part of
#	GNU Coreutils). If its not a link, the 'readlink' part has no
#	effect.
	unchecked=$@.unchecked
	if [ -f $(INDIR)/$* ]; then
	  ln -fs $$(readlink -f $(INDIR)/$*) $$unchecked
	else
	  touch $(lockdir)/download
	  $(downloadwrapper) "wget --no-use-server-timestamps -O" \
	                     $(lockdir)/download $$url $$unchecked
	fi

#	Check the checksum to see if this is the proper dataset.
	sum=$$(sha256sum $$unchecked | awk '{print $$1}')
	if [ $$sum = $$sha ]; then
	  mv $$unchecked $@
	  echo "Integrity confirmed, using $@ in this project."
	else
	  echo; echo;
	  echo "Wrong SHA256 checksum for input file '$*':"
	  echo "  File location: $$unchecked"; \
	  echo "  Expected SHA256 checksum:   $$sha"; \
	  echo "  Calculated SHA256 checksum: $$sum"; \
	  echo; exit 1
	fi





# Final TeX macro
# ---------------
#
# It is very important to mention the address where the data were
# downloaded in the final report.
$(mtexdir)/download.tex: $(pconfdir)/INPUTS.conf | $(mtexdir)
	echo "\\newcommand{\\wfpctwourl}{$(INPUT-wfpc2.fits-url)}" > $@
