#/bin/sh -e

search_nix_path() {
    nix-instantiate --eval --expr "<$1>" 2>/dev/null
}

: ${nixpkgs:=$(search_nix_path nixpkgs)}

if [ ! -d "$nixpkgs" ]; then
    echo "Nixpkgs path not found"
    exit 1
fi

nixos=${nixpkgs}/nixos
echo "Using nixos=${nixos}"

build_package() {
    nix-build -E 'import <nixpkgs> { overlays = [ (import ./packages) ]; }' -A "$1" -o "$1"
}

nix-build '<nixos>' \
    -I nixos=${nixos} \
    -I nixos-config=sd-image-kevin.nix \
    -A config.system.build.sdImage \
    -j1 # if building on an sd card
