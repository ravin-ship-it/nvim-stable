-- Lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                -- File tree specific settings
                renderer = {
                    highlight_opened_files = "name",
                    highlight_git = true,
                    root_folder_label = false,
                },
                filters = {
                    dotfiles = false,
                },
            })
        end
    },

    -- Status Line
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine").setup({ options = { theme = 'tokyonight' } })
        end
    },

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
                    "cpp"  -- C++
                },
                highlight = { enable = true },
                -- indent = { enable = true }, -- you can enable this if you want
            })
        end
    },

    -- LSP and diagnostics setup based on none-ls
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")

            -- Enable inline error messages
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●", -- Symbol for inline error messages
                    spacing = 4, -- Spacing between error text and line
                    severity = vim.diagnostic.severity.ERROR, -- Show only errors inline
                },
                float = { border = "rounded" }, -- Floating diagnostics window style
                signs = true, -- Show error signs in gutter
                underline = true, -- Underline errors
                update_in_insert = false, -- Avoid updates while typing
            })

            -- Function to setup formatting on save
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
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

            -- Configure HTML LSP
            -- lspconfig.html.setup({
            --     cmd = { "vscode-html-language-server", "--stdio" },
            --     capabilities = capabilities,
            --     autostart = true,
            --     filetypes = { "html" },
            --     settings = {
            --         html = {
            --             validate = true,
            --             format = { enable = true, indentWidth = 4 },
            --             hover = true,
            --             completion = true,
            --             autoClosingTags = true,
            --             suggest = {
            --                 html5 = true,
            --                 classAttribute = true,
            --                 idAttribute = true,
            --             },
            --         },
            --         css = { validate = true },
            --         javascript = { validate = true },
            --     },
            --     on_attach = function(client, bufnr)
            --         setup_format_on_save(client, bufnr)
            --     end,
            -- })

            lspconfig.html.setup({
                cmd = { "vscode-html-language-server", "--stdio" },
                capabilities = capabilities,
                autostart = true,
                filetypes = { "html" },
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
                        format = { enable = true, indentWidth = 4, wrapLineLength = 0 },
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
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- Configure CSS/SCSS/SASS LSP
            lspconfig.cssls.setup({
                cmd = { "vscode-css-language-server", "--stdio" },
                capabilities = capabilities,
                autostart = true,
                filetypes = { "css", "scss", "sass" },
                settings = {
                    css = { validate = true },
                    scss = { validate = true },
                    sass = { validate = true },
                },
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- Configure Lua LSP
            lspconfig.lua_ls.setup({
                cmd = { "lua-language-server" },
                capabilities = capabilities,
                autostart = true,
                filetypes = { "lua" },
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
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- Configure TypeScript/JavaScript LSP
            lspconfig.ts_ls.setup({
                cmd = { "typescript-language-server", "--stdio" },
                capabilities = capabilities,
                autostart = true,
                filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html" },
                root_dir = require("lspconfig.util").root_pattern("package.json", "tsconfig.json", ".git"),
                settings = {
                    javascript = {
                        validate = true,
                        suggest = { completeFunctionCalls = true, },
                        format = { enable = true, },
                        implicitProjectConfig = { strict = true, },
                    },
                    typescript = {
                        validate = true,
                        suggest = { completeFunctionCalls = true, },
                        format = { enable = true, },
                        implicitProjectConfig = { strict = true, },
                    },
                },
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- jsonls configuration block
            lspconfig.jsonls.setup({
                cmd = { "vscode-json-language-server", "--stdio" },
                filetypes = { "json", "jsonc" },
                root_dir = lspconfig.util.root_pattern(".git", vim.fn.getcwd()),
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
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- Configure Python LSP (pylsp)
            lspconfig.pylsp.setup({
                capabilities = capabilities,
                autostart = true,
                filetypes = { "python" },
                settings = {
                    pylsp = {
                        plugins = {
                            pyflakes = { enabled = true }, -- Enable Pyflakes for linting
                            yapf = { enabled = true },     -- Enable YAPF for formatting
                            -- Additional plugins like 'mypy' can be configured here
                        },
                    },
                },
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- Configure Java LSP (jdtls)
            local jdtls_path = "/data/data/com.termux/files/home/.local/share/jdtls/bin/jdtls"
            lspconfig.jdtls.setup({
                cmd = { jdtls_path },
                -- other configurations
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- Configure C++ LSP (clangd)
            lspconfig.clangd.setup({
                capabilities = capabilities,
                autostart = true,
                filetypes = { "c", "cpp", "objc", "objcpp" },
                cmd = { "clangd", "--background-index" },
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
            })

            -- Golang Lsp setup
            lspconfig.gopls.setup({
                on_attach = function(client, bufnr)
                    setup_format_on_save(client, bufnr)
                end,
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                            unreachable = true,
                        },
                        staticcheck = true,
                    },
                },
            })

            -- Additional LSP configurations can be added here
        end,
    },

    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
    },
    {
        "mfussenegger/nvim-dap",
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = "mfussenegger/nvim-dap",
    },

    -- SchemaStore (json specific tool)
    {
        "b0o/SchemaStore.nvim",
    },

    -- Emmet for HTML, JS, CSS, SCSS, SASS, and more
    {
        "mattn/emmet-vim",
        config = function()
            vim.g.user_emmet_mode = "n"
            vim.g.user_emmet_expandabbr_key = "<C-l>" -- Set expansion key to Ctrl+L
            vim.api.nvim_set_keymap("i", "<C-l>", "<Plug>(emmet-expand-abbr)", { noremap = true, silent = true })
            vim.cmd([[autocmd FileType html,css,scss,sass,jsx,xml,js,ts,json EmmetInstall]])
        end,
    },

    -- nvim-cmp configuration for autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = {
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Up>"] = cmp.mapping.select_prev_item(),
                    ["<Down>"] = cmp.mapping.select_next_item(),
                },
                sources = cmp.config.sources({
                    {
                        name = "nvim_lsp",
                        entry_filter = function(entry)
                            -- Prevent LSP from suggesting files & folders (fixes duplicate path suggestions)
                            local kind = entry:get_kind()
                            return kind ~= cmp.lsp.CompletionItemKind.File
                                and kind ~= cmp.lsp.CompletionItemKind.Folder
                        end
                    },
                    { name = "path" },    -- Ensures correct path suggestions
                    { name = "luasnip" }, -- Snippet completion
                    { name = "buffer" },  -- Buffer completion (can be removed if unnecessary)
                }),
                experimental = {
                    ghost_text = true, -- Enables inline preview of suggestions
                },
            })
        end,
    },

    -- Snippets for Boilerplates by LuaSnip
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets"
        },
        config = function()
            local luasnip = require("luasnip")
            local types = require("luasnip.util.types")

            -- Configure LuaSnip settings
            luasnip.config.set_config({
                history = true,                            -- Enable snippet history
                updateevents = "TextChanged,TextChangedI", -- Update on text changes
                enable_autosnippets = true,                -- Enable autosnippets
                ext_opts = {
                    [types.choiceNode] = {
                        active = { virt_text = { { "●", "Error" } } },
                    },
                    [types.insertNode] = {
                        active = { virt_text = { { "●", "Comment" } } },
                    },
                },
            })

            -- Lazy-load snippets from friendly-snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Prevent Invalid 'end_row' errors
            vim.api.nvim_create_autocmd("InsertLeave", {
                pattern = "*",
                callback = function()
                    require("luasnip").unlink_current()
                end,
            })

            -- Custom snippets for Eruda and Font Awesome

            -- Eruda snippet (HTML)
            luasnip.add_snippets("html", {
                luasnip.s("eruda", {
                    luasnip.t('<script src="https://cdn.jsdelivr.net/npm/eruda"></script>'),
                    luasnip.t({ '', '<script>eruda.init();</script>' }) -- Use a table for multi-line
                }),
            })

            -- Font Awesome snippet for HTML
            luasnip.add_snippets("html", {
                luasnip.s("fa", {
                    luasnip.t(
                        '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css">'),
                }),
            })

            -- Font Awesome snippet for CSS
            luasnip.add_snippets("css", {
                luasnip.s("fa", {
                    luasnip.t(
                        '@import url("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css");'),
                }),
            })

            -- Font Awesome snippet for SCSS
            luasnip.add_snippets("scss", {
                luasnip.s("fa", {
                    luasnip.t(
                        '@import url("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css");'),
                }),
            })

            -- Font Awesome snippet for SASS
            luasnip.add_snippets("sass", {
                luasnip.s("fa", {
                    luasnip.t(
                        '@import url("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css");'),
                }),
            })

            -- MarkDown Preview
            luasnip.add_snippets("html", {
                luasnip.s("mdpreview", {
                    luasnip.t({
                        "<!DOCTYPE html>",
                        "<html>",
                        "",
                        "<head>",
                        '    <meta charset="UTF-8" />',
                        "    <title>Markdown Preview</title>",
                        '    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>',
                        '    <link href="https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css" rel="stylesheet">',
                        "    <style>",
                        "        body {",
                        "            width: 100%;",
                        "            margin: 2rem auto;",
                        "            padding: 2rem;",
                        "        }",
                        "",
                        "        .markdown-body {",
                        "            font-family: system-ui, sans-serif;",
                        "        }",
                        "    </style>",
                        "</head>",
                        "",
                        '<body class="markdown-body">',
                        '    <div id="content">Loading markdown...</div>',
                        "    <script>",
                        '        fetch("README.md")',
                        "            .then(response => response.text())",
                        "            .then(text => {",
                        '                document.getElementById("content").innerHTML = marked.parse(text);',
                        "            });",
                        "    </script>",
                        "</body>",
                        "",
                        "</html>"
                    }),
                }),
            })
        end,
    },

    -- SQL / MariaDB support
    {
        "tpope/vim-dadbod",
        cmd = { "DB", "DBUI", "DBUIToggle", "DBUIFindBuffer", "DBUIRenameBuffer", "DBUILastQueryInfo" },
        dependencies = {
            {
                "kristijanhusak/vim-dadbod-ui",
                cmd = { "DBUI", "DBUIToggle", "DBUIFindBuffer", "DBUIRenameBuffer", "DBUILastQueryInfo" },
            },
            {
                "kristijanhusak/vim-dadbod-completion",
                ft = { "sql", "mysql", "plsql" },
            },
        },
        config = function()
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "sql", "mysql", "plsql" },
                callback = function()
                    local cmp = require("cmp")
                    cmp.setup.buffer({
                        sources = {
                            { name = "vim-dadbod-completion" },
                            { name = "buffer" },
                        },
                    })
                end,
            })
        end,
    },

    -- Diagnostic and Error Indicators
    {
        "folke/trouble.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons" },
        config = function()
            require("trouble").setup()
            vim.keymap.set("n", "<leader>xx", ":TroubleToggle<CR>", { noremap = true, silent = true })
        end
    },

    -- Icon support for Neovim
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        opts = { default = true }
    },

    -- none-ls
    {
        "nvimtools/none-ls.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvimtools/none-ls-extras.nvim",
        },
        config = function()
            local null_ls = require("null-ls")
            local eslint = require("none-ls.diagnostics.eslint")

            null_ls.setup({
                sources = {
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
                    -- Add other sources as needed
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

    -- Debugging (nvim-dap)
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            -- Example configuration for debugging
            dap.adapters.node2 = {
                type = "executable",
                command = "node",
                args = { "/path/to/vscode-node-debug2/out/src/nodeDebug.js" },
            }
            dap.configurations.javascript = {
                {
                    type = "node2",
                    request = "launch",
                    name = "Launch Program",
                    program = "${file}",
                    cwd = vim.fn.getcwd(),
                },
            }
        end,
    },

    -- Git Integration
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                current_line_blame = true, -- Show blame info for the current line
            })
        end,
    },

    -- Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_config = {
                        prompt_position = "top",
                    },
                    sorting_strategy = "ascending",
                },
            })
        end,
    },

    -- nvim-autopairs setup
    {
        'windwp/nvim-autopairs',
        config = function()
            local autopairs = require("nvim-autopairs")
            autopairs.setup({
                check_ts = true, -- Use TreeSitter for intelligent pairing
                fast_wrap = {},
                map_cr = true,   -- Ensure Enter key is mapped correctly
            })
        end,
    },

    -- Initialize the Comment.nvim plugin
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()

            -- Import the Comment APIs
            -- Normal Mode: Toggle comments with Ctrl+/
            vim.api.nvim_set_keymap(
                "n",
                "<C-_>", -- Note: <C-_> is often used for Ctrl+/
                [[<cmd>lua require('Comment.api').toggle.linewise.current()<CR>]],
                { noremap = true, silent = true }
            )

            -- Visual Mode: Toggle comments with Ctrl+/
            vim.api.nvim_set_keymap(
                "v",
                "<C-_>",
                [[<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>]],
                { noremap = true, silent = true }
            )

            -- Insert Mode: Toggle comments with Ctrl+/ (cursor returns to insert mode)
            vim.api.nvim_set_keymap(
                "i",
                "<C-_>",
                [[<Esc><cmd>lua require('Comment.api').toggle.linewise.current()<CR>gi]],
                { noremap = true, silent = true }
            )
        end,
    },

    -- Color Scheme
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.cmd("colorscheme tokyonight")
        end
    },

    -- Color Picker setup
    {
        'uga-rosa/ccc.nvim',
        config = function()
            -- Set up the color picker with the default format and other configurations
            require("ccc").setup({
                default_output = "rgba", -- Set the default color format (rgba, hex, rgb, hsl, etc.)
                highlighter = {
                    auto_enable = true,  -- Automatically enable color highlighting
                },
                picker = {
                    live_preview = true,  -- Show live preview while interacting with the color picker
                    show_values = true,   -- Show the current color value next to the picker
                    use_popup = true,     -- Use a popup window for better interaction (optional)
                },
                color_suggestions = true, -- Enable suggestions for commonly used colors
            })

            -- Color CccPick
            vim.api.nvim_set_keymap("n", "<leader>cp", ":CccPick<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "<leader>ch", ":CccHighlighterToggle<CR>", { noremap = true, silent = true })
        end
    },

    -- Telescope for enhanced search
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                    },
                    prompt_prefix = "🔍 ",
                    selection_caret = " ",
                    path_display = { "smart" },
                    mappings = {
                        i = {
                            ["<C-n>"] = require("telescope.actions").move_selection_next,
                            ["<C-p>"] = require("telescope.actions").move_selection_previous,
                            ["<C-c>"] = require("telescope.actions").close,
                        },
                        n = {
                            ["<C-c>"] = require("telescope.actions").close,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                    },
                    live_grep = {
                        theme = "dropdown",
                    },
                },
                extensions = {},
            })
        end
    },

    -- Toggle Terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",                      -- Use latest stable version
        event = "VeryLazy",                 -- Load only when needed
        cmd = { "ToggleTerm", "TermExec" }, -- Commands that trigger loading
        keys = {
            { "<C-t>",      desc = "Toggle terminal" },
            { "<leader>tf", desc = "Terminal float" },
            { "<leader>tv", desc = "Terminal vertical" },
            { "<leader>th", desc = "Terminal horizontal" },
        },
        config = function()
            require("toggleterm").setup({
                -- Main settings
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = [[<C-t>]],
                direction = "float", -- Default direction

                -- Terminal behavior
                start_in_insert = true,
                insert_mappings = true,
                terminal_mappings = true,
                persist_mode = false,
                close_on_exit = true,
                shell = vim.o.shell,

                -- Visual settings
                hide_numbers = true,
                shade_terminals = true,
                shading_factor = 2,
                shade_filetypes = {},

                -- Float specific options
                float_opts = {
                    border = "curved",
                    width = function()
                        return math.floor(vim.o.columns * 0.85)
                    end,
                    height = function()
                        return math.floor(vim.o.lines * 0.8)
                    end,
                    winblend = 0,
                    title_pos = "center",
                    highlights = {
                        border = "FloatBorder",
                        background = "Normal",
                    }
                },

                -- Winbar configuration
                winbar = {
                    enabled = false,
                    name_formatter = function(term)
                        return term.name or term.id
                    end,
                },
            })

            -- Set up keymaps for regular :term command (not toggleterm)
            local function set_terminal_keymaps()
                -- Terminal mode mappings
                local opts = { buffer = 0 }
                -- vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
                vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            end

            -- Auto-command to set terminal keymaps when regular terminal opens
            vim.api.nvim_create_autocmd("TermOpen", {
                pattern = "term://*",
                callback = function(ev)
                    -- Only apply to regular :term, not toggleterm
                    if string.match(vim.api.nvim_buf_get_name(ev.buf), "toggleterm") == nil then
                        set_terminal_keymaps()
                    end
                end
            })

            -- Normal mode keymaps for toggleterm
            vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm Float" })
            vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "ToggleTerm Vertical" })
            vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>",
                { desc = "ToggleTerm Horizontal" })

            -- Function to open a terminal with a specific command
            function _G.run_command(cmd)
                local term = require("toggleterm.terminal").Terminal:new({
                    cmd = cmd,
                    direction = "float",
                    close_on_exit = false,
                    on_open = function(term)
                        vim.cmd("startinsert!")
                    end,
                })
                term:toggle()
            end

            -- Example of running a specific command
            vim.keymap.set("n", "<leader>lg", function() _G.run_command("lazygit") end, { desc = "LazyGit" })
        end,
    },

    -- More plugins goes here
})

