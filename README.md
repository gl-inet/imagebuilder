

# Imagebuilder

Imagebuilder for GL.iNet devices. The Imagebuilder (previously called the Image Generator) is a pre-compiled environment suitable for creating custom images without having to compile the entire OpenWRT build environment.

***Note: Using the imagebuilder you can build a firmware using GL.iNet Router API and User Interface. This is free for personal use. If you use for commercial project, you need to obtain a commercial license. ***

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

## Usage

To build all the device firmwares, run **./gl_image -a**. To build a specific firmware, run **./gl_image -p <image_name>**. You can list all the device names by running **./gl_image -l**.

Run **./gl_image -h** to see more details and advanced options.

To use your own configuration, use the **customize.json** file. Make any changes and run the imagebuilder with the following command to run the custom configuration:

**./gl_image -c customize.json -p <image_name>**

## Complete usage example

To make an image for the **Mifi** with some [extra packages](https://openwrt.org/packages/start) included:

```bash
./gl_image -p mifi -e "openssh-sftp-server nano htop"
```

You'll find the compiled firmware image in *bin/gl-mifi/openwrt-mifi-ar71xx-generic-gl-mifi-squashfs-sysupgrade.bin*

For other firmwares, the compiled firmware file is in **bin/<device_name>/**

## Docker build environment

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

## Adding custom packages to your image

**1.** To create the required directory structure, you must run the Imagebuilder at least once using **./gl_image -p <image_name>**.

**2.** Place your custom package in the packages folder of the Imagebuilder target. For the **Mifi** the folder is:

```bash
imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/packages/
```

**3.** Modify the **customize.json** file, adding the name of your package to the end of the "packages" property of your target:

"**mifi**":<br/>
{<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"profile": "gl-mifi",<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"version": "3.027",<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"imagebuilder": "3.1/openwrt-imagebuilder-ar71xx-generic_3.1",<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"packages": "gl-base-files-ar $basic $vpn $storage $glinet $usb -wpa-cli -kmod-rt2800-usb **mylibndpi**"<br/>
}

**4.** Re-run the Imagebuilder using the custom config file: **./gl_image -c customize.json -p <image_name>**

**5.** You custom package will be included in the compiled firmware.

## Including / changing files in your image

**1.** To create the required directory structure, you must run the Imagebuilder at least once using **./gl_image -p <image_name>**.

**2.** If you want to for example add files to the /www folder of the firmware, or change files in the /etc folder, you will need to specify a root files folder when creating the image.  For the Mifi, we will create a new folder named "files" inside the following folder:

```bash
imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/packages/
```
So we end up with:

```bash
imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files/
```

**3.** The folder we created will serve as a custom root for the image, where any files we put inside will be copied to the final image, replacing any existing files. If we for example wanted to add a new file called **/usr/myfile** to the final image, we would place it in our custom root as bellow:

> imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files/**usr/myfile**

If we for example wanted to replace a config file in the firmware, such as the firewall config **/etc/config/firewall** we would copy the default file, change it, and place it in our custom root:

> imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files/**etc/config/firewall**

⚠️ Notice that the GL firmware has a lot of scripts, many that run on first boot of the firmware. Those scripts might modify files and cause confusion. If you notice that one of your updated files is being replaced, you will need to find which script is modifying your file. You could also add your own script that runs after a certain time, replacing your files on first boot. This is beyond the scope of this document, but it's possible to do.

**4.** Modify the **customize.json** file, adding the "files" property to your target, pointing to our custom root folder:

"**mifi**":<br/>
{<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"profile": "gl-mifi",<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"version": "3.027",<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"imagebuilder": "3.1/openwrt-imagebuilder-ar71xx-generic_3.1",<br/>
&nbsp;&nbsp;&nbsp;&nbsp;"packages": "gl-base-files-ar $basic $vpn $storage $glinet $usb -wpa-cli -kmod-rt2800-usb",<br/>
&nbsp;&nbsp;&nbsp;&nbsp;**"files": "imagebuilder/3.1/openwrt-imagebuilder-ar71xx-generic_3.1/files"**,<br/>
}

**5.** Re-run the Imagebuilder using the custom config file: **./gl_image -c customize.json -p <image_name>**

**6.** You file changes will be included in the compiled firmware.


## Compiling a stock GL-iNet firmware

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
