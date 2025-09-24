#!/bin/bash
# Arch Linux 配置管理工具 v2.0
# 加载配置和函数
source ./config.sh
source ./functions.sh

# 主菜单函数
show_main_menu() {
  clear
  echo "=========================================="
  echo "    Arch Linux 配置管理工具 v2.0"
  echo "=========================================="
  echo ""
  echo "1. 同步配置到系统"
  echo "2. 同步系统配置到项目"
  echo "3. 环境安装"
  echo "4. 更新镜像源"
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
    read -p "请选择操作 (0-4): " choice

    # 清理输入，只保留数字
    choice=$(echo "$choice" | tr -d '[:space:]')

    case $choice in
    1)
      show_submenu "同步配置到系统"
      sync_config_to_system
      wait_for_key
      ;;
    2)
      show_submenu "同步系统配置到项目"
      sync_system_to_project
      wait_for_key
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
