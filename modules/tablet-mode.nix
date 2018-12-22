{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.kevin.tablet-mode;

  hook = pkgs.writeShellScriptBin "tablet-mode-hook" ''
    export PATH=${lib.makeBinPath [ pkgs.xorg.xinput ]}

    declare -a laptop_devices
    laptop_devices=(${lib.escapeShellArgs cfg.laptopDevices})

    enable_all() {
      for dev in "''${@}"; do
        xinput enable "$dev"
      done
    }

    disable_all() {
      for dev in "''${@}"; do
        xinput disable "$dev"
      done
    }

    case "$1" in
      laptop)
        enable_all "''${laptop_devices[@]}"
        ;;
      tablet)
        disable_all "''${laptop_devices[@]}"
        ;;
     esac
  '';
in
{

  options = {
    hardware.kevin.tablet-mode = with lib; {
      enable = mkEnableOption "Automatic tablet mode";

      laptopDevices = mkOption {
        description = "Devices that are only available in laptop mode";
        type = types.listOf types.string;
        default = [
          "Atmel maXTouch Touchpad"
          "cros_ec"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.kevin-tablet-mode = {
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      script = ''
        exec ${pkgs.kevin-tablet-mode}/bin/kevin-tablet-mode ${hook}/bin/tablet-mode-hook
      '';
    };
  };
}
