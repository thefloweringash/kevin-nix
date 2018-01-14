self: super: {
  vboot_utils = super.callPackages ./vboot_utils.nix {};

  linux_gru_4_4 = super.callPackage ./linux_gru_4_4.nix {
    kernelPatches = with self; [
      kernelPatches.bridge_stp_helper
      kernelPatches.cpu-cgroup-v2."4.4"
      kernelPatches.modinst_arg_list_too_long

      { name = "arch-1"; patch = ./0001-Input-atmel_mxt_ts-Use-KERN_DEBUG-loglevel-for-statu.patch; }
      { name = "arch-2"; patch = ./0002-Revert-CHROMIUM-drm-rockchip-Add-PSR-residency-debug.patch; }
      { name = "arch-3"; patch = ./0003-temporary-hack-to-fix-console-output.patch; }
    ];
  };

  linuxPackages_gru_4_4 = super.linuxPackagesFor self.linux_gru_4_4;
}
