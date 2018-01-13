{ config, lib, pkgs, ... }:

let
  kpart = pkgs.callPackage ./kpart.nix {
    linux = config.boot.kernelPackages.kernel;
    initrd = "${config.system.build.toplevel}/initrd";
    cmdline = pkgs.runCommand "cmdline" {} ''
      echo "systemConfig=${config.system.build.toplevel} init=${config.system.build.toplevel}/init $(cat ${config.system.build.toplevel}/kernel-params)" > $out
    '';
  };
in
{
  imports = [
    <nixos/modules/profiles/base.nix>
    <nixos/modules/profiles/installation-device.nix>
    ./sd-image-depthcharge.nix
    ./modules/packages.nix
  ];

  assertions = lib.singleton {
    assertion = pkgs.stdenv.system == "aarch64-linux";
    message = "sd-image-aarch64.nix can be only built natively on Aarch64 / ARM64; " +
      "it cannot be cross compiled";
  };

  boot.kernelPackages = pkgs.linuxPackages_gru_4_4;

  sdImage.kpart = kpart;

  # FIXME: this probably should be in installation-device.nix
  users.extraUsers.root.initialHashedPassword = "";

  # dev config?
  boot.loader.grub.enable = false;
}
