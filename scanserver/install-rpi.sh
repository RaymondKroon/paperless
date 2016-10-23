#!/usr/bin/env bash

set -e

RPI=${RPI:-raspberrypi}
RPI_USER=${RPI_USER:-pi}

ADDRESS=$RPI_USER@$RPI

#ssh $ADDRESS "sudo apt-get update && sudo apt-get upgrade -y"
#ssh $ADDRESS "sudo apt-get -f install -y" #libsane.
#ssh $ADDRESS "sudo apt-get install -y libusb-dev build-essential git-core sane \\
#              libsane-dev libavahi-client-dev libavahi-glib-dev debhelper imagemagick unpaper \\
#              tesseract-ocr tesseract-ocr-nld pdftk bc inotify-tools" #exactimage
#
#scp build-and-install-sane-backends.sh $ADDRESS:/tmp/build-and-install-sane-backends.sh
#ssh $ADDRESS "cd /tmp && ./build-and-install-sane-backends.sh"
#
#scp config/79-scanner.rules drivers/1300i_0D12.nal config/epjitsu.conf config/dll.conf config/saned.conf $ADDRESS:/tmp
#ssh $ADDRESS "sudo mv /tmp/79-scanner.rules /etc/udev/rules.d/ \\
#              && sudo mkdir -p /usr/share/sane/epjitsu/ \\
#              && sudo mv /tmp/1300i_0D12.nal  /usr/share/sane/epjitsu/ \\
#              && sudo mv /etc/sane.d/epjitsu.conf /etc/sane.d/epjitsu.conf.bak \\
#              && sudo mv /tmp/epjitsu.conf /etc/sane.d/epjitsu.conf \\
#              && sudo mv /etc/sane.d/dll.conf /etc/sane.d/dll.conf.bak \\
#              && sudo mv /tmp/dll.conf /etc/sane.d/dll.conf \\
#              && sudo mv /etc/sane.d/saned.conf /etc/sane.d/saned.conf.bak \\
#              && sudo mv /tmp/saned.conf /etc/sane.d/saned.conf"
#ssh $ADDRESS "sudo usermod -a -G scanner $RPI_USER"
#ssh $ADDRESS "sudo systemctl enable saned.socket" # && sudo systemctl start saned.socket"
#
#scp trigger/build-and-install-insaned.sh $ADDRESS:/tmp/
#ssh $ADDRESS "cd /tmp && ./build-and-install-insaned.sh"
#
#ssh $ADDRESS "sudo dpkg -r --force-all libsane" #only remove libsane, we only want the new version. Could be done earlier if we fix dependencies for insaned

scp trigger/insaned.service trigger/insaned $ADDRESS:/tmp/
ssh $ADDRESS "cd /tmp \\
              && sudo mv insaned /etc/default/insaned \\
              && sudo mv insaned.service /lib/systemd/system/"
ssh $ADDRESS "sudo systemctl enable insaned"


ssh $ADDRESS "mkdir -p /tmp/actions " && scp actions/* $ADDRESS:/tmp/actions/
ssh $ADDRESS "sudo mv /tmp/actions/* /etc/insaned/events/"

ssh $ADDRESS "sudo mkdir -p /scans && sudo chown pi.scanner /scans && sudo setfacl -Rdm g:scanner:rwx /scans && sudo chmod ug+s /scans"
ssh $ADDRESS "sudo mkdir -p /scans/raw && sudo chown pi.scanner /scans/raw && sudo setfacl -Rdm g:scanner:rwx /scans/raw && sudo chmod ug+s /scans/raw"

ssh $ADDRESS "sudo mkdir -p /scans/cleaned && sudo chown pi.scanner /scans/cleaned && sudo setfacl -Rdm g:scanner:rwx /scans/cleaned && sudo chmod ug+s /scans/cleaned"
scp clean/clean-listener.sh clean/clean.sh $ADDRESS:/tmp/
ssh $ADDRESS "sudo mv /tmp/clean-listener.sh /usr/local/bin && sudo mv /tmp/clean.sh /usr/local/bin"

scp clean/paperless-clean.service $ADDRESS:/tmp/
ssh $ADDRESS "cd /tmp && sudo mv paperless-clean.service /etc/systemd/system/"
ssh $ADDRESS "sudo systemctl enable paperless-clean && sudo systemctl start paperless-clean"

ssh $ADDRESS "sudo mkdir -p /scans/pdf && sudo chown pi.scanner /scans/pdf && sudo setfacl -Rdm g:scanner:rwx /scans/pdf && sudo chmod ug+s /scans/pdf"
scp pdf/pdf-listener.sh pdf/pdf.sh $ADDRESS:/tmp/
ssh $ADDRESS "sudo mv /tmp/pdf-listener.sh /usr/local/bin && sudo mv /tmp/pdf.sh /usr/local/bin"

scp pdf/paperless-pdf.service $ADDRESS:/tmp/
ssh $ADDRESS "cd /tmp && sudo mv paperless-pdf.service /etc/systemd/system/"
ssh $ADDRESS "sudo systemctl enable paperless-pdf && sudo systemctl start paperless-pdf"

ssh $ADDRESS "sudo mkdir -p /scans/sent && sudo chown pi.scanner /scans/sent && sudo setfacl -Rdm g:scanner:rwx /scans/sent && sudo chmod ug+s /scans/sent"
scp transfer/transfer-listener.sh transfer/transfer.sh $ADDRESS:/tmp/
ssh $ADDRESS "sudo mv /tmp/transfer-listener.sh /usr/local/bin && sudo mv /tmp/transfer.sh /usr/local/bin"

scp transfer/paperless-transfer.service $ADDRESS:/tmp/
ssh $ADDRESS "cd /tmp && sudo mv paperless-transfer.service /etc/systemd/system/"
ssh $ADDRESS "sudo systemctl enable paperless-transfer && sudo systemctl start paperless-transfer"

# REBOOT

###ssh $ADDRESS "printf \"\n# Fujitsu S1300i\nfirmware /usr/share/sane/epjitsu/1300i_0D12.nal\nusb 0x04c5 0x128d\n\" | sudo tee -a /etc/sane.d/epjitsu.conf"
#

###ssh $ADDRESS sudo groupadd scanner

#

####ssh $ADDRESS "sudo cp /tmp/sane-backends/tools/udev/libsane.rules /etc/udev/rules.d/60-libsane.rules"
#

#scp drivers/1300i_0D12.nal $ADDRESS:/tmp/1300i_0D12.nal

#
#ssh $ADDRESS "printf \"RUN=no\n\" | sudo tee /etc/default/saned"

#scp saned.socket saned@.service $ADDRESS:/tmp
#ssh $ADDRESS "sudo mv /tmp/saned* /etc/systemd/system/"
#ssh $ADDRESS "printf \"\nlocalhost\n192.168.1.0/24\n\" | sudo tee /etc/sane.d/saned.conf"
#ssh $ADDRESS "sudo systemctl enable saned.socket && sudo systemctl start saned.socket && systemctl status saned.socket"