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





# The bibliography
# ----------------
#
# We need to run the `biber' program on the output of LaTeX to generate the
# necessary bibliography before making the final paper.
#
# NOTE: `tex/pipeline.tex' is an order-only-prerequisite for
# `paper.bbl'. This is because we need to run LaTeX in both the `paper.bbl'
# recipe and the `paper.pdf' recipe. But if `tex/references.tex' hasn't
# been modified, we don't want to re-build the bibliography, only the final
# PDF.
$(texbdir)/paper.bbl: tex/references.tex                         \
                      | $(tikzdir) $(texbdir) tex/pipeline.tex

        # We'll run LaTeX first to generate the `.bcf' file (necessary for
        # `biber') and then run `biber' to generate the `.bbl' file.
	p=$$(pwd);                                               \
	export TEXINPUTS=$$p:$$TEXINPUTS;                        \
	cd $(texbdir);                                           \
        pdflatex -shell-escape -halt-on-error $$p/paper.tex;     \
	biber paper





# The final paper
# ---------------
#
# The commands to build the final report. We want the pipeline version to
# be checked everytime the final PDF is to be built.
paper.pdf: tex/pipeline.tex paper.tex $(texbdir)/paper.bbl       \
	   | $(tikzdir) $(texbdir)

        # Make the report.
	p=$$(pwd);                                               \
	export TEXINPUTS=$$p:$$TEXINPUTS;                        \
	cd $(texbdir);                                           \
        pdflatex -shell-escape -halt-on-error $$p/paper.tex
	cp $(texbdir)/$@ $@
