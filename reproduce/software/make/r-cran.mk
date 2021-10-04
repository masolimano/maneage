# Build the project's R (here called R-CRAN) dependencies.
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be loaded into 'high-level.mk', which is called by the
# './project configure' script. It is not included into the project
# afterwards.
#
# This Makefile contains instructions to build all the R-CRAN-related
# software within the project.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2022 Boud Roukema <boud@cosmo.torun.pl>
# Copyright (C) 2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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





# BUGS/IMPROVEMENTS
# -----------------
#
# As of 2021-06-20, the R system is still very new and has not yet
# been tested on non-Debian-derived systems. Please provide bug
# reports ( https://savannah.nongnu.org/task/?15772 ) or propose fixes
# as git pull requests on a public git server (e.g.  on a fork of
# https://codeberg.org/boud/maneage_dev ).





# R-CRAN enviroment
# -----------------
#
# It may be necessary to override host-level R-related environment
# variables that interfere with the Maneage-installed R system.
# systems which might interfere.

# Ideas for which environment variables might create problems
# and might need to be set to be empty here:
#
# https://stat.ethz.ch/R-manual/R-devel/library/base/html/EnvVar.html

# These first variables should be set automatically when R starts:
#export R_HOME             := $(idir)/lib/R
#export R_INCLUDE_DIR      := $(idir)/lib/R/include





# R-CRAN-specific installation directories.
r-cran-major-version = $(shell echo $(r-cran-version) \
                                    | awk 'BEGIN{FS="."} \
	                            {printf "%d.%d\n", $$1, $$2}')





# R-CRAN-specific build rules for 'make'
# ======================================

# Double-check an already downloaded R source
# -------------------------------------------
#
# Check that the tarball with the version in
# 'reproduce/software/conf/versions.conf' has the sha512sum (checksum)
# stated 'reproduce/software/conf/checksums.conf'. This does not do any
# security checks; it only checks that the source file package is the one
# that is expected the last time that someone updated these two files for
# the R package of interest.
#
# Calculate the checksum and exit with a non-zero error code if there's a
# mismatch, after informing the user.
#
# Arguments:
#   1: The expected checksum of the tarball.
#
# Necessary shell variables
#   'tarball': This is the name of the actual tarball file without a
#   directory.
double-check-R-source = final=$(tdir)/$$tarball; \
	exp_checksum="$(strip $(1))"; \
	if [ x"$$exp_checksum" = x"NO-CHECK-SUM" ]; then \
	  result=0; \
	else \
	  if type sha512sum > /dev/null 2>/dev/null; then \
	    checksum=$$(sha512sum "$$final" | awk '{print $$1}'); \
	    if [ x"$$checksum" = x"$$exp_checksum" ]; then \
	      result=0; \
	    else \
	      echo "ERROR: Non-matching checksum: $$final"; \
	      echo "Checksum should be: $$exp_checksum"; \
	      echo "Checksum is:        $$checksum"; \
	      result=1; \
	      exit 1; \
	    fi; \
	  else \
	    echo "ERROR: sha512sum is unavailable."; \
	    exit 1; \
	  fi; \
	fi

