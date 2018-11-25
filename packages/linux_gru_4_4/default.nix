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
      rev = "e31696ae4e3e4b6467003f53ff069814031eeb09";
      sha256 = "0fnvryyrc6a4pfaix7hjxphp6hfp70yi7ngzpqs1881c0i21fwai";
    };

    version = "4.4.163-ARCH";
    modDirVersion = "4.4.163-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
