#!/bin/bash

if [ "$1" == "" ]
then
  echo "Usage: ./quicksetup.sh <email@address>"
  echo "       - The email address should belong to the user who needs to get the onc certificate."
  echo "       - For example: ./quick.sh test@blogofy.com"
  echo ""
  exit 1
fi

echo "Downloading..."
curl https://nodeload.github.com/royans/ec2_chromeos_openvpn/zip/master > m.zip 2> /dev/null
rm -rf ec2_chromeos_openvpn-master 2> /dev/null
unzip m.zip
rm m.zip
cd ec2_chromeos_openvpn-master/
./setup.sh $1
cd ..
rm -rf ec2_chromeos_openvpn-master
