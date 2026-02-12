#!/usr/bin/bash
# 智能工作区配置脚本
# 自动检测显示器并分配工作区

sleep 1  # 等待显示器初始化

# 获取所有显示器信息
MONITORS=$(hyprctl monitors | grep -E "^Monitor (eDP-|HDMI-|DP-)" | awk '{print $2}')
COUNT=$(echo "$MONITORS" | wc -l)

if [ "$COUNT" -eq 1 ]; then
    # 单显示器：所有工作区都在这个显示器
    MONITOR=$(echo "$MONITORS" | head -1)
    for i in {1..10}; do
        hyprctl keyword workspace "$i,monitor:$MONITOR"
    done
else
    # 多显示器：判断主屏
    PRIMARY=""
    SECONDARY=""

    # 检查是否是笔记本（有 eDP）
    EDP=$(echo "$MONITORS" | grep "eDP-" | head -1)

    if [ -n "$EDP" ]; then
        # 笔记本：外接显示器为主屏
        PRIMARY=$(echo "$MONITORS" | grep -v "eDP-" | head -1)
        SECONDARY="$EDP"
    else
        # 台式机：分辨率更高的为主屏
        # 获取所有显示器的分辨率信息并排序
        PRIMARY=$(hyprctl monitors | grep -E "^Monitor (HDMI-|DP-)" | while read -r line; do
            name=$(echo "$line" | awk '{print $2}')
            width=$(echo "$line" | grep -oP '\d+x\d+@' | head -1 | grep -oP '^\d+')
            echo "$width $name"
        done | sort -rn | head -1 | awk '{print $2}')

        SECONDARY=$(echo "$MONITORS" | grep -v "$PRIMARY" | head -1)
    fi

    # 分配工作区
    for i in {1..5}; do
        hyprctl keyword workspace "$i,monitor:$PRIMARY"
    done
    for i in {6..10}; do
        hyprctl keyword workspace "$i,monitor:$SECONDARY"
    done

    # 让副屏初始化显示工作区6，避免工作区1被占用的冲突
    hyprctl dispatch moveworkspacetomonitor 1 "$PRIMARY"
    hyprctl dispatch focusmonitor "$SECONDARY"
    hyprctl dispatch workspace 6
    hyprctl dispatch focusmonitor "$PRIMARY"
fi
