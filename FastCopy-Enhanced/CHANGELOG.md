# Changelog

All notable changes to FastCopy-Enhanced will be documented in this file.

## [Unreleased] - 2026-01-08

### Added
- Created FastCopy-Enhanced project based on FastCopy v3.63
- Added Windows 11 compatibility improvements
- Modern build system support (Visual Studio 2022)
- CPU dispatch optimization support via xxh_x86dispatch

### Changed
- ✅ **Windows SDK upgraded to 10.0.22621.0** (Windows 11)
- ✅ **xxHash upgraded to v0.8.3** (from v0.6.5) - Latest version with significant performance improvements
- ✅ **Platform toolset upgraded to v143** (Visual Studio 2022)
- ✅ **All project files modernized** for Windows 11 SDK
- 🚧 Shell extension Windows 11 compatibility fixes (in progress)
- ⏳ Async I/O optimizations (pending)
- ⏳ NVMe SSD-specific optimizations (pending)

### Technical Details

#### Base Version
- FastCopy v3.63 (2019-02-19)
- xxHash v0.6.5 (2016)
- Windows SDK 10.0.15063.0 (original)
- Visual Studio 2017 toolset (v141)

#### Enhanced Version (Current)
- FastCopy v3.63 Enhanced
- xxHash v0.8.3 (December 30, 2024) ✅
- Windows SDK 10.0.22621.0 (Windows 11) ✅
- Visual Studio 2022 toolset (v143) ✅

#### Completed Improvements
1. **Windows 11 Compatibility**
   - [x] Upgrade Windows SDK target to 10.0.22621.0
   - [x] Update all project files to VS2022 toolset
   - [ ] Fix shell extension for Windows 11 (in progress)
   - [ ] Update API calls for modern Windows

2. **Performance Improvements**
   - [x] xxHash v0.8.3 integration (3-4x faster than v0.6.5)
   - [x] CPU dispatch optimization support
   - [ ] Async I/O optimization for NVMe
   - [ ] Buffer pre-allocation in privileged mode
   - [ ] Enhanced SSD detection and optimization

3. **Code Modernization**
   - [x] Visual Studio 2022 support
   - [ ] C++17 standard compliance
   - [ ] Modern compiler optimizations

---

## Base Version Information

### FastCopy v3.63 (2019-02-19) - Original
- Last open-source release under GPLv3
- Multi-threaded copy/delete operations
- Overlapped I/O for async operations
- MAX_OPENTHREADS=16 for parallel file opening
- xxHash, MD5, SHA1, SHA256 verification
- ACL and alternate stream support
- Hardlink support
