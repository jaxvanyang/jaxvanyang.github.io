---
title: Nginx 安装及基本配置
date: '2020-11-30 02:00:00 +0800'
modified_date: '2022-04-03'
tags:
- 笔记
- Nginx
- 环境配置
---

> Note：看看就好

> 默认只有 root 用户才能读取 Nginx 配置文件，并且不能运行 Apache 或者其他处理进程在 80 端口和 443 端口。  

<br>

## 安装 Nginx

```bash
bash
sudo apt update
sudo apt install nginx
```
<br>

## 启动 Nginx

> Note：你可能需要 root 权限来运行 Nginx 相关的命令

一般 Nginx 在安装完成后会自动启动，如果没有可以手动执行 `nginx` 命令来启动。

也可以通过 `systemctl enable nginx --now` 来启动 Nginx，这样 Nginx 就会在系统重启时自动启动。

## 查看 Nginx 状态

1. 方法一：查看系统进程  

   ```bash
   sudo systemctl status nginx
   ```

2. 方法二：浏览器打开 <http://localhost> 或 <http://YOUR_IP>  

<br>

## Nginx 命令
___

```bash
nginx   # 打开 Nginx

nginx -t    # 测试配置文件是否有语法错误

nginx -s reopen # 重启 Nginx（不推荐）

nginx -s reload # 重新加载 Nginx 配置文件，然后以优雅的方式重启 Nginx（推荐）

nginx -s stop   # 强制停止 Nginx 服务（不推荐）

nginx -s quit   # 优雅地停止 Nginx 服务（推荐）
```

<br>

## 配置防火墙
___

确保防火墙允许流量通过 HTTP（80）和 HTTPS（443）端口。  

```bash
sudo ufw allow 'Nginx Full'
```

想要验证状态，输入：  

```bash
sudo ufw status
```

输出将会像下面这样：  

```bash
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
Nginx Full                 ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
Nginx Full (v6)            ALLOW       Anywhere (v6)
```

<br>

## Nginx 配置文件结构以及最佳实践
___

1. 所有的 Nginx 配置文件都在 `/etc/nginx/` 目录下。  

2. 主要的 Nginx 配置文件是 `/etc/nginx/nginx.conf`。

3. 为每个域名创建一个独立的配置文件，便于维护服务器。你可以按照需要定义任意多的 block 文件。


4. Nginx 服务器配置文件被储存在 `/etc/nginx/sites-available` 目录下。在 `/etc/nginx/sites-enabled` 目录下的配置文件都将被 Nginx 使用。

5. 使用标准的命名方式。例如，如果你的域名是 `mydomain.com`，那么配置文件应该被命名为 `/etc/nginx/sites-available/mydomain.com.conf`


6. 如果你在域名服务器配置块中有可重用的配置段，把这些配置段摘出来，做成一小段可重用的配置。  

7. Nginx 日志文件（`access.log` 和 `error.log`）位于 `/var/log/nginx/` 目录。推荐为每个服务器配置块，配置一个不同的 access 和 error。

8. 你可以将你的网站根目录设置在任何你想要的地方。常用的网站根目录位置有：

   1. `/home/<user_name>/<site_name>`

   2. `/var/www/<site_name>`

   3. `/var/www/html/<site_name>`

   4. `/opt/<site_name>`
    
<br>

## 创建网站
___

初始网页放置在 `var/www/html` 下。你可以把静态页面放在这，或者使用虚拟主机并放在其他位置。  

<br>

## 参考
___

- [如何在 Ubuntu 20.04 上安装 Nginx]<https://cloud.tencent.com/developer/article/1626594>

- <https://nginx.org/>