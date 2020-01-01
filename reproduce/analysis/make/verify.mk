# Verify the project outputs before building the paper.
#
# Copyright (C) 2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# Verification functions
# ----------------------
#
# These functions are used by the final rule in this Makefil
verify-print-tips = \
  echo "If you are still developing your project, you can disable"; \
  echo "verification by removing the value of the variable in the"; \
  echo "following file (from the top project source directory):"; \
  echo "    reproduce/analysis/config/verify-outputs.mk"; \
  echo; \
  echo "If this is the final version of the file, you can just copy"; \
  echo "and paste the calculated checksum (above) for the file in"; \
  echo "the following project source file:"; \
  echo "    reproduce/analysis/make/verify.mk"

verify-txt-no-comments-leading-space = \
  infile=$(strip $(1)); \
  inchecksum=$(strip $(2)); \
  checksum=$$(sed -e 's/^[[:space:]]*//g' \
                  -e 's/\#.*$$//' \
                  -e '/^$$/d' $$infile \
	          | md5sum \
	          | awk '{print $$1}'); \
  if [ x"$$inchecksum" = x"$$checksum" ]; then \
    echo "Verified: $$infile"; \
  else \
    echo; \
    echo "VERIFICATION ERROR"; \
    echo "------------------"; \
    $(call verify-print-tips); \
    echo; \
    echo "Checked file (without empty or commented lines):"; \
    echo "    $$infile"; \
    echo "Expected MD5 checksum:   $$inchecksum"; \
    echo "Calculated MD5 checksum: $$checksum"; \
    echo; exit 1; \
  fi;





# Final verification TeX macro (can be empty)
# -------------------------------------------
#
# This is the FINAL analysis step (before going onto the paper. Please use
# this step to veryify the contents of the figures/tables used in the paper
# and the LaTeX macros generated from all your processing. It should depend
# on all the LaTeX macro files that are generated (their contents will be
# checked), and any files that go into the tables/figures of the paper
# (generated in various stages of the analysis.
#
# Since each analysis step's data files are already prerequisites of their
# respective TeX macro file, its enough for `verify.tex' to depend on the
# final TeX macro.
#
# USEFUL TIP: during the early phases of your research (when you are
# developing your analysis, and the values aren't final), you can comment
# the respective lines.
#
# Here is a description of the variables defined here.
#
#   verify-dep: The major step dependencies of `verify.tex', this includes
#               all the steps that must be finished before it.
#
#   verify-changes: The files whose contents are important. This is
#               essentially the same as `verify-dep', but it has removed
#               the `initialize' step (which is information about the
#               pipeline, not the results).
verify-dep = $(subst verify,,$(subst paper,,$(makesrc)))
verify-check = $(subst initialize,,$(verify-dep))
$(mtexdir)/verify.tex: $(foreach s, $(verify-dep), $(mtexdir)/$(s).tex)

        # Make sure that verification is actually requested.
	if [ x"$(verify-outputs)" = xyes ]; then

          # Verify the figure datasets.
	  $(call verify-txt-no-comments-leading-space, \
	         $(delete-num), ad345e873e6af577f0e4e7c8942cdf08)
	  $(call verify-txt-no-comments-leading-space, \
	         $(delete-histogram), 12a81c4c8c5f552e5ed5686453587fe8)

          # Verify TeX macros (the values that go into the PDF text).
	  for m in $(verify-check); do
	    file=$(mtexdir)/$$m.tex
	    if   [ $$m == delete-me ]; then s=711e2f7fa1f16ecbeeb3df6bcb4ec705
	    elif [ $$m == download  ]; then s=6749e17ce606d57d30cebdbc1a5d23ad
	    else echo; echo "'$$m' not recognized."; exit 1
	    fi
	    $(call verify-txt-no-comments-leading-space, $$file, $$s)
	  done
	fi

        # Make an empty final target.
	touch $@
