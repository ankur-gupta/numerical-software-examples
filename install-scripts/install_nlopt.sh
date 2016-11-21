#!/bin/sh -e

# For Linux
cd /tmp
rm -rf /tmp/nlopt
git clone git@github.com:stevengj/nlopt.git
cd /tmp/nlopt

# Install octave dev and swig (for python)
# sudo apt install liboctave-dev
# sudo apt-get install swig
cmake -DCMAKE_INSTALL_PREFIX=~/toolbox/nlopt .
make
rm -rf ~/toolbox/nlopt
mkdir -p ~/toolbox/nlopt
make install
cd ~/toolbox/nlopt
rm -rf ~/anaconda/lib/python2.7/site-packages/nlopt
cp -r ~/toolbox/nlopt/lib/python2.7/site-packages ~/anaconda/lib/python2.7/site-packages/nlopt
cd ~/anaconda/lib/python2.7/site-packages/nlopt
mv ~/anaconda/lib/python2.7/site-packages/nlopt/nlopt.py ~/anaconda/lib/python2.7/site-packages/nlopt/__init__.py
cd ~/toolbox/numerical-software-examples/examples/nlopt

# May need to install
# conda install libgcc
# or, update matplotlib
# conda update matplotlib
python ~/toolbox/numerical-software-examples/examples/nlopt/nlopt_example.py