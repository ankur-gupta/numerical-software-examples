#!/bin/sh

ver=5 #for 2.5.0

# Location of installer files
loc0="$HOME/Downloads/sundials-2.${ver}.0"

# Location of installed C files
locC="$HOME/toolbox/sundials2${ver}0"

# Location of installed toolbox
locTB="$HOME/toolbox/sundials2${ver}0TB"

echo "Installing Sundials 2.${ver}.0 ..."

echo "Removing existing installer files at ${loc0} ..."
rm -rf $loc0
echo "Removing existing installed C files at ${locC} ..."
rm -rf $locC
echo "Removing existing installed toolbox at ${locTB} ..."
rm -rf $locTB

echo "Unzipping a new copy of installer files at ${loc0} ..."
cd $HOME/Downloads
tar -xf sundials-2.${ver}.0.tar.gz

cd $loc0
# Ubuntu 12.10 doesn't seem to have g77. So I need to disable fortran
./configure --prefix=${locC} --enable-examples --disable-mpi --disable-fcmix --with-cflags="-O3 -fPIC"
make
make install

mkdir $locTB
cd $loc0/sundialsTB
echo "Run octave 3.6.3 (3.6.2. has a copyfile bug) and install the toolbox."