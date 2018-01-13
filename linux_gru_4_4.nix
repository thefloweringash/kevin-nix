{ stdenv, runCommand, fetchurl, buildLinux, kernelPatches ? [] }:

let
  sources = import ./ayufan-rock64-sources.nix;

  fetchGru = { commit, sha256 }:
    let
      raw = fetchurl {
       url = "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/${commit}.tar.gz";
       inherit sha256;
       };
     in runCommand "linux-gru-source" {} ''
       mkdir $out
       tar -C $out -xf ${raw}
    '';
in

buildLinux {
  inherit stdenv;

  src = fetchGru {
    commit = "3aa6760c93900123744c104b67fecda917f73fde";
    sha256 = "1nqma087civ6fnscpi767jcjp6iz9gg8gpvk1yb6x4cs8pyf3v89";
  };

  version = "4.4.110-gru";
  modDirVersion = "4.4.110-ARCH";

  configfile = ./linux-gru.config;

  allowImportFromDerivation = true; # Let nix check the assertions about the config

  kernelPatches = kernelPatches ++ [
    { name = "arch-1"; patch = ./0001-Input-atmel_mxt_ts-Use-KERN_DEBUG-loglevel-for-statu.patch; }
    { name = "arch-2"; patch = ./0002-Revert-CHROMIUM-drm-rockchip-Add-PSR-residency-debug.patch; }
    { name = "arch-3"; patch = ./0003-temporary-hack-to-fix-console-output.patch; }
  ];
}
