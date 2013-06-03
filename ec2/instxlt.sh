#!/bin/sh

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install tor openswan xl2tpd ppp -y
sudo cp ./xlt.sh /etc/xlt.sh
echo "Switching to /etc/xlt.sh"
sudo /etc/xlt.sh
