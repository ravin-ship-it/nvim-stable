-- Disable Lua Bytecode caching permanently to fix Android/Termux filesystem bugs
if vim.loader then
    vim.loader.disable()
end

-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- ADDED: Ensure custom treesitter parsers are in the runtimepath for all modules
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/site")

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

-- Ensure syntax highlighting starts immediately for the first buffer
vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype ~= "" then
        pcall(vim.treesitter.start, buf)
    end
end)