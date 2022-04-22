---
title: CSAPP 阅读记录 | 运行时库打桩出现段错误（segmentation fault）
category: CSAPP
tags:
- segfault
- library interpositioning
- daynamic linking
---

> 在使用《深入理解计算机系统》上的运行时库打桩示例代码的时候，我遇到了这个错误，以下是 debug 过程以及解决方法。

## Error

```bash
gcc -Wall -DRUNTIME -shared -fpic -o mymalloc.so mymalloc.c -ldl
gcc -o intr int.c
LD_PRELOAD="./mymalloc.so" ./intr
[1]    5657 segmentation fault (core dumped)  LD_PRELOAD="./mymalloc.so" ./intr
```

## Debug

导致出错的代码段如下：

```c
/* malloc wrapper function */
void *malloc(size_t size)
{
    void *(*mallocp)(size_t size);
    char *error;

    mallocp = dlsym(RTLD_NEXT, "malloc"); /* Get address of libc malloc */
    if ((error = dlerror()) != NULL) {
        fputs(error, stderr);
        exit(1);
    }
    char *ptr = mallocp(size); /* Call libc malloc */
    printf("malloc(%d) = %p\n", (int)size, ptr);
    return ptr;
}
```

```c
/* 
 * hello.c - Example program to demonstrate different ways to
 *           interpose on the malloc and free functions.
 *
 * Note: be sure to compile unoptimized (-O0) so that gcc won't
 * optimize away the calls to malloc and free.
 */
/* $begin interposemain */
#include <stdio.h>
#include <malloc.h>

int main()
{
    int *p = malloc(32);
    free(p);
    return(0); 
}
/* $end interposemain */
```

我一开始以为错误的原因是解引用了空指针或野指针，因为原始代码中并没有进行判空处理，但仅仅是分配 32 字节的空间是不应该分配失败的，更何况代码里也没有解引用的操作。为了排除我抄错代码的原因，我甚至写了一个[脚本](https://github.com/JaxVanYang/lang-study/blob/main/shell/csapp-dl.sh)来下载 CSAPP 的源码，但结果也是一样地报错。然后我开始尝试用 `GDB` 调试跟踪错误，但是 `GDB` 出现了无法打开共享库文件的错误：

```bash
(gdb) set environment LD_PRELOAD "./mymalloc.so"
(gdb) run
Starting program: /home/jax/repos/lang-study/shell/intr 
ERROR: ld.so: object '"./mymalloc.so"' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
ERROR: ld.so: object '"./mymalloc.so"' from LD_PRELOAD cannot be preloaded (cannot open shared object file): ignored.
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/usr/lib/libthread_db.so.1".
[Inferior 1 (process 7498) exited normally]
(gdb)
```

一般只有在共享库文件缺失的情况下才会出现这个错误，但实际上这个文件是存在的，所以我开始了 Google，很不幸，搜到的解决办法都是针对文件缺失的情况，唯一一个可能有用的说需要使用绝对路径也是错的，在搜寻了几个小时后我才意识到找错误的方向是错误的。

## 解决

前面我都是用报错信息作关键词来搜索，但既然是 CSAPP 书上出现的错误，为什么不用 CSAPP 作关键词来搜索呢？然后我很快就找到了问题原因以及解决办法：

[CSAPP第三版运行时打桩Segmentation fault_imred的博客-CSDN博客](https://blog.csdn.net/imred/article/details/77418323#commentBox)

[Library interpositioning](https://stackoverflow.com/questions/65275140/library-interpositioning)

产生错误的根本原因是我们的 `malloc()` 实现替代了 `libc` 的实现，但我们的 `malloc()` 函数里调用了 `printf()`，而 `printf()`又调用了 `malloc()`，这就导致了间接递归调用：`malloc() → printf() → malloc() → ...`，最终无限递归导致堆栈溢出。

由于 `printf()` 最多只可能调用 `malloc()` 一次，所以我们可以想办法在 `printf()` 调用的 `malloc()` 中取消掉 `printf()` 的调用，这可以用静态变量记录调用状态实现：

```c
static int is_first_malloc = 1;
if (is_first_malloc) {
  is_first_malloc = 0;
  printf("malloc(%ld) = %p\n", size, ptr);
  is_first_malloc = 1;
}
```

> 引用前述参考资料：「实际上dlsym、dlerror和fputs这些函数也是有可能调用了malloc函数的，但是程序正确运行了，说明在这种场景下这些函数没有调用malloc函数，在其他场景下是否会调用malloc函数就不一定了。为了简单起见，没有进行更多的修改。」
> 

所以说这样解决也不是绝对安全的，要完全解决必须对标准库的实现有一定的了解，不然就只能尽量避免在包装函数中调用其他库函数，或者掌握正确的 debug 方法。

## 延伸阅读

[記憶體區段錯誤 - 维基百科，自由的百科全书](https://zh.wikipedia.org/wiki/%E8%A8%98%E6%86%B6%E9%AB%94%E5%8D%80%E6%AE%B5%E9%8C%AF%E8%AA%A4)