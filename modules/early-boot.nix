{ config, ... }:

{
  boot.initrd.availableKernelModules = [
    "analogix_dp"
    "panel_simple"
    "pwm_bl"
    "pwm_cros_ec"
    "rockchipdrm"
  ];
}
