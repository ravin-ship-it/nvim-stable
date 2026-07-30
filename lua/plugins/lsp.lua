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
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            not require("core.utils").is_android and "williamboman/mason-lspconfig.nvim" or nil,
        },
        config = function()
            -- Initialize mason-lspconfig to bridge Mason and lspconfig
            local is_android = require("core.utils").is_android
            if not is_android then
                local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
                if status_ok then
                    mason_lspconfig.setup()
                end
            end

            -- Configure inline error messages
            vim.diagnostic.config({
                virtual_text = false,           -- Disable ghostly inline error messages
                float = { border = "rounded" }, -- Floating diagnostics window style
                signs = true,                   -- Show error signs in gutter
                underline = true,               -- Underline errors
                update_in_insert = false,       -- Avoid updates while typing
            })

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
                        format = {
                            enable = true,
                            indentWidth = 4,
                            wrapLineLength = 999999, -- large number effectively disables wrapping
                            wrapAttributes = "preserve",
                            contentUnformatted = "pre, code, textarea, p",
                        },
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
                    javascript = {
                        validate = true,
                        suggest = {
                            completeFunctionCalls = true,
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithObjectLiteralText = true,
                            includeCompletionsWithClassMemberSnippets = true,
                        },
                        format = { enable = true },
                        implicitProjectConfig = { checkJs = true },
                    },
                }

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
                            library = { vim.env.VIMRUNTIME },
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
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
                capabilities = capabilities,
                init_options = {
                    preferences = {
                        includeCompletionsWithSnippetText = true,
                        includeCompletionsForImportStatements = true,
                        importModuleSpecifierPreference = "relative",
                    },
                    hostInfo = "neovim",
                },
                settings = {
                    javascript = {
                        validate = true,
                        suggest = {
                            completeFunctionCalls = true,
                            autoImports = true,
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithObjectLiteralText = true,
                            includeCompletionsWithClassMemberSnippets = true,
                            includeAutomaticOptionalChainCompletions = true,
                        },
                        format = { enable = false }, -- let prettier/eslint handle formatting
                        implicitProjectConfig = {
                            checkJs = true,
                            experimentalDecorators = true,
                        },
                        inlayHints = {
                            includeInlayParameterNameHints = "literals",
                        },
                    },
                    typescript = {
                        validate = true,
                        suggest = {
                            completeFunctionCalls = true,
                            autoImports = true,
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithObjectLiteralText = true,
                            includeCompletionsWithClassMemberSnippets = true,
                            includeAutomaticOptionalChainCompletions = true,
                        },
                        format = { enable = false }, -- let prettier/eslint handle formatting
                        inlayHints = {
                            includeInlayParameterNameHints = "literals",
                        },
                    },
                    completions = {
                        completeFunctionCalls = true,
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
                        schemas = (function()
                            local ok, schemastore = pcall(require, "schemastore")
                            if ok then return schemastore.json.schemas() end
                            return {}
                        end)(),
                        -- Disable built-in schema fetching when using SchemaStore.nvim
                        schemaStore = { enable = false, url = "" },
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

            -- Configure Zig LSP (zls)
            vim.lsp.config.zls = {
                cmd = require("core.utils").is_android and { "proot", "-0", "zls" } or { "zls" },
                filetypes = { "zig", "zir" },
                root_markers = { "zls.json", "build.zig", ".git" },
                capabilities = capabilities,
                init_options = {
                    enable_build_on_save = false,
                    enable_autofix = false,
                },
                settings = {
                    zls = {
                        enable_build_on_save = false,
                        enable_autofix = false,
                    },
                },
            }

            vim.lsp.enable("zls")

            -- Configure Tailwind CSS LSP
            vim.lsp.config.tailwindcss = {
                cmd = { "tailwindcss-language-server", "--stdio" },
                filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
                root_markers = { "tailwind.config.js", "tailwind.config.ts", "tailwind.config.mjs", "tailwind.config.cjs" },
                capabilities = capabilities,
                settings = {
                    tailwindCSS = {
                        classAttributes = { "class", "className", "classList", "ngClass" },
                        lint = {
                            cssConflict = "warning",
                            invalidApply = "error",
                            invalidConfigPath = "error",
                            invalidScreen = "error",
                            invalidTailwindDirective = "error",
                            invalidVariant = "error",
                            recommendedVariantOrder = "warning",
                        },
                        validate = true,
                    },
                },
            }

            vim.lsp.enable("tailwindcss")

            -- Configure Java LSP (jdtls) — portable across Termux and Linux PC
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function()
                    local is_android = require("core.utils").is_android
                    local jdtls_path
                    if is_android then
                        jdtls_path = "/data/data/com.termux/files/home/.local/share/jdtls/bin/jdtls"
                    else
                        jdtls_path = vim.fn.exepath("jdtls")
                        if jdtls_path == "" then jdtls_path = "jdtls" end
                    end

                    local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
                    local root_dir = require("jdtls.setup").find_root(root_markers)
                    if root_dir == "" then
                        root_dir = vim.fn.getcwd()
                    end

                    local workspace_base = is_android
                        and "/data/data/com.termux/files/home/.local/share/jdtls-workspace/"
                        or (vim.fn.stdpath("data") .. "/jdtls-workspace/")
                    local workspace_folder = workspace_base .. vim.fn.fnamemodify(root_dir, ":p:h:t")

                    local config = {
                        cmd = { jdtls_path, "-data", workspace_folder },
                        root_dir = root_dir,
                        capabilities = capabilities,
                    }
                    require("jdtls").start_or_attach(config)
                end,
            })

            -- Format-on-save for ALL LSP clients (jsonls, cssls, html, none-ls, etc.)
            -- Uses per-buffer augroups to avoid the bug where attaching to a new buffer
            -- would nuke format-on-save for all previous buffers.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/formatting", args.buf) then
                        local augroup_name = "LspFormat_" .. args.buf
                        vim.api.nvim_create_augroup(augroup_name, { clear = true })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup_name,
                            buffer = args.buf,
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
