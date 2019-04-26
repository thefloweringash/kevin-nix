{ stdenv
, fetchgit
, mesa_drivers
, meson, ninja
, bison, flex
, xorg
, autoreconfHook
, panfrostSource ? null
, panfrostNondrmSource ? null
, versionSuffix ? "-panfrost"
}:
let
  defaultPanfrostSource = fetchgit {
    name = "panfrost";
    url = https://gitlab.freedesktop.org/mesa/mesa.git/;
    rev = "5d310015c57536224600252e4ceadcf964bfc4fa"; # master
    sha256 = "0i9xk0c3hm5x60p6zx3i9ggfrjyhnhzs2jzyjnm6ip71wj1s7s0v";
  };

  defaultPanfrostNondrmSource = fetchgit {
    name = "nondrm";
    url = "https://gitlab.freedesktop.org/panfrost/nondrm";
    rev = "6fb97dae1b372fe26cc05d6342b7bf32eb26db5f"; # master
    sha256 = "0jyw99hkh6k6d9fv1l8p3jzw1f60dnbni0j73z2m4swv1zv6disd";
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
  preConfigure = ''
    ln -sfT ${
      if panfrostNondrmSource != null
      then panfrostNondrmSource
      else defaultPanfrostNondrmSource
    } src/gallium/drivers/panfrost/nondrm
  '';
  src =
    if panfrostSource != null
    then panfrostSource
    else defaultPanfrostSource;
})
