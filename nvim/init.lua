-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.opt.clipboard = "unnamedplus"
vim.opt.wrap = true
vim.keymap.set("n", "yy", '"+yy', { noremap = true })

-- 当文本被复制时，使用 OSC 52 将其发送到本地剪贴板
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      -- 将行数组拼接成字符串，用换行符分隔
      local content = table.concat(vim.v.event.regcontents, "\n")
      -- 转义单引号用于 shell
      content = content:gsub("'", "'\\''")
      -- 构造并执行 OSC 52 命令
      vim.fn.system(
        string.format(
          "printf '\\033]52;c;%s\\007' \"$(echo -n '%s' | base64 -w0)\"",
          vim.fn.shellescape(content, true):gsub("\\'", "'\\''")
        )
      )
    end
  end,
})
