# Dummy Makefile to create a random dataset for plotting.
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





# Dummy dataset
# -------------
#
# Just as a demonstration(!): we will use AWK to generate a table showing X
# and X^2 and draw its plot.
#
# Note that this dataset is directly read by LaTeX to generate a plot, so
# we need to put it in the $(tex-publish-dir) directory.
dm-squared = $(tex-publish-dir)/squared.txt
$(dm-squared): $(pconfdir)/delete-me-squared-num.conf | $(tex-publish-dir)

#	When the plotted values are re-made, it is necessary to also delete
#	the TiKZ externalized files so the plot is also re-made by
#	PGFPlots.
	rm -f $(tikzdir)/delete-me-squared.pdf

#	Write the column metadata in a temporary file name (appending
#	'.tmp' to the actual target name). Once all steps are done, it is
#	renamed to the final target. We do this because if there is an
#	error in the middle, Make will not consider the job to be complete
#	and will stop here.
	echo "# Data for demonstration plot of default Maneage (MANaging data linEAGE)." > $@.tmp
	echo "# It is a simple plot, showing the power of two: y=x^2! " >> $@.tmp
	echo "# " >> $@.tmp
	echo "# Column 1: X       [arbitrary, f32] The horizontal axis numbers." \
	     >> $@.tmp
	echo "# Column 2: X_POW2  [arbitrary, f32] The horizontal axis to the power of two." \
	     >> $@.tmp
	echo "# " >> $@.tmp
	$(call print-general-metadata, $@.tmp)

#	Generate the table of random values.
	awk 'BEGIN {for(i=1;i<=$(delete-me-squared-num);i+=0.5) \
	              printf("%-8.1f%.2f\n", i, i*i); }' >> $@.tmp

#	Write it into the final target
	mv $@.tmp $@





# Demo image PDF
# --------------
#
# For an example image, we'll make a PDF copy of the WFPC II image to
# display in the paper.
dm-histdir = $(texdir)/image-histogram
$(dm-histdir): | $(texdir); mkdir $@
dm-img-pdf = $(dm-histdir)/wfpc2.pdf
$(dm-img-pdf): $(dm-histdir)/%.pdf: $(indir)/%.fits | $(dm-histdir)

#	When the plotted values are re-made, it is necessary to also
#	delete the TiKZ externalized files so the plot is also re-made.
	rm -f $(tikzdir)/delete-me-image-histogram.pdf

#	Convert the dataset to a PDF.
	astconvertt --colormap=gray --fluxhigh=4 $< -h0 -o$@





# Histogram of demo image
# -----------------------
#
# For an example plot, we'll show the pixel value histogram also. IMPORTANT
# NOTE: because this histogram contains data that is included in a plot, we
# should publish it, so it will go into the $(tex-publish-dir).
dm-img-histogram = $(tex-publish-dir)/wfpc2-histogram.txt
$(dm-img-histogram): $(tex-publish-dir)/%-histogram.txt: $(indir)/%.fits \
                     | $(tex-publish-dir)

#	When the plotted values are re-made, it is necessary to also delete
#	the TiKZ externalized files so the plot is also re-made.
	rm -f $(tikzdir)/delete-me-image-histogram.pdf

#	Generate the pixel value histogram.
	aststatistics --lessthan=5 $< -h0 --histogram -o$@.data

#	Put a two-line description of the dataset, copy the column metadata
#	from '$@.data', and add copyright.
	echo "# Histogram of example image to demonstrate Maneage (MANaging data linEAGE)." \
	     > $@.tmp
	echo "# Example image URL: $(DEMO-URL)" >> $@.tmp
	echo "# " >> $@.tmp
	awk '/^# Column .:/' $@.data >> $@.tmp
	echo "# " >> $@.tmp
	$(call print-general-metadata, $@.tmp)

#	Add the column numbers in a formatted manner, rename it to the
#	output and clean up.
	awk '!/^#/{printf("%-15.4f%d\n", $$1, $$2)}' $@.data >> $@.tmp
	mv $@.tmp $@
	rm $@.data





# Basic statistics
# ----------------
#
# This is just as a demonstration on how to get analysic configuration
# parameters from variables defined in 'reproduce/analysis/config/'.
dm-img-stats = $(dm-histdir)/wfpc2-stats.txt
$(dm-img-stats): $(dm-histdir)/%-stats.txt: $(indir)/%.fits \
                 | $(dm-histdir)
	aststatistics $< -h0 --mean --median > $@





# TeX macros
# ----------
#
# This is how we write the necessary parameters in the final PDF.
#
# NOTE: In LaTeX you cannot use any non-alphabetic character in a variable
# name.
$(mtexdir)/delete-me.tex: $(dm-squared) $(dm-img-pdf) $(dm-img-histogram) \
                          $(dm-img-stats)

#	Write the number of random values used.
	echo "\newcommand{\deletemenum}{$(delete-me-squared-num)}" > $@

#	Note that since Make variables start with a '$(', if you want to
#	use '$' within the shell (not Make), you have to quote any
#	occurance of '$' with another '$'. That is why there are '$$' in
#	the AWK command below.
#
#	Here, we are first using AWK to find the minimum and maximum
#	values, then using it again to read each separately to use in the
#	macro definition.
	mm=$$(awk 'BEGIN{min=99999; max=-min}
	           !/^#/{if($$2>max) max=$$2; if($$2<min) min=$$2;}
	           END{print min, max}' $(dm-squared));
	v=$$(echo "$$mm" | awk '{printf "%.3f", $$1}');
	echo "\newcommand{\deletememin}{$$v}"             >> $@
	v=$$(echo "$$mm" | awk '{printf "%.3f", $$2}');
	echo "\newcommand{\deletememax}{$$v}"             >> $@

#	Write the statistics of the demo image as a macro.
	mean=$$(awk     '{printf("%.2f", $$1)}' $(dm-img-stats))
	echo "\newcommand{\deletemewfpctwomean}{$$mean}"          >> $@
	median=$$(awk   '{printf("%.2f", $$2)}' $(dm-img-stats))
	echo "\newcommand{\deletemewfpctwomedian}{$$median}"      >> $@
