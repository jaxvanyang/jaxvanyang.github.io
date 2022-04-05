---
title: "手把手带你写一个简单的 Makefile"
date: 2020-12-11 03:00:00 +0800
modified_date: 2022-04-05
---

> 推荐收藏 [Makefile Tutorial By Example](https://makefiletutorial.com/)，那是一个全面详细容易上手的教程。

## 1. make

`make` 通常用于 C 语言程序的开发管理，通过编写 `Makefile` 你就可以只需要在命令行输入 `make` 就可以根据修改的文件自动编译连接，避免了每次输入一长串的编译指令。`make` 也不仅限于 C 语言程序的编译工作，凡是可以用 `shell 脚本` 完成的操作都可以用 `make` 实现，也就是说你几乎可以用它做任何事！  

## 2. Makefile

`make` 这个东西很好用，但也是需要配置一下的，好在配置十分简单，只需要编写一个 `Makefile` 文件放在工作目录下，写成 `makefile` 也行，看个人的喜好了。接下来就让我们一起来写一个简单的 `Makefile` 来了解一下它的用法。  

### 2.1 规则（rule）

`Makefile` 最基本的组成部分就是`规则`了，可以说只要会写`规则`就会用 `make`。  

```bash
# rule
target ... : prerequisite ...
      recipe    # 注意必须以 Tab 开头
      ...
```

一个`规则`通常由三部分组成：`目标（target）`、`依赖文件（prerequisite）`和`步骤（recipe）`，`目标`表示这条规则会生成文件，*依赖文件*则是这条*规则*运行所需要的文件，而*步骤*则是这条*规则*实际会运行的命令。  
让我们一起来看看下面的这段代码来理解它们各自的作用吧：  
```bash
# Makefile

# rule0
hello.out : hello.c util_1.o util_2.o
      cc -o hello.out hello.c util_1.o util_2.o

# rule1
util_1.o : util_1.c helper.h
      cc -c util_1.c

# rule2
util_2.o : util_2.c helper.h
      cc -c util_2.c
```

在 `Makefile` 中写下这段代码后再运行 `make`：  
```bash
$ make
# shell 就会执行
$ cc -c util_1.c helper.h
$ cc -c util_2.c helper.h
$ cc -o hello.out hello.c util_1.o util_2.o
```

如果直接运行 `make` 不加参数，那么它会运行第一个 `rule`，这时 `make` 会检查*依赖文件*是否都存在，如果不存在就会下面寻找是否有*缺失文件*的规则，如果有就会执行*缺失文件*的规则，如果没有就会报错中断。所以我们会在上面看到是先运行了 `rule1` 和 `rule2` 后再执行的 `rule0`。  
其实 `make` 也十分智能，只要你的源文件有所更改，比如你修改了 `util_1.c`，然后再执行 `make` 即使 `util_1.o` 已经存在，它也会重新执行 `rule1` 编译生成新的 `util_1.o`。  

### 2.2 隐式规则

因为编译源文件生成对象文件是一个十分频繁的操作，所以 `make` 内置了一种隐式规则来简化这部分*规则*的书写，例如：
```bash
# 你可以将之前的
util_1.o : util_1.c helper
      cc -c util_1.c

util_2.o : util_2.c helper
      cc -c util_2.c

# 写成
util_1.o util_1.o : helper
```

这两种写法的效果完全是一样的，因为*目标*的后缀是 `.o`，`make` 就知道你会执行 `cc -c example.c` 来编译，所以你只需要在后面指定其它的*依赖文件*，从而你就可以根据*依赖文件*来组织*规则*了。  
`make` 也不会因为其中一个文件的缺失而一次重新编译两个文件，而是会自动选择，所以不必怀疑 `make` 的智能。

### 2.3 .PHONY 标签

除了编译生成文件，`make` 能做的事还有很多，比如清理工作目录。按照惯例，我们先来看一段代码：  
```bash
# 省略了之前编写的规则
...

.PHONY : clean
clean :
      -rm hello.out
      -rm util_1.o util_2.0
```

想要运行这段代码就只需要输入 `make clean`。
因为这只是单纯的一个任务，并不需要生成文件，所以我们需要通过 `.PHONY 标签` 来告诉 `make` 不要把这个 `clean` 当成一个文件，这样可以避免因为一个真实存在的 `clean` 文件而导致的错误。  
而 `-rm` 中的 `-` 则是告诉 `make` 即使这条命令出错也继续执行后面的命令。如果你不加 `-` ，假如现在 `hello.out` 文件并不存在，那么执行 `rm hello.out` 就会报错，这就会导致 `make` 退出，后面的命令就不会执行了，而如果加了 `-` 就会忽略报错继续执行后面的命令。  

### 2.4 变量

另外一个简化代码的方法就是定义*变量*，`Makefile` *变量*的使用方法和 `shell` 类似，但是等号两边可以加空格，例如：  
```bash
TARGET = hello.out
OBJS = util_1.o util_2.o

$(TARGET) : hello.c $(OBJS)
      cc -o $(TARGET) hello.c $(OBJS)

$(OBJS) : helper.h
```

这个过于简单就不解释了，看看就好。

## 3. 总结

以上就是本文的全部内容了，只是简单地讲了一下 `Makefile` 的基础功能，其实还有很多复杂的功能，但是我接触 `make` 也没多久，精力也有限，有机会再展开吧。  

这里不加解释地给出 `make` 官方文档里的一段代码，可以借鉴一下：
```bash
objects = main.o kbd.o command.o display.o \
          insert.o search.o files.o utils.o

edit : $(objects)
        cc -o edit $(objects)

main.o : defs.h
kbd.o : defs.h command.h
command.o : defs.h command.h
display.o : defs.h buffer.h
insert.o : defs.h buffer.h
search.o : defs.h buffer.h
files.o : defs.h buffer.h command.h
utils.o : defs.h

.PHONY : clean
clean :
        rm edit $(objects)
```

## 4. 参考

[GUN make](http://www.gnu.org/software/make/manual/make.html#Overview)  

[Make 快速入门](https://juejin.cn/post/6844903957618393101#heading-0)