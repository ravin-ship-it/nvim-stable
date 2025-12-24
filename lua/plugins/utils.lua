return {
    -- Git Integration
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                current_line_blame = true, -- Show blame info for the current line
            })
        end,
    },

    -- Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_config = {
                        prompt_position = "top",
                    },
                    sorting_strategy = "ascending",
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                    },
                    prompt_prefix = "🔍 ",
                    selection_caret = " ",
                    path_display = { "smart" },
                    mappings = {
                        i = {
                            ["<C-n>"] = require("telescope.actions").move_selection_next,
                            ["<C-p>"] = require("telescope.actions").move_selection_previous,
                            ["<C-c>"] = require("telescope.actions").close,
                        },
                        n = {
                            ["<C-c>"] = require("telescope.actions").close,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                    },
                    live_grep = {
                        theme = "dropdown",
                    },
                },
                extensions = {},
            })
        end
    },

    -- nvim-autopairs setup
    {
        'windwp/nvim-autopairs',
        config = function()
            local autopairs = require("nvim-autopairs")
            autopairs.setup({
                check_ts = true, -- Use TreeSitter for intelligent pairing
                fast_wrap = {},
                map_cr = true,   -- Ensure Enter key is mapped correctly
            })
        end,
    },

    -- Initialize the Comment.nvim plugin
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()

            -- Import the Comment APIs
            -- Normal Mode: Toggle comments with Ctrl+/
            vim.api.nvim_set_keymap(
                "n",
                "<C-_>", -- Note: <C-_> is often used for Ctrl+/
                [[<cmd>lua require('Comment.api').toggle.linewise.current()<CR>]],
                { noremap = true, silent = true }
            )

            -- Visual Mode: Toggle comments with Ctrl+/
            vim.api.nvim_set_keymap(
                "v",
                "<C-_>",
                [[<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>]],
                { noremap = true, silent = true }
            )

            -- Insert Mode: Toggle comments with Ctrl+/ (cursor returns to insert mode)
            vim.api.nvim_set_keymap(
                "i",
                "<C-_>",
                [[<Esc><cmd>lua require('Comment.api').toggle.linewise.current()<CR>gi]],
                { noremap = true, silent = true }
            )
        end,
    },

    -- Multi-Cursor Functionality
    {
        'mg979/vim-visual-multi',
        branch = 'master',
        init = function()
            -- Remap the main multi-cursor key from Ctrl-n to something else
            vim.g.VM_maps = {
                ['Find Under'] = '<C-d>', -- Ctrl-d to select word (like VS Code)
                ['Find Subword Under'] = '<C-d>', -- Same for subword
                ['Add Cursor Down'] = '<C-Down>', -- Keep Ctrl-Down for adding cursor below
                ['Add Cursor Up'] = '<C-Up>', -- Keep Ctrl-Up for adding cursor above
            }
        end,
    },

    -- Color Picker setup
    {
        'uga-rosa/ccc.nvim',
        config = function()
            -- Set up the color picker with the default format and other configurations
            require("ccc").setup({
                default_output = "rgba", -- Set the default color format (rgba, hex, rgb, hsl, etc.)
                highlighter = {
                    auto_enable = true,  -- Automatically enable color highlighting
                },
                picker = {
                    live_preview = true,  -- Show live preview while interacting with the color picker
                    show_values = true,   -- Show the current color value next to the picker
                    use_popup = true,     -- Use a popup window for better interaction (optional)
                },
                color_suggestions = true, -- Enable suggestions for commonly used colors
            })
        end
    },

    -- Emmet for HTML, JS, CSS, SCSS, SASS, and more
    {
        "mattn/emmet-vim",
        config = function()
            vim.g.user_emmet_mode = "n"
            vim.g.user_emmet_expandabbr_key = "<C-l>" -- Set expansion key to Ctrl+L
            vim.api.nvim_set_keymap("i", "<C-l>", "<Plug>(emmet-expand-abbr)", { noremap = true, silent = true })
            vim.cmd([[autocmd FileType html,css,scss,sass,jsx,xml,js,ts,json EmmetInstall]])
        end,
    },
}
