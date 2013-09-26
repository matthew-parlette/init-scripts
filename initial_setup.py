#!/bin/bash
#Verify if root
if [ "$(whoami)" != "root" ]; then
  echo "This program must be run as root, try 'sudo $0'"
  exit 1
fi

#Setup the motd
apt-get -yqq install figlet		# for block text
echo "" > /etc/motd		# clear the disclaimer
cp files/motd /etc/init.d/motd	# motd script with figlet command
service motd stop		# enable the change
service motd start
echo "| MOTD configured |"

echo "| System is ready |"
