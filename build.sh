#!/usr/bin/env bash

msg(){
    echo
    echo "==> $*"
    echo
}

err(){
    echo 1>&2
    echo "==> $*" 1>&2
    echo 1>&2
}

make clean && make mrproper
defconfig_original="exynos9820-$2_defconfig"
defconfig_gcov="exynos9820-$2-gcov_defconfig"
defconfig_pgo="exynos9820-$2-pgo_defconfig"

mode="$1"
echo "Mode: $mode"
if [ "$mode" = "gcov" ]; then
    cp arch/arm64/configs/$defconfig_original arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_DEBUG_KERNEL=y"     >> arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_DEBUG_FS=y"         >> arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_GCOV_KERNEL=y"      >> arch/arm64/configs/$defconfig_gcov
    echo "CONFIG_GCOV_PROFILE_ALL=y" >> arch/arm64/configs/$defconfig_gcov
    defconfig=$defconfig_gcov
elif [ "$mode" = "pgo" ]; then
    cp arch/arm64/configs/$defconfig_original arch/arm64/configs/$defconfig_pgo
    echo "CONFIG_PGO=y"              >> arch/arm64/configs/$defconfig_pgo
    defconfig=$defconfig_pgo
elif [ "$mode" = "none" ]; then
    defconfig=$defconfig_original
fi
# Clone Letest  stable kernelSU

rm -rf KernelSU
rm -rf drivers/kernelsu
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -


if [ "$3" == "local" ]; then
  export PATH="/home/anurag/Desktop/s10plusstrok/Kernel/toolchain/gcc-cfp/gcc-cfp-jopp-only/aarch64-linux-android-4.9/bin:${PATH}"
fi
# Dynamic generate name

latest_version_of_Kernel_SU=$(curl -s https://api.github.com/repos/tiann/KernelSU/releases/latest | jq -r '.tag_name')
TIMESTAMP=$(TZ=UTC-8 date +%Y%m%d%H%M)
CONFIG_LOCALVERSION="-An-UNKNOWN-$2-$latest_version_of_Kernel_SU"

# Dynamic generate name
export ARCH="arm64"
export CROSS_COMPILE="aarch64-elf-"

msg "-------------------------------------------------------------------"
msg ""
msg "Generating defconfig from \`make $defconfig\`..."
msg ""
msg "-------------------------------------------------------------------"

if ! make O=out ARCH="arm64" $defconfig; then
    err "Failed generating .config, make sure it is actually available in arch/${ARCH}/configs/ and is a valid defconfig file"
    exit 2
fi
msg "-------------------------------------------------------------------"
msg ""
msg "Begin building kernel..."
msg ""
msg "-------------------------------------------------------------------"

make O=out ARCH="arm64" -j"$(nproc --all)" LOCAL_prepare

if ! make O=out ARCH="arm64" -j"$(nproc --all)" LOCALVERSION="$CONFIG_LOCALVERSION"; then
    err "Failed building kernel, probably the toolchain is not compatible with the kernel, or kernel source problem"
    exit 3
fi

msg "-------------------------------------------------------------------"
msg ""
msg "Packaging the kernel..."
msg ""
msg "-------------------------------------------------------------------"

rm -rf out/ak3
cp -r ak3 out/

cp out/arch/arm64/boot/Image out/ak3/Image
tools/mkdtimg cfg_create out/ak3/dtb exynos9820.cfg -d out/arch/arm64/boot/dts/exynos

cd out/ak3
zip -r9 $2-'$(/bin/date -u '+%Y%m%d-%H%M')'.zip .

