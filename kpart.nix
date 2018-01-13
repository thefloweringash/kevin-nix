{ stdenv, runCommand, linux, cmdline, vboot_utils, dtc, ubootTools, initrd }:

runCommand "linux.kpart" {
  inherit linux initrd;
  nativeBuildInputs = [ dtc ubootTools vboot_utils ];
} ''
  substituteAll ${./kernel.its} kernel.its
  mkimage -D "-I dts -O dtb -p 2048" -f kernel.its vmlinux.uimg

  dd if=/dev/zero of=bootloader.bin bs=512 count=1

  futility vbutil_kernel \
    --pack $out \
    --version 1 \
    --vmlinuz vmlinux.uimg \
    --arch aarch64 \
    --keyblock ${vboot_utils}/share/vboot/devkeys/kernel.keyblock \
    --signprivate ${vboot_utils}/share/vboot/devkeys/kernel_data_key.vbprivk \
    --config ${cmdline} \
    --bootloader bootloader.bin
''
