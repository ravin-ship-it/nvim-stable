-- ============================================================================
-- Autocommands (organized with augroups for clean re-sourcing)
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Enable Treesitter Highlighting (Neovim 0.12+)
autocmd("FileType", {
    group = augroup("TreesitterHighlight", { clear = true }),
    callback = function(ev)
        -- Skip if already active
        if vim.treesitter.highlighter.active[ev.buf] then return end

        -- Don't highlight very large files to avoid lag
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
        if ok and stats and stats.size > max_filesize then
            return
        end

        -- Don't attach Treesitter to special UI buffers (like NvimTree)
        local bt = vim.bo[ev.buf].buftype
        if bt ~= "" then return end

        -- Only start treesitter if the filetype is defined
        local ft = vim.bo[ev.buf].filetype
        if ft == "" then return end

        -- Try to start treesitter highlighting silently
        pcall(vim.treesitter.start, ev.buf)
    end,
})

-- SCSS/SASS-specific indentation (consolidated from two separate autocmds)
autocmd("FileType", {
    group = augroup("SassIndent", { clear = true }),
    pattern = { "scss", "sass" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
    end,
})

-- Reset htmlangular filetype to html
autocmd("FileType", {
    group = augroup("HtmlAngularFix", { clear = true }),
    pattern = "htmlangular",
    callback = function()
        vim.bo.filetype = "html"
    end,
})

-- Fix HTML indentation
autocmd("FileType", {
    group = augroup("HtmlIndentFix", { clear = true }),
    pattern = "html",
    callback = function()
        vim.opt_local.smartindent = false
        -- The built-in HTML indent script is usually better than Tree-sitter for HTML
        vim.cmd("runtime! indent/html.vim")
    end,
})

-- ============================================================================
-- Autosave Feature
-- ============================================================================
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
        -- CRITICAL: vim.cmd must be inside vim.schedule when called from a timer callback.
        -- Without this, vim.cmd("write") crashes with E565 or causes random corruption.
        vim.schedule(function()
            if autosave_enabled and vim.bo.modified and vim.fn.expand("%") ~= "" then
                vim.cmd("write")
                vim.notify("File saved successfully", vim.log.levels.INFO, { title = "AutoSave" })
            end
        end)
    end)
end

autocmd({ "TextChanged", "TextChangedI" }, {
    group = augroup("AutoSave", { clear = true }),
    callback = function()
        if autosave_enabled then
            start_autosave_timer()
        end
    end,
})

-- ============================================================================
-- Terminal Settings (single source of truth — replaces 3 duplicate blocks)
-- ============================================================================
autocmd("TermOpen", {
    group = augroup("TerminalSettings", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.scrollback = 10000
        vim.bo.bufhidden = "hide"
        vim.bo.swapfile = false
        vim.cmd("startinsert")
    end,
})

-- NOTE: The old BufEnter autocmd that force-killed ALL terminal buffers whenever
-- you switched to a non-terminal buffer has been REMOVED. That was destroying
-- running processes, dev servers, and shell sessions on every buffer switch.

-- ============================================================================
-- General Autocmds
-- ============================================================================

-- Highlight on Yank
autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Auto-reload files when changed outside
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = augroup("AutoReload", { clear = true }),
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})

-- Force refresh after external file change
-- NOTE: Removed nvim_exec_autocmds('BufEnter') cascade that triggered ALL BufEnter
-- handlers (including the old terminal-killing one) — just redraw is sufficient.
autocmd("FileChangedShellPost", {
    group = augroup("FileChangeRefresh", { clear = true }),
    pattern = "*",
    callback = function()
        vim.cmd("redraw!")
    end,
})

-- Automatically resize splits when the window is resized
autocmd("VimResized", {
    group = augroup("AutoResize", { clear = true }),
    desc = "Automatically resize splits when terminal is resized",
    callback = function()
        local current_tab = vim.fn.tabpagenr()

        -- ToggleTerm sets winfixwidth/height which prevents resizing. Disable temporarily.
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            vim.wo[win].winfixwidth = false
            vim.wo[win].winfixheight = false
        end

        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)

        -- Re-apply winfix settings for toggleterm windows
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "toggleterm" then
                local width = vim.api.nvim_win_get_width(win)
                if width >= vim.o.columns - 2 then
                    vim.wo[win].winfixheight = true
                else
                    vim.wo[win].winfixwidth = true
                end
            end
        end
    end,
})
