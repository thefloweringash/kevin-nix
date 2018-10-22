{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_gru_4_4_86;

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

    monitorSection = ''
      DisplaySize 317 211
    '';

    videoDrivers = [ "modesetting" "fbdev" ];

    displayManager.slim = {
      enable = true;
      defaultUser = "panfrost";
      autoLogin = true;
    };

    windowManager.default = "i3";
    windowManager.i3.enable = true;

    desktopManager.default = "none";
    desktopManager.xterm.enable = false;
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
