#!/bin/sh -e

# For Linux
cd /tmp
rm -rf /tmp/nlopt
git clone git@github.com:stevengj/nlopt.git
cd /tmp/nlopt
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
cd ~/toolbox/examples/
python ~/toolbox/examples/nlopt_example.py