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
      rev = "d5dcc34e053c963d083c2d4bf9409ede1878199a";
      sha256 = "14dh0z1lhq0h5kqlhqhr89qqqmypa2pr8a71slzmkrpyfk3hbxvg";
    };

    version = "4.4.86-ARCH";
    modDirVersion = "4.4.86-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
