@echo off
echo ========================================
echo QuickCopy - Clean Build Folders
echo ========================================
echo.
echo This will delete all build output folders to free up space.
echo.

set /p confirm="Are you sure you want to delete bin/ and obj/ folders? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Cancelled.
    pause
    exit /b
)

echo.
echo Cleaning bin folder...
if exist bin (
    rmdir /s /q bin
    echo ✓ bin/ deleted
) else (
    echo - bin/ does not exist
)

echo Cleaning obj folder...
if exist obj (
    rmdir /s /q obj
    echo ✓ obj/ deleted
) else (
    echo - obj/ does not exist
)

echo.
echo ========================================
echo CLEANUP COMPLETE!
echo ========================================
echo.
echo You can safely rebuild the project when needed.
echo The source code is intact.
echo.
pause
