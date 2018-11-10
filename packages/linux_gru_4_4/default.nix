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
      rev = "bab82969195f719cc44d52572030149bbbecc66d";
      sha256 = "1fnhpkydy34shkvh0656jkcgsii1g64rqjfr8yj1glrx1g24igjb";
    };

    version = "4.4.162-ARCH";
    modDirVersion = "4.4.162-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
