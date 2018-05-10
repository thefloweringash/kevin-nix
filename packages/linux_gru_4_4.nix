{ stdenv, hostPlatform, runCommand, fetchgit, linuxManualConfig,
  features ? {}, kernelPatches ? [] }:

# Additional features cannot be added to this kernel
assert features == {};

let
  passthru = { features = {}; };

  drv = linuxManualConfig {
    inherit stdenv kernelPatches hostPlatform;

    src = fetchgit {
      url = "https://chromium.googlesource.com/chromiumos/third_party/kernel/";
      rev = "34e968b3d0ed7eb6c36645c899f7461802ef27d3";
      sha256 = "0gdg9zci2rx1jsqvl8b8pp032fv470jgwqzqiwjnwdjss3q3qaqh";
    };

    version = "4.4.130-ARCH";
    modDirVersion = "4.4.130-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
