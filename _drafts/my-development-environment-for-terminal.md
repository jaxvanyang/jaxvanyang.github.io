---
title: title
category: configuration
tags:
- terminal
- development environment
- cli
- best practice
---

# 我的终端环境配置

> Tested on Arch Linux & Ubuntu 22.04.

> TODO: write a more comprehensive description.

一些配置可以在我的 [dotfiles 仓库](https://github.com/JaxVanYang/dotfiles)找到，里面还有自动配置脚本哦。

## 更换镜像源

为了后面的配置能顺利进行，最好先搭梯子，和[更换镜像源](https://jaxyoung.notion.site/fd8211572955458f9010e89fd03239ed)。

## Windows Terminal

先更新到最新版，在设置中设置 WT 为默认终端程序。

我之前使用 Oh My Zsh 默认主题的时候用的是 Cai 配色，看了[这个 Youtube 视频](https://youtu.be/CF1tMjvHDRA)我改成了和他一样的 Cool Night 配色，另外本配置的大部分也都是来自这个视频。

下面是这两种配色对应的 WT 配置，可以打开 WT JSON 配置文件编辑：

```json
{
  "background": "#09111A",
  "black": "#000000",
  "blue": "#274DCA",
  "brightBlack": "#808080",
  "brightBlue": "#8DA3E9",
  "brightCyan": "#8DE9D4",
  "brightGreen": "#A3E98D",
  "brightPurple": "#D48DE9",
  "brightRed": "#E98DA3",
  "brightWhite": "#FFFFFF",
  "brightYellow": "#E9D48D",
  "cursorColor": "#D9E6F2",
  "cyan": "#27CAA4",
  "foreground": "#D9E6F2",
  "green": "#4DCA27",
  "name": "Cai",
  "purple": "#A427CA",
  "red": "#CA274D",
  "selectionBackground": "#FFFFFF",
  "white": "#808080",
  "yellow": "#CAA427"
},
{
  "background": "#010C18",
  "black": "#0B3B61",
  "blue": "#1376F9",
  "brightBlack": "#63686D",
  "brightBlue": "#388EFF",
  "brightCyan": "#FF6AD7",
  "brightGreen": "#74FFD8",
  "brightPurple": "#AE81FF",
  "brightRed": "#FF54B0",
  "brightWhite": "#60FBBF",
  "brightYellow": "#FCF5AE",
  "cursorColor": "#38FF9D",
  "cyan": "#FF5ED4",
  "foreground": "#ECDEF4",
  "green": "#52FFD0",
  "name": "Cool Night",
  "purple": "#C792EA",
  "red": "#FF3A3A",
  "selectionBackground": "#38FF9C",
  "white": "#16FDA2",
  "yellow": "#FFF383"
},
```

字体使用 Cascadia Code，背景不透明度改为 90%。

添加新配置文件，设置启动命令行为 ssh user@your.server 登录服务器，达到打开 WT 就直接登录服务器的效果。

> TODO: add a picture

## WSL

设置主机名 → 去 Windows 设置里去设置。

## Oh My Zsh

安装 [Oh My Zsh](https://ohmyz.sh/)：

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

[使用 LDAP 登录的普通用户无法自己更换登录 shell](https://askubuntu.com/a/632301)，可以在 ~/.bashrc 中使用 exec zsh 来 hack：

```bash
if [ "$SHELL" = /bin/bash ]; then
    export SHELL=/bin/zsh
    exec zsh
fi
```

安装 [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)：

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

安装 [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)（注意：该插件需要放在插件列表的最后）：

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

~~安装~~  [zsh-z](https://github.com/agkozak/zsh-z)，Zsh-z 现在已经内置于 Oh-My-Zsh，只需要在插件列表中用 z 启用即可。

除了安装别人的插件，也可以编写自己的插件，为了方便管理我的 alias，我写了一个 my-alias 插件（$ZSH/custom/plugins/my-alias/my-alias-plugin.zsh）：

```bash
# My alias
alias v=nvim
alias py=python3
alias gc1="git clone --depth=1"
```

在 ~/.zshrc 中启用安装的插件：

```bash
plugins=(
  git
  zsh-autosuggestions
  z
  my-alias
  zsh-syntax-highlighting
)
```

最后 source ~/.zshrc，all done！

效果图：

> TODO: add picture

## TLDR

[Tealdeer](https://dbrgn.github.io/tealdeer/intro.html) 是一个使用 Rust 的 [tldr](https://github.com/tldr-pages/tldr) 实现，它比原版更快，还可以独立安装，原版需要使用 pip 安装。

安装 Tealdeer：

```bash
wget https://github.com/dbrgn/tealdeer/releases/download/v1.6.1/tealdeer-linux-x86_64-musl
mkdir -p ~/.local/bin
mv tealdeer-linux-x86_64-musl ~/.local/bin/tldr
chmod u+x ~/.local/bin/tldr
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
tldr --update
```

## Neovim

> TODO: rewrite this section

因为没有 sudo 权限，安装编译依赖也不方便，暂时先使用 tarball 安装（也可以使用 AppImage）：

```bash
wget https://github.com/neovim/neovim/releases/download/v0.8.0/nvim-linux64.tar.gz
tar xzvf nvim-linux64.tar.gz -C ~/opt
echo 'export PATH="$HOME/opt/nvim-linux64/bin:$PATH"' >> ~/.zshrc
```

设置 nvim 为默认编辑器（~/.zshrc）：

```bash
export VISUAL="nvim"
export EDITOR="nvim"
```

Neovim 的配置文件目录为 ~/.config/nvim/，我的配置目录结构为：

```bash
.
├── init.lua
└── lua
    ├── mappings.lua
    └── settings.lua

1 directory, 3 files
```

settings.lua：

```lua
HOME = os.getenv('HOME')

-- Basic Settings
vim.opt.number = true
vim.opt.wrap = false
vim.opt.showmatch = true
vim.opt.synmaxcol = 300 -- stop syntax highlighting after n lines for performance
vim.opt.laststatus = 2  -- always show status line
vim.opt.foldenable = false
vim.opt.foldlevel = 4
vim.opt.foldmethod = 'syntax'   -- use language syntax to generate folds
vim.opt.showcmd = true  -- display command in bottom bar
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.cursorline = true

-- Search
vim.opt.incsearch = true        -- start searching as soon as typing without enter needed
vim.opt.ignorecase = true       -- ignore case when searching
vim.opt.smartcase = true        -- case insentive unless capitals used in search

-- Format
vim.opt.cindent = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 2     -- 1 tab = 2 spaces
vim.opt.shiftwidth = 2  -- indentation rule
```

安装插件管理器 packer.nvim：

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

- LSP

## Tmux

Ubuntu 仓库里的 tmux 版本太旧了，我的 config 很多都识别不了，只能自己下载 AppImage 了：

```bash
wget https://github.com/nelsonenzo/tmux-appimage/releases/download/latest/tmux.appimage
```

直接 copy 了以前配的 tmux.config 到 ~/.config/tmux/：

```bash
set -g default-terminal "tmux-256color"

# Toggle mouse
bind-key m set-option -g mouse \; display "Mouse: #{?mouse,ON,OFF}"

# Remap prefix to 'C-a' (use C-a C-a to go to the beginning of line)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file
bind r source-file ~/.config/tmux/tmux.conf

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable mouse control
set -g mouse on

# Neovim advice (:checkhealth)
set-option -sg escape-time 10   # set escape-time to 10ms
set-option -g focus-events on   # for nvim 'autoread' to work
set-option -sa terminal-overrides ',xterm-256color:RGB' # use $TERM to support true colors

##################
### TMUX STYLE ###
##################

# loud or quiet?
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none

# modes
# setw -g clock-mode-colour colour5
# setw -g mode-style 'fg=colour1 bg=colour18 bold'

# panes
# set -g pane-border-style 'fg=colour19 bg=colour0'
# set -g pane-active-border-style 'bg=colour0 fg=colour9'

# statusbar
set -g status-position bottom
set -g status-justify left
# set -g status-style 'fg=colour137 bg=colour18 dim'
set -g status-left ''
set -g status-right '%m/%d %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20
```

## n

[tj/n: Node version management (github.com)](https://github.com/tj/n)

下载源码并安装 n 到用户目录：

```bash
git clone --depth=1 https://github.com/tj/n.git
cd n
PREFIX="$HOME/opt/n" make install
```

n 默认会将 Node.js 安装到 /usr/local，如果没有 sudo 权限可以设置 N_PREFIX 环境变量：

```bash
export N_PREFIX="$HOME/opt/n"
export PATH="$N_PREFIX/bin:$PATH"
```

安装 Node.js：

```bash
# 安装 LTS 版本（18.*.*）
n lts
# 安装 v16.0.0
n 16.0.0
```

## Pip

应该始终用 `pip install --user` 来安装 Pip 包，参见 **[Python Packaging User Guide](https://packaging.python.org/) 来查看官方的最佳实践。**

## 小玩具

[Neofetch](https://github.com/dylanaraps/neofetch)

> TODO: add picture

## References

- [Installing Neovim · neovim/neovim Wiki · GitHub](https://github.com/neovim/neovim/wiki/Installing-Neovim#install-from-download)
- [Installing - Tealdeer User Manual (dbrgn.github.io)](https://dbrgn.github.io/tealdeer/installing.html)
- [The Missing Semester of Your CS Education · the missing semester of your cs education (mit.edu)](https://missing.csail.mit.edu/)
- [wbthomason/packer.nvim: A use-package inspired plugin manager for Neovim. Uses native packages, supports Luarocks dependencies, written in Lua, allows for expressive config (github.com)](https://github.com/wbthomason/packer.nvim#quickstart)