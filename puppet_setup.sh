#!/bin/bash
#Verify if root
if [ "$(whoami)" != "root" ]; then
  echo "This program must be run as root, try 'sudo $0'"
  exit 1
fi
reboot=0
puppetmaster="puppet-master.andromeda"
hostname=`hostname`

#Make sure the hostname ends in .andromeda
if [ "$hostname" != *.andromeda ]; then
  hostname="$hostname.andromeda"
fi
echo "*Hostname set to $hostname*"

read -r -p "Configure puppet? [Y/n] " response
response=${response,,}
if [[ "$response" =~ ^(yes|y|)$ ]]; then
  #Install puppet
  echo "Installing puppet..."
  apt-get install -qq puppet
  if [ ! "$?" ]; then
    echo -n "Puppet failed to install, exiting..."
    exit 1
  fi

  echo "Verifying connectivity to puppet master ($puppetmaster)..."
  ping -c 1 "$puppetmaster" > /dev/null
  if [ ! "$?" ]; then
    echo -n "$puppetmaster did not respond to ping, exiting..."
    exit 1
  fi

  #Run first time
  echo "Executing first run of puppet agent..."
  echo "** Check to see if the cert needs to be authenticated on the puppet master **"
  puppet agent --test --server "$puppetmaster" --waitforcert 10 --certname "$hostname"

  if [ ! "$?" ]; then
    echo -n "Puppet agent first time run failed, exiting..."
    exit 1
  fi

  echo "Starting puppet agent..."
  if [ -a "/etc/default/puppet" ]; then
    sed -i 's/START=no/START=yes/g' /etc/default/puppet
  fi
  #sed -i s/'^DAEMON_OPTS=.*$'/"DAEMON_OPTS=\"--certname $hostname\""/g /etc/default/puppet
  puppet agent --enable

fi


#echo -n "n2n IP: "
#read n2n_ip
#sed -i s/"ip_addr"/"$n2n_ip"/g /etc/init/n2n.conf

echo "| Puppet config done |"
if [ $reboot -eq 1 ]; then
  echo "| Reboot before use  |"
fi