-- General Settings
vim.opt.number = true                                     -- Enable absolute line numbers
vim.opt.relativenumber = false                            -- Enable relative line numbers
vim.opt.tabstop = 4                                       -- Set tab width to 4 spaces
vim.opt.shiftwidth = 4                                    -- Set indentation width to 4 spaces
vim.opt.expandtab = true                                  -- Use spaces instead of tabs
vim.opt.smartindent = true                                -- Enable smart indentation
vim.opt.autoindent = true                                 -- Enable automatic indentation for new lines
vim.opt.termguicolors = true                              -- Enable true color support
vim.opt.mouse = "a"                                       -- Enable mouse support
vim.opt.fileencoding = "utf-8"                            -- Ensure files are written in UTF-8
vim.opt.encoding = "utf-8"                                -- Set internal encoding (redundant but explicit)
vim.opt.textwidth = 0
vim.opt.wrap = false                                      -- Disable wrapping completely
vim.opt.cursorline = true                                 -- Highlight the current line
vim.opt.incsearch = true                                  -- Show search matches as you type
vim.opt.hlsearch = true                                   -- Highlight all search results
vim.opt.ignorecase = true                                 -- Ignore case during searches
vim.opt.smartcase = true                                  -- Override ignorecase if search contains uppercase
vim.opt.completeopt = { "menuone", "noselect" }           -- Customize completion behavior
vim.opt.undofile = true                                   -- Enable persistent undo across sessions
vim.opt.undodir = vim.fn.expand("~/.config/nvim/undodir") -- Specify undo directory
vim.opt.showmode = false                                  -- Hide mode indicator
vim.opt.laststatus = 2                                    -- Always show status line

