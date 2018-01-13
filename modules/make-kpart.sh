#!/bin/sh -e

set -x

out=$1

cd $out

ls -lh kernel

PATH="@dtc@/bin:$PATH"

cp @kernel_its@ ./kernel.its
@ubootTools@/bin/mkimage -D "-I dts -O dtb -p 2048" -f kernel.its vmlinux.uimg

dd if=/dev/zero of=bootloader.bin bs=512 count=1

echo "systemConfig=$out init=$out/init $(cat kernel-params)" >> kpart-config;

@vboot_utils@/bin/futility vbutil_kernel \
  --pack $out/kpart \
  --version 1 \
  --vmlinuz vmlinux.uimg \
  --arch aarch64 \
  --keyblock @vboot_utils@/share/vboot/devkeys/kernel.keyblock \
  --signprivate @vboot_utils@/share/vboot/devkeys/kernel_data_key.vbprivk \
  --config kpart-config \
  --bootloader bootloader.bin
