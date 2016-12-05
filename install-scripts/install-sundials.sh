#!/bin/bash -e

# Location of tar.gz file containing source code
# Download from https://github.com/casadi/casadi/wiki/InstallationInstructions
tarball_location="$HOME/toolbox/sources/sundials-2.5.0-ankur2.tar.gz"

# Location of temp folder
temp_folder="/tmp/sundials"

# Install location folder for SUNDIALS C files
# Note that this folder will be deleted and overwritten if it already exists
install_location="${HOME}/toolbox/`uname`/sundials"
c_install_location="${install_location}/c"

# Install location folder for SUNDIALS Octave/MATLAB files
# Note that this folder will be deleted and overwritten if it already exists
octave_install_location="${install_location}/octave"

# Clear out space for this installation
rm -rf ${install_location}
rm -rf ${c_install_location}
rm -rf ${octave_install_location}
mkdir -p ${c_install_location}
mkdir -p ${octave_install_location}

# Extract tarball in the specified location
rm -rf ${temp_folder}
mkdir -p ${temp_folder}
tar -xvf ${tarball_location} -C ${temp_folder}

# Build and install the C files
cd ${temp_folder}/*
# Ubuntu 12.10 doesn't seem to have g77. So I need to disable fortran.
./configure --prefix=${c_install_location} --enable-examples \
    --disable-mpi --disable-fcmix --with-cflags="-O3 -fPIC"
make
make install

# Install Octave/MATLAB toolbox
# If you see a copyfile issue, it could be due to a copyfile bug (Octave 3.6.2 and earlier)
# Or, one of the .mex files was not correctly built.
# This is usually kim.mex.
# Modify return -> return(0) in sundialsTB/kinsol/kim/src/kim.c (lines 682 and 810).
# See http://sundials.2283335.n4.nabble.com/SundialsTB-not-compiling-on-OSX-td4653061.html
cd ${temp_folder}/*/sundialsTB
echo 'Run octave 3.6.3+ (3.6.2. has a copyfile bug) and install the toolbox.'
echo "cd ${temp_folder}/*/sundialsTB"
echo 'Install Octave/MATLAB toolbox executing `install_STB` in Octave'
echo "Enter this as your toolbox location: ${octave_install_location}"


# Manual Add to Octave Path
echo 'Add this line to your ~/.octaverc:'
echo 'addpath(genpath(['~/toolbox/' uname.sysname '/sundials/octave'])); startup_STB'
