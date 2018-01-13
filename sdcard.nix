{ stdenv, runCommand, vboot_utils, utillinux, kpart }:

runCommand "linux.kpart.testimage" {
  nativeBuildInputs = [ vboot_utils utillinux ];

  # todo randomize
  diskUUID = "A8ABB0FA-2FD7-4FB8-ABB0-2EEB7CD66AFA";
  bootUUID = "534078AF-3BB4-EC43-B6C7-828FB9A788C6";
  rootUUID = "0340EA1D-C827-8048-B631-0C60D4478796";
} ''
  truncate -s 32m $out

  sfdisk --no-reread --no-tell-kernel $out <<EOF
      label: gpt
      label-id: $diskUUID
      type=FE3A2A5D-4F32-41A7-B725-ACCC3285A309, uuid=$bootUUID, name=kernel
  EOF

  cgpt add -i 1   -S 1 -T 5 -P 10 $out

  # Copy the bootloader to the SD image start
  eval $(partx $out -o START,SECTORS --nr 1 --pairs)
  dd conv=notrunc if=${kpart} of=$out seek=$START count=$SECTORS

''
