##############################################################################
# 将yolov7 torchscript模型转换为int8bmodel
# 注意：
#     1.下载的为官方原生模型，必须要先转成torchscript模型后继续后面转换
##############################################################################
#!/bin/bash

WORKBASE=$(dirname $(readlink -f "$0"))
root_dir=${WORKBASE}/..

if [ $# -lt 1 ];then
    echo "2.0 please input platform, eg:BM1684"
    exit -1
fi

platform=$1

model_dir="${root_dir}/data/models/torch/yolov7.torchscript.pt"
output_dir="${root_dir}/data/models/${platform}/int8bmodel"
if [ ! -d "$output_dir" ]; then
    echo "create data dir: $output_dir"
    mkdir -p $output_dir
fi

echo "2.0 start int8bmodel transform, platform: ${platform}......"

pushd ${WORKBASE}

./2_1_gen_fp32umodel.sh ${platform}
if [ $? -eq 0 ]; then
    echo "2.0 Congratulation! step1: fp32umode is done!"
else
    echo "2.0 Something is wrong, pleae have a check!"
    popd
    exit -1
fi

./2_2_gen_int8umodel.sh ${platform}
if [ $? -eq 0 ]; then
    echo "2.0 Congratulation! step2: int8umode is done!"
else
    echo "2.0 Something is wrong, pleae have a check!"
    popd
    exit -1
fi

./2_3_gen_int8bmodel.sh ${platform}
if [ $? -eq 0 ]; then
    cp ${output_dir}/compilation.bmodel ${output_dir}/../yolov7_640_v0.1_3output_int8_1b.bmodel -rf
    echo "2.0 Congratulation! int8bmode is done!"
else
    echo "2.0 Something is wrong, pleae have a check!"
    popd
    exit -1
fi

popd
exit 0
