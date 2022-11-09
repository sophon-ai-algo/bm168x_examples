

# Python例程
- [Python例程](#python例程)
  - [1. 目录](#1-目录)
  - [2. 环境](#2-环境)
  - [3.  测试](#3--测试)
## 1. 目录

​	目录结构说明如下：

```
./python
├── README.md
├── utils
├── yolov7_bmcv_3output.py       # 采用bmcv预处理
├── yolov7_opencv_3output.py     # 采用opencv预处理
└── yolov7_pytorch.py

```



## 2. 环境

支持以下环境运行本程序。

### 2.1 PCIE模式

**硬件：**x86平台，并安装了168X PCIE加速卡，168X作为从设备。

**软件：**需要依赖SDK环境，具体可以参考[官网](https://developer.sophgo.com/site/index.html)说明，进行环境安装，这里不做赘述。

> 注：如报错找不到sophon时，可以参考官方文档进行sail安装

### 2.2 SOC模式

**硬件：**SE5 SE6等，168X作为主控。

**软件：**设备出厂一般会具备运行必备的环境，如果存在问题，可通过[官网](https://developer.sophgo.com/site/index/material/12/all.html)下载安装对应版本，进行固件升级。

​	对于SE5盒子，内部已经集成了相应的SDK运行库包，位于/system目录下，只需设置环境变量即可，需要设置环境变量后使用，如下：

```Bash
# 设置环境变量
export PATH=$PATH:/system/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/system/lib/:/system/usr/lib/aarch64-linux-gnu
export PYTHONPATH=$PYTHONPATH:/system/lib
```

> 注：上述环境变量配置临时生效，设备重启后需要重新配置，其他永久性配置方法可自行网上查找

如果您使用的设备是Debian系统，您可能需要安装numpy包，以在python中使用opencv和SAIL：

```Bash
# Debian 9，请指定numpy版本为1.17.2
sudo apt update
sudo apt-get install python3-pip
sudo pip3 install numpy==1.17.2
```

## 3.  测试

python程序默认有一套参数，您可以根据实际情况传入,具体参数说明如下：

```bash
usage: yolov7_opencv_3output.py [-h] [--bmodel BMODEL] [--labels LABELS]
                                [--input INPUT] [--tpu_id TPU_ID]
                                [--conf CONF] [--nms NMS] [--obj OBJ]
                                [--use_np_file_as_input USE_NP_FILE_AS_INPUT]

Demo of YOLOv7 with preprocess by OpenCV

optional arguments:
  -h, --help            show this help message and exit
  --bmodel BMODEL       bmodel file path.
  --labels LABELS       labels txt file path.
  --input INPUT         input pic/video file path.
  --tpu_id TPU_ID       tpu dev id(0,1,2,...).
  --conf CONF           test conf threshold.
  --nms NMS             test nms threshold.
  --obj OBJ             test obj conf.
  --use_np_file_as_input USE_NP_FILE_AS_INPUT
                        whether use dumped numpy file as input.
```

​	demo中支持单图和视频，按照实际情况传入参数即可。模型支持fp32bmodel、int8bmodel，可以通过传入模型路径参数进行测试：

```bash
# 测试单张图片
python yolov5_opencv.py
```
