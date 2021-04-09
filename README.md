# Imagebuilder

Imagebuilder for GL.iNet devices. The Imagebuilder (previously called the Image Generator) is a pre-compiled environment suitable for creating custom images without having to compile the entire OpenWRT build environment.

**Note: Using the imagebuilder you can build a firmware using GL.iNet Router API and User Interface. This is free for personal use. If you use for commercial project, you need to obtain a commercial license.**

## Introduction

As the old imagebuilder repository gets bigger and bigger, it makes it harder to download and use. Because of this we have improved the imagebuilder code. It is smaller and faster than before, however, executing 'git pull' under the old imagebuilder will conflict, so please clone the new imagebuilder to a new directory or delete the old one. The old imagebuilder has been moved to https://github.com/gl-inet/imagebuilder_archive.

The companion https://github.com/gl-inet/glinet repository is downloaded automatically when running the **gl_image** program. If you encounter any issues downloading the glinet repository, you can use the '--depth=' parameter to clone it manually:

```bash
git clone --depth=1 https://github.com/gl-inet/imagebuilder gl_imagebuilder
```

## System requirements

- x86_64 platform
- Ubuntu or another linux distro

Running Imagebuilder under Windows can be done using the Windows Subsystem For Linux (WSL) with Ubuntu installed to it. Follow the guide bellow, installing Ubuntu 18.04 LTS from the Microsoft Store:

https://docs.microsoft.com/en-us/windows/wsl/install-win10

## Preparing your build environment

To use the Imagebuilder on your system will usually require you to install some extra packages.

For **Ubuntu 18.04 LTS**, run the following commands to install the required packages:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install device-tree-compiler gawk gcc git g++ make ncurses-dev python unzip -y
```

## Clone the Imagebuilder to your system

```bash
git clone https://github.com/gl-inet/imagebuilder gl_imagebuilder
cd gl_imagebuilder
```

**Note for Windows Subsystem For Linux (WSL) users:**

The Imagebuilder requires a "case sensitive" system, Windows is unfortunately not. To run the Imagebuilder in WSL you **MUST** clone the repo to the linux folder tree, ie: ```/home/<username>/``` or any other folder you choose. This is required, you **CAN NOT** run it from ```/mnt/c/``` or any other windows native drive mounted in WSL. Running the Imagebuilder from a Windows mounted disk will result in a failed build with cryptic messages.

# Usage

## 1.Basic usage

You can list all the device names by running the following command.
```
$ ./gl_image -l
```
You can run **./gl_image -p <image_name>** to build a specific firmware.For example, if you want to build a mifi firmware, run
```
$ ./gl_image -p mifi
```
To build all the device firmwares, run
```
$ ./gl_image -a
```
To see more details and advanced options,run
```
$ ./gl_image -h
```

## 2.Use your own configuration

To use your own configuration, use the **customize.json** file. Make any changes and run the command **./gl_image -c customize.json -p <image_name>** to build custom configured firmware.For example, build your custom configured firmware for the mifi:
```
$ ./gl_image -c customize.json -p mifi
```
**customize.json is just a demo that tells the customer how to modify the configuration file. GL is not maintained continuously. If you can't modify this file, please don't use customize.json to compile the firmware**
## 3.Add additional packages

For example, make an image for the **mifi** with some [extra packages](https://openwrt.org/packages/start) included:

```bash
$ ./gl_image -p mifi -e "openssh-sftp-server nano htop"
```
You'll find the compiled firmware image in *bin/gl-mifi/openwrt-mifi-ar71xx-generic-gl-mifi-squashfs-sysupgrade.bin*

For other firmwares, the compiled firmware file is in **bin/<device_name>/**

# Compile stable firmware based on GL.iNet.

Make sure you have compiled it once. It will automatically download the specified imagebuilder and glinet repository. 

## Example 1
Select the GL.iNet standard firmware that you want to make,such as the mifi

1. clone imagebuilder
```
$ git clone https://github.com/gl-inet/imagebuilder.git
```
2. switch to imagebuilder folder
```
$ cd imagebuilder
```
3. clone glinet (default master branch)
```
$ git clone https://github.com/gl-inet/glinet.git
```
4. compile firmware
```
$ ./gl_image -p mifi
```

## Example 2
Select another branch to compile,such as ar750s branch(this method is generally required for compiling the latest firmware)

1. clone imagebuilder
```
$ git clone https://github.com/gl-inet/imagebuilder.git
```
2. switch to imagebuilder folder
```
$ cd imagebuilder
```
3. clone glinet (default master branch)
```
$ git clone https://github.com/gl-inet/glinet.git
```
4. switch to ar750s branch to compile
```
$ cd glinet
$ git checkout ar750s
```
5. return to the imagebuilder folder
```
$ cd ../
```
6. compile firmware
```
$ ./gl_image -p ar750s
```

## Example 3
Choose another tag to compile the version you want, for example, the firmware of ar750s with version 3.025

1. clone imagebuilder
```
$ git clone https://github.com/gl-inet/imagebuilder.git
```
2. switch to imagebuilder folder
```
$ cd imagebuilder
```
3. clone glinet (default master branch)
```
$ git clone https://github.com/gl-inet/glinet.git
```
4. go to the glinet directory and view the history tag
```
$ cd glinet
$ git tag
```
5. switch to the 3.025 version of the ar750s firmware tag
```
$ git checkout ar750s_v3.025_20190626
```
6. return to the imagebuilder folder
```
$ cd ../
```
7. compile firmware
```
$ ./gl_image -i -p ar750s
```

**Oops! Failed to parse glinet/images.json**

If you encounter this error, don't panic. Please copy the corresponding version in the config directory to the glinet directory and run again.

```
$ cp glinet/images.json glinet/images.json
$ ./gl_image -i -p ar750s
```

# Build a custom ipk using imagebuilder

You can go to the link https://github.com/gl-inet/sdk according to the instructions to compile helloworld.ipk. Use this package for imagebuilder test.Or use your own ipk and emulate the following steps to build the firmware.

## Basic configuration

**Add ipk packages**

1.The new download of the uncompiled imagebuilder code in the root directory did not generate **/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1** directory structure, need to use **./gl_image -c custom.json -p <image_name>** to compile the source code once.

  Then create the **packages** directory in the **gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1** directory and place the customized **ipk** in that directory, as shown below，I put in a **helloworld_1.0_mips_24kc.ipk**

```
linux@ubuntu:~/gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1# ls packages/

