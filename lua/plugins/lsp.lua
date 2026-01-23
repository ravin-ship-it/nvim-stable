return {
    -- SchemaStore (json specific tool)
    {
        "b0o/SchemaStore.nvim",
    },

    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
    },

    -- LSP and diagnostics setup using vim.lsp.config (nvim 0.11+)
    {
        "neovim/nvim-lspconfig",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            -- Enable inline error messages
            vim.diagnostic.config({
                virtual_text = false, -- Disable ghostly inline error messages
                float = { border = "rounded" },           -- Floating diagnostics window style
                signs = true,                             -- Show error signs in gutter
                underline = true,                         -- Underline errors
                update_in_insert = false,                 -- Avoid updates while typing
            })

            -- Function to setup formatting on save
            ---@diagnostic disable-next-line: unused-function, unused-local
            local function setup_format_on_save(client, bufnr)
                if client.server_capabilities.documentFormattingProvider then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end,
                    })
                end
            end

            -- Common capabilities with snippet support
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            -- Ensure cmp_nvim_lsp is available since it is a dependency
            local status_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            if status_cmp then
                capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
            end

            -- Configure HTML LSP
            vim.lsp.config.html = {
                cmd = { "vscode-html-language-server", "--stdio" },
                filetypes = { "html" },
                root_markers = { ".git" },
                capabilities = capabilities,
                init_options = {
                    provideFormatter = true,
                    embeddedLanguages = {
                        css = true,
                        javascript = true,
                    },
                    configurationSection = { "html", "css", "javascript" },
                },
                settings = {
                    html = {
                        validate = true,
                        format = { enable = true, indentWidth = 4, wrapLineLength = 0, contentUnformatted = "code" },
                        hover = true,
                        completion = true,
                        autoClosingTags = true,
                        suggest = {
                            html5 = true,
                            classAttribute = true,
                            idAttribute = true,
                        },
                    },
                    css = { validate = true },
                    javascript = { validate = true },
                },
            }

            vim.lsp.enable("html")

            -- Configure CSS/SCSS/SASS LSP
            vim.lsp.config.cssls = {
                cmd = { "vscode-css-language-server", "--stdio" },
                filetypes = { "css", "scss", "sass" },
                root_markers = { ".git" },
                capabilities = capabilities,
                settings = {
                    css = { validate = true },
                    scss = { validate = true },
                    sass = { validate = true },
                },
            }

            vim.lsp.enable("cssls")

            -- Configure Lua LSP
            vim.lsp.config.lua_ls = {
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                root_markers = { ".git" },
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = {
                            enable = true,
                            globals = { "vim" }, -- Prevent "undefined vim" warnings
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        format = { enable = true },
                    },
                },
            }

            vim.lsp.enable("lua_ls")

            -- Configure TypeScript/JavaScript LSP
            vim.lsp.config.ts_ls = {
                cmd = { "typescript-language-server", "--stdio" },
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
                root_markers = { "package.json", "tsconfig.json", ".git" },
                capabilities = capabilities,
                settings = {
                    javascript = {
                        validate = true,
                        suggest = { completeFunctionCalls = true },
                        format = { enable = true },
                        implicitProjectConfig = { strict = true },
                    },
                    typescript = {
                        validate = true,
                        suggest = { completeFunctionCalls = true },
                        format = { enable = true },
                        implicitProjectConfig = { strict = true },
                    },
                },
            }

            vim.lsp.enable("ts_ls")

            -- Configure JSON LSP
            vim.lsp.config.jsonls = {
                cmd = { "vscode-json-language-server", "--stdio" },
                filetypes = { "json", "jsonc" },
                root_markers = { ".git" },
                capabilities = capabilities,
                settings = {
                    json = {
                        validate = { enable = true },
                        schemas = require('schemastore').json.schemas(),
                        schemaStore = {
                            enable = true,
                            url = "https://www.schemastore.org/api/json/catalog.json",
                        },
                    },
                },
            }

            vim.lsp.enable("jsonls")

            -- Configure Python LSP (pylsp)
            vim.lsp.config.pylsp = {
                cmd = { "pylsp" },
                filetypes = { "python" },
                root_markers = { ".git", "pyproject.toml", "setup.py" },
                capabilities = capabilities,
                settings = {
                    pylsp = {
                        plugins = {
                            pyflakes = { enabled = true }, -- Enable Pyflakes for linting
                            yapf = { enabled = true },     -- Enable YAPF for formatting
                            -- Additional plugins like 'mypy' can be configured here
                        },
                    },
                },
            }

            vim.lsp.enable("pylsp")

            -- Configure C++ LSP (clangd)
            vim.lsp.config.clangd = {
                cmd = { "clangd", "--background-index" },
                filetypes = { "c", "cpp", "objc", "objcpp" },
                root_markers = { ".git", "compile_commands.json" },
                capabilities = capabilities,
            }

            vim.lsp.enable("clangd")

            -- Configure Golang LSP
            vim.lsp.config.gopls = {
                cmd = { "gopls" },
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                root_markers = { "go.mod", ".git" },
                capabilities = capabilities,
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                            unreachable = true,
                        },
                        staticcheck = true,
                    },
                },
            }

            vim.lsp.enable("gopls")

            -- Configure Rust LSP
            vim.lsp.config.rust_analyzer = {
                cmd = { "rust-analyzer" },
                filetypes = { "rust" },
                root_markers = { "Cargo.toml", "rust-project.json" },
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                        },
                        check = {
                            command = "clippy",
                        },
                        rustfmt = {
                            enableRangeFormatting = true,
                        },
                    },
                },
            }

            vim.lsp.enable("rust_analyzer")

            -- Configure Java LSP (jdtls)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function()
                    local jdtls_path = "/data/data/com.termux/files/home/.local/share/jdtls/bin/jdtls"
                    local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
                    local root_dir = require("jdtls.setup").find_root(root_markers)
                    if root_dir == "" then
                        root_dir = vim.fn.getcwd()
                    end

                    local workspace_folder = "/data/data/com.termux/files/home/.local/share/jdtls-workspace/" ..
                        vim.fn.fnamemodify(root_dir, ":p:h:t")

                    local config = {
                        cmd = { jdtls_path, "-data", workspace_folder },
                        root_dir = root_dir,
                        capabilities = capabilities,
                    }
                    require("jdtls").start_or_attach(config)
                end,
            })

            -- Setup format on save for all LSP clients
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.server_capabilities.documentFormattingProvider then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = args.buf,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 5000 })
                            end,
                        })
                    end
                end,
            })
        end,
    },
}
