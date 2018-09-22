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
      rev = "96466abef15b7778bde7f3597e28c1c2b46c22e2";
      sha256 = "16fk4z2pnzpfn5w11rms8q13x2hpnyj9b2b24bh6r808y85nqvzs";
    };

    version = "4.4.153-ARCH";
    modDirVersion = "4.4.153-ARCH";

    configfile = ./linux-gru.config;

    allowImportFromDerivation = true; # Let nix check the assertions about the config
  };

in

stdenv.lib.extendDerivation true passthru drv
