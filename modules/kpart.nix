{ config, pkgs, lib, ... }:

let
  make-kpart = pkgs.runCommand "make-kpart.sh" {
    inherit (pkgs) vboot_utils ubootTools dtc;
    kernel_its = ./kernel.its;
  } ''
    substituteAll ${./make-kpart.sh} $out
    chmod a+x $out
  '';
in
{
  system.extraSystemBuilderCmds = ''
    ${make-kpart} $out
  '';
}
