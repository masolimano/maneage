#! /bin/sh
#
# Necessary preparations/configurations for the reproducible project.
#
# Copyright (C) 2018-2020 Mohammad Akhlaghi <mohammad@akhlaghi.org>
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


# Script settings
# ---------------
# Stop the script if there are any errors.
set -e





# Internal directories
# --------------------
#
# These are defined to help make this script more readable.
topdir=$(pwd)
optionaldir="/optional/path"
adir=reproduce/analysis/config
cdir=reproduce/software/config

pconf=$cdir/LOCAL.conf
ptconf=$cdir/LOCAL_tmp.conf
poconf=$cdir/LOCAL_old.conf
depverfile=$cdir/versions.conf
depshafile=$cdir/checksums.conf
# --------- Delete for no Gnuastro ---------
glconf=$adir/gnuastro/gnuastro-local.conf
# ------------------------------------------





# Notice for top of generated files
# ---------------------------------
#
# In case someone opens the files output from the configuration scripts in
# a text editor and wants to edit them, it is important to let them know
# that their changes are not going to be permenant.
create_file_with_notice ()
{
    if echo "# IMPORTANT: file can be RE-WRITTEN after './project configure'" > "$1"
    then
        echo "#"                                                      >> "$1"
        echo "# This file was created during configuration"           >> "$1"
        echo "# ('./project configure'). Therefore, it is not under"  >> "$1"
        echo "# version control and any manual changes to it will be" >> "$1"
        echo "# over-written if the project re-configured."           >> "$1"
        echo "#"                                                      >> "$1"
    else
        echo; echo "Can't write to $1"; echo;
        exit 1
    fi
}





# Get absolute address
# --------------------
#
# Since the build directory will go into a symbolic link, we want it to be
# an absolute address. With this function we can make sure of that.
absolute_dir ()
{
    if stat "$1" 1> /dev/null; then
        echo "$(cd "$(dirname "$1")" && pwd )/$(basename "$1")"
    else
        exit 1;
    fi
}





# Check for C/C++ compilers
# -------------------------
#
# To build the software, we'll need some basic tools (the compilers in
# particular) to be present.
hascc=0;
if type cc > /dev/null 2>/dev/null; then
    if type c++ > /dev/null 2>/dev/null; then export CC=cc; hascc=1; fi
else
    if type gcc > /dev/null 2>/dev/null; then
        if type g++ > /dev/null 2>/dev/null; then export CC=gcc; hascc=1; fi
    else
        if type clang > /dev/null 2>/dev/null; then
            if type clang++ > /dev/null 2>/dev/null; then export CC=clang; hascc=1; fi
        fi
    fi
fi
if [ $hascc = 0 ]; then
    cat <<EOF
______________________________________________________
!!!!!!!       C/C++ Compiler NOT FOUND         !!!!!!!

To build the project's software, the host system needs to have basic C and
C++ compilers. The executables that were checked are 'cc', 'gcc' and
'clang' for a C compiler, and 'c++', 'g++' and 'clang++' for a C++
compiler. If you have a relevant compiler that is not checked, please get
in touch with us (with the form below) so we add it:

  https://savannah.nongnu.org/support/?func=additem&group=reproduce
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
    exit 1
fi





# Special directory for compiler testing
# --------------------------------------
#
# This directory will be deleted when the compiler testing is finished.
compilertestdir=.compiler_test_dir_please_delete
if ! [ -d $compilertestdir ]; then mkdir $compilertestdir; fi





# Check C compiler
# ----------------
gcc_works=0
testprog=$compilertestdir/test
testsource=$compilertestdir/test.c
echo; echo; echo "Checking host C compiler...";
cat > $testsource <<EOF
#include <stdio.h>
#include <stdlib.h>
int main(void){printf("...C compiler works.\n");
               return EXIT_SUCCESS;}
EOF
if $CC $testsource -o$testprog && $testprog; then
    rm $testsource $testprog
else
    rm $testsource
    cat <<EOF

______________________________________________________
!!!!!!!        C compiler doesn't work         !!!!!!!

Host C compiler ('gcc') can't build a simple program.

A working C compiler is necessary for building the project's software.
Please use the error message above to find a good solution and re-run the
project configuration.

If you can't find a solution, please send the error message above to the
link below and we'll try to help

https://savannah.nongnu.org/support/?func=additem&group=reproduce

TIP: Once you find the solution, you can use the '-e' option to use
existing configuration:

   $ ./project configure -e

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
    exit 1
fi





# See if the linker accepts -Wl,-rpath-link
# -----------------------------------------
#
# `-rpath-link' is used to write the information of the linked shared
# library into the shared object (library or program). But some versions of
# LLVM's linker don't accept it an can cause problems.
cat > $testsource <<EOF
#include <stdio.h>
#include <stdlib.h>
int main(void) {return EXIT_SUCCESS;}
EOF
if $CC $testsource -o$testprog -Wl,-rpath-link 2>/dev/null > /dev/null; then
    export rpath_command="-Wl,-rpath-link=$instdir/lib"
else
    export rpath_command=""
fi
rm -f $testprog $testsource





