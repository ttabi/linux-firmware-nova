#!/bin/sh
# SPDX-License-Identifier: MIT

URL="http://linuxqa.nvidia.com/builds/release/display/x86_64"

usage()
{
    echo "Usage: $0 <version>"
}

if [ $# -lt 1 ]
then
    usage
    exit 1
fi

if ! ping -q -c 1 -w 1 linuxqa.nvidia.com >/dev/null
then
    echo "Cannot access Q/A builds"
    exit 1
fi

if [ -z "${P4ROOT}" ] || [ ! -d "${P4ROOT}" ]
then
    echo "Please set P4ROOT variable"
    exit 1
fi

if [ ! -x ${P4ROOT}/sw/dev/gpu_drv/chips_a/drivers/resman/build/common/extract-firmware-nova.py ]
then
    echo "Cannot find extract-firmware-nova.py in ${P4ROOT}"
    exit 1
fi

if ! git lfs version >/dev/null 2>&1
then
    echo "git-lfs must be installed"
    exit 1
fi

NVIDIA_VERSION=$1
DEST=$(pwd -P)

if ! wget --spider -q --timeout=2 --tries=1 --max-redirect=0 "${URL}/${NVIDIA_VERSION}/"
then
    echo "Invalid release ${NVIDIA_VERSION}"
    exit 1
fi

if git show-ref --quiet --verify refs/heads/v${NVIDIA_VERSION}
then
    git checkout v${NVIDIA_VERSION}
else
    # Create the branch if it doesn't exist already.
    git checkout main -b v${NVIDIA_VERSION}
fi

TEMPDIR=$(mktemp -d)

cd ${TEMPDIR}
wget -O - ${URL}/${NVIDIA_VERSION}/NVIDIA-kernel-module-source-${NVIDIA_VERSION}.tar.xz | tar xJ --strip-components=1

if [ ! "${NVIDIA_VERSION}" = $(sed -n 's/^NVIDIA_VERSION *= *//p' version.mk) ]
then
    echo "${URL}/${NVIDIA_VERSION}/NVIDIA-kernel-module-source-${NVIDIA_VERSION}.tar.xz contains an incomplete source tree"
    exit 1
fi

if [ "${NVIDIA_VERSION}" != "${NVIDIA_VERSION}" ]
then
    echo "OpenRM source tree version mismatch ${NVIDIA_VERSION}"
    exit 1
fi

${P4ROOT}/sw/dev/gpu_drv/chips_a/drivers/resman/build/common/extract-firmware-nova.py -d ${URL}/${NVIDIA_VERSION}/NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run -s -w

cd _out
mv WHENCE.txt ${DEST}/WHENCE
find . -type f -exec cp --parents -t ${DEST} {} +

cd ${DEST}

git add WHENCE nvidia
git commit -m "nvidia: add v${NVIDIA_VERSION}"

git checkout logfiles
wget -O - ${URL}/${NVIDIA_VERSION}/mangle/gsp_log.tar.xz | tar xJ
mv gsp_log_tu10x.bin logfiles/gsp_log_tu10x-${NVIDIA_VERSION}.bin
mv gsp_log_ga10x.bin logfiles/gsp_log_ga10x-${NVIDIA_VERSION}.bin
git add logfiles
git commit -m "nvidia: add v${NVIDIA_VERSION} log files"

git checkout v${NVIDIA_VERSION}
rm -rf ${TEMPDIR}
