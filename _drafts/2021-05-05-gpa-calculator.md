---
title: "长沙理工大学 GPA 自动计算爬虫"
date: 2021-05-05 17:00:00 +0800
---

![gpa-calculator]({{ "/assets/images/gpa-calculator-edge.png" | absolute_url }})  

## 简介

该脚本使用 [Edge 浏览器的测试驱动](https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/)模拟手工访问教务网站，只需要输入帐号密码就可以自动获取课程成绩信息，并计算各学年或学期的 GPA，简单易用。  

## 使用方法

1. 克隆原仓库：

	```bash
	git clone https://gitee.com:Jaxvanyang/lang-study.git
	```

1. 切换到原仓库的 `python/src` 路径：

	```bash
	cd lang-study/python/src
	```

2. 安装好依赖：

	```bash
	pip install selenium
	```

3. 运行脚本：

	```bash
	python3 gpa_calculator.py
	```

## 参考链接


- 主程序：[gpa_calculator.py](https://gitee.com/Jaxvanyang/lang-study/blob/gpa/python/src/gpa_calculator.py)  

- [Browser manipulation](https://www.selenium.dev/documentation/en/webdriver/browser_manipulation/)  

## 更新

[FIX BUG](https://gitee.com/Jaxvanyang/lang-study/commit/685ffad3c2e416bd02ba76963e24a13dc2802762)