# See if we need the dynamic-linker (-ldl)
# ----------------------------------------
#
# Some programs (like Wget) need dynamic loading (using `libdl'). On
# GNU/Linux systems, we'll need the `-ldl' flag to link such programs.  But
# Mac OS doesn't need any explicit linking. So we'll check here to see if
# it is present (thus necessary) or not.
cat > $testsource <<EOF
#include <stdio.h>
#include <dlfcn.h>
int
main(void) {
    void *handle=dlopen ("/lib/CEDD_LIB.so.6", RTLD_LAZY);
    return 0;
}
EOF
if $CC $testsource -o$testprog 2>/dev/null > /dev/null; then
    needs_ldl=no;
else
    needs_ldl=yes;
fi
rm -f $testprog $testsource





# See if the C compiler can build static libraries
# ------------------------------------------------

# We are manually only working with shared libraries: because some
# high-level programs like Wget and cURL need dynamic linking and if we
# build the libraries statically, our own builds will be ignored and these
# programs will go and find their necessary libraries on the host system.
#
# Another good advantage of shared libraries is that we can actually use
# the shared library tool of the system (`ldd' with GNU C Library) and see
# exactly where each linked library comes from. But in static building,
# unless you follow the build closely, its not easy to see if the source of
# the library came from the system or our build.
static_build=no





# If we are on a Mac OS system
# ----------------------------
#
# For the time being, we'll use the existance of `otool' to see if we are
# on a Mac OS system or not. Some tools (for example OpenSSL) need to know
# this.
#
# On Mac OS, the building of GCC crashes sometimes while building libiberty
# with CLang's `g++'. Until we find a solution, we'll just use the host's C
# compiler.
if type otool > /dev/null 2>/dev/null; then
    host_cc=1
    on_mac_os=yes
    cat <<EOF

______________________________________________________
!!!!!!!!!!!!!!!        Warning        !!!!!!!!!!!!!!!!

The GNU Compiler Collection (GCC, including compilers for C, C++, Fortran
and etc) is currently not built on macOS systems for this project. To build
the project's necessary software on this system, we need to use your
system's C compiler.

Project's configuration will continue in 5 seconds.
______________________________________________________

EOF
    sleep 5
else
    host_cc=0
    on_mac_os=no
fi





# Necessary C library element positions
# -------------------------------------
#
# On some systems (in particular Debian-based OSs), the static C library
# and necessary headers in a non-standard place, and we can't build GCC. So
# we need to find them first. The `sys/cdefs.h' header is also in a
# similarly different location.
sys_cpath=""
sys_library_path=""
if [ x"$$on_mac_os" != xyes ]; then

    # Get the GCC target name of the compiler, when its given, special
    # C libraries and headers are in a sub-directory of the host.
    gcctarget=$(gcc -v 2>&1 \
                    | tr ' ' '\n' \
                    | awk '/\-\-target/' \
                    | sed -e's/\-\-target=//')
    if [ x"$gcctarget" != x ]; then
        if [ -f /usr/lib/$gcctarget/libc.a ]; then
            export sys_library_path=/usr/lib/$gcctarget
            export sys_cpath=/usr/include/$gcctarget
        fi
    fi

    # For a check:
    #echo "sys_library_path: $sys_library_path"
    #echo "sys_cpath: $sys_cpath"
fi





# See if a link-able static C library exists
# ------------------------------------------
#
# A static C library and the `sys/cdefs.h' header are necessary for
# building GCC.
if [ x"$host_cc" = x0 ]; then
    echo; echo; echo "Checking if static C library is available...";
    cat > $testsource <<EOF
#include <stdio.h>
#include <stdlib.h>
#include <sys/cdefs.h>
int main(void){printf("...yes\n");
               return EXIT_SUCCESS;}
EOF
    cc_call="$CC $testsource $CPPFLAGS $LDFLAGS -o$testprog -static -lc"
    if $cc_call && $testprog; then
        gccwarning=0
        rm $testsource $testprog
    else
        echo; echo "Compilation command:"; echo "$cc_call"
        rm $testsource
        gccwarning=1
        host_cc=1
        cat <<EOF

_______________________________________________________
!!!!!!!!!!!!            Warning            !!!!!!!!!!!!

The 'sys/cdefs.h' header cannot be included, or a usable static C library
('libc.a', in any directory) cannot be used with the current settings of
this system. SEE THE ERROR MESSAGE ABOVE.

Because of this, we can't build GCC. You either 1) don't have them, or 2)
the default system environment aren't enough to find them.

1) If you don't have them, your operating system provides them as separate
packages that you must manually install. Please look into your operating
system documentation or contact someone familiar with it. For example on
some Redhat-based GNU/Linux distributions, the static C library package can
be installed with this command:

    $ sudo yum install glibc-static

2) If you have 'libc.a' and 'sys/cdefs.h', but in a non-standard location (for
example in '/PATH/TO/STATIC/LIBC/libc.a' and
'/PATH/TO/SYS/CDEFS_H/sys/cdefs.h'), please run the commands below, then
re-configure the project to fix this problem.

    $ export LDFLAGS="-L/PATH/TO/STATIC/LIBC \$LDFLAGS"
    $ export CPPFLAGS="-I/PATH/TO/SYS/CDEFS_H \$LDFLAGS"

_______________________________________________________

EOF
    fi
fi

