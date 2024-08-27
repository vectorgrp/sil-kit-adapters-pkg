#!/bin/bash

pkg_dir=$PKG_DIR
adapter=$ADAPTER_NAME
tag_name=$TAG_NAME

if [ -z "$adapter" ]; then
  echo "[error] The adapter name is required. You must export ADAPTER_NAME variable before running this script."
  echo "The allowed adapter names are: tap, vcan, qemu, generic-linux-io"
  echo "Example: export ADAPTER_NAME=tap"
  exit 1
fi

adapter_full_name=
if [[ "$adapter" == "tap" ]]; then
  adapter_full_name="TAP devices"
elif [[ "$adapter" == "vcan" ]]; then
  adapter_full_name="virtual CAN"
elif [[ "$adapter" == "qemu" ]]; then
  adapter_full_name="QEMU"
elif [[ "$adapter" == "generic-linux-io" ]]; then
  adapter_full_name="Generic Linux IO"
else
  echo "[error] The provided adapter name is invalid."
  echo "The allowed adapter names are: tap, vcan, qemu, generic-linux-io"
  exit 1
fi

echo "[info] Building the Vector SIL Kit Adapter for $adapter_full_name package"

debian_path="${pkg_dir}/sil-kit-adapter-${adapter}/debian"

if [ ! -z ${tag_name} ] ; then
  tag_name=${tag_name:1} # remove the 'v' from the tag
  # update the adapter version with the tag
  sed -i -E "s/(sil-kit-adapter-${adapter} \()[0-9]+\.[0-9]+\.[0-9]+(-preview[0-9]*)?(-RC[0-9]*)?/\1${tag_name}/" ${debian_path}/changelog
fi

adapter_full_version=$(sed -En "s/sil-kit-adapter-${adapter} \(([0-9]+\.[0-9]+\.[0-9]+(-preview[0-9]*)?(-RC[0-9]*)?(-[0-9]+))\).*/\1/p" ${debian_path}/changelog)
adapter_version=$(echo $adapter_full_version | sed 's/-[0-9]*$//')
debian_version=$(echo $adapter_full_version | awk -F'-' '{print $NF}')

echo "[info] Packaging sil-kit-adapter-${adapter} version $adapter_version"
echo "[info] Packaging Debian version $debian_version"

# Check if running in CI
if [[ $CI_RUN -eq "1" ]] ; then
  echo "[info] Saving the version and revision to Github step outputs"
  echo "adapter_version=${adapter_version}" >> $GITHUB_OUTPUT
  echo "debian_revision=${debian_version}" >> $GITHUB_OUTPUT
fi

adapter_folder="sil-kit-adapter-${adapter}-${adapter_version}"

echo "[info] Cloning sil-kit-adapters-${adapter} repository"
git -c http.sslVerify=false clone https://github.com/vectorgrp/sil-kit-adapters-${adapter}.git -b v${adapter_version} --recursive $adapter_folder
ret_val=$?
if [ "$ret_val" != '0' ] ; then
  echo "[error] Could not clone sil-kit-adapters-${adapter}"
  exit 1
fi

tar --exclude='.git' -cJf sil-kit-adapter-${adapter}_${adapter_version}.orig.tar.xz -C $adapter_folder .
ret_val=$?
if [ "$ret_val" != '0' ] ; then
  echo "[error] Could not create orig tarball sil-kit-adapter-${adapter}_${adapter_version}.orig.tar.xz"
  exit 1
fi

cp -r $debian_path $adapter_folder
cd $adapter_folder

echo "[info] Running debuild"
debuild -us -uc --lintian-opts -E --pedantic
ret_val=$?
if [ "$ret_val" != '0' ] ; then
  echo "[error] \"debuild -us -uc --lintian-opts -E --pedantic\" exit code $ret_val"
  exit 1
fi

exit 0
