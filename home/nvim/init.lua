-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- LEADER
vim.g.mapleader = ","
vim.g.localleader = "\\"

-- Core config
local ok, _ = pcall(require, "core.options")
if not ok then
  vim.notify("Failed to load core.options", vim.log.levels.ERROR)
end

ok, _ = pcall(require, "core.keymaps")
if not ok then
  vim.notify("Failed to load core.keymaps", vim.log.levels.ERROR)
end

-- Load plugins
ok, _ = pcall(require("lazy").setup, "plugins")
if not ok then
  vim.notify("Failed to load plugins", vim.log.levels.ERROR)
end
