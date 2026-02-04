# MaxCoin Node Setup on Oracle Cloud Free Tier

## 1. Create Oracle Cloud Account

1. Go to https://www.oracle.com/cloud/free/
2. Sign up (requires credit card for verification, but won't be charged)
3. Select your home region (choose one close to you)

## 2. Create a Free Tier VM

1. Go to **Compute → Instances → Create Instance**
2. Choose:
   - **Shape**: VM.Standard.E2.1.Micro (AMD) - Always Free
   - **Image**: Ubuntu 22.04
   - **Boot volume**: 50GB (free)
3. Download your SSH key
4. Click **Create**

## 3. Reserve a Static (Public) IP

1. Go to **Networking → IP Management → Reserved Public IPs**
2. Click **Reserve Public IP Address**
3. Assign it to your instance's VNIC

## 4. Configure Firewall

### Oracle Cloud Console (Security List):
1. Go to **Networking → Virtual Cloud Networks**
2. Click your VCN → Security Lists → Default Security List
3. Add **Ingress Rule**:
   - Source: `0.0.0.0/0`
   - Protocol: TCP
   - Destination Port: `8668`

### On the VM (iptables):
```bash
sudo iptables -I INPUT -p tcp --dport 8668 -j ACCEPT
sudo netfilter-persistent save
```

## 5. Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install build dependencies
sudo apt install -y build-essential libssl-dev libboost-all-dev \
    libdb-dev libdb++-dev git

# Install from release or build from source
cd ~
git clone https://github.com/carlosdias1975now-code/maxcoin.git
cd maxcoin/src

# Build LevelDB
cd leveldb && make libleveldb.a libmemenv.a && cd ..

# Build Crypto++
cd cryptopp && make libcryptopp.a && cd ..

# Build daemon
make -f makefile.unix USE_UPNP=-
```

## 6. Configure MaxCoin

```bash
mkdir -p ~/.maxcoin
cat > ~/.maxcoin/maxcoin.conf << 'EOF'
# MaxCoin Node Configuration
server=1
daemon=1
rpcuser=maxcoinrpc
rpcpassword=CHANGE_THIS_TO_A_STRONG_PASSWORD
rpcallowip=127.0.0.1

# Accept incoming connections
listen=1
maxconnections=50

# Logging
debug=0
printtoconsole=0
EOF
```

## 7. Run the Daemon

```bash
# Start the daemon
./maxcoind -daemon

# Check status
./maxcoind getinfo

# Check peer connections
./maxcoind getpeerinfo
```

## 8. Set Up as System Service

```bash
sudo tee /etc/systemd/system/maxcoind.service << 'EOF'
[Unit]
Description=MaxCoin Daemon
After=network.target

[Service]
User=ubuntu
ExecStart=/home/ubuntu/maxcoin/src/maxcoind -daemon=0
ExecStop=/home/ubuntu/maxcoin/src/maxcoind stop
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable maxcoind
sudo systemctl start maxcoind
```

## 9. Get Your Node's IP for Wallet Configuration

```bash
# Your public IP
curl -s ifconfig.me
```

## 10. Convert IP to Hex for pnSeed

```bash
# Example: If your IP is 129.146.123.45
python3 -c "
import struct
ip = '129.146.123.45'  # Replace with your IP
parts = [int(p) for p in ip.split('.')]
hex_val = struct.unpack('<I', bytes(parts))[0]
print(f'Your IP: {ip}')
print(f'Hex for pnSeed[]: 0x{hex_val:08x}')
"
```

---

## Alternative: DNS Seed Setup

If you want DNS-based seeding (more flexible):

### Using Cloudflare DNS (Free):
1. Register a domain (Namecheap, Porkbun ~$10/year)
2. Use Cloudflare for DNS (free)
3. Create A records:
   ```
   seed1.yourdomain.com → Your Oracle IP
   seed2.yourdomain.com → Another node IP (if you have one)
   ```

### Update src/net.cpp:
```cpp
static const char *strMainNetDNSSeed[][3] = {
    {"Primary Seed", "seed1.yourdomain.com"},
    {"Backup Seed", "seed2.yourdomain.com"},
    {NULL, NULL}
};
```

---

## Monitoring

Check your node is accepting connections:
```bash
# From another machine
nc -zv YOUR_IP 8668

# On the node
./maxcoind getconnectioncount
./maxcoind getpeerinfo
```
