/* ========================================================================
	Project  Name			: FastCopy Enhanced - NVMe Optimization
	Create					: 2026-01-08(Wed)
	Copyright				: FastCopy-Enhanced Contributors
	License					: GNU General Public License version 3

	NVMe SSD Optimizations:
	- Increased queue depth for better NVMe performance
	- Optimized buffer sizes for NVMe drives
	- Pre-allocation support in privileged mode
	======================================================================== */

#ifndef NVME_OPTIMIZE_H
#define NVME_OPTIMIZE_H

#include <windows.h>
#include <winioctl.h>

#ifndef BusTypeNvme
#define BusTypeNvme 17
#endif

#ifndef BusTypePCIe
#define BusTypePCIe 15
#endif

// Enhanced queue depths for modern NVMe SSDs
// Original FastCopy uses lower queue depths designed for SATA
#define NVME_MAX_OVL_NUM		64	// NVMe can handle much higher queue depths (vs 20 default)
#define NVME_MAX_OVL_SIZE		(2 * 1024 * 1024)	// 2MB chunks optimal for NVMe
#define NVME_BUFFER_SIZE		(512 * 1024 * 1024)	// 512MB buffer for high-speed NVMe

// Standard (SATA/HDD) settings - keep original values
#define STD_MAX_OVL_NUM			20
#define STD_MAX_OVL_SIZE		(1 * 1024 * 1024)	// 1MB chunks
#define STD_BUFFER_SIZE			(256 * 1024 * 1024)	// 256MB buffer

// Check if drive is NVMe by examining device properties
inline BOOL IsNVMeDrive(const WCHAR *root_dir)
{
	if (!root_dir || !*root_dir) {
		return FALSE;
	}

	WCHAR	device_path[MAX_PATH];
	if (root_dir[0] == '\\' && root_dir[1] == '\\') {
		// Network path, not NVMe
		return FALSE;
	}

	// Build device path like "\\.\C:"
	swprintf_s(device_path, MAX_PATH, L"\\\\.\\%c:", root_dir[0]);

	HANDLE hDevice = ::CreateFileW(device_path, 0,
		FILE_SHARE_READ | FILE_SHARE_WRITE, NULL,
		OPEN_EXISTING, 0, NULL);

	if (hDevice == INVALID_HANDLE_VALUE) {
		return FALSE;
	}

	BOOL isNVMe = FALSE;

	// Query storage property to determine if NVMe
	STORAGE_PROPERTY_QUERY query = {};
	query.PropertyId = StorageDeviceProperty;
	query.QueryType = PropertyStandardQuery;

	BYTE buffer[4096] = {};
	DWORD bytesReturned = 0;

	if (::DeviceIoControl(hDevice, IOCTL_STORAGE_QUERY_PROPERTY,
		&query, sizeof(query), buffer, sizeof(buffer),
		&bytesReturned, NULL)) {

		STORAGE_DEVICE_DESCRIPTOR *desc = (STORAGE_DEVICE_DESCRIPTOR *)buffer;

		// NVMe drives typically report BusType as BusTypeNvme (17)
		// or might be on PCIe (15)
		if (desc->BusType == 17) { // BusTypeNvme
			isNVMe = TRUE;
		}
		else if (desc->BusType == 15) { // BusTypePCIe - could be NVMe
			// Additional checks could be done here
			// For now, assume PCIe storage is NVMe
			isNVMe = TRUE;
		}
	}

	::CloseHandle(hDevice);
	return isNVMe;
}

// Get optimized I/O parameters based on drive type
inline void GetOptimizedIOParams(const WCHAR *root_dir,
								  DWORD *maxOvlNum,
								  DWORD *maxOvlSize,
								  size_t *bufferSize)
{
	BOOL isNVMe = IsNVMeDrive(root_dir);

	if (isNVMe) {
		// NVMe optimizations: higher queue depth, larger buffers
		*maxOvlNum = NVME_MAX_OVL_NUM;
		*maxOvlSize = NVME_MAX_OVL_SIZE;
		*bufferSize = NVME_BUFFER_SIZE;
	}
	else {
		// Standard (SATA/HDD) settings
		*maxOvlNum = STD_MAX_OVL_NUM;
		*maxOvlSize = STD_MAX_OVL_SIZE;
		*bufferSize = STD_BUFFER_SIZE;
	}
}

// Pre-allocate file space for better SSD performance
// This reduces fragmentation and improves write performance
inline BOOL PreAllocateFile(HANDLE hFile, int64 fileSize)
{
	if (hFile == INVALID_HANDLE_VALUE || fileSize <= 0) {
		return FALSE;
	}

	// Use SetFileInformationByHandle with FileAllocationInfo
	// to pre-allocate space without writing data
	FILE_ALLOCATION_INFO allocInfo = {};
	allocInfo.AllocationSize.QuadPart = fileSize;

	return ::SetFileInformationByHandle(hFile, FileAllocationInfo,
		&allocInfo, sizeof(allocInfo));
}

#endif // NVME_OPTIMIZE_H
