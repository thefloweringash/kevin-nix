#!/usr/bin/env bash

out=$1

PATH="@dtc@/bin:$PATH"

@xz@/bin/lzma --threads 0 < $out/kernel > $out/kernel.lzma

@make_kernel_its@ $out > $out/kernel.its

@ubootTools@/bin/mkimage -D "-I dts -O dtb -p 2048" -f $out/kernel.its $out/vmlinux.uimg

dd if=/dev/zero of=$out/bootloader.bin bs=512 count=1

echo "systemConfig=$out init=$out/init $(cat $out/kernel-params)" > $out/kpart-config;

@vboot_reference@/bin/futility vbutil_kernel \
  --pack $out/kpart \
  --version 1 \
  --vmlinuz $out/vmlinux.uimg \
  --arch aarch64 \
  --keyblock @vboot_reference@/share/vboot/devkeys/kernel.keyblock \
  --signprivate @vboot_reference@/share/vboot/devkeys/kernel_data_key.vbprivk \
  --config $out/kpart-config \
  --bootloader $out/bootloader.bin
