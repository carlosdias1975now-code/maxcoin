#!/bin/bash
# Maxcoin Wallet Compile Script
# Double-click this file to compile the wallet on macOS

echo "=========================================="
echo "  Maxcoin Wallet Compilation Script"
echo "=========================================="
echo ""

# IMPORTANT: Use symlink path to avoid spaces in path breaking the makefile
# The symlink points to the actual iCloud location
BUILD_DIR="$HOME/maxcoin-build"

# Check if symlink exists
if [ ! -L "$BUILD_DIR" ]; then
    echo "ERROR: Build symlink not found at $BUILD_DIR"
    echo ""
    echo "Create it with:"
    echo '  ln -s "/Users/admin/Library/Mobile Documents/com~apple~CloudDocs/claude-workspaces/maxcoin-dev/maxcoin-wallet-fork/maxcoin" ~/maxcoin-build'
    echo ""
    echo "Press any key to close..."
    read -n 1
    exit 1
fi

# Set up environment for Homebrew dependencies
export BOOST_INCLUDE_PATH=/opt/homebrew/include
export BOOST_LIB_PATH=/opt/homebrew/lib
export BDB_INCLUDE_PATH=/opt/homebrew/opt/berkeley-db@4/include
export BDB_LIB_PATH=/opt/homebrew/opt/berkeley-db@4/lib
export OPENSSL_INCLUDE_PATH=/opt/homebrew/opt/openssl@3/include
export OPENSSL_LIB_PATH=/opt/homebrew/opt/openssl@3/lib
export LDFLAGS="-L/opt/homebrew/opt/berkeley-db@4/lib -L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/berkeley-db@4/include -I/opt/homebrew/opt/openssl@3/include"
export PATH="/opt/homebrew/opt/berkeley-db@4/bin:/opt/homebrew/opt/openssl@3/bin:$PATH"

echo "Environment configured:"
echo "  BUILD_DIR: $BUILD_DIR"
echo "  BOOST_INCLUDE_PATH: $BOOST_INCLUDE_PATH"
echo "  BDB_INCLUDE_PATH: $BDB_INCLUDE_PATH"
echo "  OPENSSL_INCLUDE_PATH: $OPENSSL_INCLUDE_PATH"
echo ""

# Change to src directory via symlink
cd "$BUILD_DIR/src"
echo "Working directory: $(pwd)"
echo ""

# Clean previous build (optional - comment out if you want incremental builds)
# echo "Cleaning previous build..."
# make -f makefile.unix clean

# Compile
echo "Starting compilation..."
echo ""
make -f makefile.unix

# Check result
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "  BUILD SUCCESSFUL!"
    echo "=========================================="
    echo ""
    echo "The daemon is located at:"
    echo "  $BUILD_DIR/src/maxcoind"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "  BUILD FAILED"
    echo "=========================================="
    echo ""
    echo "Check the errors above for details."
    echo ""
fi

# Keep terminal open to see output
echo "Press any key to close..."
read -n 1
