// Copyright (c) 2017 MaxCoin Developers and Nigel Smart
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.
#ifndef H_MAXCOIN_SCHNORR
#define H_MAXCOIN_SCHNORR

#include <string>
#include <iostream>
using namespace std;

// Fix Windows BOOLEAN conflict with Crypto++
// Windows defines BOOLEAN as a typedef, Crypto++ defines it as an enum.
// We must hide Windows BOOLEAN while including Crypto++ headers, then restore it.
#ifdef WIN32
#ifdef BOOLEAN
#define _MAXCOIN_SAVED_WIN_BOOLEAN BOOLEAN
#undef BOOLEAN
#endif
#endif

#include "cryptopp/osrng.h"      // Random Number Generator
#include "cryptopp/eccrypto.h"   // Elliptic Curve
#include "cryptopp/ecp.h"        // F(p) EC
#include "cryptopp/integer.h"    // Integer
#include "cryptopp/sha3.h"       // SHA3

// Restore Windows BOOLEAN after Crypto++ headers
#ifdef WIN32
#ifdef _MAXCOIN_SAVED_WIN_BOOLEAN
#define BOOLEAN _MAXCOIN_SAVED_WIN_BOOLEAN
#undef _MAXCOIN_SAVED_WIN_BOOLEAN
#endif
#endif

#define SCHNORR_SECRET_KEY_SIZE 32
#define SCHNORR_SIG_SIZE 32
#define SCHNORR_PUBLIC_KEY_COMPRESSED_SIZE 33
#define SCHNORR_PUBLIC_KEY_UNCOMPRESSED_SIZE 65

#endif
