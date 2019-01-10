{ ... }: {
  imports = [
    ./packages.nix
    ./depthcharge.nix
    ./early-boot.nix
    ./console-font.nix
    ./mali.nix
    ./cmt.nix
    ./tablet-mode.nix
  ];
}
