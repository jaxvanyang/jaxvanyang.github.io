---
title: 我是如何重构博客的
---

## 1. 确定要实现的功能

- [x] 排除 `README.md`  

- [ ] 添加翻页功能  

- [ ] 添加分类  

    - [ ] 推荐阅读  

    - [ ] 环境配置  

    - [ ] 学习日记  

- [ ] 添加显示模式切换  

- [ ] 添加文章目录  

- [ ] 掌控布局  

    - [x] 消除网页开头的外边距  

- [x] 增加评论系统  

- [ ] 新页面  

    - [ ] 友链  

    - [ ] 自定义主页  

    - [ ] 安利  

    - [x] 关于  

- [ ] 添加 `jekyll-regex-replace` 插件  

## 要注意的地方

1. `page.url` 变量不包含域名，但是有一个前导斜杠，例如：`/2008/12/14/my-post.html`  

2. [Jekyll 的目录结构](https://jekyllrb.com/docs/structure/)，注意文件要分门别类  

3. 在主目录以 `,`、`_`、`#` 或 `~` 开头的文件或目录不会被复制到生成的目录里
，除非在配置文件里显式指定  

## 日志

1. Jekyll 存储的链接变量是不包含域名的，默认在域名内跳转：  

    ```html
    {% raw %}<!-- 源码 -->
    <a href="{{ item.link }}" {% if page.url == item.link %}class="current"{% endif %}>
        {{ item.name }}
    </a>
    <!-- localhost -->
    <a href="/test/" {% if page.url == /test/ %}class="current"{% endif %}>
        {{ item.name }}
    </a>
    <!-- GitHub Pages -->
    <a href="/test/" {% if jekyll-site/test/ == /test/ %}class="current"{% endif %}>
        {{ item.name }}
    </a>{% endraw %}
    ```

2. 删除了所有文章里显式指定布局的指令 `layout: post`  

3. 删除了所有文章里不必要的指定作者的指令 `author: Jax`  

4. 修改 `404.html` 的 `permalink` 会导致找不到页面时出现的不是 `404.html`  

5. 通过注释掉 `_sass/minima/_layout.scss` 中的 `border-top` 删除了网页顶端边界  

6. 将 `head.html` 格式化后无法引入生成的 `style.css`，原因是 VS Code 在路径前面插入了空格，Issue 详见：<https://github.com/microsoft/vscode/issues/43520>  
    使用单双引号混用可解决 `head.html` 中的问题  

7. 尝试使用 OneDrive 作为图床，但是 OneDrive 提供的图片背景不能透明  

8. 使用字符串切片让 `gitalk.id` 满足长度限制：  

    ```js
    id: location.pathname.slice(0, 49),      // Ensure uniqueness and length less than 50
    ```
    
    一般不用担心路径会重名  

9. 在头信息里使用 `[]` 会导致 YAML 解析错误  

10. Jekyll 不能识别 `type: "draft"`  

11. Markdown 的表格必须另起一行开始  