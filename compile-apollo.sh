#!/bin/sh

# Some general variables
PHONE="apollo"
ARCH="arm64"
SUBARCH="arm64"
DEFCONFIG=nogravity-${PHONE}_defconfig
COMPILER=clang
LINKER="lld"
COMPILERDIR="/media/pierre/Expension/Android/PocoX3Pro/Kernels/Proton-Clang"

# Copy gpu dtsi
cp arch/arm64/boot/dts/vendor/qcom/kona-v2-gpu-xxxx/kona-v2-gpu-${PHONE}.dtsi arch/arm64/boot/dts/vendor/qcom/kona-v2-gpu.dtsi

# Copy touch fw
cp touch_fw/* drivers/input/touchscreen/focaltech_3658u/include/firmware/
cp touch_fw/* drivers/input/touchscreen/focaltech_spi/include/firmware/
cp touch_fw/* drivers/input/touchscreen/focaltech_touch/include/firmware/
cp touch_fw/* drivers/input/touchscreen/focaltech_touch/include/pramboot/

# Cleanup output
rm -rf out/outputs/${PHONE}/*

# Export shits
export KBUILD_BUILD_USER=Pierre2324
export KBUILD_BUILD_HOST=G7-7588

# Speed up build process
MAKE="./makeparallel"

# Basic build function
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

Build () {
PATH="${COMPILERDIR}/bin:${PATH}" \
make -j$(nproc --all) O=out \
ARCH=${ARCH} \
LLVM=1 \
LLVM_IAS=1 \
CC=${COMPILER} \
CROSS_COMPILE=${COMPILERDIR}/bin/aarch64-linux-gnu- \
CROSS_COMPILE_COMPAT=${COMPILERDIR}/bin/arm-linux-gnueabi- \
LD_LIBRARY_PATH=${COMPILERDIR}/lib \
Image.gz-dtb dtbo.img
}

Build_lld () {
PATH="${COMPILERDIR}/bin:${PATH}" \
make -j$(nproc --all) O=out \
ARCH=${ARCH} \
LLVM=1 \
LLVM_IAS=1 \
CC=${COMPILER} \
CROSS_COMPILE=${COMPILERDIR}/bin/aarch64-linux-gnu- \
CROSS_COMPILE_COMPAT=${COMPILERDIR}/bin/arm-linux-gnueabi- \
LD=ld.${LINKER} \
AR=llvm-ar \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
OBJDUMP=llvm-objdump \
STRIP=llvm-strip \
ld-name=${LINKER} \
KBUILD_COMPILER_STRING="Proton Clang" \
Image.gz-dtb dtbo.img
}

dts_source=arch/arm64/boot/dts/vendor/qcom
# Correct panel dimensions on MIUI builds
miui_fix_dimens()
{
    sed -i 's/<154>/<1537>/g' $dts_source/dsi-panel-j1s*
    sed -i 's/<154>/<1537>/g' $dts_source/dsi-panel-j2*
    sed -i 's/<155>/<1544>/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
    sed -i 's/<155>/<1545>/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/<155>/<1546>/g' $dts_source/dsi-panel-k11a-38-08-0a-dsc-cmd.dtsi
    sed -i 's/<155>/<1546>/g' $dts_source/dsi-panel-l11r-38-08-0a-dsc-cmd.dtsi
    sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
    sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-k11a-38-08-0a-dsc-cmd.dtsi
    sed -i 's/<70>/<695>/g' $dts_source/dsi-panel-l11r-38-08-0a-dsc-cmd.dtsi
    sed -i 's/<71>/<710>/g' $dts_source/dsi-panel-j1s*
    sed -i 's/<71>/<710>/g' $dts_source/dsi-panel-j2*
}

# Enable back mi smartfps while disabling qsync min refresh-rate
miui_fix_fps()
{
    sed -i 's/qcom,mdss-dsi-qsync-min-refresh-rate/\/\/qcom,mdss-dsi-qsync-min-refresh-rate/g' $dts_source/dsi-panel*
    sed -i 's/\/\/ mi,mdss-dsi-smart-fps-max_framerate/mi,mdss-dsi-smart-fps-max_framerate/g' $dts_source/dsi-panel*
    sed -i 's/\/\/ mi,mdss-dsi-pan-enable-smart-fps/mi,mdss-dsi-pan-enable-smart-fps/g' $dts_source/dsi-panel*
    sed -i 's/\/\/ qcom,mdss-dsi-pan-enable-smart-fps/qcom,mdss-dsi-pan-enable-smart-fps/g' $dts_source/dsi-panel*
}

# Enable back refresh rates supported on MIUI
miui_fix_dfps()
{
    sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-37-02-0a-dsc-video.dtsi
    sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-37-02-0b-dsc-video.dtsi
    sed -i 's/120 90 60/120 90 60 50 30/g' $dts_source/dsi-panel-g7a-36-02-0c-dsc-video.dtsi
    sed -i 's/144 120 90 60/144 120 90 60 50 48 30/g' $dts_source/dsi-panel-j3s-37-02-0a-dsc-video.dtsi
}

# Enable back MI fod dimlayer support on MIUI
miui_fix_fod()
{
    sed -i 's/\/\/39 00 00 00 00 00 03 51 03 FF/39 00 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j9-38-0a-0a-fhd-video.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 03 51 0D FF/39 00 00 00 00 00 03 51 0D FF/g' $dts_source/dsi-panel-j2-p2-1-38-0c-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-mp-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2-mp-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2-p2-1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 00 00 00 00 00 05 51 0F 8F 00 00/39 00 00 00 00 00 05 51 0F 8F 00 00/g' $dts_source/dsi-panel-j2s-mp-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 00 00/39 01 00 00 00 00 03 51 00 00/g' $dts_source/dsi-panel-j2-38-0c-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 00 00/39 01 00 00 00 00 03 51 00 00/g' $dts_source/dsi-panel-j2-38-0c-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 03 FF/39 01 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 03 FF/39 01 00 00 00 00 03 51 03 FF/g' $dts_source/dsi-panel-j9-38-0a-0a-fhd-video.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j1u-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j2-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 07 FF/39 01 00 00 00 00 03 51 07 FF/g' $dts_source/dsi-panel-j2-p1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j1u-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j2-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 03 51 0F FF/39 01 00 00 00 00 03 51 0F FF/g' $dts_source/dsi-panel-j2-p1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j1s-42-02-0a-mp-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2-mp-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2-p2-1-42-02-0b-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 00 00 05 51 07 FF 00 00/39 01 00 00 00 00 05 51 07 FF 00 00/g' $dts_source/dsi-panel-j2s-mp-42-02-0a-dsc-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 01 00 03 51 03 FF/39 01 00 00 01 00 03 51 03 FF/g' $dts_source/dsi-panel-j11-38-08-0a-fhd-cmd.dtsi
    sed -i 's/\/\/39 01 00 00 11 00 03 51 03 FF/39 01 00 00 11 00 03 51 03 FF/g' $dts_source/dsi-panel-j2-p2-1-38-0c-0a-dsc-cmd.dtsi
}

# Make defconfig

make O=out ARCH=${ARCH} ${DEFCONFIG}
if [ $? -ne 0 ]
then
    echo "Build failed"
else
    echo "Made ${DEFCONFIG}"
fi

# Build starts here
if [ -z ${LINKER} ]
then
    Build
else
    echo | Build_lld
fi

if [ $? -ne 0 ]
then
    echo "Build failed"
    rm -rf out/outputs/${PHONE}/*
    rm out/outputs/dtbo-miui.img
else
    echo "Build succesful"
    mkdir out/outputs
    mkdir out/outputs/${PHONE}
    #cp out/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb out/outputs/${PHONE}/dtb
    find out/arch/arm64/boot/dts/vendor/qcom/ -name '*.dtb' -exec cat {} + >out/outputs/${PHONE}/dtb
    cp out/arch/arm64/boot/dtbo.img out/outputs/${PHONE}/dtbo.img
    cp out/arch/arm64/boot/Image.gz out/outputs/${PHONE}/Image.gz
    #MIUI dtbo
    rm out/outputs/${PHONE}/${PHONE}_dtbo-miui.img
    miui_fix_dimens
    miui_fix_fps
    miui_fix_dfps
    miui_fix_fod
    echo | Build_lld
    if [ $? -ne 0 ]
    then
        rm out/outputs/${PHONE}/${PHONE}_dtbo-miui.img
    else
        cp out/arch/arm64/boot/dtbo.img out/outputs/${PHONE}/${PHONE}_dtbo-miui.img
    fi
    git checkout $dts_source/dsi-panel*
fi

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"