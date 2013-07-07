lahana
======

Lahana - building cabbage routers (VPN -> Tor bridges) on a brassic budget.

Overview
========

Lahana is a set of scripts to turn a Free Tier EC2 instance into a cabbage router (a VPN -> Tor bridge). The goal of Lahana is to bypass filtering by behaving like business traffic.

Lahana consists of a node (server) and clients. The architecture of Lahana is designed specifically to support as wide an array of devices as possible. The VPN is not secure, especially if you publish the details (which is encouraged). As such, Lahana **does not intend to provide secrecy**.

The Tor link tunnels all outbound TCP and DNS traffic over Tor but *not* ICMP or other UDP traffic. This means that while you have full TCP access for things like XMPP over tor, you need to make sure the protocol you use is supported.

The purpose of the Tor link is not to provide bulletproof anonymity but to make it harder to identify the VPN server from a destination or on exit from Tor.

Use Cases
=========

Mustafa wants to access youtube but it's blocked in his country. This will not do. Mustafa creates an EC2 node and deploys Lahana. He then connects to Lahana and can finally watch the highlights of the lakers game on youtube.

Later Mustafa wants to post a controversial opinion on a forum inside his country. Mustafa uses the Lahana connection and posts his views after making sure his browser is secure, and the ministry of the interior can only track his connection back to Tor, not the the EC2 instance in Ireland and as such can't block the EC2 instance.

Sebnem is a journalist. She wants to discuss womens rights in rural areas but knows women will be told not to talk to her if she comes to their villages. The women are worried about being identified by their husbands in case they're accused of saying something embarrassing about them. Sebnem sets up a hidden service on Tor and sends mifi hotspots preconfigured to connect to the Lahana node she's deployed to each of the villages she's arranged to have discussions. The women meet up in each village and use a laptop or mobile connected to the hotspot to discuss their views without having to worry about their husbands finding they've installed any software, and without Sebnem knowing who referred to whom.

Cengiz works in a computer shop. To get more people buying from him instead of Amazon, Cengiz sets up Lahana nodes and provides access from the routers he sells for a small additional monthly free. This lets non-technical people bypass restrictions to block sites. Nice one Cengiz.

Ali is a farmer with a big family. His youngest boy, Selim is going to university in England. Selim configures Ali's home router to use a Lahana node and because he's worried about privacy sets up a Tor hidden service for his family to post pictures back home, for him to post pictures from university and so on. Because all Ali needs to do is click on a bookmark he can stay in touch with his son. Selim knows that because neither the Lahana node nor hidden service are advertised that it's unlikely that anyone will ever get access to the site or the contents. To be sure, Selim locks down the site with a username and password. Great job, Selim.

Installing
==========

The full guide is at http://lahana.dreamcats.org/, but the basic steps are:

1. Launch an Ubuntu 12.04.2 LTS 64-bit micro instance on EC2.
2. Choose a username, password and secret.
3. Configure the security group to let TCP, UDP and ICMP in.
4. Execute the following command, replacing VPN_USER, VPN_PASSWORD and IPSEC_PSK with your preferred values:
	curl -sS https://raw.github.com/stevelord/lahana/master/ec2/go | sh -s VPN_USER VPN_PASSWORD IPSEC_PSK
5. Hit return on both popups that come up and wait for the reboot.
6. Connect via your favourite ipsec/l2tp VPN client.

Problems?
=========

Lahana is provided as is, but if you're really stuck, you can ping me on twitter via @stevelord and I'll help when I can.
