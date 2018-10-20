{ stdenv
, fetchgit
, mesa_drivers
, meson, ninja
, bison, flex
, xorg
, panfrostDriverSource ? null
, versionSuffix ? "-panfrost"
}:
let
  defaultPanfrostDriverSource = fetchgit {
    name = "panfrost";
    url = https://gitlab.freedesktop.org/panfrost/panfrost;
    # https://gitlab.freedesktop.org/panfrost/panfrost/merge_requests/2
    rev = "9f5002f6e241ba45380dbb75955ae739996d102d"; # incremental-t8xx
    sha256 = "09fga8z2a7f2ilkl76a32rhspvygfs8dm4ybsj9xmaf93iy845ak";
  };
in

mesa_drivers.overrideAttrs (o: {
  name = o.name + versionSuffix;
  nativeBuildInputs = o.nativeBuildInputs ++ [ meson ninja bison flex ];
  buildInputs = o.buildInputs ++ [ xorg.libXrandr ];
  mesonBuildType = "debugoptimized";
  mesonFlags = ["-Ddri-drivers=" "-Dvulkan-drivers=" "-Dgallium-drivers=panfrost"];
  patches = [];
  postInstall = ":";
  outputs = ["out"];
  src = fetchgit {
    name = "mesa";
    url = https://gitlab.freedesktop.org/panfrost/mesa;
    rev = "13aae958f70a69166c0c241f683c8d3566ed26db"; # upstream-overlay
    sha256 = "056smp4nkxcml1phmf4wspygjlrrjcnh1zykm634qfw91c0mizxk";
  };
  preConfigure = ''
    rm src/gallium/drivers/panfrost
    ln -s ${
      if panfrostDriverSource != null
      then panfrostDriverSource
      else defaultPanfrostDriverSource
    } src/gallium/drivers/panfrost
  '';
})
