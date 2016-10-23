#!/usr/bin/env bash

git clone git://git.debian.org/sane/sane-backends.git
cd sane-backends
BACKENDS=epjitsu ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-avahi
make
sudo make install