# Print a warning if GCC is not meant to be built.
if [ x"$gccwarning" = x1 ]; then
        cat <<EOF

PLEASE SEE THE WARNINGS ABOVE.

Since GCC is pretty low-level, this configuration script will continue in 5
seconds and use your system's C compiler (it won't build a custom GCC). But
please consider installing the necessary package(s) to complete your C
compiler, then re-run './project configure'.

Project's configuration will continue in 5 seconds.

EOF
        sleep 5
fi





# Fortran compiler
# ----------------
#
# If GCC is ultimately build within the project, the user won't need to
# have a fortran compiler, we'll build it internally for high-level
# programs. However, when the host C compiler is to be used, the user needs
# to have a Fortran compiler available.
if [ $host_cc = 1 ]; then

    # See if a Fortran compiler exists.
    hasfc=0;
    if type gfortran > /dev/null 2>/dev/null; then hasfc=1; fi
    if [ $hasfc = 0 ]; then
        cat <<EOF
______________________________________________________
!!!!!!!      Fortran Compiler NOT FOUND        !!!!!!!

The project won't be building its own GCC (which includes a Fortran
compiler) on this system. If you need software that need a Fortran
compiler, it will crash with an error. Fortran is necessary for many
lower-level scientific programs, hence this warning. Currently we search
for 'gfortran'. If you have a Fortran compiler that is not checked, please
get in touch with us (with the form below) so we add it:

  https://savannah.nongnu.org/support/?func=additem&group=reproduce

Project's configuration will continue in 5 seconds.
______________________________________________________

EOF
        sleep 5
    else

        # See if the Fortran compiler works
        testsource=$compilertestdir/test.f
        echo; echo; echo "Checking host Fortran compiler...";
        echo "      PRINT *, \"... Fortran Compiler works.\""  > $testsource
        echo "      END"                                      >> $testsource
        if gfortran $testsource -o$testprog && $testprog; then
            rm $testsource $testprog
        else
            rm $testsource
            cat <<EOF

______________________________________________________
!!!!!!!     Fortran compiler doesn't work      !!!!!!!

Host Fortran compiler ('gfortran') can't build a simple program.

A working Fortran compiler is necessary for building some of the project's
software.  Please use the error message above to find a good solution and
re-run the project configuration.

If you can't find a solution, please send the error message above to the
link below and we'll try to help

https://savannah.nongnu.org/support/?func=additem&group=reproduce

TIP: Once you find the solution, you can use the '-e' option to use
existing configuration:

   $ ./project configure -e

Project's configuration will continue in 5 seconds.
______________________________________________________

EOF
            sleep 5
        fi
    fi
fi





# Delete the compiler testing directory
# -------------------------------------
#
# This directory was made above to make sure the necessary compilers can be
# run.
rm -rf $compilertestdir





# Inform the user
# ---------------
#
# Print some basic information so the user gets a feeling of what is going
# on and is prepared on what will happen next.
cat <<EOF

-----------------------------
Project's local configuration
-----------------------------

Local configuration includes things like top-level directories, or
processing steps. It is STRONGLY recommended to read the comments, and set
the best values for your system (where necessary).

EOF





# What to do with possibly existing configuration file
# ----------------------------------------------------
#
# `LOCAL.conf' is the top-most local configuration for the project. If it
# already exists when this script is run, we'll make a copy of it as backup
# (for example the user might have ran `./project configure' by mistake).
printnotice=yes
rewritepconfig=yes
rewritegconfig=yes
if [ -f $pconf ] || [ -f $glconf ]; then
    if [ $existing_conf = 1 ]; then
        printnotice=no
        if [ -f $pconf  ]; then rewritepconfig=no; fi
        if [ -f $glconf ]; then rewritegconfig=no; fi
    fi
fi




# Make sure the group permissions satisfy the previous configuration (if it
# exists and we don't want to re-write it).
if [ $rewritepconfig = no ]; then
    oldgroupname=$(awk '/GROUP-NAME/ {print $3; exit 0}' $pconf)
    if [ "x$oldgroupname" = "x$reproducible_paper_group_name" ]; then
        just_a_place_holder_to_avoid_not_equal_test=1;
    else
        echo "-----------------------------"
        echo "!!!!!!!!    ERROR    !!!!!!!!"
        echo "-----------------------------"
        if [ "x$oldgroupname" = x ]; then
            status="NOT configured for groups"
            confcommand="./project configure"
        else
            status="configured for '$oldgroupname' group"
            confcommand="./project configure --group=$oldgroupname"
        fi
        echo "Project was previously $status!"
        echo "Either enable re-write of this configuration file,"
        echo "or re-run this configuration like this:"
        echo
        echo "   $confcommand"; echo
        exit 1
    fi
fi





# Identify the downloader tool
# ----------------------------
#
# After this script finishes, we will have both Wget and cURL for
# downloading any necessary dataset during the processing. However, to
# complete the configuration, we may also need to download the source code
# of some necessary software packages (including the downloaders). So we
# need to check the host's available tool for downloading at this step.
if [ $rewritepconfig = yes ]; then
    if type wget > /dev/null 2>/dev/null; then
        name=$(which wget)

        # By default Wget keeps the remote file's timestamp, so we'll have
        # to disable it manually.
        downloader="$name --no-use-server-timestamps -O";
    elif type curl > /dev/null 2>/dev/null; then
        name=$(which curl)

        # - cURL doesn't keep the remote file's timestamp by default.
        # - With the `-L' option, we tell cURL to follow redirects.
        downloader="$name -L -o"
    else
        cat <<EOF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!         Warning        !!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Couldn't find GNU Wget, or cURL on this system. These programs are used for
