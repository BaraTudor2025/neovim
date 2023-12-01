-- Run this file as `nvim --clean -u minimal.lua`

for name, url in pairs{
  -- ADD PLUGINS _NECESSARY_ TO REPRODUCE THE ISSUE, e.g:
  -- some_plugin = 'https://github.com/author/plugin.nvim'
  'https://github.com/max397574/better-escape.nvim',
} do
  local install_path = vim.fn.fnamemodify('nvim_issue/'..name, ':p')
  if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system { 'git', 'clone', '--depth=1', url, install_path }
  end
  vim.opt.runtimepath:append(install_path)
end

-- ADD INIT.LUA SETTINGS _NECESSARY_ FOR REPRODUCING THE ISSUE
require("better_escape").setup()
vim.fn.setreg("q", vim.api.nvim_replace_termcodes("ijkijkhhhAk<esc>h", true, true, true))
vim.keymap.set("n", "Q", "@q")