..............
..............
**helloworld_1.0_mips_24kc.ipk**                                 Packages
libc_1.1.19-1_mips_24kc.ipk                                      Packages.gz
..............
..............
```
2.Modify the **customize.json** file.

	"mifi": {
			"profile": "gl-mifi",
			"version": "3.027",
			"imagebuilder": "3.1/openwrt-imagebuilder-ar71xx-generic_3.1",
			"packages": "gl-base-files-ar $basic $vpn $storage $glinet $usb -wpa-cli -kmod-rt2800-usb helloworld"
		}

----------
**Set files properties**

1.If you want to compile your own **/etc/init.d/gl_init** files or **/www** folders, you need to specify the files properties.Then create the files directory in the **gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1** directory.

  The modified **/etc/init.d/gl_init** file, according to the folder directory structure put into the **gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files** directory.

   The modified */www* folder is also placed in the files directory. As shown below.
```
linux@ubuntu:~/gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files$ ls

etc  www
```
2.Modify the **customize.json** file.

	"mifi": {
			"profile": "gl-mifi",
			"version": "3.027",
			"imagebuilder": "3.1/openwrt-imagebuilder-ar71xx-generic_3.1",
			"packages": "gl-base-files-ar $basic $vpn $storage $glinet $usb -wpa-cli -kmod-rt2800-usb helloworld",
			"files": "imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files"
		}

----------
3.Save the customize.json file.

4.Compile the code with **./gl_image -c custom.json -p mifi**

5.Completed in *gl_imagebuilder/bin/mifi/openwrt-mifi-3.027-0312_customize.bin*, find the bin file and installed to the routing.

## Advanced configuration

All the GL device package configuration is done with the **images.json** file. The following

	packages: The default packages included in all firmwares
	profiles: Configuration for each firmware
	{
		<image_name>:
		{
		    profile: The name of the device. Run "make info" for a list of available devices.
		    version: Firmware version. Generates a version file called /etc/glversion and overrides /etc/opk/distfeeds.conf with the version number
		    imagebuilder: Image builder folder
		    packages: Packages in the firmware. Variables include the default packages. Add the package name to include. "-" appended to the package name excludes the package, eg: "-mwan3"
		    files: Files folder, it allows customized configuration files to be included in images built with Image Generator, all files from the folder will be copied into device's rootfs("/").
		}
	}

**Example**

We want to create a clean customized firmware for our mifi device that includes **helloworld.ipk**, here is an example of a user-defined configuration file. We name it **myfirst.json**:

```
linux@ubuntu:~/gl_imagebuilder# cat myfirst.json

{
	"profiles":
	{
	    "helloworld":
		{
	        "profile": "gl-mifi",
	        "version": "3.027",
	        "imagebuilder": "3.1/openwrt-imagebuilder-ar71xx-generic_3.1",
	        "packages": "luci helloworld"
	    }
	}
}

```

Placing the helloworld.ipk in the glinet/ar71xx folder and running **./gl_image -c myfirst.json -p helloworld** will build our clean image with our helloworld.ipk included.

# Docker build environment

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

You'll find the compiled firmware image in *bin/<date>/gl-mifi/openwrt-mifi-ar71xx-generic-gl-mifi-squashfs-sysupgrade.bin*

For other firmwares, the compiled firmware file is in **bin/<date>/<device_name>/**
