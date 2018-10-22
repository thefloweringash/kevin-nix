{ config, lib, pkgs, ... }:

let
  kevinNixSources = pkgs.runCommand "kevin-nix" {} ''
    mkdir -p $out
    cp -prd ${lib.cleanSource ./.} $out/kevin-nix
  '';
in
{
  boot.postBootCommands = lib.mkAfter ''
    if ! [ -e /var/lib/nixos/did-kevin-channel-init ]; then
      echo "unpacking kevin-nix sources..."
      mkdir -p /nix/var/nix/profiles/per-user/root
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/per-user/root/channels \
        -i ${kevinNixSources} --quiet --option build-use-substitutes false
      touch /var/lib/nixos/did-kevin-channel-init
    fi
  '';
}
