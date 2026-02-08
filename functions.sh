#!/bin/bash
# 功能函数库

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
CHEZMOI_SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$PROJECT_ROOT/chezmoi}"

chezmoi_cmd() {
  chezmoi --source "$CHEZMOI_SOURCE_DIR" "$@"
}

prompt_action() {
  local prompt="$1"
  local action
  while true; do
    read -r -p "$prompt" action
    action="$(echo "$action" | tr -d '[:space:]')"
    case "$action" in
    d | D | o | O | a | A | s | S | q | Q)
      echo "$action"
      return 0
      ;;
    *)
      echo "无效选项，请输入 d/o/a/s/q" >&2
      ;;
    esac
  done
}

chezmoi_apply_change_count() {
  local target="$1"
  chezmoi_cmd status --no-pager "$target" 2>/dev/null | awk 'length($0)>=2 && substr($0,2,1)!=" " {c++} END {print c+0}'
}

print_chezmoi_diff() {
  local target="$1"
  local diff_output
  if [ -d "$target" ]; then
    diff_output="$(chezmoi_cmd diff --no-pager --recursive "$target" 2>/dev/null || true)"
  else
    diff_output="$(chezmoi_cmd diff --no-pager "$target" 2>/dev/null || true)"
  fi
  if [ -z "$diff_output" ]; then
    echo "无差异"
  else
    echo "$diff_output"
  fi
}

ensure_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    return 0
  fi

  log_message "chezmoi 未安装，正在尝试安装..."
  if sudo pacman -S --noconfirm --needed chezmoi; then
    log_message "chezmoi 安装成功"
    return 0
  fi

  handle_error "chezmoi 安装失败，请检查网络/镜像源后重试"
}

apply_user_configs_with_chezmoi() {
  ensure_chezmoi || return 1

  if [ ! -d "$CHEZMOI_SOURCE_DIR" ]; then
    handle_error "chezmoi 源目录不存在: $CHEZMOI_SOURCE_DIR"
    return 1
  fi

  if [ "$#" -eq 0 ]; then
    log_message "正在应用全部用户配置（chezmoi）..."
    chezmoi_cmd apply
    return $?
  fi

  log_message "正在应用选择的用户配置（chezmoi）..."
  chezmoi_cmd apply "$@"
}

apply_user_configs_with_chezmoi_interactive() {
  ensure_chezmoi || return 1

  if [ ! -d "$CHEZMOI_SOURCE_DIR" ]; then
    handle_error "chezmoi 源目录不存在: $CHEZMOI_SOURCE_DIR"
    return 1
  fi

  local items=()
  local item
  for dir in "${CONFIG_DIRS[@]}"; do
    items+=("$dir|$HOME/.config/$dir")
  done
  for target in "${USER_CONFIG_FILES[@]}"; do
    items+=("$(basename "$target")|$target")
  done

  local changed_items=()
  local unchanged_items=()
  for item in "${items[@]}"; do
    local label="${item%%|*}"
    local target="${item#*|}"
    local count
    count="$(chezmoi_apply_change_count "$target")"
    if [ "$count" -gt 0 ]; then
      changed_items+=("$label|$target|$count")
    else
      unchanged_items+=("$label")
    fi
  done

  echo "用户配置（chezmoi）变更扫描完成："
  if [ "${#changed_items[@]}" -eq 0 ]; then
    echo "- 无需要同步的变更"
    return 0
  fi

  echo "- 需要同步的模块:"
  for item in "${changed_items[@]}"; do
    local label="${item%%|*}"
    local rest="${item#*|}"
    local count="${rest##*|}"
    echo "  - $label ($count)"
  done
  if [ "${#unchanged_items[@]}" -gt 0 ]; then
    if [ "${#unchanged_items[@]}" -le 10 ]; then
      echo "- 无变化: ${unchanged_items[*]}"
    else
      local first
      first=("${unchanged_items[@]:0:10}")
      echo "- 无变化(前10/${#unchanged_items[@]}): ${first[*]} ..."
    fi
  fi

  echo ""
  echo "提示: d=diff, o=overwrite, a=all-overwrite, s=skip, q=quit"

  local overwrite_all=0
  local applied_any=0

  for item in "${changed_items[@]}"; do
    local label="${item%%|*}"
    local rest="${item#*|}"
    local target="${rest%%|*}"

    local action
    if [ "$overwrite_all" -eq 1 ]; then
      action="o"
    else
      while true; do
        echo ""
        echo "模块: $label"
        action="$(prompt_action "选择 [d/o/a/s/q]: ")"
        case "$action" in
        d | D)
          print_chezmoi_diff "$target"
          ;;
        *)
          break
          ;;
        esac
      done
    fi

    case "$action" in
    o | O | a | A)
      if [ "$action" = "a" ] || [ "$action" = "A" ]; then
        overwrite_all=1
      fi
      chezmoi_cmd apply --force "$target" || handle_error "chezmoi apply 失败: $label"
      applied_any=1
      log_message "已同步到系统: $label"
      ;;
    s | S)
      log_message "已跳过: $label"
      ;;
    q | Q)
      log_message "用户中止同步"
      return 130
      ;;
    esac
  done

  [ "$applied_any" -eq 1 ] && echo "用户配置同步完成！"
}

