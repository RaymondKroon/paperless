#!/usr/bin/env bash

git clone https://github.com/RaymondKroon/insaned.git
cd insaned
make
sudo cp insaned /usr/local/bin
cd ..
rm -rf insaned
#dpkg-buildpackage -b -rfakeroot -us -uc
#cd ..
#for deb in insaned*.deb; do sudo dpkg --ignore-depends -i $deb; done