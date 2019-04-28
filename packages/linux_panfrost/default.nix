{ stdenv, buildPackages, fetchgit, buildLinux, ... }@args:

buildLinux (args // rec {
  version = "5.0";
  modDirVersion = "5.0.0";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/panfrost/linux.git/";
    rev = "88b124cdc880a5d27f8c9235be58a6a7439d98e9";
    sha256 = "1cshhm94s388dk8iiw3v6qrb0b08wm4pak5scr02i0yxkzcw8kgx";
  };


  # Add DRM_PANFROST to make sure it's enabled
  # Disable DRM_MESON, because it doesn't build.
  extraConfig = ''
    DRM_PANFROST m
    DRM_MESON n
  '';
} // (args.argsOverride or {}))
