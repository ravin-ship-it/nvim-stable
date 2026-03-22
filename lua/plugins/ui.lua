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
                filters = {
                    dotfiles = false,
                    custom = { "node_modules", ".git" },
                },
                filesystem_watchers = {
                    enable = false,
                },
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
        dependencies = { "kyazdani42/nvim-web-devicons" },
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
            vim.cmd("colorscheme tokyonight")

            -- Background color and highlighting settings
            vim.cmd("highlight Normal guibg=black")
            vim.cmd("highlight Comment guifg=#808080 gui=none cterm=none") -- Disable italics for comments
            vim.cmd("highlight Function guifg=#88c0d0")

            -- Customizing File Tree Colors (nvim-tree)
            vim.cmd("highlight NvimTreeNormal guibg=black")
            vim.cmd("highlight NvimTreeFolderName guifg=#00FFFF") -- Cyan
            vim.cmd("highlight NvimTreeFileName guifg=#FCA7EA")   -- Pink
            vim.cmd("highlight NvimTreeOpenedFolderName guifg=#00FFFF")
            vim.cmd("highlight NvimTreeRootFolder guifg=#FCA7EA")

            -- Customizing Trouble Colors
            vim.cmd("highlight TroubleNormal guibg=black")
            vim.cmd("highlight TroubleNormalNC guibg=black")
        end
    },
}
