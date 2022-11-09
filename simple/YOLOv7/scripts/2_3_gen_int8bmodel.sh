##############################################################################
#
#   将yolov7 int8umodel模型转换为int8bmodel
#
##############################################################################
#!/bin/bash

WORKBASE=$(dirname $(readlink -f "$0"))
root_dir=${WORKBASE}/..

if [ $# -lt 1 ];then
    echo "2.3 please input platform, eg:BM1684"
    exit -1
fi

platform=$1

output_dir="${root_dir}/data/models/${platform}/int8bmodel"
if [ ! -d "$output_dir" ]; then
    echo "create data dir: $output_dir"
    mkdir -p $output_dir
fi

echo "2.3 Start int8bmodel transform, platform: ${platform}......"
pushd ${output_dir}
bmnetu \
    -model ${output_dir}/yolov7.torchscript_bmnetp_deploy_int8_unique_top.prototxt \
    -weight ${output_dir}/yolov7.torchscript_bmnetp.int8umodel \
    -target ${platform} \
    -outdir ${output_dir} \
    -cmp true

if [ $? -eq 0 ]; then
    cp ${output_dir}/compilation.bmodel ${output_dir}/yolov7_640_v0.1_3output_int8_1b.bmodel -rf
    echo "2.3 Congratulation! Everything is OK!"
else
    echo "2.3 Something is wrong, pleae have a check!"
    popd
    exit -1
fi

popd
exit 0
