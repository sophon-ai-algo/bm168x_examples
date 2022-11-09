# YOLOv7

- [YOLOv7](#yolov7)
  - [1. 简介](#1-简介)
  - [2. 数据集](#2-数据集)
  - [3. 准备数据与模型](#3-准备数据与模型)
  - [4. 模型编译](#4-模型编译)
    - [4.1 生成FP32 BModel](#41-生成fp32-bmodel)
    - [4.2 生成INT8 BModel](#42-生成int8-bmodel)
  - [5. 例程测试](#5-例程测试)

## 1. 简介

​	`YOLOv7`在 5 FPS 到 160 FPS 范围内的速度和准确度都超过了所有已知的目标检测器，并且在 GPU V100 上 30 FPS 或更高的所有已知实时目标检测器中，具有最高的准确度 56.8% AP。

​	`YOLOv7-E6`（56 FPS V100，55.9% AP）比基于`Transformer`的检测器 `SWIN-L Cascade-Mask R-CNN`（9.2 FPS A100，53.9% AP）的速度和准确度分别高出 509% 和 2%，并且比基于卷积的检测器 `ConvNeXt-XL Cascade-Mask R-CNN` (8.6 FPS A100, 55.2% AP) 速度提高 551%，准确率提高 0.7%，以及 `YOLOv7` 的表现还优于：`YOLOR`、`YOLOX`、`Scaled-YOLOv4`、`YOLOv5`、 `DETR`、`Deformable DETR`、`DINO-5scale-R50`、`ViT-Adapter-B` 和许多其他速度和准确度的目标检测算法。此外，`YOLOv7`基于 `MS COCO` 数据集上从零开始训练 ，未使用任何其他数据集或预训练的权重。

**文档:** [YOLOv7文档](https://arxiv.org/abs/2207.02696)

**参考repo:** [yolov7](https://github.com/WongKinYiu/yolov7)

## 2. 数据集

​	YOLOv7基于[COCO2017数据集](https://cocodataset.org/#home)，该数据集是一个可用于图像检测（image detection），语义分割（semantic segmentation）和图像标题生成（image captioning）的大规模数据集。它有超过330K张图像（其中220K张是有标注的图像），包含150万个目标，80个目标类别（object categories：行人、汽车、大象等），91种材料类别（stuff categoris：草、墙、天空等），每张图像包含五句图像的语句描述，且有250,000个带关键点标注的行人。

## 3. 准备数据与模型

​	Pytorch的模型在编译前要经过`torch.jit.trace`，trace后的模型才能用于编译BModel。trace的方法和原理可参考[torch.jit.trace参考文档](https://vscode-remote+ssh-002dremote-002b11-002e73-002e12-002e77.vscode-resource.vscode-cdn.net/home/jin.zhang/chencp/examples/docs/torch.jit.trace参考文档.md)。

​	同时，您需要准备用于测试的数据，如果量化模型，还要准备用于量化的数据集。

​	本例程在`scripts`目录下提供了相关模型和数据集的下载脚本，您也可以自己准备模型和数据集，并参考[4. 模型转换](https://vscode-remote+ssh-002dremote-002b11-002e73-002e12-002e77.vscode-resource.vscode-cdn.net/home/jin.zhang/chencp/examples/LPRNet/README.md#4-模型转换)进行模型转换。脚本说明如下：

```
./scripts/
|-- 0_prepare_model_data.sh       # 下载模型、测试数据、数据集等
|-- 1_gen_fp32bmodel.sh           # 一键生成fp32bmodel
|-- 2_0_auto_gen_int8bmodel.sh    # 一键生成int8bmodel
|-- 2_1_gen_fp32umodel.sh         # 分步生成int8bmodel
|-- 2_2_gen_int8umodel.sh         # 分步生成int8bmodel
`-- 2_3_gen_int8bmodel.sh         # 分步生成int8bmodel
```

​	执行`0_prepare_model_data.sh`会自动下载程序执行需要的测试图片、bmodel、量化数据集等，如下所示（具体可能会有差异，以实际为准）：

```
./data/
├── images
│   ├── coco                      # 解压后的coco2017val
│   ├── coco200                   # 挑选出的量化数据集
│   ├── coco2017val.zip           # 官方数据集
│   ├── coco.names                # 类别名
│   ├── data.mdb                  # lmdb格式的数据集
│   ├── dog.jpg                   # 测试图片
│   └── zidane.jpg                # 测试图片
├── models
│   ├── BM1684                    # bmodel
│   └── torch                     # 官方trace后的pt模型
└── videos                        # 测试视频
    └── dance.mp4
```

​	模型信息：

| 模型名称 | [yolov7.pt](https://github.com/WongKinYiu/yolov7/releases/download/v0.1/yolov7.pt) |
| :------- | :----------------------------------------------------------- |
| 训练集   | MS COCO                                                      |
| 概述     | 80类通用目标检测                                             |
| 输入数据 | images, [batch_size, 3, 640, 640], FP32，NCHW，RGB planar    |
| 输出数据 | [batch_size, 3, 80, 80, 85], FP32 <br /> [batch_size, 3, 40, 40, 85], FP32  <br /> [batch_size, 3, 20, 20, 85], FP32  <br /> |
| 其他信息 | YOLO_ANCHORS: [12,16, 19,36, 40,28,  36,75, 76,55, 72,146,  142,110, 192,243, 459,401] |
| 前处理   | BGR->RGB、/255.0                                             |
| 后处理   | nms等                                                        |

## 4. 模型编译

​	trace后的pytorch模型需要编译成BModel才能在SOPHON TPU上运行，如果使用下载好的BModel可跳过本节。

​	模型编译前需要搭建环境，具体可参考[官方指导](https://developer.sophgo.com/site/index/document/all/all.html)进行搭建，根据SDK版本不同，环境搭建方式略有不同，这里不做赘述。

### 4.1 生成FP32 BModel

​	pytorch模型编译为FP32 BModel，具体方法可参考[BMNETP 使用](https://doc.sophgo.com/docs/3.0.0/docs_latest_release/nntc/html/usage/bmnetp.html)。

​	本例程在`scripts`目录下提供了编译FP32 BModel的脚本。请注意修改`2_1_gen_fp32bmodel.sh`中的JIT模型路径、生成模型目录和输入大小shapes等参数，并在执行时指定BModel运行的目标平台（如BM1684等）：

```bash
cd ./scripts
./1_gen_fp32bmodel.sh BM1684
```

​	执行上述命令会在`data/models/BM1684/`下生成fp32bmodel文件，即可以在对应平台运行的模型文件。

### 4.2 生成INT8 BModel

​	如无量化需求，可以跳过本节内容。

​	pytorch模型的量化方法可参考[官方指导](https://doc.sophgo.com/docs/3.0.0/docs_latest_release/calibration-tools/html/index.html)中相关说明。

​	本例程在`scripts`目录下提供了量化INT8 BModel的脚本，默认参数可以直接执行，也可以根据实际需要，修改脚本中JIT模型路径、生成模型目录和输入大小shapes等参数，在执行时需要输入BModel的目标平台（如BM1684等）：

```shell
cd ./scripts
./2_0_auto_gen_int8bmodel.sh BM1684
```

​	上述脚本会在`data/models/BM1684/`下生成int8bmodel文件，，即可以在对应平台运行的模型文件。

> **YOLOv7模型量化建议（也可参考[官方量化手册指导](https://doc.sophgo.com/docs/3.0.0/docs_latest_release/calibration-tools/html/module/chapter7.html)）：**
>
> 1. 制作lmdb量化数据集时，通过convert_imageset.py完成数据的预处理；
> 2. 尝试不同的iterations进行量化可能得到较明显的精度提升；
> 3. 最后一层conv到输出之间层之间设置为fp32，可能得到较明显的精度提升；
>
> 4. 尝试采用不同优化策略，比如：图优化、卷积优化，可能会得到较明显精度提升。

## 5. 例程测试

- [C++例程](./cpp/README.md)
- [Python例程](./python/README.md)