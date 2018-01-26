{ stdenv, runCommand, fetchgit, buildLinux, kernelPatches ? [] }:

buildLinux {
  inherit stdenv kernelPatches;

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromiumos/third_party/kernel/";
    rev = "3aa6760c93900123744c104b67fecda917f73fde";
    sha256 = "0ff4qzw5mjz93v6midrg1g82v75nvqf40nk86zgqabbij58zwjy4";
  };

  version = "4.4.110-gru";
  modDirVersion = "4.4.110-ARCH";

  configfile = ./linux-gru.config;

  allowImportFromDerivation = true; # Let nix check the assertions about the config
}
