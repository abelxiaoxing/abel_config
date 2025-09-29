local wezterm = require("wezterm")
local act = wezterm.action
local platform = require("utils.platform")()

local mod = {}

if platform.is_mac then
	mod.SUPER = "SUPER"
	mod.SUPER_REV = "CTRL|SUPER"
else
	mod.SUPER = "CTRL"
	mod.SUPER_REV = "CTRL|SUPER"
end

local keys = {
	-- misc/useful --
	{ key = "F3", mods = "NONE", action = act.ShowLauncher },
	{ key = "F4", mods = "NONE", action = act.ShowTabNavigator },
	{ key = "F11", mods = "NONE", action = act.ToggleFullScreen },
	{ key = "F12", mods = "NONE", action = act.ShowDebugOverlay },

	-- copy/paste --
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

	-- tabs --
	-- tabs: spawn+close
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("DefaultDomain") },
	{ key = "w", mods = mod.SUPER, action = act.CloseCurrentTab({ confirm = false }) },

	-- tabs: navigation
	{ key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },

	-- tabs: navigation by number
	{ key = "1", mods = "ALT", action = act.ActivateTab(0) },
	{ key = "2", mods = "ALT", action = act.ActivateTab(1) },
	{ key = "3", mods = "ALT", action = act.ActivateTab(2) },
	{ key = "4", mods = "ALT", action = act.ActivateTab(3) },
	{ key = "5", mods = "ALT", action = act.ActivateTab(4) },
	{ key = "6", mods = "ALT", action = act.ActivateTab(5) },
	{ key = "7", mods = "ALT", action = act.ActivateTab(6) },
	{ key = "8", mods = "ALT", action = act.ActivateTab(7) },
	{ key = "9", mods = "ALT", action = act.ActivateTab(8) },

	-- panes --
	-- panes: split panes
	{
		key = [[/]],
		mods = mod.SUPER,
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = [[\]],
		mods = mod.SUPER,
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = [[-]],
		mods = mod.SUPER,
		action = act.CloseCurrentPane({ confirm = true }),
	},

	-- fonts --
	-- fonts: resize
	{ key = "UpArrow", mods = mod.SUPER, action = act.IncreaseFontSize },
	{ key = "DownArrow", mods = mod.SUPER, action = act.DecreaseFontSize },
	{ key = "0", mods = mod.SUPER, action = act.ResetFontSize },
}

local mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	-- Move mouse will only select text and not copy text to clipboard
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("Cell"),
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.ExtendSelectionToMouseCursor("Cell"),
	},
	{
		event = { Drag = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.ExtendSelectionToMouseCursor("Cell"),
	},
	-- Triple Left click will select a line
	{
		event = { Down = { streak = 3, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("Line"),
	},
	{
		event = { Up = { streak = 3, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("Line"),
	},
	-- Double Left click will select a word
	{
		event = { Down = { streak = 2, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("Word"),
	},
	{
		event = { Up = { streak = 2, button = "Left" } },
		mods = "NONE",
		action = act.SelectTextAtMouseCursor("Word"),
	},
	-- Turn on the mouse wheel to scroll the screen
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "NONE",
		action = act.ScrollByCurrentEventWheelDelta,
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "NONE",
		action = act.ScrollByCurrentEventWheelDelta,
	},
}

return {
	disable_default_key_bindings = true,
	disable_default_mouse_bindings = true,
	leader = { key = "Space", mods = "CTRL|SHIFT" },
	keys = keys,
	mouse_bindings = mouse_bindings,
}
