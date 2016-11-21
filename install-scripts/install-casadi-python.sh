#!/bin/sh

# Location of tar.gz file containing source code
# Download from https://github.com/casadi/casadi/wiki/InstallationInstructions
tarball_location="$HOME/Downloads/casadi-py27-np1.9.1-v3.1.0.tar.gz"


# Install location folder
# Note that this folder will be deleted and overwritten if it already exists
install_location="$HOME/toolbox/casadi/python"

# Clear out space for this installation
rm -rf ${install_location}
mkdir -p ${install_location}

# Extract tarball in the specified location
tar -xvf ${tarball_location} -C ${install_location}


# # Manual steps:
# # 1. Add location to PYTHONPATH. This depends on your shell.
# #    For fish shell, add these lines to ~/.config/fish/config.fish
# set -g -x PYTHONPATH $PYTHONPATH ~/toolbox/casadi/python
# # 2. Import casadi in your python code as usual
# import casadi



