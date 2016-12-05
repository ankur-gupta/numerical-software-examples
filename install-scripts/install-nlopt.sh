#!/bin/bash -e

# Step 0: Install location
install_location="${HOME}/toolbox/`uname`/nlopt"

# Step 1: Download the bleeding edge version.
# Bleeding edge version gets frequent updates and is better supported.
cd /tmp
rm -rf /tmp/nlopt
git clone git@github.com:stevengj/nlopt.git
cd /tmp/nlopt

# Step 2: Prepare for installation
# Install octave-dev (for Octave Client) and swig & guile (for python client)
# After running cmake, see the results. If it says "Could NOT find SWIG" or
# "Could NOT find GUILE" then Python client will not be built.
# if [ `uname` -eq 'Linux' ]; then
#     # For Linux:
#     sudo apt install liboctave-dev
#     sudo apt-get install swig
# fi
# if [ `uname` -eq 'Darwin' ]; then
#     # For Mac:
#     brew install swig
#     brew install guile
#     # You might need to install gmp too. You will need to specify location
#     # in the cmake step below.
#     brew install gmp
#     # You might also need to install garbage collector bdwgc (provides gc/gc.h)
#     # See https://github.com/ivmai/bdwgc
#     # This will be used in the cmake step below for Mac
# fi

# Step 3: Collect information about supporting software
# If you need to specify more options, you can get a list of variables
# by `cmake -LAH`
if [ "$(uname)" == "Linux" ]; then
    cmake -DCMAKE_INSTALL_PREFIX=${install_location} .
fi
if [ "$(uname)" == "Darwin" ]; then
    cmake -DCMAKE_CXX_FLAGS="-I /usr/local/include -I ~/toolbox/Darwin/bdwgc/include" \
        -DCMAKE_INSTALL_PREFIX=${install_location} .
fi


# Step 4: Install
# Manually check for make errors
make
rm -rf ${install_location}
mkdir -p ${install_location}
make install
cd ${install_location}

# (Old procedure) Step 5: Copy into anaconda for Python
# May still be needed for Linux. Delete if not needed.
# This will enable "import nlopt" from anywhere.
# rm -rf ~/anaconda/lib/python2.7/site-packages/nlopt
# cp -r ${install_location}/lib/python2.7/site-packages ~/anaconda/lib/python2.7/site-packages/nlopt
# cd ~/anaconda/lib/python2.7/site-packages/nlopt
# mv ~/anaconda/lib/python2.7/site-packages/nlopt/nlopt.py ~/anaconda/lib/python2.7/site-packages/nlopt/__init__.py


# Step 5(a): Add location to PYTHONPATH. This depends on your shell. Manual step
# Lets you "import nlopt" from anywhere.
# For fish shell, add these lines to ~/.config/fish/config.fish
# Note that this depends on the install location.
echo "Add this line to your fish shell (if you did not change install location): "
echo 'set -g -x PYTHONPATH ~/toolbox/(uname)/nlopt/lib/python2.7/site-packages:"$PYTHONPATH"'

# Step 5(b): Add to Octave Path
echo 'Add this line to your ~/.octaverc:'
echo 'addpath(genpath(['~/toolbox/' uname.sysname, '/nlopt']));'


# # Step 6: Test example script. Manual step.
# # May need to install
# conda install libgcc
# # or, update matplotlib
# conda update matplotlib
# # We change directories to ensure we are able to access nlopt from anywhere.
# cd ~/toolbox/numerical-software-examples/examples/nlopt
# python ~/toolbox/numerical-software-examples/examples/nlopt/nlopt_example.py
# octave-cli ~/toolbox/numerical-software-examples/examples/nlopt/nlopt_example.m