-- SCSS-specific indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "scss",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
    end,
})

-- SASS-specific indentation
vim.api.nvim_create_autocmd("FileType", {
    pattern = "sass",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
    end,
})


-- Background color and highlighting settings
vim.cmd("highlight Normal guibg=black")
vim.cmd("highlight Comment guifg=#808080")
vim.cmd("highlight Function guifg=#88c0d0")

-- Customizing File Tree Colors (nvim-tree)
vim.cmd("highlight NvimTreeNormal guibg=black")
vim.cmd("highlight NvimTreeFolderName guifg=#00FFFF") -- Cyan
vim.cmd("highlight NvimTreeFileName guifg=#FCA7EA")   -- Pink
vim.cmd("highlight NvimTreeOpenedFolderName guifg=#00FFFF")
vim.cmd("highlight NvimTreeRootFolder guifg=#FCA7EA")

-- Keybindings for NvimTreeToggle
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Autocommand for resetting HTML filetype from htmlangular to html
vim.api.nvim_create_autocmd("FileType", {
    pattern = "htmlangular",
    callback = function()
        vim.cmd("set filetype=html")
    end,
})

-- Autocommand for autosaving feature
local autosave_enabled = false
local autosave_timer = nil

vim.api.nvim_create_user_command("AS", function()
    autosave_enabled = not autosave_enabled
    vim.notify("AutoSave: " .. (autosave_enabled and "ON" or "OFF"))
end, {})