sync_system_config_to_system_interactive() {
  echo "系统配置（/etc）变更扫描完成："

  local changed=()
  local unchanged=()
  local config

  for config in "${SYSTEM_CONFIG_FILES[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"

    if [ ! -f "$src_file" ]; then
      continue
    fi

    if sudo test -f "$dest_file" && sudo cmp -s "$src_file" "$dest_file" 2>/dev/null; then
      unchanged+=("$(basename "$dest_file")")
    else
      changed+=("$src_file|$dest_file")
    fi
  done

  if [ "${#changed[@]}" -eq 0 ]; then
    echo "- 无需要同步的系统配置变更"
    return 0
  fi

  echo "- 需要同步的文件:"
  for config in "${changed[@]}"; do
    local dest_file="${config##*|}"
    echo "  - $dest_file"
  done
  if [ "${#unchanged[@]}" -gt 0 ]; then
    echo "- 无变化: ${unchanged[*]}"
  fi

  echo ""
  echo "提示: d=diff, o=overwrite, a=all-overwrite, s=skip, q=quit"

  local overwrite_all=0
  local applied_any=0

  for config in "${changed[@]}"; do
    local src_file="${config%%|*}"
    local dest_file="${config##*|}"
    local label
    label="$(basename "$dest_file")"

    local action
    if [ "$overwrite_all" -eq 1 ]; then
      action="o"
    else
      while true; do
        echo ""
        echo "文件: $dest_file"
        action="$(prompt_action "选择 [d/o/a/s/q]: ")"
        case "$action" in
        d | D)
          if sudo test -f "$dest_file"; then
            sudo diff -u "$dest_file" "$src_file" || true
          else
            echo "目标文件不存在，将被创建：$dest_file"
          fi
          ;;
        *)
          break
          ;;
        esac
      done
    fi

    case "$action" in
    o | O | a | A)
      if [ "$action" = "a" ] || [ "$action" = "A" ]; then
        overwrite_all=1
      fi
      sudo install -Dm 0644 "$src_file" "$dest_file" || handle_error "同步失败: $dest_file"
      applied_any=1
      log_message "已同步到系统: $dest_file"
      ;;
    s | S)
      log_message "已跳过: $dest_file"
      ;;
    q | Q)
      log_message "用户中止同步"
      return 130
      ;;
    esac
  done

  [ "$applied_any" -eq 1 ] && echo "系统配置同步完成！"
}

