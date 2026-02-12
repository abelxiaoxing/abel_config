#!/usr/bin/env bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

POSITION=0
YOFF=0
XOFF=0
FONT="DejaVu Sans Mono 14"
MAX_NETWORK_LINES=8

if [ -r "$DIR/config" ]; then
	source "$DIR/config"
elif [ -r "$HOME/.config/rofi/wifi" ]; then
	source "$HOME/.config/rofi/wifi"
else
	:
fi

require_cmd() {
	command -v "$1" >/dev/null 2>&1 || { printf 'ERROR: missing command: %s\n' "$1" >&2; exit 127; }
}

nmcli_unescape() {
	local s="${1-}"
	s="${s//\\:/:}"
	s="${s//\\\\/\\}"
	printf '%s' "$s"
}

rofi_err() {
	rofi -e "$1" >/dev/null 2>&1 || printf '%s\n' "$1" >&2
}

rofi_dmenu_index() {
	local prompt="$1"
	local lines="$2"
	local selected_row="${3-}"
	local active_row="${4-}"

	local -a args=(
		-dmenu
		-p "$prompt"
		-l "$lines"
		-i
		-no-custom
		-format i
		-location "$POSITION"
		-yoffset "$YOFF"
		-xoffset "$XOFF"
		-font "$FONT"
		-width "-${RWIDTH:-30}"
	)
	[[ -n "$selected_row" ]] && args+=( -selected-row "$selected_row" )
	[[ -n "$active_row" ]] && args+=( -a "$active_row" )

	set +e
	local out
	out="$(rofi "${args[@]}")"
	local rc=$?
	set -e

	(( rc == 0 )) || return 1
	printf '%s' "$out"
}

rofi_prompt_line() {
	local prompt="$1"
	local password="${2-0}"
	local -a args=(
		-dmenu
		-p "$prompt"
		-l 1
		-i
		-location "$POSITION"
		-yoffset "$YOFF"
		-xoffset "$XOFF"
		-font "$FONT"
	)
	(( password == 1 )) && args+=( -password )

	set +e
	local out
	out="$(printf '\n' | rofi "${args[@]}")"
	local rc=$?
	set -e

	(( rc == 0 )) || return 1
	printf '%s' "$out"
}

require_cmd nmcli
require_cmd rofi

WIFI_STATE="$(nmcli -g WIFI general 2>/dev/null | head -n 1 || true)"
if [[ -z "$WIFI_STATE" ]]; then
	rofi_err "nmcli error: cannot query NetworkManager"
	exit 1
fi

if [[ "$WIFI_STATE" == "enabled" ]]; then
	TOGGLE_LABEL="toggle off"
else
	TOGGLE_LABEL="toggle on"
fi

declare -a MENU_LINES=()
declare -a SSIDS=()
declare -a SECURITIES=()

MENU_LINES+=( "$TOGGLE_LABEL" )
TOP_ENTRIES=1

ACTIVE_ROW=""
SELECTED_ROW=""

