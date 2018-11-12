# Build the final PDF paper/report.
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
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.





# The bibliography
# ----------------
#
# We need to run the `biber' program on the output of LaTeX to generate the
# necessary bibliography before making the final paper. So we'll first have
# one run of LaTeX (similar to the `paper.pdf' recipe), then `biber'.
#
# NOTE: `tex/pipeline.tex' is an order-only-prerequisite for
# `paper.bbl'. This is because we need to run LaTeX in both the `paper.bbl'
# recipe and the `paper.pdf' recipe. But if `tex/references.tex' hasn't
# been modified, we don't want to re-build the bibliography, only the final
# PDF.
$(texbdir)/paper.bbl: tex/references.tex                         \
                      | $(tikzdir) $(texbdir) tex/pipeline.tex

        # To find LaTeX (which currently isn't internally installed).
	PATH=$(sys-path)

        # We'll run LaTeX first to generate the `.bcf' file (necessary for
        # `biber') and then run `biber' to generate the `.bbl' file.
	p=$$(pwd);
	export TEXINPUTS=$$p:$$TEXINPUTS;
	cd $(texbdir);
	pdflatex -shell-escape -halt-on-error $$p/paper.tex;
	biber paper





# The final paper
# ---------------
#
# Run LaTeX in the `$(texbdir)' directory so all the intermediate and
# auxiliary files stay there and keep the top directory clean. To be able
# to run everything cleanly from there, it is necessary to add the current
# directory (top reproduction pipeline directory) to the `TEXINPUTS'
# environment variable.
paper.pdf: tex/pipeline.tex paper.tex $(texbdir)/paper.bbl       \
	   | $(tikzdir) $(texbdir)

        # To find LaTeX (which currently isn't internally installed).
	PATH=$(sys-path)

        # Go into the top TeX build directory and make the paper.
	p=$$(pwd)
	export TEXINPUTS=$$p:$$TEXINPUTS
	cd $(texbdir)
	pdflatex -shell-escape -halt-on-error $$p/paper.tex

        # Come back to the top pipeline directory and copy the built PDF
        # file here.
	cd $$p
	cp $(texbdir)/$@ $@
