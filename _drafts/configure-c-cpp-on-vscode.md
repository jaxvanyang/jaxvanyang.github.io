---
title: 「持续更新」如何在 VS Code 上配置 C/C++ 开发环境
author: Jax Young
---

## 1. 准备工作
1. 安装 [VS Code](https://code.visualstudio.com/download)  
    这个就不用我多说了吧  

2. 为 VS Code 安装 [C++ 扩展](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)  
    ![C++ 扩展](../assets/images/cpp-extension.png)  
    推荐安装 VS Code 的[中文插件](TODO)

3. 安装 GCC
    1. Windows 系统  

    2. Linux 系统  

<br>

## 2. 添加配置文件
在继续之前，我们先来看看都有哪些配置文件：  
- `tasks.json`（用于编译器的设置）  
- `launch.json`（用于 debugger 的设置）  
- `c_cpp_propetties.json`（用于编译器路径和 IntelliSense 的设置）  

TODO: 根据语言学习仓库补充一下  
<br>

## 3. 重用配置文件
直接复制到新的工作目录就行，但是要记得根据实际情况做一些修改  