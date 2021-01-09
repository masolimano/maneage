#!/bin/sh
#
# Necessary preparations/configurations for the reproducible project.
#
# Copyright (C) 2018-2021 Mohammad Akhlaghi <mohammad@akhlaghi.org>
#
# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script.  If not, see <http://www.gnu.org/licenses/>.





# Script settings
# ---------------
# Stop the script if there are any errors.
set -e





# Project-specific settings
# -------------------------
#
# The variables defined here may be different between different
# projects. Ideally, they should be detected automatically, but we haven't
# had the chance to implement it yet (please help if you can!). Until then,
# please set them based on your project (if they differ from the core
# branch).
need_gfortran=0





# Internal source directories
# ---------------------------
#
# These are defined to help make this script more readable.
topdir="$(pwd)"
optionaldir="/optional/path"
adir=reproduce/analysis/config
cdir=reproduce/software/config

pconf=$cdir/LOCAL.conf
ptconf=$cdir/LOCAL_tmp.conf
poconf=$cdir/LOCAL_old.conf
depverfile=$cdir/versions.conf
depshafile=$cdir/checksums.conf





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
    address="$1"
    if stat "$address" 1> /dev/null; then
        echo "$(cd "$(dirname "$1")" && pwd )/$(basename "$1")"
    else
        exit 1;
    fi
}





# Check file permission handling (POSIX-compatibility)
# ----------------------------------------------------
#
# Check if a `given' directory handles permissions as expected.
#
# This is to prevent a known bug in the NTFS filesystem that prevents
# proper installation of Perl, and probably some other packages. This
# function receives the directory as an argument and then, creates a dummy
# file, and examines whether the given directory handles the file
# permissions as expected.
#
# Returns `0' if everything is fine, and `255' otherwise. Choosing `0' is
# to mimic the `$ echo $?' behavior, while choosing `255' is to prevent
# misunderstanding 0 and 1 as true and false.
#
# ===== CAUTION! ===== #
#
# Since there is a `set -e' before running this function, the whole script
# stops and exits IF the `check_permission' (or any other function) returns
# anything OTHER than `0'! So, only use this function as a test. Here's a
# minimal example:
#
#     if $(check_permission $some_directory) ; then
#       echo "yay"; else "nay";
#     fi ;
check_permission ()
{
    # Make a `junk' file, activate its executable flag and record its
    # permissions generally.
    local junkfile="$1"/check_permission_tmp_file
    rm -f "$junkfile"
    echo "Don't let my short life go to waste" > "$junkfile"
    chmod +x "$junkfile"
    local perm_before=$(ls -l "$junkfile" | awk '{print $1}')

    # Now, remove the executable flag and record the permissions.
    chmod -x "$junkfile"
    local perm_after=$(ls -l "$junkfile" | awk '{print $1}')

    # Clean up before leaving the function
    rm -f "$junkfile"

    # If the permissions are equal, the filesystem doesn't allow
    # permissions.
    if [ $perm_before = $perm_after ]; then
        # Setting permission FAILED
        return 1
    else
        # Setting permission SUCCESSFUL
	return 0
    fi
}





# Check if there is enough free space available in the build directory
# --------------------------------------------------------------------
#
# Use this function to check if there is enough free space in a
# directory. It is meant to be passed to the 'if' statement in the
# shell. So if there is enough space, it returns 0 (which translates to
# TRUE), otherwise, the funcion returns 1 (which translates to FALSE).
#
# Expects to be called with two arguments, the first is the threshold and
# the second is the desired directory. The 'df' function checks the given
# path to see where it is mounted on, and how much free space there is on
# that partition (in units of 1024 bytes).
#
# synopsis:
# $ free_space_warning <acceptable_threshold> <path-to-check>
#
# example:
# To check if there is 5MB of space available in /path/to/check
# call the command with arguments as shown below:
# $ free_space_warning 5000 /path/to/check/free/space
free_space_warning()
{
    fs_threshold=$1
    fs_destpath="$2"
    return $(df "$fs_destpath" \
                | awk 'FNR==2 {if($4>'$fs_threshold') print 1; \
                               else                   print 0; }')
}





