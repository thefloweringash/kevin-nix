{ stdenv, runCommand, fetchgit, linuxManualConfig,
  features ? {}, kernelPatches ? [] }:

# Additional features cannot be added to this kernel
assert features == {};

let
  passthru = { features = {}; };

  drv = linuxManualConfig {
    inherit stdenv kernelPatches;

    src = builtins.fetchGit {
      url = "https://chromium.googlesource.com/chromiumos/third_party/kernel/";
      rev = "fd7170200801a48f8881d29e64f272280204ddef";
    };

    version = "4.4.154-ARCH";
    modDirVersion = "4.4.154-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
