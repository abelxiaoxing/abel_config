return {
	-- 行为
	automatically_reload_config = true,
	check_for_updates = false,
	exit_behavior = "CloseOnCleanExit", -- 如果shell程序以成功状态退出
	status_update_interval = 1000,
	enable_wayland = true,

	-- 滚动条
	scrollback_lines = 5000,

	-- 粘贴行为
	canonicalize_pasted_newlines = "CarriageReturn",

	hyperlink_rules = {
		-- 匹配: 括号中的URL: (URL)
		{
			regex = "\\((\\w+://\\S+)\\)",
			format = "$1",
			highlight = 1,
		},
		-- 匹配: 方括号中的URL: [URL]
		{
			regex = "\\[(\\w+://\\S+)\\]",
			format = "$1",
			highlight = 1,
		},
		-- 匹配: 花括号中的URL: {URL}
		{
			regex = "\\{(\\w+://\\S+)\\}",
			format = "$1",
			highlight = 1,
		},
		-- 匹配: 尖括号中的URL: <URL>
		{
			regex = "<(\\w+://\\S+)>",
			format = "$1",
			highlight = 1,
		},
		-- 然后处理未包含在括号中的URL
		{
			regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",
			format = "$0",
		},
		-- 隐式mailto链接
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},
	},
}
