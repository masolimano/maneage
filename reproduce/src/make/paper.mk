# Build the final PDF paper/report.
#
# Original author:
#     Your name <your@email.address>
# Contributing author(s):
# Copyright (C) YYYY, Your Name.
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
paper.pdf: tex/pipeline.tex paper.tex

        # Make the report.
	@pdflatex -shell-escape -halt-on-error paper.tex
	@rm -f *.auxlock *.aux *.out *.log
