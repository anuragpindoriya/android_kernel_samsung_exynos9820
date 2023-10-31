FROM docker.io/ubuntu:jammy

WORKDIR /workdir

RUN apt update && apt install -y \
	bc \
	git \
	gnupg \
	flex \
	bison \
	build-essential \
	zip \
	curl \
	zlib1g-dev \
	libc6-dev-i386 \
	libncurses5 \
	x11proto-core-dev \
	libx11-dev \
	lib32z1-dev \
	libgl1-mesa-dev \
	libxml2-utils \
	xsltproc \
	unzip \
	fontconfig \
	python-is-python3 \
	nano

RUN apt install -y libssl-dev && \
    git clone https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git clang && \
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git gcc-aarch64 && \
    git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git gcc-arm && \
    git clone https://android.googlesource.com/platform/system/libufdt
