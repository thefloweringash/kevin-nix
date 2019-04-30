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
      rev = "4514416f9f9459bdc4a6c7d1a355471c9f3a3c2d";
      sha256 = "0vmggbz5xbcxfkk6min366nvg0s1c2ggijx4kzg3kizz3ii459q8";
    };

    version = "4.4.168-ARCH";
    modDirVersion = "4.4.168-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  } // stdenv.lib.optionalAttrs (randstructSeed != null) { inherit randstructSeed; });

in

stdenv.lib.extendDerivation true passthru drv
