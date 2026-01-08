/* ========================================================================
	Project  Name			: FastCopy Enhanced - Windows 11 Compatibility
	Create					: 2026-01-08(Wed)
	Copyright				: FastCopy-Enhanced Contributors
	License					: GNU General Public License version 3
	======================================================================== */

#ifndef WIN11_COMPAT_H
#define WIN11_COMPAT_H

// Windows 11 specific constants
#ifndef FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS
#define FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS 0x00400000
#endif

#ifndef FILE_ATTRIBUTE_RECALL_ON_OPEN
#define FILE_ATTRIBUTE_RECALL_ON_OPEN 0x00040000
#endif

#ifndef FILE_ATTRIBUTE_PINNED
#define FILE_ATTRIBUTE_PINNED 0x00080000
#endif

#ifndef FILE_ATTRIBUTE_UNPINNED
#define FILE_ATTRIBUTE_UNPINNED 0x00100000
#endif

// Check if a file is an OneDrive placeholder (not downloaded)
inline BOOL IsOneDrivePlaceholder(const WCHAR *path)
{
	if (!path || !*path) {
		return FALSE;
	}

	DWORD attr = ::GetFileAttributesW(path);

	if (attr == INVALID_FILE_ATTRIBUTES) {
		return FALSE;
	}

	// Check if file has OneDrive placeholder attributes
	// FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS means the file is a placeholder
	// and accessing it will trigger a download from OneDrive
	if (attr & FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS) {
		return TRUE;
	}

	return FALSE;
}

// Check if path should be skipped for Windows 11 shell extension
// This prevents triggering OneDrive downloads on right-click
inline BOOL ShouldSkipPathWin11(const WCHAR *path)
{
	if (!path || !*path) {
		return FALSE;
	}

	// Skip OneDrive placeholders to prevent automatic downloads
	// This fixes the issue in Windows 11 where right-clicking on
	// an empty OneDrive file starts an unwanted download
	return IsOneDrivePlaceholder(path);
}

#endif // WIN11_COMPAT_H
