##############################################################################
#
#   将yolov7 fp32umodel模型转换为int8umodel
#
##############################################################################
#!/bin/bash

WORKBASE=$(dirname $(readlink -f "$0"))
root_dir=${WORKBASE}/..

if [ $# -lt 1 ];then
    echo "2.2 please input platform, eg:BM1684"
    exit -1
fi

platform=$1

output_dir="${root_dir}/data/models/${platform}/int8bmodel"
if [ ! -d "$output_dir" ]; then
    echo "create data dir: $output_dir"
    mkdir -p $output_dir
fi

echo "2.2 Start int8umodel transform......"
pushd ${output_dir}
calibration_use_pb  quantize \
            -model ${output_dir}/yolov7.torchscript_bmnetp_test_fp32.prototxt \
            -weights ${output_dir}/yolov7.torchscript_bmnetp.fp32umodel \
            -iterations 200 \
            -save_test_proto \
            -graph_transform \
            -accuracy_opt \
            -conv_group \
            -per_channel

if [ $? -eq 0 ]; then
    echo "2.2 Congratulation! Everything is OK!"
else
    echo "2.2 Something is wrong, pleae have a check!"
    popd
    exit -1
fi

popd
exit 0
