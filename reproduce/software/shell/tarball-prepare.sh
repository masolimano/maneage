#!/bin/bash

# Script to convert all files (tarballs in any format; just recognized
# by 'tar') within an 'odir' to a unified '.tar.lz' format.
#
# The inputs are assumed to be formatted with 'NAME_VERSION', and only for
# the names, we are currently assuming '.tar.*' (for the 'sed'
# command). Please modify/generalize accordingly.
#
# It will unpack the source in a certain empty directory with the
# 'tmpunpack' suffix, and rename the top directory to the requested format
# of NAME-VERSION also. So irrespective of the name of the top original
# tarball directory, the resulting tarball's top directory will have a name
# formatting of NAME-VERSION.
#
# Discussion: https://savannah.nongnu.org/task/?15699
#
# Copyright (C) 2022 Mohammad Akhlaghi <mohammad@akhlaghi.org>
# Copyright (C) 2022 Pedram Ashofteh Ardakani <pedramardakani@pm.me>
# Released under GNU GPLv3+

# Abort the script in case of an error.
set -e





# Default arguments
odir=
idir=
quiet=
basedir=$PWD


# The --help output
print_help() {
    cat <<EOF
Usage: $0 [OPTIONS]

Low-level script to create maneage-standard tarballs.

  -o, --output-dir         Target directory to write the packed tarballs.
                           Current: $odir


  -i, --input-dir          Directory containing original tarballs.
                           Current: $idir

  -q, --quiet              Suppress logging information. Only print the
                           final packed file and its sha512sum.

Maneage URL: https://maneage.org

Report bugs: https://savannah.nongnu.org/bugs/?group=reproduce
EOF
}




# Parse the arguments
while [ $# -gt 0 ]
do
  case $1 in
      -q|--quiet)      quiet=1; shift;;
      -h|--help|-'?')  print_help; exit 0;;
      -i|--input-dir)
          # Remove the trailing '/' introduced by autocomplete
          idir=$(echo "$2" | sed 's|/$||');
          shift;  # past argument
          shift;; # past value
      -o|--output-dir)
          # Remove the trailing '/' introduced by autocomplete
          odir=$(echo "$2" | sed 's|/$||');
          shift;  # past argument
          shift;; # past value
      *)  echo "$0: unknown option '$1'"; exit 1;;
  esac
done




# Extract the 'absolute path' to input and output directories. Working with
# relative path is a great source of confusion and unwanted side-effects
# like moving/removing files by accident.
if [ ! -d "$idir" ]; then
    echo "$0: please pass the input directory (option --input-dir or -i)."
    exit 1
else
    idir=$(realpath $idir)
fi

if [ ! -d "$odir" ]; then
    echo "$0: please pass the output directory (option --output-dir or -o)."
    exit 1
else
    odir=$(realpath $odir)
fi





# Unpack and pack all files in the '$idir'
# ----------------------------------------
allfiles=$(ls $idir | sort)

# Let user know number of tarballs if its not in quiet mode
if [ -z $quiet ]; then
    nfiles=$(ls $idir | wc -l)
    echo "Found $nfiles file(s) in '$idir/'"
fi

# Process all files
for f in $allfiles; do

    # Seperate name and version number
    name=$(echo $f | sed -e 's/.tar.*//' | \
                     awk 'BEGIN { FS = "[-_ ]" } {print $1 "-" $2}')

    # Skip previously packed files
    if [ -f $odir/$name.tar.lz ]; then

        # Print the info message if not in quiet mode
        if [ -z $quiet ]; then
            echo "$0: skipping '$odir/$name.tar.lz'"
        fi

        # skip this file
        continue
    else

        # Print the info message if not in quiet mode
        if [ -z $quiet ]; then
            echo "$0: processing '$idir/$f'"
        fi
    fi

    # Create a temporary directory name
    tmpdir=$odir/$name-tmpunpack

    # If the temporary directory exists, mkdir will throw an error. The
    # developer needs to intervene manually to fix the issue.
    mkdir $tmpdir





    # Move into the temporary directory
    # ---------------------------------
    #
    # The default output directory for all the following commands: $tmpdir
    cd $tmpdir

    # Unpack
    tar -xf $idir/$f

    # Make sure the unpacked tarball is contained within a directory with
    # the clean program name
    if [ ! -d "$name" ]; then
        mv * $name/
    fi

    # Pack with recommended options
    tar -c -Hustar --owner=root --group=root \
        -f $name.tar $name/
    lzip -9 $name.tar

    # Move the compressed file from the temporary directory to the target
    # output directory
    mv $name.tar.lz $odir/

    # Print the sha512sum along with the filename for a quick reference
    echo $(sha512sum $odir/$name.tar.lz)

    # Clean up the temporary directory
    rm -r $tmpdir
done
