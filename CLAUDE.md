# CLAUDE.md - Maxcoin Wallet Development Guide

This document provides comprehensive documentation for developing and maintaining the Maxcoin cryptocurrency wallet. It is designed to help Claude (and human developers) understand the codebase structure, build process, and development workflow.

---

## ⚠️ CRITICAL: Network Status (February 2026)

**THE MAXCOIN NETWORK IS CURRENTLY DOWN**

| Issue | Status |
|-------|--------|
| **Seed Nodes** | All offline (5+ days) |
| **maxcoinproject.net** | 502 Bad Gateway |
| **Exchange Trading** | Stopped 12+ days ago |
| **Block Explorer** | Unreachable |

**Known Dead Nodes:**
- `143.198.129.217:8668` - last seen 138+ hours ago
- `46.101.98.56:8668` - last seen 115+ hours ago
- `104.234.220.135:8668` - never responded

**To Recover:**
1. Need bootstrap.dat or blockchain data from someone with synced node
2. Check Wayback Machine: `https://web.archive.org/web/*/maxcoinproject.net/wallets/`
3. Contact community: [@getmaxcoin on X](https://x.com/getmaxcoin)
4. Post on [BitcoinTalk MaxCoin thread](https://bitcointalk.org/index.php?topic=438150.0)

**User has 6,000,000 MAX (~$10,200 at $0.0017/coin) that cannot be accessed until network recovers.**

---

## Quick Reference

| Item | Value |
|------|-------|
| **Version** | 0.9.4.1 |
| **Base** | Bitcoin 0.8.5 fork via Blakecoin |
| **Language** | C++ (91%), C (4%), Qt for GUI |
| **License** | MIT |
| **Last Updated** | February 2026 |
| **GitHub Release** | [v1.0.0-apple-silicon](https://github.com/carlosdias1975now-code/maxcoin/releases/tag/v1.0.0-apple-silicon) |

---

## ✅ macOS Apple Silicon Build (COMPLETED)

Both daemon and Qt wallet compile successfully on macOS Apple Silicon (M1/M2/M3/M4).

### Compile Scripts

| Script | Purpose |
|--------|---------|
| `maxcoin-wallet-compile.command` | Builds maxcoind daemon |
| `maxcoin-qt-wallet-compile.command` | Builds MaxCoin-Qt.app |

Double-click either script in Finder to compile.

### Manual Build Commands

**Daemon:**
```bash
cd src
make -f makefile.osx USE_UPNP=-
```

**Qt Wallet:**
```bash
/opt/homebrew/opt/qt@5/bin/qmake "USE_UPNP=-" maxcoin-qt.pro
make -j$(sysctl -n hw.ncpu)
```

### Dependencies (Homebrew)
```bash
brew install boost openssl@3 berkeley-db@4 qt@5
```

### Key Fixes Applied

| File | Fix |
|------|-----|
| `src/bignum.h` | OpenSSL 3.x opaque BIGNUM/BN_CTX |
| `src/crypter.cpp` | EVP_CIPHER_CTX API changes |
| `src/net.cpp` | `io_service` → `io_context` |
| `src/util.cpp` | `is_complete()` → `is_absolute()` |
| `src/walletdb.cpp` | `copy_option` → `copy_options` |
| `src/makefile.osx` | Apple Silicon Homebrew paths |
| `maxcoin-qt.pro` | Qt5 ARM64 paths, C++14, quoted paths |
| `src/qt/clientmodel.cpp` | `using namespace boost::placeholders` |
| `src/qt/walletmodel.cpp` | `using namespace boost::placeholders` |

### Data Directory
```
~/Library/Application Support/MaxCoin/
├── maxcoin.conf      # Configuration
├── wallet.dat        # Wallet (BACKUP THIS!)
├── blocks/           # Blockchain data
├── chainstate/       # UTXO database
├── peers.dat         # Known peers
└── debug.log         # Debug output
```

---

## IMPORTANT: Build Path Symlink

**The project files are stored in iCloud which contains spaces in the path.** Makefiles don't handle spaces well, so a symlink is used for building.

### Symlink Setup (REQUIRED for building)

```bash
# Create symlink (only needed once)
ln -s "/Users/admin/Library/Mobile Documents/com~apple~CloudDocs/claude-workspaces/maxcoin-dev/maxcoin-wallet-fork/maxcoin" ~/maxcoin-build
```

### Paths

| Purpose | Path |
|---------|------|
| **Actual files (iCloud)** | `/Users/admin/Library/Mobile Documents/com~apple~CloudDocs/claude-workspaces/maxcoin-dev/maxcoin-wallet-fork/maxcoin` |
| **Build symlink** | `~/maxcoin-build` |
| **Always use for building** | `~/maxcoin-build/src` |

### Why This Matters
- The iCloud path contains "Mobile Documents" (has a space)
- Make splits paths on spaces, breaking include paths
- The symlink provides a space-free path that points to the same files
- **Always build from `~/maxcoin-build`, never from the iCloud path directly**

---

## Project Overview

Maxcoin is a cryptocurrency introduced in 2014 with several notable technical differences from Bitcoin:

### Cryptographic Differences

| Feature | Bitcoin | Maxcoin |
|---------|---------|---------|
| Hashing | SHA-256 | SHA-3 Keccak |
| Signatures | ECDSA | Schnorr |
| Elliptic Curve | secp256k1 | secp256r1 (NIST P-256) |
| Public Key | Optional for verification | Required for verification |

### Network Parameters

```
Max Supply:        ~100,000,000 coins (106,058,400 exactly)
Block Reward:      8 coins (halving every 4 years)
Block Time:        60 seconds
Coinbase Maturity: 120 blocks
Max Block Size:    1,000,000 bytes
```

### Hard Fork Block Heights
- Fork 1: Block 140,000
- Fork 2: Block 177,500
- Fork 3: Block 600,000
- Fork 4: Block 635,000

---

## Directory Structure

```
maxcoin-master/
├── src/                    # Main source code
│   ├── qt/                 # Qt GUI implementation
│   │   ├── forms/          # Qt Designer .ui files
│   │   ├── locale/         # Translation files
│   │   └── res/            # Resources (icons, images)
│   ├── cryptopp/           # Crypto++ library (bundled)
│   ├── leveldb/            # LevelDB database (bundled)
│   ├── json/               # JSON Spirit library
│   ├── test/               # Unit tests
│   ├── obj/                # Compiled objects (generated)
│   └── obj-test/           # Test objects (generated)
├── doc/                    # Documentation
├── contrib/                # Contribution scripts
├── share/                  # Shared resources
│   ├── genbuild.sh         # Build info generator
│   └── qt/                 # Qt-specific resources
├── img/                    # Images (logo)
├── maxcoin-qt.pro          # Qt project file (GUI build)
├── maxcoin-EXAMPLE.conf    # Example configuration
├── COPYING                 # MIT License
├── INSTALL                 # Basic install notes
└── README.md               # Project readme
```

---

## Key Source Files

### Core Blockchain

| File | Purpose | Size |
|------|---------|------|
| `main.cpp` | Block validation, chain management, consensus rules | 178 KB |
| `main.h` | Core constants, class declarations | 71 KB |
| `net.cpp` | P2P networking, node communication | 57 KB |
| `script.cpp` | Transaction scripting (Bitcoin Script variant) | 63 KB |

### Maxcoin-Specific

| File | Purpose |
|------|---------|
| `schnorr.cpp/h` | Schnorr signature implementation using Crypto++ |
| `keccak.c` | SHA-3/Keccak hashing implementation |
| `sph_keccak.h` | Keccak header definitions |
| `key.cpp/h` | Key generation using secp256r1 curve |

### Wallet

| File | Purpose |
|------|---------|
| `wallet.cpp/h` | Wallet management, key storage, transactions |
| `walletdb.cpp/h` | Wallet database persistence |
| `crypter.cpp/h` | Wallet encryption |
| `keystore.cpp/h` | Key management interface |

### RPC Interface

| File | Purpose |
|------|---------|
| `bitcoinrpc.cpp/h` | RPC server implementation |
| `rpcwallet.cpp` | Wallet RPC commands |
| `rpcblockchain.cpp` | Blockchain RPC commands |
| `rpcmining.cpp` | Mining RPC commands |
| `rpcnet.cpp` | Network RPC commands |
| `rpcdump.cpp` | Key import/export |
| `rpcrawtransaction.cpp` | Raw transaction handling |

### Qt GUI

| File | Purpose |
|------|---------|
| `qt/bitcoin.cpp` | Application entry point |
| `qt/bitcoingui.cpp/h` | Main window |
| `qt/walletmodel.cpp/h` | Wallet data model |
| `qt/sendcoinsdialog.cpp` | Send coins interface |
| `qt/miningpage.cpp` | Mining interface |
| `qt/overviewpage.cpp` | Dashboard overview |

---

## Build System

### Two Build Methods

1. **Makefile (Daemon only)**: `src/makefile.unix`
2. **qmake (GUI + Daemon)**: `maxcoin-qt.pro`

### Dependencies

```bash
# Ubuntu 18.04 (original target)
sudo apt install -y \
    git build-essential \
    libssl1.0-dev \           # OpenSSL 1.0 (DEPRECATED!)
    libboost-all-dev \        # Boost libraries
    libdb-dev libdb++-dev \   # Berkeley DB
    libminiupnpc-dev \        # UPnP support
    libqrencode-dev \         # QR code support
    libqt5gui5 libqt5core5a libqt5dbus5 \
    qttools5-dev qttools5-dev-tools \
    qt5-default               # Qt5 (DEPRECATED in Ubuntu 22.04+)
```

### Build Commands

**Daemon:**
```bash
cd src
make -f makefile.unix
# Output: maxcoind
```

**Qt GUI:**
```bash
qmake maxcoin-qt.pro
make
# Output: maxcoin-qt
```

### Build Artifacts

The build process generates:
- `src/cryptopp/libcryptopp.a` - Crypto++ static library
- `src/leveldb/libleveldb.a` - LevelDB static library
- `src/leveldb/libmemenv.a` - LevelDB memory environment
- `src/obj/*.o` - Object files
- `build/` - Qt MOC/UI generated files

---

## Known Issues

### Critical Bugs (from GitHub Issues)

1. **Issue #42 (2014)**: Multisig transactions cause crash
   - Location: Likely in `script.cpp` signature verification
   - Status: UNFIXED

2. **Issue #36 (2014)**: Large fee charged even when transaction > 0.01
   - Location: Fee calculation in `wallet.cpp`
   - Status: UNFIXED

3. **Issue #70 (2022)**: Version mismatch in Windows release
   - Status: Acknowledged

### Compilation Issues (Modern Systems)

1. **OpenSSL 1.0 Deprecated**
   - Ubuntu 22.04+ uses OpenSSL 3.x
   - Many API changes needed

2. **Qt5-default Removed**
   - Ubuntu 22.04+ removed `qt5-default`
   - Need explicit Qt version selection

3. **Boost Library Changes**
   - Newer Boost versions have breaking changes
   - Thread library suffix changes

4. **C++ Standard**
   - Code uses C++11 features
   - Some constructs deprecated in C++17/20

---

## Schnorr Signature Implementation

Located in `src/schnorr.cpp`:

```cpp
// Uses secp256r1 (NIST P-256) curve parameters
void LoadSECP256r1Curve(Integer& q, ECP& ec, ECPPoint& G)

// Key generation
void KeyGen(Integer& secretKey, Integer& publicKeyX, Integer& publicKeyY, AutoSeededRandomPool& rng)

// Signing: produces (e, s) pair
void Sign(Integer& sigE, Integer& sigS, const Integer& secretKey,
          const byte* message, int mlen, AutoSeededRandomPool& rng)

// Verification
bool Verify(const Integer& publicKeyX, const Integer& publicKeyY,
            const Integer& sigE, const Integer& sigS,
            const byte* message, int mlen)
```

**Key Points:**
- Uses Crypto++ library for elliptic curve operations
- Hash function: SHA-3 (Keccak-256)
- Signature format: (e, s) where e = H(M||r), s = k - secret*e

---

## Configuration

### Config File Location
- Linux: `~/.maxcoin/maxcoin.conf`
- Windows: `%APPDATA%\MaxCoin\maxcoin.conf`
- macOS: `~/Library/Application Support/MaxCoin/maxcoin.conf`

### Key Configuration Options (from maxcoin-EXAMPLE.conf)

```ini
# Network
rpcuser=maxcoinrpc
rpcpassword=<secure-password>
rpcport=8181
port=8668

# Mining
gen=0                    # Enable/disable mining
genproclimit=-1          # CPU threads for mining (-1 = all)

# Network Settings
listen=1                 # Accept connections
server=1                 # Enable RPC server
addnode=<ip>             # Add peer node

# Testnet
testnet=0                # Enable testnet mode
```

---

## RPC API Modifications

Maxcoin modifies these Bitcoin RPC commands:

```
verifymessage <publickey> <signature> <message>
    - Requires public key (Bitcoin uses address)

makekeypair [hex-encoded prefix]
    - Generates new keypair

dumppubkey <maxcoinaddress>
    - Exports public key for address
```

---

## Development Workflow

### Setting Up Development Environment

1. **Install Dependencies** (see Build System section)

2. **Clone Repository**
   ```bash
   git clone https://github.com/[your-fork]/maxcoin.git
   cd maxcoin
   ```

3. **First Build Attempt**
   ```bash
   cd src
   make -f makefile.unix 2>&1 | tee build.log
   ```

4. **Document Errors**
   - Save build.log for analysis
   - Categorize errors by type

### Making Changes

1. Create feature branch
2. Make changes in small, testable increments
3. Test compilation after each change
4. Run on testnet before mainnet

### Code Style

- Follow existing Bitcoin Core style
- 4-space indentation
- Braces on same line
- CamelCase for classes, lowercase_with_underscores for functions

---

## Modernization Roadmap

### Phase 1: Get It Compiling ✅ COMPLETED
- [x] Update OpenSSL 1.0 → 3.x API calls
- [x] Fix Boost 1.69+ compatibility (io_context, is_absolute, copy_options, header-only boost_system)
- [x] Update for C++14 (required for Crypto++)
- [x] macOS Apple Silicon (ARM64) support
- [x] Qt5 GUI compilation
- [x] Create compile scripts

### Phase 2: Network Recovery (CURRENT PRIORITY)
- [ ] Find active nodes or bootstrap.dat
- [ ] Sync blockchain
- [ ] Verify wallet access to 6M MAX
- [ ] Consider running own seed node

### Phase 3: Bug Fixes
- [ ] Fix multisig crash (Issue #42)
- [ ] Fix fee calculation (Issue #36)
- [ ] Review and fix any security issues

### Phase 4: Build System
- [ ] Migrate to CMake
- [ ] Add GitHub Actions CI/CD
- [ ] Create Docker build environment

### Phase 5: Modernization
- [ ] Update bundled libraries (Crypto++, LevelDB)
- [ ] Improve sync performance
- [ ] Add unit tests
- [ ] Consider GUI framework alternatives

### Phase 6: Features (Future)
- [ ] Enhanced scripting (timelocks, better multisig)
- [ ] Performance improvements
- [ ] Mobile wallet support
- [ ] Smart contracts (mentioned in original roadmap)

---

## Testing

### Testnet Mode

Enable in config:
```ini
testnet=1
```

Or via command line:
```bash
./maxcoind -testnet
```

### Unit Tests

```bash
cd src
make -f makefile.unix test_maxcoin
./test_maxcoin
```

---

## Security Considerations

### Cryptographic Components
- **DO NOT** modify cryptographic code without expert review
- Schnorr implementation in `schnorr.cpp` is security-critical
- Key generation in `key.cpp` must use proper randomness

### Wallet Security
- Wallet encryption uses AES-256-CBC
- Keys stored in Berkeley DB
- Never commit wallet.dat or private keys

### Network Security
- Validate all incoming network messages
- Check block and transaction validity
- Be cautious of DoS vectors

---

## Useful Commands

### Daemon
```bash
./maxcoind -daemon              # Start daemon
./maxcoind stop                 # Stop daemon
./maxcoind getinfo              # Get node info
./maxcoind getblockcount        # Current block height
./maxcoind getconnectioncount   # Number of peers
```

### Wallet
```bash
./maxcoind getnewaddress        # Generate new address
./maxcoind getbalance           # Check balance
./maxcoind listunspent          # List UTXOs
./maxcoind sendtoaddress <addr> <amount>
```

### Debug
```bash
./maxcoind -debug               # Enable debug logging
./maxcoind -printtoconsole      # Print to console
```

---

## Resources

### GitHub Repositories
- **This Fork**: https://github.com/carlosdias1975now-code/maxcoin
- **Release**: https://github.com/carlosdias1975now-code/maxcoin/releases/tag/v1.0.0-apple-silicon
- **Original Repo**: https://github.com/Max-Coin/maxcoin
- **Wiki**: https://github.com/Max-Coin/maxcoin/wiki
- **Bitcoin Reference**: https://github.com/bitcoin/bitcoin

### Community (for network recovery)
- **Twitter/X**: [@getmaxcoin](https://x.com/getmaxcoin)
- **BitcoinTalk**: [MaxCoin ANN Thread](https://bitcointalk.org/index.php?topic=438150.0)

### Network Info
- **Port**: 8668 (mainnet)
- **RPC Port**: 8669
- **Mining Algorithm**: Keccak (SHA-3)
- **Block Time**: 60 seconds

### Bootstrap Recovery
- Check Wayback Machine: `https://web.archive.org/web/*/maxcoinproject.net/wallets/`
- DNS Seeds (currently down):
  - `dnsseed.maxcoinhub.io`
  - `dnsseed.maxcoin.org.uk`
  - `node.maxcoinhub.io`

---

## Notes for Claude

When working on this codebase:

1. **Always check build output** - Compile after changes
2. **Preserve cryptographic correctness** - Don't modify crypto without understanding
3. **Test on testnet first** - Never test with real funds
4. **Document changes** - Update this file as needed
5. **Small commits** - Make incremental, testable changes
6. **Security first** - This handles real money
7. **Network is down** - Cannot sync until nodes found or bootstrap obtained

---

## Git Commits

| Commit | Description |
|--------|-------------|
| `30c3f9e` | Fix compilation for macOS Apple Silicon with modern dependencies (daemon) |
| `11895e9` | Add Qt wallet compilation support for macOS Apple Silicon |

---

*Last Updated: February 2, 2026*
*Fork maintained by: carlosdias1975now-code*
