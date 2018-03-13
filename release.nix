with (import <nixpkgs/nixos> {
  configuration = ./sd-image-kevin.nix;
});

{
  inherit (config.system.build)
    kernel
    toplevel
    sdImage
    ;
}
