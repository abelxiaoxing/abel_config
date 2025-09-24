# Arch Linux 配置管理工具

## 功能特性

1. **模块化配置管理**: 提供多种配置好的统一快捷键工作环境（i3, hyprland）
2. **完整美化方案**: 清爽简介的界面美化配置
3. **智能脚本系统**: 自动化配置同步和环境安装
4. **双向同步功能**: 支持配置文件的双向同步，便于备份和恢复
5. **交互式操作**: 提供数字菜单界面，操作简单直观

## 快速开始

### 1. 下载配置仓库

```bash
git clone https://github.com/abelxiaoxing/archlinux_config.git ~/.config/archlinux_config
cd ~/.config/archlinux_config
```

### 2. 运行配置管理工具

```bash
./autoinstall.sh
```

## 使用说明

### 主菜单选项

```
==========================================
    Arch Linux 配置管理工具 v2.0
==========================================

1. 同步配置到系统
2. 同步系统配置到项目
3. 环境安装
4. 更新镜像源
0. 退出
==========================================
```

#### 功能详解

1. **同步配置到系统**: 将项目中的配置文件同步到系统对应位置
2. **同步系统配置到项目**: 将系统中的配置文件同步回项目，便于备份
3. **环境安装**: 自动更新镜像源并安装所有必要的软件包
4. **更新镜像源**: 仅更新系统镜像源为国内源

### 支持的配置文件

#### .config 目录配置
- `autotiling` - 平铺桌面智能分割窗口
- `dunst` - 通知系统
- `fcitx5` - 中文输入法
- `foot` - Wayland 终端
- `hypr` - Hyprland 窗口管理器
- `i3` - i3 窗口管理器
- `polybar` - 状态栏
- `rofi` - 程序启动器
- `waybar` - Wayland 状态栏
- `wezterm` - 终端模拟器
- `wlogout` - 注销菜单
- `wofi` - Wayland 程序启动器
- `ZshPlugins` - Zsh 插件
- `system_scripts` - 系统脚本

#### 用户配置文件
- `zshrc` - Zsh 配置文件

#### 系统配置文件
- `pacman.conf` - 包管理器配置
- `paru.conf` - AUR 助手配置

#### 单向同步文件
- `backgrounds` - 壁纸文件（仅同步到系统）

## 快捷键查看

### i3 窗口管理器
配置文件位置: `~/.config/i3/config/config`

### Hyprland 窗口管理器
配置文件位置: `~/.config/hypr/hyprland.conf`

## 高级配置

### 输入法配置
在环境变量配置文件 `/etc/environment` 中添加：

```bash
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
```

### 主题与界面配置

#### Kvantum 环境配置
```bash
paru -S kvantum-theme-arc
```
然后打开 Kvantum，应用 arc-dark 主题

#### 解决 Dolphin 等界面问题
修改 `/etc/profile` 文件：
```bash
sudo nvim /etc/profile
```
添加以下内容：
```bash
export QT_STYLE_OVERRIDE=kvantum
```

## 文件结构

```
archlinux_config/
├── autoinstall.sh          # 主脚本，提供交互式菜单
├── config.sh             # 配置文件，定义路径和包列表
├── functions.sh          # 函数库，包含核心功能
├── zshrc               # Zsh 配置文件
├── pacman.conf          # Pacman 配置文件
├── paru.conf           # Paru 配置文件
├── backgrounds/         # 壁纸文件
├── system_scripts/      # 系统脚本
├── ZshPlugins/         # Zsh 插件
├── autotiling/         # Autotiling 配置
├── dunst/             # 通知系统配置
├── fcitx5/            # 输入法配置
├── foot/              # Foot 终端配置
├── hypr/              # Hyprland 配置
├── i3/                # i3 配置
├── polybar/           # Polybar 配置
├── rofi/              # Rofi 配置
├── waybar/            # Waybar 配置
├── wezterm/           # Wezterm 配置
├── wlogout/           # Wlogout 配置
└── wofi/              # Wofi 配置
```

## 注意事项

1. **权限要求**: 某些操作需要 sudo 权限，请确保有管理员权限
2. **网络要求**: 环境安装需要网络连接，建议配置好代理或使用国内镜像源
3. **备份建议**: 在执行大规模配置同步前，建议备份重要数据
4. **依赖检查**: 确保系统已安装基础的开发工具和 git

## 更新日志

### v0.0.2
- 重构为模块化架构
- 添加交互式菜单界面
- 实现双向同步功能
- 分离配置同步和环境安装
- 优化错误处理和日志记录

