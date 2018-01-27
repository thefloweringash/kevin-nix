{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.boot.loader.depthcharge;

  make-kpart = pkgs.runCommand "make-kpart.sh" {
    inherit (pkgs) vboot_utils ubootTools dtc;
    kernel_its = ./kernel.its;
  } ''
    substituteAll ${./make-kpart.sh} $out
    chmod a+x $out
  '';
in
{
  options = {
    boot.loader.depthcharge = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Whether to enable Depthcharge compatibility.
        '';
      };

      partition = mkOption {
        default = "";
        example = "/dev/disk/by-partlabel/kenrel";
        type = types.str;
        description = ''
          The kernel partition that holds the boot configuration.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    system.boot.loader.id = "depthcharge";

    system.extraSystemBuilderCmds = ''
      ${make-kpart} $out
    '';

    system.build.installBootLoader = pkgs.writeScript "install-depthcharge.sh" ''
      #!${pkgs.stdenv.shell}
      set -e
      system=$1
      kpart=$system/kpart

      if [ ! -f $kpart ]; then
        echo "Missing kpart file in system"
        echo "Expected: $kpart"
        exit 1
      fi

      echo "Installing kpart at $kpart to ${cfg.partition}"
      dd if="$kpart" of="${cfg.partition}"
    '';
  };
}
