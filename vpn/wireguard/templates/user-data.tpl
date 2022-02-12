#!/bin/bash -v
# apt update && apt upgrade -y

apt install -y wireguard net-tools

echo '[Interface]
Address = ${wg_server_net}
PrivateKey = ${wg_server_private_key}
ListenPort = ${wg_server_port}
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ${wg_server_interface} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ${wg_server_interface} -j MASQUERADE

${peers}
' > /etc/wireguard/wg0.conf

chown -R root:root /etc/wireguard/
chmod -R 600 /etc/wireguard/*

sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p
ufw allow ssh
ufw allow ${wg_server_port}/udp
ufw --force enable

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service