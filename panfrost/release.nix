{ nixpkgs ? { outPath = <nixpkgs>; }
, stableBranch ? false
, panfrost ? null
, mali_kbase ? null
}:

let
  panfrostSuffix =
    if panfrost ? revCount && panfrost ? shortRev
    then "-panfrost${toString panfrost.revCount}.${panfrost.shortRev}"
    else "";

  mali_kbaseSuffix =
    if mali_kbase ? revCount && mali_kbase ? shortRev
    then "-${toString mali_kbase.revCount}.${mali_kbase.shortRev}"
    else "";

  nixSuffix =
    if nixpkgs ? revCount && nixpkgs ? shortRev
    then (if stableBranch then "." else "pre") + "${toString nixpkgs.revCount}.${nixpkgs.shortRev}"
    else "git";

  versionSuffix = "${nixSuffix}${panfrostSuffix}";

  versionModule = {
    system.nixos = { inherit versionSuffix; } //
    (if nixpkgs ? rev || nixpkgs ? shortRev then {
      revision = nixpkgs.rev or nixpkgs.shortRev;
    } else {});
  };

  panfrostSrcModule = if panfrost != null then
    {
      nixpkgs.overlays = [(self: super: {
        panfrost = super.panfrost.override {
          panfrostSource = panfrost;
          versionSuffix = panfrostSuffix;
        };
      })];
    } else {};

  mali_kbaseSrcModule = if mali_kbase != null then
    {
      nixpkgs.overlays = [(self: super: {
        linuxPackagesFor = kernel: (super.linuxPackagesFor kernel).extend (kself: ksuper: {
          mali_kbase = ksuper.mali_kbase.overrideAttrs ({ pname, ... }: {
            name = "${pname}${mali_kbaseSuffix}";
            src = mali_kbase;
          });
        });
      })];
    } else {};
in

with (import (nixpkgs+"/nixos/lib/eval-config.nix") {
  modules = [
    ../sd-image-kevin.nix
    versionModule
    ../modules/mali.nix
    ./live-environment.nix
    panfrostSrcModule
    mali_kbaseSrcModule
  ];
});

{
  inherit (config.system.build)
    kernel
    toplevel
    sdImage
    ;

  inherit (config.boot.kernelPackages)
    mali_kbase
    ;

  inherit (pkgs)
    panfrost
    ;
}
