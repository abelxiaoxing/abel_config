local platform = require("utils.platform")()

local options = {
	default_prog = {},
	launch_menu = {},
}

if platform.is_win then
	options.default_prog = { "pwsh" }
	options.launch_menu = {
		{ label = " PowerShell", args = { "pwsh" } },
		{ label = " Cmd", args = { "cmd" } },
		{ label = " Nushell", args = { "nu" } },
		{ label = " GitBash", args = { "bash" } },
	}
elseif platform.is_mac then
	options.default_prog = { "zsh", "--login" }
	options.launch_menu = {
		{ label = " Zsh", args = { "zsh", "--login" } },
		{ label = " Bash", args = { "bash", "--login" } },
		{ label = " Fish", args = { "fish", "--login" } },
		{ label = " Nushell", args = { "nu", "--login" } },
	}
elseif platform.is_linux then
	options.default_prog = { "zsh", "--login" }
	options.launch_menu = {
		{ label = " Zsh", args = { "zsh", "--login" } },
		{ label = " Bash", args = { "bash", "--login" } },
		{ label = " Fish", args = { "fish", "--login" } },
		{ label = " Nushell", args = { "nu", "--login" } },
	}
end

return options
