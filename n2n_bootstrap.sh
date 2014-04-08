#!/bin/bash

# Configuration
###############


# Functions
###########
function show_help {
    echo "Help Text"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo -e "-h\tShow this help"
}

# Ask a question, defaults to yes
function yes_no_question () {
    read -r -p "$1 [Y/n] " response
    response=${response,,}
    if [[ "$response" =~ ^(yes|y|)$ ]]; then
        return 0
    else
        return 1
    fi
}

# Ask a question, defaults to no
function no_yes_question () {
    read -r -p "$1 [Y/n] " response
    response=${response,,}
    if [[ "$response" =~ ^(no|n|)$ ]]; then
        return 0
    else
        return 1
    fi
}

# Useful Variables
##################
# Directory containing this script
#  (no matter where it is called from)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
script_dir="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Script
########

# Read Command Line Arguments
while getopts "h" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
  esac
done

# Get n2n Parameters
echo "Enter the n2n community parameters below"
echo "========================================"
echo -n "n2n IP: "
read n2n_ip
echo -n "n2n Community: "
read n2n_community
echo -n "n2n Community Password: "
read community_password
echo -n "n2n Supernode Address: "
read supernode_addr

# Install n2n
apt-get install -qq n2n
if [ ! "$?" ]; then
    echo -n "n2n failed to install, exiting..."
    exit 1
fi

# Install n2n init script
cp files/n2n.conf /etc/init/
sed -i s/"ip_addr"/"$n2n_ip"/g /etc/init/n2n.conf
sed -i s/"n2n_community"/"$n2n_community"/g /etc/init/n2n.conf
sed -i s/"community_password"/"$community_password"/g /etc/init/n2n.conf
sed -i s/"supernode_addr"/"$supernode_addr"/g /etc/init/n2n.conf

# Start n2n
echo "Starting n2n..."
echo "(You may need to enter your sudo password)"
sudo initctl reload
sudo start n2n
if [ ! "$?" ]; then
    echo "Error starting n2n..."
    exit 1
fi
exit 0