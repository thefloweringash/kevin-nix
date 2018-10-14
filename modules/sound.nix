{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.hardware.kevin.sound;

  alsaucm-config = pkgs.buildEnv {
    name = "alsaucm-config";
    paths = with pkgs; [ alsaLib alsaucm-kevin ];
    pathsToLink = [ "/share/alsa/ucm" ];
  };
in
{
  options = {
    hardware.kevin.sound.enable = mkEnableOption "Configure alsaucm for Kevin";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.alsaUtils ];
    environment.variables = {
      ALSA_CONFIG_UCM = "${alsaucm-config}/share/alsa/ucm";
    };
  };
}
