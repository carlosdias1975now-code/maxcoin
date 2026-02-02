# Maxcoin Build Errors - Analysis Report

**Date:** February 2026
**System:** Ubuntu 22.04 LTS (ARM64/aarch64), GCC 11.4.0
**Build Attempt:** Daemon via `make -f makefile.unix`

---

## Current Status: PARTIAL SUCCESS

**Build Progress:**
1. ✅ **Crypto++ library** - COMPILES SUCCESSFULLY (with C++14 fix)
2. ✅ **LevelDB library** - COMPILES SUCCESSFULLY (with ARM64 fix)
3. ⏸️ **Main Maxcoin code** - Blocked on missing Boost headers

The remaining blockers are **missing system dependencies**, not code issues!

---

## Fixes Applied

### Fix 1: C++14 Standard (Crypto++ `std::byte` conflict)

**Files Modified:**
- `src/cryptopp/GNUmakefile` - Added `-std=c++14` to CXXFLAGS
- `src/makefile.unix` - Added `-std=c++14` to xCXXFLAGS

**Problem:** C++17 introduced `std::byte` which conflicted with Crypto++'s `typedef unsigned char byte;`

### Fix 2: ARM64 Support (LevelDB AtomicPointer)

**File Modified:** `src/leveldb/port/atomic_pointer.h`

**Changes:**
1. Added `__aarch64__` architecture detection:
```cpp
#elif defined(__aarch64__)
#define ARCH_CPU_ARM64_FAMILY 1
```

2. Added ARM64 memory barrier implementation:
```cpp
// ARM64 (aarch64)
#elif defined(ARCH_CPU_ARM64_FAMILY)
inline void MemoryBarrier() {
  asm volatile("dmb ish" : : : "memory");
}
#define LEVELDB_HAVE_MEMORY_BARRIER
```

3. Added cleanup at end of file:
```cpp
#undef ARCH_CPU_ARM64_FAMILY
```

---

## Remaining Issue: Missing Dependencies

The build now stops at main Maxcoin code compilation because system libraries are missing:

```
alert.cpp:6:10: fatal error: boost/algorithm/string/classification.hpp: No such file or directory
```

### Required Dependencies

```bash
sudo apt install -y \
    libboost-all-dev \      # Boost libraries (MISSING)
    libssl-dev \            # OpenSSL development files (MISSING)
    libdb-dev libdb++-dev \ # Berkeley DB (MISSING)
    libminiupnpc-dev \      # UPnP support (MISSING)
```

For Qt GUI:
```bash
sudo apt install -y \
    qt6-base-dev \
    qt6-tools-dev \
    libqt6widgets6
```

---

## Build Warnings (Non-Critical)

### Crypto++ Warnings
1. `std::uncaught_exception()` deprecated → Use `std::uncaught_exceptions()`
2. `throw` in destructor calls `terminate` → Mark destructor `noexcept(false)`
3. `std::auto_ptr` deprecated → Use `std::unique_ptr`

### LevelDB Warnings
1. Sign comparison warnings (`-Wsign-compare`)
2. Implicit fallthrough warnings (`-Wimplicit-fallthrough`)

These are warnings only and don't prevent compilation.

---

## Complete Build Instructions (For System with Dependencies)

```bash
# 1. Install dependencies
sudo apt update
sudo apt install -y build-essential libboost-all-dev libssl-dev \
    libdb-dev libdb++-dev libminiupnpc-dev

# 2. Build daemon
cd maxcoin-master/src
make -f makefile.unix

# 3. Optional: Build Qt GUI (requires Qt packages)
cd ..
qmake maxcoin-qt.pro
make
```

---

## Summary of Code Changes for Modern Compilation

| File | Change | Purpose |
|------|--------|---------|
| `src/cryptopp/GNUmakefile` | Add `-std=c++14` | Avoid `std::byte` conflict |
| `src/makefile.unix` | Add `-std=c++14` | Consistent C++ standard |
| `src/leveldb/port/atomic_pointer.h` | Add ARM64 support | Enable ARM64 compilation |

---

## Next Steps

1. **On a full dev environment:** Install missing dependencies and complete build
2. **Test compilation:** Verify full daemon build works
3. **Test Qt build:** Attempt GUI compilation with Qt6
4. **Address warnings:** Fix deprecated API usage

---

*Last Updated: February 2, 2026*
