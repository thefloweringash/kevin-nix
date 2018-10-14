{ runCommand }:

runCommand "alsaucm-kevin" {
  src = ./.;
} ''
  mkdir -p $out/share/alsa/ucm/rk3399-gru-sound
  cp --target-directory=$out/share/alsa/ucm/rk3399-gru-sound \
    $src/rk3399-gru-sound.conf \
    $src/HiFi.conf
''
