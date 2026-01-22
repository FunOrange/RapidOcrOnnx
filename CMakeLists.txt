if (WIN32)
    cmake_minimum_required(VERSION 3.12)
elseif (APPLE)
    cmake_minimum_required(VERSION 3.17)
elseif (UNIX)
    cmake_minimum_required(VERSION 3.17)
endif ()
project(RapidOcrOnnx)

# Output BIN JNI CLIB
if (NOT DEFINED OCR_OUTPUT)
    set(OCR_OUTPUT "BIN")
    message(STATUS "No OCR_OUTPUT, defaulting to BIN")
endif ()
option(OCR_BENCHMARK "build benchmark" ON)
set(OCR_BENCHMARK ON)
#set(OCR_OUTPUT "BIN")

if (NOT DEFINED OCR_ONNX)
    set(OCR_ONNX "CPU")
    message(STATUS "No OCR_ONNX, defaulting to CPU")
endif ()
#set(OCR_OUTPUT "GPU")

#set(CMAKE_CXX_STANDARD 11)
add_definitions(-DUNICODE -D_UNICODE)
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_definitions("-Wall -g -O0")
else ()
    add_definitions("-Wall")
endif ()

# OnnxRuntime (manual linking for prebuilt binaries)
if (OCR_ONNX STREQUAL "CPU")
    set(ONNXRUNTIME_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/onnxruntime-static/windows-x64/include")
    set(ONNXRUNTIME_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/onnxruntime-static/windows-x64/lib")
elseif (OCR_ONNX STREQUAL "CUDA") # CUDA
    set(ONNXRUNTIME_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/onnxruntime-gpu/windows-x64/include")
    set(ONNXRUNTIME_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/onnxruntime-gpu/windows-x64/lib")
elseif (OCR_ONNX STREQUAL "DIRECTML") # DIRECTML
    set(ONNXRUNTIME_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/onnxruntime-DirectML/windows-x64/include")
    set(ONNXRUNTIME_LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/onnxruntime-DirectML/windows-x64/lib")
endif ()
include_directories(${ONNXRUNTIME_INCLUDE_DIR})
link_directories(${ONNXRUNTIME_LIB_DIR})
set(ONNXRUNTIME_LIBS onnxruntime)

# OpenCV
set(BUILD_SHARED_LIBS false)
include(${CMAKE_CURRENT_SOURCE_DIR}/opencv-static/OpenCVWrapperConfig.cmake)
find_package(OpenCV REQUIRED)
if (OpenCV_FOUND)
    message(STATUS "OpenCV_LIBS: ${OpenCV_LIBS}")
    message(STATUS "OpenCV_INCLUDE_DIRS: ${OpenCV_INCLUDE_DIRS}")
else ()
    message(FATAL_ERROR "opencv Not Found!")
endif (OpenCV_FOUND)

# project include
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# source
file(GLOB OCR_SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
set(OCR_COMPILE_CODE ${OCR_SRC})

# JNI
if (OCR_OUTPUT STREQUAL "JNI")
    find_package(JNI REQUIRED)
    if (JNI_FOUND)
        message("JNI FOUND")
        message(STATUS "JNI_LIBS: ${JNI_LIBS}")
        message(STATUS "JNI_INCLUDE_DIRS: ${JNI_INCLUDE_DIRS}")
        include_directories(${JNI_INCLUDE_DIRS})
    else ()
        message(FATAL_ERROR "JNI Not Found!")
    endif ()
endif ()

if (OCR_OUTPUT STREQUAL "JNI") # JNI
    add_library(RapidOcrOnnx SHARED ${OCR_COMPILE_CODE})
    target_compile_definitions(RapidOcrOnnx PRIVATE __JNI__)
    target_link_libraries(RapidOcrOnnx ${ONNXRUNTIME_LIBS} ${OpenCV_LIBS} ${JNI_LIBS})
elseif (OCR_OUTPUT STREQUAL "CLIB") # CLIB
    add_library(RapidOcrOnnx SHARED ${OCR_COMPILE_CODE})
    target_compile_definitions(RapidOcrOnnx PRIVATE __CLIB__)
    target_link_libraries(RapidOcrOnnx ${ONNXRUNTIME_LIBS} ${OpenCV_LIBS})
elseif (OCR_OUTPUT STREQUAL "BIN") # BIN
    add_executable(RapidOcrOnnx ${OCR_COMPILE_CODE})
    target_compile_definitions(RapidOcrOnnx PRIVATE __EXEC__)
    target_link_libraries(RapidOcrOnnx ${ONNXRUNTIME_LIBS} ${OpenCV_LIBS})
endif ()

install(TARGETS RapidOcrOnnx EXPORT RapidOcrOnnx)
if (OCR_OUTPUT STREQUAL "CLIB") # CLIB
    file(GLOB OCR_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h)
    install(FILES ${OCR_INCLUDE} DESTINATION include)
endif ()

if (OCR_ONNX STREQUAL "CUDA")
    target_compile_definitions(RapidOcrOnnx PRIVATE __CUDA__)
elseif(OCR_ONNX STREQUAL "DIRECTML")
    target_compile_definitions(RapidOcrOnnx PRIVATE __DIRECTML__)
endif ()

# benchmark
if (OCR_BENCHMARK AND (OCR_OUTPUT STREQUAL "BIN"))
    add_executable(benchmark benchmark/benchmark.cpp
            src/AngleNet.cpp
            src/clipper.cpp
            src/CrnnNet.cpp
            src/DbNet.cpp
            src/getopt.cpp
            src/OcrLiteImpl.cpp
            src/OcrLite.cpp
            src/OcrUtils.cpp)
    target_link_libraries(benchmark ${ONNXRUNTIME_LIBS} ${OpenCV_LIBS})
    target_compile_definitions(benchmark PRIVATE __EXEC__)

    if (OCR_ONNX STREQUAL "CUDA")
        target_compile_definitions(benchmark PRIVATE __CUDA__)
    endif ()
    install(TARGETS benchmark EXPORT benchmark
            ARCHIVE DESTINATION staticlib
            LIBRARY DESTINATION sharedlib
            RUNTIME DESTINATION bin)
endif ()

# Windows Link CRT
if (OCR_BUILD_CRT STREQUAL "True")
    include(${CMAKE_CURRENT_SOURCE_DIR}/OcrCRTLinkage.cmake)
endif ()
