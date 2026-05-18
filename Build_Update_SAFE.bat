@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
cd /d "%ROOT%"

echo.
echo ============================================
echo VK Mods - build update package
echo ============================================
echo.

if not exist "%ROOT%tools\MakeUpdatePackage.ps1" (
    echo ERROR: File not found:
    echo "%ROOT%tools\MakeUpdatePackage.ps1"
    echo.
    echo Put this BAT file into the template root folder.
    echo The same folder must contain:
    echo   latest
    echo   package_source
    echo   tools
    echo.
    pause
    exit /b 1
)

if not exist "%ROOT%package_source\VK_Mod.dll" (
    echo ERROR: package_source\VK_Mod.dll not found.
    echo Put VK_Mod.dll into package_source folder.
    echo.
    pause
    exit /b 1
)

if not exist "%ROOT%package_source\VK_Core.dll" (
    echo ERROR: package_source\VK_Core.dll not found.
    echo Put VK_Core.dll into package_source folder.
    echo.
    pause
    exit /b 1
)

if not exist "%ROOT%package_source\icons" (
    echo ERROR: package_source\icons folder not found.
    echo Put icons folder into package_source folder.
    echo.
    pause
    exit /b 1
)

set "VERSION="
set /p VERSION=Enter update version, for example 1.0.2: 

if "%VERSION%"=="" (
    echo ERROR: Version is empty.
    pause
    exit /b 1
)

set "NOTES="
set /p NOTES=Enter update notes: 
if "%NOTES%"=="" set "NOTES=VK Mods update"

echo.
echo Building version %VERSION%...
echo Root: "%ROOT%"
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& '%ROOT%tools\MakeUpdatePackage.ps1' -Version '%VERSION%' -Notes '%NOTES%'"

if errorlevel 1 (
    echo.
    echo ERROR: Update package was not created.
    echo Check the error above.
    echo.
    pause
    exit /b 1
)

echo.
echo DONE.
echo Upload these files to GitHub /latest:
echo   latest\update.json
echo   latest\VK_Mods_update_%VERSION%.zip
echo.
pause
exit /b 0
