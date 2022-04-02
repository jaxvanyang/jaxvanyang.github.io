---
title:  "写给自己看的编程规范"
date: 2020-12-17 20:50:00 +0800
---

> 至少要让自己能看懂  

很多学习编程的同学在编程的时候往往是想到什么写什么，并不会遵循所谓的**编程规范**，我也是一样。  

这种方法虽然在写老师布置的编程题时有用，代码确实能跑起来，但是当我回过头去看以前写的代码时，我发现自己居然看不懂自己写的代码！  

代码确实是我自己写的，但是我再看时确实不能一目了然，其实原因也很简单，由于每次敲代码时心中并没有一个**编程规范**，程序的结构设计往往十分随意，可能变量和函数的名字都是随便取的，写的时候还能知道函数有什么用，但是过段时间就不能“望文生义”了。  

所以，为了尽量降低日后代码维护工作的难度，请遵循一种**编程规范**，即使是非常小的代码片段也要注意，说不准哪天你也会想要参考一下以前的代码却发现看不懂。  

那我们要遵循什么样的**编程规范**？其实网上已经有了很多关于**编程规范**的文章，我的这篇博文也是启发自它们。  

以下是我总结的一些规范，它们都有同一个出发点——让我自己能看懂，并不一定是最佳实践，仅供参考。  

## 1. 命名风格

命名风格有好几种，常见的有：  
1. 驼峰命名法  
    1. [小驼峰法](https://baike.baidu.com/item/%E9%AA%86%E9%A9%BC%E5%91%BD%E5%90%8D%E6%B3%95#2_1)
    2. [大驼峰法（也叫帕斯卡命名法）](https://baike.baidu.com/item/%E9%AA%86%E9%A9%BC%E5%91%BD%E5%90%8D%E6%B3%95#2_2)  
2. 下划线命名法  
3. [匈牙利命名法](https://baike.baidu.com/item/%E5%8C%88%E7%89%99%E5%88%A9%E5%91%BD%E5%90%8D%E6%B3%95)  

它们的用法看名字大概就能知道，除了匈牙利命名法，不过匈牙利命名法也是最少用的，所以我就不在此一一介绍了。  

其实命名法并没有优劣之分，它们都有各自的优缺点，比如下划线命名法的可读性最好，但是相对来说也更长。所以你可以根据自己的喜好选择一种或几种命名法，但是有一点一定要遵守，就是统一性。你的代码里可以同时出现多种命名法，但是对于同一类对象，请使用同一种命名法，比如不能既使用 `redCat` 又使用 `blue_dog` 来给同一类变量命名。  

再就是不要使用不规范的缩写，避免望文不知意。反例：condition 缩写成 condi。  

## 2. 运用抽象

抽象是程序员的一项基本技能。编程语言从最开始的机器语言，再到汇编语言，一直到现在广为人知的高级语言，总体的趋势就是抽象层面越来越高。在高级语言里，一行代码可能相当于几十行汇编代码，虽然在底层让程序更复杂了，但是却让程序更易读且更易维护。  

所以如果我们不想当“码农”的话就要运用好抽象，在编程的时候可以把处理同一个功能的代码放在一起，或者直接用函数封装起来，用的时候就不用考虑具体的实现细节，减少了代码量，这样的代码维护起来也比较方便。  

## 3. 删除~~不必要的注释~~

虽然写注释是一个好习惯，但是有些注释非但不能让我们的代码更易读，反而会让代码变得冗长、难以维护，甚至产生误导。  

我们可以先来看一下这段代码：  
```cpp
// 对数组排序
void sortArray(const int arr[], const int size) {
    ...
}
```

这行注释其实完全没有必要，因为函数的名字就已经足够显示它的作用了。有些同学可能还会喜欢在每一行代码后面加上注释，例如上面的排序函数，如果针对其中的每个实现细节进行说明，将会增加不少的工作量，而且万一哪一天你想换一种算法排序，那你所有的注释都白写了，而且还需要重写每一步。  

所以，为了头发，请尽量写**自注释**的代码。  

## 推荐阅读

由于笔者水平有限，前面我也说了，关于编程规范的文章网上有很多，所以我就不班门弄斧了，这篇博文主要是写给自己看的，作为自己编程的规范随时查阅，日后有时间会继续完善。  

如果你还想了解更多，可以阅读这些文章：  
[代码整洁之道的 7 个方法](https://juejin.cn/post/6904047941883789319)  

[Java 开发手册（嵩山版）](https://github.com/alibaba/p3c/blob/master/Java%E5%BC%80%E5%8F%91%E6%89%8B%E5%86%8C%EF%BC%88%E5%B5%A9%E5%B1%B1%E7%89%88%EF%BC%89.pdf)，这本书是阿里巴巴的官方开发手册，内容十分全面，不仅是开源免费的，更有配套的 IDEA 插件可以使用，从事 Java 开发的同学一定要学习一下。  

[如何写好 C main 函数](https://juejin.cn/post/6844903861786771469)  
## 参考
[命名法：驼峰、下划线、匈牙利](https://www.cnblogs.com/linuxAndMcu/p/11280748.html)  