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
    rev = "283a2a86d3414a8d270860b8f8c9aec2b9e6821f"; # master
    sha256 = "0qp6bqp2ll30xmnzavnqsckc733pifclh1vrbvcpawr7dp9dhqz4";
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
  src =
    if panfrostSource != null
    then panfrostSource
    else defaultPanfrostSource;
})
