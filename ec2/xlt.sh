#!/bin/bash

source $HOME/lahana-master/ec2/config.sh

# Those two variables will be found automatically
# If you're not using EC2 create a private interface in
# /etc/network/interfaces and use that for the PRIVATE_IP, and your public
# IP address for PUBLIC_IP
PRIVATE_IP=`wget -q -O - 'http://instance-data/latest/meta-data/local-ipv4'`
PUBLIC_IP=`wget -q -O - 'http://instance-data/latest/meta-data/public-ipv4'`

cat > /etc/ipsec.conf <<EOF
version 2.0

config setup
 dumpdir=/var/run/pluto/
 nat_traversal=yes
 virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:25.0.0.0/8,%v6:fd00::/8,%v6:fe80::/10
 oe=off
 protostack=netkey
 nhelpers=0
 interfaces=%defaultroute

conn vpnpsk
 auto=add
 left=$PRIVATE_IP
 leftid=$PUBLIC_IP
 leftsubnet=$PRIVATE_IP/32
 leftnexthop=%defaultroute
 leftprotoport=17/1701
 rightprotoport=17/%any
 right=%any
 rightsubnetwithin=0.0.0.0/0
 rightsubnet=vhost:%no,%priv
 forceencaps=yes
 authby=secret
 pfs=no
 type=transport
 auth=esp
 ike=3des-sha1
 phase2alg=3des-sha1
 dpddelay=30
 dpdtimeout=120
 dpdaction=clear
EOF

cat > /etc/ipsec.secrets <<EOF
$PUBLIC_IP %any : PSK "$IPSEC_PSK"
EOF

cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
port = 1701

;debug avp = yes
;debug network = yes
;debug state = yes
;debug tunnel = yes

[lns default]
ip range = 192.168.42.10-192.168.42.250
local ip = 192.168.42.1
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
;ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

cat > /etc/ppp/options.xl2tpd <<EOF
ipcp-accept-local
ipcp-accept-remote
ms-dns $PRIVATE_IP
noccp
auth
crtscts
idle 1800
mtu 1280
mru 1280
lock
connect-delay 5000
EOF

cat > /etc/ppp/chap-secrets <<EOF
# Secrets for authentication using CHAP
# client server secret IP addresses

$VPN_USER l2tpd $VPN_PASSWORD *
EOF

iptables -t nat -A POSTROUTING -s 192.168.42.0/24 -o eth0 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables-save > /etc/iptables.rules

cat > /etc/network/if-pre-up.d/iptablesload <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.rules
echo 1 > /proc/sys/net/ipv4/ip_forward
exit 0
EOF

# Tor kludge. Ugly I know but it works.
cat > /etc/ppp/ip-down.d/00tor <<EOF
#! /bin/sh
#
# 00tor - Removes vpn cruft on connection teardown

PPP_IFACE=\$1

TRANS_PORT="9040"

iptables -t nat -D PREROUTING -i \$PPP_IFACE -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -D PREROUTING -i \$PPP_IFACE -p tcp --syn -j REDIRECT --to-ports \$TRANS_PORT

logger Rules cleaned for \$PPP_IFACE
EOF

chmod 755 /etc/ppp/ip-down.d/00tor

cat > /etc/ppp/ip-up.d/00tor <<EOF
#!/bin/sh
#
# Check if tor's alive, otherwise restart it
#

PPP_IFACE=\$1

if [ ! "\$(pidof tor)" ]
then
	logger Tor dead, restarting for \$PPP_IFACE
	/etc/init.d/tor restart
else
	logger Tor alive, no need to restart for \$PPP_IFACE
fi

TRANS_PORT="9040"

iptables -t nat -A PREROUTING -i \$PPP_IFACE -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i \$PPP_IFACE -p tcp --syn -j REDIRECT --to-ports \$TRANS_PORT
EOF

chmod 755 /etc/ppp/ip-up.d/00tor

# Sort out DNS
#perl -pi.bak -e 's/#prepend domain-name-servers 127.0.0.1;/prepend domain-name-servers 127.0.0.1;/' /etc/dhcp/dhclient.conf
#perl -pi.bak -e 's/domain-name-servers,//' /etc/dhcp/dhclient.conf

# Configure Tor

cat >> /etc/tor/torrc <<EOF
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 53
DNSListenAddress 192.168.42.1
DNSListenAddress 127.0.0.1
TransListenAddress 127.0.0.1
TransListenAddress 192.168.42.1
SocksPort 0
ORPort 443 # or some other port if you already run a webserver/skype
BridgeRelay 1
Exitpolicy reject *:*

## CHANGEME_1 -> provide a nickname for your bridge, can be anything you like
Nickname lahana
## CHANGEME_2 -> provide some email address so we can contact you if there's a problem
ContactInfo devnull@lahana.localhost

ServerTransportPlugin obfs2,obfs3 exec /usr/bin/obfsproxy managed
EOF

# A restart isn't necessary, but a clean boot proves everything works in
# Case you need to shut down for now and start again later
shutdown -r now
