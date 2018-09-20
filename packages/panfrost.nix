{ stdenv
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
  src = builtins.fetchGit {
    name = "mesa";
    url = https://gitlab.freedesktop.org/panfrost/mesa;
    rev = "13aae958f70a69166c0c241f683c8d3566ed26db";
    ref = "upstream-overlay";
  };
  preConfigure = ''
    rm src/gallium/drivers/panfrost
    ln -s ${builtins.fetchGit {
      name = "panfrost";
      url = https://gitlab.freedesktop.org/panfrost/panfrost;
      rev = "a25f2c0938874d71676c193aa31c20f99a7dcdf5";
      ref = "incremental-t8xx";
    }} src/gallium/drivers/panfrost
  '';
})