local function start_autosave_timer()
    if autosave_timer then
        vim.fn.timer_stop(autosave_timer)
    end

    autosave_timer = vim.fn.timer_start(1000, function()
        if autosave_enabled and vim.bo.modified and vim.fn.expand("%") ~= "" then
            vim.cmd("write") -- Save file (and trigger format on save if you configured it)
            vim.schedule(function()
                vim.notify("File saved successfully", vim.log.levels.INFO, { title = "AutoSave" })
            end)
        end
    end)
end

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    callback = function()
        if autosave_enabled then
            start_autosave_timer()
        end
    end,
})

-- Keybindings for Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { noremap = true, silent = true })

-- Keybinding for checking Diagnostic
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostics" })


-- Run Command Keybinding for running JavaScript, TypeScript, Java ,GO and C++  in a split terminal
-- Run Command Keybinding for running JavaScript, TypeScript, Java, C++, Python, Assembly and Go in a split terminal
vim.api.nvim_set_keymap('n', '<leader>r', ':lua '
    .. 'if vim.bo.filetype == "java" then vim.cmd("RunJava") '
    .. 'elseif vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then vim.cmd("RunJS") '
    .. 'elseif vim.bo.filetype == "cpp" then vim.cmd("RunCpp") '
    .. 'elseif vim.bo.filetype == "asm" or vim.bo.filetype == "s" then vim.cmd("RunAsm") '
    .. 'elseif vim.bo.filetype == "python" then vim.cmd("RunPython") '
    .. 'elseif vim.bo.filetype == "go" then vim.cmd("RunGo") '
    .. 'else print("Not a supported file type") end<CR>',
    { noremap = true, silent = true })


