{ stdenv, kernel, fetchgit }:

stdenv.mkDerivation rec {
  pname = "mali-kbase";
  version = "20181213";
  name = "${pname}-${version}";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/panfrost/mali_kbase";
    rev = "c59a1cd7c66f0800c826814ac1096e3a746e2a91"; # master
    sha256 = "1ms72x4snrpps84ppx62hfbq3y4wlb9nsdh2r3i7r1zhbwnpf9fi";
  };

  KDIR = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = "\${out}";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  installPhase = ''
    make -C $KDIR M=$PWD/driver/product/kernel/drivers/gpu/arm/midgard modules_install
  '';
}
