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

  linux_gru_4_4_kpart = super.callPackage ./kpart.nix {
    cmdline="console=ttyS2,115200n8 earlyprintk=ttyS2,115200n8 console=tty1 init=/sbin/init root=PARTUUID=%U/PARTNROFF=1 rootwait rw noinitrd loglevel=4";
    linux = self.linux_gru_4_4;
  };

  linux_gru_4_4_sdcard = super.callPackage ./sdcard.nix {
    kpart = self.linux_gru_4_4_kpart;
  };
}
