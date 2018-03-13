#/bin/sh -e

build_package() {
    nix-build -E 'import <nixpkgs> { overlays = [ (import ./packages) ]; }' -A "$1" -o "$1"
}

nix-build '<nixpkgs/nixos>' \
    -I nixos-config=sd-image-kevin.nix \
    -A config.system.build.sdImage \
    -j1 # if building on an sd card
