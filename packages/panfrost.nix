{ stdenv
, fetchgit
, mesa_drivers
, meson, ninja
, bison, flex
, xorg
, panfrostSource ? null
, versionSuffix ? "-panfrost"
}:
let
  defaultPanfrostSource = fetchgit {
    name = "panfrost";
    url = https://gitlab.freedesktop.org/panfrost/mesa.git/;
    rev = "76ae2649d4071b3a09394ee91c1608aeefbaab01"; # master
    sha256 = "0fa8jr365a6pd0kz76h6mq9mx916whiknm7vsrjz0j5zcg8fscv5";
  };
in

mesa_drivers.overrideAttrs (o: {
  name = o.name + versionSuffix;
  nativeBuildInputs = o.nativeBuildInputs ++ [ meson ninja bison flex ];
  buildInputs = o.buildInputs ++ [ xorg.libXrandr ];
  mesonBuildType = "debugoptimized";
  mesonFlags = ["-Ddri-drivers=" "-Dvulkan-drivers=" "-Dgallium-drivers=panfrost,rockchip"];
  patches = [];
  postInstall = ":";
  outputs = ["out"];
  src =
    if panfrostSource != null
    then panfrostSource
    else defaultPanfrostSource;
})
