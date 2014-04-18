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

echo "Checking on n2n status..."
echo "(You may need to enter your sudo password)"
sudo status n2n
n2n_status="$?"
if [ "$n2n_status" ]; then
    if yes_no_question "n2n does not appear to be running, would you like to configure it now?"
    then
        eval "$script_dir/n2n_bootstrap.sh"
        echo "Checking on n2n status..."
        echo "(You may need to enter your sudo password)"
        sudo status n2n
        n2n_status="$?"
    else
        echo "Exiting..."
        exit 1
    fi
fi

if [ "$n2n_status" ]; then
    # n2n Stopped
    echo "n2n does not appear to be running, exiting..."
    exit 1
else
    # n2n Running
    echo "n2n apears to be running!"
    if yes_no_question "Continue with salt bootstrap?"
    then
        echo "Checking on salt dns entry..."
        if grep -q "salt" "/etc/hosts"
        then
            echo "Salt server dns is setup!"
        else
            echo "Adding salt dns entry to hosts..."
            echo "(You may need to enter your sudo password)"
            echo -e "10.1.2.5\tsalt" | sudo tee -a /etc/hosts > /dev/null
        fi

        echo "Installing salt minion..."
        echo "(You may need to enter your sudo password)"
        eval "wget -O - http://bootstrap.saltstack.org | sudo sh"
    else
        echo "Exiting..."
fi