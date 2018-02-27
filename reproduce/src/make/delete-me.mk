# Dummy Makefile to create a random dataset for plotting.
#
# Original author:
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Contributing author(s):
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





# Dummy dataset
# -------------
#
# We will use AWK's random number generator to generate a random dataset to
# be imported by PGFPlots for a plot in the paper.
dmdir = $(texdir)/delete-me
dm    = $(dmdir)/data.txt
$(dmdir): | $(texdir); mkdir $@
$(dm): $(pconfdir)/delete-me-num.mk | $(dmdir)

        # When the plotted values are re-made, it is necessary to also
        # delete the TiKZ externalized files so the plot is also re-made.
	rm -f $(tikzdir)/delete-me.pdf

        # Generate the table of random values.
	awk 'BEGIN { for (i = 1; i <= $(delete-me-num); i++)          \
                       print i, rand(); }' > $@





# TeX macros
# ----------
#
# This is how we write the necessary parameters in the final PDF.
#
# NOTE: In LaTeX you cannot use any non-alphabetic character in a variable
# name.
$(mtexdir)/delete-me.tex: $(dm)

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
	mm=$$(awk 'BEGIN{min=99999; max=-min}                     \
                   {if($$2>max) max=$$2; if($$2<min) min=$$2;}    \
                   END{print min, max}' $(dm));                   \
	v=$$(echo "$$mm" | awk '{printf "%.3f", $$1}');           \
	echo "\newcommand{\deletememin}{$$v}"             >> $@;  \
	v=$$(echo "$$mm" | awk '{printf "%.3f", $$2}');           \
	echo "\newcommand{\deletememax}{$$v}"             >> $@
