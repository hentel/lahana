#!/bin/sh

cat >> /etc/apt/sources.list <<EOF
deb     http://deb.torproject.org/torproject.org precise main
deb     http://deb.torproject.org/torproject.org experimental-precise main
EOF

gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
sudo apt-get update
sudo apt-get install tor deb.torproject.org-keyring obfsproxy
sudo apt-get upgrade -y
sudo apt-get install openswan xl2tpd ppp -y
sudo cp ./xlt.sh /etc/xlt.sh
echo "Switching to /etc/xlt.sh"
sudo /etc/xlt.sh