# Default 'make' build rules for an CRAN package
# -----------------------------------------------
#
# The default 'install.packages' function of R only recognizes 'tar.gz'
# tarballs. But Maneage uses '.tar.lz' format for its archival. So to be
# agnostic to the compression algorithm, we will be using 'tar' externally
# (before entering R), then give the un-compressed directory to
# 'install.packages'.
#
# Parameters:
# 1. package name (without 'r-cran', without the version string)
# 2. version string
# 3. checksum of the package
r_cran_build = \
	pkg=$(strip $(1)); \
	version=$(strip $(2)); \
	checksum=$(strip $(3)); \
	$(call import-source, \
	       https://cran.r-project.org/src/contrib, \
	       $$checksum, \
	       $$tarball, \
	       https://cran.r-project.org/src/contrib/00Archive/$$pkg); \
	cd "$(ddir)"; \
	tar -xf $(tdir)/$$tarball; \
	unpackdir=$$pkg-$$version; \
	(printf "install.packages(c(\"$(ddir)/$$unpackdir\"),"; \
	 printf 'lib="$(ilibrcrandir)",'; \
	 printf 'repos=NULL,'; \
	 printf 'type="source")\n'; \
	 printf 'quit()\n'; \
	 printf 'n\n') | R --no-save; \
	rm -rf $$unpackdir; \
	if [ $$pkg = r-pkgconfig ]; then iname=pkgconfig; \
	else                             iname=$$pkg; fi; \
	if [ -e "$(ilibrcrandir)"/$$iname/Meta/nsInfo.rds ]; then \
	   $(call double-check-R-source, $$checksum) \
	          && echo "$$pkg $$version" > $@; \
	else \
	   printf "r-cran-$$pkg failed: Meta/nsInfo.rds missing.\n"; \
	   exit 1; \
	fi





# Necessary programs and libraries
# --------------------------------
#
# While this Makefile is for R programs, in some cases, we need certain
# programs (like R itself), or libraries for the modules.  Comment on
# building R without GUI support ('--without-tcltlk')
#
# Tcl/Tk are a set of tools to provide Graphic User Interface (GUI) support
# in some software. But they are not yet natively built within Maneage,
# primarily because we have higher-priority work right now (if anyone is
# interested, they can ofcourse contribute!). GUI tools in general aren't
# high on our priority list right now because they are generally good for
# human interaction (which is contrary to the reproducible philosophy:
# there will always be human-error and frustration, for example in GUI
# tools the best level of reproducibility is statements like this: "move
# your mouse to button XXX, then click on menu YYY and etc"). A robust
# reproducible solution must be done automatically.
#
# If someone wants to use R's GUI functionalities while investigating for
# their analysis, they can do the GUI part on their host OS
# implementation. Later, they can bring the finalized source into Maneage
# to be automatically run in Maneage. This will also be the recommended way
# to deal with GUI tools later when we do install them within Maneage.
$(ibidir)/r-cran-$(r-cran-version): \
            $(itidir)/texlive \
            $(ibidir)/icu-$(icu-version) \
            $(ibidir)/pcre-$(pcre-version) \
            $(ibidir)/cairo-$(cairo-version) \
            $(ibidir)/libpng-$(libpng-version) \
            $(ibidir)/libjpeg-$(libjpeg-version) \
            $(ibidir)/libtiff-$(libtiff-version) \
            $(ibidir)/libpaper-$(libpaper-version)

#	Prepare the tarball, unpack it and enter the directory.
	tarball=R-$(r-cran-version).tar.lz
	$(call import-source, $(r-cran-url), $(r-cran-checksum))
	cd $(ddir)
	tar -xf $(tdir)/$$tarball
	unpackdir=R-$(r-cran-version)
	cd $$unpackdir

#	We need to manually remove the lines with '~autodetect~', they
#	cause the configure script to crash in version 4.0.2. They are used
#	in relation to Java, and we don't use Java anyway.
	sed -i -e '/\~autodetect\~/ s/^/#/g' configure
	export R_SHELL=$(SHELL)
	./configure --prefix=$(idir) \
	            --without-x \
	            --with-pcre1 \
	            --disable-java \
	            --with-readline \
	            --without-tcltk \
	            --disable-openmp
	make -j$(numthreads)
	make install
	cd ..
	rm -rf R-$(r-cran-version)
	cp -p $(dtexdir)/r-cran.tex $(ictdir)/
	echo "R $(r-cran-version) \citep{RIhakaGentleman1996}" > $@





# Non-Maneage'd tarballs
# ----------------------
#
# CRAN tarballs differ in two aspects from Maneage'd tarballs:
#    - CRAN uses '.tar.gz', while Maneage uses 'tar.lz'.
#    - CRAN uses 'name_version', while Maneage uses 'name-version'.
#
# So if you add a new R package, or update the version of an existing one
# (that is not yet in Maneage's archive), you need to use the CRAN naming
# format for the 'tarball' variable.





# R-CRAN modules
# ---------------
#
# The rules for downloading, compiling and installing any R-CRAN modules
# that are needed should be provided here. Each target (before the colon)
# is first shown with its dependence on prerequisites (which are listed
# after the colon. The default macro 'r_cran_build' will install the
# package without checking on dependencies.

$(ircrandir)/r-cran-cli-$(r-cran-cli-version): \
                        $(ibidir)/r-cran-$(r-cran-version) \
                        $(ircrandir)/r-cran-glue-$(r-cran-glue-version)
	tarball=cli-$(r-cran-cli-version).tar.lz
	$(call r_cran_build, cli, $(r-cran-cli-version), \
	                     $(r-cran-cli-checksum))

$(ircrandir)/r-cran-colorspace-$(r-cran-colorspace-version): \
                               $(ibidir)/r-cran-$(r-cran-version)
	tarball=colorspace-$(r-cran-colorspace-version).tar.lz
	$(call r_cran_build, colorspace, $(r-cran-colorspace-version), \
	                     $(r-cran-colorspace-checksum))

$(ircrandir)/r-cran-cowplot-$(r-cran-cowplot-version): \
                 $(ibidir)/r-cran-$(r-cran-version) \
                 $(ircrandir)/r-cran-rlang-$(r-cran-rlang-version) \
                 $(ircrandir)/r-cran-gtable-$(r-cran-gtable-version) \
                 $(ircrandir)/r-cran-scales-$(r-cran-scales-version) \
                 $(ircrandir)/r-cran-ggplot2-$(r-cran-ggplot2-version)
	tarball=cowplot-$(r-cran-cowplot-version).tar.lz
	$(call r_cran_build, cowplot, $(r-cran-cowplot-version), \
	                     $(r-cran-cowplot-checksum))

$(ircrandir)/r-cran-crayon-$(r-cran-crayon-version): \
                           $(ibidir)/r-cran-$(r-cran-version)
	tarball=crayon-$(r-cran-crayon-version).tar.lz
	$(call r_cran_build, crayon, $(r-cran-crayon-version), \
	                     $(r-cran-crayon-checksum))

$(ircrandir)/r-cran-digest-$(r-cran-digest-version): \
                           $(ibidir)/r-cran-$(r-cran-version)
	tarball=digest-$(r-cran-digest-version).tar.lz
	$(call r_cran_build, digest, $(r-cran-digest-version), \
	                     $(r-cran-digest-checksum))

$(ircrandir)/r-cran-farver-$(r-cran-farver-version): \
                           $(ibidir)/r-cran-$(r-cran-version)
	tarball=farver-$(r-cran-farver-version).tar.lz
	$(call r_cran_build, farver, $(r-cran-farver-version), \
	                     $(r-cran-farver-checksum))

$(ircrandir)/r-cran-ellipsis-$(r-cran-ellipsis-version): \
                    $(ibidir)/r-cran-$(r-cran-version) \
                    $(ircrandir)/r-cran-rlang-$(r-cran-rlang-version)
	tarball=ellipsis-$(r-cran-ellipsis-version).tar.lz
	$(call r_cran_build, ellipsis, $(r-cran-ellipsis-version), \
	                     $(r-cran-ellipsis-checksum))

$(ircrandir)/r-cran-fansi-$(r-cran-fansi-version): \
                          $(ibidir)/r-cran-$(r-cran-version)
	tarball=fansi-$(r-cran-fansi-version).tar.lz
	$(call r_cran_build, fansi, $(r-cran-fansi-version), \
	                     $(r-cran-fansi-checksum))

$(ircrandir)/r-cran-ggplot2-$(r-cran-ggplot2-version): \
                $(ibidir)/r-cran-$(r-cran-version) \
                $(ircrandir)/r-cran-glue-$(r-cran-glue-version) \
                $(ircrandir)/r-cran-mgcv-$(r-cran-mgcv-version) \
                $(ircrandir)/r-cran-MASS-$(r-cran-MASS-version) \
                $(ircrandir)/r-cran-rlang-$(r-cran-rlang-version) \
                $(ircrandir)/r-cran-withr-$(r-cran-withr-version) \
                $(ircrandir)/r-cran-digest-$(r-cran-digest-version) \
                $(ircrandir)/r-cran-gtable-$(r-cran-gtable-version) \
                $(ircrandir)/r-cran-scales-$(r-cran-scales-version) \
                $(ircrandir)/r-cran-tibble-$(r-cran-tibble-version) \
                $(ircrandir)/r-cran-isoband-$(r-cran-isoband-version)
	tarball=ggplot2-$(r-cran-ggplot2-version).tar.lz
	$(call r_cran_build, ggplot2, $(r-cran-ggplot2-version), \
	                     $(r-cran-ggplot2-checksum))

$(ircrandir)/r-cran-glue-$(r-cran-glue-version): \
                         $(ibidir)/r-cran-$(r-cran-version)
	tarball=glue-$(r-cran-glue-version).tar.lz
	$(call r_cran_build, glue, $(r-cran-glue-version), \
	                     $(r-cran-glue-checksum))

$(ircrandir)/r-cran-gridExtra-$(r-cran-gridExtra-version): \
                  $(ibidir)/r-cran-$(r-cran-version) \
                  $(ircrandir)/r-cran-gtable-$(r-cran-gtable-version)
	tarball=gridExtra-$(r-cran-gridExtra-version).tar.lz
	$(call r_cran_build, gridExtra, $(r-cran-gridExtra-version), \
	                     $(r-cran-gridExtra-checksum))

$(ircrandir)/r-cran-gtable-$(r-cran-gtable-version): \
                           $(ibidir)/r-cran-$(r-cran-version)
	tarball=gtable-$(r-cran-gtable-version).tar.lz
	$(call r_cran_build, gtable, $(r-cran-gtable-version), \
	                     $(r-cran-gtable-checksum))

$(ircrandir)/r-cran-isoband-$(r-cran-isoband-version): \
                            $(ibidir)/r-cran-$(r-cran-version)
	tarball=isoband-$(r-cran-isoband-version).tar.lz
	$(call r_cran_build, isoband, $(r-cran-isoband-version), \
	                     $(r-cran-isoband-checksum))

$(ircrandir)/r-cran-labeling-$(r-cran-labeling-version): \
                             $(ibidir)/r-cran-$(r-cran-version)
	tarball=labeling-$(r-cran-labeling-version).tar.lz
	$(call r_cran_build, labeling, $(r-cran-labeling-version), \
                             $(r-cran-labeling-checksum))

$(ircrandir)/r-cran-lifecycle-$(r-cran-lifecycle-version): \
                    $(ibidir)/r-cran-$(r-cran-version) \
                    $(ircrandir)/r-cran-glue-$(r-cran-glue-version) \
                    $(ircrandir)/r-cran-rlang-$(r-cran-rlang-version)
	tarball=lifecycle-$(r-cran-lifecycle-version).tar.lz
	$(call r_cran_build, lifecycle, $(r-cran-lifecycle-version), \
	                     $(r-cran-lifecycle-checksum))

$(ircrandir)/r-cran-magrittr-$(r-cran-magrittr-version): \
                             $(ibidir)/r-cran-$(r-cran-version)
	tarball=magrittr-$(r-cran-magrittr-version).tar.lz
	$(call r_cran_build, magrittr, $(r-cran-magrittr-version), \
	                     $(r-cran-magrittr-checksum))

$(ircrandir)/r-cran-MASS-$(r-cran-MASS-version): \
                         $(ibidir)/r-cran-$(r-cran-version)
	tarball=MASS-$(r-cran-MASS-version).tar.lz
	$(call r_cran_build, MASS, $(r-cran-MASS-version), \
	                     $(r-cran-MASS-checksum))

# The base R-2.0.4 install includes nlme and Matrix.
# https://cran.r-project.org/web/packages/mgcv/index.html
$(ircrandir)/r-cran-mgcv-$(r-cran-mgcv-version): \
                         $(ibidir)/r-cran-$(r-cran-version)
	tarball=mgcv-$(r-cran-mgcv-version).tar.lz
	$(call r_cran_build, mgcv, $(r-cran-mgcv-version), \
	                     $(r-cran-mgcv-checksum))

$(ircrandir)/r-cran-munsell-$(r-cran-munsell-version): \
                 $(ibidir)/r-cran-$(r-cran-version) \
                 $(ircrandir)/r-cran-colorspace-$(r-cran-colorspace-version)
	tarball=munsell-$(r-cran-munsell-version).tar.lz
	$(call r_cran_build, munsell, $(r-cran-munsell-version), \
	                     $(r-cran-munsell-checksum))

#TODO: https://cran.r-project.org/web/packages/pillar/index.html
$(ircrandir)/r-cran-pillar-$(r-cran-pillar-version): \
              $(ibidir)/r-cran-$(r-cran-version) \
              $(ircrandir)/r-cran-cli-$(r-cran-cli-version) \
              $(ircrandir)/r-cran-utf8-$(r-cran-utf8-version) \
              $(ircrandir)/r-cran-fansi-$(r-cran-fansi-version) \
              $(ircrandir)/r-cran-rlang-$(r-cran-rlang-version) \
              $(ircrandir)/r-cran-vctrs-$(r-cran-vctrs-version) \
              $(ircrandir)/r-cran-crayon-$(r-cran-crayon-version) \
              $(ircrandir)/r-cran-ellipsis-$(r-cran-ellipsis-version) \
              $(ircrandir)/r-cran-lifecycle-$(r-cran-lifecycle-version)
	tarball=pillar-$(r-cran-pillar-version).tar.lz
	$(call r_cran_build, pillar, $(r-cran-pillar-version), \
	                     $(r-cran-pillar-checksum))

# Since we have other software packages with the name 'pkgconfig', to avoid
# confusion with those tarballs, we have put a 'r-' prefix in the tarball
# name. If you want to use the CRAN tarball, please correct the name
# accordingly (as described in the comment above this group of rules).
$(ircrandir)/r-cran-pkgconfig-$(r-cran-pkgconfig-version): \
                              $(ibidir)/r-cran-$(r-cran-version)
	tarball=r-pkgconfig-$(r-cran-pkgconfig-version).tar.lz
	$(call r_cran_build, r-pkgconfig, $(r-cran-pkgconfig-version), \
	                     $(r-cran-pkgconfig-checksum))

$(ircrandir)/r-cran-RColorBrewer-$(r-cran-RColorBrewer-version): \
                                 $(ibidir)/r-cran-$(r-cran-version)
	tarball=RColorBrewer-$(r-cran-RColorBrewer-version).tar.lz
	$(call r_cran_build, RColorBrewer, $(r-cran-RColorBrewer-version), \
	                     $(r-cran-RColorBrewer-checksum))

$(ircrandir)/r-cran-R6-$(r-cran-R6-version): \
                       $(ibidir)/r-cran-$(r-cran-version)
	tarball=R6-$(r-cran-R6-version).tar.lz
	$(call r_cran_build, R6, $(r-cran-R6-version), $(r-cran-R6-checksum))

$(ircrandir)/r-cran-rlang-$(r-cran-rlang-version): \
                          $(ibidir)/r-cran-$(r-cran-version)
	tarball=rlang-$(r-cran-rlang-version).tar.lz
	$(call r_cran_build, rlang, $(r-cran-rlang-version), \
	                     $(r-cran-rlang-checksum))

# https://cran.r-project.org/web/packages/scales/index.html
$(ircrandir)/r-cran-scales-$(r-cran-scales-version): \
           $(ibidir)/r-cran-$(r-cran-version) \
           $(ircrandir)/r-cran-R6-$(r-cran-R6-version) \
           $(ircrandir)/r-cran-farver-$(r-cran-farver-version) \
           $(ircrandir)/r-cran-munsell-$(r-cran-munsell-version) \
           $(ircrandir)/r-cran-labeling-$(r-cran-labeling-version) \
           $(ircrandir)/r-cran-lifecycle-$(r-cran-lifecycle-version) \
           $(ircrandir)/r-cran-viridisLite-$(r-cran-viridisLite-version) \
           $(ircrandir)/r-cran-RColorBrewer-$(r-cran-RColorBrewer-version)
	tarball=scales-$(r-cran-scales-version).tar.lz
	$(call r_cran_build, scales, $(r-cran-scales-version), \
	                     $(r-cran-scales-checksum))

#https://cran.r-project.org/web/packages/tibble/index.html
$(ircrandir)/r-cran-tibble-$(r-cran-tibble-version): \
              $(ibidir)/r-cran-$(r-cran-version) \
              $(ircrandir)/r-cran-fansi-$(r-cran-fansi-version) \
              $(ircrandir)/r-cran-rlang-$(r-cran-rlang-version) \
              $(ircrandir)/r-cran-vctrs-$(r-cran-vctrs-version) \
              $(ircrandir)/r-cran-pillar-$(r-cran-pillar-version) \
              $(ircrandir)/r-cran-ellipsis-$(r-cran-ellipsis-version) \
              $(ircrandir)/r-cran-magrittr-$(r-cran-magrittr-version) \
              $(ircrandir)/r-cran-lifecycle-$(r-cran-lifecycle-version) \
              $(ircrandir)/r-cran-pkgconfig-$(r-cran-pkgconfig-version)
	tarball=tibble-$(r-cran-tibble-version).tar.lz
	$(call r_cran_build, tibble, $(r-cran-tibble-version), \
	                     $(r-cran-tibble-checksum))

$(ircrandir)/r-cran-utf8-$(r-cran-utf8-version): \
                         $(ibidir)/r-cran-$(r-cran-version)
	tarball=utf8-$(r-cran-utf8-version).tar.lz
	$(call r_cran_build, utf8, $(r-cran-utf8-version), \
	                     $(r-cran-utf8-checksum))

$(ircrandir)/r-cran-vctrs-$(r-cran-vctrs-version): \
              $(ibidir)/r-cran-$(r-cran-version) \
              $(ircrandir)/r-cran-glue-$(r-cran-glue-version) \
              $(ircrandir)/r-cran-rlang-$(r-cran-rlang-version) \
              $(ircrandir)/r-cran-ellipsis-$(r-cran-ellipsis-version)
	tarball=vctrs-$(r-cran-vctrs-version).tar.lz
	$(call r_cran_build, vctrs, $(r-cran-vctrs-version), \
	                     $(r-cran-vctrs-checksum))

$(ircrandir)/r-cran-viridisLite-$(r-cran-viridisLite-version): \
                                $(ibidir)/r-cran-$(r-cran-version)
	tarball=viridisLite-$(r-cran-viridisLite-version).tar.lz
	$(call r_cran_build, viridisLite, $(r-cran-viridisLite-version), \
	                     $(r-cran-viridisLite-checksum))

$(ircrandir)/r-cran-withr-$(r-cran-withr-version): \
                          $(ibidir)/r-cran-$(r-cran-version)
	tarball=withr-$(r-cran-withr-version).tar.lz
	$(call r_cran_build, withr, $(r-cran-withr-version), \
	                     $(r-cran-withr-checksum))
