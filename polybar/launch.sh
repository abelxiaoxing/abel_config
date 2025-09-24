#!/usr/bin/env sh

# More info : https://github.com/jaagr/polybar/wiki

# Install the following applications for polybar and icons in polybar if you are on ArcoLinuxD
# awesome-terminal-fonts
# Tip : There are other interesting fonts that provide icons like nerd-fonts-complete
# --log=error

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID polybar > /dev/null; do sleep 1; done

# Function to launch polybar for a specific window manager
launch_polybar() {
    local wm_name=$1
    local count=$(xrandr --query | grep " connected" | cut -d" " -f1 | wc -l)

    if type "xrandr" > /dev/null; then
        if [ "$wm_name" = "xmonad" ] && [ $count = 1 ]; then
            # Special handling for xmonad with single monitor
            local m=$(xrandr --query | grep " connected" | cut -d" " -f1)
            MONITOR=$m polybar --reload "mainbar-$wm_name" -c ~/.config/polybar/config &
        else
            # Standard multi-monitor support for all WMs
            for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
                MONITOR=$m polybar --reload "mainbar-$wm_name" -c ~/.config/polybar/config &
            done
        fi
    else
        # Fallback when xrandr is not available
        polybar --reload "mainbar-$wm_name" -c ~/.config/polybar/config &
    fi
}

# Get current desktop environment
desktop=$(echo $DESKTOP_SESSION)


case $desktop in
    i3|/usr/share/xsessions/i3)
        launch_polybar "i3"
        ;;
    openbox|/usr/share/xsessions/openbox)
        launch_polybar "openbox"
        ;;
    bspwm|/usr/share/xsessions/bspwm)
        launch_polybar "bspwm"
        ;;
    herbstluftwm|/usr/share/xsessions/herbstluftwm)
        launch_polybar "herbstluftwm"
        ;;
    worm|/usr/share/xsessions/worm)
        launch_polybar "worm"
        ;;
    berry|/usr/share/xsessions/berry)
        launch_polybar "berry"
        ;;
    xmonad|/usr/share/xsessions/xmonad)
        launch_polybar "xmonad"
        ;;
    spectrwm|/usr/share/xsessions/spectrwm)
        launch_polybar "spectrwm"
        ;;
    cwm|/usr/share/xsessions/cwm)
        launch_polybar "cwm"
        ;;
    fvwm3|/usr/share/xsessions/fvwm3)
        launch_polybar "fvwm3"
        ;;
    wmderland|/usr/share/xsessions/wmderland)
        launch_polybar "wmderland"
        ;;
    leftwm|/usr/share/xsessions/leftwm)
        launch_polybar "leftwm"
        ;;
esac
