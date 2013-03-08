#!/bin/bash
# royans@gmail.com - Mar 2013


uname -a | grep amzn1.i686 2> /dev/null > /dev/null
if [ $? -eq 1 ]
then
  echo "You are not running this script from amazon's distribution on amazon's cloud."
  echo "A lot of things here are hardcoded for amazon, so please edit the scripts and use at your own risk."
  exit 1
fi

ME=`pwd`
export ME

source $ME/vars.sh

if [ "$1" == "" ]
then
  echo "Usage: ./setup.sh <email@address>"
  echo "       - The email address should belong to the user who needs to get the onc certificate."
  echo "       - For example: ./setup.sh test@blogofy.com"
  echo ""
  exit 1
fi
export KEY_EMAIL=$1


./cleanup.sh  
./server_init.sh 
./openvpn_config.sh 

