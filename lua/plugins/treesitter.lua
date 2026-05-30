return {
    -- Syntax Highlighting (Neovim 0.12+ 2026 update)
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        priority = 1000,
        build = ":TSUpdate",
        config = function()
            local utils = require("core.utils")
            local parser_install_dir = vim.fn.stdpath("data") .. "/site"
            
            -- Ensure the directory is in the runtimepath so Neovim can find the parsers
            vim.opt.runtimepath:prepend(parser_install_dir)

            -- The new main branch setup
            -- Use git instead of curl (more stable on PC/Windows)
            local has_tree_sitter = vim.fn.executable("tree-sitter") == 1
            
            require("nvim-treesitter").setup({
                install_dir = parser_install_dir,
                prefer_git = true,
                -- Only auto-install if we have the necessary tools on PC
                auto_install = utils.is_android or has_tree_sitter,
            })

            -- Automatically install common parsers asynchronously
            -- Note: 'vimdoc', 'vim', 'lua', 'c', and 'query' are bundled with Neovim 0.10+
            local parsers = { 
                "bash", "cpp", "rust", "go", "javascript", "typescript", 
                "html", "css", "scss", "json", "yaml", "markdown", 
                "markdown_inline", "python"
            }
            
            -- Only add bundled parsers if we have the tree-sitter CLI or if on Android
            if utils.is_android or has_tree_sitter then
                vim.list_extend(parsers, { "c", "lua", "vim", "vimdoc", "query" })
            end
            
            -- CRITICAL: On PC, if tree-sitter CLI is missing, skip the install call 
            -- to prevent the "ENOENT: tree-sitter" error spam.
            if utils.is_android or has_tree_sitter then
                pcall(function()
                    require("nvim-treesitter").install(parsers)
                end)
            else
                -- Notify the user once that they need the CLI for full functionality on PC
                vim.schedule(function()
                    vim.notify("Treesitter: 'tree-sitter' CLI not found. Automatic parser installation disabled on PC.", vim.log.levels.WARN)
                end)
            end
        end,
    },
}
