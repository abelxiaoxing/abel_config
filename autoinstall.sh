#!/bin/bash
# Arch Linux 配置管理工具 v2.0

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT
cd "$PROJECT_ROOT" || exit 1

# 加载配置和函数
source "$PROJECT_ROOT/config.sh"
source "$PROJECT_ROOT/functions.sh"

# 主菜单函数
show_main_menu() {
  clear
  echo "=========================================="
  echo "    Arch Linux 配置管理工具 v3.0"
  echo "=========================================="
  echo ""
  echo "1. 同步配置到系统"
  echo "2. 同步系统配置到项目"
  echo "3. 环境安装"
  echo "4. 更新镜像源"
  echo "5. 一键部署（换源+安装+同步）"
  echo "0. 退出"
  echo ""
  echo "=========================================="
}

# 显示子菜单
show_submenu() {
  clear
  echo "=========================================="
  echo "    $1"
  echo "=========================================="
  echo ""
}

# 等待用户按键
wait_for_key() {
  echo ""
  read -p "按回车键继续..." -r
}

# 主程序循环
main() {
  while true; do
    show_main_menu
    read -p "请选择操作 (0-5): " choice

    # 清理输入，只保留数字
    choice=$(echo "$choice" | tr -d '[:space:]')

    case $choice in
    1)
      while true; do
        show_submenu "同步配置到系统"
        echo "1. 全部同步（用户+系统+壁纸）"
        echo "2. 仅同步用户配置（chezmoi apply）"
        echo "3. 仅同步系统配置（/etc + 壁纸）"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择操作 (0-3): " subchoice
        subchoice=$(echo "$subchoice" | tr -d '[:space:]')

        case $subchoice in
        1)
          sync_config_to_system_interactive
          wait_for_key
          ;;
        2)
          apply_user_configs_with_chezmoi_interactive
          wait_for_key
          ;;
        3)
          if sync_system_config_to_system_interactive && sync_one_way_to_system_interactive; then
            echo "系统配置同步完成！"
          else
            echo "同步已中止或失败。"
          fi
          wait_for_key
          ;;
        0)
          break
          ;;
        *)
          echo "无效选择，请重试"
          sleep 1
          ;;
        esac
      done
      ;;
    2)
      while true; do
        show_submenu "同步系统配置到项目"
        echo "1. 全部同步回项目（用户+系统）"
        echo "2. 仅同步用户配置回项目（chezmoi add）"
        echo "3. 仅同步系统配置回项目（/etc）"
        echo "0. 返回主菜单"
        echo ""
        read -p "请选择操作 (0-3): " subchoice
        subchoice=$(echo "$subchoice" | tr -d '[:space:]')

        case $subchoice in
        1)
          if sync_user_configs_to_project_interactive; then
            sync_system_config_to_project
            echo "同步回项目完成！"
          else
            echo "同步已中止或失败。"
          fi
          wait_for_key
          ;;
        2)
          if sync_user_configs_to_project_interactive; then
            echo "用户配置同步回项目完成！"
          else
            echo "同步已中止或失败。"
          fi
          wait_for_key
          ;;
        3)
          sync_system_config_to_project
          echo "系统配置同步回项目完成！"
          wait_for_key
          ;;
        0)
          break
          ;;
        *)
          echo "无效选择，请重试"
          sleep 1
          ;;
        esac
      done
      ;;
    3)
      show_submenu "换源+环境安装"
      update_mirrorlist
      install_packages
      wait_for_key
      ;;
    4)
      show_submenu "仅更新镜像源"
      update_mirrorlist
      echo "镜像源更新完成！"
      wait_for_key
      ;;
    5)
      show_submenu "一键部署（换源+安装+同步）"
      update_mirrorlist
      install_packages
      sync_config_to_system_interactive
      wait_for_key
      ;;
    0)
      echo "感谢使用，再见！"
      exit 0
      ;;
    *)
      echo "无效选择，请重试"
      sleep 2
      ;;
    esac
  done
}

# 启动主程序
main
