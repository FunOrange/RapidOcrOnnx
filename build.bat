@ECHO OFF
chcp 65001
cls
@SETLOCAL
echo "========Please refer to README.md to prepare your build environment========"
echo.

echo "========Build Options========"
echo "Note: The project uses Release libraries by default. Do not select Debug unless you have built Debug versions of Onnxruntime and OpenCV."
echo "Enter build type and press Enter: 1)Release, 2)Debug"
set BUILD_TYPE=Release
set /p flag=
if %flag% == 1 (set BUILD_TYPE=Release)^
else if %flag% == 2 (set BUILD_TYPE=Debug)^
else (echo Input Error!)
echo.

echo "Note: If you select 2) JNI dynamic library, you must install and configure Oracle JDK."
echo "Select build output type and press Enter: 1)BIN executable, 2)JNI dynamic library, 3)C dynamic library"
set /p flag=
if %flag% == 1 (set BUILD_OUTPUT="BIN")^
else if %flag% == 2 (set BUILD_OUTPUT="JNI")^
else if %flag% == 3 (set BUILD_OUTPUT="CLIB")^
else (echo Input Error!)
echo.

echo "Library linkage type: 1)Static CRT (mt), 2)Dynamic CRT (md)"
echo "Note: Example project uses static CRT (mt) by default."
set /p flag=
if %flag% == 1 (
    set MT_ENABLED="True"
)^
else (set MT_ENABLED="False")
echo.

echo "onnxruntime: 1)CPU (default), 2)GPU (cuda)"
echo "Note: Example project uses CPU version by default. CUDA version is only supported for x64 and must be downloaded separately."
set /p flag=
if %flag% == 1 (set ONNX_TYPE="CPU")^
else if %flag% == 2 (set ONNX_TYPE="CUDA")^
else (echo Input Error!)
echo.

echo "VS Version: 1)vs2019-x64, 2)vs2019-x86, 3)vs2022-x64, 4)vs2022-x86"
set BUILD_CMAKE_T="v142"
set BUILD_CMAKE_A="x64"
set /p flag=
if %flag% == 1 (
    set BUILD_CMAKE_T="v142"
    set BUILD_CMAKE_A="x64"
)^
else if %flag% == 2 (
    set BUILD_CMAKE_T="v142"
    set BUILD_CMAKE_A="Win32"
)^
else if %flag% == 3 (
    set BUILD_CMAKE_T="v143"
    set BUILD_CMAKE_A="x64"
)^
else if %flag% == 4 (
    set BUILD_CMAKE_T="v143"
    set BUILD_CMAKE_A="Win32"
)^
else (echo Input Error!)
echo.

mkdir win-%BUILD_OUTPUT%-%ONNX_TYPE%-%BUILD_CMAKE_A%
pushd win-%BUILD_OUTPUT%-%ONNX_TYPE%-%BUILD_CMAKE_A%

cmake -T "%BUILD_CMAKE_T%,host=x64" -A %BUILD_CMAKE_A% ^
  -DCMAKE_INSTALL_PREFIX=install ^
  -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DOCR_OUTPUT=%BUILD_OUTPUT% ^
  -DOCR_BUILD_CRT=%MT_ENABLED% -DOCR_ONNX=%ONNX_TYPE% ..
cmake --build . --config %BUILD_TYPE% -j %NUMBER_OF_PROCESSORS%
cmake --build . --config %BUILD_TYPE% --target install

popd
GOTO:EOF

@ENDLOCAL
