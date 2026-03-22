return {
    -- none-ls
    {
        "nvimtools/none-ls.nvim",
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
                    command = "htmlhint",
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

            null_ls.setup({
                sources = {
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
                    htmlhint,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        local group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
                        vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = group,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ async = false })
                            end,
                        })
                    end
                end,
            })
        end,
    },
}
