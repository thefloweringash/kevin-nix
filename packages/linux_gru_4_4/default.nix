{ stdenv, runCommand, fetchgit, linuxManualConfig,
  features ? {}, kernelPatches ? [], randstructSeed ? null }:

# Additional features cannot be added to this kernel
assert features == {};

let
  passthru = { features = {}; };

  drv = linuxManualConfig ({
    inherit stdenv kernelPatches;

    src = fetchgit {
      url = "https://chromium.googlesource.com/chromiumos/third_party/kernel/";
      rev = "5fce67aba2047d29a6290bbfdd98c22926621957";
      sha256 = "1kh1bq2lyz6j8i9wn0piyi8x5g4x09kas0h8yadcmwrg02jrw9jr";
    };

    version = "4.4.179-ARCH";
    modDirVersion = "4.4.179-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  } // stdenv.lib.optionalAttrs (randstructSeed != null) { inherit randstructSeed; });

in

stdenv.lib.extendDerivation true passthru drv
