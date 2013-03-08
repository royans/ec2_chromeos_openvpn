
ec2_chromeos_openvpn
====================
The goal of this bunch of scripts is to 
* Make it very very easy to launch and amazon EC2 instance with openvpn server which you could use from chromebook.  
* This is a highly recommended way to browse internet from locations you don't trust (coffee shops, hotels, airports, etc).  
* Instead of keeping EC2 instance always running, this script allows you to setup an openvpn server in a few seconds after an EC2 instance is launched. 
* It mail you an "onc" (OpenNetworkConfiguration file is configuration format used by ChromeOS) file which you could import into chromebook to quickly go online.

How to - slightly longer
========================

This script is specifically written for amazons EC2 instance using amazons linux distribution

* Step 1: Boot up instance and pull these files in
* Step 2: Update vars.sh
* Step 3: Run setup.sh
* Step 4: The email address you setup in vars.sh should get an email with the onc file which you should be able to import into chromebooks.

Really quick
============

```
curl https://raw.github.com/royans/ec2_chromeos_openvpn/master/quicksetup.sh > quicksetup.sh; 
chmod +x quicksetup.sh;
./quicksetup.sh email_address@blogofy.com
```

Notes
=====

* This is the bare minimum configuration. There are a lot of things you could improve.
   + Enable PAM based login if you want to do password checks. This would be very helpful if you want to share this ONC file with multiple users.
   + However, if you do have multiple users, you should create a unique client cert for everyone.

* TLS-auth is disabled currently. I couldn't figure out how to enable it yet... I know it works, but its not there yet.

* I picked Amazon's EC2 instance with Amazon's distribution because thats the cheapest and most stable distribution on that platform (my personal opinion)
   + The scripts could be adapted to other platforms as well. Few things to think about
     - package manager may be different. 
     - I parse output from a few binaries to do things automatically... u may have to test them to make sure format changes don't break the script.

* This set of scripts is available on github. Please feel free to fork this and send me back changes which I could incorporate into this.

