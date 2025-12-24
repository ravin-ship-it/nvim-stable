return {
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

            -- Override the <C-t> mapping to open in current file's directory
            vim.keymap.set("n", "<C-t>", function()
                local file_dir = vim.fn.expand('%:p:h')
                if file_dir ~= '' then
                    require("toggleterm").toggle(nil, nil, file_dir, "float")
                else
                    require("toggleterm").toggle()
                end
            end, { desc = "Toggle terminal in file directory" })

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
                    ---@diagnostic disable-next-line: unused-local
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
}
