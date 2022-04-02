---
title:  "vsFTPd 配置"
date: 2020-11-30 05:00:00 +0800
tags: 笔记 vsFTPd
---

> 本文内容不太完善，请酌情阅读。  

## 下载安装
___

```bash
sudo apt-get install vsftpd
```

<br>

## 备份配置文件
___

```bash
sudo mv /etc/vsftpd.conf /etc/vsftpd.conf.bak
```

<br>

## 创建并编辑新的配置文件
___

```bash
sudo vim /etc/vsftpd.conf
```

<br>

## 将以下内容复制到配置文件
___

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

<br>

## 配置防火墙
___

```bash
sudo ufw allow from any to any port 20,21,10000:10100 proto tcp
```

<br>

## 重启 vsFTPd
___

```bash
sudo systemctl restart vsftpd
```

<br>

## 创建 FTP 使用者
___

```bash
sudo useradd -m ftpuser
sudo passwd ftpuser
```

<br>

## 默认目录是 `/home/ftpuser/`
___

可以在里面添加文件，测试是否连接成功

<br>

## 查看 IP 地址
___

```bash
 jax@FX50J  ~  ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp4s0f1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether 9c:5c:8e:1e:7a:a1 brd ff:ff:ff:ff:ff:ff
3: wlp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 80:a5:89:ab:ef:0d brd ff:ff:ff:ff:ff:ff
    inet 192.168.43.212/24 brd 192.168.43.255 scope global dynamic noprefixroute wlp3s0
       valid_lft 2293sec preferred_lft 2293sec
    inet6 2408:84f2:487:71b0:6877:cb26:98b9:dc37/64 scope global temporary dynamic 
       valid_lft 3101sec preferred_lft 3101sec
    inet6 2408:84f2:487:71b0:f8ef:e6a6:1c21:52fb/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 3101sec preferred_lft 3101sec
    inet6 fe80::c935:c088:5f73:7776/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:21:ea:39 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
5: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
    link/ether 52:54:00:21:ea:39 brd ff:ff:ff:ff:ff:ff
 jax@FX50J  ~  ifconfig
enp4s0f1: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        ether 9c:5c:8e:1e:7a:a1  txqueuelen 1000  (以太网)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (本地环回)
        RX packets 3174  bytes 778254 (778.2 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3174  bytes 778254 (778.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:21:ea:39  txqueuelen 1000  (以太网)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.43.212  netmask 255.255.255.0  broadcast 192.168.43.255
        inet6 2408:84f2:487:71b0:6877:cb26:98b9:dc37  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::c935:c088:5f73:7776  prefixlen 64  scopeid 0x20<link>
        inet6 2408:84f2:487:71b0:f8ef:e6a6:1c21:52fb  prefixlen 64  scopeid 0x0<global>
        ether 80:a5:89:ab:ef:0d  txqueuelen 1000  (以太网)
        RX packets 3029  bytes 1987445 (1.9 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3194  bytes 668829 (668.8 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

 jax@FX50J  ~  
```

<br>

## 参考
___

[How to setup FTP server on Ubuntu 20.04 Focal Fossa Linux](https://linuxconfig.org/how-to-setup-ftp-server-on-ubuntu-20-04-focal-fossa-linux)