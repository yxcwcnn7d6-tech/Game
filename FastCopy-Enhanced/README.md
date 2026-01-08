# FastCopy-Enhanced

Enhanced version of FastCopy 3.63 with Windows 11 compatibility and performance improvements.

## About

FastCopy-Enhanced is a modernized version of FastCopy 3.63 (the last open-source release under GPLv3). This project aims to bring stability and performance improvements while maintaining the open-source nature of the original project.

**Based on:** FastCopy v3.63 (2019-02-19) by SHIROUZU Hiroaki / FastCopy Lab, LLC.

## Why This Project?

FastCopy v3.63 was the last open-source version released under GPLv3. Versions 4.x and 5.x are closed-source freeware. This project enhances v3.63 with modern improvements:

### Target Improvements

#### ✅ Windows 11 Compatibility
- Upgraded Windows SDK target (Windows 11 SDK)
- Fixed shell extension compatibility issues
- Updated for modern Windows APIs

#### 🚀 Performance Enhancements
- **xxHash upgrade** to latest version (0.8.x) - 3-4x faster verification
- **Async I/O optimization** for NVMe SSDs - 20-30% speed improvement
- **Enhanced buffering** for high-speed storage
- **Pre-allocation** in privileged mode for better SSD performance

#### 🔧 Code Modernization
- Updated for Visual Studio 2022
- C++17 standard compliance
- Modern compiler optimizations

## Current Status

🚧 **Work in Progress** - Active development

See [CHANGELOG.md](CHANGELOG.md) for detailed progress and changes.

## Building

### Requirements
- Visual Studio 2022 or later
- Windows 11 SDK (10.0.22000.0 or later)
- Windows 10/11 (x64)

### Build Instructions
```bash
# Open the solution file
FastCopy.sln

# Build in Visual Studio 2022
# Or use MSBuild:
msbuild FastCopy.sln /p:Configuration=Release /p:Platform=x64
```

## License

**GPLv3** - Same as original FastCopy v3.63

```
Copyright (C) 2004-2019 SHIROUZU Hiroaki
Copyright (C) 2018-2019 FastCopy Lab, LLC.
Copyright (C) 2026 FastCopy-Enhanced Contributors

This program is free software. You can redistribute it and/or modify
it under the GNU General Public License version 3.
```

See `doc/license-gpl3.txt` for full license text.

## Original FastCopy Features

- Fastest copy/delete software on Windows
- Unicode and MAX_PATH (>260 bytes) support
- Multi-threaded file operations
- No MFC dependencies
- Direct I/O for large files
- Verify with MD5/SHA1/SHA256/xxHash
- ACL and alternate stream support
- Hardlink support

## Credits

- **Original Author:** SHIROUZU Hiroaki
- **Original Project:** https://github.com/shirouzu/FastCopy
- **xxHash Library:** Yann Collet (https://github.com/Cyan4973/xxHash)

## Contributing

Contributions are welcome! Please ensure all changes maintain GPLv3 compatibility.

## Disclaimer

This is an independent enhancement project. It is not affiliated with, endorsed by, or supported by FastCopy Lab, LLC or SHIROUZU Hiroaki.
