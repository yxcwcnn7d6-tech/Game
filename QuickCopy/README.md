# QuickCopy Vattenfall Edition

**Professional file/folder copy and move utility with GUI**

![Version](https://img.shields.io/badge/version-1.0-blue.svg)
![.NET](https://img.shields.io/badge/.NET-8.0-purple.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)

## Overview

QuickCopy Vattenfall Edition is a powerful Windows application for copying and moving files and folders. It features a dual-pane file browser interface with advanced robocopy integration for reliable file operations.

**Author:** Marcus Thilander YISPC
**Date:** 2024-12-22
**Converted to C#:** 2025

## Features

### Core Functionality
- **Dual-pane file browser** with independent navigation
- **Copy and Move operations** using Windows robocopy
- **Real-time progress monitoring** with activity logging
- **File filtering** support (e.g., `*.jpg;*.png;*.pdf`)
- **Context menu** with common file operations
- **Settings persistence** (paths, window position, preferences)

### Advanced Options
- **Only newer files (/XO)** - Skip files that haven't changed
- **Network compression (/COMPRESS)** - Optimize for network transfers
- **Sound notifications** - Audio feedback on completion

### File Operations
- Navigate folders with double-click
- Sort by name, size, type, or modified date
- Copy/Move with robocopy reliability
- Delete to Recycle Bin
- View file properties
- Copy full paths to clipboard
- Open files in Windows Explorer

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Copy selected items |
| `Ctrl+M` | Move selected items |
| `Ctrl+A` | Select all items |
| `Delete` | Delete selected items |
| `Escape` | Deselect all items |
| `F5` | Refresh both panels |
| `Enter` | Apply file filter (when filter box is focused) |

## Context Menu (Right-Click)

- **Copy Path** - Copy full path(s) to clipboard
- **Open in Explorer** - Open file location in Windows Explorer
- **Delete** - Move to Recycle Bin
- **Properties** - Show Windows file properties dialog

## System Requirements

- **OS:** Windows 10 or later
- **Framework:** .NET 8.0 or later
- **Dependencies:** Microsoft.VisualBasic (for RecycleBin operations)

## Building the Project

### Prerequisites
- Visual Studio 2022 or later
- .NET 8.0 SDK

### Build Steps

```bash
# Clone the repository
git clone <repository-url>

# Navigate to QuickCopy directory
cd QuickCopy

# Restore NuGet packages
dotnet restore

# Build the project
dotnet build

# Run the application
dotnet run
```

### Build in Visual Studio

1. Open `QuickCopy.sln` in Visual Studio
2. Press `F5` to build and run
3. Or use `Build > Build Solution` (Ctrl+Shift+B)

## Configuration

Settings are automatically saved to `QuickCopy.ini` in the application directory:

```ini
[Paths]
SourcePath=C:\Users\...
DestinationPath=D:\...

[Window]
WindowX=100
WindowY=100

[Options]
NewerFiles=0
Compress=0
Sound=1
LastFilter=*.jpg;*.png
```

## Robocopy Integration

QuickCopy uses Windows built-in `robocopy.exe` for reliable file operations:

- **Retry logic:** 10 retries with 30-second wait
- **Network throttling:** 10ms inter-packet gap
- **Copy options:** Full directory trees with subdirectories
- **Move support:** `/MOVE` flag for move operations
- **Exit codes:** Interpreted and displayed in activity log
- **Batch file execution:** Uses temporary batch files to avoid Windows command line length limits (handles 100+ files easily)
- **Performance optimization:** All files from the same folder are copied in a single robocopy command (5x faster than running robocopy per file)

## Design - Vattenfall Color Scheme

The application uses Vattenfall's brand colors:
- **Primary Blue:** #2071B5
- **Accent Yellow:** #FFDA00
- **Text Grey:** #4E4B48
- **Panel Background:** #E8F4F8

## Original AutoIt Version

This C# version is a conversion of the original AutoIt3 script. The conversion maintains all functionality while providing:
- Better performance
- Native Windows integration
- Modern .NET framework
- Enhanced maintainability

## License

© 2025 YISPC - All rights reserved

## Support

For issues or questions, please contact the development team.

---

**Powered by Windows Robocopy**