downloading necessary programs and data if they aren't already present (in
directories that you can specify with this configure script). Therefore if
the necessary files are not present, the project will crash.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
        downloader="no-downloader-found"
    fi;
fi





# Build directory
# ---------------
if [ $rewritepconfig = yes ]; then
    cat <<EOF

===============
Build directory
===============

The project's "source" (this directory) and "build" directories are treated
separately. This greatly helps in managing the many intermediate files that
are created during the build. The intermediate build files don't need to be
archived or backed up: you can always re-build them with the contents of
the source directory. The build directory also needs a relatively large
amount of free space (atleast serveral Giga-bytes), while the source
directory (all plain text) will usually be a mega-byte or less.

'.build' (a symbolic link to the build directory) will also be created
during this configuration. It can help encourage you to set the actual
build directory in a very different address from this one (one that can be
deleted and has large volume), while having easy access to it from here.

--- CAUTION ---
Do not choose any directory under the top source directory (this
directory). The build directory cannot be a subdirectory of the source.
---------------

EOF
    bdir=
    currentdir=$(pwd)
    junkname=pure-junk-974adfkj38
    while [ x$bdir = x ]
    do
        # Ask the user (if not already set on the command-line).
        if [ x"$build_dir" = x ]; then
            read -p"Please enter the top build directory: " build_dir
        fi

        # If it exists, see if we can write in it. If not, try making it.
        if [ -d $build_dir ]; then
            if mkdir $build_dir/$junkname 2> /dev/null; then
                instring="the already existing"
                bdir=$(absolute_dir $build_dir)
                rm -rf $build_dir/$junkname
            else
                echo " -- Can't write in '$build_dir'"; echo
            fi
        else
            if mkdir $build_dir 2> /dev/null; then
                instring="the newly created"
                bdir=$(absolute_dir $build_dir)
            else
                echo " -- Can't create '$build_dir'"; echo
            fi
        fi

        # If its given, make sure it isn't a subdirectory of the source
        # directory.
        if ! [ x"$bdir" = x ]; then
            echo "Given build directory: $bdir"
            if echo "$bdir/" \
                    | grep '^'$currentdir 2> /dev/null > /dev/null; then

                # If it was newly created, it will be empty, so delete it.
                if ! [ "$(ls -A $bdir)" ]; then rm --dir $bdir; fi

                # Inform the user that this is not acceptable and reset `bdir'.
                bdir=
                echo " -- The build-directory cannot be under the source-directory."
                echo "    Please specify another build-directory that is outside of the source."
                echo ""
            else
                echo " -- Build directory set to ($instring): '$bdir'"
            fi
        fi

        # Reset `build_dir' to blank, so it continues asking when the
        # previous value wasn't usable.
        build_dir=
    done
fi





# Input directory
# ---------------
if [ x"$input_dir" = x ]; then
    indir=$optionaldir
else
    indir=$input_dir
fi
wfpc2name=$(awk '!/^#/ && $1=="WFPC2IMAGE" {print $3}' $adir/INPUTS.conf)
wfpc2md5=$(awk  '!/^#/ && $1=="WFPC2MD5"   {print $3}' $adir/INPUTS.conf)
wfpc2size=$(awk '!/^#/ && $1=="WFPC2SIZE"  {print $3}' $adir/INPUTS.conf)
wfpc2url=$(awk  '!/^#/ && $1=="WFPC2URL"   {print $3}' $adir/INPUTS.conf)
if [ $rewritepconfig = yes ] && [ x"$input_dir" = x ]; then
    cat <<EOF

----------------------------------
(OPTIONAL) Input dataset directory
----------------------------------

This project needs the dataset(s) listed below. If you already have them,
please specify the directory hosting them on this system. If you don't,
they will be downloaded automatically. Each file is shown with its total
volume and its 128-bit MD5 checksum in parenthesis.

  $wfpc2name ($wfpc2size, $wfpc2md5):
    A 100x100 Hubble Space Telescope WFPC II image used in the FITS
    standard webpage as a demonstration of this file format.
    URL: $wfpc2url/$wfpc2name

NOTE I: This directory, or the datasets above, are optional. If it doesn't
exist, the files will be downloaded in the build directory and used.

NOTE II: This directory (if given) will only be read, nothing will be
written into it, so no writing permissions are necessary.

TIP: If you have these files in multiple directories on your system and
don't want to download them or make duplicates, you can create symbolic
links to them and put those symbolic links in the given top-level
directory.

EOF
    read -p"(OPTIONAL) Input datasets directory ($indir): " inindir
    if [ x$inindir != x ]; then
        indir=$inindir
        echo " -- Using '$indir'"
    fi
fi





# Dependency tarball directory
# ----------------------------
if [ x"$software_dir" = x ]; then
    ddir=$optionaldir