# See if we are on a Linux-based system
# --------------------------------------
#
# Some features are tailored to GNU/Linux systems, while the BSD-based
# behavior is different. Initially we only tested macOS (hence the name of
# the variable), but as FreeBSD is also being inlucded in our tests. As
# more systems get used, we need to tailor these kinds of things better.
kernelname=$(uname -s)
if [ x$kernelname = xLinux ]; then
    on_mac_os=no

    # Don't forget to add the respective C++ compiler below (leave 'cc' in
    # the end).
    c_compiler_list="gcc clang cc"
elif [ x$kernelname = xDarwin ]; then
    host_cc=1
    on_mac_os=yes

    # Don't forget to add the respective C++ compiler below (leave 'cc' in
    # the end).
    c_compiler_list="clang gcc cc"
else
    on_mac_os=no
    cat <<EOF
______________________________________________________
!!!!!!!                 WARNING                !!!!!!!

Maneage has been tested on GNU/Linux and Darwin (macOS) systems. But, it
seems that the current system is not GNU/Linux or Darwin (macOS). If you
notice any problem during the configure phase, please contact us with this
web-form:

    https://savannah.nongnu.org/support/?func=additem&group=reproduce

The configuration will continue in 10 seconds...
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
    sleep 10
fi





# Collect CPU information
# -----------------------
#
# When the project is built, the type of a machine that built it also has
# to to be documented. This way, if different results or behaviors are
# observed in software-related or analysis-related phases of the project,
# it would be easier to track down the root cause. So far this is just
# later recorded as a LaTeX macro to be put in the final paper, but it
# could be used in a more systematic way to optimize/revise project
# workflow and build.
hw_class=$(uname -m)
if [ x$kernelname = xLinux ]; then
    byte_order=$(lscpu \
                     | grep 'Byte Order' \
                     | awk '{ \
                             for(i=3;i<NF;++i) \
                             printf "%s ", $i; \
                             printf "%s", $NF}')
    address_sizes=$(lscpu \
                     | grep 'Address sizes' \
                     | awk '{ \
                             for(i=3;i<NF;++i) \
                             printf "%s ", $i; \
                             printf "%s", $NF}')
elif [ x$on_mac_os = xyes ]; then
    hw_byteorder=$(sysctl -n hw.byteorder)
    if   [ x$hw_byteorder = x1234 ]; then byte_order="Little Endian";
    elif [ x$hw_byteorder = x4321 ]; then byte_order="Big Endian";
    fi
    address_size_physical=$(sysctl -n machdep.cpu.address_bits.physical)
    address_size_virtual=$(sysctl -n machdep.cpu.address_bits.virtual)
    address_sizes="$address_size_physical bits physical, "
    address_sizes+="$address_size_virtual bits virtual"
else
    byte_order="unrecognized"
    address_sizes="unrecognized"
    cat <<EOF
______________________________________________________
!!!!!!!                 WARNING                !!!!!!!

Machine byte order and address sizes could not be recognized. You can add
the necessary steps in the 'reproduce/software/shell/configure.sh' script
(just above this error message), or contact us with this web-form:

    https://savannah.nongnu.org/support/?func=additem&group=reproduce

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
    sleep 5
fi





# Check for Xcode in macOS systems
# --------------------------------
#
# When trying to build Maneage on macOS systems, there are some problems
# related with the Xcode and Command Line Tools. As a consequnce, in order to
# avoid these error it is highly recommended to install Xcode in the host
# system.  Here, it is checked that this is the case, and if not, warn the user
# about not having Xcode already installed.
if [ x$on_mac_os = xyes ]; then
  xcode=$(which xcodebuild)
  if [ x$xcode != x ]; then
    xcode_version=$(xcodebuild -version | grep Xcode)
    echo "                                              "
    echo "$xcode_version already installed in the system"
    echo "                                              "
  else
    cat <<EOF
______________________________________________________
!!!!!!!                 WARNING                !!!!!!!

Maneage has been tested Darwin (macOS) systems with host Xcode
installation.  However, Xcode cannot be found in this system. As a
consequence, the configure step may fail at some point. If this is the
case, please install Xcode and try to run again the configure step. If the
problem still persist after installing Xcode, please contact us with this
web-form:

    https://savannah.nongnu.org/support/?func=additem&group=reproduce

