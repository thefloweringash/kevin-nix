{ stdenv, runCommand, fetchgit, linuxManualConfig,
  features ? {}, kernelPatches ? [] }:

# Additional features cannot be added to this kernel
assert features == {};

let
  passthru = { features = {}; };

  drv = linuxManualConfig {
    inherit stdenv kernelPatches;

    src = fetchgit {
      url = "https://chromium.googlesource.com/chromiumos/third_party/kernel/";
      rev = "0ac175878149810e87acd790856faa3c3a1806a4";
      sha256 = "1ihxm8w6vwbrdp9n40v2y3lppr058pk73bavcpcbsjcz1x6cddl9";
    };

    version = "4.4.123-ARCH";
    modDirVersion = "4.4.123-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
