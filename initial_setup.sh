#!/bin/bash
#Verify if root
if [ "$(whoami)" != "root" ]; then
  echo "This program must be run as root, try 'sudo $0'"
  exit 1
fi

#Setup the motd
apt-get install -qq figlet	# for block text
echo "" > /etc/motd		# clear the disclaimer
cp files/motd /etc/init.d/motd	# motd script with figlet command
service motd stop		# enable the change
service motd start
echo "|  MOTD configured   |"

#Setup the network
echo -n "Local IP Address for this pi: "
read ip
sed s/"ip_addr"/"$ip"/ <files/interfaces >/etc/network/interfaces
apt-get install -qq n2n
if [ ! "$?" ]; then
  echo -n "n2n failed to install, exiting..."
  exit 1
fi
apt-get install -qq --force-yes upstart # Force yes for this major change
if [ ! "$?" ]; then
  echo -n "Upstart failed to install, exiting..."
  exit 1
fi

echo -n "n2n IP: "
read n2n_ip
echo -n "n2n Community: "
read n2n_community
echo -n "n2n Community Password: "
read community_password
echo -n "n2n Supernode Address: "
read supernode_addr
cp files/n2n.conf /etc/init/
sed -i s/"ip_addr"/"$n2n_ip"/g /etc/init/n2n.conf
sed -i s/"n2n_community"/"$n2n_community"/g /etc/init/n2n.conf
sed -i s/"community_password"/"$community_password"/g /etc/init/n2n.conf
sed -i s/"supernode_addr"/"$supernode_addr"/g /etc/init/n2n.conf

echo "| Network configured |"

echo "|  System is ready   |"
echo "| Reboot before use  |"
