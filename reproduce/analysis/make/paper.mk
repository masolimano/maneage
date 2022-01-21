# Build the final PDF paper/report.
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




# LaTeX macros for paper
# ----------------------
#
# To report the input settings and results, the final report's PDF (final
# target of this project) uses macros generated from various steps of the
# project. All these macros are defined through '$(mtexdir)/project.tex'.
#
# '$(mtexdir)/project.tex' is actually just a combination of separate files
# that keep the LaTeX macros related to each workhorse Makefile (in
# 'reproduce/src/make/*.mk'). Those individual macros are pre-requisites to
# '$(mtexdir)/verify.tex' which will check them before starting to build
# the paper. The only workhorse Makefile that doesn't need to produce LaTeX
# macros is this Makefile ('reproduce/src/make/paper.mk').
#
# This file is thus the interface between the analysis/processing steps and
# the final PDF: when we get to this point, all the processing has been
# completed.
#
# Note that if you don't want the final PDF and just want the processing
# and file outputs, you can give any value other than 'yes' to
# 'pdf-build-final' in 'reproduce/analysis/config/pdf-build.conf'.
$(mtexdir)/project.tex: $(mtexdir)/verify.tex

#	If no PDF is requested, or if LaTeX isn't available, don't continue
#	to building the final PDF. Otherwise, merge all the TeX macros into
#	one for building the PDF.
	@if [ -f .local/bin/pdflatex ] && [ x"$(pdf-build-final)" = xyes ]; then

#	  Put a LaTeX input command for all the necessary macro files.
#	  'hardware-parameters.tex' is created in 'configure.sh'.
	  projecttex=$(mtexdir)/project.tex
	  rm -f $$projecttex
	  for t in $(subst paper,,$(makesrc)) hardware-parameters; do
	    echo "\input{tex/build/macros/$$t.tex}" >> $$projecttex
	  done

#	  Possibly highlight the '\new' parts of the text.
	  if [ x"$(highlightnew)" = x1 ]; then
	    echo "\newcommand{\highlightnew}{}" >> $$projecttex
	  fi

#	  Possibly show the text within '\tonote'.
	  if [ x"$(highlightnotes)" = x1 ]; then
	    echo "\newcommand{\highlightnotes}{}" >> $$projecttex
	  fi

#	The paper shouldn't be built.
	else
	  echo
	  echo "-----"
	  echo "The processing has COMPLETED SUCCESSFULLY! But the final "
	  echo "LaTeX-built PDF paper will not be built."
	  echo
	  if [ x$(more-on-building-pdf) = x1 ]; then
	    echo "To build the PDF, make sure that the 'pdf-build-final' "
	    echo "variable has a value of 'yes' (it is defined in this file)"
	    echo "    reproduce/analysis/config/pdf-build.conf"
	    echo
	    echo "If you still see this message, there was a problem with "
	    echo "building LaTeX within the project. You can re-try building"
	    echo "it when you have internet access with the two commands below:"
	    echo "    $ rm .local/version-info/tex/texlive*"
	    echo "    $./project configure -e"
	  else
	    echo "For more, run './project make more-on-building-pdf=1'"
	  fi
	  echo
	  echo "" > $@
	fi





# The bibliography
# ----------------
#
# We need to run the 'biber' program on the output of LaTeX to generate the
# necessary bibliography before making the final paper. So we'll first have
# one run of LaTeX (similar to the 'paper.pdf' recipe), then 'biber'.
#
# NOTE: '$(mtexdir)/project.tex' is an order-only-prerequisite for
# 'paper.bbl'. This is because we need to run LaTeX in both the 'paper.bbl'
# recipe and the 'paper.pdf' recipe. But if 'tex/src/references.tex' hasn't
# been modified, we don't want to re-build the bibliography, only the final
# PDF.
$(texbdir)/paper.bbl: tex/src/references.tex $(mtexdir)/dependencies-bib.tex \
                      | $(mtexdir)/project.tex
#	If '$(mtexdir)/project.tex' is empty, don't build PDF.
	@macros=$$(cat $(mtexdir)/project.tex)
	if [ x"$$macros" != x ]; then

#	  We'll run LaTeX first to generate the '.bcf' file (necessary for
#	  'biber') and then run 'biber' to generate the '.bbl' file.
	  p=$$(pwd)
	  export TEXINPUTS=$$p:
	  cd $(texbdir);

#	  Delete any possibly existing target (a '.bbl' file) to avoid
#	  complications with LaTeX being run before the command that
#	  generates it. Otherwise users will have to manually delete it. It
#	  will be built anyway once this rule is done.
	  rm -f $@

#	  The pdflatex option '-shell-escape' is "normally disallowed for
#	  security reasons" according to the 'info pdflatex' manual, but is
#	  enabled here in order to allow the use of PGFPlots. If you do not
#	  use PGFPlots, then you should remove the '-shell-escape' option
#	  for better security. See https://savannah.nongnu.org/task/?15694
#	  for details.
	  pdflatex -shell-escape -halt-on-error "$$p"/paper.tex
	  biber paper

	fi





# The final paper
# ---------------
#
# Run LaTeX in the '$(texbdir)' directory so all the intermediate and
# auxiliary files stay there and keep the top directory clean. To be able
# to run everything cleanly from there, it is necessary to add the current
# directory (top project directory) to the 'TEXINPUTS' environment
# variable.
paper.pdf: $(mtexdir)/project.tex paper.tex $(texbdir)/paper.bbl

#	If '$(mtexdir)/project.tex' is empty, don't build the PDF.
	@macros=$$(cat $(mtexdir)/project.tex)
	if [ x"$$macros" != x ]; then

#	  Go into the top TeX build directory and make the paper.
	  p=$$(pwd)
	  export TEXINPUTS=$$p:
	  cd $(texbdir)

#	  See above for a warning and brief discussion on the the pdflatex
#	  option '-shell-escape'.
	  pdflatex -shell-escape -halt-on-error "$$p"/paper.tex

#	  Come back to the top project directory and copy the built PDF
#	  file here.
	  cd "$$p"
	  cp $(texbdir)/$@ $(final-paper)

	fi
