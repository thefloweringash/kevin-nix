{ stdenv
, fetchgit
, mesa_drivers
, meson, ninja
, bison, flex
, xorg
, autoreconfHook
, panfrostSource ? null
, versionSuffix ? "-panfrost"
}:
let
  defaultPanfrostSource = fetchgit {
    name = "panfrost";
    url = https://gitlab.freedesktop.org/mesa/mesa.git/;
    rev = "5d310015c57536224600252e4ceadcf964bfc4fa"; # master
    sha256 = "0i9xk0c3hm5x60p6zx3i9ggfrjyhnhzs2jzyjnm6ip71wj1s7s0v";
  };
in

mesa_drivers.overrideAttrs (o: {
  name = o.name + versionSuffix;
  nativeBuildInputs = (stdenv.lib.remove autoreconfHook o.nativeBuildInputs) ++ [ meson ninja bison flex ];
  buildInputs = o.buildInputs ++ [ xorg.libXrandr ];
  mesonBuildType = "debugoptimized";
  mesonFlags = ["-Ddri-drivers=" "-Dvulkan-drivers=" "-Dgallium-drivers=panfrost,kmsro" "-Dlibunwind=false"];
  patches = [];
  postInstall = ":";
  outputs = ["out"];
  src =
    if panfrostSource != null
    then panfrostSource
    else defaultPanfrostSource;
})
