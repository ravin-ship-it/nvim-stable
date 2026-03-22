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
                        -- Take exactly 50% of the current total lines (height)
                        return math.floor(vim.o.lines * 0.5)
                    elseif term.direction == "vertical" then
                        -- Take exactly 50% of the current total columns (width)
                        -- Ensure it calculates based on the full editor width
                        return math.floor(vim.o.columns * 0.5)
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

            local dir_terminals = {}
            local next_term_id = 1

            local function toggle_term_in_dir(direction)
                -- If we are currently in a toggleterm buffer, just toggle it to close
                if vim.bo.filetype == "toggleterm" then
                    local term_id = vim.b.toggle_number
                    if term_id then
                        require("toggleterm").toggle(term_id)
                        return
                    end
                elseif vim.bo.buftype == "terminal" then
                    -- If it's a regular :term buffer, close the window or switch buffer
                    if vim.fn.winnr('$') > 1 then
                        vim.cmd("hide")
                    else
                        -- It's the last window, switch to alternate buffer or create a new one
                        local prev_buf = vim.fn.bufnr('#')
                        if prev_buf > 0 and vim.fn.buflisted(prev_buf) == 1 then
                            vim.cmd("buffer " .. prev_buf)
                        else
                            vim.cmd("bprevious")
                            if vim.bo.buftype == "terminal" then
                                vim.cmd("enew")
                            end
                        end
                    end
                    return
                end

                local file_dir = vim.fn.expand('%:p:h')
                if file_dir == '' then
                    file_dir = vim.fn.getcwd()
                end
                
                if not dir_terminals[file_dir] then
                    dir_terminals[file_dir] = next_term_id
                    next_term_id = next_term_id + 1
                end

                -- Calculate exact explicit size on every open to prevent ToggleTerm from using stale cached dimensions
                local size = nil
                if direction == "horizontal" then
                    size = math.floor(vim.o.lines * 0.5)
                elseif direction == "vertical" then
                    size = math.floor(vim.o.columns * 0.5)
                end
                
                require("toggleterm").toggle(dir_terminals[file_dir], size, file_dir, direction)
            end

            -- Override the <C-t> mapping to open in current file's directory
            vim.keymap.set({ "n", "t" }, "<C-t>", function()
                -- When in terminal mode, `<C-t>` will now also trigger the toggle function
                -- If we are in terminal mode, we want to ensure we're interacting with the toggle properly
                -- We use schedule to avoid issues with closing terminals while in insert mode
                vim.schedule(function() toggle_term_in_dir("float") end)
            end, { desc = "Toggle terminal in file directory" })

            -- Global terminal mode mappings for scrolling the terminal buffer
            vim.keymap.set("t", "<PageUp>", "<C-\\><C-n><PageUp>", { desc = "Scroll Terminal Up" })
            vim.keymap.set("t", "<PageDown>", "<C-\\><C-n><PageDown>", { desc = "Scroll Terminal Down" })
            
            -- Map them in normal mode as well so you can continuously scroll once triggered
            vim.keymap.set("n", "<PageUp>", "<C-u>", { desc = "Scroll Window Up" })
            vim.keymap.set("n", "<PageDown>", "<C-d>", { desc = "Scroll Window Down" })

            -- Set up keymaps for regular :term command (not toggleterm)
            local function set_terminal_keymaps()
                -- Terminal mode mappings
                local opts = { buffer = 0 }
                -- <Esc> is handled globally above now
                vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            end

            -- Normal mode keymaps for toggleterm
            vim.keymap.set("n", "<leader>tf", function() toggle_term_in_dir("float") end, { desc = "ToggleTerm Float" })
            vim.keymap.set("n", "<leader>tv", function() toggle_term_in_dir("vertical") end, { desc = "ToggleTerm Vertical" })
            vim.keymap.set("n", "<leader>th", function() toggle_term_in_dir("horizontal") end, { desc = "ToggleTerm Horizontal" })

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
