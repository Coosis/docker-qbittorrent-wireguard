# What's this:
A fork of linuxserver/docker-qbittorrent, adding Wireguard configuration.
This is originally made to route traffic from qbittorrent through a vps, 
to solve the problem of torrenting behind CORP-NAT/Double-NAT/etc.

# Wording:
Those words are used interchangeably:
server - vps
client - your machine - qbittorrent client - container host machine

# Get started:
1. Clone this repo.
2. ssh into the server, and install Wireguard.
3. Generate (at least 2, one for server, one for client) wireguard keypairs:
e.g.:
```bash
wg genkey | tee privatekey | wg pubkey > publickey
```
4. Fill the keys:
- For server:
    - Put the server's private key in `wg0.conf`
    - Put the server's public key in `compose.yaml`
- For client:
    - Put the client's private key in `compose.yaml`
    - Put the client's public key in `wg0.conf`
5. Fill the server's endpoint in `compose.yaml`:
First you can choose any unused port for your server in the wg0.conf file, 
under `[Interface]` section, the `ListenPort` field.
Then you fill out the endpoint. This is usually the server's public ip given by your vps provider, and the port you just chose.
6. Create wg0.conf on server:
You can move the file, or just create it.
e.g. (using vi):
```bash
vi /etc/wireguard/wg0.conf
```
7. Start Wireguard on server:
```bash
wg-quick up wg0
```
8. Start the container on client:
```bash
cd docker-qbittorrent-wireguard
docker-compose up
```
9. Visit the webpage in the output, default username and password are also there.
Once you logged in successfully, change the password.
10. Dry-run the container:
```bash
docker-compose down
docker-compose up -d
```
11. Now you can just start torrenting via the WebUI! You can check the status of the container using your container runtime. I am using podman, so I use `podman ps` to check the status of the container.

# Note:
You can always change the compose file to set desired ports, volumes, etc.
You can also alter the Wireguard config at both ./root/runentry.sh and ./wg0.conf.
Default WebUI port is 8080.
