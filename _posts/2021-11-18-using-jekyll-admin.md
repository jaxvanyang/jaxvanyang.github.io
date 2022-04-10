---
title: 使用 Jekyll Admin
layout: post
date: '2021-11-18 00:54:13 +0800'
categories:
- jekyll
---

![banner]({{ "/assets/images/using-jekyll-admin-banner.png" | absolute_url }})

使用 Jekyll Admin，你就可以使用图形化界面管理你的博客，而不是通过编辑代码来管理，在一定情况下更加方便。

## TOC

- [安装 Jekyll Admin](#安装-jekyll-admin)

- [使用 Jekyll Admin](#使用-jekyll-admin)

- [参考](#参考)

## 安装 Jekyll Admin

1. 在网站配置文件 `Gemfile` 中将 `jekyll-admin` 加入 group `:jekyll_plugins`，示例如下：

   ```text
   group :jekyll_plugins do
   gem "jekyll-feed", "~> 0.12"
   gem "jekyll-admin"
   end
   ```

2. 安装依赖：

   ```shell
   bundle install
   ```

## 使用 Jekyll Admin

1. 启动网站服务：

   ```shell
   bundle exec jekyll serve
   ```

2. 在网站 URL 后加上 `/admin`，即可访问 Jekyll Admin：

   ![using jekyll admin]({{ "/assets/images/using-jekyll-admin.png" | absolute_url }})

## 参考

- <https://jekyllrb.com/docs/plugins/installation/>

- <https://jekyll.github.io/jekyll-admin/>

- <https://gems.ruby-china.com/>

- <https://jekyllrb.com/docs/liquid/filters/>

- <https://www.seoquake.com/blog/relative-or-absolute-urls/>
