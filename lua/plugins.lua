return {
    -- Other plugins
    {
        "taketwo/vim-live-server",
        config = function()
            -- Optional: Add custom settings here
        end,
    },

    -- LSP configuration (Add this block)
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lspconfig").jdtls.setup({}) -- Ensure JDTLS is set up properly

            -- Diagnostic settings
            vim.diagnostic.config({
                virtual_text = false,          -- Hide inline diagnostics
                signs = true,                  -- Keep signs in the gutter
                float = { border = "rounded" } -- Prettier floating diagnostics
            })

            -- Show diagnostics on hover
            vim.o.updatetime = 250
            vim.api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = function()
                    vim.diagnostic.open_float(nil, { focus = false })
                end,
            })

            -- Keybindings for diagnostics navigation
            vim.keymap.set("n", "<leader>l", vim.diagnostic.open_float, { desc = "Show Diagnostics" })
        end,
    },
}
