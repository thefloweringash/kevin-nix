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
      rev = "91681b08b2f300c0197b4eff4061c81eafb529cf";
      sha256 = "0bj99m9r9kyssb5h0nm5dppdzyr96yhfgs0d9lq40s59v3ffwb2g";
    };

    version = "4.4.144-ARCH";
    modDirVersion = "4.4.144-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
