local is_android = require("core.utils").is_android

if is_android then
    return {}
end

return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    -- LSPs
                    "html-lsp",
                    "css-lsp",
                    "lua-language-server",
                    "typescript-language-server",
                    "json-lsp",
                    "python-lsp-server",
                    "clangd",
                    "gopls",
                    "rust-analyzer",
                    "tailwindcss-language-server",

                    -- Linters & Formatters
                    "htmlhint",
                    "eslint_d",
                    "clang-format",
                    "stylua",
                },
                auto_update = true,
                run_on_start = true,
            })
        end,
    },
}
