# Imagebuilder #

Imagebuilder for GL.iNet devices. The Imagebuilder (previously called the Image Generator) is a pre-compiled environment suitable for creating custom images without having to compile the entire OpenWRT build environment.

## Introduction

As the old imagebuilder repository gets bigger and bigger, it makes it harder to download and use. Because of this we have improved the imagebuilder code. It is smaller and faster than before, however, executing 'git pull' under the old imagebuilder will conflict, so please clone the new imagebuilder to a new directory or delete the old one. The old imagebuilder has been moved to https://github.com/gl-inet/imagebuilder_archive.

The companion https://github.com/gl-inet/glinet repository is downloaded automatically when running the **gl_image** program. If you encounter any issues downloading the glinet repository, you can use the '--depth=' parameter to clone it manually:

```bash
git clone --depth=1 https://github.com/gl-inet/imagebuilder gl_imagebuilder
```

## System requirements ##

- x86_64 platform
- Ubuntu or another linux distro

Running Imagebuilder under Windows can be done using the Windows Subsystem For Linux (WSL) with Ubuntu installed to it. Follow the guide bellow, installing Ubuntu 18.04 LTS from the Microsoft Store:

https://docs.microsoft.com/en-us/windows/wsl/install-win10

## Preparing your build environment ##

To use the Imagebuilder on your system will usually require you to install some extra packages.

For **Ubuntu 18.04 LTS**, run the following commands to install the required packages:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install device-tree-compiler gawk gcc git g++ make ncurses-dev python unzip -y
```

## Clone the Imagebuilder to your system ##

```bash
git clone https://github.com/gl-inet/imagebuilder gl_imagebuilder
cd gl_imagebuilder
```

**Note for Windows Subsystem For Linux (WSL) users:**

The Imagebuilder requires a "case sensitive" system, Windows is unfortunately not. To run the Imagebuilder in WSL you **MUST** clone the repo to the linux folder tree, ie: ```/home/<username>/``` or any other folder you choose. This is required, you **CAN NOT** run it from ```/mnt/c/``` or any other windows native drive mounted in WSL. Running the Imagebuilder from a Windows mounted disk will result in a failed build with cryptic messages.

## Usage ##

To build all the device firmwares, run **./gl_image -a**. To build a specific firmware, run **./gl_image -p <image_name>**. You can list all the device names by running **./gl_image -l**.

Run **./gl_image -h** to see more details and advanced options.

To use your own configuration, use the **customize.json** file. Make any changes and run the imagebuilder with the following command to run the custom configuration:

**./gl_image -c customize.json -p <image_name>**

## Complete usage example ##

To make an image for the **Mifi** with some [extra packages](https://openwrt.org/packages/start) included:

```bash
./gl_image -p mifi -e "openssh-sftp-server nano htop"
```

You'll find the compiled firmware image in *bin/gl-mifi/openwrt-mifi-ar71xx-generic-gl-mifi-squashfs-sysupgrade.bin*

For other firmwares, the compiled firmware file is in **bin/<device_name>/**

## Docker build environment ##

You can also use a docker container as build environment.

Install Docker to your system, here is how to do it for Ubuntu:

```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

After cloning the Imagebuilder to your system as in the previous section, build the Docker image by running the following:

```bash
sudo docker build --rm -t gl_imagebuilder - < Dockerfile
```

To list all the possible device names:

```bash
sudo docker run -v "$(pwd)":/src gl_imagebuilder -l
```

And to make a firmware image for the **Mifi** with some extra packages included:

```bash
sudo docker run -v "$(pwd)":/src gl_imagebuilder -p mifi -e openssh-sftp-server nano htop
```

You'll find the compiled firmware image in *bin/gl-mifi/openwrt-mifi-ar71xx-generic-gl-mifi-squashfs-sysupgrade.bin*

For other firmwares, the compiled firmware file is in **bin/<device_name>/**

## Advanced configuration ##

All the GL device package configuration is done with the **images.json** file. The following options control the configuration:

```bash
packages: The default packages included in all firmwares
profiles: Configuration for each firmware
{
    <image_name>:
    {
        profile: The name of the device. Run "make info" for a list of available devices.
        version: Firmware version. Generates a version file called /etc/glversion and overrides /etc/opk/distfeeds.conf with the version number
        imagebuilder: Imagebuilder folder
        packages: Packages in the firmware. Variables include the default packages. Add the package name to include. "-" appended to the package name excludes the package, eg: "-mwan3"
        files: Files folder, it allows customized configuration files to be included in images built with Image Generator, all files from the folder will be copied into device's rootfs("/").
    }
}
```

Assuming that we have a helloworld.ipk created by the SDK here:

https://github.com/gl-inet/sdk

And we want to create a clean customized firmware for our AR150 device that includes this ipk, here is an example of a user-defined configuration file. We name it *myfirst.json*:

```bash
{
	"profiles": {
		"helloworld": {
			"profile": "gl-ar150",
			"version": "3.001",
			"imagebuilder": "3.0/openwrt-imagebuilder-ar71xx-generic",
			"packages": "luci helloworld"
			"files": "files_folder"
		}
	}
}
```

Note: the `files_folder` path can be a relative path or an absolute path or current directory.

Placing the helloworld.ipk in the *glinet/ar71xx* folder and running **./gl_image -c myfirst.json -p helloworld** will build our clean image with our helloworld.ipk included.

## How to compile stable firmware based on GL.iNet?

Make sure you have compiled it once. It will automatically download the specified imagebuilder and glinet repository. 

Select the version you want to make, sush as mifi_v3.023,

```
$ cd glinet/
$ git tag -l
...
mifi_v3.023_20190513
...

$ git checkout mifi_v3.023_20190513
$ cd ../
$ ./gl_image -i -p mifi
Oops! Failed to parse glinet/images.json
```

Warnning, If you encounter this error, don't panic. Please copy the corresponding version in the config directory to the glinet directory and run again.

```
$ cp config/images.json.3.023 glinet/images.json
$ ./gl_image -i -p mifi
```

