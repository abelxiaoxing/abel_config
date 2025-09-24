#!/bin/bash

# i3 颜色主题切换脚本
# 使用方法: ./theme-switch.sh <主题路径>

CONFIG_FILE="$HOME/.config/i3/config"
THEME_DIR="$HOME/.config/i3/themes"

if [ -z "$1" ]; then
  echo "可用主题:"
  ls "$THEME_DIR"/*.theme | sed 's/.*\//  /' | sed 's/\.theme$//'
  echo ""
  echo "使用方法: $0 <主题名称或路径>"
  echo "例如: $0 default"
  echo "或者: $0 /path/to/theme.theme"
  exit 1
fi

# 检查参数是路径还是主题名称
if [[ "$1" == /* ]]; then
  # 绝对路径
  THEME_FILE="$1"
elif [[ "$1" == *".theme" ]]; then
  # 相对路径
  THEME_FILE="$1"
else
  # 主题名称
  THEME_FILE="$THEME_DIR/$1.theme"
fi

if [ ! -f "$THEME_FILE" ]; then
  echo "主题文件不存在: $THEME_FILE"
  echo "可用主题:"
  ls "$THEME_DIR"/*.theme | sed 's/.*\//  /' | sed 's/\.theme$//'
  exit 1
fi

# 备份当前配置
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"

# 创建临时配置文件
TEMP_CONFIG=$(mktemp)

# 复制配置文件，但不包含颜色相关的部分
awk '
    BEGIN { skip_colors = 0 }
    /^################# bar appearance/ { skip_colors = 1; next }
    { if (!skip_colors) print }
' "$CONFIG_FILE" >"$TEMP_CONFIG"

# 将主题颜色配置添加到配置文件
echo "" >>"$TEMP_CONFIG"
echo "################# bar appearance                   " >>"$TEMP_CONFIG"

# 从主题文件中提取颜色配置
awk '
    /^client\.focused/ { print $0 }
    /^client\.unfocused/ { print $0 }
    /^client\.focused_inactive/ { print $0 }
    /^client\.placeholder/ { print $0 }
    /^client\.urgent/ { print $0 }
    /^client\.background/ { print $0 }
' "$THEME_FILE" >>"$TEMP_CONFIG"

# 替换原配置文件
mv "$TEMP_CONFIG" "$CONFIG_FILE"

# 提取主题名称用于显示
if [[ "$1" == /* ]]; then
  THEME_NAME=$(basename "$1" .theme)
elif [[ "$1" == *".theme" ]]; then
  THEME_NAME=$(basename "$1" .theme)
else
  THEME_NAME="$1"
fi

echo "主题已切换到: $THEME_NAME"
echo "重新加载 i3 配置..."
i3-msg reload

echo "完成！新主题已生效。"

