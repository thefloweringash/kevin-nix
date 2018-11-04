{ config, lib, pkgs, options, ... }:

let
  xresources = pkgs.writeText "Xresources" ''
    UXTerm*font: xft:SourceCodePro:size=9

    Xcursor.size: 48
    Xcursor.theme: Adwaita
  '';

  sway-module = if options.programs ? "sway-beta" then "sway-beta" else "sway";
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
    extraGroups = [ "wheel" "video" "networkmanager" ];
  };

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  services.xserver = {
    enable = true;
    layout = "us";

    dpi = 192;

    monitorSection = ''
      DisplaySize 317 211
    '';

    videoDrivers = [ "modesetting" "fbdev" ];

    libinput = {
      enable = true;
      naturalScrolling = true;
      clickMethod = "clickfinger";
    };

    displayManager.slim = {
      enable = true;
      defaultUser = "panfrost";
      autoLogin = true;
    };

    displayManager.sessionCommands = with pkgs; ''
      ${xorg.xrdb}/bin/xrdb -merge ${xresources}
      ${dex}/bin/dex -ae i3
    '';

    windowManager.default = "i3";
    windowManager.i3.enable = true;

    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
  };

  programs.light.enable = true;
  programs."${sway-module}".enable = true;

  environment.systemPackages = with pkgs; [
    # System essentials
    hicolor-icon-theme
    networkmanagerapplet
    gnome3.adwaita-icon-theme

    # Directly relevant to panfrost
    glmark2
  ] ++ (with xorg; [
    # X introspection
    xdpyinfo
    xev
    xmodmap
    xwininfo
  ]);
}
