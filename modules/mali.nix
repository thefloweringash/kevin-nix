{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
    KERNEL=="mali[0-9]", MODE="0660", GROUP="video"
  '';

  hardware.opengl.package = pkgs.rockchip-linux-libmali-gldriver;
}
