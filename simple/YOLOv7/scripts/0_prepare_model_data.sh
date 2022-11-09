#!/bin/bash

pip3 install dfn

root_dir=$(cd `dirname $BASH_SOURCE[0]`/../ && pwd)
model_path=${root_dir}/data/models
images_path=${root_dir}/data/images
videos_path=${root_dir}/data/videos

pushd ${root_dir}


function download_val_dataset()
{
  if [ ! -d ${images_path} ]; then
    mkdir ${images_path} -p
  fi
  pushd ${images_path}

  if [ -d "coco200" ]; then
    echo "coco image 200 exists"
    return 0
  fi

  # download val dataset
  if [ ! -f "coco2017val.zip" ]; then
    echo "download coco2017 val dataset from github"
    # wget https://github.com/ultralytics/yolov5/releases/download/v1.0/coco2017val.zip
    # if [ $? -ne 0 ];then
    #   echo "download coco2017 val dataset failed!"
    #   popd
    #   exit 1
    # fi
    python3 -m dfn --url  http://219.142.246.77:65000/sharing/vMUK6RYBZ
  fi

  if [ ! -d "coco" ]; then
    echo "unzip coco2017val.zip"
    unzip coco2017val.zip
  fi

  # choose 200 images and copy to ./images/coco200
  mkdir coco200 -p
  ls -l coco/images/val2017 | sed -n '2,201p' | awk -F " " '{print $9}' | xargs -t -i cp ./coco/images/val2017/{} ./coco200/
  echo "200 jpg files has been choosen"

  # 下载制作好的lmdb数据集
  if [ ! -f "data.mdb" ]; then
    python3 -m dfn --url  http://219.142.246.77:65000/sharing/r7ntm0UOI
  fi

  popd
}

function download_model()
{
  # JIT模型
  if [ ! -d "${model_path}/torch" ]; then
    mkdir ${model_path}/torch -p
  fi

  pushd ${model_path}/torch
  if [ ! -f "yolov7.torchscript.pt" ]; then
    echo "start downloading yolov7.torchscript.pt"
    python3 -m dfn --url  http://219.142.246.77:65000/sharing/hGzFIooRq
    
    if [ $? -eq 0 ]; then
      echo "download torchscript done!"
    else
        echo "Something is wrong, pleae have a check!"
        popd
        exit -1
    fi
  fi
  popd

  # fp32bmodel
  if [ ! -d "${model_path}/BM1684" ]; then
    mkdir ${model_path}/BM1684 -p
  fi

  pushd ${model_path}/BM1684
  if [ ! -f "yolov7_640_v0.1_3output_fp32_1b.bmodel" ]; then
    echo "start downloading BM1684 fp32 bmodel"
    python3 -m dfn --url  http://219.142.246.77:65000/sharing/XHgwJEaxS
    popd
    if [ $? -eq 0 ]; then
      echo "BM1684 fp32 bmodel done!"        
    else
        echo "Something is wrong, pleae have a check!"
        exit -1
    fi
  fi
 
  # int8bmodel
  if [ ! -d "${model_path}/BM1684" ]; then
    mkdir ${model_path}/BM1684 -p
  fi

  pushd ${model_path}/BM1684
  if [ ! -f "yolov7_640_v0.1_3output_int8_1b.bmodel" ]; then
    echo "start downloading BM1684 int8 bmodel"
    python3 -m dfn --url  http://219.142.246.77:65000/sharing/UC3lMzYLs
    popd
    if [ $? -eq 0 ]; then
      echo "BM1684 int8 bmodel done!"
    else
        echo "Something is wrong, pleae have a check!"
        exit -1
    fi
  fi
}

function download_test_data()
{
  echo "start downloading test data"
  # 测试图片
  if [ ! -d ${images_path} ]; then
    mkdir ${images_path} -p
  fi
  pushd ${images_path}
  python3 -m dfn --url  http://219.142.246.77:65000/sharing/Fol0BuTA0
  python3 -m dfn --url  http://219.142.246.77:65000/sharing/mWdrrPbpn
  popd

  # 测试视频
  if [ ! -d ${videos_path} ]; then
    mkdir ${videos_path} -p
  fi
  pushd ${videos_path}
  python3 -m dfn --url  http://219.142.246.77:65000/sharing/A7C4AXUfY
  popd

  echo "download test data done"
}

download_val_dataset
download_model
download_test_data
popd
