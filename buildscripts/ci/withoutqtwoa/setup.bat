@echo off
REM SPDX-License-Identifier: GPL-3.0-only
REM MuseScore-Studio-CLA-applies
REM
REM MuseScore Studio
REM Music Composition & Notation
REM
REM Copyright (C) 2024 MuseScore Limited

ECHO "Setup Windows ARM64 build environment (without Qt)"

SET ARTIFACTS_DIR=build.artifacts
SET BUILD_TOOLS=%USERPROFILE%\build_tools
SET ENV_FILE=%BUILD_TOOLS%\environment.bat

REM Create build tools directory
IF NOT EXIST "%BUILD_TOOLS%" (
    MKDIR "%BUILD_TOOLS%"
)

REM Remove old environment file if it exists
IF EXIST "%ENV_FILE%" (
    DEL "%ENV_FILE%"
)

ECHO @echo off > "%ENV_FILE%"
ECHO REM Setup MuseScore build environment for ARM64 >> "%ENV_FILE%"

REM Install tools
where /q git
IF ERRORLEVEL 1 ( choco install -y git.install )

where /q cmake
IF ERRORLEVEL 1 ( choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System' )

where /q ninja
IF ERRORLEVEL 1 ( choco install -y ninja )

REM Setup Visual Studio ARM64 environment
SET VSWHERE="C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
FOR /f "usebackq tokens=*" %%i in (`%VSWHERE% -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
  SET VS_INSTALL_DIR=%%i
)

IF NOT DEFINED VS_INSTALL_DIR (
    ECHO Error: Visual Studio not found
    EXIT /b 1
)

ECHO SET "VS_INSTALL_DIR=%VS_INSTALL_DIR%" >> "%ENV_FILE%"
ECHO CALL "%%VS_INSTALL_DIR%%\VC\Auxiliary\Build\vcvarsamd64_arm64.bat" >> "%ENV_FILE%"

REM Create artifacts directory
IF NOT EXIST "%ARTIFACTS_DIR%" (
    MKDIR "%ARTIFACTS_DIR%"
)
IF NOT EXIST "%ARTIFACTS_DIR%\env" (
    MKDIR "%ARTIFACTS_DIR%\env"
)

ECHO Setup complete
cmake --version
ninja --version

EXIT /b 0
