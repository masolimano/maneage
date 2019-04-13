# Rules to build ATLAS shared libraries in multi-threaded mode on GNU/Linux
#
# ------------------------------------------------------------------------
#                      !!!!! IMPORTANT NOTES !!!!!
#
# This Makefile will be run during the initial `./configure' script. It is
# not included into the reproduction pipe after that.
#
# ------------------------------------------------------------------------
#
# Copyright (C) 2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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

ORIGLDFLAGS := $(LDFLAGS)

include Make.inc

all: libatlas.so libf77blas.so libptf77blas.so libstcblas.so libptcblas.so \
   libblas.so libcblas.so liblapack.so.3.6.1 libptlapack.so.3.6.1 liblapack.so.3

libatlas.so: libatlas.a
	ld $(ORIGLDFLAGS) $(LDFLAGS) -shared -soname $@ -o $@ \
	   --whole-archive libatlas.a --no-whole-archive -lc $(LIBS)

libf77blas.so : libf77blas.a libatlas.so
	ld $(ORIGLDFLAGS) $(LDFLAGS) -shared -soname libf77blas.so.3 \
	   -o $@ --whole-archive libf77blas.a --no-whole-archive \
	   $(F77SYSLIB) -L. -latlas

libptf77blas.so : libptf77blas.a libatlas.so
	ld $(ORIGLDFLAGS) $(LDFLAGS) -shared -soname libblas.so.3 \
	   -o $@ --whole-archive libptf77blas.a --no-whole-archive \
	   $(F77SYSLIB) -L. -latlas

libstcblas.so : libcblas.a libatlas.so libblas.so
	ld $(ORIGLDFLAGS) $(LDFLAGS) -shared -soname libstcblas.so \
	   -o $@ --whole-archive libcblas.a -L. -latlas -lblas

libptcblas.so : libptcblas.a libatlas.so libblas.so
	ld $(ORIGLDFLAGS) $(LDFLAGS) -shared -soname libcblas.so \
	   -o $@ --whole-archive libptcblas.a -L. -latlas -lblas

libblas.so: libptf77blas.so
	ln -s $< $@

libcblas.so: libptcblas.so
	ln -s $< $@

liblapack.so.3.6.1 : liblapack.a libstcblas.so libf77blas.so
	ld $(ORIGLDFLAGS) $(LDFLAGS) -shared -soname libstlapack.so.3 \
	   -o $@ --whole-archive liblapack.a --no-whole-archive \
	   $(F77SYSLIB) -L. -lstcblas -lf77blas

libptlapack.so.3.6.1 : libptlapack.a libcblas.so libblas.so
	ld $(ORIGLDFLAGS) $(LDFLAGS) -shared -soname liblapack.so.3 \
	   -o $@ --whole-archive libptlapack.a --no-whole-archive \
	   $(F77SYSLIB) -L. -lcblas -lblas

liblapack.so.3: libptlapack.so.3.6.1
	ln -s $< $@
