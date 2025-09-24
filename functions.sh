#!/bin/bash
# 功能函数库

# 镜像源更新函数
update_mirrorlist() {
  local mirrorlist="/etc/pacman.d/mirrorlist"
  local aliyun="Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
  local tsinghua="Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"

  log_message "开始更新镜像源..."

  # 检查镜像源文件是否存在
  if [ ! -f "$mirrorlist" ]; then
    echo "$aliyun" | sudo tee "$mirrorlist" >/dev/null
    echo "$tsinghua" | sudo tee -a "$mirrorlist" >/dev/null
    log_message "镜像源文件已创建"
    return
  fi

  # 检查是否已包含阿里云镜像源
  if ! sudo grep -q "^$aliyun" "$mirrorlist"; then
    # 创建临时文件
    local temp_file=$(mktemp)

    # 添加阿里云镜像源到顶部
    echo "$aliyun" >"$temp_file"

    # 添加清华镜像源到顶部
    echo "$tsinghua" >>"$temp_file"

    # 添加空行分隔
    echo "" >>"$temp_file"

    # 添加原有内容
    sudo cat "$mirrorlist" >>"$temp_file"

    # 替换原文件
    sudo mv "$temp_file" "$mirrorlist"
    sudo chmod 644 "$mirrorlist"
    log_message "镜像源已更新"
  else
    log_message "镜像源已包含所需源，跳过更新"
  fi
}

# 同步配置到系统
sync_config_to_system() {
  log_message "开始同步配置到系统..."

  # 同步 .config 目录
  for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "./$dir" ]; then
      echo "正在同步 $dir 配置..."
      mkdir -p "$HOME/.config/$dir"
      cp -rf "./$dir"/* "$HOME/.config/$dir/" && log_message "$dir 配置同步成功" || handle_error "$dir 配置同步失败"
    fi
  done

  # 同步用户配置文件
  sync_user_config_to_system

  # 同步系统配置文件
  sync_system_config_to_system

  # 同步单向文件
  sync_one_way_to_system

  echo "配置同步完成！"
}

# 同步系统配置到项目
sync_system_to_project() {
  log_message "开始同步系统配置到项目..."

  # 同步 .config 目录
  for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
      echo "正在同步 $dir 配置到项目..."
      mkdir -p "./$dir"
      cp -rf "$HOME/.config/$dir"/* "./$dir/" && log_message "$dir 配置同步到项目成功" || handle_error "$dir 配置同步到项目失败"
    fi
  done

  # 同步用户配置文件
  sync_user_config_to_project

  # 同步系统配置文件
  sync_system_config_to_project

  echo "系统配置同步到项目完成！"
}

# 同步用户配置文件到系统
sync_user_config_to_system() {
  for config in "${USER_CONFIG_FILES[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"
    if [ -f "$src_file" ]; then
      echo "正在同步 $(basename "$src_file") 到系统..."
      cp -f "$src_file" "$dest_file" && log_message "$(basename "$src_file") 同步到系统成功" || handle_error "$(basename "$src_file") 同步到系统失败"
    fi
  done
}

# 同步用户配置文件到项目
sync_user_config_to_project() {
  for config in "${USER_CONFIG_FILES[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"
    if [ -f "$dest_file" ]; then
      echo "正在同步 $(basename "$dest_file") 到项目..."
      cp -f "$dest_file" "$src_file" && log_message "$(basename "$dest_file") 同步到项目成功" || handle_error "$(basename "$dest_file") 同步到项目失败"
    fi
  done
}

# 同步系统配置文件到系统
sync_system_config_to_system() {
  for config in "${SYSTEM_CONFIG_FILES[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"
    if [ -f "$src_file" ]; then
      echo "正在同步 $(basename "$src_file") 到系统..."
      sudo cp -f "$src_file" "$dest_file" && log_message "$(basename "$src_file") 同步到系统成功" || handle_error "$(basename "$src_file") 同步到系统失败"
    fi
  done
}

# 同步系统配置文件到项目
sync_system_config_to_project() {
  for config in "${SYSTEM_CONFIG_FILES[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"
    if [ -f "$dest_file" ]; then
      echo "正在同步 $(basename "$dest_file") 到项目..."
      sudo cp -f "$dest_file" "$src_file" && log_message "$(basename "$dest_file") 同步到项目成功" || handle_error "$(basename "$dest_file") 同步到项目失败"
      sudo chown "$USER:$USER" "$src_file" 2>/dev/null || true
    fi
  done
}

# 同步单向文件到系统
sync_one_way_to_system() {
  for config in "${ONE_WAY_SYNC[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"
    if [ -d "$src_file" ]; then
      echo "正在同步 $(basename "$src_file") 到系统..."
      sudo cp -rf "$src_file"/* "$dest_file/" && log_message "$(basename "$src_file") 同步到系统成功" || handle_error "$(basename "$src_file") 同步到系统失败"
    fi
  done
}

# 安装软件包
install_packages() {
  log_message "开始安装软件包..."

  # 先安装 paru
  echo "正在安装 paru 包管理器..."
  sudo pacman -Sy --noconfirm --needed archlinuxcn-keyring paru && log_message "paru 安装成功" || handle_error "paru 安装失败"

  # 循环遍历列表，安装每一个包
  for package in "${PACKAGE_LIST[@]}"; do
    # 如果该行是注释，则跳过
    [[ "$package" =~ ^# ]] && continue

    echo "Installing $package ..."
    if paru --noconfirm --needed -S "$package"; then
      log_message "$package 安装成功"
    else
      handle_error "$package 安装失败"
    fi
  done

  echo "软件包安装完成！"
}

# 日志记录函数
log_message() {
  local message="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $message"
}

# 错误处理函数
handle_error() {
  local error_message="$1"
  log_message "错误: $error_message"
  echo "错误: $error_message" >&2
  return 1
}

