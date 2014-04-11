#!/bin/sh

# Setup enviroment
export CROSS_COMPILE="/home/vanyas/android/android-ndk-r9d/toolchains/arm-linux-androideabi-4.6/prebuilt/linux-x86_64/bin/arm-linux-androideabi-"
export ARCH="arm"

#Building kernel
make mrproper
make VARIANT_DEFCONFIG=msm8974_sec_picassoeur_defconfig msm8974_sec_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make menuconfig
make -j3

#Building ramfs
./tools/repack_ramdisk ramdisk/ramdisk ramdisk.cpio.gz

#Building Device Tree image
./tools/dtbTool -o ./build/dt.img -s 2048 -p ./scripts/dtc/ ./arch/arm/boot/

#Building boot.img
./tools/mkbootimg --kernel ./arch/arm/boot/zImage --ramdisk ./ramdisk/ramdisk.cpio.gz --cmdline 'console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02000000 --tags_offset 0x01E00000 --dt ./build/dt.img -o ./build/boot.img
rm ./build/dt.img
cd build
tar -H ustar -c boot.img > boot.tar
md5sum -t boot.tar >> boot.tar
mv boot.tar boot.tar.md5
