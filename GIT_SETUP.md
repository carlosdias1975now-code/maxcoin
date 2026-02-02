# Git Setup Guide for Maxcoin Development

Since you downloaded the zip file, you need to set up git properly to commit changes to your fork.

---

## Option A: Clone Your Fork Properly (Recommended)

On your local machine with git installed:

```bash
# 1. Clone your fork
git clone https://github.com/carlosdias1975now-code/maxcoin.git
cd maxcoin

# 2. Set up anonymous git identity (for your safety)
git config user.name "CarlosDias"
git config user.email "your-anonymous-email@protonmail.com"

# 3. Add original repo as upstream (to pull future updates)
git remote add upstream https://github.com/Max-Coin/maxcoin.git

# 4. Copy our fixes into your cloned repo
# (Copy the modified files from the zip extraction)
```

---

## Option B: Initialize Git in Current Directory

```bash
cd maxcoin-master

# 1. Initialize git repository
git init

# 2. Set up identity
git config user.name "CarlosDias"
git config user.email "your-anonymous-email@protonmail.com"

# 3. Add your fork as origin
git remote add origin https://github.com/carlosdias1975now-code/maxcoin.git

# 4. Add original as upstream
git remote add upstream https://github.com/Max-Coin/maxcoin.git

# 5. Initial commit with all files
git add .
git commit -m "Initial fork with modern compilation fixes

- Add C++14 flag to fix std::byte conflict with Crypto++
- Add ARM64 (aarch64) support to LevelDB atomic_pointer.h
- Add CLAUDE.md documentation
- Add BUILD_ERRORS.md with compilation analysis

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

# 6. Push to your fork (may need to force if fork has different history)
git branch -M main
git push -u origin main
```

---

## Files Changed (To Commit)

### New Files
- `CLAUDE.md` - Project documentation for development
- `BUILD_ERRORS.md` - Compilation analysis and fixes
- `GIT_SETUP.md` - This setup guide

### Modified Files
- `src/cryptopp/GNUmakefile` - Added `-std=c++14`
- `src/makefile.unix` - Added `-std=c++14`
- `src/leveldb/port/atomic_pointer.h` - Added ARM64 support

---

## Recommended Git Workflow

```bash
# Create feature branch for new work
git checkout -b feature/fix-multisig-crash

# Make changes...

# Stage and commit
git add src/script.cpp
git commit -m "Fix multisig transaction crash

Resolves issue #42 from original repo.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

# Push to your fork
git push origin feature/fix-multisig-crash

# Later, merge to main
git checkout main
git merge feature/fix-multisig-crash
git push origin main
```

---

## Keeping Up with Upstream

```bash
# Fetch updates from original repo
git fetch upstream

# Merge upstream changes
git checkout main
git merge upstream/master

# Push to your fork
git push origin main
```

---

## Security Reminder

Since anonymity is important to you:
1. Use a VPN when pushing to GitHub
2. Don't include any personal information in commit messages
3. Review commits before pushing for any identifying info
4. Consider using a dedicated email for this project

---

*This guide was generated during the initial project setup.*
