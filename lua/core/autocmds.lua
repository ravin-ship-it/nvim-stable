-- Enable Treesitter Highlighting (Neovim 0.12+ 2026 update)
vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufWinEnter" }, {
    callback = function(ev)
        -- Skip if already active
        if vim.treesitter.highlighter.active[ev.buf] then return end

        -- Don't highlight very large files to avoid lag
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
        if ok and stats and stats.size > max_filesize then
            return
        end

        -- Don't attach Treesitter to special UI buffers (like NvimTree) to prevent rendering glitches
        local bt = vim.bo[ev.buf].buftype
        if bt ~= "" then return end

        -- Only start treesitter if the filetype is defined and known
        local ft = vim.bo[ev.buf].filetype
        if ft == "" then return end

        -- Try to start treesitter highlighting silently
        pcall(vim.treesitter.start, ev.buf)
    end,
})

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

-- Fix HTML indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "html",
    callback = function()
        vim.opt_local.smartindent = false
        -- The built-in HTML indent script is usually better than Tree-sitter for HTML
        vim.cmd("runtime! indent/html.vim")
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
  autocmd BufEnter term://* setlocal scrollback=10000  " Ensure scrollback is set
  autocmd BufEnter term://* setlocal mouse=a  " Enable mouse interactions
  augroup END
]])

-- Auto-command to set terminal keymaps when regular terminal opens
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function(ev)
        vim.cmd('setlocal norelativenumber nonumber') -- Disable line numbers
        vim.cmd('setlocal scrollback=10000')          -- Ensure scrollback is set
        vim.cmd('setlocal mouse=a')                   -- Enable mouse interactions
        vim.cmd('startinsert')                        -- Start in insert/terminal mode
    end,
})

-- Terminal Mode Lock (Old duplicate removed, combined above)
-- vim.api.nvim_create_autocmd('TermOpen', {

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

-- Auto-reload files when changed outside
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})

-- Force refresh plugins after external file change
vim.api.nvim_create_autocmd('FileChangedShellPost', {
    pattern = '*',
    callback = function()
        vim.cmd('redraw!')
        -- Trigger BufEnter again to wake up plugins like ccc
        vim.api.nvim_exec_autocmds('BufEnter', { group = nil })
    end,
})

-- Auto-refresh nvim-tree when entering its window
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "NvimTree*",
    callback = function()
        require("nvim-tree.api").tree.reload()
    end,
})

-- Automatically resize splits when the window is resized
vim.api.nvim_create_autocmd("VimResized", {
    desc = "Automatically resize splits when terminal is resized",
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        
        -- ToggleTerm sets winfixwidth/height which prevents resizing. Disable it temporarily.
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            vim.wo[win].winfixwidth = false
            vim.wo[win].winfixheight = false
        end
        
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
        
        -- Re-apply winfix settings for toggleterm windows based on their proportions
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "toggleterm" then
                local width = vim.api.nvim_win_get_width(win)
                local height = vim.api.nvim_win_get_height(win)
                -- If it spans full width, it's likely a horizontal split
                if width >= vim.o.columns - 2 then
                    vim.wo[win].winfixheight = true
                else
                    vim.wo[win].winfixwidth = true
                end
            end
        end
    end,
})
