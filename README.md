# What's this:
A fork of linuxserver/docker-qbittorrent, adding Wireguard configuration.
This is originally made to route traffic from qbittorrent through a vps, 
to solve the problem of torrenting behind CORP-NAT/Double-NAT/etc.

# Wording:
Those words are used interchangeably:
server - vps
client - your machine - container host machine
container - qbittorrent container

# Get started:
1. Clone this repo.

2. ssh into the server, and install Wireguard.

3. Generate (at least 3, one for server, one for client, one for container) wireguard keypairs:
e.g.:
```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

4. Fill the keys(basically make server and container know each other):
- For server:
    - Put the server's private key in `wg0.conf`
    - Put the server's public key in `compose.yaml`
- For container:
    - Put the container's private key in `compose.yaml`
    - Put the container's public key in `wg0.conf`

5. Fill the server's endpoint in `compose.yaml`:
First you can choose any unused port for your server in the wg0.conf file, 
under `[Interface]` section, the `ListenPort` field.
Then you fill out the endpoint. This is usually the server's public ip given by your vps provider, and the port you just chose.

6. Create wg0.conf on server:
Remember to put host's public key in the `[Peer]` section of wg0.conf for the server.
You can move the file, or just create it.
e.g. (using vi):
```bash
vi /etc/wireguard/wg0.conf
```

7. Start Wireguard on server:
```bash
wg-quick up wg0
```

8. Adding port forwarding on server:
```bash
vi /etc/sysctl.conf

net.ipv4.ip_forward=1
```
Then:
```bash
sysctl -p
sudo iptables -t nat -A PREROUTING -i wg0 -p tcp --dport 8080 -j DNAT --to-destination 11.0.0.2:8080
sudo iptables -A FORWARD -p tcp -d 11.0.0.2 --dport 8080 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
```

9. Start the container on host machine:
```bash
cd docker-qbittorrent-wireguard
docker-compose build --no-cache
docker-compose up
```

10. Configure host machine(basically make host machine know the server):
```bash
vi /etc/wireguard/wg0.conf

[Interface]
PrivateKey = host's private key
Address = 11.0.0.3/24

[Peer]
PublicKey = server's public key
Endpoint = server's public ip:server's port
AllowedIPs = 11.0.0.0/24
PersistentKeepalive = 25
```

11. Start Wireguard on host machine:
```bash
wg-quick up wg0
```

12. Visit http://11.0.0.1:8080/ default username and password can be found in compose session.
Once you logged in successfully, change the password.

13. Dry-run the container:
```bash
docker-compose down
docker-compose up -d
```

14. Now you can just access webui from another machine! You can check the status of the container using your container runtime. I am using podman, so I use `podman ps` to check the status of the container.

# Note:
You can always change the compose file to set desired ports, volumes, etc.
You can also alter the Wireguard config at both ./root/runentry.sh and ./wg0.conf.
Default WebUI port is 8080.
