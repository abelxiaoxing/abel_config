local wezterm = require("wezterm")

local M = {}

M.background = {
	{
		source = { File = wezterm.config_dir .. "/backdrops/dark.png" },
		hsb = { brightness = 0.9 },
		width = "Contain",
		height = "Contain",
		horizontal_align = "Center",
		vertical_align = "Middle",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
	},
	{
		source = { Color = "#1A1B26" },
		height = "100%",
		width = "100%",
		opacity = 0.95,
	},
}

M.setup = function()
	wezterm.on("window-config-reloaded", function(window)
		wezterm.time.call_after(0.1, function()
			window:set_config_overrides({ background = M.background })
		end)
	end)
end

return M
