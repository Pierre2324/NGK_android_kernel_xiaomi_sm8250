#!/bin/sh

# Some general variables
PHONE="munch"
ARCH="arm64"
SUBARCH="arm64"
DEFCONFIG=nogravity-${PHONE}_defconfig
COMPILER=clang
LINKER="lld"
COMPILERDIR="/media/pierre/Expension/Android/PocoX3Pro/Kernels/Proton-Clang"

# Copy gpu dtsi
cp arch/arm64/boot/dts/vendor/qcom/kona-v2-gpu-xxxx/kona-v2-gpu-alioth.dtsi arch/arm64/boot/dts/vendor/qcom/kona-v2-gpu.dtsi

# Copy touch fw
cp touch_fw/* drivers/input/touchscreen/focaltech_3658u/include/firmware/
cp touch_fw/* drivers/input/touchscreen/focaltech_spi/include/firmware/
cp touch_fw/* drivers/input/touchscreen/focaltech_touch/include/firmware/
cp touch_fw/* drivers/input/touchscreen/focaltech_touch/include/pramboot/

#AOSP Panel dimensions
cp arch/arm64/boot/dts/vendor/qcom/panel-dimensions/dsi-panel-l11r-38-08-0a-dsc-cmd.dtsi arch/arm64/boot/dts/vendor/qcom/dsi-panel-l11r-38-08-0a-dsc-cmd.dtsi 

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
else
    echo "Build succesful"
    mkdir out/outputs
    mkdir out/outputs/${PHONE}
    cp out/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb out/outputs/${PHONE}/dtb
    cp out/arch/arm64/boot/dtbo.img out/outputs/${PHONE}/dtbo.img
    cp out/arch/arm64/boot/Image.gz out/outputs/${PHONE}/Image.gz
fi

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"