sync_one_way_to_system_interactive() {
  local overwrite_all=0
  local config

  for config in "${ONE_WAY_SYNC[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"

    [ -d "$src_file" ] || continue

    local changed_files=()
    local total=0

    while IFS= read -r -d '' file; do
      total=$((total + 1))
      local rel="${file#"$src_file"/}"
      local dest_path="$dest_file/$rel"

      if ! sudo test -f "$dest_path"; then
        changed_files+=("$rel (new)")
        continue
      fi

      local src_sum dest_sum
      src_sum="$(sha256sum "$file" | awk '{print $1}')"
      dest_sum="$(sudo sha256sum "$dest_path" 2>/dev/null | awk '{print $1}')"
      if [ -n "$src_sum" ] && [ -n "$dest_sum" ] && [ "$src_sum" != "$dest_sum" ]; then
        changed_files+=("$rel (modified)")
      fi
    done < <(find "$src_file" -type f -print0 2>/dev/null)

    echo ""
    echo "单向同步: $src_file -> $dest_file"
    if [ "${#changed_files[@]}" -eq 0 ]; then
      echo "- 无变化（共 $total 个文件）"
      continue
    fi

    echo "- 需要更新/创建: ${#changed_files[@]} 个文件（共 $total 个文件）"
    echo "提示: d=diff(list), o=overwrite, a=all-overwrite, s=skip, q=quit"

    local action
    if [ "$overwrite_all" -eq 1 ]; then
      action="o"
    else
      while true; do
        action="$(prompt_action "选择 [d/o/a/s/q]: ")"
        case "$action" in
        d | D)
          printf '%s\n' "${changed_files[@]}" | sed -n '1,200p'
          ;;
        *)
          break
          ;;
        esac
      done
    fi

    case "$action" in
    o | O | a | A)
      if [ "$action" = "a" ] || [ "$action" = "A" ]; then
        overwrite_all=1
      fi
      sudo mkdir -p "$dest_file" || handle_error "创建目录失败: $dest_file"
      sudo cp -rf "$src_file"/* "$dest_file/" || handle_error "同步失败: $src_file"
      log_message "已同步到系统: $dest_file"
      ;;
    s | S)
      log_message "已跳过: $dest_file"
      ;;
    q | Q)
      log_message "用户中止同步"
      return 130
      ;;
    esac
  done
}

sync_config_to_system_interactive() {
  log_message "开始同步配置到系统（交互式）..."

  apply_user_configs_with_chezmoi_interactive || return $?
  sync_system_config_to_system_interactive || return $?
  sync_one_way_to_system_interactive || return $?

  echo "配置同步完成！"
}

add_user_configs_to_project_with_chezmoi() {
  ensure_chezmoi || return 1

  if [ ! -d "$CHEZMOI_SOURCE_DIR" ]; then
    handle_error "chezmoi 源目录不存在: $CHEZMOI_SOURCE_DIR"
    return 1
  fi

  log_message "正在从系统回同步用户配置到项目（chezmoi add）..."

  for dir in "${CONFIG_DIRS[@]}"; do
    [ -d "$HOME/.config/$dir" ] || continue
    if [ "$dir" = "opencode" ]; then
      [ -f "$HOME/.config/opencode/opencode.json" ] && chezmoi_cmd add "$HOME/.config/opencode/opencode.json" || true
      continue
    fi

    chezmoi_cmd add --recursive "$HOME/.config/$dir" || handle_error "chezmoi add 失败: $dir"
  done

  for target in "${USER_CONFIG_FILES[@]}"; do
    [ -e "$target" ] || continue
    chezmoi_cmd add "$target" || handle_error "chezmoi add 失败: $target"
  done
}

sync_user_configs_to_project_interactive() {
  ensure_chezmoi || return 1

  if [ ! -d "$CHEZMOI_SOURCE_DIR" ]; then
    handle_error "chezmoi 源目录不存在: $CHEZMOI_SOURCE_DIR"
    return 1
  fi

  local items=()
  local dir
  for dir in "${CONFIG_DIRS[@]}"; do
    if [ "$dir" = "opencode" ]; then
      [ -d "$HOME/.config/opencode" ] && items+=("opencode|$HOME/.config/opencode|special")
      continue
    fi
    [ -d "$HOME/.config/$dir" ] && items+=("$dir|$HOME/.config/$dir|dir")
  done
  for target in "${USER_CONFIG_FILES[@]}"; do
    [ -e "$target" ] && items+=("$(basename "$target")|$target|file")
  done

  if [ "${#items[@]}" -eq 0 ]; then
    log_message "未找到可同步的用户配置目标"
    return 0
  fi

  local changed_items=()
  local unchanged_items=()
  local item
  for item in "${items[@]}"; do
    local label="${item%%|*}"
    local rest="${item#*|}"
    local target="${rest%%|*}"
    local count
    count="$(chezmoi_apply_change_count "$target")"
    if [ "$count" -gt 0 ]; then
      changed_items+=("$label|$target|${rest##*|}|$count")
    else
      unchanged_items+=("$label")
    fi
  done

  echo "用户配置回同步（chezmoi）变更扫描完成："
  if [ "${#changed_items[@]}" -eq 0 ]; then
    echo "- 无需要同步回仓库的变更"
    return 0
  fi

  echo "- 需要回同步的模块:"
  for item in "${changed_items[@]}"; do
    local label="${item%%|*}"
    local count="${item##*|}"
    echo "  - $label ($count)"
  done
  if [ "${#unchanged_items[@]}" -gt 0 ]; then
    if [ "${#unchanged_items[@]}" -le 10 ]; then
      echo "- 无变化: ${unchanged_items[*]}"
    else
      local first
      first=("${unchanged_items[@]:0:10}")
      echo "- 无变化(前10/${#unchanged_items[@]}): ${first[*]} ..."
    fi
  fi

  log_message "开始交互式回同步用户配置到仓库（chezmoi add）..."
  log_message "提示: d=diff, o=overwrite, a=all-overwrite, s=skip, q=quit"

  local overwrite_all=0
  local synced_any=0

  local status_before_file status_after_file
  status_before_file="$(mktemp)"
  status_after_file="$(mktemp)"
  git -C "$PROJECT_ROOT" status --porcelain=v1 | sort >"$status_before_file"

  for item in "${changed_items[@]}"; do
    local label="${item%%|*}"
    local rest="${item#*|}"
    local target="${rest%%|*}"
    rest="${rest#*|}"
    local mode="${rest%%|*}"

    local action
    if [ "$overwrite_all" -eq 1 ]; then
      action="o"
    else
      while true; do
        echo ""
        echo "模块: $label"
        action="$(prompt_action "选择 [d/o/a/s/q]: ")"
        case "$action" in
        d | D)
          print_chezmoi_diff "$target"
          ;;
        *)
          break
          ;;
        esac
      done
    fi

    case "$action" in
    o | O | a | A)
      if [ "$action" = "a" ] || [ "$action" = "A" ]; then
        overwrite_all=1
      fi

      case "$mode" in
      special)
        [ -f "$HOME/.config/opencode/opencode.json" ] && chezmoi_cmd add --force "$HOME/.config/opencode/opencode.json" || true
        ;;
      dir)
        chezmoi_cmd add --force --exact --recursive "$target" || handle_error "chezmoi add 失败: $label"
        ;;
      file)
        chezmoi_cmd add --force "$target" || handle_error "chezmoi add 失败: $label"
        ;;
      esac

      synced_any=1
      log_message "已同步到仓库: $label"
      ;;
    s | S)
      log_message "已跳过: $label"
      ;;
    q | Q)
      log_message "用户中止同步"
      rm -f "$status_before_file" "$status_after_file"
      return 130
      ;;
    esac
  done

  git -C "$PROJECT_ROOT" status --porcelain=v1 | sort >"$status_after_file"

  echo ""
  if [ "$synced_any" -eq 1 ]; then
    local new_changes
    new_changes="$(comm -13 "$status_before_file" "$status_after_file" || true)"
    if [ -z "$new_changes" ]; then
      echo "已执行回同步，但仓库没有检测到新的变更。"
    else
      echo "本次回同步写入仓库的变更:"
      echo "$new_changes"
    fi

    echo ""
    echo "当前仓库状态（git status）:"
    git -C "$PROJECT_ROOT" status --short
  else
    echo "没有执行任何回同步操作。"
  fi

  rm -f "$status_before_file" "$status_after_file"
}

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

  # 同步用户配置（chezmoi 管理）
  apply_user_configs_with_chezmoi || return 1

  # 同步系统配置文件
  sync_system_config_to_system

  # 同步单向文件
  sync_one_way_to_system

  echo "配置同步完成！"
}

# 同步系统配置到项目
sync_system_to_project() {
  log_message "开始同步系统配置到项目..."

  # 同步用户配置文件（chezmoi 管理）
  add_user_configs_to_project_with_chezmoi

  # 同步系统配置文件
  sync_system_config_to_project

  echo "系统配置同步到项目完成！"
}

# 同步系统配置文件到系统
sync_system_config_to_system() {
  for config in "${SYSTEM_CONFIG_FILES[@]}"; do
    local src_file="${config%%:*}"
    local dest_file="${config##*:}"
    if [ -f "$src_file" ]; then
      echo "正在同步 $(basename "$src_file") 到系统..."
      sudo install -Dm 0644 "$src_file" "$dest_file" && log_message "$(basename "$src_file") 同步到系统成功" || handle_error "$(basename "$src_file") 同步到系统失败"
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
      sudo mkdir -p "$dest_file" || handle_error "创建目录失败: $dest_file"
      sudo cp -rf "$src_file"/* "$dest_file/" && log_message "$(basename "$src_file") 同步到系统成功" || handle_error "$(basename "$src_file") 同步到系统失败"
    fi
  done
}

# 安装软件包
install_packages() {
  log_message "开始安装软件包..."

  # 基础依赖（用于构建 AUR 包）
  sudo pacman -Syu --noconfirm --needed base-devel git && log_message "基础依赖安装完成" || handle_error "基础依赖安装失败"

  # 先安装 chezmoi
  ensure_chezmoi || return 1

  # 安装 paru（优先已存在，其次尝试从 AUR 构建）
  if ! command -v paru >/dev/null 2>&1; then
    echo "正在安装 paru (AUR)..."
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$tmp_dir/paru" || handle_error "克隆 paru 仓库失败"
    (cd "$tmp_dir/paru" && makepkg -si --noconfirm --needed) || handle_error "构建/安装 paru 失败"
    rm -rf "$tmp_dir"
    command -v paru >/dev/null 2>&1 && log_message "paru 安装成功" || handle_error "paru 安装失败"
  fi

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

  # 启用必要的服务
  enable_services
}

# 启用系统服务
enable_services() {
  log_message "开始启用系统服务..."

  # 需要启用的服务列表
  local services=(
    "sddm"           # 显示管理器
    "sshd"           # SSH服务
    "pipewire"       # PipeWire音频服务
    "pipewire-pulse" # PipeWire Pulse兼容层
    "wireplumber"    # PipeWire会话管理
    "bluetooth"      # 蓝牙
  )

  # 系统级服务（需要sudo）
  local system_services=(
    "sddm"
    "sshd"
  )

  # 用户级服务
  local user_services=(
    "pipewire"
    "pipewire-pulse"
    "wireplumber"
  )

  # 启用系统级服务
  for service in "${system_services[@]}"; do
    echo "正在启用系统服务: $service..."
    if sudo systemctl enable "$service"; then
      log_message "系统服务 $service 启用成功"
    else
      handle_error "系统服务 $service 启用失败"
    fi
  done

  # 启用用户级服务
  for service in "${user_services[@]}"; do
    echo "正在启用用户服务: $service..."
    if systemctl --user enable "$service"; then
      log_message "用户服务 $service 启用成功"
    else
      log_message "用户服务 $service 启用失败（可能需要用户登录后生效）"
    fi
  done

  echo "服务启用完成！"
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
