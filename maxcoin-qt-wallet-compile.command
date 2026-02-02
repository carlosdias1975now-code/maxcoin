#!/bin/bash
# MaxCoin Qt Wallet Compile Script for macOS Apple Silicon
# Double-click this file in Finder to compile the GUI wallet

cd "$(dirname "$0")"

echo "=========================================="
echo "MaxCoin Qt Wallet Compiler for Apple Silicon"
echo "=========================================="
echo ""

# Check for Qt5
if [ ! -d "/opt/homebrew/opt/qt@5" ]; then
    echo "ERROR: Qt5 not found. Install with:"
    echo "  brew install qt@5"
    exit 1
fi

# Check for required dependencies
MISSING_DEPS=""
[ ! -d "/opt/homebrew/opt/boost" ] && MISSING_DEPS="$MISSING_DEPS boost"
[ ! -d "/opt/homebrew/opt/openssl@3" ] && MISSING_DEPS="$MISSING_DEPS openssl@3"
[ ! -d "/opt/homebrew/opt/berkeley-db@4" ] && MISSING_DEPS="$MISSING_DEPS berkeley-db@4"

if [ -n "$MISSING_DEPS" ]; then
    echo "ERROR: Missing dependencies:$MISSING_DEPS"
    echo "Install with: brew install$MISSING_DEPS"
    exit 1
fi

echo "All dependencies found."
echo ""

# Clean previous build
echo "Cleaning previous build..."
rm -rf Makefile .qmake.stash build 2>/dev/null

# Run qmake
echo "Running qmake..."
/opt/homebrew/opt/qt@5/bin/qmake "USE_UPNP=-" maxcoin-qt.pro

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: qmake failed!"
    read -p "Press Enter to exit..."
    exit 1
fi

# Compile
echo ""
echo "Compiling MaxCoin-Qt wallet (this may take a few minutes)..."
echo ""
make -j$(sysctl -n hw.ncpu)

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "BUILD SUCCESSFUL!"
    echo "=========================================="
    echo ""
    echo "The wallet app is located at:"
    echo "  $(pwd)/MaxCoin-Qt.app"
    echo ""
    echo "To run: open MaxCoin-Qt.app"
    echo ""

    # Ask if user wants to open the app
    read -p "Open MaxCoin-Qt now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open MaxCoin-Qt.app
    fi
else
    echo ""
    echo "=========================================="
    echo "BUILD FAILED!"
    echo "=========================================="
    echo "Check the error messages above."
fi

echo ""
read -p "Press Enter to exit..."
