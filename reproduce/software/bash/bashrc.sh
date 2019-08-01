# Bash startup file for better control of project environment.
#
# To have better control over the environment of each analysis step (Make
# recipe), besides having environment variables (directly included from
# Make), it may also be useful to have a Bash startup file (this file). All
# of the Makefiles set this file as the `BASH_ENV' environment variable, so
# it is loaded into all the Make recipes within the project.
#
# The special `PROJECT_STATUS' environment variable is defined in every
# top-level Makefile of the project. It defines the the state of the Make
# that is calling this script. It can have three values:
#
#    configure_basic
#    ---------------
#       When doing basic configuration, therefore the executed steps cannot
#       make any assumptions about the version of Bash (or any other
#       program). Therefore it is important for any step in this step to be
#       highly portable.
#
#    configure_highlevel
#    -------------------
#       When building the higher-level programs, so the versions of the
#       most basic tools are set and you may safely assume certain
#       features.
#
#    make
#    ----
#       When doing the project's analysis: all software have known
#       versions.
#
#
# Copyright (C) 2019 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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
