{ stdenv
, fetchgit
, mesa_drivers
, meson, ninja
, bison, flex
, xorg
, panfrostSource ? null
, panfrostNondrmSource ? null
, versionSuffix ? "-panfrost"
}:
let
  defaultPanfrostSource = fetchgit {
    name = "panfrost";
    url = https://gitlab.freedesktop.org/mesa/mesa.git/;
    rev = "49397a3c840b38f8c65705dd05d642c0beb4dea9"; # master
    sha256 = "0xfr47b6q1i2ss30nmxkp7jcw2jk7x24x8wcd2n1fkkh0s145hs7";
  };

  panfrostNondrmSource = fetchgit {
    name = "nondrm";
    url = "https://gitlab.freedesktop.org/panfrost/nondrm";
    rev = "2363a3be0a8d999b4fcccfde4fc4808a8fca758e"; # master
    sha256 = "0cz5jz4fnnqiisra3f5xg42jk2g276aw8k2cvjzcvwwspbjacw86";
  };
in

mesa_drivers.overrideAttrs (o: {
  name = o.name + versionSuffix;
  nativeBuildInputs = o.nativeBuildInputs ++ [ meson ninja bison flex ];
  buildInputs = o.buildInputs ++ [ xorg.libXrandr ];
  mesonBuildType = "debugoptimized";
  mesonFlags = ["-Ddri-drivers=" "-Dvulkan-drivers=" "-Dgallium-drivers=panfrost,kmsro" "-Dlibunwind=false"];
  patches = [ ./panfrost-nondrm.patch ];
  postInstall = ":";
  outputs = ["out"];
  preConfigure = ''
    ln -sfT ${panfrostNondrmSource} src/gallium/drivers/panfrost/nondrm
  '';
  src =
    if panfrostSource != null
    then panfrostSource
    else defaultPanfrostSource;
})
