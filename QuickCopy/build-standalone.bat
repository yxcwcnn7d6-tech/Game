@echo off
echo ========================================
echo QuickCopy - Build Standalone Executable
echo ========================================
echo.

echo Cleaning previous builds...
if exist bin\Release rmdir /s /q bin\Release
if exist obj\Release rmdir /s /q obj\Release

echo.
echo Building standalone executable...
echo This will create a single .exe file that includes .NET runtime
echo Target: Windows 64-bit
echo.

dotnet publish -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Output location:
    echo bin\Release\net8.0-windows\win-x64\publish\QuickCopy.exe
    echo.
    echo This file can be copied to any Windows 10/11 (64-bit) computer
    echo and will run WITHOUT requiring .NET installation!
    echo.
    echo File size: ~70 MB
    echo ========================================

    if exist "bin\Release\net8.0-windows\win-x64\publish\QuickCopy.exe" (
        echo.
        echo Opening output folder...
        explorer "bin\Release\net8.0-windows\win-x64\publish"
    )
) else (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo Please check the error messages above.
    echo Make sure you have .NET 8.0 SDK installed.
)

echo.
pause
