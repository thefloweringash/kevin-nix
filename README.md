# NixOS on Samsung Chromebook Plus

This project is a configuration of NixOS that renders it bootable on a
Samsung Chromebook Plus in the form of a image that can be dumped to a
microSD card and booted directly. The majority of the effort was
accomplished by the [Arch Linux ARM][] project, which builds an
[appropriate kernel][], which was imported directly.

[Arch Linux ARM]: https://archlinuxarm.org
[appropriate kernel]: https://github.com/archlinuxarm/PKGBUILDs/tree/master/core/linux-gru

## Status

Weekend hobby project. Works for me. Does not support `nixos-rebuild
switch`, boot configuration must be set manually.

## Building

```
nix-build '<nixos>' \
  -I nixos=... \
  -I nixos-config=sd-image-kevin.nix \
  -A config.system.build.sdImage
```

`<nixos>` should refer to the `nixos` subdirectory of a nixpkgs
checkout.

Or try `./simple-build.sh`.

## Installation

Dump image to SD card. Insert into Chromebook. Boot.

## Post installation configuration

Use the standard nixos-generate-config command to generate the
hardware and filesystem configuration file. In the main configuration
file (`configuration.nix`), include the two modules from this
repository's `modules/` directory, which adds in the kernel package,
and the kernel partition (kpart) builder. In you main
configuration.nix, specify your desired kernel. For example:

```
{ config, lib, pkgs, ... }:
{
  include = [
    ./kevin-nix/modules/packages.nix
    ./kevin-nix/modules/kpart.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_gru_4_4;
}
```

## nixos-rebuild switch

The boot process scans the media for a partition designated as a
kernel, using attributes stored in GPT. This kernel partition (kpart)
is a Flattened Image Tree (fit) image including the kernel, a set of
dtbs,the initrd, and the kernel command line. The `kpart` module
produces this file as part of each nixos-rebuild.

Since the kernel command line in nixos determines which system
configuration is booted, each kpart corresponds to a profile. To set
the boot configuration you must install the kpart into the kernel
partition.

For example, on a microSD card install, the kernel partition will
typically be at /dev/mmcblk1p1, and hence setting a profile as the
boot profile is achieved through:

```
dd if=/run/current-system/kpart of=/dev/mmcblk1p1
```

Note that the kernel partition is not a GC root. If you remove old
versions of your system profile, you may render your environment
unbootable.

### Generated partition layout

```
$(nix-build --no-out-link -E 'import <nixpkgs> { overlays = [ (import ./packages) ]; }' -A vboot_utils)/bin/cgpt show $(readlink ./result)

       start        size    part  contents
           0           1          PMBR
           1           1          Pri GPT header
           2          32          Pri GPT table
        2048      131072       1  Label: "kernel"
                                  Type: ChromeOS kernel
                                  UUID: 534078AF-3BB4-EC43-B6C7-828FB9A788C6
                                  Attr: priority=10 tries=5 successful=1
      133120     4393031       2  Label: "NIX_SD"
                                  Type: B921B045-1DF0-41C3-AF44-4C6F280D3FAE
                                  UUID: 0340EA1D-C827-8048-B631-0C60D4478796
     4526151          32          Sec GPT table
     4526183           1          Sec GPT header
```

Notice the additional metadata for the kernel partition `Attr:
priority=10 tries=5 successful=1`.

## Versions

Tested against nixpkgs f607771d0f5.

## Future work

 * Make a fit image containing uboot, which can then use the standard
   extlinux-based boot flow.

 * Use a vanilla kernel. It is expected that 4.16 will include support
   that enables the display without additional patches.