The configuration will continue in 5 seconds ...
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
    sleep 5
  fi
fi





# Check for C/C++ compilers
# -------------------------
#
# To build the software, we'll need some basic tools (the C/C++ compilers
# in particular) to be present.
has_compilers=no
for c in $c_compiler_list; do

    # Set the respective C++ compiler.
    if   [ x$c = xcc    ]; then cplus=c++;
    elif [ x$c = xgcc   ]; then cplus=g++;
    elif [ x$c = xclang ]; then cplus=clang++;
    else
        cat <<EOF
______________________________________________________
!!!!!!!                   BUG                  !!!!!!!

The respective C++ compiler executable name for the C compiler '$c' hasn't
been set! You can add it in the 'reproduce/software/shell/configure.sh'
script (just above this error message), or contact us with this web-form:

    https://savannah.nongnu.org/support/?func=additem&group=reproduce

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
        exit 1
    fi

    # Check if they exist.
    if type $c > /dev/null 2>/dev/null; then
        export CC=$c;
        if type $cplus > /dev/null 2>/dev/null; then
            export CXX=$cplus
            has_compilers=yes
            break
        fi
    fi
done
if [ x$has_compilers = xno ]; then
    cat <<EOF
______________________________________________________
!!!!!!!       C/C++ Compiler NOT FOUND         !!!!!!!

To build this project's software, the host system needs to have both C and
C++ compilers. The commands that were checked are listed below:

    cc, c++            Generic C/C++ compiler (possibly links to below).
    gcc, g++           Part of GNU Compiler Collection (GCC).
    clang, clang++     Part of LLVM compiler infrastructure.

If your compiler is not checked, please get in touch with the web-form
below, so we add it. We will try our best to add it soon. Until then,
please install at least one of these compilers on your system to proceed.

    https://savannah.nongnu.org/support/?func=additem&group=reproduce

NOTE: for macOS systems, the LLVM compilers that are provided in a native
Xcode install are recommended. There are known problems with GCC on macOS.

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
testprog=$compilertestdir/test
testsource=$compilertestdir/test.c
echo; echo; echo "Checking host C compiler ('$CC')...";
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

Host C compiler ('$CC') can't build a simple program.

A working C compiler is necessary for building the project's software.
Please use the error message above to find a good solution and re-run the
project configuration.

If you can't find a solution, please send the error message above to the
link below and we'll try to help

https://savannah.nongnu.org/support/?func=additem&group=reproduce

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
    exit 1
fi





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






# See if the C compiler can build static libraries
# ------------------------------------------------
#
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





# Print warning if the host CC is to be used.
if [ x$host_cc = x1 ]; then
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
# have a fortran compiler: we'll build it internally for high-level
# programs with GCC. However, when the host C compiler is to be used, the
# user needs to have a Fortran compiler available.
if [ $host_cc = 1 ]; then

    # If a Fortran compiler is necessary, see if 'gfortran' exists and can
    # be used.
    if [ "x$need_gfortran" = "x1" ]; then

        # First, see if 'gfortran' exists.
        hasfc=0;
        if type gfortran > /dev/null 2>/dev/null; then hasfc=1; fi
        if [ $hasfc = 0 ]; then
            cat <<EOF
______________________________________________________
!!!!!!!      Fortran Compiler NOT FOUND        !!!!!!!

This project requires a Fortran compiler. However, the project won't/can't
build its own GCC on this system (GCC also builds the 'gfortran' Fortran
compiler). Please install 'gfortran' using your operating system's package
manager, then re-run this configure script to continue the configuration.

Currently the only Fortran compiler we check is 'gfortran'. If you have a
Fortran compiler that is not checked, please get in touch with us (with the
form below) so we add it:

  https://savannah.nongnu.org/support/?func=additem&group=reproduce
______________________________________________________

EOF
            exit 1
        fi

        # Then, see if the Fortran compiler works
        testsourcef=$compilertestdir/test.f
        echo; echo; echo "Checking host Fortran compiler...";
        echo "      PRINT *, \"... Fortran Compiler works.\""  > $testsourcef
        echo "      END"                                      >> $testsourcef
        if gfortran $testsourcef -o$testprog && $testprog; then
            rm $testsourcef $testprog
        else
            rm $testsourcef
            cat <<EOF

