{ runCommand }:

runCommand "alsaucm-kevin" {
  src = ./rk3399-gru-sound;
} ''
  outdir=$out/share/alsa/ucm/rk3399-gru-sound

  mkdir -p $outdir
  cp --target-directory=$outdir \
    $src/rk3399-gru-sound.conf \
    $src/HiFi.conf

  sed -i -E \
    -e '/(Capture|Playback)PCM/s/rk3399-gru-sound/rk3399grusound/' \
    -e '/PlaybackRate/d' \
    $outdir/HiFi.conf
''
