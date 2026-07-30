return {
    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                -- File tree specific settings
                renderer = {
                    highlight_opened_files = "name",
                    highlight_git = true,
                    root_folder_label = false,
                },
                git = {
                    enable = true,
                    show_on_dirs = true,
                    show_on_open_dirs = true,
                },
                filters = {
                    dotfiles = false,
                    custom = { "node_modules", ".git" },
                },
                filesystem_watchers = {
                    enable = true,
                },
                actions = {
                    open_file = {
                        window_picker = {
                            enable = true,
                        },
                    },
                },
            })

            -- Refresh NvimTree (including git status) when entering its window
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("NvimTreeRefresh", { clear = true }),
                pattern = "NvimTree*",
                callback = function()
                    vim.schedule(function()
                        local api = require("nvim-tree.api")
                        if api.tree.is_visible() then
                            api.tree.reload()
                        end
                    end)
                end,
            })
        end
    },

    -- Status Line
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({ options = { theme = 'tokyonight' } })
        end
    },

    -- Diagnostic and Error Indicators
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup()
            vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { noremap = true, silent = true })
        end
    },

    -- Icon support for Neovim
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        config = function()
            require("nvim-web-devicons").setup({
                override = {
                    css = {
                        icon = "",
                        color = "#4288d0",
                        cterm_color = "65",
                        name = "css",
                    },
                },
                default = true,
            })
        end
    },

    -- Color Scheme
    {
        "folke/tokyonight.nvim",
        config = function()
            local utils = require("core.utils")
            require("tokyonight").setup({
                transparent = true,
                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })
            vim.cmd("colorscheme tokyonight")

            -- CRITICAL: Fix Termux BCE scrolling tears by using transparent backgrounds.
            -- This prevents the terminal emulator from incorrectly scrolling colored blocks across splits.
            if utils.is_android then
                vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
                vim.cmd("highlight NormalNC guibg=NONE ctermbg=NONE")
                vim.cmd("highlight EndOfBuffer guibg=NONE ctermbg=NONE")
                -- Make CursorLine transparent to prevent BCE tearing when scrolling
                vim.cmd("highlight CursorLine guibg=NONE ctermbg=NONE")
                vim.cmd("highlight CursorColumn guibg=NONE ctermbg=NONE")
            end
            
            vim.cmd("highlight Comment guifg=#808080 gui=none cterm=none") -- Disable italics for comments
            vim.cmd("highlight Function guifg=#88c0d0")

            -- Customizing File Tree Colors (nvim-tree)
            if utils.is_android then
                vim.cmd("highlight NvimTreeNormal guibg=NONE ctermbg=NONE")
                vim.cmd("highlight NvimTreeCursorLine guibg=NONE ctermbg=NONE")
            end
            vim.cmd("highlight NvimTreeFolderName guifg=#00FFFF") -- Cyan
            vim.cmd("highlight NvimTreeFileName guifg=#FCA7EA")   -- Pink
            vim.cmd("highlight NvimTreeOpenedFolderName guifg=#00FFFF")
            vim.cmd("highlight NvimTreeRootFolder guifg=#FCA7EA")

            -- Customizing Trouble Colors
            if utils.is_android then
                vim.cmd("highlight TroubleNormal guibg=NONE ctermbg=NONE")
                vim.cmd("highlight TroubleNormalNC guibg=NONE ctermbg=NONE")
            end

            -- CRITICAL: Make separators completely transparent to avoid drawing boundaries that tear
            if utils.is_android then
                vim.cmd("highlight WinSeparator guibg=NONE ctermbg=NONE guifg=#4288d0 ctermfg=4")
                vim.cmd("highlight VertSplit guibg=NONE ctermbg=NONE guifg=#4288d0 ctermfg=4")
                vim.cmd("highlight NvimTreeWinSeparator guibg=NONE ctermbg=NONE guifg=#4288d0 ctermfg=4")
                
                -- Make sure side columns don't have backgrounds that drag during scrolling
                vim.cmd("highlight SignColumn guibg=NONE ctermbg=NONE")
                vim.cmd("highlight FoldColumn guibg=NONE ctermbg=NONE")
                vim.cmd("highlight StatusLine guibg=NONE ctermbg=NONE")
                vim.cmd("highlight StatusLineNC guibg=NONE ctermbg=NONE")
            end
        end
    },
}
