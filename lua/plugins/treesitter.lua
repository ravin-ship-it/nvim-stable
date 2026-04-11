return {
    -- Syntax Highlighting (Neovim 0.12+ 2026 update)
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        priority = 1000,
        build = ":TSUpdate",
        config = function()
            local parser_install_dir = vim.fn.stdpath("data") .. "/site"
            
            -- Ensure the directory is in the runtimepath so Neovim can find the parsers
            vim.opt.runtimepath:prepend(parser_install_dir)

            -- The new main branch setup
            require("nvim-treesitter").setup({
                install_dir = parser_install_dir,
            })

            -- Automatically install common parsers asynchronously
            local parsers = { 
                "bash", "c", "cpp", "lua", "vim", "vimdoc", "query", 
                "rust", "go", "javascript", "typescript", "html", "css",
                "scss", "json", "yaml", "markdown", "markdown_inline", "python"
            }
            
            -- Pcall so it doesn't crash on startup if offline
            pcall(function()
                require("nvim-treesitter").install(parsers)
            end)
        end,
    },
}
