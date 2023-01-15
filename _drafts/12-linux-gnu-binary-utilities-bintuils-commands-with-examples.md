---
title: 译 | GNU 的 12 个二进制工具及示例（RISC-V 版）
author: Terrence Sun
category: linux
tags:
- bintuils
- risc-v
- translation
---

![banner]({{ "/assets/images/gnu-binutils.png" | relative_url }})

> 此篇文章翻译自 [12 Linux GNU Binary Utilities Binutils Commands with Examples (as, ld, ar, nm, objcopy, objdump, size, strings, strip, c++flint, addr2line, readelf Command Examples)](https://www.thegeekstuff.com/2017/01/gnu-binutils-commands/)
>
> 原作者：Terrence Sun
> 
> 翻译协力：[DeepL](https://www.deepl.com/translator)、[Bing Microsoft Translator](https://www.bing.com/translator)

GNU 二进制工具，通常被称为 binutils，是一个处理汇编文件、目标文件和库的开发工具集合。

在过去几年中出现的新一代编程语言掩盖了这些工具的功能，因为它们被用在后端，许多开发人员接触不到这些工具。

但如果你是一个在 Linux / UNIX 平台上工作的开发者，了解 GNU 开发工具的各种命令是非常必要的。

以下是本教程中涉及的 12 个不同的 binutils 命令。

1. as - GNU 汇编程序命令
2. ld - GNU 链接器命令
3. ar - GNU 归档命令
4. nm - 列出目标文件的符号
5. objcopy - 复制和翻译目标文件
6. objdump - 显示目标文件信息
7. size - 列中各部分的大小信息和总的大小信息
8. strings - 显示文件中的可打印字符
9. strip - 去除目标文件中的符号
10. c++filt - 符号名称解码器命令
11. addr2line - 转换地址为文件名和行号
12. readelf - 显示 ELF 文件信息

这些工具将帮助你有效地处理你的二进制、目标和库文件。

在这 12 个工具中，as 和 ld 是最重要的，它们是 GNU 编译器集合（gcc）的默认后端。GCC 只负责将 C/C++ 编译成汇编语言，而其中 as 和 ld 的工作是输出可执行二进制文件。

## 准备示例代码

为了理解所有这些命令是如何工作的，首先，让我们用 gcc -S 从 C 代码中准备一些汇编代码。这里的所有实验都是在 x86 64 位的 Linux 环境里进行的。

下面是 C 代码，它只使用外部函数的返回值作为返回代码。没有输入/输出，所以如果你想检查程序是否按预期执行，请检查返回状态（echo $?）。我们有三个函数，main、func1 和 func2，每个文件对应一个函数。

```c
// func1.c file:
int func1() {
	return func2();
}

// func2.c file:
int func2() {
	return 1;
}

// main.c file:
int main() {
	return func1();
}
```

GCC 集成了 C 语言运行库，所以主函数会被当作普通函数处理。为了简化演示，我们不希望在编译和链接这些 .s 文件时涉及 C 库。因此，我们对 main.s 做了两个修改。

第一个修改是在链接阶段添加了 _start 标签。

_start 标签是应用程序的入口点，如果没有定义，在运行 ld 时将会出现如下警告。

```bash
ld: warning: cannot find entry symbol _start; defaulting to 0000000000400078
```

第二个修改是，用 exit 系统调用代替 ret。

我们应该手动引发系统退出中断。%eax 用于保存函数的返回值，但 exit 系统调用使用 %ebx 保存返回状态。所以我们要把 %eax 的值复制到 %ebx。

下面是编辑过后的 gcc 汇编代码。

func1.s 文件:

```asm
	.file	"func1.c"
	.text
.globl func1
	.type	func1, @function
func1:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$0, %eax
	call	func2
	leave
```

func2.s 文件:

```asm
	.file	"func2.c"
	.text
.globl func2
	.type	func2, @function
func2:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$1, %eax
	leave
	ret
```

main.s 文件:

```asm
	.file	"main.c"
	.text
.globl main
.globl _start
	.type	main, @function
_start:
main:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$0, %eax
	call	func1
            movl    %eax, %ebx
            movl    $1, %eax
            int        $0x80
	leave
```

## 1. as – GNU 汇编程序命令

as 将汇编文件作为输入，并输出一个目标文件。对象文件只是一种内部格式，它将作为 ld 的输入，用于生成最终的可执行文件。

在 main.s 文件上执行 as 命令，可以得到 main.o 对象文件，如下所示。

```bash
as main.s -o main.o
```

执行命令 “file main.o”（由"as main.s -o main.o "生成），我们可以得到以下信息。

```bash
main.o: ELF 64-bit LSB relocatable, AMD x86-64, version 1 (SYSV), not stripped
```

该对象文件是 ELF 格式，这是在 Linux 发行版中使用最广泛的文件格式。

请注意，"as "命令也有对预处理、符号、约束、表达式、伪操作/指令和注释的语法支持。

GNU 汇编程序可以支持大量机器，但通常在编译或交叉编译时只选择一个机器/架构系列。

## 2. ld – GNU 链接器命令

对象文件通常包含对不同库/对象中的外部函数的引用，链接器（ld）的工作是合并最终二进制文件所需的所有对象/库文件，重新定位符号表节，并解决引用问题。

ld 的实际行为是在链接器脚本中定义的，它描述了可执行文件的内存布局。

如果我们只链接 main.o（ld main.o -o main），会出现未定义的引用错误：

```bash
main.o: In function `_start':
main.c:(.text+0xa): undefined reference to `func1'
```

我们需要链接全部的三个对象文件才能得到一个可执行文件（ld main.o func1.o func2.o -o main）。

```bash
# file main 
main: ELF 64-bit LSB executable, AMD x86-64, version 1 (SYSV), statically linked, not stripped
```

与对象文件不同，这里我们得到了一个静态链接的可执行文件。

as 和 ld 在特定的目标/架构上工作。但是有一些工具可以在 binutils 中定义的 BFD 对象上工作。

从 objcopy -h 输出的最后几行，我们可以获取到支持的目标类型。

```bash
objcopy: supported targets: elf64-x86-64 elf32-i386 a.out-i386-linux pei-i386 pei-x86-64 elf64-l1om elf64-little elf64-big elf32-little elf32-big plugin srec symbolsrec verilog tekhex binary ihex
```

需要说明的是，verilog、ihex 并不被真正的操作系统所支持，但它在处理文本格式的对象内容时非常有用。它们被广泛用于芯片仿真环境中的 memory/rom 初始化。

## 3. ar/ranlib – GNU 归档命令

ar 可以用来生成和编辑静态库，这是一个由许多对象组成的档案文件。

ar 的行为可以通过命令行参数（Unix风格）或脚本文件来控制。ranlib 可以为归档文件添加符号索引，这可以加快链接速度，也便于调用例程。as -s 与 ranlib 有一样的效果。

对于我的测试，不管有没有 -s，ar 都会输出存档索引。

测试 1，ar 不加 -s。

```bash
# ar -r extern.a func1.o func2.o && nm -s extern.a
ar: creating extern.a

Archive index:
func1 in func1.o
func2 in func2.o

func1.o:
0000000000000000 T func1
                 U func2

func2.o:
0000000000000000 T func2
```

要查看 ar 命令的全部细节，请阅读此文：[Linux ar command Examples: How To Create, View, Extract, Modify C Archive Files (*.a)](https://www.thegeekstuff.com/2010/08/ar-command-examples/)

测试 2，ar 加上 -s。

```bash
# ar -r -s externS.a func1.o func2.o && nm -s externS.a
ar: creating externS.a

Archive index:
func1 in func1.o
func2 in func2.o

func1.o:
0000000000000000 T func1
                 U func2

func2.o:
0000000000000000 T func2
```

测试 3，再运行一次 ranlib。

```bash
# cp extern.a externR.a && ranlib externR.a && nm -s externR.a
Archive index:
func1 in func1.o
func2 in func2.o

func1.o:
0000000000000000 T func1
                 U func2

func2.o:
0000000000000000 T func2
```

可以看到每个测试的结果都是一样的。

## 4. nm – 列出对象文件的符号

nm 可以列出对象文件中的符号。我们已经在上一节中展示了它的用途。

nm 命令提供对象文件或可执行文件中使用的符号信息。

nm 命令所提供的默认信息如下：

- 符号的虚拟地址
- 一个描述符号类型的字符。如果该字符是小写的，那么该符号是本地的，如果该字符是大写的，那么该符号是外部的。
- 符号的名称

```bash
$ nm  -A ./*.o | grep func
./hello2.o:0000000000000000 T func_1
./hello3.o:0000000000000000 T func_2
./hello4.o:0000000000000000 T func_3
./main.o:                   U func
./reloc.o:                  U func
./reloc.o:0000000000000000  T func1
./test1.o:0000000000000000  T func
./test.o:                   U func
```

了解更多：[10 Practical Linux nm Command Examples](https://www.thegeekstuff.com/2012/03/linux-nm-command/)

## 5. objcopy – 复制和翻译对象文件

objcopy 可以把一个对象文件的内容复制到另一个对象文件，也可以用不同的格式输入/输出对象。

有些时候，你需要把一个可用于一种平台（如 ARM 或 x86）的对象文件移植到另一种平台。

如果源代码是可用的，解决就相对容易些，因为它可以在目标平台上重新编译。

但是，如果源代码不可用，而你仍然需要将一个对象文件从一种平台移植到另一种平台，那该怎么办？好吧，如果你使用的是 Linux，那么 objcopy 命令正好能满足你的要求。

这个命令的语法是：

```bash
objcopy [options] infile [outfile]...
```

了解更多：[Linux Objcopy Command Examples to Copy and Translate Object Files](https://www.thegeekstuff.com/2013/01/objcopy-examples/)

## 6. objdump – 显示对象文件信息

objdump 可以显示对象文件中的选定信息。我们可以使用 objdump -d 来对 main 进行反汇编。

```bash
# objdump -d main
main:     file format elf64-x86-64

Disassembly of section .text:

0000000000400078 <main>:
  400078:	55                   	push   %rbp
  400079:	48 89 e5             	mov    %rsp,%rbp
  40007c:	b8 00 00 00 00       	mov    $0x0,%eax
  400081:	e8 0a 00 00 00       	callq  400090 <func1>
  400086:	c9                   	leaveq 
  400087:	89 c3                	mov    %eax,%ebx
  400089:	b8 01 00 00 00       	mov    $0x1,%eax
  40008e:	cd 80                	int    $0x80

0000000000400090 <func1>:
  400090:	55                   	push   %rbp
  400091:	48 89 e5             	mov    %rsp,%rbp
  400094:	b8 00 00 00 00       	mov    $0x0,%eax
  400099:	e8 02 00 00 00       	callq  4000a0 <func2>
  40009e:	c9                   	leaveq 
  40009f:	c3                   	retq   

00000000004000a0 <func2>:
  4000a0:	55                   	push   %rbp
  4000a1:	48 89 e5             	mov    %rsp,%rbp
  4000a4:	b8 01 00 00 00       	mov    $0x1,%eax
  4000a9:	c9                   	leaveq 
  4000aa:	c3                   	retq   
```

了解更多：[Linux Objdump Command Examples (Disassemble a Binary File)](https://www.thegeekstuff.com/2012/09/objdump-examples/)

## 7. size – 列中各部分的大小信息和总的大小信息

size 可以显示对象文件中各部分的大小信息。

```bash
# size main
   text	   data	    bss	    dec	    hex	filename
     51	      0	      0	     51	     33	main
```

## 8. strings – 显示文件中的可打印字符

string 可以显示对象文件中可打印的字符序列。默认情况下，它只在 .data 部分进行搜索。加上 -a 选项后可以搜索所有的部分。

```bash
# strings -a main
.symtab
.strtab
.shstrtab
.text
main.c
func1.c
func2.c
func1
_start
__bss_start
main
func2
_edata
_end
```

了解更多：[Linux Strings Command Examples (Search Text in UNIX Binary Files)](https://www.thegeekstuff.com/2010/11/strings-command-examples/)

## 9. strip – 去除对象文件中的符号

strip 可以从对象文件中删除符号，这可以减少文件的大小，加快执行速度。

我们可以通过 objdump 显示符号表。符号表显示了每个函数/标签的条目/偏移量。

```bash
# objdump -t main

main:     file format elf64-x86-64

SYMBOL TABLE:
0000000000400078 l    d  .text	0000000000000000 .text
0000000000000000 l    df *ABS*	0000000000000000 main.c
0000000000000000 l    df *ABS*	0000000000000000 func1.c
0000000000000000 l    df *ABS*	0000000000000000 func2.c
0000000000400090 g     F .text	0000000000000000 func1
0000000000400078 g       .text	0000000000000000 _start
00000000006000ab g       *ABS*	0000000000000000 __bss_start
0000000000400078 g     F .text	0000000000000000 main
00000000004000a0 g     F .text	0000000000000000 func2
00000000006000ab g       *ABS*	0000000000000000 _edata
00000000006000b0 g       *ABS*	0000000000000000 _end
```

在 strip（#strip main）之后，符号表将被删除。

```bash
#objdump -t main

main:     file format elf64-x86-64

SYMBOL TABLE:
no symbols
```

了解更多：[10 Linux Strip Command Examples (Reduce Executable/Binary File Size)](https://www.thegeekstuff.com/2012/09/strip-command-examples/)

## 10. c++filt – 符号名称解码器命令

C++ 支持重载，可以让同一个函数名接受不同种类/数量的参数。

这是通过将重载函数名改写为底层的汇编符号名称来实现的，c++filt 可以为 C++ 和 Java 做这种符号名称解码。

在这里，我们做一个新的示例代码来解释符号名称编码。

假设我们有两种类型的 func3，分别接受不同类型的输入参数，即 void 和 int。

```cpp
==> mangling.cpp <==
int func3(int a) {
	return a;
}
int func3() {
	return 0;
}
int main() {
	return func3(1);
}
```

在汇编格式中，它们其实有不同的名字，_Z5func3v 和 _Z5func3i。而且，根据我们在 mangling.cpp 中传递给 func3 的参数类型，只有其中一个会被调用。在这个例子中，调用的是 _Z5func3i。

```bash
==> mangling.s <==
	.file	"mangling.cpp"
	.text
.globl _Z5func3i
	.type	_Z5func3i, @function
_Z5func3i:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	%edi, -4(%rbp)
	movl	-4(%rbp), %eax
	leave
	ret

.globl _Z5func3v
	.type	_Z5func3v, @function
_Z5func3v:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$0, %eax
	leave
	ret

.globl main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	$1, %edi
	call	_Z5func3i
	leave
	ret

#grep func3.*: mangling.s
_Z5func3i:
_Z5func3v:
```

我们可以把这些汇编函数名传递给 c++filt，它们就会被还原成原来的函数定义语句。

```bash
#grep func3.*: mangling.s | c++filt 
func3(int):
func3():
```

objdump 也可以用不同的风格做符号名称解码。

```
  -C, --demangle[=STYLE]
  
  Decode mangled/processed symbol names
    The STYLE, if specified, can be 'auto', 'gnu',
    'lucid', 'arm', 'hp', 'edg', 'gnu-v3', 'java'
    or 'gnat'
```

## 11. addr2line – 转换地址为文件名和行号

通过传递调试信息给 addr2line，可以得到重定位后给定地址或偏移量对应的文件和行号。

首先，我们必须用 -g 标志编译汇编文件，这样调试信息就会被添加到对象中。从下面可以看出，现在有一些调试信息节。

```bash
objdump -h mainD

mainD:     file format elf64-x86-64

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         00000033  0000000000400078  0000000000400078  00000078  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .debug_aranges 00000090  0000000000000000  0000000000000000  000000b0  2**4
                  CONTENTS, READONLY, DEBUGGING
  2 .debug_info   000000dd  0000000000000000  0000000000000000  00000140  2**0
                  CONTENTS, READONLY, DEBUGGING
  3 .debug_abbrev 0000003c  0000000000000000  0000000000000000  0000021d  2**0
                  CONTENTS, READONLY, DEBUGGING
  4 .debug_line   000000ba  0000000000000000  0000000000000000  00000259  2**0
                  CONTENTS, READONLY, DEBUGGING
```

> FIXME：这里提到的反汇编结果不知道在哪里
从第 2.d 节 objdump 中显示的反汇编结果，我们可以看到 0x400090 是 func1 的入口，这与 addr2line 给出的结果相同。

```bash
addr2line -e mainD 0x400090
/media/shared/TGS/func1.s:6
```

## 12. readelf – 显示 ELF 文件信息

readelf 和 elfedit 只能对 ELF 文件进行操作。

readelf 可以显示 ELF 文件的信息。

例如显示 ELF 头的详细信息。

```bash
#readelf -h main_full
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x400078
  Start of program headers:          64 (bytes into file)
  Start of section headers:          208 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         1
  Size of section headers:           64 (bytes)
  Number of section headers:         5
  Section header string table index: 2
```

就像 readelf 一样，你也可以使用 elfedit，它可以更新 ELF 头中的机器、文件类型和操作系统 ABI。请注意，你的发行版可能默认没有包含 elfedit。

了解更多：[Linux ELF Object File Format (and ELF Header Structure) Basics](https://www.thegeekstuff.com/2012/07/elf-object-file-format/)
