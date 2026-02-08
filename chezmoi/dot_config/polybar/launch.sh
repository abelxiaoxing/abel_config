#!/usr/bin/env sh

# More info : https://github.com/jaagr/polybar/wiki

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID polybar > /dev/null; do sleep 1; done

# Function to detect the current window manager
detect_wm() {
    # Try multiple methods to detect the window manager
    
    # Method 1: DESKTOP_SESSION (most reliable)
    if [ -n "$DESKTOP_SESSION" ]; then
        echo "$DESKTOP_SESSION"
        return 0
    fi
    
    # Method 2: XDG_CURRENT_DESKTOP
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        echo "$XDG_CURRENT_DESKTOP"
        return 0
    fi
    
    # Method 3: Check running processes
    for wm in i3 bspwm openbox xmonad herbstluftwm spectrwm cwm fvwm3 berry worm leftwm wmderland; do
        if pgrep -x "$wm" > /dev/null; then
            echo "$wm"
            return 0
        fi
    done
    
    # Method 4: Use xprop to get window manager name
    if command -v xprop >/dev/null 2>&1; then
        wm_name=$(xprop -root _NET_WM_NAME 2>/dev/null | cut -d'"' -f2)
        if [ -n "$wm_name" ]; then
            echo "$wm_name"
            return 0
        fi
    fi
    
    # Default fallback
    echo "i3"
    return 1
}

# Function to launch polybar for a specific window manager
launch_polybar() {
    local wm_name=$1
    local config_file="$HOME/.config/polybar/config"
    
    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        echo "Error: Config file not found at $config_file"
        return 1
    fi
    
    # Check if the bar configuration exists
    if ! grep -q "\[bar/mainbar-$wm_name\]" "$config_file"; then
        echo "Warning: Bar configuration [mainbar-$wm_name] not found, trying mainbar-i3"
        wm_name="i3"
    fi
    
    local count=$(xrandr --query 2>/dev/null | grep " connected" | cut -d" " -f1 | wc -l)

    if command -v xrandr >/dev/null 2>&1 && [ "$count" -gt 0 ]; then
        if [ "$wm_name" = "xmonad" ] && [ "$count" -eq 1 ]; then
            # Special handling for xmonad with single monitor
            local m=$(xrandr --query | grep " connected" | cut -d" " -f1)
            echo "Launching polybar for $wm_name on monitor $m"
            MONITOR=$m polybar --reload "mainbar-$wm_name" -c "$config_file" &
        else
            # Standard multi-monitor support for all WMs
            primary=$(xrandr --query | grep " primary" | cut -d" " -f1)
            for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
                if [ "$m" = "$primary" ]; then
                    echo "Launching polybar for $wm_name on primary monitor $m"
                    MONITOR=$m polybar --reload "mainbar-$wm_name" -c "$config_file" &
                else
                    echo "Launching polybar for $wm_name on secondary monitor $m"
                    MONITOR=$m polybar --reload "mainbar-$wm_name-secondary" -c "$config_file" 2>/dev/null || \
                    MONITOR=$m polybar --reload "mainbar-$wm_name" -c "$config_file" &
                fi
            done
        fi
    else
        # Fallback when xrandr is not available
        echo "Launching polybar for $wm_name (fallback mode)"
        polybar --reload "mainbar-$wm_name" -c "$config_file" &
    fi
}

# Detect window manager
wm=$(detect_wm)
echo "Detected window manager: $wm"

# Normalize WM name (remove full paths)
case "$wm" in
    */*) wm=$(basename "$wm") ;;
esac

# Launch polybar for the detected window manager
case "$wm" in
    i3|openbox|bspwm|herbstluftwm|worm|berry|xmonad|spectrwm|cwm|fvwm3|wmderland|leftwm)
        launch_polybar "$wm"
        ;;
    *)
        echo "Unknown or unsupported window manager: $wm, falling back to i3"
        launch_polybar "i3"
        ;;
esac

echo "Polybar launch completed"
