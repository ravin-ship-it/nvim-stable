return {
  -- nvim-cmp configuration for autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require "cmp"
      local cmp_autopairs = require "nvim-autopairs.completion.cmp"

      cmp.setup {
        performance = {
          debounce = 30,
          throttle = 30,
          fetching_timeout = 500,
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
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
          { name = "nvim_lsp", max_item_count = 20, priority = 1000 },
          { name = "luasnip", max_item_count = 5, priority = 750, keyword_length = 2 },
        }, {
          { name = "path", option = { trailing_slash = true }, max_item_count = 8 },
          {
            name = "buffer",
            keyword_length = 4,
            max_item_count = 8,
            option = {
              get_bufnrs = function()
                return { vim.api.nvim_get_current_buf() }
              end,
            },
          },
        }),
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
        experimental = {
          ghost_text = false,
        },
      }

      -- JS/TS/React: LSP-only completions (ts_ls handles imports, paths, everything)
      cmp.setup.filetype({ "javascript", "javascriptreact", "typescript", "typescriptreact" }, {
        sources = cmp.config.sources({
          { name = "nvim_lsp", max_item_count = 20, priority = 1000 },
          { name = "luasnip", max_item_count = 3, priority = 500, keyword_length = 3 },
        }, {
          {
            name = "buffer",
            keyword_length = 5,
            max_item_count = 5,
            option = {
              get_bufnrs = function()
                return { vim.api.nvim_get_current_buf() }
              end,
            },
          },
        }),
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
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local luasnip = require "luasnip"
      local types = require "luasnip.util.types"

      -- Configure LuaSnip settings
      luasnip.config.set_config {
        history = false, -- Disable snippet history (prevents stale expansions)
        updateevents = "TextChanged", -- Only update on TextChanged, NOT TextChangedI (lag killer)
        enable_autosnippets = false, -- Disable auto-triggering snippets
        ext_opts = {
          [types.choiceNode] = {
            active = { virt_text = { { "●", "Error" } } },
          },
          [types.insertNode] = {
            active = { virt_text = { { "●", "Comment" } } },
          },
        },
      }

      -- Lazy-load snippets from friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Prevent Invalid 'end_row' errors by cleaning up snippet session on leave
      vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = "*",
        callback = function()
          local luasnip_ok, ls = pcall(require, "luasnip")
          if luasnip_ok and ls.session and ls.session.current_nodes[vim.api.nvim_get_current_buf()] then
            ls.unlink_current()
          end
        end,
      })

      -- Custom snippets for Eruda and Font Awesome

      -- Eruda snippet (HTML)
      luasnip.add_snippets("html", {
        luasnip.s("eruda", {
          luasnip.t '<script src="https://cdn.jsdelivr.net/npm/eruda"></script>',
          luasnip.t { "", "<script>eruda.init();</script>" }, -- Use a table for multi-line
        }),
      })

      -- Font Awesome snippet for HTML
      luasnip.add_snippets("html", {
        luasnip.s("fa", {
          luasnip.t '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css">',
        }),
      })

      -- Font Awesome snippet for CSS
      luasnip.add_snippets("css", {
        luasnip.s("fa", {
          luasnip.t '@import url("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css");',
        }),
      })

      -- Font Awesome snippet for SCSS
      luasnip.add_snippets("scss", {
        luasnip.s("fa", {
          luasnip.t '@import url("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css");',
        }),
      })

      -- Font Awesome snippet for SASS
      luasnip.add_snippets("sass", {
        luasnip.s("fa", {
          luasnip.t '@import url("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free/css/all.min.css");',
        }),
      })

      -- Shebang snippet for Shell
      luasnip.add_snippets("sh", {
        luasnip.s("shebang", {
          luasnip.t "#!/usr/bin/env bash",
        }),
        luasnip.s("env", {
          luasnip.t "#!/usr/bin/env bash",
        }),
      })

      -- Shebang snippet for Python
      luasnip.add_snippets("python", {
        luasnip.s("shebang", {
          luasnip.t "#!/usr/bin/env python3",
        }),
        luasnip.s("env", {
          luasnip.t "#!/usr/bin/env python3",
        }),
      })

      -- Shebang snippet for JavaScript (Node.js)
      luasnip.add_snippets("javascript", {
        luasnip.s("shebang", {
          luasnip.t "#!/usr/bin/env node",
        }),
        luasnip.s("env", {
          luasnip.t "#!/usr/bin/env node",
        }),
      })

      -- Shebang snippet for TypeScript (ts-node)
      luasnip.add_snippets("typescript", {
        luasnip.s("shebang", {
          luasnip.t "#!/usr/bin/env ts-node",
        }),
        luasnip.s("env", {
          luasnip.t "#!/usr/bin/env ts-node",
        }),
      })

      -- Shebang snippet for Lua
      luasnip.add_snippets("lua", {
        luasnip.s("shebang", {
          luasnip.t "#!/usr/bin/env lua",
        }),
        luasnip.s("env", {
          luasnip.t "#!/usr/bin/env lua",
        }),
      })

      -- Shebang snippet for Ruby
      luasnip.add_snippets("ruby", {
        luasnip.s("shebang", {
          luasnip.t "#!/usr/bin/env ruby",
        }),
        luasnip.s("env", {
          luasnip.t "#!/usr/bin/env ruby",
        }),
      })

      -- Shebang snippet for Perl
      luasnip.add_snippets("perl", {
        luasnip.s("shebang", {
          luasnip.t "#!/usr/bin/env perl",
        }),
        luasnip.s("env", {
          luasnip.t "#!/usr/bin/env perl",
        }),
      })

      -- MarkDown Preview
      luasnip.add_snippets("html", {
        luasnip.s("mdpreview", {
          luasnip.t {
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
            "            max-width: 100%;",
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
            "</html>",
          },
        }),
      })
    end,
  },
}
