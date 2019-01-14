#!/bin/bash

set -Ceux

base_url="https://github.com/FRRouting/frr/releases/download/frr-${FRR_VERSION}"
frr_pkgs=(
  "frr_${FRR_VERSION}-${FRR_PACKAGE_VERSION}_amd64.deb"
  "frr-pythontools_${FRR_VERSION}-${FRR_PACKAGE_VERSION}_all.deb"
  "frr-doc_${FRR_VERSION}-${FRR_PACKAGE_VERSION}_all.deb"
  "frr-snmp_${FRR_VERSION}-${FRR_PACKAGE_VERSION}_amd64.deb"
)

export DEBIAN_FRONTEND=noninteractive
sudo apt-get -q update
printf "%s\n" "${frr_pkgs[@]}" | xargs -I{} curl -LOs $base_url/{}
printf "%s\n" "${frr_pkgs[@]}" | xargs -I{} sudo -E apt-get install -yq ./{}
sudo -E apt-get install -yq linux-modules-extra-$(uname -r)
sudo apt-get clean
rm ${frr_pkgs[@]}

# Use traditional ifname such as eth0
sudo sed -i 's/^GRUB_CMDLINE_LINUX=""$/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
sudo update-grub

sudo usermod -aG frr,frrvty $USER
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
