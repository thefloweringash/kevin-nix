self: super: {
  vboot_utils = super.callPackages ./vboot_utils.nix {};

  linux_gru_4_4 = super.callPackage ./linux_gru_4_4.nix {
    kernelPatches = with self; [
      kernelPatches.bridge_stp_helper
      kernelPatches.cpu-cgroup-v2."4.4"
      kernelPatches.modinst_arg_list_too_long
    ];
  };

  linuxPackages_gru_4_4 = super.linuxPackagesFor self.rock64.linux_gru_4_4;
}
