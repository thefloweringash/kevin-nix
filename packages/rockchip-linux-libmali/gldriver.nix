{ runCommand }:

{
  libmali,
  gllinks ? [
    "libGLESv1_CM.so" "libGLESv1_CM.so.1"
    "libGLESv2.so" "libGLESv2.so.2"
    "libOpenCL.so" "libOpenCL.so.1"
    "libEGL.so" "libEGL.so.1"
    "libwayland-egl.so" "libwayland-egl.so.1"
    "libgbm.so" "libgbm.so.1"
  ]
}:

runCommand "libmali-gldriver" {
  inherit gllinks libmali;
} ''
  mkdir -p $out/lib
  for i in $gllinks; do
    ln -s $libmali/lib/libmali.so $out/lib/$i
  done
''
