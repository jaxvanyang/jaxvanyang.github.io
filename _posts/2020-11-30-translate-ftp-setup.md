---
title: '[译]如何在 Ubuntu 20.04 上配置 FTP 服务器'
date: '2020-11-30 05:00:00 +0800'
modified_date: '2022-04-05'
tags:
- 笔记
- FTP
---

> 本文翻译自 [How to setup FTP server on Ubuntu 20.04 Focal Fossa Linux](https://linuxconfig.org/how-to-setup-ftp-server-on-ubuntu-20-04-focal-fossa-linux)，原作者是 [Korbin Brown](https://linuxconfig.org/author/korbinpublisher)。

在本教程中，我们将会向你展示在 [Ubuntu 20.04](https://linuxconfig.org/ubuntu-20-04-guide) Focal Fossa 上如何用 `VSFTPD` 来配置 FTP 服务器。

`VSFTPD` 是配置 FTP 服务器的流行选择，而且它也是一些 [Linux 发行版](https://linuxconfig.org/how-to-choose-the-best-linux-distro) 的默认 FTP 工具。
跟着我们一起来看看如何安装并且配置运行你的 FTP 服务器吧。

在本篇教程中你将学会：

- [如何安装 `VSFTPD`](#安装-vsftpd)

- [如何配置 `VSFTPD`](#配置-vsftpd-服务器)

- [如何配置一个 FTP 用户账号](#创建一个-ftp-用户)

- [如何通过命令行连接到 FTP 服务器](#通过-cli-连接-ftp-服务器)

- [如何通过 GUI 连接到 FTP 服务器](#通过-gui-连接-ftp-服务器)


![How to setup FTP server on Ubuntu 20.04 Focal Fossa Linux]({{ "/assets/images/03-how-to-setup-ftp-server-on-ubuntu-20-04-focal-fossa-linux.webp" | absolute_url }})

## 前提条件

| 分类 | 要求、基础知识或使用的软件版本 |
| --- | --- |
| 系统 | 安装或[升级到 Ubuntu 20.04 Focal Fossa](https://linuxconfig.org/how-to-upgrade-ubuntu-to-20-04-lts-focal-fossa)
| 软件 | VSFTPD |
| 其它 | 可登录 root 用户或可以使用 `sudo` 命令 |
| 基础知识 | 会执行给出的 [Linux 命令](https://linuxconfig.org/linux-commands) |

## 安装 `VSFTPD`

首先，在[终端](https://linuxconfig.org/shortcuts-to-access-terminal-on-ubuntu-20-04-focal-fossa)中输入以下命令安装 `VSFTPD`：

```shell
$ sudo apt-get install vsftpd
```

## 配置 `VSFTPD` 服务器

1. 备份原始的配置文件始终是最佳实践，以防稍后出现问题。让我们通过重命名来备份默认的配置文件：

	 ```shell
	 $ sudo mv /etc/vsftpd.conf /etc/vsftpd.conf_orig
	 ```

2. 用 nano 或者其它你喜欢的文本编辑器创建一个新的 `VSFTPD` 配置文件：

	 ```shell
	 $ sudo nano /etc/vsftpd.conf
	 ```

3. 将下面的基础配置复制到你的配置文件。这对于一个基本的 FTP 服务器来说是足够的，并且在你确定能正常工作后还可以根据你的需要进行修改。

	 ```
	 listen=NO
	 listen_ipv6=YES
	 anonymous_enable=NO
	 local_enable=YES
	 write_enable=YES
	 local_umask=022
	 dirmessage_enable=YES
	 use_localtime=YES
	 xferlog_enable=YES
	 connect_from_port_20=YES
	 chroot_local_user=YES
	 secure_chroot_dir=/var/run/vsftpd/empty
	 pam_service_name=vsftpd
	 rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
	 rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
	 ssl_enable=NO
	 pasv_enable=Yes
	 pasv_min_port=10000
	 pasv_max_port=10100
	 allow_writeable_chroot=YES
	 ```

	 将上面的配置复制到你新建的 `/etc/vsftpd.conf` 文件中，然后保存并关闭文件。

	 ![VSFTPD configuration file]({{ "/assets/images/01-how-to-setup-ftp-server-on-ubuntu-20-04-focal-fossa-linux.webp" | absolute_url }})

4. Ubuntu 内置的防火墙默认屏蔽 FTP 流量，但下面的命令可以在 UFW（即内置的防火墙软件）中创建一个允许这些流量的规则：

	 ```shell
	 $ sudo ufw allow from any to any port 20,21,10000:10100 proto tcp
	 ```

5. 在保存配置文件和更新防火墙规则之后，重启 `VSFTPD` 以应用这些更改：

	 ```shell
	 $ sudo systemctl restart vsftpd
	 ```

## 创建一个 FTP 用户

我们的 FTP 服务器已经准备好了接受传入连接，所以现在是时候创建一个用来连接 FTP 服务的新用户账号了。

1. 用第一条命令创建一个新帐号 `ftpuser`，然后用第二条命令为其设置密码：

	 ```shell
	 $ sudo useradd -m ftpuser
	 $ sudo passwd ftpuser
	 New password: 
	 Retype new password: 
	 passwd: password updated successfully
	 ```

2. 为了验证一切工作正常，你需要在 `ftpuser` 的家目录下存放至少一个文件。当我们在后面登录 FTP 时应该是可见的。

	 ```shell
	 $ sudo bash -c "echo FTP TESTING > /home/ftpuser/FTP-TEST"
	 ```

> NOTE: FTP 并不是一个加密的协议，它之应该被用于在你的本地网络上访问和传输文件。如果你打算接受来自互联网的流量，你最好配置一个 SFTP 服务器以获得额外的安全性。

## 通过 CLI 连接 FTP 服务器

1. 你现在应该可以通过 IP 地址或者主机名连接到你的 FTP 服务器了。要通过[命令行](https://linuxconfig.org/linux-command-line-tutorial)连接并验证一切正常，你需要[打开一个终端](https://linuxconfig.org/shortcuts-to-access-terminal-on-ubuntu-20-04-focal-fossa)然后使用 Ubuntu 的 `ftp` 命令连接到你的环回地址（127.0.0.1）。

	 ```shell
	 $ ftp 127.0.0.1
	 Connected to 127.0.0.1.
	 220 (vsFTPd 3.0.3)
	 Name (127.0.0.1:user1): ftpuser
	 331 Please specify the password.
	 Password:
	 230 Login successful.
	 Remote system type is UNIX.
	 Using binary mode to transfer files.
	 ftp> ls
	 200 PORT command successful. Consider using PASV.
	 150 Here comes the directory listing.
	 -rw-r--r--    1 0        0              12 Mar 04 22:41 FTP-TEST
	 226 Directory send OK.
	 ftp> 
	 ```

	 你的输出应该和上面的差不多，它表示登录成功而且有一条 `ls` 命令列出了我们之前创建的测试文件。

## 通过 GUI 连接 FTP 服务器

如果你喜欢，你也可以通过 GUI 连接到你的 FTP 服务器。FTP 客户端有很多选择，但 Nautilus 文件管理器是 Ubuntu 默认安装的一个可行选择。下面介绍了如何用它连接到你的 FTP 服务器：

1. 从应用程序菜单打开 Nautilus 文件管理器。

2. 点击“其它位置（Other Locations）”，然后在窗口底部的“连接到服务器（Connect to server）”输入框中输入 `ftp://127.0.0.1` 并点击“连接（connect）”。

	 ![Connect to FTP server with Nautilus]({{ "/assets/images/02-how-to-setup-ftp-server-on-ubuntu-20-04-focal-fossa-linux.webp" | absolute_url }})

3. 输入我们之前设置的 FTP 账号信息，然后点击“连接（connect）”。

	 ![Enter FTP credentials]({{ "/assets/images/03-how-to-setup-ftp-server-on-ubuntu-20-04-focal-fossa-linux.webp" | absolute_url }})

4. 在成功连接后，你就会看到你之前创建的测试文件。

	 ![Successful connection to FTP server]({{ "/assets/images/04-how-to-setup-ftp-server-on-ubuntu-20-04-focal-fossa-linux.webp" | absolute_url }})

## 总结

在本文中，我们了解如何使用 `VSFTPD` 在 Ubuntu 20.04 Focal Fossa 上创建 FTP 服务器。我们还介绍了如何使用命令行和 Ubuntu GUI 连接到 FTP 服务器。

按照本指南，本地网络上的计算机可以通过命令行或其首选 FTP 客户端访问您的系统来存储和检索文件。

## 相关 Linux 教程

- [Things to install on Ubuntu 20.04](https://linuxconfig.org/things-to-install-on-ubuntu-20-04)

- [Things to do after installing Ubuntu 20.04 Focal Fossa Linux](https://linuxconfig.org/things-to-do-after-installing-ubuntu-20-04-focal-fossa-linux)

- [How to setup FTP/SFTP server and client on AlmaLinux](https://linuxconfig.org/how-to-setup-ftp-sftp-server-and-client-on-almalinux)

- [How to setup vsftpd on Debian](https://linuxconfig.org/how-to-setup-vsftpd-on-debian)

- [Ubuntu 20.04 Tricks and Things you Might not Know](https://linuxconfig.org/ubuntu-20-04-tricks-and-things-you-might-not-know)

- [Ubuntu 20.04 Guide](https://linuxconfig.org/ubuntu-20-04-guide)

- [FTP client list and installation on Ubuntu 20.04 Linux…](https://linuxconfig.org/ftp-client-list-and-installation-on-ubuntu-20-04-linux-desktop-server)

- [Install ARCH Linux on ThinkPad X1 Carbon Gen 7 with…](https://linuxconfig.org/install-arch-linux-on-thinkpad-x1-carbon-gen-7-with-encrypted-filesystem-and-uefi)

- [Linux Download](https://linuxconfig.org/linux-download)

- [Mint 20: Better Than Ubuntu and Microsoft Windows?](https://linuxconfig.org/mint-20-better-than-ubuntu-and-microsoft-windows)