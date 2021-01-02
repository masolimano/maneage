#!/usr/bin/env sh

# Surrounding text for software acknowledgement and citation. The list of
# names, versions and citations of the software are written by an automatic
# script. However, through this file, users have the option to specify the
# text surrounding those lists.
#
# We recommend to leave these values untouched at first, after building
# your PDF, you can see how they surround the list of software you used in
# your project to make a smoothly readable English text. Afterwards, please
# feel free to modify them as you wish.
#
# Copyright (C) 2021 Boud Roukema <boud@cosmo.torun.pl>
# Copyright (C) 2021 Mohammad Akhlaghi <mohammad@akhlaghi.org>
#
# This script is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# This script is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# A copy of the GNU General Public License is available at
# <http://www.gnu.org/licenses/>.

# WARNING:
# In contrast to most configure files in maneage, this configure file is
# technically a shell script, to be called by 'configure.sh', so the
# variables defined here must follow 'shell' syntax, not 'make' syntax.

# These variables will be exported to the 'configure.sh' script - so
# descriptive, unique names should be used, to reduce the chance of
# conflicts between identically named variables.

# COMMENT:
# Sentences have a tendancy to become very long. To avoid making the
# variable values too long (and thus making this file hard to read), one
# method is to break the sentence into smaller components and build the
# full sentence gradually, similar to what we have done with 'str' in the
# examples below. Each time, the value of 'str' is re-written by appending
# its previous value with the rest of the sentence.

# COMMENT:
# As of 2020-06-10, the general issue of how to best cite software within
# maneage, especially a full list of software in the Acknowledgments
# section, remains wide open. See
# https://savannah.nongnu.org/task/index.php?15318 for some technical
# aspects of software citation.





# Add your definitions of the LaTeX text here.
#
# To override a default but generate no text, use a string of non-zero
# length such as "{}" that will have only minor effects in LaTeX.

# An introduction to the software acknowledgement.
thank_software_introduce=

# The text to be used before listing C/C++ programs and libraries.
thank_progs_libs=

# The text to be used before listing Python modules.
thank_python=

# The text to be used before listing LaTeX packages.
thank_latex=

# Concluding remarks.
thank_software_conclude=





# Defaults
# --------
#
# These are the default values which are only written into the variable if
# you don't specify a value above
if [ "x$thank_software_introduce" = "x" ]; then
    thank_software_introduce=""
fi

if [ "x$thank_progs_libs" = "x" ]; then
    str="This research was done with the following free software"
    str="$str programs and libraries:"
    thank_progs_libs="$str"
fi

if [ "x$thank_python" = "x" ]; then
    thank_python="Within Python, the following modules were used:"
fi

if [ "x$thank_latex" = "x" ]; then
    str="The \LaTeX{} source of the paper was compiled to make the"
    str="$str PDF using the following packages:"
    thank_latex="$str"
fi

if [ "x${thank_software_conclude}" = "x" ]; then
    str="We are very grateful to all their creators for freely "
    str="$str providing this necessary infrastructure. This research "
    str="$str (and many other projects) would not be possible without "
    str="$str them."
    thank_software_conclude="$str"
fi
