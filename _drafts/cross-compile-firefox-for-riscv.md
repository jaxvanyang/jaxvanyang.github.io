---
title: 交叉编译 Firefox for RISC-V
category: RISC-V
tags:
- Firefox
- cross compile
---

本文试图记录交叉编译 Firefox 的过程，但交叉编译是一个复杂的过程，而且 Firefox 也是一个拥有众多依赖的庞大项目，所以本文的记录会比较简略，过程也不会适用于所有人。

Host：Arch Linux X86_64, Ubuntu Linux X86_64

Traget: Ubuntu Linux RISC-V

> Note：如果你想要在自己的设备上复现这些操作，一定要注意环境变量和路径。

## 准备工具

- [ ] 编译 RISC-V 64 GCC 工具链：

获取 Firefox 源码可以参考 [^1]。

## 安装依赖

- libX11：

  下载源码包：

	```bash
	wget https://www.x.org/releases/individual/lib/libX11-1.8.tar.xz
	wget https://xorg.freedesktop.org/archive/individual/proto/xproto-7.0.31.tar.gz
	wget https://www.x.org/releases/individual/lib/xtrans-1.4.0.tar.gz
	wget https://xorg.freedesktop.org/archive/individual/proto/kbproto-1.0.7.tar.gz
	wget https://xorg.freedesktop.org/archive/individual/proto/inputproto-2.3.2.tar.gz
	wget https://www.x.org/releases/individual/lib/libxcb-1.15.tar.xz
	wget https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-1.15.tar.xz
	wget https://www.x.org/releases/individual/lib/libXau-1.0.10.tar.xz
	wget https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2022.2.tar.xz
	wget https://www.x.org/releases/individual/lib/libXext-1.3.5.tar.xz
	wget https://www.x.org/releases/individual/lib/libxshmfence-1.3.tar.gz
	```

	解压：

	```bash
	for file in *.tar.*; do tar xvf "$file"; done
	```

	编写一个简单的脚本（env.sh）来管理编译要用到的环境变量：

	```bash
	export PREFIX="$HOME/opt/riscv/sysroot/usr/local"
	export HOST="riscv64-unknown-linux-gnu"
	export LD_LIBRARY_PATH="$PREFIX/lib"
	export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"
	```

	添加一个 cache file（riscv64.cache）来规避 configure 的检查：

	```
	xorg_cv_malloc0_returns_null=yes
	```

	我们的目标是编译 libX11，其它的都是它的依赖，依赖之间可能还有依赖关系，所以我们需要按照依赖关系来编译。另外，有些库可能是不需要的，可以自行取舍，下面是参考的编译顺序：

	```bash
	source env.sh
	
	libs=(
		xproto-7.0.31
		xtrans-1.4.0
		kbproto-1.0.7
		inputproto-2.3.2
		xcb-proto-1.15
		libXau-1.0.10
		libxcb-1.15
		xorgproto-2022.2
		libX11-1.8
		libXext-1.3.5
		libxshmfence-1.3
	)
	
	for lib in "${libs[@]}"; do
		cd "$lib"
		./configure --prefix="$PREFIX" --host="$HOST" --cache-file=../riscv64.cache
		make install -j $(nproc) || break
		cd ..
	done
	```

## References

[^1]: [20220406 - Coelacanthus - 如何给火狐（Firefox）贡献代码- PLCT实验室（内部报告，仅用于关系者交流技术进展）](https://www.bilibili.com/video/BV1fY41177mf)