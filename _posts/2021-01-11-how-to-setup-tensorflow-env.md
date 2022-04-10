---
title: 开源教程 | 快速配置 TensorFlow 本地开发环境（Docker + Jupyter + VS Code）
modified_date: 2022-04-05
excerpt: <blockquote><p>本文主要参考自 <a href="https://tensorflow.google.cn/install">TensorFlow 官方安装教程</a>，选择了 Docker 容器作为开发环境，并且可以用 Jupyter 和 VS Code 开发。</p></blockquote>
---

![TensorFlow logo]({{ '/assets/images/tensorflow-logo.png' | absolute_url }})  

> 本文主要参考自 [TensorFlow 官方安装教程](https://tensorflow.google.cn/install)，选择了 Docker 容器作为开发环境，并且可以用 Jupyter 和 VS Code 开发。  

安装 TensorFlow 有很多种方法，最方便快捷的是使用 `pip` 安装，这在官网上有十分简单的说明，我就不在这里重复了，这篇文章主要是带你看看安装 TensorFlow 容器，和如何解决可能会碰到的一些问题，让我们开始吧！  

因为我使用的是 Ubuntu 20.04，所以在配置过程中我都是用 Ubuntu 演示的，如果你用的也是 Ubuntu，那就太好了，如果不是请仅作参考。  

## 0. 关于开源教程

这是我写的第一篇开源教程，开源的意思就是任何人都可以引用、编辑，网上的各种教程五花八门，但很多都不会随时间更新，这就会造成一些教程一开始是可行的，但是过了一段时间就会遇到一些错误，所以我建议大家在学习的时候多看官方教程，因为官方的教程一般都会及时更新并且是最佳实践。  

这篇教程也不适合所有人，很多细节我并没有研究得很透彻，主要是给那些新手快速配置环境看的，但我也希望这篇文章足够可靠，如果你有任何问题和建议都可以在评论区提出，有能力的也可以到我的 [GitHub 仓库](https://github.com/JaxVanYang/jaxvanyang.github.io/blob/main/_posts/2021-01-11-how-to-setup-tensorflow-env.md)  提交 PR。  

## 1. 安装 Docker

我们先来看看 [Docker 官方安装教程](https://docs.docker.com/get-docker/) 是如何介绍 Docker 的：  

![Get Docker]({{ '/assets/images/get-docker.png' | absolute_url }})  

翻译：

> Docker 是一个用于开发，发布和运行应用程序的开放平台。
> Docker 使您能够将应用程序与基础架构分开，从而可以快速交付软件。
> 借助 Docker，您可以以与管理应用程序相同的方式来管理基础架构。
> 通过利用 Docker 的方法进行快速的运输，测试和部署，您可以大大减少编写代码和在生产环境中运行代码之间的延迟。

简单来说，Docker 可以让我们在多种环境中开发，并且易于切换，不用每次都大费周章地配置环境。因为我用的是 Ubuntu 20.04，所以我就选择 Linux 的 Docker 安装作为演示，你可以根据自己的情况在官网选择对应的安装方式。  

### 1. 卸载旧版本（如果没有安装过 Docker，可以忽略此步骤）

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

### 2. 安装 Docker

安装 Docker 也有好几种方法，这是它们的区别：<https://docs.docker.com/engine/install/ubuntu/#installation-methods>，为了避免麻烦，本文只介绍如何使用仓库来安装。  

1. 更新 `apt` 包的索引并安装一些可以让 `apt` 使用 HTTPS 连接仓库的包：  

   ```bash
   sudo apt-get update

   sudo apt-get install \
   apt-transport-https \
   ca-certificates \
   curl \
   gnupg-agent \
   software-properties-common
   ```

2. 添加 Docker 的官方 GPG 公钥：  

   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```

   测试是否添加成功：  

   ```bash
   sudo apt-key fingerprint 0EBFCD88
   ```

   如果出现类似以下信息，那就是成功了：  

   ```text
   pub     rsa4096 2017-02-22 [SCEA]
         9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
   uid           [ 未知 ] Docker Release (CE deb) <docker@docker.com>
   sub     rsa4096 2017-02-22 [S]
   ```

3. 设置 **stable**（稳定版）仓库：  

   ```bash
   sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   ```

4. 安装最新版本的 Docker Engine：  

   ```bash
   sudo apt update
   sudo apt install docker-ce docker-ce-cli containerd.io
   ```

   测试是否安装成功：

   ```bash
   sudo docker run hello-world
   ```

   第一次运行需要下载，等待一段时间即可，以下是成功信息：  

   ```bash
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
   ...
   ```

## 3. 让你的 Docker 更好用

由于 Docker 官方的镜像源受到魔法的影响，直接连接速度感人，所以我们使用 Docker 的第一步就是换源。这里有几个免费的加速器：  

1. Docker官方的中国镜像加速器：https://registry.docker-cn.com  不用注册

2. 中科大的镜像加速器：https://docker.mirrors.ustc.edu.cn/   不用注册

3. 阿里云的镜像加速器：登录阿里云的容器hub服务，镜像加速器那一栏里会为你独立分配一个加速器地址 要注册

4. DaoCloud的镜像加速器：登录DaoCloud的加速器获取脚本，该脚本可以将加速器添加到守护进程的配置文件中 要注册

这里使用 Docker 官方的中国镜像加速器作为示范，直接输入以下命令即可：  

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

使用阿里云镜像加速器可以参考这篇文章：[docker下载镜像太慢的解决方案](https://blog.csdn.net/weixin_43569697/article/details/89279225)  

因为 Docker 的使用可能会影响到系统安全，所以大部分的 `docker` 命令都要使用 `sudo` 才能运行，如果你不想每次都加一个 `sudo` 的话，可以使用以下命令解决：  

1. 添加 `docker` 组：  

   ```bash
   sudo groupadd docker
   ```

2. 添加当前用户到 `docker` 组：  

   ```bash
   sudo usermod -aG docker $USER
   ```

用户组的更改需要重新登录才能刷新，重新登录后可以使用 `docker run hello-world` 测试是否成功，建议不要在服务器上使用这个方法。  

## 4. 下载 TensorFlow Docker 映像

| 标记  | 说明  |
|------|------|
| latest    | TensorFlow CPU 二进制映像的最新版本。（默认版本） |
| nightly   | TensorFlow 映像的每夜版（不稳定）。|
| version   | 指定 TensorFlow 二进制映像的版本，例如：2.1.0 |
| devel     | TensorFlow master 开发环境的每夜版。包含 TensorFlow 源代码。|
| custom-op | 用于开发 TF 自定义操作的特殊实验性映像。|

如需了解更多信息，请点击以下链接：<https://github.com/tensorflow/custom-op>

每个基本标记都有会添加或更改功能的变体：  

| 标记变体  | 说明 |
|---------|------|
| tag-gpu   | 支持 GPU 的指定标记版本。（详见下文）|
| tag-jupyter   | 针对 Jupyter 的指定标记版本（包含 TensorFlow 教程笔记本）|

您可以一次使用多个变体。例如，以下命令会将 TensorFlow 版本映像下载到计算机上：

```bash
docker pull tensorflow/tensorflow                     # latest stable release
docker pull tensorflow/tensorflow:devel-gpu           # nightly dev release w/ GPU support
docker pull tensorflow/tensorflow:latest-gpu-jupyter  # latest release w/ GPU support and Jupyter
```

以上内容摘自 [TensorFlow 官网安装教程]，我使用的是 `docker pull tensorflow/tensorflow:latest-gpu-jupyter`，注意一定要换源后再安装，不然你就可以先睡一觉明天再起来看了。  

安装成功后你就可以在 Docker 容器中开发了，例如在仅支持 CPU 的映像中启动 `bash` 会话：  

```bash
docker run -it tensorflow/tensorflow bash
```

不过这样还不够方便，我们可以使用 Jupyter 笔记本来开发：  

```bash
docker run -it -p 8888:8888 tensorflow/tensorflow:latest-jupyter
```

然后按照终端输出的提示在主机网络浏览器中打开以下网址：`http://127.0.0.1:8888/?token=...`  

## 5. 使用 GPU 支持

Docker 是在 GPU 上运行 TensorFlow 的最简单的方法，因为主机只需安装 NVIDIA® 驱动程序，而不必安装 NVIDIA® CUDA® 工具包。  

1. 使用最新的驱动程序  

   如果你使用的也是 Ubuntu 20.04，那么恭喜你，切换到最新的驱动十分容易，只需要打开自带的软件“软件和更新”，然后选择最新的驱动即可，如图所示：  
   ![NVIDIA 驱动]({{ '/assets/images/nvidia-drive.png' | absolute_url }})  
   
   如果你使用的不是 20 版本的 Ubuntu，或者使用的是其他发行版，那么可以参考 [How do I install the NVIDIA driver?](https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#how-do-i-install-the-nvidia-driver)  

2. 检查 GPU 是否可用：  

   ```bash
   lspci | grep -i nvidia
   ```

3. 安装 NVIDIA 容器工具包：  

   > 请通过 docker -v 检查 Docker 版本。对于 19.03 之前的版本，您需要使用 nvidia-docker2 和 --runtime=nvidia 标记；对于 19.03 及之后的版本，您将需要使用 nvidia-container-toolkit 软件包和 --gpus all 标记。  

   1. 配置 `stable` 仓库和 GPG 公钥：  

      ```bash
      distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
      && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
      ```

   2. 安装 `nvidia-container-toolkit`：  

      ```bash
      sudo apt update
      sudo apt install -y nvidia-container-toolkit
      ```

   3. 重启 Docker：  

      ```bash
      sudo systemctl restart docker
      ```

   4. 测试是否安装成功：  

      ```bash
      sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
      ```

      示例输出：  

      ```bash
      Mon Jan 11 05:33:48 2021       
      +-----------------------------------------------------------------------------+
      | NVIDIA-SMI 460.32.03    Driver Version: 460.32.03    CUDA Version: 11.2     |
      |-------------------------------+----------------------+----------------------+
      | GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
      | Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
      |                               |                      |               MIG M. |
      |===============================+======================+======================|
      |   0  GeForce GTX 950M    Off  | 00000000:01:00.0 Off |                  N/A |
      | N/A   50C    P0    N/A /  N/A |    397MiB /  4046MiB |      0%      Default |
      |                               |                      |                  N/A |
      +-------------------------------+----------------------+----------------------+
                                                                                 
      +-----------------------------------------------------------------------------+
      | Processes:                                                                  |
      |  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
      |        ID   ID                                                   Usage      |
      |=============================================================================|
      +-----------------------------------------------------------------------------+
      ```

   其他系统请参考 <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker>  

4. 验证安装效果：  

   ```bash
   docker run --gpus all --rm nvidia/cuda nvidia-smi
   ```

5. 使用支持 GPU 的映像在容器中启动 `bash`：  

   ```bash
   docker run --gpus all -it tensorflow/tensorflow:latest-gpu bash
   ```

## 6. 使用 VS Code 编辑 Jupyter 笔记本

我们可以使用仅支持 CPU 的 Jupyter 服务器：  

```bash
docker run -it -p 8888:8888 tensorflow/tensorflow:latest-jupyter
```

也可以使用支持 GPU 的 Jupyter 服务器：  

```bash
docker run -it -p 8888:8888 tensorflow/tensorflow:latest-gpu-jupyter
```

我比较喜欢使用支持 GPU 的，如果不想每次输入这么长的命令可以使用 `alias`：  

```bash
vim ~/.bashrc
# 将以下内容加入 .bashrc
alias webj='docker run -it -p 8888:8888 tensorflow/tensorflow:latest-gpu-jupyter'
# 更新 alias
source ~/.bashrc
```

然后就可以使用 `webj` 来达到相同的作用了：  

```bash
webj
# 示例输出
[I 05:46:26.894 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
jupyter_http_over_ws extension initialized. Listening on /http_over_websocket
[I 05:46:27.805 NotebookApp] Serving notebooks from local directory: /tf
[I 05:46:27.806 NotebookApp] Jupyter Notebook 6.1.5 is running at:
[I 05:46:27.806 NotebookApp] http://7ce58fd012c4:8888/?token=dc6015d8174f76ba8842f65df0c731dd3c802dc7ec7818e1
[I 05:46:27.806 NotebookApp]  or http://127.0.0.1:8888/?token=dc6015d8174f76ba8842f65df0c731dd3c802dc7ec7818e1
[I 05:46:27.806 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 05:46:27.817 NotebookApp] 
    
    To access the notebook, open this file in a browser:
        file:///root/.local/share/jupyter/runtime/nbserver-1-open.html
    Or copy and paste one of these URLs:
        http://7ce58fd012c4:8888/?token=dc6015d8174f76ba8842f65df0c731dd3c802dc7ec7818e1
     or http://127.0.0.1:8888/?token=dc6015d8174f76ba8842f65df0c731dd3c802dc7ec7818e1
```

在终端按住 `Ctrl` 单击最后一个链接就可以打开 Jupyter 笔记本的网站了。  

另外我们也可以让 VS Code 使用这个支持 GPU 的服务器，首先我们要在 VS Code 中新建一个 Jupyter 笔记本，然后打开，在右上角的 Jupyter Server 中选择 `Existing` 然后填入上述链接即可：  

![VS Code Jupyter 笔记本]({{ '/assets/images/vscode-jupyter.png' | absolute_url }})  

![VS Code Jupyter 更换服务器]({{ '/assets/images/vscode-jupyter-change-server.png' | absolute_url }})  


## 参考

- [配置 Docker 镜像加速器](https://developer.aliyun.com/article/606808)  

- [TensorFlow 官方安装教程](https://tensorflow.google.cn/install)  