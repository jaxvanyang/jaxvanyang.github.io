---
title: 配置 OpenSSH
date: '2020-11-30 04:00:00 +0800'
modified_date: '2022-04-03'
tags:
- 笔记
- SSH
---

## 启用 OpenSSH 服务（用于远程连接到本机）
___

1. 安装 `openssh`  

   ```bash
   sudo apt update
   sudo apt install openssh-server
   ```

2. 查看运行状态  

   安装后 `openssh` 会自动启动并开机自启，你可以输入以下命令查看状态：
   
   ```bash
   systemctl status ssh
   
   # 或者
   systemctl status sshd
   ```  

3. 设置防火墙以允许 SSH 连接

   ```bash
   sudo ufw allow ssh
   ```

<br>

## 远程连接到本机（没有公网地址的话需要在同一个局域网内）
___

1. 通过以下命令查看本机 IP 地址：

   ```bash
   ip a
   ```

2. 连接 SSH 服务器：

   ```bash
   ssh <username>@<ip_address>
   ```

3. 根据提示输入密码

<br>

## 禁用 or 启用 OpenSSH 服务
___

1. 禁用：

   ```bash
   sudo systemctl disable --now ssh
   ```

2. 启用：

   ```bash
   sudo systemctl enable --now ssh
   ```

<br>

## 配置 SSH 的密钥

> 以下内容大部分翻译自 [How to Setup Passwordless SSH Login](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/?spm=a2c6h.12873639.0.0.7539785dKjw1jo)

*`Secure Shell（SSH，安全外壳）` 是一种用于连接服务器和客户端的加密网络协议，并且支持好几种验证机制。最常用的两种验证方式分别是基于密码和基于密钥的验证机制。*

使用密钥验证不需要每次连接都输入密码，而且安全性更高（只要确保没人可以查看你的密钥），所以推荐开启 SSH 服务后就关闭密码验证，只使用密钥验证。

具体步骤：

1. 检查已有的 SSH 密钥对，如果有，则可以使用这些密钥，或者备份并删除它们。

   ```bash
   ls -al ~/.ssh/id_*.pub
   ```

2. 生成新的 SSH 密钥对：

   ```bash
   # 推荐
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
   
   或者：
   
   ```bash
   # 如果 OpenSSH 版本较老不支持上面那条就用这一条
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

3. 确保真的生成了新的密钥对：

   ```bash
   ls ~/.ssh/id_*
   ```

4. 复制公钥到服务器上：

   ```bash
   ssh-copy-id remote_username@server_ip_address
   ```
   
   如果上述命令用不了，可以使用以下命令：
   
   ```bash
   cat ~/.ssh/id_rsa.pub | ssh remote_username@server_ip_address "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
   ```

5. 使用 SSH 密钥登录服务器：

   ```bash
   ssh remote_username@server_ip_address
   ```

   如果配置正确，你现在不用输密码就可以登录到服务器上了。

## 关闭 SSH 的密码验证

1. 使用超级用户（sudo）或 root 登录到服务器：

   ```bash
   ssh sudo_user@server_ip_address
   ```

 或者先用普通用户登录到服务器上再切换到超级用户。

2. 打开 SSH 的配置文件 `/etc/ssh/sshd_config`，找到下面的配置项并修改得和下面一样：

   ```text
   /etc/ssh/sshd_config
   PasswordAuthentication no
   ChallengeResponseAuthentication no
   UsePAM no
   ```

3. 保存文件后重启 SSH 服务

   - Ubuntu 或 Debian 服务器：

     ```bash
     sudo systemctl restart ssh
     ```

   - CentOS、Fedora 或 Arch Linux 服务器：

     ```bash
     sudo systemctl restart sshd
     ```

## 如果你想要了解密钥对算法和它的安全性
___

这里有几个不错的科普：

- [想知道比特币（和其他加密货币）的原理吗？](https://www.bilibili.com/video/BV11x411i72w/?spm_id_from=333.788.videocard.0)  

- [256位加密有多安全？](https://www.bilibili.com/video/BV1yx411i7BX)


## 参考
___

- [如何在 Ubuntu 20.04 启用 SSH](https://developer.aliyun.com/article/763896)

- [How to Setup Passwordless SSH Login](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/?spm=a2c6h.12873639.0.0.7539785dKjw1jo)

- [Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/cn/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)