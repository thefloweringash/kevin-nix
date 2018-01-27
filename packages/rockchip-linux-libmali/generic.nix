{ stdenv, fetchgit, wayland, libdrm,

  driverName,
}:

stdenv.mkDerivation {
  name = "rockchip-linux-libmali";
  src = fetchgit {
    url = "https://github.com/rockchip-linux/libmali";
    rev = "6d53e639c8f9f35a4a3177cd7859a01c6a9e1b85";
    sha256 = "0k8qksz12cx8jrabf3akvck7wam39nafaxrbv402wliyzlfzyyps";
  };

  driverFile = "lib/aarch64-linux-gnu/${driverName}";

  libPath = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc.lib
    wayland
    libdrm
  ];

  buildPhase = ''
    patchelf --set-rpath "$libPath" $driverFile
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp $driverFile $out/lib/libmali.so
  '';
}
