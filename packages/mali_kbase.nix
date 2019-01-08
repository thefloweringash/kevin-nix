{ stdenv, kernel, fetchgit }:

stdenv.mkDerivation rec {
  pname = "mali-kbase";
  version = "20181213";
  name = "${pname}-${version}";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/tomeu/mali_kbase";
    rev = "3eae495a"; # rk3399
    sha256 = "0qlp30kfsymr23xplji5wlqk15mmi2q4lqqrzh49c8iayqdwyqay";
  };

  KDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = "\${out}";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  installPhase = ''
    make -C $KDIR M=$PWD/driver/product/kernel/drivers/gpu/arm/midgard modules_install
  '';
}