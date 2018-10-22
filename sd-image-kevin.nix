{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    ./sd-image-depthcharge.nix
    ./modules
    ./channel.nix
  ];

  assertions = lib.singleton {
    assertion = pkgs.stdenv.system == "aarch64-linux";
    message = "sd-image-aarch64.nix can be only built natively on Aarch64 / ARM64; " +
      "it cannot be cross compiled";
  };

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_gru_4_4;

  sdImage.kpart = "${config.system.build.toplevel}/kpart";
  sdImage.storePaths = [ config.system.build.toplevel ];

  # dev config?
  boot.loader.grub.enable = false;

  boot.kernelParams = [ "console=tty1" ];

  hardware.kevin.console-font.fontfile =
    "${pkgs.source-code-pro}/share/fonts/opentype/SourceCodePro-Regular.otf";

}
