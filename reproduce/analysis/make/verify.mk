# Verify the project outputs before building the paper.
#
# Copyright (C) 2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# Verification functions
# ----------------------
#
# These functions are used by the final rule in this Makefil
verify-print-error-start = \
  echo; \
  echo "VERIFICATION ERROR"; \
  echo "------------------"; \
  echo

verify-print-tips = \
  echo "If you are still developing your project, you can disable"; \
  echo "verification by removing the value of the variable in the"; \
  echo "following file (from the top project source directory):"; \
  echo "    reproduce/analysis/config/verify-outputs.conf"; \
  echo; \
  echo "If this is the final version of the file, you can just copy"; \
  echo "and paste the calculated checksum (above) for the file in"; \
  echo "the following project source file:"; \
  echo "    reproduce/analysis/make/verify.mk"

# Removes following components of a plain-text file, calculates checksum
# and compares with given checksum:
#   - All commented lines (starting with '#') are removed.
#   - All empty lines are removed.
#   - All space-characters in remaining lines are removed (so the width of
#     the printed columns won't invalidate the verification).
#
# It takes three arguments:
#   - First argument: Full address of file to check.
#   - Second argument: Expected checksum of the file to check.
#   - File name to write result.
verify-txt-no-comments-no-space = \
  infile=$(strip $(1)); \
  inchecksum=$(strip $(2)); \
  innobdir=$$(echo $$infile | sed -e's|$(BDIR)/||g'); \
  if ! [ -f "$$infile" ]; then \
    $(call verify-print-error-start); \
    echo "The following file (that should be verified) doesn't exist:"; \
    echo "    $$infile"; \
    echo; exit 1; \
  fi; \
  checksum=$$(sed -e 's/[[:space:]][[:space:]]*//g' \
                  -e 's/\#.*$$//' \
                  -e '/^$$/d' $$infile \
                  | md5sum \
                  | awk '{print $$1}'); \
  if [ x"$$inchecksum" = x"$$checksum" ]; then \
    echo "%% (VERIFIED) $$checksum $$innobdir" >> $(3); \
  else \
    $(call verify-print-error-start); \
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

          # Make sure the temporary output doesn't exist (because we want
          # to append to it). We are making a temporary output target so if
          # there is a crash in the middle, Make will not continue. If we
          # write in the final target progressively, the file will exist,
          # and its date will be more recent than all prerequisites, so
          # next time the project is run, Make will continue and ignore the
          # rest of the checks.
	  rm -f $@.tmp

          # Verify the figure datasets.
	  $(call verify-txt-no-comments-no-space, \
	         $(dm-squared), 6b6d3b0f9c351de53606507b59bca5d1, $@.tmp)
	  $(call verify-txt-no-comments-no-space, \
	         $(dm-img-histogram), b1f9c413f915a1ad96078fee8767b16c, $@.tmp)

          # Verify TeX macros (the values that go into the PDF text).
	  for m in $(verify-check); do
	    file=$(mtexdir)/$$m.tex
	    if   [ $$m == download  ]; then s=49e4e9f049aa9da0453a67203d798587
	    elif [ $$m == delete-me ]; then s=711e2f7fa1f16ecbeeb3df6bcb4ec705
	    else echo; echo "'$$m' not recognized."; exit 1
	    fi
	    $(call verify-txt-no-comments-no-space, $$file, $$s, $@.tmp)
	  done

          # Move temporary file to final target.
	  mv $@.tmp $@
	else
	  echo "% Verification was DISABLED!" > $@
	fi
