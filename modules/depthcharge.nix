{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.boot.loader.depthcharge;

  make_kernel_its = pkgs.runCommand "make-kernel-its.sh" {} ''
    cp ${./make-kernel-its.sh} $out
    chmod a+x $out
    patchShebangs $out
  '';

  make_kpart = pkgs.runCommand "make-kpart.sh" {
    inherit (pkgs) vboot_reference ubootTools dtc xz;
    inherit make_kernel_its;
  } ''
    substituteAll ${./make-kpart.sh} $out
    chmod a+x $out
    patchShebangs $out
  '';
in
{
  options = {
    boot.loader.depthcharge = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to enable Depthcharge compatibility.
        '';
      };

      partition = mkOption {
        example = "/dev/disk/by-partlabel/kernel";
        type = types.str;
        description = ''
          The kernel partition that holds the boot configuration. The
          value "nodev" indiciates the kpart partition should be
          created but not installed.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    system.boot.loader.id = "depthcharge";

    system.extraSystemBuilderCmds = ''
      ${make_kpart} $out
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

      ${if cfg.partition != "nodev" then ''
        echo "Installing kpart at $kpart to ${cfg.partition}"
        dd if="$kpart" of="${cfg.partition}"
      '' else ''
        echo "Kpart produced at $kpart, but automatic installation is disabled."
      ''}
    '';
  };
}
