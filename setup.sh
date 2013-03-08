#!/bin/bash
# royans@gmail.com - Mar 2013


uname -a | grep amzn1.i686
if [ $? -eq 1 ]
then
  echo "You are not running this script from amazon's distribution on amazon's cloud."
  echo "A lot of things here are hardcoded for amazon, so please edit the scripts and use at your own risk."
  exit 1
fi

ME=`pwd`
export ME

source $ME/vars.sh

./cleanup.sh  
./server_init.sh 
./openvpn_config.sh 

