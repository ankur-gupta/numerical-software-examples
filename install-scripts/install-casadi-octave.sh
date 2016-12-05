#!/bin/sh

# Location of tar.gz file containing source code
# Download from https://github.com/casadi/casadi/wiki/InstallationInstructions
tarball_location="$HOME/Downloads/casadi-octave-v3.1.1.tar.gz"


# Install location folder
# Note that this folder will be deleted and overwritten if it already exists
install_location="${HOME}/toolbox/`uname`/casadi/octave"

# Clear out space for this installation
rm -rf ${install_location}
mkdir -p ${install_location}

# Extract tarball in the specified location
tar -xvf ${tarball_location} -C ${install_location}

# # Manual steps:
# # 1. Add this line to your ~/.octaverc file
# addpath(genpath(['~/toolbox/' uname.sysname '/casadi/octave']));
# # 2. Import casadi in your code using this line
# import casadi.*



