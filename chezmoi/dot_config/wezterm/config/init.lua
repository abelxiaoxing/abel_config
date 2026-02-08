local wezterm = require("wezterm")

---@class Config
---@field options table
local Config = {}

---初始化配置
---@return Config
function Config:init()
  local o = {}
  self = setmetatable(o, { __index = Config })
  self.options = {}
  return o
end

---追加到 `Config.options`
---@param new_options table 要追加的新选项
---@return Config
function Config:append(new_options)
  for k, v in pairs(new_options) do
    if self.options[k] ~= nil then
      wezterm.log_warn(
        '检测到重复的配置选项: ',
        { old = self.options[k], new = new_options[k] }
      )
      goto continue
    end
    self.options[k] = v
    ::continue::
  end
  return self
end

return Config
