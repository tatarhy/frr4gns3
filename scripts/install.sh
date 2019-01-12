#!/bin/bash

sudo apt-get -q update
curl -LOs https://github.com/FRRouting/frr/releases/download/frr-6.0/frr_6.0-1.ubuntu18.04+1_amd64.deb
sudo dpkg -i frr_6.0-1.ubuntu18.04+1_amd64.deb
sudo apt-get install -fyq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq linux-modules-extra-$(uname -r)
sudo apt-get clean
rm frr_6.0-1.ubuntu18.04+1_amd64.deb

sudo gpasswd -a $USER frrvty
sudo sed -i 's/=no/=yes/' /etc/frr/daemons

cat <<EOF | sudo tee /etc/modules
mpls_router
mpls_gso
mpls_iptunnel
EOF

cat <<EOF | sudo tee /etc/sysctl.d/99-frr.conf
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
net.mpls.conf.eth0.input=1
net.mpls.conf.eth1.input=1
net.mpls.conf.eth2.input=1
net.mpls.conf.eth3.input=1
net.mpls.conf.eth4.input=1
net.mpls.conf.eth5.input=1
net.mpls.conf.eth6.input=1
net.mpls.conf.eth7.input=1
net.mpls.conf.lo.input=1
net.mpls.platform_labels=1048575
EOF

echo 'vtysh' >> $HOME/.profile
