# Build Instructions

### Third-Party Dependency Downloads

1. Download OpenCV: [Download link](https://github.com/RapidAI/OpenCVBuilder/releases)

- OpenCV static library: opencv-(version)-(platform).7z
- Extract the archive to the project root directory. On Windows, pay attention to the folder structure. After extraction, the structure should look like this:
- On Windows, there are mt and md versions: mt means static CRT linkage, md means dynamic CRT linkage.

```
opencv-static
├── OpenCVWrapperConfig.cmake
├── linux
├── macos
├── windows-x64
└── windows-x86
```

2. Download onnxruntime: [Download link](https://github.com/RapidAI/OnnxruntimeBuilder/releases)

- static is the static library: onnxruntime-(version)-(platform)-static.7z
- shared is the dynamic library: onnxruntime-(version)-(platform)-shared.7z
- Usually, use the static library.
- Extract the archive to the project root directory. On Windows, pay attention to the folder structure. After extraction, the structure should look like this:
- On Windows, there are mt and md versions: mt means static CRT linkage, md means dynamic CRT linkage.

```
onnxruntime-static
├── OnnxRuntimeWrapperConfig.cmake
├── linux
├── macos
├── windows-x64
└── windows-x86
```

### Build Environment

1. Windows 10 x64
2. macOS 10.15
3. Linux Ubuntu 18.04 x64

**Note: The following instructions are for native compilation. If you need to cross-compile for ARM or other platforms (see Android as reference), you must first cross-compile all third-party dependencies (ncnn, opencv), then integrate and replace the dependencies in this project.**

### Windows Build Instructions

#### Note: From OnnxRuntime 1.7.0, only VS2019 is supported for building.

#### Windows nmake Build

1. Install VS2019, and select at least "Desktop development with C++" during installation.
2. Download and configure cmake >= 3.12: [Download link](https://cmake.org/download/)
3. Open "x64 Native Tools Command Prompt for VS 2019" (or VS2017 x64 tools) and navigate to the project root.
4. Run `build.bat` and follow the prompts, finally select 'BIN executable'.
5. After building, run `run-test.bat` to test (remember to edit the target image path in the script).
6. Build JNI dynamic library (optional, for Java usage).

- Download jdk-8u221-windows-x64.exe, use default install options (make sure "Source Code" is selected). After installation, open "System Properties" -> Advanced -> Environment Variables.
- Add a new system variable: `JAVA_HOME` with value `C:\Program Files\Java\jdk1.8.0_221`
- Add a new system variable: `CLASSPATH` with value `.;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar;`
- Edit the system variable `Path`: On Win7, add `%JAVA_HOME%\bin;` at the beginning; on Win10, add a new line `%JAVA_HOME%\bin`
- Open "x64 Native Tools Command Prompt for VS 2019" (or VS2017 x64 tools) and navigate to the project root.
- Run `build.bat` and follow the prompts, finally select 'JNI dynamic library'.

#### Windows Visual Studio Build Instructions

1. VS2019, cmake, etc. should be installed/configured as above.
2. Run `generate-vs-project.bat`, enter the number to select the Visual Studio solution version to generate.
3. According to your build environment, go to the build-xxxx-x86 or x64 folder and open RapidOcrOnnx.sln.
4. In the top toolbar, select Release. In the right "Solution" window, right-click "ALL_BUILD" -> Build. If you want Debug, you must build Debug versions of OpenCV and onnxruntime yourself.

#### Windows Deployment Instructions

1. If any dependencies are dynamic libraries, remember to copy the DLLs to the executable directory when deploying.
2. If you get a missing "VCRUNTIME140_1.dll" error, install the Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017, and 2019: [Download link](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads)

### macOS Build Instructions

1. macOS Catalina 10.15.x, install Xcode >= 12 and Xcode Command Line Tools: run `xcode-select –install` in terminal.
2. Download and install HomeBrew, cmake >= 3.19: [Download link](https://cmake.org/download/)
3. Install libomp: `brew install libomp`
4. Open terminal in project root, run `./build.sh` and follow the prompts, finally select 'BIN executable'.
5. Test: `./run-test.sh` (remember to edit the target image path in the script).
6. Build JNI dynamic library (optional, for Java usage).

- Download jdk-8u221-macosx-x64.dmg and install.
- Edit the hidden file `.zshrc` in your user directory, add `export JAVA_HOME=$(/usr/libexec/java_home)`
- Run `build.sh` and follow the prompts, finally select 'JNI dynamic library'.

#### macOS Deployment Instructions

If any dependencies are dynamic libraries, refer to the following methods:

- Add the dynamic library path to DYLD_LIBRARY_PATH
- Copy or link the dynamic library to /usr/lib

### Linux Build Instructions

1. Ubuntu 18.04 LTS or other distributions (please build OpenCV and onnxruntime dependencies yourself, or adapt official dynamic libraries)
2. `sudo apt-get install build-essential`
3. g++ >= 5, cmake >= 3.17: [Download link](https://cmake.org/download/)
4. Open terminal in project root, run `./build.sh` and follow the prompts, finally select 'BIN executable'.
5. Test: `./run-test.sh` (remember to edit the target image path in the script).
6. Build JNI dynamic library (optional, for Java usage).

- Download jdk-8u221 and install/configure
- Run `build.sh` and follow the prompts, finally select 'JNI dynamic library'.
- **Note: g++ version >= 6 is required for JNI compilation.**

#### Linux Deployment Instructions

If any dependencies are dynamic libraries, refer to the following methods:

- Add the dynamic library path to LD_LIBRARY_PATH
- Copy or link the dynamic library to /usr/lib
