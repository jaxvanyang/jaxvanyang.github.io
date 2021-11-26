---
title:  "个性化 Jekyll 博客"
layout: post
date: '2021-11-24 00:54:13 +0800'
categories: draft test
---

> 个性化只能优化阅读体验，博客内容才是王道，所以本文的讨论范围仅限于替换网站主题和一些简单的个性化方式，不会深入 Jekyll 的个性化。

## TOC

- [更换主题](#更换主题)

- [自定义图标](#自定义图标)

- [添加折叠文本块功能](#添加折叠文本块功能)

- [ ] 添加主题切换功能

- [ ] 添加分类页面

- [ ] 添加评论

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


## 参考

- <https://pages.github.com/versions/>

- <https://jekyllrb.com/docs/themes/#installing-a-theme>

- <https://github.com/jekyll/minima>

- [Adding support for HTML5's details element to Jekyll](http://movb.de/jekyll-details-support.html)