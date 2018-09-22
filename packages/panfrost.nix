{ stdenv
, fetchgit
, mesa_drivers
, meson, ninja
, bison, flex
, xorg
}:
mesa_drivers.overrideAttrs (o: {
  nativeBuildInputs = o.nativeBuildInputs ++ [ meson ninja bison flex ];
  buildInputs = o.buildInputs ++ [ xorg.libXrandr ];
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
    ln -s ${fetchgit {
      name = "panfrost";
      url = https://gitlab.freedesktop.org/panfrost/panfrost;
      rev = "a25f2c0938874d71676c193aa31c20f99a7dcdf5"; # incremental-t8xx
      sha256 = "1l6kz67m9cm2lhi8yb41vlb3ayva5li6r000zvpj2ffkq623lhqq";
    }} src/gallium/drivers/panfrost
  '';
})
