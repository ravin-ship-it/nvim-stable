return {
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
    {
        "rcarriga/nvim-dap-ui",
        dependencies = "mfussenegger/nvim-dap",
    },
}
