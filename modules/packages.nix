{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ./../packages) ];
}
