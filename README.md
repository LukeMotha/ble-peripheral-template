# Information

This repo contains an example on how to development nRF52 projects with Nix (on NixOs or another Linux distro) using ble_app_template from the nordic SDK. I put this here in the hopes it would help others since embedded development on NixOs/with Nix is rarely discussed. As such this should be by no means taken as an optimal setup but simply one that was sufficient for my needs.
This example targets the nRF52840DK board (pca10056) and softdevice s140. To change the target the Makefile TARGETS variable should be overwritten. Nordic dev board requires s140 softdevice to be flashed prior to the BLE application hex/binary being flashed. 

[nRF52840DK User Guide](https://infocenter.nordicsemi.com/pdf/nRF52840_PDK_User_Guide_v1.2.pdf)


# Workflow

To build the hex/binary for nRF dev board simply call:

``` sh
nix-build
```

This can then be flashed to the device using nrfjprog. For convienence drop into nix-shell to have the nRF SDK easily available (SDK_ROOT) and the device can erased and flashed with:

``` sh
remake erase
remake flash_softdevice
remake flash
```

# Workaround(s)/Issue(s)

- Standard fetchurl hangs when attempting to download the SDK so a custom fetcher, fetchurlWithHttpie, is used as a workaround. Strangely curl itself doesn't hang (if used with -L) in CLI.
- nrfjprog isn't integrated since it's installation is more involved (requires udev) and the user may have a different preference for flashing their nrf52 device.
- nix-build will re-compile all C source dependencies since they are stored in the nix-store (under result/), for regular development it's more ergonomic to just use nix-shell and make.

