cmake_minimum_required(VERSION 3.5)
project(yolov7)

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR})
message("cur dir: ${PROJECT_SOURCE_DIR}")

if (NOT DEFINED TARGET_ARCH)
    set(TARGET_ARCH x86)
endif()

if (NOT DEFINED SDK)
    message(FATAL_ERROR "please input the root path of SDK")    
endif()

if (${TARGET_ARCH} STREQUAL "x86")
    message( "${TARGET_ARCH} mode, starting......")
    message( "SDK path: ${SDK}")
    include_directories(
        ${SDK}/include 
        ${SDK}/include/bmruntime 
        ${SDK}/include/bmlib 
        ${SDK}/include/third_party/boost/include  
        ${SDK}/NeuralNetwork/include 
        ${SDK}/include/opencv/opencv4 
        ${SDK}/include/ffmpeg 
    )

    link_directories(
        ${SDK}/lib/thirdparty/x86 
        ${SDK}/lib/sys/x86 
        ${SDK}/lib/bmnn/pcie 
        ${SDK}/lib/opencv/x86 
        ${SDK}/lib/ffmpeg/x86 
        ${SDK}/lib/decode/x86
    )    

    set(DEPEND_LIB bmrt bmlib bmcv dl opencv_core opencv_imgproc 
            opencv_imgcodecs opencv_videoio bmvideo swresample swscale 
            avformat avutil protobuf gflags glog boost_system boost_filesystem 
            pthread bmjpuapi bmjpulite)    

    set(CMAKE_CXX_FLAGS "-Wall -std=c++11 -ldl")

    aux_source_directory(. SRC_FILES)
    add_executable(yolov7_demo.pcie ${SRC_FILES})
    target_link_libraries(yolov7_demo.pcie ${DEPEND_LIB})

elseif (${TARGET_ARCH} STREQUAL "soc")
    message( "${TARGET_ARCH} mode, starting......")
    message( "SDK path: ${SDK}")

    set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
    set(CMAKE_ASM_COMPILER aarch64-linux-gnu-gcc)
    set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

    include_directories(
        ${SDK}/include 
        ${SDK}/include/bmruntime 
        ${SDK}/include/bmlib 
        ${SDK}/include/third_party/boost/include  
        ${SDK}/NeuralNetwork/include 
        ${SDK}/include/opencv/opencv4 
        ${SDK}/include/ffmpeg 
    )

    link_directories(
        ${SDK}/lib/thirdparty/soc 
        ${SDK}/lib/bmnn/soc
        ${SDK}/lib/opencv/soc
        ${SDK}/lib/ffmpeg/soc
        ${SDK}/lib/decode/soc
    )

    set(DEPEND_LIB bmrt bmlib bmcv dl opencv_core opencv_imgproc 
            opencv_imgcodecs opencv_videoio bmvideo swresample swscale 
            avformat avutil protobuf gflags glog boost_system boost_filesystem 
            pthread bmjpuapi bmjpulite)  

    set(CMAKE_CXX_FLAGS "-O2 -Wall -std=c++11 -ldl")
    aux_source_directory(. SRC_FILES)
    add_executable(yolov7_demo.soc ${SRC_FILES})
    target_link_libraries(yolov7_demo.soc ${DEPEND_LIB})
else ()
    message( FATAL_ERROR  "not support mode, eg: soc/x86, cur: ${TARGET_ARCH}")
endif ()