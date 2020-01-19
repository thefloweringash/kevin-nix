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

  fallbackDeviceSetup = optionalString (cfg.fallbackPartition != null) ''
    export PATH=${lib.makeBinPath [ pkgs.vboot_reference pkgs.utillinux ]}:$PATH

    deviceToDisk() {
      local device=$1
      local name
      name=$(lsblk -no pkname "$device")
      echo "/dev/$name"
    }

    deviceToIndex() {
      local disk=$1
      local device=$2
      local PARTUUID
      source <(blkid --output export "$device" | grep '^PARTUUID=' | tr 'a-f' 'A-F')
      cgpt find -n -u "$PARTUUID" "$disk"
    }

    primary_disk=$(deviceToDisk ${cfg.partition})
    primary_index=$(deviceToIndex "$primary_disk" ${cfg.partition})
    fallback_disk=$(deviceToDisk ${cfg.fallbackPartition})
    fallback_index=$(deviceToIndex "$fallback_disk" ${cfg.fallbackPartition})

    if [ "$primary_disk" != "$fallback_disk" ]; then
      echo "Primary partition and fallback partition are not on the same disk" >&2
      exit 1
    fi
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

      fallbackPartition = mkOption {
        example = "/dev/disk/by-partlabel/kernel-fallback";
        type = types.nullOr types.str;
        default = null;
        description = ''
          If not null, this partition will be used to boot a known
          good system if the primary partition fails to boot.
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
      set -x
      set -euo pipefail
      system=$1
      kpart=$system/kpart

      if [ ! -f $kpart ]; then
        echo "Missing kpart file in system"
        echo "Expected: $kpart"
        exit 1
      fi

      ${if cfg.partition != "nodev" then ''
        ${fallbackDeviceSetup}

        ${lib.optionalString (cfg.fallbackPartition != null) ''
          if [ -e /run/booted-system/kpart ]; then
            echo "Copying booted kernel to fallback partition"
            dd if=/run/booted-system/kpart of="${cfg.fallbackPartition}"

            echo "Setting known good configuration as known good"
            cgpt add -i "$fallback_index" -T 0 -S 1 "$fallback_disk"
          fi
        ''}

        echo "Installing kpart at $kpart to ${cfg.partition}"
        dd if="$kpart" of="${cfg.partition}"

        ${lib.optionalString (cfg.fallbackPartition != null) ''
          echo "Setting new kpart state"
          cgpt add -i "$primary_index" -T 1 -S 0 "$primary_disk"
        ''}
      '' else ''
        echo "Kpart produced at $kpart, but automatic installation is disabled."
      ''}
    '';

    systemd.services.set-successful-boot = mkIf (cfg.fallbackPartition != null) {
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      script = ''
        set -x
        set -euo pipefail

        ${fallbackDeviceSetup}

        good_kpart=$(readlink -f /run/booted-system/kpart)

        # use the /run/booted-system kpart
        kpart_length=$(stat -c '%s' "$good_kpart")

        set_active_if_match() {
          local partition=$1
          local disk=$2
          local index=$3
          if cmp -n "$kpart_length" "$good_kpart" "$partition"; then
            echo "Booted system found at $partition, setting successful flag on $disk:$index"
            cgpt add -i "$index" --successful 1 "$disk"
            cgpt prioritize -i "$index" "$disk"
          else
            echo "$partition doesn't match"
          fi
        }

        set_active_if_match "${cfg.partition}" "$primary_disk" "$primary_index"
      '';
      path = with pkgs; [ diffutils vboot_reference ];
    };
  };
}
