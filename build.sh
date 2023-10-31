#!/bin/bash
# According to LineageOS 20 manifest kernel should be built using this prebuilt toolchain:
# Clang: https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b (branch lineage-20.0),
# Crossgcc(aarch64): https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 (branch lineage-19.1),
# Crossgcc(arm): https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 (branch lineage-19.1)

OUTPUT_DIR='out'
DEVICE='d2s'

echo "Rendering the config from defconfig of the device specified..."
make O=${OUTPUT_DIR} ARCH=arm64 exynos9820-${DEVICE}_defconfig

echo "Building the kernel..."
# Set PATH to clang and crossgcc for aarch64 and (just in case) arm architectures
PATH="/workdir/clang/bin:/workdir/gcc-aarch64/bin:/workdir/gcc-arm/bin:${PATH}" \
# Fix libdss-build path in Makefile so it won't be searched in OUTPUT dir
sed -i 's|bash -C lib/libdss-build.sh|bash -C ../lib/libdss-build.sh|' Makefile
rm -f build.log
make -j$(nproc --all) 2>&1 O=${OUTPUT_DIR} \
                           ARCH=arm64 \
                           CC=clang \
                           CLANG_TRIPLE=aarch64-linux-gnu- \
                           CROSS_COMPILE=aarch64-linux-android- | tee build.log

#CROSS_COMPILE_ARM32=arm-linux-androideabi-

echo "Creating the DTB image..."
build-tools/mkdtimg cfg_create ${OUTPUT_DIR}/dtb build-tools/exynos9820-dtb.cfg -d ${OUTPUT_DIR}/arch/arm64/boot/dts/exynos

# ToDo - add AnyKernel3