if [[ "$WIFI_STATE" == "enabled" ]]; then
	MENU_LINES+=( "manual" )
	TOP_ENTRIES=2

	WIFI_LIST="$(LC_ALL=C nmcli -t -e yes -f IN-USE,SSID,SECURITY,SIGNAL dev wifi list 2>/dev/null || true)"
	ACTIVE_SSID_ESCAPED="$(printf '%s\n' "$WIFI_LIST" | awk -F: '$1=="*"{print $2; exit}')"
	ACTIVE_SSID="$(nmcli_unescape "$ACTIVE_SSID_ESCAPED")"

	declare -A SEEN_SSIDS=()
	while IFS= read -r line; do
		[[ -n "$line" ]] || continue

		IFS=':' read -r in_use ssid_escaped security_escaped signal <<<"$line"
		ssid="$(nmcli_unescape "${ssid_escaped-}")"
		security="$(nmcli_unescape "${security_escaped-}")"
		signal="${signal-}"

		[[ -n "$ssid" && "$ssid" != "--" ]] || continue
		[[ -z "${SEEN_SSIDS[$ssid]+x}" ]] || continue
		SEEN_SSIDS["$ssid"]=1

		SSID_LABEL="$ssid"
		if [[ "$security" == "--" || -z "$security" ]]; then
			SEC_LABEL="open"
		else
			SEC_LABEL="$security"
		fi
		[[ -n "$signal" ]] && SIG_LABEL=" ${signal}%" || SIG_LABEL=""
		[[ "$in_use" == "*" ]] && PREFIX="* " || PREFIX="  "

		MENU_LINES+=( "${PREFIX}${SSID_LABEL}  [${SEC_LABEL}]${SIG_LABEL}" )
		SSIDS+=( "$ssid" )
		SECURITIES+=( "$security" )

		if [[ -n "$ACTIVE_SSID" && "$ssid" == "$ACTIVE_SSID" ]]; then
			ACTIVE_ROW=$(( ${#MENU_LINES[@]} - 1 ))
			SELECTED_ROW="$ACTIVE_ROW"
		fi
	done <<<"$WIFI_LIST"
fi

NETWORK_COUNT="${#SSIDS[@]}"
VISIBLE_NETWORK_LINES="$NETWORK_COUNT"
if (( VISIBLE_NETWORK_LINES > MAX_NETWORK_LINES )); then
	VISIBLE_NETWORK_LINES="$MAX_NETWORK_LINES"
fi
VISIBLE_LINES=$TOP_ENTRIES
(( VISIBLE_NETWORK_LINES > 0 )) && VISIBLE_LINES=$(( TOP_ENTRIES + VISIBLE_NETWORK_LINES ))

RWIDTH="$(printf '%s\n' "${MENU_LINES[@]}" | awk '{ if (length($0) > m) m = length($0) } END { print (m ? m + 2 : 30) }')"

MENU_INDEX="$(printf '%s\n' "${MENU_LINES[@]}" | rofi_dmenu_index "Wi-Fi SSID: " "$VISIBLE_LINES" "$SELECTED_ROW" "$ACTIVE_ROW" || true)"
[[ -n "$MENU_INDEX" ]] || exit 0
[[ "$MENU_INDEX" =~ ^[0-9]+$ ]] || exit 0

if (( MENU_INDEX == 0 )); then
	if [[ "$WIFI_STATE" == "enabled" ]]; then
		nmcli radio wifi off
	else
		nmcli radio wifi on
	fi
	exit 0
fi

if (( MENU_INDEX == 1 )) && [[ "$WIFI_STATE" == "enabled" ]]; then
	if ! MSSID="$(rofi_prompt_line "SSID: " 0)"; then
		exit 0
	fi
	[[ -n "$MSSID" ]] || exit 0
	if nmcli dev wifi connect "$MSSID" >/dev/null 2>&1; then
		exit 0
	fi
	if ! MPASS="$(rofi_prompt_line "Password (optional): " 1)"; then
		exit 0
	fi
	if [[ -z "$MPASS" ]]; then
		nmcli dev wifi connect "$MSSID"
	else
		nmcli dev wifi connect "$MSSID" password "$MPASS"
	fi
	exit 0
fi

if [[ "$WIFI_STATE" != "enabled" ]]; then
	rofi_err "Wi-Fi is disabled"
	exit 1
fi

NETWORK_INDEX=$(( MENU_INDEX - TOP_ENTRIES ))
(( NETWORK_INDEX >= 0 && NETWORK_INDEX < NETWORK_COUNT )) || exit 0

CHSSID="${SSIDS[$NETWORK_INDEX]}"
CHSEC="${SECURITIES[$NETWORK_INDEX]}"

WIFI_DEV="$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}')"

disconnect_current() {
	[[ -n "$WIFI_DEV" ]] && nmcli device disconnect "$WIFI_DEV" >/dev/null 2>&1 || true
}

connect_saved() {
	local saved_name
	while IFS=: read -r name type; do
		if [[ "$type" == "wifi" ]]; then
			local ssid
			ssid="$(nmcli -g 802-11-wireless.ssid connection show "$name" 2>/dev/null || true)"
			if [[ "$ssid" == "$CHSSID" ]]; then
				nmcli connection up "$name" >/dev/null 2>&1 && return 0
			fi
		fi
	done < <(nmcli -t -f NAME,TYPE connection show 2>/dev/null)
	return 1
}

if [[ "$CHSEC" == "--" || -z "$CHSEC" ]]; then
	disconnect_current
	nmcli dev wifi connect "$CHSSID" ifname "$WIFI_DEV"
	exit 0
fi

if connect_saved; then
	exit 0
fi

disconnect_current
if nmcli dev wifi connect "$CHSSID" ifname "$WIFI_DEV" >/dev/null 2>&1; then
	exit 0
fi

if ! WIFIPASS="$(rofi_prompt_line "Password (optional): " 1)"; then
	exit 0
fi
if [[ -z "$WIFIPASS" ]]; then
	nmcli dev wifi connect "$CHSSID" ifname "$WIFI_DEV"
else
	nmcli dev wifi connect "$CHSSID" password "$WIFIPASS" ifname "$WIFI_DEV"
fi
