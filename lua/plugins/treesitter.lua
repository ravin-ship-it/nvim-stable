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
            require("nvim-treesitter").setup({
                install_dir = parser_install_dir,
                prefer_git = true,
                auto_install = true,
            })

            -- Automatically install common parsers asynchronously
            -- Note: 'vimdoc', 'vim', 'lua', 'c', and 'query' are bundled with Neovim 0.10+
            local parsers = { 
                "bash", "cpp", "rust", "go", "javascript", "typescript", 
                "html", "css", "scss", "json", "yaml", "markdown", 
                "markdown_inline", "python"
            }
            
            -- Only add bundled parsers if we have the tree-sitter CLI or if on Android
            -- On PC, 'vimdoc' often requires the CLI to build, which causes ENOENT
            if utils.is_android or vim.fn.executable("tree-sitter") == 1 then
                vim.list_extend(parsers, { "c", "lua", "vim", "vimdoc", "query" })
            end
            
            -- Pcall so it doesn't crash on startup if offline or if tree-sitter CLI is missing
            pcall(function()
                require("nvim-treesitter").install(parsers)
            end)
        end,
    },
}
