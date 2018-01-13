{ stdenv, runCommand, fetchurl, buildLinux, kernelPatches ? [] }:

let
  fetchGru = { commit, sha256 }:
    let
      raw = fetchurl {
       url = "https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/${commit}.tar.gz";
       inherit sha256;
       };
     in runCommand "linux-gru-source" {} ''
       mkdir $out
       tar -C $out -xf ${raw}
    '';
in

buildLinux {
  inherit stdenv kernelPatches;

  src = fetchGru {
    commit = "3aa6760c93900123744c104b67fecda917f73fde";
    sha256 = "1nqma087civ6fnscpi767jcjp6iz9gg8gpvk1yb6x4cs8pyf3v89";
  };

  version = "4.4.110-gru";
  modDirVersion = "4.4.110-ARCH";

  configfile = ./linux-gru.config;

  allowImportFromDerivation = true; # Let nix check the assertions about the config
}
