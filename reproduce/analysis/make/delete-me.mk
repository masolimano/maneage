# Dummy Makefile to create a random dataset for plotting.
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





# Dummy dataset
# -------------
#
# We will use AWK to generate a table showing X and X^2 and draw its plot.
delete-numdir = $(texdir)/delete-me-num
delete-num    = $(delete-numdir)/data.txt
$(delete-numdir): | $(texdir); mkdir $@
$(delete-num): $(pconfdir)/delete-me-num.conf | $(delete-numdir)

        # When the plotted values are re-made, it is necessary to also
        # delete the TiKZ externalized files so the plot is also re-made.
	rm -f $(tikzdir)/delete-me.pdf

        # Generate the table of random values.
	awk 'BEGIN {for(i=1;i<=$(delete-me-num);i+=0.5) print i, i*i; }' > $@





# WFPC2 image PDF
# -----------------
#
# For an example image, we'll make a PDF copy of the WFPC II image to
# display in the paper.
delete-demodir = $(texdir)/delete-me-demo
$(delete-demodir): | $(texdir); mkdir $@
delete-pdf = $(delete-demodir)/wfpc2.pdf
$(delete-pdf): $(delete-demodir)/%.pdf: $(indir)/%.fits | $(delete-demodir)

        # When the plotted values are re-made, it is necessary to also
        # delete the TiKZ externalized files so the plot is also re-made.
	rm -f $(tikzdir)/delete-me-wfpc2.pdf

        # Convert the dataset to a PDF.
	astconvertt --colormap=gray --fluxhigh=4 $< -h0 -o$@





# Histogram of WFPC2 image
# ------------------------
#
# For an example plot, we'll show the pixel value histogram also.
delete-histogram = $(delete-demodir)/wfpc2-hist.txt
$(delete-histogram): $(delete-demodir)/%-hist.txt: $(indir)/%.fits \
                     | $(delete-demodir)

        # When the plotted values are re-made, it is necessary to also
        # delete the TiKZ externalized files so the plot is also re-made.
	rm -f $(tikzdir)/delete-me-wfpc2.pdf

        # Generate the pixel value distribution
	aststatistics --lessthan=5 $< -h0 --histogram -o$@





# Basic statistics
# ----------------
#
# This is just as a demonstration on how to get analysic configuration
# parameters from variables defined in `reproduce/analysis/config/'.
delete-stats = $(delete-demodir)/wfpc2-stats.txt
$(delete-stats): $(delete-demodir)/%-stats.txt: $(indir)/%.fits \
                 | $(delete-demodir)
	aststatistics $< -h0 --mean --median > $@





# TeX macros
# ----------
#
# This is how we write the necessary parameters in the final PDF.
#
# NOTE: In LaTeX you cannot use any non-alphabetic character in a variable
# name.
$(mtexdir)/delete-me.tex: $(delete-num) $(delete-pdf) $(delete-histogram) \
                          $(delete-stats)

        # Write the number of random values used.
	echo "\newcommand{\deletemenum}{$(delete-me-num)}" > $@

        # Note that since Make variables start with a `$(', if you want to
        # use `$' within the shell (not Make), you have to quote any
        # occurance of `$' with another `$'. That is why there are `$$' in
        # the AWK command below.
        #
        # Here, we are first using AWK to find the minimum and maximum
        # values, then using it again to read each separately to use in the
        # macro definition.
	mm=$$(awk 'BEGIN{min=99999; max=-min}
	           !/^#/{if($$2>max) max=$$2; if($$2<min) min=$$2;}
	           END{print min, max}' $(delete-num));
	v=$$(echo "$$mm" | awk '{printf "%.3f", $$1}');
	echo "\newcommand{\deletememin}{$$v}"             >> $@
	v=$$(echo "$$mm" | awk '{printf "%.3f", $$2}');
	echo "\newcommand{\deletememax}{$$v}"             >> $@

        # Write the statistics of the WFPC2 image as a macro.
	mean=$$(awk     '{printf("%.2f", $$1)}' $(delete-stats))
	echo "\newcommand{\deletemewfpctwomean}{$$mean}"          >> $@
	median=$$(awk   '{printf("%.2f", $$2)}' $(delete-stats))
	echo "\newcommand{\deletemewfpctwomedian}{$$median}"      >> $@
