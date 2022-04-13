---
title: 个性化 Jekyll 博客
layout: post
date: '2021-11-24 00:54:13 +0800'
modified_date: '2022-04-13'
banner:
  video: https://vjs.zencdn.net/v/oceans.mp4
  loop: true
  volume: 0.8
  start_at: 8.5
  image: https://bit.ly/3xTmdUP
  opacity: 0.618
  background: "#000"
  height: "100vh"
  min_height: "38vh"
  heading_style: "font-size: 4.25em; font-weight: bold; text-decoration: underline"
  subheading_style: "color: gold"
categories:
- jekyll
- personalize
---

> 个性化只能优化阅读体验，博客内容才是王道，所以本文的讨论范围仅限于替换网站主题和一些简单的个性化方式，不会深入 Jekyll 的个性化。

## TOC

- [更换主题](#更换主题)

- [自定义图标](#自定义图标)

- [添加折叠文本块功能](#添加折叠文本块功能)

- [使用 GitHub Actions 持续集成](#使用-github-actions-持续集成)

- [配置 LaTex](#配置-latex)

- [添加评论](#添加评论)

- [ ] 添加代码一键复制功能

- [参考](#参考)

## 更换主题

更换 Jekyll 网站的主题有两种方式：一种是直接在网站工作目录下编辑布局文件；另一种是导入基于 `gem` 的主题。

导入 `gem` 主题的方式又分为两种：一种以 `gem` 插件的形式在 `Gemfile` 中引入，再在 `_config.yml` 中以 `theme` 指定发布在 [RubyGems](https://rubygems.org/) 上的主题；另一种通过 `jekyll-remote-theme` 插件引入托管在 [GitHub](https://github.com/topics/jekyll-theme) 上的主题。

一般推荐使用引入 `gem` 主题的方式，因为 `gem` 主题的更新更灵活，而且也能在此基础上进行修改。Jekyll 默认以 `gem` 插件的形式导入主题，但是 [RubyGems](https://rubygems.org/) 上的主题有限并且更新并不是很及时，所以本文使用 `jekyll-remote-theme` 插件引入托管在 [GitHub](https://github.com/topics/jekyll-theme) 上的主题。

更换主题需要修改 2 个文件：`Gemfile` 和 `_config.yml`。我们需要先在 `Gemfile` 中引入 `jekyll-remote-theme` 插件，然后在 `_config.yml` 中指定主题。

- 修改前：

  `Gemfile`:

  ```ruby
  gem "minima", "~> 2.5.1"
  ```

  `_config.yml`:

  ```yaml
  theme: minima
  ```

- 修改后：

  `Gemfile`:

  ```ruby
  group :jekyll_plugins do
      gem "jekyll-remote-theme"
      gem "jekyll-seo-tag", "~> 2.7.1"
  end
  ```

  `_config.yml`:

  ```yaml
  remote_theme: jaxvanyang/minima
  ```

上述修改将 Jekyll 默认的 `Minima` 主题替换为了托管在 Github 上的 [jaxvanyang/minima](https://github.com/jaxvanyang/minima)，实际上是更新了 `Minima` 主题的版本，因为在 RubyGems 上 `Minima` 的最新版本是 `2.5.1`，而在 GitHub 上已经更新到了 `3.0` 以上，但是不知道为什么没有创建新的 release。顺带一提，上面用到的主题地址是我 fork 原仓库 [jekyll/minima](https://github.com/jekyll/minima) 的地址，这样做的原因是方便我以后修改主题。

修改之后需要更新依赖，执行 `bundle update` 即可，如果碰到错误，可以先尝试删除 `Gemfile.lock` 文件，再执行 `bundle update`，如果还是不行，可能是因为缺乏依赖的原因，在 `Gemfile` 中加入缺少的依赖再执行 `bundle update`。

需要注意的是，更换主题后，网站的一些配置可能会发生变化，比如 `Minima-3.0` 就修改了社交网络的配置方式：

> From `Minima-3.0` onwards, the usernames are to be nested under `minima.social_links`.

所以更换主题时最好过一遍主题的帮助文档。

## 自定义图标

> 这是使用 `Minima` 主题自定义图标的方式，其他主题的自定义方式与之类似，根本原理就是在网页的 `<head>` 标签内指定网站图标。

如果你浏览过 `Minima` 主题的 `_includes/` 文件夹，那你就会发现一个叫 `custom-head.html` 的文件：

```html
{% raw %}{% comment %}
  Placeholder to allow defining custom head, in principle, you can add anything here, e.g. favicons:

  1. Head over to https://realfavicongenerator.net/ to add your own favicons.
  2. Customize default _includes/custom-head.html in your source directory and insert the given code snippet.
{% endcomment %}{% endraw %}
```

> 有热心网友推荐 <https://www.websiteplanet.com/zh-hans/webtools/favicon-generator/>，这也是一个网页图标生成工具，而且包含中文， 可以试一试。

翻译一下就是说，这个文件就是用来自定义网站的 `<head>` 标签的，比如你可以在这里添加你的*网站图标*：

1. 先到 <https://realfavicongenerator.net/> 生成图标。

2. 然后在你网站的 `_includes/` 文件夹下的 `custom-head.html` 文件中添加生成的代码片段。

注意这里是修改你网站的源文件而不是修改主题的源文件，因为主题可以应用到不同网站，而不同网站的图标可能是不同的。

<https://realfavicongenerator.net/> 这个网站可以生成适配各个平台的图标，而且也有很多自定义选项，建议都试一试。

![Favicon Generator. For real.]({{ "/assets/images/real-favicon-generator-screenshot.png" | absolute_url }})

如果你不能把图标文件放到网站的根目录，可以在下面这个选项里指定图标的位置：

![Favicon Generator Options]({{ "/assets/images/favicon-generator-options-screenshot.png" | absolute_url }})

点击 `Generate your Favicons and HTML code` 按钮后就会得到一个图标包和相应的 `HTML` 代码：

![Install your favicon]({{ "/assets/images/install-favicon-screenshot.png" | absolute_url }})

按照提示填入网站源文件下的 `_includes/custom-head.html`（没有就新建一个）：

```html
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="manifest" href="/site.webmanifest">
<link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">
<meta name="msapplication-TileColor" content="#da532c">
<meta name="theme-color" content="#ffffff">
```

## 添加折叠文本块功能

> 本节方法来自 [Adding support for HTML5's details element to Jekyll](http://movb.de/jekyll-details-support.html)。

这个方法的原理是将要折叠的内容放到 [`<details>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/details) 标签里，为了方便我们插入，我们需要添加插件来定义一个 [Liquid](https://jekyllrb.com/docs/liquid/) Tag，为了做到这点，我们只需要在新建一个在 `_plugins/` 文件夹下新建一个 `details_tag.rb` 文件，并在其中添加如下代码：

```ruby
module Jekyll
    module Tags
      class DetailsTag < Liquid::Block
  
        def initialize(tag_name, markup, tokens)
          super
          @caption = markup
        end
  
        def render(context)
          site = context.registers[:site]
          converter = site.find_converter_instance(::Jekyll::Converters::Markdown)
          # below Jekyll 3.x use this:
          # converter = site.getConverterImpl(::Jekyll::Converters::Markdown)
          caption = converter.convert(@caption).gsub(/<\/?p[^>]*>/, '').chomp
          body = converter.convert(super(context))
          "<details><summary>#{caption}</summary>#{body}</details>"
        end
  
      end
    end
  end
  
Liquid::Template.register_tag('details', Jekyll::Tags::DetailsTag)
```

然后我们就可以使用 `{% raw %}{% details %}{% endraw %}` 标签来折叠内容了：

~~~markdown
{% raw %}{% details 示例%}
#### 这是一个折叠块的示例

```python
print("Hello World!")
```
{% enddetails %}{% endraw %}
~~~

{% details 示例%}
#### 这是一个折叠块的示例

```python
print("Hello World!")
```
{% enddetails %}

`<details>` 是 HTML5 新增的标签，有些浏览器可能不支持，如果你需要为过时的浏览器提供支持，可以在原文的 [Polyfill](http://movb.de/jekyll-details-support.html#polyfill) 找到解决方案。

还可以使用自定义 SCSS 美化折叠块，我使用的是 `Minima` 主题，添加自定义样式只需要在 `_sass/minima/custom-styles.scss` 添加内容即可，我这里就简单地修改了一下原文提供的样式代码：

```scss
// _sass/minima/custom-styles.scss
details {
    summary {
        color: teal;
        &::before {
            font-family: FontAwesome;
            font-size: 1.2em;
            float: left;
            margin-right: 0.4em;
        }
        &::-webkit-details-marker {
            display: none;
        }
        margin-bottom: 0.8em;
    }
    color: grey;
}
```

## 使用 GitHub Actions 持续集成

> 详细教程参见 <https://jekyllrb.com/docs/continuous-integration/github-actions/>

之前我使用的部署方式是最简单的 GitHub Pages 标准方式，但是标准方式有许多安全限制，构建网站的 Jekyll 版本不是最新的，很多插件也不能用，比如前面我们定义的 `{% raw %}{% details %}{% endraw %}` 标签就用不了，为了解决这个问题我们可以现在本地构建，再把网站代码推送上去，但是这样会使用额外的仓库空间，并且每次还需要手动构建，为了偷懒我们可以使用 GitHub Actions 来自动部署，而且这也是推荐的网站发布方式。

1. 先在仓库中新建一个 `.github/workflows/github-pages.yml` 文件，内容如下：

   ```yaml
   name: Build and deploy Jekyll site to GitHub Pages
 
   on:
     push:
       branches:
         - main
 
   jobs:
     github-pages:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v2
         - uses: helaili/jekyll-action@v2
           with:
           token: ${% raw %}{{ secrets.DEPLOY_TOKEN }}{% endraw %}
   ```

    > Note: [原教程](https://jekyllrb.com/docs/continuous-integration/github-actions/) 里使用的 `token` 名为 `GITHUB_TOKEN`，但是现在 GitHub 规定不能生成以 `GITHUB` 开头的 `secrets`，所以我改成了 `DEPLOY_TOKEN`。

2. 再到 GitHub 的 [Personal Access Tokens](https://github.com/settings/tokens) 生成一个勾选了 `public_repos` 权限的 `token`，复制这个 `token` 的值，然后到 GitHub 上仓库的 **Settings** 选项选择 **Secrets** 标签，添加一个名为 `DEPLOY_TOKEN` 的 **repository secret** 并填入之前复制的 `token`。

3. 配置好了就在本地提交修改并推送到 GitHub 的 `main` 分支，这样 GitHub Actions 就会自动构建，但是这个过程有一点点慢，需要耐心等待。

4. 部署情况可以在 GitHub 上查看，如果构建成功的话，GitHub Actions 会自动创建一个 `gh-pages` 分支，这个操作会覆盖原有的 `gh-pages` 分支，所以不要在仓库里手动修改这个分支。

    最后你需要将仓库的 **Pages** 设置页里的 **Source** 改成 `gh-pages` 分支的根目录，这样 GitHub 就会自动部署构建好的网站了。

![GitHub Pages Source]({{ "/assets/images/github-pages-source-screenshot.png" | absolute_url }})

## 配置 LaTex

> Note: 现在我使用的是 [Jekyll Spaceship](https://github.com/jeffreytse/jekyll-spaceship) 的 `mathjax-processor`，有一点问题，但是在它的 Issues 页面可以找到大部分解决办法。

Jekyll 默认的 Markdown 渲染器是 Kramdown，Kramdown 默认的公式渲染器是 MathJax，所以理论上 Jekyll 默认可以渲染 LaTex，事实也确实如此，但是它只做了从 Markdown 到 HTML 的转换，并没有添加样式，所以我们还需要额外引入 MathJax 库并启动它。

MathJax 的官方文档提供多种配置方法，我觉得比较好的是[这一种](https://jekyllrb.com/docs/configuration/markdown/)，应用到 Jekyll 网站上的过程大致如下：

1. 创建一个 `loda-mathjax.js` 脚本，内容如下：

   ```js
   window.MathJax = {
     tex: {
       inlineMath: [['$', '$'], ['\\(', '\\)']]
     },
     svg: {
       fontCache: 'global'
     }
   };
 
   (function () {
     var script = document.createElement('script');
     script.src = 'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js';
     script.async = true;
     document.head.appendChild(script);
   })();
   ```

2. 在网站的 `<head>` 标签内引入上述脚本，方法和[更换主题](#-更换主题)一节中的方法一样，因为我把脚本放在 `assets/js/load-mathjax.js`，所以我需要在 `_includes/custom-head.html` 里加入：

   ```html
   <script src="/assets/js/load-mathjax.js" async></script>
   ```

   然后就可以开始编写公式了。

   - 行内公式：

     - 公式：

       ```markdown
       $E = mc^2$
       ```

     - 渲染效果：

       $E = mc^2$

   - 公式块：

     - 公式：

       ```markdown
       $$
       \begin{bmatrix}
       1 & 2 & 3\\
       a & b & c
       \end{bmatrix}
       $$
       ```

     - 渲染效果：

       $$
       \begin{bmatrix} 1 & 2 & 3 \\ a & b & c \end{bmatrix}
       $$

## 添加评论

博客的评论工具我本来想用 [Gitalk](https://github.com/gitalk/gitalk)，因为它免费、美观而且易于配置，还是国人开发的。但是也有缺点，因为它使用 GitHub 的 Issues 存储评论，所以必须使用 GitHub 登录才能评论，不能匿名评论。
 
另外还有很多人质疑它的安全性，因为使用 Gitalk 登录它会要求获取你的 GitHub 公共仓库的读写权限：

![Gitalk grant]({{ '/assets/images/gitalk-grant.png' | absolute_url }})

已经有很多人在 Issues 页讨论了这个问题：

- <https://github.com/gitalk/gitalk/issues/95>

- <https://github.com/gitalk/gitalk/issues/150#issuecomment-402366588>

理论上来说只要博客所有者不利用访客授予的权限就没有问题，但是我在查阅 Gitalk 安全性资料的时候看到了这篇[博客](https://lookingaf.com/2021/11/16/somethings_aboout_blog/)，作者介绍了一些第三方评论插件，[utterances](https://utteranc.es/) 是作者最后选择的比 Gitalk 更安全的替代品，所以我也选择了它。

`utterances` 的配置也十分简单，它的网站也很有意思，是一个交互式的[教程](https://utteranc.es/)，一路看下来你就能学会如何配置。

重要的是新建的一个公开仓库用于存放评论，并安装 [utterances app](https://github.com/apps/utterances) 到这个仓库，最后在上述教程页面得到一段类似于下面的嵌入代码：

```html
<script src="https://utteranc.es/client.js"
        repo="jaxvanyang/utteranc.blog"
        issue-term="pathname"
        label="💬comment"
        theme="preferred-color-scheme"
        crossorigin="anonymous"
        async>
</script>
```

然后只要放到你的博客模板中合适的位置就可以了，对于 `Jekyll` 来说这个位置是 `/_layouts/post.html`。

## 参考

- <https://pages.github.com/versions/>

- <https://jekyllrb.com/docs/themes/#installing-a-theme>

- <https://github.com/jekyll/minima>

- [Adding support for HTML5's details element to Jekyll](http://movb.de/jekyll-details-support.html)

- <https://jekyllrb.com/docs/continuous-integration/github-actions/>

- <https://jekyllrb.com/docs/configuration/markdown/>

- <https://kramdown.gettalong.org/math_engine/mathjax.html>

- <http://docs.mathjax.org/en/latest/web/configuration.html#configuring-and-loading-in-one-script>

- <https://github.com/jekyll/minima/blob/master/_layouts/post.html>

- [搭建个人博客的二三事](https://lookingaf.com/2021/11/16/somethings_aboout_blog)

- [GitHub 风格的 Markdown 规范](http://gfm.docschina.org/zh-hans/)