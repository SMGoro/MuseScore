@echo off
REM SPDX-License-Identifier: GPL-3.0-only
REM MuseScore-Studio-CLA-applies
REM
REM MuseScore Studio
REM Music Composition & Notation
REM
REM Copyright (C) 2024 MuseScore Limited

ECHO "Build MuseScore for Windows ARM64 (without Qt)"

SET ARTIFACTS_DIR=build.artifacts
SET BUILD_TOOLS=%USERPROFILE%\build_tools
SET ENV_FILE=%BUILD_TOOLS%\environment.bat
SET BUILD_MODE=devel
SET TARGET_PROCESSOR_ARCH=arm64

:GETOPTS
IF /I "%1" == "-m" SET BUILD_MODE=%2& SHIFT
SHIFT
IF NOT "%1" == "" GOTO GETOPTS

REM Source environment
IF NOT EXIST "%ENV_FILE%" (
    ECHO Error: Environment file not found. Run setup.bat first.
    EXIT /b 1
)

ECHO Loading environment from %ENV_FILE%
CALL "%ENV_FILE%"

REM Setup build mode
bash ./buildscripts/ci/tools/make_build_mode_env.sh -e workflow_dispatch -m %BUILD_MODE%
IF ERRORLEVEL 1 (
    ECHO Error: Failed to setup build mode
    EXIT /b 1
)

REM Setup build number
bash ./buildscripts/ci/tools/make_build_number.sh
IF ERRORLEVEL 1 (
    ECHO Error: Failed to setup build number
    EXIT /b 1
)

REM Build a simple test without Qt to verify ARM64 compilation
ECHO Building without Qt for ARM64...
cd tools\check_build_without_qt

IF NOT EXIST "build-check_build_without_qt_arm64" (
    MKDIR build-check_build_without_qt_arm64
)

cd build-check_build_without_qt_arm64

REM Configure with CMake for ARM64
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_SYSTEM_PROCESSOR=ARM64
IF ERRORLEVEL 1 (
    ECHO Error: CMake configuration failed
    cd ..\..\..
    EXIT /b 1
)

REM Build
ninja
IF ERRORLEVEL 1 (
    ECHO Error: Build failed
    cd ..\..\..
    EXIT /b 1
)

cd ..\..\..

REM Create artifact
ECHO Build successful
SET /p BUILD_VERSION=<%ARTIFACTS_DIR%\env\build_version.env 2>nul || SET BUILD_VERSION=unknown
SET /p BUILD_NUMBER=<%ARTIFACTS_DIR%\env\build_number.env 2>nul || SET BUILD_NUMBER=unknown

ECHO Build completed for ARM64
ECHO BUILD_VERSION=%BUILD_VERSION%
ECHO BUILD_NUMBER=%BUILD_NUMBER%
ECHO TARGET_ARCH=%TARGET_PROCESSOR_ARCH%

REM Save artifact info
bash ./buildscripts/ci/tools/make_artifact_name_env.sh MuseScore-WithoutQt-ARM64-%BUILD_MODE%.txt
ECHO ARM64 build without Qt completed successfully > %ARTIFACTS_DIR%\MuseScore-WithoutQt-ARM64-%BUILD_MODE%.txt

EXIT /b 0