else
    ddir=$software_dir
fi
if [ $rewritepconfig = yes ] && [ x"$software_dir" = x ]; then
    cat <<EOF

---------------------------------------
(OPTIONAL) Software tarball directory
---------------------------------------

To ensure an identical build environment, the project will use its own
build of the programs it needs. Therefore the tarball of the relevant
programs are necessary. If a tarball isn't present in the specified
directory, *IT WILL BE DOWNLOADED* automatically.

If you don't specify any directory here, or it doesn't contain the tarball
of a dependency, it is necessary to have an internet connection. The
project will download the tarballs it needs automatically.

EOF
    read -p"(OPTIONAL) Directory of dependency tarballs ($ddir): " tmpddir
    if [ x"$tmpddir" != x ]; then
        ddir=$tmpddir
        echo " -- Using '$ddir'"
    fi
fi





# Write the parameters into the local configuration file.
if [ $rewritepconfig = yes ]; then

    # Add commented notice.
    create_file_with_notice $pconf

    # Write the values.
    sed -e's|@bdir[@]|'"$bdir"'|' \
        -e's|@indir[@]|'"$indir"'|' \
        -e's|@ddir[@]|'"$ddir"'|' \
        -e's|@sys_cpath[@]|'"$sys_cpath"'|' \
        -e's|@downloader[@]|'"$downloader"'|' \
        -e's|@groupname[@]|'"$reproducible_paper_group_name"'|' \
        $pconf.in >> $pconf
else
    # Read the values from existing configuration file.
    inbdir=$(awk '$1=="BDIR" {print $3}' $pconf)

    # Read the software directory.
    ddir=$(awk '$1=="DEPENDENCIES-DIR" {print $3}' $pconf)

    # The downloader command may contain multiple elements, so we'll just
    # change the (in memory) first and second tokens to empty space and
    # write the full line (the original file is unchanged).
    downloader=$(awk '$1=="DOWNLOADER" {$1=""; $2=""; print $0}' $pconf)

    # Make sure all necessary variables have a value
    err=0
    verr=0
    novalue=""
    if [ x"$inbdir"     = x ]; then novalue="BDIR, ";              fi
    if [ x"$downloader" = x ]; then novalue="$novalue"DOWNLOADER;  fi
    if [ x"$novalue"   != x ]; then verr=1; err=1;                 fi

    # Make sure `bdir' is an absolute path and it exists.
    berr=0
    ierr=0
    bdir=$(absolute_dir $inbdir)

    if ! [ -d $bdir  ]; then if ! mkdir $bdir; then berr=1; err=1; fi; fi
    if [ $err = 1 ]; then
        cat <<EOF

#################################################################
########  ERORR reading existing configuration file  ############
#################################################################
EOF
        if [ $verr = 1 ]; then
            cat <<EOF

These variables have no value: $novalue.
EOF
        fi
        if [ $berr = 1 ]; then
           cat <<EOF

Couldn't create the build directory '$bdir' (value to 'BDIR') in
'$pconf'.
EOF
        fi

        cat <<EOF

Please run the configure script again (accepting to re-write existing
configuration file) so all the values can be filled and checked.
#################################################################
EOF
    fi
fi





# --------- Delete for no Gnuastro ---------
# Get the version of Gnuastro that must be used.
gversion=$(awk '$1=="gnuastro-version" {print $NF}' $depverfile)

# Gnuastro's local configuration settings
if [ $rewritegconfig = yes ]; then
    create_file_with_notice $glconf
    echo "# Minimum number of bytes to use HDD/SSD instead of RAM." >> $glconf
    echo " minmapsize $minmapsize"                                  >> $glconf
    echo                                                            >> $glconf
    echo "# Version of Gnuastro that must be used."                 >> $glconf
    echo " onlyversion $gversion"                                   >> $glconf
else
    ingversion=$(awk '$1=="onlyversion" {print $NF}' $glconf)
    if [ x$ingversion != x$gversion ]; then
           cat <<EOF
______________________________________________________
!!!!!!!!!!!!!!!!!!CONFIGURATION ERROR!!!!!!!!!!!!!!!!!

Gnuastro's version in '$glconf' ($ingversion) doesn't match the tarball
version that this project was designed to use in '$depverfile'
($gversion). Please re-run after removing the former file:

   $ rm $glconf
   $ ./project configure

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
        exit 1
    fi
fi
# ------------------------------------------





# Delete final configuration target
# ---------------------------------
#
# We only want to start running the project later if this script has
# completed successfully. To make sure it hasn't crashed in the middle
# (without the user noticing), in the end of this script we make a file and
# we'll delete it here (at the start). Therefore if the script crashed in
# the middle that file won't exist.
sdir=$bdir/software
finaltarget=$sdir/configuration-done.txt
if ! [ -d $sdir ];  then mkdir $sdir; fi
rm -f $finaltarget





# Project's top-level directories
# -------------------------------
#
# These directories are possibly needed by many steps of process, so to
# avoid too many directory dependencies throughout the software and
# analysis Makefiles (thus making them hard to read), we are just building
# them here
# Software tarballs
tardir=$sdir/tarballs
if ! [ -d $tardir ];  then mkdir $tardir; fi

