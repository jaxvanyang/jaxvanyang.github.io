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
> 翻译协力：[DeepL](https://www.deepl.com/translator)

GNU 二进制工具，通常被称为 binutils，是一个处理汇编文件、对象文件和库的开发工具集合。

在过去几年中出现的新一代编程语言掩盖了这些工具的功能，因为它们被用在后端，许多开发人员接触不到这些工具。

但如果你是一个在 Linux / UNIX平台上工作的开发者，了解 GNU 开发工具的各种命令是非常重要的。

以下是本教程中涉及的 12 个不同的 binutils 命令。

1. as - GNU 汇编程序命令
2. ld - GNU 链接器命令
3. ar - GNU 归档命令
4. nm - 列出对象文件的符号
5. objcopy - 复制和翻译对象文件
6. objdump - 显示对象文件信息
7. size - 列出符号表节大小和总大小
8. strings - 显示文件中的可打印字符
9. strip - 去除对象文件中的符号
10. c++filt - 符号名称解码器命令
11. addr2line - 转换地址为文件名和行号
12. readelf - 显示 ELF 文件信息

这些工具将帮助你有效地处理你的二进制、对象和库文件。

在这 12 个工具中，as 和 ld 是最重要的，它们是 GNU 编译器集合（gcc）的默认后端。GCC 只负责将 C/C++ 编译成汇编语言，而 as 和 ld 的工作是输出可执行二进制文件。

## 准备示例代码

为了理解所有这些命令是如何工作的，首先，让我们用 gcc -S 从 C 代码中准备一些汇编代码。这里的所有实验都是在 x86 64 位的 Linux 环境里进行的。

下面是 C 代码，它只使用外部函数的返回值作为返回代码。没有输入/输出，所以如果你想检查程序是否按预期执行，请检查返回状态（echo $?）。我们有三个函数，main、func1 和 func2，每个函数有一个文件。

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

GCC 集成了 C 语言运行库，所以主函数会被当作普通函数处理。为了简化演示，我们不希望在编译和链接这些 .s 文件时使用 C 库。因此，我们对 main.s 做了两个修改。

第一个修改是在链接阶段添加了 _start 标签。

_start 标签是应用程序的入口点，如果没有定义，在运行 ld 时将会出现如下警告。

```bash
ld: warning: cannot find entry symbol _start; defaulting to 0000000000400078
```

第二个修改是，用 exit 系统调用代替 ret。

我们应该手动引发系统退出中断。%eax 用于保存函数的返回值，但 exit 系统调用使用 %ebx 作为返回状态。所以我们要把它 %eax 的值复制到 %ebx。

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

## 1. as – GNU Assembler Command

as takes assembly file as input and output an object file. Object file is only an internal format, which will be used as the input of ld for the producing of final executable file.

Execute the as command on main.s file to get the main.o object file as shown below.

```bash
as main.s -o main.o
```

file main.o (produced by “as main.s -o main.o”), we can get below information.

```bash
main.o: ELF 64-bit LSB relocatable, AMD x86-64, version 1 (SYSV), not stripped
```

The object file is in ELF format, which is the most widely used file format for linux distributions.

Please note that “as” command also has syntax support for preprocessing, symbol, constraint, expression, pseudo ops/directives, and comments.

GNU Assembler can support a huge collection of machines, but usually only one machine/architecture family is selected when compiled or cross-compiled.

## 2. ld – GNU Linker Command

Object file usually contains reference to external functions in different library/object, and it’s linker (ld)’s job to combine all the object/library files needed for the final binary, relocate sections, and resolve the reference.

The actual behavior of ld is defined in the linker script, which describes the memory layout of the executable.

If we link main.o only (ld main.o -o main), there will be a undefined reference error:

```bash
main.o: In function `_start':
main.c:(.text+0xa): undefined reference to `func1'
```

We won’t get an executable file without linking all the three objection files (ld main.o func1.o func2.o -o main).

```bash
# file main 
main: ELF 64-bit LSB executable, AMD x86-64, version 1 (SYSV), statically linked, not stripped
```

Be different with the object file, here we get a statically linked executable.

as and ld works on specific target/architecture. But there are some tools that working on BFD objects defined in binutils.

From the last few lines of the output of objcopy -h, we can get the support targets.

```bash
objcopy: supported targets: elf64-x86-64 elf32-i386 a.out-i386-linux pei-i386 pei-x86-64 elf64-l1om elf64-little elf64-big elf32-little elf32-big plugin srec symbolsrec verilog tekhex binary ihex
```

Need to say that verilog, ihex are not supported by real OS, but it can be very useful in processing the content of objects in text format. They are widely used in chip simulation environment for memory/rom initialization.

## 3. ar/ranlib – GNU Archive Command

ar can be used to generate and manipulate static library, which is a archive file that composed by many objects.

Behavior of ar can be controlled from command line argument (the unix style) or script file. ranlib can add a index of symbols to an archive, which can speed up the link speed and also facilitate the call of routines. ar -s will do the same thing as ranlib.

For my test, with or without -s, ar will always output the archive index.

Test1, ar without -s.

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

For full details on ar command, read this: [Linux ar command Examples: How To Create, View, Extract, Modify C Archive Files (*.a)](https://www.thegeekstuff.com/2010/08/ar-command-examples/)

Test 2, ar with -s.

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

Test 3, run ranlib again.

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

It can be shown that each test outputs the same result.

## 4. nm – List Object File Symbols

nm can list symbols from object file. We have show the used of it in above section.

The nm commands provides information on the symbols being used in an object file or executable file.

The default information that the nm command provides are the following:

- Virtual address of the symbol
- A character which depicts the symbol type. If the character is in lower case then the symbol is local but if the character is in upper case then the symbol is external
- Name of the symbol

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

Read more: [10 Practical Linux nm Command Examples](https://www.thegeekstuff.com/2012/03/linux-nm-command/)

## 5. objcopy – Copy and Translate Object Files

objcopy can copy the content of one object file to another object file, and input/output object can in different format.

There are times when you need to port an object file available for one kind of platform (like ARM or x86) to another kind of platform.

Things are relatively easy if the source code is available as it can be re-compiled on the target platform.

But, what if the source code is not available and you still need to port an object file from type of platform to other? Well, if you are using Linux then the command objcopy does exactly the required

The syntax of this command is :

```bash
objcopy [options] infile [outfile]...
```

Read more: [Linux Objcopy Command Examples to Copy and Translate Object Files](https://www.thegeekstuff.com/2013/01/objcopy-examples/)

## 6. objdump – Display Object File Information

objdump can display selected information from object files. We can use objdump -d to apply the disassemble to main.

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

Read more: [Linux Objdump Command Examples (Disassemble a Binary File)](https://www.thegeekstuff.com/2012/09/objdump-examples/)

## 7. size – List Section Size and Toal Size

size can display the size information of sections in object files.

```bash
# size main
   text	   data	    bss	    dec	    hex	filename
     51	      0	      0	     51	     33	main
```

## 8. strings – Display Printable Characters from a File

string can display printable char sequence from object files. By default, it only search in .data section. With -a switch, all the sections can be searched.

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

Read more: [Linux Strings Command Examples (Search Text in UNIX Binary Files)](https://www.thegeekstuff.com/2010/11/strings-command-examples/)

## 9. strip – Discard Symbols from Object File

strip can remove symbols from object file, which can reduce the file size and speed up the execution.

We can show the symbol table by objdump. Symbol table shows the entry/offset for each function/label.

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

After strip (#strip main), the symbol table will be removed.

```bash
#objdump -t main

main:     file format elf64-x86-64

SYMBOL TABLE:
no symbols
```

Read more: [10 Linux Strip Command Examples (Reduce Executable/Binary File Size)](https://www.thegeekstuff.com/2012/09/strip-command-examples/)

## 10. c++filt – Demangle Command

C++ support overloading that can let same function name takes different kinds/number of argument.

This is done by changing the function name to low-level assembler name, which is called as mangling. c++filt can do the demangling for C++ and Java.

Here, we make a new sample code for explanation of mangling.

Suppose we have two types of func3 that take different kind of input argument, the void and the int.

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

In assembly format, they do have different names, _Z5func3v and _Z5func3i. And, one of these will be called according to the type of argument we passed to the func3 in mangling.cpp. In this example, _Z5func3i is called.

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

We can pass these assembly function names to c++filt, and the original function define statement will be recovered.

```bash
#grep func3.*: mangling.s | c++filt 
func3(int):
func3():
```

objdump also can do the demangle with different styles:

```
  -C, --demangle[=STYLE]
  
  Decode mangled/processed symbol names
    The STYLE, if specified, can be 'auto', 'gnu',
    'lucid', 'arm', 'hp', 'edg', 'gnu-v3', 'java'
    or 'gnat'
```

## 11. addr2line – Convert Address to Filename and Numbers

addr2line can get the file and line number of given address or offset inside reallocated section, by passing the debug information.

First, we must compile assembly file with -g flag, so that debug information will be added into object. It can be shown from below that there are some debug sections now.

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

From the disassembly result shown in section 2.d objdump, we can see that 0x400090 is the entry of func1, which is the same as the result that given by addr2line.

```bash
addr2line -e mainD 0x400090
/media/shared/TGS/func1.s:6
```

## 12. readelf – Display ELF File Info

readelf and elfedit can operation on elf file only.

readelf can display information from elf file.
We can display detailed information of ELF header.

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

Just like readelf, you can also use elfedit which can update machine, file type and OS ABI in the elf header. Please note that, elfedit may not be included by default in your distribution.

Read more: [Linux ELF Object File Format (and ELF Header Structure) Basics](https://www.thegeekstuff.com/2012/07/elf-object-file-format/)
