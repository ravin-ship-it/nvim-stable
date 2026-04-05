return {
    -- Syntax Highlighting (Neovim 0.12+ 2026 update)
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        priority = 1000,
        build = ":TSUpdate",
        config = function()
            -- Note: In the new 'main' branch, setup is on the main module
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })
        end,
    },
}
