-- SCSS-specific indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "scss",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
    end,
})

-- SASS-specific indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "sass",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
    end,
})

-- Autocommand for resetting HTML filetype from htmlangular to html
vim.api.nvim_create_autocmd("FileType", {
    pattern = "htmlangular",
    callback = function()
        vim.cmd("set filetype=html")
    end,
})

-- Autocommand for autosaving feature
local autosave_enabled = false
local autosave_timer = nil

vim.api.nvim_create_user_command("AS", function()
    autosave_enabled = not autosave_enabled
    vim.notify("AutoSave: " .. (autosave_enabled and "ON" or "OFF"))
end, {})

local function start_autosave_timer()
    if autosave_timer then
        vim.fn.timer_stop(autosave_timer)
    end

    autosave_timer = vim.fn.timer_start(1000, function()
        if autosave_enabled and vim.bo.modified and vim.fn.expand("%") ~= "" then
            vim.cmd("write") -- Save file (and trigger format on save if you configured it)
            vim.schedule(function()
                vim.notify("File saved successfully", vim.log.levels.INFO, { title = "AutoSave" })
            end)
        end
    end)
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    callback = function()
        if autosave_enabled then
            start_autosave_timer()
        end
    end,
})

-- Fix for terminal buffer settings
vim.cmd([[
  augroup TerminalBufferSettings
  autocmd!
  autocmd BufEnter term://* setlocal nonumber norelativenumber
  autocmd BufEnter term://* setlocal bufhidden=hide
  autocmd BufEnter term://* setlocal noswapfile
  autocmd BufEnter term://* setlocal signcolumn=no
  autocmd BufEnter term://* setlocal scrollback=10000  -- Ensure scrollback is set
  autocmd BufEnter term://* setlocal mouse=a  -- Enable mouse interactions
  augroup END
]])

-- Terminal Mode Lock
vim.api.nvim_create_autocmd('TermOpen', {
    pattern = 'term://*',
    callback = function()
        vim.cmd('setlocal norelativenumber nonumber') -- Disable line numbers
        vim.cmd('setlocal scrollback=10000')          -- Ensure scrollback is set
        vim.cmd('setlocal mouse=a')                   -- Enable mouse interactions
    end,
})

-- Prevent extra terminal windows from opening
vim.cmd([[
  autocmd WinEnter * if &buftype == 'terminal' | setlocal norelativenumber | endif
]])

-- Ensure terminal buffers are not affected by file tree expansion
vim.cmd([[
  autocmd WinEnter term://* setlocal noswapfile
  autocmd WinEnter term://* setlocal bufhidden=hide
]])

-- Close terminal when switching to another buffer
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_type = vim.bo[current_buf].buftype
        if buf_type ~= 'terminal' then
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
                    vim.api.nvim_buf_delete(buf, { force = true }) -- Close terminal buffer
                end
            end
        end
    end,
})

-- Highlight on Yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
