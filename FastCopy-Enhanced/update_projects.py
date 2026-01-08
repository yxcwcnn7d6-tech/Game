#!/usr/bin/env python3
"""
Update all Visual Studio project files to use Windows 11 SDK and VS2022 toolset
"""

import re
import os
from pathlib import Path

# Target versions
TARGET_TOOLSVERSION = "17.0"
TARGET_WINDOWS_SDK = "10.0.22621.0"
TARGET_PLATFORMTOOLSET = "v143"

def update_vcxproj(file_path):
    """Update a single .vcxproj file"""
    print(f"Processing: {file_path}")

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = []

    # Update ToolsVersion
    new_content = re.sub(
        r'ToolsVersion="[^"]*"',
        f'ToolsVersion="{TARGET_TOOLSVERSION}"',
        content
    )
    if new_content != content:
        changes.append("Updated ToolsVersion")
        content = new_content

    # Update WindowsTargetPlatformVersion
    new_content = re.sub(
        r'<WindowsTargetPlatformVersion>[^<]*</WindowsTargetPlatformVersion>',
        f'<WindowsTargetPlatformVersion>{TARGET_WINDOWS_SDK}</WindowsTargetPlatformVersion>',
        content
    )
    if new_content != content:
        changes.append("Updated WindowsTargetPlatformVersion")
        content = new_content

    # Update PlatformToolset (handle all variants: v141, v141_xp, etc.)
    new_content = re.sub(
        r'<PlatformToolset>v141[^<]*</PlatformToolset>',
        f'<PlatformToolset>{TARGET_PLATFORMTOOLSET}</PlatformToolset>',
        content
    )
    if new_content != content:
        changes.append("Updated PlatformToolset")
        content = new_content

    # Also handle v140 (VS2015)
    new_content = re.sub(
        r'<PlatformToolset>v140[^<]*</PlatformToolset>',
        f'<PlatformToolset>{TARGET_PLATFORMTOOLSET}</PlatformToolset>',
        content
    )
    if new_content != content:
        changes.append("Updated PlatformToolset (from v140)")
        content = new_content

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ Updated: {', '.join(changes)}")
        return True
    else:
        print(f"  - No changes needed")
        return False

def main():
    """Find and update all .vcxproj files"""
    base_dir = Path(__file__).parent
    vcxproj_files = list(base_dir.rglob("*.vcxproj"))

    print(f"Found {len(vcxproj_files)} project files\n")

    updated_count = 0
    for vcxproj_file in vcxproj_files:
        if update_vcxproj(vcxproj_file):
            updated_count += 1
        print()

    print(f"\nSummary: Updated {updated_count}/{len(vcxproj_files)} files")
    print(f"Target: VS2022 (v143) with Windows 11 SDK ({TARGET_WINDOWS_SDK})")

if __name__ == "__main__":
    main()
