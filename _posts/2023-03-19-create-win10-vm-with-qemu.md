---
title: 使用 QEMU 创建 Windows 10 虚拟机
category: VM
tags:
- QEMU
- Windows
---

> 注意：本文仅作经验分享，使用命令前请确保你知晓它的作用，如需深入了解请查看文末参考链接。

以前如果有虚拟机的需求我只会想到 VMware 和 VirtualBox，VMware 听说很好用但需要付费；VirtualBox 是开源的但性能不佳，之前使用的时候还碰到过奇怪的 BUG。最近因为工作的原因接触到了 QEMU，它是一款通用的开源计算机模拟器和虚拟机，据其[主页](https://wiki.qemu.org/Main_Page)所说，「通过使用动态翻译，它实现了很不错的性能」。QEMU 的缺点是只有命令行界面而且选项多而复杂（虽然可以使用第三方 GUI 工具），但我使用 QEMU CLI 的感觉反而比 VirtualBox GUI 更舒服，可能是因为 VirutalBox 的设置也需要学习。

本着学习 QEMU 的想法，我最后选择使用 QEMU 创建 Windows 10 虚拟机，实际使用下来体验也很不错，用作个人使用完全可以替代 VMware 或 VirtualBox，只是需要研究一下它的命令行选项。不过 QEMU 貌似不支持保存虚拟机状态，也即 VirtualBox 中的「休眠」功能，每次都需要重启虚拟机。
顺带一提，QEMU 不仅能创建 x86 的虚拟机，也能创建其他架构的虚拟机，还能通过动态翻译直接执行其他架构的二进制程序，它的作者 [Fabrice Bellard](https://zh.wikipedia.org/zh-cn/%E6%B3%95%E5%B8%83%E9%87%8C%E6%96%AF%C2%B7%E8%B4%9D%E6%8B%89) 同时也是另一个知名开源软件 FFmpeg 的作者。总之 QEMU 是一款很值得学习的虚拟化工具。

## 1. 准备

### 1.1 安装 QEMU

Arch Linux：

```bash
sudo pacman -S qemu-full
```

### 1.2 下载 Windows 10 镜像

可以到[微软官网](https://www.microsoft.com/zh-cn/software-download/)下载，但下载速度比较慢，推荐使用 [MSDN](https://msdn.itellyou.cn/)。理论上各个版本都能使用，我选择的是 LTSC 64 位版，相对于家庭版/专业版会更加简洁，不会预装 Office 全家桶。

## 2. 安装

### 2.1 制作硬盘镜像

微软官方提供的系统基本要求是：32 位版本至少需要 16 GB 硬盘空间，64 位版本至少需要 32 GB 硬盘空间。但我测试下来 16 GB 根本不够用，即使是没有安装任何其他软件的 32 位版本都使用了近 14 GB 的空间。
使用 qcow2 格式只会给镜像文件分配虚拟机使用的空间，可以大大节省空间。另外因为 Windows 的磁盘管理太垃圾（会自动创建恢复分区，阻止了扩展 C 盘），所以最好一开始就确定镜像的大小。
因为我只打算用 Windows 看看企业微信、下下野狐围棋（这两个软件都没有 Linux 版本，而且使用 Wine 运行有点问题），所以就直接用了官方给出的最低要求——32 GB，装了上述软件后只剩下大概 10 GB 的空间。

```bash
qemu-img create -f qcow2 win10.cow 32G
```

查看镜像文件信息：

```bash
qemu-img info win10.cow
```

### 2.2 安装 Windows 10

```bash
qemu-system-x86_64 -m 4G -accel kvm -cpu host -cdrom SW_DVD9_WIN_ENT_LTSC_2021_64BIT_ChnSimp_MLF_X22-84402.ISO -boot menu=on -drive file=win10-ltsc.cow,format=qcow2
```

顺利的话就可以开始无脑下一步了。

### 2.3 启动 Windows 10

安装完成后我们就不需要 ISO 文件了，启动虚拟机的命令行选项和安装几乎一致，只是不需要 `-cdrom` 选项。我在第一次启动的时候碰到了黑屏的问题，但关闭后重新启动就成功了，不确定是不是第一次启动都会这样。

下面的命令还加上了一些提升性能和设备相关的选项，具体可查看文末参考链接。

```bash
qemu-system-x86_64 -m 4G -accel kvm \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -smp 4 -drive file=win10.cow,format=qcow2 \
  -usb -device usb-tablet \
  -audiodev pa,id=snd0 -device ich9-intel-hda -device hda-output,audiodev=snd0
```

### 2.4 配置 Windows 10

关闭自动更新可以参考 [3 Best Ways to Disable Automatic Update on Windows 10](https://www.cleverfiles.com/howto/disable-update-windows-10.html)。

## 3. 管理

### 3.1 使用 make 启动

```makefile
.PHONY: run

run:
	qemu-system-x86_64 -m 4G -accel kvm \
		-cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
		-smp 4 -drive file=win10.cow,format=qcow2 \
		-usb -device usb-tablet \
		-audiodev pa,id=snd0 -device ich9-intel-hda -device hda-output,audiodev=snd0
```

### 3.2 添加桌面启动项

使用命令行启动的话总是得先打开终端，有点不太方便，幸好我们也可以添加桌面启动项，这样就可以在应用菜单里直接启动虚拟机了。

存放路径：`$HOME/.local/share/applications/win10.desktop`。

```conf
[Desktop Entry]

# The type as listed above
Type=Application

# The version of the desktop entry specification to which this file complies
Version=1.0

# The name of the application
Name=Windows 10

# A comment which can/will be used as a tooltip
Comment=Windows 10 virtual machine by QEMU

# The path to the folder in which the executable is run
Path=/path/to/Makefile

# The executable of the application, possibly with arguments.
Exec=make

# The name of the icon that will be used to display this entry
Icon=win10

# Describes whether this application needs to be run in a terminal or not
Terminal=false

# Describes the categories in which this entry should be shown
Categories=System;Utility;
```

## 参考链接

- [QEMU - ArchWiki](https://wiki.archlinux.org/title/QEMU)
- [Desktop entries - ArchWiki](https://wiki.archlinux.org/title/Desktop_entries)
