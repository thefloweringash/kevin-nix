{ stdenv, fetchurl, freetype }:

stdenv.mkDerivation rec {
  name = "otf2bdf-${version}";
  version = "3.1";

  buildInputs = [ freetype ];

  patches = [
    ./0001-Remove-deprecated-MKINSTALLDIRS.patch
    ./0002-Fix-generate_font-return-value.patch
  ];

  src = fetchurl {
    url = "https://www.math.nmsu.edu/~mleisher/Software/otf2bdf/otf2bdf-3.1.tgz";
    sha256 = "1npsmd9a815h7fw0w2w34106hkk77901lcvvbfnqcww62f30ndv1";
  };
}
