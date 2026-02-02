![picture](img/logo.png)

What is MaxCoin?
==============

Maxcoin is an alternative cryptocurrency introduced in 2014.

Technical Information

+ ~100,000,000 coins
+ 8 coins rewarded per block, halving every 4 years - last halving 16 July 2017
+ 60 second block times
+ difficulty retargeting using a time-warp resistant implementation of KGW

Notable differences from Bitcoin
-----------------------------

+ sha3 Keccak encryption instead of sha256
+ replacement of ECDSA with Schnorr signing (Schnorr Signatures)
+ use of secp256r1 curve over secp256k1
+ requirement for public key when verifying transactions
+ capable of hosting smart contracts
+ no premine

Modifications to the RPC API
+ verifymessage <publickey> <signature> <message>
+ makekeypair [hex-encoded prefix]
+ dumppubkey <maxcoinaddress>

Additional technical details can be found on Everipedia (https://everipedia.org/wiki/maxcoin-cryptocurrency/) or in the [Wiki](https://github.com/Max-Coin/maxcoin/wiki/_pages).

Forked from Bitcoin reference wallet 0.8.5 and Blakecoin

Building on macOS Apple Silicon (ARM64)
--------------------------------------

This version has been updated to compile on modern macOS with Apple Silicon (M1/M2/M3/M4) using Homebrew dependencies.

### Prerequisites

Install dependencies via Homebrew:

```bash
brew install boost openssl@3 berkeley-db@4 miniupnpc qt@5
```

### Build the Daemon (maxcoind)

Use the included compile script:

```bash
chmod +x maxcoin-wallet-compile.command
./maxcoin-wallet-compile.command
```

Or build manually:

```bash
cd src
make -f makefile.osx USE_UPNP=-
```

The daemon binary will be created at `src/maxcoind`.

### Build the Qt Wallet (MaxCoin-Qt.app)

Use the included compile script:

```bash
chmod +x maxcoin-qt-wallet-compile.command
./maxcoin-qt-wallet-compile.command
```

Or build manually:

```bash
/opt/homebrew/opt/qt@5/bin/qmake "USE_UPNP=-" maxcoin-qt.pro
make -j$(sysctl -n hw.ncpu)
```

The wallet app will be created at `MaxCoin-Qt.app`.

### Key Fixes for Modern macOS

The following updates were made for compatibility with modern toolchains:

+ **OpenSSL 3.x**: Updated crypto code for opaque BIGNUM/BN_CTX and EVP API changes
+ **Boost 1.69+**: Changed `io_service` to `io_context`, `is_complete()` to `is_absolute()`, updated copy_file options, removed boost_system from linker (now header-only)
+ **C++14**: Required for modern Crypto++ compatibility
+ **Apple Silicon paths**: Updated Homebrew paths from `/usr/local/opt/` to `/opt/homebrew/opt/`
+ **Qt5**: Updated .pro file for Qt5 on ARM64

License
------

MaxCoin is released under the terms of the MIT license. See `COPYING` for more
information or see http://opensource.org/licenses/MIT.
