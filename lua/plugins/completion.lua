return {
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
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")

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
                formatting = {
                    format = function(entry, vim_item)
                        -- Custom Source Labels
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snip]",
                            buffer = "[Buf]",
                            path = "[Path]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },
                sources = cmp.config.sources({
                    {
                        name = "nvim_lsp",
                        dup = 0, -- Ignore duplicates
                    },
                    { name = "luasnip" },
                }, {
                    { name = "path", option = { trailing_slash = true } },
                    { name = "buffer", keyword_length = 3 },
                }),
                experimental = {
                    ghost_text = true, -- Enables inline preview of suggestions
                },
            })

            -- Integrate nvim-autopairs with cmp
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
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

            -- Shebang snippet for Shell
            luasnip.add_snippets("sh", {
                luasnip.s("shebang", {
                    luasnip.t("#!/usr/bin/env bash"),
                }),
                luasnip.s("env", {
                    luasnip.t("#!/usr/bin/env bash"),
                }),
            })

            -- Shebang snippet for Python
            luasnip.add_snippets("python", {
                luasnip.s("shebang", {
                    luasnip.t("#!/usr/bin/env python3"),
                }),
                luasnip.s("env", {
                    luasnip.t("#!/usr/bin/env python3"),
                }),
            })

            -- Shebang snippet for JavaScript (Node.js)
            luasnip.add_snippets("javascript", {
                luasnip.s("shebang", {
                    luasnip.t("#!/usr/bin/env node"),
                }),
                luasnip.s("env", {
                    luasnip.t("#!/usr/bin/env node"),
                }),
            })

            -- Shebang snippet for TypeScript (ts-node)
            luasnip.add_snippets("typescript", {
                luasnip.s("shebang", {
                    luasnip.t("#!/usr/bin/env ts-node"),
                }),
                luasnip.s("env", {
                    luasnip.t("#!/usr/bin/env ts-node"),
                }),
            })

            -- Shebang snippet for Lua
            luasnip.add_snippets("lua", {
                luasnip.s("shebang", {
                    luasnip.t("#!/usr/bin/env lua"),
                }),
                luasnip.s("env", {
                    luasnip.t("#!/usr/bin/env lua"),
                }),
            })

            -- Shebang snippet for Ruby
            luasnip.add_snippets("ruby", {
                luasnip.s("shebang", {
                    luasnip.t("#!/usr/bin/env ruby"),
                }),
                luasnip.s("env", {
                    luasnip.t("#!/usr/bin/env ruby"),
                }),
            })

            -- Shebang snippet for Perl
            luasnip.add_snippets("perl", {
                luasnip.s("shebang", {
                    luasnip.t("#!/usr/bin/env perl"),
                }),
                luasnip.s("env", {
                    luasnip.t("#!/usr/bin/env perl"),
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
}
