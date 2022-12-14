# 1. Introduction

This is a simple demo to run yolov3/yolov4 with SophonSDK.

# 2. Usage

- init SophonSDK first: please refer to [SophonSDK Tutorial](https://sophgo-doc.gitbook.io/sophonsdk3/sophonsdk/setup)
- Remember to use your own anchors, mask and classes number config values in `cpp/yolov3.hpp` and `python/configs/*.yml`
- Deploy on arm SoC SE/SM, remember to [set the environmental variables](https://sophgo-doc.gitbook.io/sophonsdk3/sophonsdk/setup/on-soc#1.5.3.2-yun-hang-huan-jing-pei-zhi)
- For INT8 BModel, do not forget the scale factors for input and output tensors

## 2.1 prepare test data

use `scripts/0_prepare_test_data.sh` to download test images data and videos data to `data/`

```bash
cd scripts
bash ./0_prepare_test_data.sh
```

## 2.2 prepare bmodel

Bmodel must be compiled in SophonSDK dev docker. 

### 2.2.1 fp32 bmodel

use `scripts/download.sh` to download the yolov4.weights and yolov4.cfg, then use `scripts/gen_fp32bmodel.sh` to generate fp32 bmodel from `.cfg` and `.weights`, and `.bmodel` will be saved in `../data/models/`:

```bash
cd scripts
bash ./download.sh
bash ./gen_fp32bmodel.sh
```

use `bmnetd` in SophonSDK dev docker to generate other fp32 bmodels.

### 2.2.2 int8 bmodel

Follow the instructions in [Quantization-Tools User Guide](https://doc.sophgo.com/docs/3.0.0/docs_latest_release/nntc/NNToolChain_zh.pdf) to generate int8 bmodel, the typical steps are:

- use `ufwio.io` to generate LMDB from images
- use `bmnetd --mode=GenUmodel` to generate fp32 umodel from `.cfg` and `.weights`
- use `calibration_use_pb quantize` to generate int8 umodel from fp32 umodel
- use `bmnetu` to generate int8 bmodel from int8 umodel

### 2.2.3 prepared bmodels

Several bmodels converted from [darknet](https://github.com/AlexeyAB/darknet) yolov3/yolov4  trained on [MS COCO](http://cocodataset.org/#home) are provided.

> Download bmodels from [here](http://219.142.246.77:65000/sharing/SJ4gY5Nzz) and put them in `data/models/` directory
>

| 模型文件                       | 输入                                                | 输出                                                         | anchors and masks                                            |
| ------------------------------ | --------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| yolov3_416_coco_fp32_1b.bmodel | input: data, [1, 3, 416, 416], float32, scale: 1    | output: Yolo0, [1, 255, 13, 13], float32, scale: 1<br/>output: Yolo1, [1, 255, 26, 26], float32, scale: 1<br/>output: Yolo2, [1, 255, 52, 52], float32, scale: 1 | YOLO_MASKS: [6, 7, 8, 3, 4, 5, 0, 1, 2]<br />YOLO_ANCHORS: [10, 13, 16, 30, 33, 23, 30, 61, 62, 45,59, 119, 116, 90, 156, 198, 373, 326] |
| yolov3_608_coco_fp32_1b.bmodel | input: data, [1, 3, 608, 608], float32, scale: 1    | output: Yolo0, [1, 255, 19, 19], float32, scale: 1<br/>output: Yolo1, [1, 255, 38, 38], float32, scale: 1<br/>output: Yolo2, [1, 255, 76, 76], float32, scale: 1 | YOLO_MASKS: [6, 7, 8, 3, 4, 5, 0, 1, 2]<br />YOLO_ANCHORS: [10, 13, 16, 30, 33, 23, 30, 61, 62, 45, 59, 119, 116, 90, 156, 198, 373, 326] |
| yolov4_416_coco_fp32_1b.bmodel | input: data, [1, 3, 416, 416], float32, scale: 1    | output: Yolo0, [1, 255, 52, 52], float32, scale: 1<br/>output: Yolo1, [1, 255, 26, 26], float32, scale: 1<br/>output: Yolo2, [1, 255, 13, 13], float32, scale: 1 | YOLO_MASKS: [0, 1, 2, 3, 4, 5, 6, 7, 8]<br />YOLO_ANCHORS: [12, 16, 19, 36, 40, 28, 36, 75, 76, 55, 72, 146, 142, 110, 192, 243, 459, 401] |
| yolov4_608_coco_fp32_1b.bmodel | input: data, [1, 3, 608, 608], float32, scale: 1    | output: Yolo0, [1, 255, 76, 76], float32, scale: 1<br/>output: Yolo1, [1, 255, 38, 38], float32, scale: 1<br/>output: Yolo2, [1, 255, 19, 19], float32, scale: 1 | YOLO_MASKS: [0, 1, 2, 3, 4, 5, 6, 7, 8]<br /> YOLO_ANCHORS: [12, 16, 19, 36, 40, 28, 36, 75, 76, 55, 72, 146, 142, 110, 192, 243, 459, 401] |
| yolov4_608_coco_int8_1b.bmodel | input: data, [1, 3, 608, 608], int8, scale: 127.986 | output: Yolo0, [1, 255, 76, 76], float32, scale: 0.0078125<br/>output: Yolo1, [1, 255, 38, 38], float32, scale: 0.0078125<br/>output: Yolo2, [1, 255, 19, 19], float32, scale: 0.0078125 | YOLO_MASKS: [0, 1, 2, 3, 4, 5, 6, 7, 8]<br /> YOLO_ANCHORS: [12, 16, 19, 36, 40, 28, 36, 75, 76, 55, 72, 146, 142, 110, 192, 243, 459, 401] |

## 2.3 cpp demo usage

### 2.3.1 for x86 with PCIe cards

- compile the application in SophonSDK dev docker

```shell
$ cd cpp/cpp_cv_bmcv_bmrt_postprocess
$ make -f Makefile.pcie # will generate yolo_test.pcie
```

- then put yolo_test.pcie, configs dir with `.cfg`  and data dir on pcie host with bm1684

```shell
$ realpath ../../data/images/* > imagelist.txt
$ ./yolo_test.pcie image imagelist.txt ${configs}/yolov4.cfg ../../data/models/yolov4_416_coco_fp32_1b.bmodel 4 0 0.5 0.45

# USAGE:
#  ./yolo_test.pcie image <image list> <cfg file> <bmodel file> <test count> <device id> <conf thresh> <nms thresh>
#  ./yolo_test.pcie video <video list> <cfg file> <bmodel file> <test count> <device id> <conf thresh> <nms thresh>
```

> choose the correct `.cfg` with your bmodel.

### 2.3.2 for arm SoC

- compile the application in SophonSDK dev docker


```shell 
$ cd cpp/cpp_cv_bmcv_bmrt_postprocess
$ make -f Makefile.arm # will generate yolo_test.arm
```
- then put yolo_test.arm, configs dir with `.cfg` and data dir on SoC

```shell
$ realpath ../../data/images/* > imagelist.txt
$ ./yolo_test.arm image imagelist.txt ${configs}/yolov4.cfg ../../data/models/yolov4_416_coco_fp32_1b.bmodel 4 0 0.5 0.45

# USAGE:
#  ./yolo_test.arm image <image list> <cfg file> <bmodel file> <test count> <device id> <conf thresh> <nms thresh>
#  ./yolo_test.arm video <video list> <cfg file> <bmodel file> <test count> <device id> <conf thresh> <nms thresh>
```

choose the correct `.cfg` with your bmodel.

## 2.4 python demo usage

> Notes：For Python codes,  create your own config file *.yml in `configs` based on the values of `ENGINE_FILE`, `LABEL_FILE `, `YOLO_MASKS`, `YOLO_ANCHORS`, `OUTPUT_TENSOR_CHANNELS` for your model.

### 2.4.1 for x86 with PCIe cards & arm SoC

#### Installations

- for x86 with PCIe cards, the environment variable is set when `source envsetup_pcie.sh`, you need to install SAIL

```bash
# for example, python3.7 in docker
cd /workspace/lib/sail/python3/pcie/py37
pip3 install sophon-<x.y.z>-py3-none-any.whl
```

you also need to install other requirements

```bash
# for example, python3.7 in docker
pip3 install easydict
```

- for arm SoC, you need to set the environment variable:

```bash
# set the environment variable
export PATH=$PATH:/system/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/system/lib/:/system/usr/lib/aarch64-linux-gnu
export PYTHONPATH=$PYTHONPATH:/system/lib
```

you probably need to install NumPy, then you could use OpenCV and SAIL:

```bash
# for Debian 9, please specify numpy version 1.17.2
sudo apt update
sudo apt-get install python3-pip
sudo pip3 install numpy==1.17.2
```

you also need to install other requirements

```bash
sudo apt-get install -y libjpeg-dev zlib1g-dev
sudo pip3 install Pillow pyyaml easydict
```

finally you need to copy the prepared `data/images`, `data/videos` and `data/models` in SophonSDK dev docker to `${yolov34}/data` directory.

#### Usages

``` shell
$ cd python
$ python3 main.py # default: --cfgfile=configs/yolov3_416.yml --input=../data/images/person.jpg
#$ python3 main.py --cfgfile=<config file> --input=<image file path>
#$ python3 main.py --help # show help info
```
