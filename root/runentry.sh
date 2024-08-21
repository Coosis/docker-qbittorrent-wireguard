#!/bin/sh

CLIENT_PRIVATE_KEY=${CLIENT_PRIVATE_KEY:-"<pass-client-private-key-to-env>"}
DNS=${DNS:-"1.1.1.1, 8.8.8.8"}
SERVER_PUBKEY=${SERVER_PUBKEY:-"<pass-server-public-key-to-env>"}
ENDPOINT=${ENDPOINT:-"<pass-server-endpoint-to-env>"}

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 11.0.0.2/32
DNS = $DNS

[Peer]
PublicKey = $SERVER_PUBKEY
AllowedIPs = ::/0, 0.0.0.0/0
Endpoint = $ENDPOINT
PersistentKeepalive = 25
EOF

# AllowedIPs = 0.0.0.0/0, ::/0
# exclude localhost from proxy
wg-quick up wg0

# Run qbittorrent-nox
qbittorrent-nox --webui-port=8080
