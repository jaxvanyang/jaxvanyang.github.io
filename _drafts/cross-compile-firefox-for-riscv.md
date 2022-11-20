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

如果不是交叉编译的话，那么依赖可以很容易地安装，直接 `apt build-deps firefox` 就可以了。但如果是交叉编译的话，就需要自己在[编译](#编译)的过程中根据错误信息去找到缺失的库。一般都会提示找不到某个头文件，这个头文件可能就是这个库的名字也可能不是，如果是的话那就很方便了，直接去搜就可以了，推荐到 [^2] 查找。如果和库的名字不符的话，除了 Google，还可以看看自己系统里有没有这个文件，如果有的话，Arch Linux 可以通过 `pacman -Qo /usr/include/xxx.h` 来查看是哪个包提供的，Ubuntu 则可以用 `dpkg -S /usr/include/xxx.h`，再通过包的名字去查就会容易许多。

### libX11

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

### wayland

大致的过程和安装 libX11 类似，所以这里只会对不同的地方加以说明。

下载源码包：

```bash
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/libffi/3.4.2-4/libffi_3.4.2.orig.tar.gz
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/expat/2.4.8-2/expat_2.4.8.orig.tar.gz
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/libxml2/2.9.14+dfsg-1/libxml2_2.9.14+dfsg.orig.tar.xz
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/zlib/1:1.2.11.dfsg-4.1ubuntu1/zlib_1.2.11.dfsg.orig.tar.gz
wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/xz-utils/5.2.5-2.1/xz-utils_5.2.5.orig.tar.xz
wget https://launchpadlibrarian.net/612011262/wayland_1.21.0.orig.tar.gz
```

参考 [libX11](#libx11) 解压 tarball，然后添加 env.sh 并 `source env.sh`。

参考的编译顺序：

```bash
cd libffi-3.4.2 && ./configure --prefix="$PREFIX" --host="$HOST" && make install -j $(nproc) && cd ..
cd libexpat-R_2_4_8/expat && ./buildconf.sh && ./configure --prefix="$PREFIX" --host="$HOST" && make install -j $(nproc) && cd ../..
cd zlib-1.2.11.dfsg && CC=riscv64-unknown-linux-gnu-gcc ./configure --prefix="$PREFIX" && make install -j $(nproc) && cd ..
cd xz-5.2.5 && ./configure --prefix="$PREFIX" --host="$HOST" && make install -j $(nproc) && cd ..
cd libxml2-2.9.14 && ./configure --prefix="$PREFIX" --host="$HOST" --without-python && make install -j $(nproc) && cd ..
```

最后 wayland 的编译需要特别说明一下，因为它用的编译工具是 meson，配置和 make 大不相同，甚至不能直接获取环境变量，~~真是太难用了~~。

wayland 的编译默认会生成文档和测试，但额外的编译目标需要额外的依赖，所以我们先找到配置文件 meson_options.txt 把不需要的目标关掉，配置文件基本上是自解释的，所以不再说明，直接看配置：

```
option('libraries',
	description: 'Compile Wayland libraries',
	type: 'boolean',
	value: true)
option('scanner',
	description: 'Compile wayland-scanner binary',
	type: 'boolean',
	value: true)
option('tests',
	description: 'Compile Wayland tests',
	type: 'boolean',
	value: false)
option('documentation',
	description: 'Build the documentation (requires Doxygen, dot, xmlto, xsltproc)',
	type: 'boolean',
	value: false)
option('dtd_validation',
	description: 'Validate the protocol DTD (requires libxml2)',
	type: 'boolean',
	value: false)
option('icon_directory',
	description: 'Location used to look for cursors (defaults to ${datadir}/icons if unset)',
	type: 'string',
	value: '')
```

然后的话就是交叉编译的配置了，meson 需要使用到一个专门的 cross file [^6]，配置看起来像这样（riscv64.txt）：

```
[binaries]
c = 'riscv64-unknown-linux-gnu-gcc'
cpp = 'riscv64-unknown-linux-gnu-g++'
ar = 'riscv64-unknown-linux-gnu-ar'
strip = 'riscv64-unknown-linux-gnu-strip'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'riscv64'
cpu = 'riscv64'
endian = 'little'

[properties]
sys_root = '/home/jax/.local/opt/riscv/sysroot'
pkg_config_libdir = ['/home/jax/opt/riscv/usr/local/lib/pkgconfig', '/home/jax/opt/riscv/usr/local/share/pkgconfig']
```

值得吐槽的是 meson 默认居然只会使用 `pkgconfig`，而不会尝试用它另一个风格的名字 `pkg-config`，所以在上面还必须手动设置 binaries 里的 pkgconfig [^3]。最后编译安装还有一个坑人的点，meson 会使用两个变量 —— `DESTDIR` 和 `prefix` 来确定安装路径，而且 `DESTDIR` 默认为 `/`，`prefix` 默认为 `/usr/local`，最终的安装路径则是 `$DESTDIR/$prefix`，这对惯用 make 的人来说是比较反直觉的。本来也还好，直接用 `prefix` 也是一样的，但我安装的 meson 不知为何无法识别 `--prefix` 选项，所以我只能使用 `--destdir` 选项，而当时我以为这两个变量是等价的，所以当我使用 `--destdir "$HOME/opt/riscv/sysroot/usr/local"` 时，实际的安装路径则是 `$HOME/opt/riscv/sysroot/usr/local/usr/local`，在网上找了一圈才发现问题所在，结果最后在 meson 上花的时间居然是最多的。

Anyway，最后的编译安装命令如下：

```bash
meson setup build --cross-file riscv64.txt
meson compile -C build
meson install -C build --destdir "$HOME/opt/riscv/sysroot"
```

## 编译

## References

[^1]: [20220406 - Coelacanthus - 如何给火狐（Firefox）贡献代码- PLCT实验室（内部报告，仅用于关系者交流技术进展）](https://www.bilibili.com/video/BV1fY41177mf)

[^2]: [Ubuntu in Launchpad](https://launchpad.net/ubuntu)

[^3]: [ Pkg-config not found. #3221 ](https://github.com/mesonbuild/meson/issues/3221)

[^4]: [Quick RISC-V cross compilation and emulation](https://saveriomiroddi.github.io/Quick-riscv-cross-compilation-and-emulation/#building-zlib-and-pigz)

[^5]: [How do I specify library and its include in meson cross file](https://stackoverflow.com/questions/67781802/how-do-i-specify-library-and-its-include-in-meson-cross-file)

[^6]: [Cross compilation](https://mesonbuild.com/Cross-compilation.html)