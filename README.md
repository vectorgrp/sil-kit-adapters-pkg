# The Vector SIL Kit Adapter Packaging
This sil-kit-adapters-pkg repository allows you to build a Debian package for the following SIL Kit Adapters:
* The [Vector SIL Kit Adapter for virtual CAN](https://github.com/vectorgrp/sil-kit-adapters-vcan)
* The [Vector SIL Kit Adapter for QEMU](https://github.com/vectorgrp/sil-kit-adapters-qemu)
* The [Vector SIL Kit Adapter for TAP devices](https://github.com/vectorgrp/sil-kit-adapters-tap)
* The [Vector SIL Kit Adapter for Generic Linux IO](https://github.com/vectorgrp/sil-kit-adapters-generic-linux-io)

To be able to use a SIL Kit Adapter package on your system, you have to install the SIL Kit. 
This can be done following the instructions given with the [SIL Kit source code](https://github.com/vectorgrp/sil-kit)
or by installing a SIL Kit package using the [sil-kit-pkg](https://github.com/vectorgrp/sil-kit-pkg).

> Currently the SIL Kit Adapter packages are only supported/tested on **amd64** architecture.

## Prerequisites
To build a SIL Kit Adapter package, you will need to install the following packages:
```
sudo apt install debhelper build-essential dh-cmake devscripts dh-make
```

## Building a SIL Kit Adapter package
The build environment uses the following variables:
* **ADAPTER_NAME**: The name of the adapter you want to package: `tap, vcan, qemu, generic-linux-io`
* **TAG_NAME**: ***(optional)*** A tag of the adapter if you want to package a specific version.

### Building using the Github CI
To use the provided Github Action, you first have to fork the sil-kit-adapters-pkg repository. 
Then follow the next steps:

* Click on the `Actions` tab in your Github repo
* Click on the `.github/workflows/package-debian.yml` tab
* Click on the `Run Workflow` tab
* Enter the values as described just above
* Click on the `Run Workflow` tab

> You can also modify the Ubuntu CPU architecture the package should be build for. However as mentionned before only `amd64` 
architecture is supported and tested.

The Debian package you are building will be available in an archive as artifact under the workflow you run.

### Building it manually
You can also build a SIL Kit Adapter package using the `build_deb.sh` script, which you can find in `.github/actions/build_deb.sh`. 
This script is basically the one called in the Github workflow to build a package.
Before running this script, you have to define the previous mentionned variables and the path to your
local sil-kit-adapters-pkg directory using the **PKG_DIR** variable.\
For example to package the SIL Kit Adapter TAP:
```
export PKG_DIR=/path/to/sil-kit-adapters-pkg
export ADAPTER_NAME=tap
cd /path/to/sil-kit-adapters-pkg
mkdir build && cd build
../.github/actions/build_deb.sh
```

The Debian package will be available in the build folder.

## Installing the package
To install the SIL Kit Adapter package you want, run the following command:
```
sudo dpkg -i /path/to/sil-kit-adapter-<name>_<version>_<architecture>.deb
```

> Or by using the apt command:\
>`sudo apt install /path/to/sil-kit-adapter-<name>_<version>_<architecture>.deb`

## Removing the package
To remove the SIL Kit Adapter package you installed, run the following command:
```
sudo dpkg -r sil-kit-adapter-<name>
```

> Or by using the apt command: `sudo apt remove sil-kit-adapter-<name>`
