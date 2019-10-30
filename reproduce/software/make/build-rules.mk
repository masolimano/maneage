# Generic configurable recipes to build packages with GNU Build system or
# CMake. This is Makefile is not intended to be run directly, it will be
# imported into `dependencies-basic.mk' and `dependencies.mk'. They should
# be activated with Make's `Call' function.
#
# Copyright (C) 2018-2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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
#  1: Directory name after unpacking.
#  2: Set to `static' for a static build.
#  3: Extra configuration options.
#  4: Extra options/arguments to pass to Make.
#  5: Step to run between `make' and `make install': usually `make check'.
#  6: The configuration script (`configure' by default).
#  7: Arguments for `make install'.
#
# NOTE: Unfortunately the configure script of `zlib' doesn't recognize
# `SHELL'. So we'll have to remove it from the call to the configure
# script.
#
# NOTE: A program might not contain any configure script. In this case,
# we'll just pass a non-relevant function like `pwd'. So SED should be used
# to modify `confscript' or to set `configop'.
gbuild = if [ x$(static_build) = xyes ] && [ "x$(2)" = xstatic ]; then \
	   export LDFLAGS="$$LDFLAGS -static"; \
	 fi; \
	 check="$(5)"; \
	 if [ x"$$check" = x ]; then check="echo Skipping-check"; fi; \
	 cd $(ddir); rm -rf $(1); \
	 if [ x"$$gbuild_tar" = x ]; then \
	   tarball=$(word 1,$(filter $(tdir)/%,$|)); \
	 else tarball=$$gbuild_tar; \
	 fi; \
	 if ! tar xf $$tarball; then \
	   echo; echo "Tar error"; exit 1; fi; \
	 cd $(1); \
	          \
	 if   [ x"$(strip $(6))" = x ]; then confscript=./configure; \
	 else confscript="$(strip $(6))"; \
	 fi; \
             \
	 if   [ -f $(ibdir)/bash ]; then \
	   if [ -f $$confscript ]; then \
	     sed -e's|\#\! /bin/sh|\#\! $(ibdir)/bash|' \
	         -e's|\#\!/bin/sh|\#\! $(ibdir)/bash|' \
	         $$confscript > $$confscript-tmp; \
	     mv $$confscript-tmp $$confscript; \
	     chmod +x $$confscript; \
	   fi; \
	   shellop="SHELL=$(ibdir)/bash"; \
	 elif [ -f /bin/bash ]; then shellop="SHELL=/bin/bash"; \
	 else shellop="SHELL=/bin/sh"; \
	 fi; \
             \
	 if [ -f $$confscript ]; then \
	   if [ x"$(strip $(1))" = x"zlib-$(zlib-version)" ]; then \
	     configop="--prefix=$(idir)"; \
	   else configop="$$shellop --prefix=$(idir)"; \
	   fi; \
	 fi; \
	     \
	 echo; echo "Using '$$confscript' to configure:"; echo; \
	 echo "$$confscript $(3) $$configop"; echo; \
	 $$confscript $(3) $$configop \
	 && make "$$shellop" $(4) \
	 && $$check \
	 && make "$$shellop" install $(7) \
	 && cd .. \
	 && rm -rf $(1)




# CMake
# -----
#
# According to the link below, in CMake `/bin/sh' is hardcoded, so there is
# no way to change it unfortunately!
#
# https://stackoverflow.com/questions/21167014/how-to-set-shell-variable-in-makefiles-generated-by-cmake
cbuild = if [ x$(static_build) = xyes ] && [ $(2)x = staticx ]; then \
	   export LDFLAGS="$$LDFLAGS -static"; \
	   opts="-DBUILD_SHARED_LIBS=OFF"; \
	 fi; \
	 cd $(ddir) \
	 && rm -rf $(1) \
	 && tar xf $(word 1,$(filter $(tdir)/%,$|)) \
	 && cd $(1) \
	 && rm -rf project-build \
	 && mkdir project-build \
	 && cd project-build \
	 && cmake .. -DCMAKE_LIBRARY_PATH=$(ildir) \
	             -DCMAKE_INSTALL_PREFIX=$(idir) \
	             -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON $$opts $(3) \
	 && make && make install \
	 && cd ../.. \
	 && rm -rf $(1)
