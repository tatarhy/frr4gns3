#!/bin/bash

set -Ceux

export DEBIAN_FRONTEND=noninteractive

# Add frr repository
curl -s https://deb.frrouting.org/frr/keys.asc | sudo apt-key add -
echo deb https://deb.frrouting.org/frr $(lsb_release -s -c) $FRRVER | sudo tee -a /etc/apt/sources.list.d/frr.list

# Update repository
sudo apt-get -q update

# Change kernel flavor
old_kernel_modules="linux-modules-$(uname -r)"
new_kernel_modules=$(apt-cache -n search linux-modules-extra-.*-generic | tail -1 | awk '{print $1}')
sudo -E apt-get install -yq ${new_kernel_modules}
sudo -E apt-get purge -yq linux-image-kvm ${old_kernel_modules}

# Install frr packages
sudo -E apt-get install -yq frr frr-pythontools frr-doc frr-snmp

# Install utils
sudo -E apt-get install -yq vim-tiny iputils-ping iputils-tracepath less telnet rsyslog

# Remove unused packages
sudo apt-get purge -yq lxd lxd-client lxcfs cloud-init snapd lvm2 apport
sudo apt-get autoremove -yq --purge

sudo apt-get clean

# Change GRUB options
sudo sed -i -E 's/^GRUB_TIMEOUT=[0-9]+$/GRUB_TIMEOUT=0/' /etc/default/grub
# Use traditional ifname such as eth0
sudo sed -i 's/^GRUB_CMDLINE_LINUX=""$/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
echo 'GRUB_DISABLE_OS_PROBER=true' | sudo tee -a /etc/default/grub
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
