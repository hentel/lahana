#!/bin/bash

cd ~/lahana-master
cat >> /etc/apt/sources.list.d/tor.list <<EOF
deb     http://deb.torproject.org/torproject.org precise main
EOF
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
apt-get update
apt-get install tor deb.torproject.org-keyring obfsproxy -y
apt-get upgrade -y
apt-get install openswan xl2tpd ppp -y
cp ~/lahana-master/ec2/xlt.sh /etc/xlt.sh
echo "Switching to /etc/xlt.sh"
/etc/xlt.sh
