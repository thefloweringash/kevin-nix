{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "kevin-tablet-mode";
  version = "20181222";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "thefloweringash";
    repo = pname;
    rev = "3ceb15f254cd0673a8f72b9786ff63abc8a608aa";
    sha256 = "0h0q8xpanpam3i6l6b55pbpq8v4ag4fas0w8yxqjnla0dla8dpg8";
  };

  nativeBuildInputs = [ cmake ];
}
