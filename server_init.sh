#!/bin/bash
# royans@gmail.com - Mar 2013


echo "Update the OS"
yum -y update 2> /dev/null > /dev/null
echo "Install openvpn"
yum -y install openvpn 2> /dev/null > /dev/null
echo "Install mailx"
yum -y install mailx 2> /dev/null > /dev/null
echo "Install wget"
yum -y install wget 2> /dev/null > /dev/null
 
mkdir -p $TMPDIR

pushd `pwd`
cd $TMPDIR
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
unzip master
mkdir -p /etc/openvpn/easy-rsa/
cp -rp easy-rsa-master/easy-rsa/2.0/* /etc/openvpn/easy-rsa/
rm -rf master
popd 