-- Fix for terminal buffer settings
vim.cmd([[
  augroup TerminalBufferSettings
  autocmd!
  autocmd BufEnter term://* setlocal nonumber norelativenumber
  autocmd BufEnter term://* setlocal bufhidden=hide
  autocmd BufEnter term://* setlocal noswapfile
  autocmd BufEnter term://* setlocal signcolumn=no
  autocmd BufEnter term://* setlocal scrollback=10000  -- Ensure scrollback is set
  autocmd BufEnter term://* setlocal mouse=a  -- Enable mouse interactions
  augroup END
]])

-- Terminal Mode Lock
vim.api.nvim_create_autocmd('TermOpen', {
    pattern = 'term://*',
    callback = function()
        vim.cmd('setlocal norelativenumber nonumber') -- Disable line numbers
        vim.cmd('setlocal scrollback=10000')          -- Ensure scrollback is set
        vim.cmd('setlocal mouse=a')                   -- Enable mouse interactions
    end,
})

-- Prevent extra terminal windows from opening
vim.cmd([[
  autocmd WinEnter * if &buftype == 'terminal' | setlocal norelativenumber | endif
]])

-- Ensure terminal buffers are not affected by file tree expansion
vim.cmd([[
  autocmd WinEnter term://* setlocal noswapfile
  autocmd WinEnter term://* setlocal bufhidden=hide
]])

