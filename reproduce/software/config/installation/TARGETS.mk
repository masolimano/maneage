# Necessary high-level software to build in this project.
#
# Copyright (C) 2018-2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Copyright (C) 2019 Raul Infante-Sainz <infantesainz@gmail.com>
#
# Copying and distribution of this file, with or without modification, are
# permitted in any medium without royalty provided the copyright notice and
# this notice are preserved.  This file is offered as-is, without any
# warranty.





# AVAILABLE SOFTWARE
# ------------------
#
# All software that are currently available for installation can be seen in
# the following file.
#
#     reproduce/software/config/installation/versions.mk
#
# Please add any software that you need for your project in the respective
# part below (using its name in `versions.mk', but without the `-version'
# part). Just note that if a program/library is a dependency of another,
# you don't need to include it here (it will be installed before the
# higher-level software anyway).
#
# Note that many low-level software will be installed before those that are
# installed in this step. They are clearly distinguished from the
# higher-level (optional) software in `versions.mk'. These low-level
# software MUST NOT be added here.





# Programs and libraries.
top-level-programs  = gnuastro scons

# Python libraries/modules.
top-level-python    = astropy
