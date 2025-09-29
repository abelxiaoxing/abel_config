local platform = require("utils.platform")()

local function get_home_dir()
	if platform.is_win then
		return os.getenv("USERPROFILE")
	else
		return os.getenv("HOME")
	end
end

return {
	-- 参考: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
	ssh_domains = {
		{
			-- 连接是SSH连接，不使用任何多路复用
			multiplexing = "None",

			-- 此域的名称，在所有域中必须唯一
			name = "Kali-linux",

			-- 指定远程服务器的主机:端口对
			-- 可以是DNS名称或IP地址，可选地在末尾加上 ":port"
			remote_address = "192.168.44.147:22",

			-- 是否禁用代理认证
			-- 设置为true以禁用
			-- no_agent_auth = false,

			-- 用于与远程主机认证的用户名
			username = "kali",

			-- 指定SSH连接认证文件
			-- 默认认证文件是 "~/.ssh/id_rsa"
			ssh_option = {
				identityfile = get_home_dir() .. "/.ssh/id_rsa",
			},
		},
	},

	unix_domains = {},

	wsl_domains = {},
}
