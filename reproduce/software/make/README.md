Software building instructions
------------------------------

Copyright (C) 2019-2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>\
See the end of the file for license conditions.

This directory contains Makefiles that are called by the high-level
`reproduce/software/shell/configure.sh` script. The main target for the
installation of each software is a simple plain text file that contains the
name of the software and its version (which is put in the paper in the
end). Once built, these plain-text files are all put in the proper
sub-directory under `$(BDIR)/software/installed/version-info` (where
`$(BDIR)` is the top-level build-directory specified by the user).

Besides being directly used in the paper, these simple plain text files
also act as prerequisites for higher-level software that depend on
lower-level ones.

### Note on prerequisites

Tarballs are order-only prerequsites (after a `|`) because we already
check their contents with the checksums, so their date is irrelevant: a
tarball with a different content must have a new/different name, thus it
will not exist, so it will be created, even when its order-only.q

Binary programs (that don't install any libraries to be linked/used at
compile time can also be order-only prerequisites, because usually they
don't affect the compilation of the programs that depend on them, they
are only used at run-time or by the low-level build instructions of the
software. Ofcourse, if a program's version affects the build of a
higher-level program, then it shouldn't be order-only.

Libraries or Python modules that are used at compile time must be normal
prerequisites (not order-only), because they are used during the building
of the program.





### Copyright information
This file is part of Maneage (https://maneage.org).

This file is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

This file is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with this file.  If not, see <http://www.gnu.org/licenses/>.
