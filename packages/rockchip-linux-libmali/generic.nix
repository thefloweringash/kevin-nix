{ stdenv, runCommand, fetchgit, libdrm, libX11, libxcb,

  driverName,
}:

runCommand "rockchip-linux-libmali" {
  src = fetchgit {
    url = "https://github.com/rockchip-linux/libmali";
    rev = "9840771868ebda1f6c2a17dd24dcd674ef0ca36a";
    sha256 = "11g557rckf2s86js5iqc2q75p8kz3xhph0ly6y4xs2g2pqy36r25";
  };

  driverFile = "lib/aarch64-linux-gnu/${driverName}";

  libPath = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc.lib
    libdrm
    libX11
    libxcb
  ];
} ''
  mkdir -p $out/lib
  cp --no-preserve=mode $src/$driverFile $out/lib/libmali.so
  patchelf --set-rpath "$libPath" $out/lib/libmali.so
''
