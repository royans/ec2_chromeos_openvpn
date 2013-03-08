#!/bin/bash
# royans@gmail.com - Mar 2013


cd /etc/openvpn/easy-rsa/
source vars
source $ME/vars.sh

if [ "$1" == "" ]
then
  echo "Usage: ./openvpn_config.sh <email@address>"
  echo "       - The email address should belong to the user who needs to get the onc certificate."
  echo "       - For example: ./openvpn_config.sh test@blogofy.com"
  echo ""
  exit 1
fi
export KEY_EMAIL=$1


echo "Cleanup old stuff"
./clean-all

echo "Build DH"
./build-dh

echo "Create CA key/certificate"
./pkitool --initca 

echo "Create Server key/certificate"
./pkitool --server server 

echo "For each client, create key/certificate. We are just going to do for one"
./build-key-pkcs12 --pkcs12 $clientname

echo "Some of the following key manipulation suggessions were from Ralph Stebner"
echo "Create x509 client certificate in .PEM format"
openssl x509 -in /etc/openvpn/easy-rsa/keys/$clientname.crt -out /etc/openvpn/easy-rsa/keys/$clientname.pem -outform PEM

echo "Export the client cert in PKCS12 format"
openssl pkcs12 -export -in /etc/openvpn/easy-rsa/keys/$clientname.pem -inkey /etc/openvpn/easy-rsa/keys/$clientname.key -out /etc/openvpn/easy-rsa/keys/$clientname.p12

echo "And then base64 encode it to create a .p12.enc file"
openssl enc -e -base64 -in /etc/openvpn/easy-rsa/keys/$clientname.p12 -out /etc/openvpn/easy-rsa/keys/$clientname.p12.enc

echo "Prepare client cert to be embedded"
cat /etc/openvpn/easy-rsa/keys/$clientname.p12.enc | sed -e '1 s/^/"/' -e '$ s/$/"/' | tr -d '\n' > /etc/openvpn/easy-rsa/keys/$clientname.pasteme

echo "Prepare CA cert to be embedded"
cat /etc/openvpn/easy-rsa/keys/ca.crt |  sed -e '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ !d' -e '1,1 d' -e '$ d' | sed -e '1 s/^/"-----BEGIN CERTIFICATE-----/' -e '$ s/$/-----END CERTIFICATE-----"/' | tr -d '\n' > /etc/openvpn/easy-rsa/keys/ca.pasteme

echo "Prepare server cert to be embedded"
cat /etc/openvpn/easy-rsa/keys/server.crt | sed -e '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ !d' -e '1,1 d' -e '$ d' | sed -e '1 s/^/"-----BEGIN CERTIFICATE-----/' -e '$ s/$/-----END CERTIFICATE-----"/' | tr -d '\n' > /etc/openvpn/easy-rsa/keys/server.pasteme

# Create a server.conf file
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key

# This file should be kept secret
dh /etc/openvpn/easy-rsa/keys/dh$KEY_SIZE.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
persist-key
persist-tun
status openvpn-status.log/proc/sys/net/ipv4/ip_forward
verb 6
#plugin /usr/lib/openvpn/plugin/lib/openvpn-auth-pam.so login
#client-cert-not-required
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
comp-lzo
EOF

#Start the service
/etc/init.d/openvpn start

#Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

#Setup iptable to make masqurading work
IP=`ifconfig eth0 | grep 'inet addr' | awk '{print $2}' | cut -d':' -f2`
iptables -F; iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to $IP


MYIP=`wget -qO-  https://toolbox.googleapps.com/apps/browserinfo/info/ | grep remoteAddr | cut -d'"' -f4`

cat>/etc/openvpn/easy-rsa/keys/dummy.onc<<EOF
{
"Type": "UnencryptedConfiguration",
"NetworkConfigurations": [
        {
        "GUID": "{vpn4us$STAMP}",
        "Name": "VPN Conn $STAMP",
        "Type": "VPN",
        "VPN": {
                "Type": "OpenVPN",
                "Host": "$MYIP",
                "OpenVPN":
                        {
                        "Auth": "SHA1",
                        "ClientCertType": "Ref",
                        "CompLZO": "true",
                        "Cipher": "BF-CBC",
                        "NsCertType": "server",
                        "Port": 1194,
                        "Proto": "udp",
                        "Username": "$SHELL_USER",
                        "Password": "$SHELL_PASS",
                        "SaveCredentials": true,
                        "ServerCertRef": "{servercert}",
                        "ServerCARef": "{cacert}",
                        "ClientCertRef": "{clientcert}",
                        "Verb": "3",
                        "ServerPollTimeout": 360
                        },
                }
        }
        ],
"Certificates": [
{
"GUID": "{servercert}",
"Type": "Server",
"X509": 
"---GATEWAY-CERT---"
},
{
"GUID": "{cacert}",
"Type": "Authority",
"X509":
"---CA-CERT---"
},
{
"GUID": "{clientcert}",
"Type": "Client",
"PKCS12": 
"---CLIENT-CERT---"
}
]
}
EOF


sed -e '/---CA-CERT---/ {
        r /etc/openvpn/easy-rsa/keys/ca.pasteme
        d
}' -e '/---GATEWAY-CERT---/ {
        r /etc/openvpn/easy-rsa/keys/server.pasteme
        d
}' -e '/---CLIENT-CERT---/{
        r /etc/openvpn/easy-rsa/keys/'"$clientname"'.pasteme
        d
}'</etc/openvpn/easy-rsa/keys/dummy.onc >/etc/openvpn/easy-rsa/keys/$clientname.onc


echo "Mailing onc file to $KEY_EMAIL"
mail -s "ONC file" -a /etc/openvpn/easy-rsa/keys/$clientname.onc $KEY_EMAIL<<EOF
.
EOF