# Installed software
instdir=$sdir/installed
if ! [ -d $instdir ]; then mkdir $instdir; fi

# To record software versions and citation.
verdir=$instdir/version-info
if ! [ -d $verdir ]; then mkdir $verdir; fi

# Program and library versions and citation.
ibidir=$verdir/proglib
if ! [ -d $ibidir ]; then mkdir $ibidir; fi

# Python module versions and citation.
ipydir=$verdir/python
if ! [ -d $ipydir ]; then mkdir $ipydir; fi

# Used software BibTeX entries.
ictdir=$verdir/cite
if ! [ -d $ictdir ]; then mkdir $ictdir; fi

# TeXLive versions.
itidir=$verdir/tex
if ! [ -d $itidir ]; then mkdir $itidir; fi

# Top-level LaTeX.
texdir=$bdir/tex
if ! [ -d $texdir ]; then mkdir $texdir; fi

# LaTeX macros.
mtexdir=$texdir/macros
if ! [ -d $mtexdir ]; then mkdir $mtexdir; fi


# TeX build directory. If built in a group scenario, the TeX build
# directory must be separate for each member (so they can work on their
# relevant parts of the paper without conflicting with each other).
if [ "x$reproducible_paper_group_name" = x ]; then
    texbdir=$texdir/build
else
    user=$(whoami)
    texbdir=$texdir/build-$user
fi
if ! [ -d $texbdir ]; then mkdir $texbdir; fi

# TiKZ (for building figures within LaTeX).
tikzdir=$texbdir/tikz
if ! [ -d $tikzdir ]; then mkdir $tikzdir; fi


# Set the symbolic links for easy access to the top project build
# directories. Note that these are put in each user's source/cloned
# directory, not in the build directory (which can be shared between many
# users and thus may already exist).
#
# Note: if we don't delete them first, it can happen that an extra link
# will be created in each directory that points to its parent. So to be
# safe, we are deleting all the links on each re-configure of the project.
rm -f .build .local tex/build tex/tikz .gnuastro
ln -s $bdir .build
ln -s $instdir .local
ln -s $texdir tex/build
ln -s $tikzdir tex/tikz
# --------- Delete for no Gnuastro ---------
ln -s $topdir/reproduce/software/config/gnuastro .gnuastro
# ------------------------------------------


