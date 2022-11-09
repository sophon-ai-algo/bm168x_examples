

# C++例程
- [C++例程](#c例程)
  - [1. 目录说明](#1-目录说明)
  - [2.程序编译](#2程序编译)
  - [2. 1 PCIE模式](#2-1-pcie模式)
    - [2.1.1 环境](#211-环境)
    - [2.1.2 程序编译](#212-程序编译)
  - [2. 2 SOC模式](#2-2-soc模式)
    - [2.2.1 环境](#221-环境)
    - [2.2.2 程序编译](#222-程序编译)
  - [3. 测试](#3-测试)

## 1. 目录说明

​	cpp目录下提供了C++例程以供参考使用，目录结构如下：

```
./yolov7_bmcv/
├── bmnn_utils.h
├── CMakeLists.txt     # 编译脚本
├── main.cpp           # 主程序
├── README.md
├── utils.hpp
├── yolov7.cpp         # yolov7实现
└── yolov7.hpp

```

## 2.程序编译

## 2. 1 PCIE模式

### 2.1.1 环境

​	**硬件：**x86平台，并安装了168X PCIE加速卡，168X作为从设备。

​	**软件：**需要依赖SDK环境，具体可以参考[官网](https://developer.sophgo.com/site/index.html)说明，进行环境安装，这里不做赘述。

### 2.1.2 程序编译

​	C++程序运行前需要编译可执行文件，命令如下：

```bash
cd cpp/yolov7_bmcv
mkdir build
cd build
rm ./* -rf
cmake -DTARGET_ARCH=x86 -DSDK={实际sdk根路径} ..
make
```

​	运行成功后，会在build上级目录下生成可执行文件，如下：

```
yolov7_bmcv
├──......
└── yolov7_demo.pcie    #可执行程序
```

## 2. 2 SOC模式

### 2.2.1 环境

​	**硬件**：x86平台(交叉编译)

​	**软件**：需要依赖SDK环境，具体可以参考[官网](https://developer.sophgo.com/site/index.html)说明，进行环境安装，这里不做赘述。

### 2.2.2 程序编译

​	C++程序运行前需要编译可执行文件，命令如下：

```bash
cd cpp/yolov7_bmcv
mkdir build
cd build
rm ./* -rf
cmake -DTARGET_ARCH=soc -DSDK={实际sdk根路径} ..
make
```

​	运行成功后，会在build上级目录下生成可执行文件，如下：

```
yolov7_bmcv
├──......
└── yolov7_demo.soc    #可执行程序
```



## 3. 测试

可执行程序默认有一套参数，您也可以根据具体情况传入,具体参数说明如下：

```bash
Usage: yolov7_demo.pcie/soc [params]

        --bmodel (value:../../data/models/BM1684/yolov7_640_v0.1_3output_fp32_1b.bmodel)
                bmodel file path
        --classnames (value:../../data/images/coco.names)
                class names' file path
        --conf (value:0.5)
                confidence threshold for filter boxes
        --frame_num (value:0)
                number of frames in video to process, 0 means processing all frames
        --help (value:true)
                Print help information.
        --input (value:../../data/images/zidane.jpg)
                input stream file path
        --iou (value:0.5)
                iou threshold for nms
        --is_video (value:0)
                input video file path
        --obj (value:0.5)
                object score threshold for filter boxes
        --tpuid (value:0)
                TPU device id

```

​	demo中支持单图、视频测试，按照实际情况传入参数即可，默认是单图。另外，模型支持fp3bmodel、int8bmodel，可以通过传入模型路径参数进行测试：

```bash
# 测试单张图片,PCIE mode,x86环境下运行
./yolov7_demo.pcie  

# 测试单张图片,SOC mode，BM168X环境下运行
./yolov7_demo.soc  
```

注：

1. 程序执行完毕后，会通过终端打印的方式给出各阶段耗时
2. 耗时统计存在略微波动属于正常现象