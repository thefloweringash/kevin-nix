{ config, lib, pkgs, ... }:

let
  xresources = pkgs.writeText "Xresources" ''
    UXTerm*font: xft:SourceCodePro:size=9
  '';
in
{
  boot.kernelPackages = pkgs.linuxPackages_gru_4_4_86;

  fonts.fontconfig.dpi = 192;

  fonts.fonts = with pkgs; [
    source-code-pro
  ];

  hardware.panfrost.enable = true;

  users.extraUsers.panfrost = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "video" ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.xserver = {
    enable = true;
    layout = "us";

    dpi = 192;

    monitorSection = ''
      DisplaySize 317 211
    '';

    videoDrivers = [ "modesetting" "fbdev" ];

    displayManager.slim = {
      enable = true;
      defaultUser = "panfrost";
      autoLogin = true;
    };

    displayManager.sessionCommands = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xresources}
    '';

    windowManager.default = "i3";
    windowManager.i3.enable = true;

    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
  };

  environment.systemPackages = with pkgs; [
    hicolor-icon-theme
  ];
}
