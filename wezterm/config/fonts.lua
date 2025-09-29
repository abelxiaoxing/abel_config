local wezterm = require("wezterm")
local platform = require("utils.platform")

local font = "JetBrainsMono Nerd Font Mono"
local font_size = platform().is_mac and 17 or 14

return {
	font = wezterm.font_with_fallback({
		font,
		"Noto Sans CJK SC",
	}),
	font_size = font_size,

	freetype_load_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
	freetype_render_target = "Normal", ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}