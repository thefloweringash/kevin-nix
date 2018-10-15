{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.hardware.kevin.sound;

  ucm-env = {
    ALSA_CONFIG_UCM = "${pkgs.alsaucm-kevin}/share/alsa/ucm";
  };
in
{
  options = {
    hardware.kevin.sound.enable = mkEnableOption "Configure alsaucm for Kevin";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.alsaUtils ];
    environment.variables = ucm-env;

    systemd.user.services.pulseaudio.serviceConfig.Environment =
      mapAttrsToList (k: v: "${k}=${v}") ucm-env;
  };
}
