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
                    { name = "path" },    -- Ensures correct path suggestions
                    { name = "luasnip" }, -- Snippet completion
                    { name = "buffer", keyword_length = 3 },  -- Buffer completion with length limit to reduce noise
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
}
