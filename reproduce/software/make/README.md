Software building instructions
==============================

This directory contains Makefiles that are called by the high-level
`reproduce/software/bash/configure.sh' script. The main target for the
installation of each software is a simple plain text file that contains the
name of the software and its version (which is put in the paper in the
end). Once built, these plain-text files are all put in the proper
sub-directory under `$(BDIR)/software/installed/version-info' (where
`$(BDIR)' is the top-level build-directory specified by the user).

Besides being directly used in the paper, these simple plain text files
also act as prerequisites for higher-level software that depend on
lower-level ones.

Note on prerequisites
---------------------

Tarballs are order-only prerequsites (after a `|') because we already
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