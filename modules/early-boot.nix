{ config, ... }:

{
  boot.initrd.availableKernelModules = [
    "analogix_dp"
    "panel_simple"
    "pwm_bl"
    "pwm_cros_ec"
    "rockchipdrm"
    "dw_hdmi"
    "dw_mipi_dsi"
    "drm"
    "cros_cs_dev"
    "cros_ec_ctl"
    "cros_ec_sensors"
    "cros_ec_sensors_core"
  ];
}
