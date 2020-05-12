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

## How to build custom ipk with imagebuilder?
1. The new download of the uncompiled imagebuilder code in the root directory did not generate */imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1* directory structure, need to use **./gl_image -c custom.json -p <image_name>** to compile the source code once.Then create the packages directory in the *gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1* directory and place the customized **ipk** in that directory, as shown below，I put in a **mylibndpi_2.8-1_mips_24kc.ipk**

```
linux@ubuntu:~/gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1$ ls packages/
```
kernel_4.9.120-1-3b343e31a06aaa866bf90c839452ce76_mips_24kc.ipk  **mylibndpi_2.8-1_mips_24kc.ipk**
libc_1.1.19-1_mips_24kc.ipk                                      Packages
libconfig_1.5-1_mips_24kc.ipk                                    Packages.gz
libjson-c_0.12.1-1_mips_24kc.ipk                                 uclibcxx_0.2.4-3_mips_24kc.ipk
libpcap_1.8.1-1_mips_24kc.ipk

2.Modify the **customize.json** file.

	"mifi": {
			"profile": "gl-mifi",
			"version": "3.027",
			"imagebuilder": "3.1/openwrt-imagebuilder-ar71xx-generic_3.1",
			"packages": "gl-base-files-ar $basic $vpn $storage $glinet $usb -wpa-cli -kmod-rt2800-usb mylibndpi"

		}

Just package the **ipk** file without setting the files property.

----------

If you want to compile your own /etc/init.d/gl_init files or /www folders, you need to specify the files properties.Then create the files directory in the *gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1* directory.The modified */etc/init.d/gl_init* file, according to the folder directory structure put into the *gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files* directory.The modified */www* folder is also placed in the files directory. As shown below.
```
linux@ubuntu:~/gl_imagebuilder/imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files$ ls
```

**etc  www**

	"mifi": {
			"profile": "gl-mifi",
			"version": "3.027",
			"imagebuilder": "3.1/openwrt-imagebuilder-ar71xx-generic_3.1",
			"packages": "gl-base-files-ar $basic $vpn $storage $glinet $usb -wpa-cli -kmod-rt2800-usb mylibndpi",
		        "files": "imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files"
		}

----------
3.Save the customize.json file.

4.Compile the code with **./gl_image -c custom.json -p mifi**

5.Completed in *gl_imagebuilder/bin/mifi/openwrt-mifi-3.027-0312_customize.bin*, find the bin file and installed to the routing.

## How to compile stable firmware based on GL.iNet?

Make sure you have compiled it once. It will automatically download the specified imagebuilder and glinet repository. 

Example 1:Select the version you want to make, sush as mifi

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
Example 2:Select another branch to compile

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

Warnning, If you encounter this error, don't panic. Please copy the corresponding version in the config directory to the glinet directory and run again.

```
$ cp config/images.json.3.023 glinet/images.json
$ ./gl_image -i -p mifi
```

