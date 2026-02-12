# Arch Linux 配置管理工具

## 功能特性

1. **模块化配置管理**: 提供多种配置好的统一快捷键工作环境（i3, hyprland）
2. **完整美化方案**: 清爽简介的界面美化配置
3. **智能脚本系统**: 自动化配置同步和环境安装
4. **用户配置由 chezmoi 管理**: dotfiles 统一用 chezmoi apply/add，同步更可靠
5. **交互式操作**: 提供数字菜单界面，操作简单直观

## 快速开始

### 1. 下载配置仓库

```bash
git clone https://github.com/abelxiaoxing/abel_config.git ~/.config/archlinux_config
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
    Arch Linux 配置管理工具 v3.0
==========================================

1. 同步配置到系统
2. 同步系统配置到项目
3. 环境安装
4. 更新镜像源
5. 一键部署（换源+安装+同步）
0. 退出
==========================================
```

#### 功能详解

1. **同步配置到系统**: 仅对有差异的内容提供 diff/overwrite/all-overwrite/skip/quit 确认后再写入系统
2. **同步系统配置到项目**: 仅对有差异的用户配置提供 diff/overwrite/all-overwrite/skip/quit 交互提示
3. **环境安装**: 自动更新镜像源并安装所有必要的软件包（失败会汇总提示）
4. **更新镜像源**: 更新系统镜像源为国内源（会备份原文件）
5. **一键部署**: 换源 + 安装软件包 + 同步配置到系统

### 支持的配置文件

#### 用户配置（chezmoi 管理）
> 源文件位于 `./chezmoi/`，应用到系统时写入 `~/.config/...` 和 `~/.zshrc` 等位置

##### .config 目录配置
- `autotiling` - 平铺桌面智能分割窗口
- `dunst` - 通知系统
- `fcitx5` - 中文输入法
- `foot` - Wayland 终端
- `hypr` - Hyprland 窗口管理器
- `i3` - i3 窗口管理器
- `nvim` - neovim配置文件
- `opencode` - opencode配置文件
- `polybar` - 状态栏
- `rofi` - 程序启动器
- `waybar` - Wayland 状态栏
- `wezterm` - 终端模拟器
- `wlogout` - 注销菜单
- `wofi` - Wayland 程序启动器
- `ZshPlugins` - Zsh 插件
- `system_scripts` - 系统脚本

##### 用户配置文件
- `~/.zshrc` - Zsh 配置文件

#### 系统配置（脚本管理，需要 sudo）
- `pacman.conf` - 包管理器配置
- `paru.conf` - AUR 助手配置

#### 单向同步文件（脚本管理，需要 sudo）
- `backgrounds` - 壁纸文件（同步到 `/usr/share/backgrounds`）

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
├── pacman.conf          # Pacman 配置文件
├── paru.conf           # Paru 配置文件
├── backgrounds/         # 壁纸文件
└── chezmoi/             # 用户配置（chezmoi 源）
    ├── dot_zshrc
    └── dot_config/
        ├── autotiling/
        ├── dunst/
        ├── fcitx5/
        ├── foot/
        ├── hypr/
        ├── i3/
        ├── nvim/
        ├── opencode/
        ├── polybar/
        ├── rofi/
        ├── system_scripts/
        ├── waybar/
        ├── wezterm/
        ├── wlogout/
        ├── ZshPlugins/
        └── wofi/
```

## 注意事项

1. **权限要求**: 某些操作需要 sudo 权限，请确保有管理员权限
2. **网络要求**: 环境安装需要网络连接，建议配置好代理或使用国内镜像源
3. **备份建议**: 脚本在覆盖 `/etc` 相关文件前会自动创建时间戳备份（形如 `*.bak-YYYYmmddHHMMSS`），但仍建议在大规模同步前自行备份重要数据
4. **依赖检查**: 确保系统已安装基础的开发工具和 git

## 维护与自检

```bash
# 脚本语法检查
bash -n autoinstall.sh config.sh functions.sh

# 若已安装 shellcheck，可进行静态检查
shellcheck autoinstall.sh config.sh functions.sh

# 预览/应用用户配置（chezmoi）
chezmoi --source ./chezmoi diff
chezmoi --source ./chezmoi apply
```

## 更新日志

### v0.0.2
- 重构为模块化架构
- 添加交互式菜单界面
- 实现双向同步功能
- 分离配置同步和环境安装
- 优化错误处理和日志记录
