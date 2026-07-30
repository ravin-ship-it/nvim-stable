return {
    -- none-ls
    {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvimtools/none-ls-extras.nvim",
        },
        config = function()
            local null_ls = require("null-ls")
            local helpers = require("null-ls.helpers")
            local eslint = require("none-ls.diagnostics.eslint")

            -- Set default config path if not set
            if not vim.g.htmlhint_config then
                vim.g.htmlhint_config = vim.fn.stdpath("config") .. "/linter_configs/html5.json"
            end

            -- Define custom htmlhint source
            local htmlhint = {
                method = null_ls.methods.DIAGNOSTICS,
                filetypes = { "html" },
                generator = null_ls.generator({
                    command = (vim.fn.executable("htmlhint") == 1 and "htmlhint") or
                        (vim.fn.stdpath("data") .. "/mason/bin/htmlhint"),
                    -- Dynamic args to read from global variable
                    args = function()
                        return { "--format=unix", "--config", vim.g.htmlhint_config, "stdin" }
                    end,
                    to_stdin = true,
                    from_stderr = false,
                    format = "line",
                    check_exit_code = function(code)
                        return code <= 1
                    end,
                    on_output = helpers.diagnostics.from_pattern(
                        "^stdin:(%d+):(%d+): (.+) %[(.+)%]$",
                        { "row", "col", "message", "code" },
                        {
                            severities = {
                                ["error"] = vim.diagnostic.severity.ERROR,
                                ["warning"] = vim.diagnostic.severity.WARN,
                            },
                        }
                    ),
                }),
            }

            local sources = {
                null_ls.builtins.formatting.clang_format.with({
                    filetypes = { "java" },
                    extra_args = { "--style={BasedOnStyle:Google,IndentWidth:4,ColumnLimit:0,BreakBeforeBinaryOperators:None}" },
                }),
                eslint.with({
                    diagnostics_format = "[eslint] #{m}\n(#{c})",
                    condition = function(utils)
                        return utils.root_has_file({
                            ".eslintrc",
                            ".eslintrc.js",
                            ".eslintrc.cjs",
                            ".eslintrc.yaml",
                            ".eslintrc.yml",
                            ".eslintrc.json",
                        })
                    end,
                }),
            }

            if vim.fn.executable("htmlhint") == 1 or
                vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/htmlhint") == 1 then
                table.insert(sources, htmlhint)
            end

            null_ls.setup({
                sources = sources,
                -- NOTE: Format-on-save is handled globally by LspAttach in lsp.lua
                -- This covers ALL LSP clients (jsonls, cssls, etc.), not just none-ls.
            })
        end,
    },
}
