#!/bin/sh

# Location of tar.gz file containing source code
# Download from https://github.com/casadi/casadi/wiki/InstallationInstructions
# tarball_location="$HOME/Downloads/casadi-py27-np1.9.1-v3.1.1.tar.gz"
tarball_location="$HOME/Downloads/casadi-py27-np1.9.1-v2.4.3.tar.gz"


# Install location folder
# Note that this folder will be deleted and overwritten if it already exists
install_location="${HOME}/toolbox/`uname`/casadi243/python"

# Clear out space for this installation
rm -rf ${install_location}
mkdir -p ${install_location}

# Extract tarball in the specified location
tar -xvf ${tarball_location} -C ${install_location}



# Lets you "import nlopt" from anywhere.
# For fish shell, add these lines to ~/.config/fish/config.fish
# Note that this depends on the install location.
echo "Add this line to your fish shell (if you did not change install location): "
echo 'set -g -x PYTHONPATH ~/toolbox/(uname)/casadi243/python:"$PYTHONPATH"'

# Run example:
# python ~/toolbox/numerical-software-examples/examples/casadi/python/casadi_example.py