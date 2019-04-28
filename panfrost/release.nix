{ nixpkgs ? { outPath = <nixpkgs>; }
, stableBranch ? false
, panfrost ? null
, nondrm ? null
}:

let
  panfrostSuffix =
    if panfrost ? revCount && panfrost ? shortRev
    then "-panfrost${toString panfrost.revCount}.${panfrost.shortRev}"
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
in

with (import (nixpkgs+"/nixos/lib/eval-config.nix") {
  modules = [
    ../sd-image-kevin.nix
    versionModule
    ../modules/mali.nix
    ./live-environment.nix
    panfrostSrcModule
  ];
});

{
  inherit (config.system.build)
    kernel
    toplevel
    sdImage
    ;

  inherit (pkgs)
    panfrost
    ;
}
