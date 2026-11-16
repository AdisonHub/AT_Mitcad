@echo off
rem SPDX-License-Identifier: MIT
rem Runs a command with the Visual Studio C++ environment (cl, link).
rem Set MITCAD_MSVC_ARCH=arm64 for the native ARM64 build tools.
setlocal
rem Shells started before the tools were installed (e.g. sshd sessions) have
rem a stale PATH, so rebuild it from the registry first.
for /f "usebackq delims=" %%p in (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')"`) do set "PATH=%%p"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if /i "%MITCAD_MSVC_ARCH%"=="arm64" (
  for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.ARM64 -property installationPath`) do set "VSDIR=%%i"
  set "VCVARS=vcvarsarm64.bat"
) else (
  for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSDIR=%%i"
  set "VCVARS=vcvars64.bat"
)
if not defined VSDIR (
  echo Visual Studio C++ tools for %MITCAD_MSVC_ARCH% were not found. 1>&2
  exit /b 1
)
set "MITCAD_CALLER_VCPKG_ROOT=%VCPKG_ROOT%"
call "%VSDIR%\VC\Auxiliary\Build\%VCVARS%" >nul || exit /b 1
if defined MITCAD_CALLER_VCPKG_ROOT set "VCPKG_ROOT=%MITCAD_CALLER_VCPKG_ROOT%"
if defined MITCAD_EXTRA_PATH set "PATH=%MITCAD_EXTRA_PATH%;%PATH%"
set "MITCAD_CALLER_VCPKG_ROOT="
%*
