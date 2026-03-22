-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load Core Settings
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.commands")

-- Load Plugins
require("lazy").setup("plugins")

-- Load Xen LiveServer (Must be at the bottom)
local status_ok, _ = pcall(require, "xen.liveserver")
if not status_ok then
    -- Silently fail if file not found, or use notify if you prefer debug info
    -- vim.notify("xen.liveserver not found", vim.log.levels.WARN)
end