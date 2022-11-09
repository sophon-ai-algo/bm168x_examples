##############################################################################
# 将yolov7 torchscript模型转换为fp32bmodel
# 注意：
#     1.下载的为官方原生模型，必须要先转成torchscript模型后继续后面转换
##############################################################################
#!/bin/bash

WORKBASE=$(dirname $(readlink -f "$0"))
root_dir=${WORKBASE}/..

if [ $# -lt 1 ];then
    echo "please input platform($#), eg:BM1684"
    exit -1
fi

platform=$1



model_dir="${root_dir}/data/models/torch/yolov7.torchscript.pt"
output_dir="${root_dir}/data/models/${platform}/fp32bmodel"
if [ ! -d "$output_dir" ]; then
    echo "create data dir: $output_dir"
    mkdir -p $output_dir
fi

echo "start fp32bmodel transform, platform: ${platform}......"
pushd ${output_dir}
python3 -m bmnetp \
       --net_name=yolov7 \
       --target=${platform} \
       --opt=1 \
       --cmp=true \
       --shapes="[1,3,640,640]" \
       --model=${model_dir} \
       --outdir=${output_dir} \
       --dyn=false

if [ $? -eq 0 ]; then
    cp ${output_dir}/compilation.bmodel ${output_dir}/../yolov7_640_v0.1_3output_fp32_1b.bmodel -rf
    echo "Congratulation! fp32bmode is done!"
    popd
    exit 0
else
    echo "Something is wrong, pleae have a check!"
    popd
    exit -1
fi
