{ stdenv, fetchgit, pkgconfig,
  lzma, libyaml, openssl, libuuid }:

stdenv.mkDerivation {
  name = "vboot_utils";
  src = fetchgit {
    url = "https://chromium.googlesource.com/chromiumos/platform/vboot_reference";
    rev = "fde7cdc134d66ff0ad1350901b716c4d7d158fa8";
    sha256 = "0lh7fpfry58ylmvrv9gyfy9fdp5s94835na525i4nlhr5b5dvkp9";
  };
  postPatch = ''
    patchShebangs ./scripts
  '';
  hardeningDisable = [ "all" ];
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ lzma libyaml openssl libuuid ];
  buildPhase = ''
    make BUILD=build build/futility/futility
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp build/futility/futility $out/bin

    mkdir -p $out/share/vboot
    cp -ar tests/devkeys $out/share/vboot
  '';
}

