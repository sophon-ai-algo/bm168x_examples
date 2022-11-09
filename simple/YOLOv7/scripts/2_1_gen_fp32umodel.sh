##############################################################################
# 将yolov7 torchscript模型转换为fp32umodel
# 注意：
#       1.下载的为官方原生模型，必须要先转成torchscript模型后继续后面转换
#       2.量化数据集lmdb文件可采用tools/convert_imageset.py生成
##############################################################################
#!/bin/bash

WORKBASE=$(dirname $(readlink -f "$0"))
root_dir=${WORKBASE}/..

if [ $# -lt 1 ];then
    echo "2.1 please input platform, eg:BM1684"
    exit -1
fi

platform=$1

model_dir="${root_dir}/data/models/torch/yolov7.torchscript.pt"
output_dir="${root_dir}/data/models/${platform}/int8bmodel"
if [ ! -d "$output_dir" ]; then
    echo "create data dir: $output_dir"
    mkdir -p $output_dir
fi
cali_data="${root_dir}/data/images"

echo "2.1 Start fp32umodel transform......"
pushd ${output_dir}
python3 -m ufw.tools.pt_to_umodel \
      -m ${model_dir} \
      -s '(1,3,640,640)' \
      -d ${output_dir} \
      -D ${cali_data} \
      --cmp

if [ $? -eq 0 ]; then
    echo "2.1 Congratulation! fp32umodel is done!"
else
    echo "2.1 Something is wrong, pleae have a check!"
    popd
    exit -1
fi

popd
exit 0