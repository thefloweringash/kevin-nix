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
      rev = "6463912595d0a66543375d4c5dbc615fa325fa11";
      sha256 = "9cae128deef310cfff847e9cf52b5249a13ce87dabb9811ec9268a5726621677";
    };

    version = "4.4.158-ARCH";
    modDirVersion = "4.4.158-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
