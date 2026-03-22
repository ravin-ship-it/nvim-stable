return {
    {
        "tpope/vim-dadbod",
        dependencies = {
            "kristijanhusak/vim-dadbod-ui",
            "kristijanhusak/vim-dadbod-completion",
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        init = function()
            vim.keymap.set("n", "<leader>db", ":DBUIToggle<CR>", { desc = "Toggle DBUI", silent = true })
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
            vim.g.db_ui_force_echo_notifications = 1
            vim.g.db_ui_win_width = 35
            local db_path = vim.fn.stdpath("data") .. "/db_ui"
            if vim.fn.isdirectory(db_path) == 0 then
                vim.fn.mkdir(db_path, "p")
            end
            vim.g.db_ui_save_location = db_path
        end,
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "sql", "mysql", "plsql" },
                callback = function()
                    require("cmp").setup.buffer({
                        sources = {
                            { name = "vim-dadbod-completion" },
                            { name = "buffer" },
                        },
                    })
                    -- Map <Enter> to run the query in SQL files
                    vim.keymap.set("n", "<CR>", "<Plug>(DBExe)", { buffer = true, desc = "Execute Query" })
                    -- Map <leader>S to run the query as well
                    vim.keymap.set("n", "<leader>S", "<Plug>(DBExe)", { buffer = true, desc = "Execute Query" })
                end,
            })
        end,
    },
}
