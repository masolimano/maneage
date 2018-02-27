# Build the final PDF paper/report.
#
# Original author:
#     Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Contributing author(s):
# Copyright (C) 2018, Mohammad Akhlaghi.
#
# This script is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This script is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.





# The final paper
# ---------------
#
# The commands to build the final report. We want the pipeline version to
# be checked everytime the final PDF is to be built.
texbdir=$(texdir)/build
tikzdir=$(texbdir)/tikz
$(texbdir): | $(texdir); mkdir $@
$(tikzdir): | $(texbdir); mkdir $@
paper.pdf: tex/pipeline.tex paper.tex | $(tikzdir) $(texbdir)

        # Make the report.
	p=$$(pwd);                                               \
	export TEXINPUTS=$$p:$$TEXINPUTS;                        \
	cd $(texbdir);                                           \
        pdflatex -shell-escape -halt-on-error $$p/paper.tex
	cp $(texbdir)/$@ $@