# Temporary software un-packing/build directory: if the host has the
# standard `/dev/shm' mounting-point, we'll do it in shared memory (on the
# RAM), to avoid harming/over-using the HDDs/SSDs. The RAM of most systems
# today (>8GB) is large enough for the parallel building of the software.
#
# For the name of the directory under `/dev/shm' (for this project), we'll
# use the names of the two parent directories to the current/running
# directory, separated by a `-' instead of `/'. We'll then appended that
# with the user's name (in case multiple users may be working on similar
# project names). Maybe later, we can use something like `mktemp' to add
# random characters to this name and make it unique to every run (even for
# a single user).
tmpblddir=$sdir/build-tmp
rm -rf $tmpblddir/* $tmpblddir  # If its a link, we need to empty its
                                # contents first, then itself.

# Set the top-level shared memory location.
if [ -d /dev/shm ]; then     shmdir=/dev/shm
else                         shmdir=""
fi

# If a shared memory mounted directory exists and there is enough space
# there (in RAM), build a temporary directory for this project.
needed_space=2000000
if [ x"$shmdir" != x ]; then
    available_space=$(df $shmdir | awk 'NR==2{print $4}')
    if [ $available_space -gt $needed_space ]; then
        dirname=$(pwd | sed -e's/\// /g' \
                      | awk '{l=NF-1; printf("%s-%s",$l, $NF)}')
        tbshmdir=$shmdir/"$dirname"-$(whoami)
        if ! [ -d $tbshmdir ]; then mkdir $tbshmdir; fi
    fi
else
    tbshmdir=""
fi

# If a shared memory directory was created set `build-tmp' to be a
# symbolic link to it. Otherwise, just build the temporary build
# directory under the project build directory.
if [ x$tbshmdir = x ]; then mkdir $tmpblddir;
else                        ln -s $tbshmdir $tmpblddir;
fi





# Inform the user that the build process is starting
# -------------------------------------------------
if [ $printnotice = yes ]; then
    tsec=10
    cat <<EOF

-------------------------
Building dependencies ...
-------------------------

Necessary dependency programs and libraries will be built in $tsec sec.

NOTE: the built software will NOT BE INSTALLED on your system (no root
access is required). They are only for local usage by this project. They
will be installed in:

  $sdir/installed

**TIP**: you can see which software is being installed at every moment with
the following command. See "Inspecting status" section of
'README-hacking.md' for more. In short, run it while the project is being
configured (in another terminal, but on this same directory: 'pwd'):

  $ ./project --check-config

Project's configuration will continue in $tsec seconds.

-------------------------

EOF
    sleep $tsec
fi





# Number of threads for basic builds
# ----------------------------------
#
# Since the system might not have GNU Make at this stage, and other Make
# implementations can't deal with parallel build properly, we'll just
# default to 1 thread. This is because some versions of Make complain about
# not having enough 'pipe' (memory) on some systems. After some searching,
# I found out its because of too many threads. GNU Make will be present on
# GNU systems (that have `nproc', part of GNU Coreutils). So to simplify
# the test for GNU Make, we'll just try running `nproc'.
if which nproc &> /dev/null; then
    if [ $jobs = 0 ]; then
        numthreads=$(nproc --all);
    else
        numthreads=$jobs
    fi
else
    numthreads=1;
fi





# Build `flock' before other program
# ----------------------------------
#
# Flock (or file-lock) is a unique program that is necessary to serialize
# the (generally parallel) processing of make when necessary. GNU/Linux
# machines have it as part of their `util-linux' programs. But to be
# consistent in non-GNU/Linux systems, we will be using our own build.
#
# The reason that `flock' is sepecial is that we need it to serialize the
# download process of the software tarballs.
flockversion=$(awk '/flock-version/{print $3}' $depverfile)
flockchecksum=$(awk '/flock-checksum/{print $3}' $depshafile)
flocktar=flock-$flockversion.tar.gz
flockurl=http://github.com/discoteq/flock/releases/download/v$flockversion/

# Prepare/download the tarball.
if ! [ -f $tardir/$flocktar ]; then
    flocktarname=$tardir/$flocktar
    ucname=$flocktarname.unchecked
    if [ -f $ddir/$flocktar ]; then
        cp $ddir/$flocktar $ucname
    else
        if ! $downloader $ucname $flockurl/$flocktar; then
            rm -f $ucname;
            echo
            echo "DOWNLOAD ERROR: Couldn't download the 'flock' tarball:"
            echo "  $flockurl"
            echo
            echo "You can manually place it in '$ddir' to avoid downloading."
            exit 1
        fi
    fi

    # Make sure this is the correct tarball.
    if type sha512sum > /dev/null 2>/dev/null; then
        checksum=$(sha512sum "$ucname" | awk '{print $1}')
        if [ x$checksum = x$flockchecksum ]; then mv "$ucname" "$flocktarname"
        else echo "ERROR: Non-matching checksum for '$flocktar'."; exit 1
        fi;
    else mv "$ucname" "$flocktarname"
    fi
fi

# If the tarball is newer than the (possibly existing) program (the version
# has changed), then delete the program.
if [ -f .local/bin/flock ]; then
    if [ $tardir/$flocktar -nt $ibidir/flock ]; then
        rm $ibidir/flock
    fi
fi

# Build `flock' if necessary.
if ! [ -f $ibidir/flock ]; then
    cd $tmpblddir
    tar xf $tardir/$flocktar
    cd flock-$flockversion
    ./configure --prefix=$instdir
    make
    make install
    cd $topdir
    rm -rf $tmpblddir/flock-$flockversion
    echo "Discoteq flock $flockversion" > $ibidir/flock
fi





# Paths needed by the host compiler (only for `basic.mk')
# -------------------------------------------------------
#
# At the end of the basic build, we need to build GCC. But GCC will build
# in multiple phases, making its own simple compiler in order to build
# itself completely. The intermediate/simple compiler doesn't recognize
# some system specific locations like `/usr/lib/ARCHITECTURE' that some
# operating systems use. We thus need to tell the intermediate compiler
# where its necessary libraries and headers are.
if [ x"$sys_library_path" != x ]; then
    if [ x"$LIBRARY_PATH" = x ]; then
        export LIBRARY_PATH="$sys_library_path"
    else
        export LIBRARY_PATH="$LIBRARY_PATH:$sys_library_path"
    fi
    if [ x"$CPATH" = x ]; then
        export CPATH="$sys_cpath"
    else
        export CPATH="$CPATH:$sys_cpath"
    fi
fi





# Build basic software
# --------------------
#
# When building these software we don't have our own un-packing software,
# Bash, Make, or AWK. In this step, we'll install such low-level basic
# tools, but we have to be very portable (and use minimal features in all).
echo; echo "Building necessary software (if necessary)..."
make -k -f reproduce/software/make/basic.mk \
     sys_library_path=$sys_library_path \
     rpath_command=$rpath_command \
     static_build=$static_build \
     numthreads=$numthreads \
     needs_ldl=$needs_ldl \
     on_mac_os=$on_mac_os \
     host_cc=$host_cc \
     -j$numthreads





# All other software
# ------------------
#
# We will be making all the dependencies before running the top-level
# Makefile. To make the job easier, we'll do it in a Makefile, not a
# script. Bash and Make were the tools we need to run Makefiles, so we had
# to build them in this script. But after this, we can rely on Makefiles.
if [ $jobs = 0 ]; then
    numthreads=$($instdir/bin/nproc --all)
else
    numthreads=$jobs
fi
.local/bin/env -i HOME=$bdir \
    .local/bin/make -k -f reproduce/software/make/high-level.mk \
                    sys_library_path=$sys_library_path \
                    rpath_command=$rpath_command \
                    static_build=$static_build \
                    numthreads=$numthreads \
                    on_mac_os=$on_mac_os \
                    sys_cpath=$sys_cpath \
                    host_cc=$host_cc \
                    -j$numthreads





# Make sure TeX Live installed successfully
# -----------------------------------------
#
# TeX Live is managed over the internet, so if there isn't any, or it
# suddenly gets cut, it can't be built. However, when TeX Live isn't
# installed, the project can do all its processing independent of it. It
# will just stop at the stage when all the processing is complete and it is
# only necessary to build the PDF.  So we don't want to stop the project's
# configuration and building if its not present.
if [ -f $itidir/texlive-ready-tlmgr ]; then
    texlive_result=$(cat $itidir/texlive-ready-tlmgr)
else
    texlive_result="NOT!"
fi
if [ x"$texlive_result" = x"NOT!" ]; then
    cat <<EOF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!         Warning        !!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TeX Live couldn't be installed during the configuration (probably because
there were downloading problems). TeX Live is only necessary in making the
final PDF (which is only done after all the analysis has been complete). It
is not used at all during the analysis.

Therefore, if you don't need the final PDF, and just want to do the
analysis, you can safely ignore this warning and continue.

If you later have internet access and would like to add TeX live to your
project, please delete the respective files, then re-run configure as shown
below. Within configure, answer 'n' (for "no") when asked to re-write the
configuration files.

    rm .local/version-info/tex/texlive-ready-tlmgr
    ./project configure

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
fi





# Citation of installed software
#
# After everything is installed, we'll put all the names and versions in a
# human-readable paragraph and also prepare the BibTeX citation for the
# software.
prepare_name_version ()
{
    # First see if the (possible) `*' in the input arguments corresponds to
    # anything. Note that some of the given directories may be empty (no
    # software installed).
    hasfiles=0
    for f in $@; do
        if [ -f $f ]; then hasfiles=1; break; fi;
    done

    # If there are any files, merge all the names in a paragraph.
    if [ $hasfiles = 1 ]; then

        # Count how many names there are. This is necessary to identify the
        # last element.
        num=$(.local/bin/cat $@ \
                  | .local/bin/sed '/^\s*$/d' \
                  | .local/bin/wc -l)

        # Put them all in one paragraph, while sorting them, commenting any
        # possible underscores and removing blank lines.
        .local/bin/cat $@ \
            | .local/bin/sort \
            | .local/bin/sed -e's|_|\\_|' \
            | .local/bin/awk 'NF>0 { \
                  c++; \
                  if(c==1) \
                    { \
                      if('$num'==1) printf("%s", $0); \
                      else          printf("%s", $0); \
                    } \
                  else if(c=='$num') printf(" and %s\n", $0); \
                  else printf(", %s", $0) \
                }'
    fi
}

# Report the different software in separate contexts (separating Python and
# TeX packages from the C/C++ programs and libraries).
proglibs=$(prepare_name_version $verdir/proglib/*)
pymodules=$(prepare_name_version $verdir/python/*)
texpkg=$(prepare_name_version $verdir/tex/texlive)

# Write them as one paragraph for LaTeX.
pkgver=$mtexdir/dependencies.tex
.local/bin/echo "This research was done with the following free" > $pkgver
.local/bin/echo "software programs and libraries: $proglibs."   >> $pkgver
if [ x"$pymodules" != x ]; then
    .local/bin/echo "Within Python, the following modules"      >> $pkgver
    echo "were used: $pymodules."                               >> $pkgver
fi
.local/bin/echo "The \LaTeX{} source of the paper was compiled" >> $pkgver
.local/bin/echo "to make the PDF using the following packages:" >> $pkgver
.local/bin/echo "$texpkg. We are very grateful to all their"    >> $pkgver
.local/bin/echo "creators for freely providing this necessary"  >> $pkgver
.local/bin/echo "infrastructure. This research (and many "      >> $pkgver
.local/bin/echo "others) would not be possible without them."   >> $pkgver

# Prepare the BibTeX entries for the used software (if there are any).
hasentry=0
bibfiles="$ictdir/*"
for f in $bibfiles; do if [ -f $f ]; then hasentry=1; break; fi; done;

# Make sure we start with an empty output file.
pkgbib=$mtexdir/dependencies-bib.tex
echo "" > $pkgbib

# Fill it in with all the BibTeX entries in this directory. We'll just
# avoid writing any comments (usually copyright notices) and also put an
# empty line after each file's contents to make the output more readable.
if [ $hasentry = 1 ]; then
    for f in $bibfiles; do
        awk '!/^%/{print} END{print ""}' $f >> $pkgbib
    done
fi





# Clean the temporary build directory
# ---------------------------------
#
# By the time the script reaches here the temporary software build
# directory should be empty, so just delete it. Note `tmpblddir' may be a
# symbolic link to shared memory. So, to work in any scenario, first delete
# the contents of the directory (if it has any), then delete `tmpblddir'.
.local/bin/rm -rf $tmpblddir/* $tmpblddir





# Register successful completion
# ------------------------------
echo `.local/bin/date` > $finaltarget






# Final notice
# ------------
#
# The configuration is now complete, we can inform the user on the next
# step(s) to take.
if [ x$reproducible_paper_group_name = x ]; then
    buildcommand="./project make -j8"
else
    buildcommand="./project make --group=$reproducible_paper_group_name -j8"
fi
cat <<EOF

----------------
The project and its environment are configured with no errors.

Please run the following command to start.
(Replace '8' with the number of CPU threads on your system)

    $buildcommand

To change the configuration later, please re-run './project configure', DO
NOT manually edit the relevant files.

EOF
