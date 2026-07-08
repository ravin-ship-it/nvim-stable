-- Disable Lua Bytecode caching on Android/Termux to fix stale filesystem cache bugs
-- (mtimes are unreliable on Android, causing Neovim to load old config states)
if vim.loader and vim.fn.has("android") == 1 then
    vim.loader.enable(false)
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
local utils = require("core.utils")
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.commands")

-- Load Plugins
local lazy_opts = {}
if vim.fn.has("android") == 1 then
    lazy_opts.performance = {
        cache = {
            enabled = false,
        },
    }
end
require("lazy").setup("plugins", lazy_opts)

-- Load Xen LiveServer (Must be at the bottom)
local status_ok, _ = pcall(require, "xen.liveserver")
if not status_ok then
    -- Silently fail if file not found, or use notify if you prefer debug info
    -- vim.notify("xen.liveserver not found", vim.log.levels.WARN)
end

-- Ensure syntax highlighting starts immediately for the first buffer
vim.schedule(function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "" then
        pcall(vim.treesitter.start, buf)
    end
end)

-- WORKAROUND: Fix Termux split scrolling glitches
-- Neovim's internal scroll optimization causes screen tearing in Termux when splits are open.
-- Forcing a full redraw on scroll events bypasses the optimization and prevents corruption.
if utils.is_android then
    vim.api.nvim_create_autocmd("WinScrolled", {
        callback = function()
            vim.cmd("redraw!")
        end,
    })
end