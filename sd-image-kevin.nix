{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    ./sd-image-depthcharge.nix
    ./modules/packages.nix
    ./modules/depthcharge.nix
  ];

  assertions = lib.singleton {
    assertion = pkgs.stdenv.system == "aarch64-linux";
    message = "sd-image-aarch64.nix can be only built natively on Aarch64 / ARM64; " +
      "it cannot be cross compiled";
  };

  boot.kernelPackages = pkgs.linuxPackages_gru_4_4;

  sdImage.kpart = "${config.system.build.toplevel}/kpart";
  sdImage.storePaths = [ config.system.build.toplevel ];

  # FIXME: this probably should be in installation-device.nix
  users.extraUsers.root.initialHashedPassword = "";

  # dev config?
  boot.loader.grub.enable = false;

  boot.kernelParams = [ "console=tty1" ];
}
