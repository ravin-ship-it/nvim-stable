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

            -- Helper to support single-file mode by falling back to the current file's directory
            local function make_root_dir(markers)
                return function(bufnr)
                    local root = vim.fs.root(bufnr, markers)
                    if root then return root end
                    local bufname = vim.api.nvim_buf_get_name(bufnr)
                    if bufname and bufname ~= "" then
                        return vim.fs.dirname(bufname)
                    end
                    return vim.fn.getcwd()
                end
            end

            -- Configure inline error messages (live diagnostics)
            vim.diagnostic.config({
                virtual_text = false,           -- Disable ghostly inline error messages
                float = { border = "rounded" }, -- Floating diagnostics window style
                signs = true,                   -- Show error signs in gutter
                underline = true,               -- Underline errors
                update_in_insert = true,        -- Enable live error updating while typing (Insert mode)
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
                root_dir = make_root_dir({ ".git" }),
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
                            wrapLineLength = 0,
                            contentUnformatted = "pre, code, textarea",
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
                            completeFunctionCalls = false,
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
                root_dir = make_root_dir({ ".git" }),
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
                root_dir = make_root_dir({ ".git" }),
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
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
                root_dir = make_root_dir({ "package.json", "tsconfig.json", "jsconfig.json", ".git" }),
                capabilities = capabilities,
                settings = {
                    javascript = {
                        validate = true,
                        suggest = {
                            completeFunctionCalls = false,
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithObjectLiteralText = true,
                            includeCompletionsWithClassMemberSnippets = true,
                        },
                        format = { enable = true },
                        implicitProjectConfig = { checkJs = true },
                    },
                    typescript = {
                        validate = true,
                        suggest = {
                            completeFunctionCalls = false,
                            includeCompletionsForModuleExports = true,
                            includeCompletionsWithObjectLiteralText = true,
                            includeCompletionsWithClassMemberSnippets = true,
                        },
                        format = { enable = true },
                    },
                },
            }

            vim.lsp.enable("ts_ls")

            -- Configure JSON LSP
            vim.lsp.config.jsonls = {
                cmd = { "vscode-json-language-server", "--stdio" },
                filetypes = { "json", "jsonc" },
                root_dir = make_root_dir({ ".git" }),
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
                root_dir = make_root_dir({ ".git", "pyproject.toml", "setup.py" }),
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
                root_dir = make_root_dir({ ".git", "compile_commands.json" }),
                capabilities = capabilities,
            }

            vim.lsp.enable("clangd")

            -- Configure Golang LSP
            vim.lsp.config.gopls = {
                cmd = { "gopls" },
                filetypes = { "go", "gomod", "gowork", "gotmpl" },
                root_dir = make_root_dir({ "go.mod", ".git" }),
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
                root_dir = make_root_dir({ "Cargo.toml", "rust-project.json" }),
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
                cmd = { "proot", "-0", "zls" },
                filetypes = { "zig", "zir" },
                root_dir = make_root_dir({ "zls.json", "build.zig", ".git" }),
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
            local tailwind_cmd = { "tailwindcss-language-server", "--stdio" }
            if is_android then
                tailwind_cmd = { "node", "/data/data/com.termux/files/usr/bin/tailwindcss-language-server", "--stdio" }
            end

            vim.lsp.config.tailwindcss = {
                cmd = tailwind_cmd,
                filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
                root_dir = make_root_dir({ "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "postcss.config.ts", "package.json", "node_modules", ".git" }),
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
                                require("core.utils").smart_format({ bufnr = args.buf, timeout_ms = 5000 })
                            end,
                        })
                    end
                end,
            })
        end,
    },
}
