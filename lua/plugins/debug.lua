return {
    -- Debugging (nvim-dap)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")
            local dapui_ok, dapui = pcall(require, "dapui")

            if dapui_ok then
                dapui.setup()

                dap.listeners.after.event_initialized["dapui_config"] = function()
                    dapui.open()
                end
                dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close()
                end
                dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close()
                end

                vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP UI Toggle" })
            end

            -- Debugging keymaps
            vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue / Start" })
            vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
            vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
            vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
            vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
            vim.keymap.set("n", "<leader>B", function()
                dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, { desc = "DAP Conditional Breakpoint" })
            vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })
        end,
    },
}
