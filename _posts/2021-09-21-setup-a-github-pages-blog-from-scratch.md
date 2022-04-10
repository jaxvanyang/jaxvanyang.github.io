---
title: 从 0 开始配置一个 GitHub Pages 博客
date: '2021-09-21 03:00:00 +0800'
modified_date: '2022-04-05'
tags:
- 笔记
- GitHub
- Pages
---

> 最快的配置方式是 *fork* 一个别人的仓库，然后在它的基础上进行修改。

## TOC

- [1. 安装 Jekyll](#1-安装-jekyll)

- [2. 初始化](#2-初始化)

- [3. 写博客（Blogging）](#3-写博客blogging)

- [4. 部署到 GitHub](#4-部署到-github)

- [5. 更换主题](#5-更换主题)

- [6. 最佳实践](#6-最佳实践)

- [参考](#参考)


## 1. 安装 Jekyll

> Note: 本文使用 Ubuntu 20.04 作为演示环境，你也可以到[这里](https://jekyllrb.com/docs/installation/)查看其他操作系统的安装教程。

现在有很多搭建博客的框架，比如流行的 [Hexo](https://hexo.io/) 和商业性的 [WordPress](https://wordpress.com/)。

但是本文选择一种更 old school 的框架，也就是标题中的 [Jekyll](https://jekyllrb.com/)，这也是 [GitHub Pages](https://pages.github.com/) 默认支持的框架，比较适合喜欢 DIY 的人。

安装 Jekyll 的第一步是安装依赖，因为 Jekyll 是一个用 [Ruby](https://www.ruby-lang.org/) 编写的包（在 Ruby 中包被称为 gem），所以我们首先需要安装 Ruby 和一些其它的构建工具。

```shell
# 安装 Ruby 和其他的一些依赖
sudo apt-get install ruby-full build-essential zlib1g-dev
```

如果你不想以 root 用户安装 Ruby 的包，你最好在 Shell 配置文件中指定 Gems 的安装目录（bash 的配置文件是 `~/.bashrc`，zsh 的配置文件是 `~/.zshrc`）。

在配置文件里加入以下环境变量：

```shell
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
```

别忘了更新环境变量：

```shell
source ~/.bashrc
```

终于到安装 Jekyll 的时刻了，因为 Jekyll 是一个 RubyGem，所以我们可以用 `gem` 安装：

```shell
gem install jekyll bundler
```

> Note: 我们还安装了另一个 RubyGem，也就是 bundler，它可以保证你每次运行 Jekyll 的环境都是相同的，这也是推荐的做法。

## 2. 初始化

如果你选择的是 fork 其他人仓库的方式，那么你就可以跳过这一步，但还是推荐你亲手试试从无到有创建一个 Jekyll 网站的过程。

最简单的方法时使用 `jekyll` 命令来初始化网站目录，本文也是这么做的。

1. 创建并初始化网站目录 `./myblog`：

   ```shell
   jekyll new myblog
   ```

2. 打开新建的网站目录：

   ```shell
   cd myblog
   ```

3. 构建网站并试运行：

   ```shell
   bundle exec jekyll serve
   ```

   如果一切顺利的话，通过浏览器打开 <http://127.0.0.1:4000> 就可以看到 Jekyll 通过默认模板生成的网站了，你可以在这个网站上到处逛逛，看看 Jekyll 都生成了哪些页面，并在之后的学习中尝试修改这些页面，毕竟 Jekyll 是可以完全自定义的。

   ![Jekyll Default Site]({{ "/assets/images/jekyll-default-site.png" | absolute_url }})

   实际上这条命令会在当前目录下创建一个 `_site` 目录来存放生成的网站代码，然后在 <http://127.0.0.1:4000> 上运行，并且会在编辑博客的时候自动更新网站代码。

   > Hint: 如果你想要网页也实时刷新，可以为命令加上 `--livereload` 参数。

   如果你不需要一个运行的网页服务器，可以用 `bundle exec jekyll build`，这条命令只会生成网站代码而不会运行服务器。

   > Note: 如果你选择的是 fork 他人仓库来初始化，这一步可能会遇到“找不到依赖包”的错误，这可以通过 `bundle install` 来解决，这也是使用 `bundler` 的好处之一。


## 3. 写博客（Blogging）

博文默认存放在项目的 `_posts` 目录下，所以我们要做的就是打开这个目录，然后新建一篇博文：

```shell
cd _posts

# 新建一篇博文并写入“Hello Jekyll”
touch 2021-09-26-hello-jekyll.md
echo "Hello Jekyll" > 2021-09-26-hello-jekyll.md
```

注意这里的文件命名，Jekyll 要求每篇博文的名字必须符合 `YEAR-MONTH-DAY-title.MARKUP` 的规范，`YEAR` 必须是一个 4 位的数字，`MONTH` 和 `DAY` 则必须是 2 位的数字，`MARKUP` 就是博文源文件的扩展名。如果不这么命名，这篇博文就不会出现在最后的网页里。

然会我们需要返回项目的根目录，并运行 Jekyll 的网站服务：

```shell
cd ..
bundle exec jekyll serve
```

![Jekyll New Post]({{ "assets/images/jekyll-new-post.png" | absolute_url }})

Jekyll 的哲学之一是“内容为王”，意思就是博客的内容才是个人博客最重要的东西，也就是说现在你已经学会了 Jekyll 中最核心的功能——写博客了，只差最后一步——部署网站了！

## 4. 部署到 GitHub
___

在部署之前你需要按照提示修改 `Gemfile` 文件：  

```yml
# gem "jekyll", "~> 3.9.0"

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
gem "github-pages", group: :jekyll_plugins
```

先推送到一个现有的 `GitHub` 仓库，并且开启 `GitHub Pages`，选择网站的源目录，然后你的网站应该就能成功部署了。  

详细教程请看：[Creating a GitHub Pages site with Jekyll](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/creating-a-github-pages-site-with-jekyll#creating-your-site)

## 5. 更换主题
___

更换主题其实也十分简单，只需要在 `GitHub` 上选择就行，但如果配置不当可能会出现页面格式崩坏。所以最好还是先在本地更换，测试成功后再部署。

1. 指定主题（以 `hacker` 为例）

   1. 修改 `_config.yml` 中的 `theme` 项：  

      ```yml
      # 注释掉默认主题，再指定主题
      # theme minima
      theme jekyll-theme-hacker
      ```

   2. 添加 `jekyll-theme-hacker` 到 `Gemfile`:  

      ```bash
      echo 'gem "jekyll-theme-hacker"' >> Gemfile
      ```

2. 修改头信息

   因为 `hacker` 只包含 `default` 和 `post` 默认布局，而没有 `home` 和 `page` 默认布局，所以你需要修改引用了 `home` 的 `index.md` 和 引用了 `page` 的 `about.md` 的头信息：

   ```text
   ---
   # layout: page
   layout: default
   ---
   ```

3. 修改主页或编写布局

   由于 `hacker` 提供的布局不会自动生成一个包含所有 post 的主页，所以你需要自己编写布局文件，或重写主页文件 `index.html` 或 `index.md`（现在应该还是空的）。

   编写布局文件请参考 [Layouts](https://jekyllrb.com/docs/step-by-step/04-layouts/)  

   编写主页你可以参考 [Blogging](https://jekyllrb.com/docs/step-by-step/08-blogging/)  

   以下给出一个主页文件 `index.html` 的示例：  

   ```html
   ---
   layout: default
   title: Blog
   ---
   <h1>Latest Posts</h1>

   <ul>
   {% raw %}{% for post in site.posts %}
      <li>
      <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
      {{ post.excerpt }}
      </li>
   {% endfor %}{% endraw %}
   </ul>
   ```

   上述代码使用了 `Liquid` 模板，会生成一个包括了 `_posts` 目录下所有文章的静态页面。

4. 测试

   ```bash
   bundle exec jekyll serve
   ```

   > 提示：现在的 `jekyll` 支持热更新，你可以在启动服务后修改博客（不包括配置文件 `_config.yml`），刷新网页就可以看到修改内容。  

   如果报错按照错误信息操作即可，一切顺利的话，打开 <http://localhost:4000> 应该会看到以下界面：  

   ![网站截图]({{ "/assets/images/screenshoot.png" | absolute_url }})

5. 完善网站

   之后你就可以正常地添加文章和修改网站样式，不过在开始之前可以看看 `jekyll` 的官方教程 [Step by Step Tutorial](https://jekyllrb.com/docs/step-by-step/01-setup/)

<br>

## 6. 最佳实践
___

1. 在 `_config.yml` 中指定文件编码

   ```yml
   encoding: UTF-8
   ```

2. 在 `_config.yml` 中设置默认头信息

   ```yml
   defaults:
   -
      scope:
         path: ""    # 一个空的字符串代表项目里的所有文件
         type: "posts"   # 指定类型为 post
      values:
         layout: "my-site"
   -
      scope:
         path: "projects"  # 代表目录 projects/
         type: "pages" # 以前的 `page`， 在 Jekyll 2.2 里。
      values:
         layout: "project" # 覆盖之前的默认布局
         author: "Mr. Hyde"
   ```

3. 在头信息里自定义变量，然后就可以在 `Liquid` 模板中被调用

   下面的示例就用到了自定义的 `title` 变量：  

   ```html
   <!DOCTYPE HTML>
   <html>
      <head>
         <title>{{ page.title }}</title>
      </head>
      <body>
      ...
   ```

4. 使用 `post_url` 标签链接到其他博文，例如：

   ```md
   {% raw %}[Name of Link]({% post_url 2010-07-21-name-of-post %}){% endraw %}
   ```

5. 自定义摘要  

   `Jekyll` 会自动取每篇文章从开头到第一次出现 `excerpt_separator` 的地方作为文章的摘要，并将此内容保存到变量 `post.excerpt` 中。  
   如果你不喜欢自动生成摘要，你可以在文章的 `YAML` 头信息中增加 `excerpt` 来覆盖它。另外，你也可以选择在文章中自定义一个 `excerpt_separator`:  

   ```yml
   ---
   excerpt_separator: <!--more-->
   ---

   Excerpt
   <!--more-->
   Out-of-excerpt
   ```

6. 使用 `Liquid` 模板嵌入带行号的高亮代码

   ```ruby
   {% raw %}{% highlight ruby linenos %}
   def show
   @widget = Widget(params[:id])
   respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @widget }
   end
   end
   {% endhighlight %}{% endraw %}
   ```

7. 使用草稿

   草稿是你还在创作中而暂时不想发布的文章，可以不给草稿设置发布时间。想要开始使用草稿，你需要在网站根目录下创建一个名为 `_drafts` 的文件夹，并新建你的第一份草稿：  
   ```
   |-- _drafts/
   |   |-- a-draft-post.md
   ```
   为了预览你拥有草稿的网站，运行带有 `--drafts` 配置选项的 `jekyll serve` 或者 `jekyll build`。这两种方法都会将草稿的发布时间设置为草稿的修改时间，作为其发布日期，所以你将看到当前编辑的草稿文章作为最新文章被生成。  

8. 使用 `permalink` 自定义页面的 `URL`，例如：

   ```yml
   ---
   permalink: /about/
   ---
   ```

## 参考

- [Jekyll 的常用变量](http://jekyllcn.com/docs/variables/)

- [Creating a GitHub Pages site with Jekyll](https://docs.github.com/en/free-pro-team@latest/github/working-with-github-pages/creating-a-github-pages-site-with-jekyll#creating-your-site)

- [Ruby 101](https://jekyllrb.com/docs/ruby-101/)

- [使用 Jekyll 向 GitHub Pages 站点添加内容](https://docs.github.com/cn/free-pro-team@latest/github/working-with-github-pages/adding-content-to-your-github-pages-site-using-jekyll)

- [Step by Step Tutorial](https://jekyllrb.com/docs/step-by-step/01-setup/)

- [Error upon `bundle exec jekyll 3.8.7 new .` for GitHub Pages](https://talk.jekyllrb.com/t/error-upon-bundle-exec-jekyll-3-8-7-new-for-github-pages/4561)

- <https://jekyllrb.com/docs/liquid/tags>

- <https://jekyllrb.com/docs/permalinks/>