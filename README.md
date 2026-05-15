# Linux Firmware for Nova

This repository provides temporary Linux firmware binaries for the
Nova GPU driver.  Use the files in here until proper files are
available in the official linux-firmware git repository.

## Installation Instructions

After cloning the repository, extract the tarball directly into
/lib/firmware/ as root.

```bash
cd linux-firmware-nova
sudo tar xf v570.144.tar.zstd -C /lib/firmware
