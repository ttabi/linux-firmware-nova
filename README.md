# Linux Firmware for Nova

This repository provides temporary Linux firmware binaries for the
Nova GPU driver.  Use the files in here until proper files are
available in the official linux-firmware git repository.

## Installation Instructions

After cloning the repository, run the installer to copy the files to 
/lib/firmware/ as root.

It is necessary to remove /lib/firmware/nvidia because the new files
could be in an incompatible directory hierarchy.

```bash
cd linux-firmware-nova
git checkout <branch-name>
sudo mv /lib/firmware/nvidia /lib/firmware/nvidia.orig
sudo ./copy-firmware.sh -v -j$(nproc) /lib/firmware
