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

            -- Note: In the new 'main' branch, setup is on the main module
            require("nvim-treesitter").setup({
                -- Add ensure_installed to automatically install common languages
                ensure_installed = { 
                    "bash", "c", "cpp", "lua", "vim", "vimdoc", "query", 
                    "rust", "go", "javascript", "typescript", "html", "css",
                    "json", "yaml", "markdown", "markdown_inline", "python"
                },
                
                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                auto_install = true,

                highlight = {
                    enable = true,              -- CRITICAL: Highlighting is disabled by default
                    additional_vim_regex_highlighting = false,
                },

                -- Add standard indentation module too
                indent = {
                    enable = true,
                },

                install_dir = parser_install_dir,
            })
        end,
    },
}
