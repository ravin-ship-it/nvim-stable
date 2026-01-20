return {
    -- Syntax Highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Required fields (new)
                modules = {},
                sync_install = false,
                auto_install = true,
                ignore_install = {},

                -- Treesitter settings
                ensure_installed = {
                    "html",
                    "css",
                    "scss",
                    "javascript",
                    "typescript",
                    "java",
                    "json",
                    "lua",
                    "python",
                    "asm", -- Assembly
                    "go",
                    "cpp",  -- C++
                    "rust"
                },
                highlight = { enable = true },
                -- indent = { enable = true }, -- you can enable this if you want
            })
        end
    },
}