-- Custom command to run JavaScript and TypeScript files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunJS', function()
    local filepath = vim.fn.expand('%:p:h') -- Get file directory
    local filename = vim.fn.expand('%:t')   -- Get current file name

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Use quotes to handle directory paths with spaces or special characters
    vim.cmd('vsplit')
    vim.cmd('wincmd l')
    vim.cmd(string.format('term cd "%s" && node "%s"', filepath, filename))
end, {})


-- Custom command to run Java files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunJava', function()
    local filepath = vim.fn.expand('%:p:h')           -- Get file directory
    local filename = vim.fn.expand('%:t')             -- Get current file name
    local class_name = filename:match('^(.*)%.java$') -- Extract class name

    if not class_name then
        print('Error: Not a Java file')
        return
    end

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Use quotes to handle directory paths with spaces or special characters
    vim.cmd('vsplit')
    vim.cmd('wincmd l')
    vim.cmd(string.format('term cd "%s" && javac "%s" && java -cp "%s" %s; rm -f "%s.class"', filepath, filename,
        filepath, class_name, class_name))
end, {})

-- Close terminal when switching to another buffer
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_type = vim.bo[current_buf].buftype
        if buf_type ~= 'terminal' then
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
                    vim.api.nvim_buf_delete(buf, { force = true }) -- Close terminal buffer
                end
            end
        end
    end,
})


-- Custom command to run C++ files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunCpp', function()
    local filepath = vim.fn.expand('%:p:h')         -- Get file directory
    local filename = vim.fn.expand('%:t')           -- Get current file name
    local output_name = filename:gsub("%.cpp$", "") -- Remove .cpp extension for output file

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && g++ "%s" -o "%s" && ./"%s"; rm -f "%s"', filepath, filename, output_name,
        output_name, output_name))
end, {})


-- Assembly Code
vim.api.nvim_create_user_command('RunAsm', function()
    local filepath = vim.fn.expand('%:p:h')                          -- Get file directory
    local filename = vim.fn.expand('%:t')                            -- Get current file name
    local output_name = filename:gsub("%.asm$", ""):gsub("%.s$", "") -- Remove .asm/.s extension

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && as -o "%s.o" "%s" && ld -o "%s" "%s.o" && ./"%s"; rm -f "%s.o" "%s"',
        filepath, output_name, filename, output_name, output_name, output_name, output_name, output_name))
end, {})


-- Custom command to run Python files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunPython', function()
    local filepath = vim.fn.expand('%:p:h') -- Get file directory
    local filename = vim.fn.expand('%:t')   -- Get current file name

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the Python program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && python3 "%s"', filepath, filename))
end, {})

-- Custom command to run Go files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunGo', function()
    local filepath = vim.fn.expand('%:p:h') -- Get file directory
    local filename = vim.fn.expand('%:t')   -- Get current file name

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the Go program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && go run "%s"', filepath, filename))
end, {})


require("xen.liveserver") -- Place this at the bottom or inside a config function
