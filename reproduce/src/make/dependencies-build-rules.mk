# Generic configurable recipes to build packages with GNU Build system or
# CMake. This is Makefile is not intended to be run directly, it will be
# imported into `dependencies-basic.mk' and `dependencies.mk'. They should
# be activated with Make's `Call' function.
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





# IMPORTANT note
# --------------
#
# Without using `&&', if a step fails, the process will continue. However,
# in the `if' statements, we need `;' (particularly between `]' and
# `then'). So we need to put any necessary checks at the start, then when
# we start the process, every command will be separated by an `&&'.





# GNU Build system
# ----------------
#
# Arguments:
#  1: Tarball full address.
#  2: Directory name after unpacking.
#  3: Set to `static' for a static build.
#  4: Extra configuration options.
#  5: Extra options/arguments to pass to Make.
#  6: Step to run between `make' and `make install': usually `make check'.
#
# NOTE: Unfortunately the configure script of `zlib' doesn't recognize
# `SHELL'. So we'll have to remove it from the call to the configure
# script.
gbuild = if [ x$(static_build) = xyes ] && [ $(3)x = staticx ]; then          \
	   export LDFLAGS="$$LDFLAGS -static";                                \
	 fi;                                                                  \
	 check="$(6)";                                                        \
	 if [ x"$$check" = x ]; then check="echo Skipping-check"; fi;         \
	 cd $(ddir); rm -rf $(2);                                             \
	 if ! tar xf $(1); then echo; echo "Tar error"; exit 1; fi;           \
	 cd $(2);                                                             \
                                                                              \
	 if   [ -f configure ]; then confscript=configure;                    \
	 elif [ -f config    ]; then confscript=config;                       \
	 fi;                                                                  \
                                                                              \
	 if   [ -f $(ibdir)/bash ]; then                                      \
	   sed $$confscript -e's|\#\! /bin/sh|\#\! $(ibdir)/bash|'            \
	                    -e's|\#\!/bin/sh|\#\! $(ibdir)/bash|'             \
	       > tmp-$$confscript;                                            \
	   mv tmp-$$confscript $$confscript;                                  \
	   chmod +x $$confscript;                                             \
	   shellop="SHELL=$(ibdir)/bash";                                     \
	 elif [ -f /bin/bash     ]; then shellop="SHELL=/bin/bash";           \
	 else                            shellop="SHELL=/bin/sh";             \
	 fi;                                                                  \
                                                                              \
	 if [ x"$(2)" = x"zlib-$(zlib-version)" ]; then                       \
	    configop="--prefix=$(idir)";                                      \
	 else configop="$$shellop --prefix=$(idir)";                          \
	 fi;                                                                  \
                                                                              \
	 ./$$confscript $(4) $$configop  &&                                   \
	 make "$$shellop" $(5) &&                                             \
	 $$check &&                                                           \
	 make "$$shellop" install &&                                          \
	 cd .. && rm -rf $(2)





# CMake
# -----
#
# According to the link below, in CMake `/bin/sh' is hardcoded, so there is
# no way to change it.
#
# https://stackoverflow.com/questions/21167014/how-to-set-shell-variable-in-makefiles-generated-by-cmake
cbuild = if [ x$(static_build) = xyes ] && [ $(3)x = staticx ]; then          \
	   export LDFLAGS="$$LDFLAGS -static";                                \
	   opts="-DBUILD_SHARED_LIBS=OFF";                                    \
	 fi;                                                                  \
	 cd $(ddir) && rm -rf $(2) && tar xf $(1) && cd $(2) &&               \
	 rm -rf pipeline-build && mkdir pipeline-build &&                     \
	 cd pipeline-build &&                                                 \
	 cmake .. -DCMAKE_LIBRARY_PATH=$(ildir)                               \
	          -DCMAKE_INSTALL_PREFIX=$(idir) $$opts $(4) &&               \
	 make && make install &&                                              \
	 cd ../.. &&                                                          \
	 rm -rf $(2)
