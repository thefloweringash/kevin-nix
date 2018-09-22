{ config, lib, pkgs, ... }:

let
  cfg = config.hardware;
in
{
  options = {
    hardware.libmali.enable  = lib.mkEnableOption "Enable libmali gl driver";
  };

  config = lib.mkMerge [
    {
      # TODO: this should probably be integrated with login sessions.
      services.udev.extraRules = ''
        KERNEL=="mali[0-9]", MODE="0660", GROUP="video"
      '';

      environment.systemPackages = with pkgs; [ glxinfo ];
    }
    (lib.mkIf cfg.libmali.enable {
      # This is wishful thinking until the versions match
      hardware.opengl.package = pkgs.rockchip-linux-libmali-gldriver;
    })
  ];
}
