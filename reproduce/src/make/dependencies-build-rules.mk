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
gbuild = if [ x$(static_build) = xyes ] && [ $(3)x = staticx ]; then          \
	   export LDFLAGS="$$LDFLAGS -static";                                \
	 fi;                                                                  \
	 check="$(6)";                                                        \
	 if [ x"$$check" = x ]; then check="echo Skipping-check"; fi;         \
	 cd $(ddir) && rm -rf $(2) && tar xf $(tdir)/$(1) && cd $(2) &&       \
	 ./configure $(4) --prefix=$(idir) &&                                 \
	 make $(5) &&                                                         \
	 $$check &&                                                           \
	 make install&&                                                       \
	 cd .. && rm -rf $(2)





# CMake
# -----
cbuild = if [ x$(static_build) = xyes ] && [ $(3)x = staticx ]; then          \
	   export LDFLAGS="$$LDFLAGS -static";                                \
	   opts="-DBUILD_SHARED_LIBS=OFF";                                    \
	 fi;                                                                  \
	 cd $(ddir) && rm -rf $(2) && tar xf $(tdir)/$(1) && cd $(2) &&       \
	 rm -rf pipeline-build && mkdir pipeline-build &&                     \
	 cd pipeline-build &&                                                 \
	 cmake .. $$opts $(4) &&                                              \
	 cmake --build . &&                                                   \
	 cmake .. -DCMAKE_INSTALL_PREFIX=$(idir) &&                           \
	 cmake --build . --target install &&                                  \
	 cd ../.. &&                                                          \
	 rm -rf $(2)
