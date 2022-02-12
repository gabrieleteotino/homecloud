[Interface]
Address = ${peer_ip}
PrivateKey = ${peer_priv_key}
DNS = 1.1.1.1

[Peer]
PublicKey = ${wg_server_pub_key}
Endpoint = ${wg_server_public_ip}:${wg_server_port}
AllowedIPs = 0.0.0.0/0, ::/0