______________________________________________________
!!!!!!!     Fortran compiler doesn't work      !!!!!!!

Host Fortran compiler ('gfortran') can't build a simple program.

A working Fortran compiler is necessary for this project. Please use the
error message above to find a good solution in your operating system and
re-run the project configuration.

If you can't find a solution, please send the error message above to the
link below and we'll try to help

https://savannah.nongnu.org/support/?func=additem&group=reproduce
______________________________________________________

EOF
            exit 1
        fi
    fi
fi





# Inform the user
# ---------------
#
# Print some basic information so the user gets a feeling of what is going
# on and is prepared on what will happen next.
cat <<EOF

-----------------------------
Project's local configuration
-----------------------------

Below, some basic local settings will be requested to start building
Maneage on this system (if they haven't been specified on the
command-line). This includes the top-level directories that Maneage will
use on your system. Most are only optional and you can simply press ENTER,
without giving any value (in this case, Maneage will download the necessary
components from pre-defined webpages). It is STRONGLY recommended to read
the description above each question before answering it.

EOF





# What to do with possibly existing configuration file
# ----------------------------------------------------
#
# `LOCAL.conf' is the top-most local configuration for the project. If it
# already exists when this script is run, we'll make a copy of it as backup
# (for example the user might have ran `./project configure' by mistake).
printnotice=yes
rewritepconfig=yes
if [ -f $pconf ]; then
    if [ $existing_conf = 1 ]; then
        printnotice=no
        if [ -f $pconf  ]; then rewritepconfig=no; fi
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
currentdir="$(pwd)"
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
    junkname=pure-junk-974adfkj38
    while [ x"$bdir" = x ]
    do
        # Ask the user (if not already set on the command-line).
        if [ x"$build_dir" = x ]; then
            if read -p"Please enter the top build directory: " build_dir; then
                just_a_place_holder_to_avoid_not_equal_test=1;
            else
                echo "ERROR: shell is in non-interactive-mode and no build directory specified."
                echo "The build directory (described above) is mandatory, configuration can't continue."
                echo "Please use '--build-dir' to specify a build directory non-interactively."
                exit 1
            fi
        fi

        # If it exists, see if we can write in it. If not, try making it.
        if [ -d "$build_dir" ]; then
            if echo "test" > "$build_dir"/$junkname ; then
                rm -f "$build_dir"/$junkname
                instring="the already existing"
                bdir="$(absolute_dir "$build_dir")"
            else
                echo " ** Can't write in '$build_dir'";
            fi
        else
            if mkdir "$build_dir" 2> /dev/null; then
                instring="the newly created"
                bdir="$(absolute_dir "$build_dir")"
            else
                echo " ** Can't create '$build_dir'";
            fi
        fi

        # If it is given, make sure it isn't a subdirectory of the source
        # directory.
        if ! [ x"$bdir" = x ]; then
            if echo "$bdir/" \
                    | grep '^'"$currentdir" 2> /dev/null > /dev/null; then

                # If it was newly created, it will be empty, so delete it.
                if ! [ "$(ls -A $bdir)" ]; then rm --dir "$bdir"; fi

                # Inform the user that this is not acceptable and reset `bdir'.
                bdir=
                echo " ** The build-directory cannot be under the source-directory."
            fi
        fi

        # If things are fine so far, make sure it does not contain a space
        # or other meta-characters which can cause problems during software
        # building.
        if ! [ x"$bdir" = x ]; then
            hasmeta=0;
            case $bdir in *['!'\@\#\$\%\^\&\*\(\)\+\;\ ]* ) hasmeta=1 ;; esac
            if [ $hasmeta = 1 ]; then

                # If it was newly created, it will be empty, so delete it.
                if ! [ "$(ls -A "$bdir")" ]; then rm --dir "$bdir"; fi

                # Inform the user and set 'bdir' to empty again.
                bdir=
                echo " ** Build directory should not contain meta-characters"
                echo " ** (like SPACE, %, \$, !, ;, or parenthesis, among "
                echo " ** others): they can interrup the build for some software."
            fi
        fi

	# If everything is still fine so far, see if we're able to
	# manipulate file permissions in the directory's filesystem and if
	# so, see if there is atleast 5GB free space.
	if ! [ x"$bdir" = x ]; then
            if ! $(check_permission "$bdir"); then
                # Unable to handle permissions well
                bdir=
                echo " ** File permissions can't be modified in this directory"
            else
                # Able to handle permissions, now check for 5GB free space
                # in the given partition (note that the number is in units
                # of 1024 bytes). If this is not the case, print a warning.
                if $(free_space_warning 5000000 "$bdir"); then
                    echo " !! LESS THAN 5GB FREE SPACE IN: $bdir"
                    echo " !! We recommend choosing another partition."
                    echo " !! Build will continue in 5 seconds..."
                    sleep 5
                fi
            fi
        fi

        # If the build directory was good, the loop will stop, if not,
        # reset `build_dir' to blank, so it continues asking for another
        # directory and let the user know that they must select a new
        # directory.
        if [ x"$bdir" = x ]; then
            build_dir=
            echo " ** Please select another directory."
            echo ""
        else
            echo " -- Build directory set to ($instring): '$bdir'"
        fi
    done
fi





# Input directory
# ---------------
if [ x"$input_dir" = x ]; then
    indir="$optionaldir"
else
    indir="$input_dir"
fi
noninteractive_sleep=2
if [ $rewritepconfig = yes ] && [ x"$input_dir" = x ]; then
    cat <<EOF

----------------------------------
(OPTIONAL) Input dataset directory
----------------------------------

This project needs the dataset(s) listed in the following file:

      reproduce/analysis/config/INPUTS.conf

If you already have a copy of them on this system, please specify the
directory hosting them on this system. If they aren't present, they will be
downloaded automatically when necessary.

NOTE I: This directory is optional. If not given, or if the files can't be
found inside it, any necessary file will be downloaded directly in the
build directory and used.

NOTE II: If a directory is given, it will be used as read-only. Nothing
will be written into it, so no writing permissions are necessary.

TIP: If you have these files in multiple directories on your system and
don't want to make duplicates, you can create symbolic links to them and
put those symbolic links in the given top-level directory.

EOF
    # Read the input directory if interactive mode is enabled.
    if read -p"(OPTIONAL) Input datasets directory ($indir): " inindir; then
        just_a_place_holder_to_avoid_not_equal_test=1;
    else
        echo "WARNING: interactive-mode seems to be disabled!"
        echo "If you have a local copy of the inputs, use '--input-dir'."
        echo "... project configuration will continue in $noninteractive_sleep sec ..."
        sleep $noninteractive_sleep
    fi

    # In case an input-directory is given, write it in 'indir'.
    if [ x$inindir != x ]; then
        indir="$(absolute_dir "$inindir")"
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
programs are necessary.

If you don't specify any directory here, or it doesn't contain the tarball
of a dependency, it is necessary to have an internet connection because the
project will download the tarballs it needs automatically.

EOF
    # Read the software directory if interactive mode is enabled.
    if read -p"(OPTIONAL) Directory of dependency tarballs ($ddir): " tmpddir; then
        just_a_place_holder_to_avoid_not_equal_test=1;
    else
        echo "WARNING: interactive-mode seems to be disabled!"
        echo "If you have a local copy of the software source, use '--software-dir'."
        echo "... project configuration will continue in $noninteractive_sleep sec ..."
        sleep $noninteractive_sleep
    fi

    # If given, write the software directory.
    if [ x"$tmpddir" != x ]; then
        ddir="$(absolute_dir "$tmpddir")"
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
    # Read the values from existing configuration file. Note that the build
    # directory may have space characters. Even though we currently check
    # against it, we hope to be able to remove this condition in the
    # future.
    inbdir=$(awk '$1=="BDIR" { for(i=3; i<NF; i++) \
                               printf "%s ", $i; \
                               printf "%s", $NF }' $pconf)

    # Read the software directory (same as 'inbdir' above about space).
    ddir=$(awk '$1=="DEPENDENCIES-DIR" { for(i=3; i<NF; i++) \
                                         printf "%s ", $i; \
                                         printf "%s", $NF}' $pconf)

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
    bdir="$(absolute_dir "$inbdir")"

    if ! [ -d "$bdir"  ]; then if ! mkdir "$bdir"; then berr=1; err=1; fi; fi
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





# Delete final configuration target
# ---------------------------------
#
# We only want to start running the project later if this script has
# completed successfully. To make sure it hasn't crashed in the middle
# (without the user noticing), in the end of this script we make a file and
# we'll delete it here (at the start). Therefore if the script crashed in
# the middle that file won't exist.
sdir="$bdir"/software
finaltarget="$sdir"/configuration-done.txt
if ! [ -d "$sdir" ];  then mkdir "$sdir"; fi
rm -f "$finaltarget"





# Project's top-level built software directories
# ----------------------------------------------
#
# These directories are possibly needed by many steps of process, so to
# avoid too many directory dependencies throughout the software and
# analysis Makefiles (thus making them hard to read), we are just building
# them here
# Software tarballs
tardir="$sdir"/tarballs
if ! [ -d "$tardir" ];  then mkdir "$tardir"; fi

# Installed software
instdir="$sdir"/installed
if ! [ -d "$instdir" ]; then mkdir "$instdir"; fi

# To record software versions and citation.
verdir="$instdir"/version-info
if ! [ -d "$verdir" ]; then mkdir "$verdir"; fi

# Program and library versions and citation.
ibidir="$verdir"/proglib
if ! [ -d "$ibidir" ]; then mkdir "$ibidir"; fi

# Python module versions and citation.
ipydir="$verdir"/python
if ! [ -d "$ipydir" ]; then mkdir "$ipydir"; fi

# Used software BibTeX entries.
ictdir="$verdir"/cite
if ! [ -d "$ictdir" ]; then mkdir "$ictdir"; fi

# TeXLive versions.
itidir="$verdir"/tex
if ! [ -d "$itidir" ]; then mkdir "$itidir"; fi

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
tmpblddir="$sdir"/build-tmp
rm -rf "$tmpblddir"/* "$tmpblddir"  # If its a link, we need to empty its
                                    # contents first, then itself.





# Project's top-level built analysis directories
# ----------------------------------------------

# Top-level built analysis directories.
badir="$bdir"/analysis
if ! [ -d "$badir" ]; then mkdir "$badir"; fi

# Top-level LaTeX.
texdir="$badir"/tex
if ! [ -d "$texdir" ]; then mkdir "$texdir"; fi

# LaTeX macros.
mtexdir="$texdir"/macros
if ! [ -d "$mtexdir" ]; then mkdir "$mtexdir"; fi

# TeX build directory. If built in a group scenario, the TeX build
# directory must be separate for each member (so they can work on their
# relevant parts of the paper without conflicting with each other).
if [ "x$reproducible_paper_group_name" = x ]; then
    texbdir="$texdir"/build
else
    user=$(whoami)
    texbdir="$texdir"/build-$user
fi
if ! [ -d "$texbdir" ]; then mkdir "$texbdir"; fi

# TiKZ (for building figures within LaTeX).
tikzdir="$texbdir"/tikz
if ! [ -d "$tikzdir" ]; then mkdir "$tikzdir"; fi

# If 'tex/build' and 'tex/tikz' are symbolic links then 'rm -f' will delete
# them and we can continue. However, when the project is being built from
# the tarball, these two are not symbolic links but actual directories with
# the necessary built-components to build the PDF in them. In this case,
# because 'tex/build' is a directory, 'rm -f' will fail, so we'll just
# rename the two directories (as backup) and let the project build the
# proper symbolic links afterwards.
if rm -f tex/build; then
    rm -f tex/tikz
else
    mv tex/tikz tex/tikz-from-tarball
    mv tex/build tex/build-from-tarball
fi

# Set the symbolic links for easy access to the top project build
# directories. Note that these are put in each user's source/cloned
# directory, not in the build directory (which can be shared between many
# users and thus may already exist).
#
# Note: if we don't delete them first, it can happen that an extra link
# will be created in each directory that points to its parent. So to be
# safe, we are deleting all the links on each re-configure of the
# project. Note that at this stage, we are using the host's 'ln', not our
# own, so its best not to assume anything (like 'ln -sf').
rm -f .build .local

ln -s "$bdir" .build
ln -s "$instdir" .local
ln -s "$texdir" tex/build
ln -s "$tikzdir" tex/tikz

# --------- Delete for no Gnuastro ---------
rm -f .gnuastro
# ------------------------------------------



# Set the top-level shared memory location.
if [ -d /dev/shm ]; then     shmdir=/dev/shm
else                         shmdir=""
fi

# If a shared memory mounted directory exists and there is enough space
# there (in RAM), build a temporary directory for this project.
needed_space=2000000
if [ x"$shmdir" != x ]; then
    available_space=$(df "$shmdir" | awk 'NR==2{print $4}')
    if [ $available_space -gt $needed_space ]; then
        dirname=$(pwd | sed -e's/\// /g' \
                      | awk '{l=NF-1; printf("%s-%s",$l, $NF)}')
        tbshmdir="$shmdir"/"$dirname"-$(whoami)
        if ! [ -d "$tbshmdir" ]; then mkdir "$tbshmdir"; fi
    fi
else
    tbshmdir=""
fi

# If a shared memory directory was created set `build-tmp' to be a
# symbolic link to it. Otherwise, just build the temporary build
# directory under the project build directory.
if [ x"$tbshmdir" = x ]; then mkdir "$tmpblddir";
else                          ln -s "$tbshmdir" "$tmpblddir";
fi





# Inform the user that the build process is starting
# -------------------------------------------------
if [ $printnotice = yes ]; then
    tsec=10
    cat <<EOF

-------------------------
Building dependencies ...
-------------------------

Necessary dependency programs and libraries will be built in

  $sdir/installed

NOTE: the built software will NOT BE INSTALLED on your system (no root
access is required). They are only for local usage by this project.

**TIP**: you can see which software are being installed at every moment
with the following command. See "Inspecting status" section of
'README-hacking.md' for more. In short, run it while the project is being
configured (in another terminal, but in this same directory:
'$currentdir'):

  $ ./project --check-config

Project's configuration will continue in $tsec seconds.

-------------------------

EOF
    sleep $tsec
fi





# Number of threads to build software
# -----------------------------------
#
# If the user hasn't manually specified the number of threads, see if we
# can deduce it from the host:
#  - On systems with GNU Coreutils we have 'nproc'.
#  - On BSD-based systems (for example FreeBSD and macOS), we have a
#    'hw.ncpu' in the output of 'sysctl'.
#  - When none of the above work, just set the number of threads to 1.
if [ $jobs = 0 ]; then
    if type nproc > /dev/null 2> /dev/null; then
        numthreads=$(nproc --all);
    else
        numthreads=$(sysctl -a | awk '/^hw\.ncpu/{print $2}')
        if [ x"$numthreads" = x ]; then numthreads=1; fi
    fi
else
    numthreads=$jobs
fi





# See if the linker accepts -Wl,-rpath-link
# -----------------------------------------
#
# `-rpath-link' is used to write the information of the linked shared
# library into the shared object (library or program). But some versions of
# LLVM's linker don't accept it an can cause problems.
#
# IMPORTANT NOTE: This test has to be done **AFTER** the definition of
# 'instdir', otherwise, it is going to be used as an empty string.
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





# Delete the compiler testing directory
# -------------------------------------
#
# This directory was made above to make sure the necessary compilers can be
# run.
rm -f $testprog $testsource
rm -rf $compilertestdir





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





# Find Zenodo URL for software downloading
# ----------------------------------------
#
# All free-software source tarballs that are potentially used in Maneage
# are also archived in Zenodo with a certain concept-DOI. A concept-DOI is
# a Zenodo terminology, meaning a fixed DOI of the project (that can have
# many sub-DOIs for different versions). By default, the concept-DOI points
# to the most recently uploaded version. However, the concept-DOI itself is
# not directly usable for downloading files. The concept-DOI will just take
# us to the top webpage of the most recent version of the upload.
#
# The problem is that as more software are added (as new Zenodo versions),
# the most recent Zenodo-URL that the concept-DOI points to, also
# changes. The most reliable solution was found to be the tiny script below
# which will download the DOI-resolved webpage, and extract the Zenodo-URL
# of the most recent version from there (using the 'coreutils' tarball as
# an example, the directory part of the URL for all the other software are
# the same).
user_backup_urls=""
zenodocheck=.build/software/zenodo-check.html
if $downloader $zenodocheck https://doi.org/10.5281/zenodo.3883409; then
    zenodourl=$(sed -n -e'/coreutils/p' $zenodocheck \
                    | sed -n -e'/http/p' \
                    | tr ' ' '\n' \
                    | grep http \
                    | sed -e 's/href="//' -e 's|/coreutils| |' \
                    | awk 'NR==1{print $1}')
else
    zenodourl=""
fi
rm -f $zenodocheck

# Add the Zenodo URL to the user's given back software URLs. Since the user
# can specify 'user_backup_urls' (not yet implemented as an option in
# './project'), we'll give preference to their specified servers, then add
# the Zenodo URL afterwards.
user_backup_urls="$user_backup_urls $zenodourl"





# Build core tools for project
# ----------------------------
#
# Here we build the core tools that 'basic.mk' depends on: Lzip
# (compression program), GNU Make (that 'basic.mk' is written in), Dash
# (minimal Bash-like shell) and Flock (to lock files and enable serial
# download).
./reproduce/software/shell/pre-make-build.sh \
    "$bdir" "$ddir" "$downloader" "$user_backup_urls"





# Build other basic tools our own GNU Make
# ----------------------------------------
#
# When building these software we don't have our own un-packing software,
# Bash, Make, or AWK. In this step, we'll install such low-level basic
# tools, but we have to be very portable (and use minimal features in all).
echo; echo "Building necessary software (if necessary)..."
.local/bin/make -k -f reproduce/software/make/basic.mk \
     user_backup_urls="$user_backup_urls" \
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
    numthreads=$(.local/bin/nproc --all)
else
    numthreads=$jobs
fi
.local/bin/env -i HOME=$bdir \
     .local/bin/make -k -f reproduce/software/make/high-level.mk \
          user_backup_urls="$user_backup_urls" \
          sys_library_path=$sys_library_path \
          rpath_command=$rpath_command \
          all_highlevel=$all_highlevel \
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
below.

    rm .local/version-info/tex/texlive-ready-tlmgr
    ./project configure -e

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

# Import the context/sentences for placing between the list of software
# names during their acknowledgment.
. $cdir/software_acknowledge_context.sh

# Report the different software in separate contexts (separating Python and
# TeX packages from the C/C++ programs and libraries).
proglibs=$(prepare_name_version $verdir/proglib/*)
pymodules=$(prepare_name_version $verdir/python/*)
texpkg=$(prepare_name_version $verdir/tex/texlive)

# Acknowledge these software packages in a LaTeX paragraph.
pkgver=$mtexdir/dependencies.tex

# Add the text to the ${pkgver} file.
.local/bin/echo "$thank_software_introduce " > $pkgver
.local/bin/echo "$thank_progs_libs $proglibs. "   >> $pkgver
if [ x"$pymodules" != x ]; then
    .local/bin/echo "$thank_python $pymodules. "   >> $pkgver
fi
.local/bin/echo "$thank_latex $texpkg. " >> $pkgver
.local/bin/echo "$thank_software_conclude" >> $pkgver

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





# Report machine architecture
# ---------------------------
#
# Report hardware
hwparam="$mtexdir/hardware-parameters.tex"

# Add the text to the ${hwparam} file. Since harware class might include
# underscore, it must be replaced with '\_', otherwise pdftex would
# complain and break the build process when doing ./project make.
hw_class_fixed="$(echo $hw_class | sed -e 's/_/\\_/')"
.local/bin/echo "\\newcommand{\\machinearchitecture}{$hw_class_fixed}" > $hwparam
.local/bin/echo "\\newcommand{\\machinebyteorder}{$byte_order}" >> $hwparam
.local/bin/echo "\\newcommand{\\machineaddresssizes}{$address_sizes}" >> $hwparam





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

To change the configuration later, you can re-run './project configure' or
manually edit 'reproduce/software/config/LOCAL.conf'. Just be careful with
the build-directory: its location is hard-coded in the installed software
so if you change it manually, many of the project's software will crash. If
you have to use another built-directory, just re-configure a clean project
there.

Please run the following command to start the project.
(Replace '8' with the number of CPU threads on your system)

    $buildcommand

EOF
