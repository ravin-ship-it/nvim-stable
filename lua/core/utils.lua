local M = {}

M.is_android = vim.fn.has("android") == 1
M.is_windows = vim.fn.has("win32") == 1

M.shell_rm = M.is_windows and "del /f" or "rm -f"
M.shell_exec_prefix = M.is_windows and ".\\" or "./"
M.shell_sep = M.is_windows and "\\" or "/"

-- Safe formatting wrapper: skips formatting if there are active syntax errors
M.smart_format = function(opts)
    opts = opts or {}
    local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if ok and parser then
        local tree_ok, tree = pcall(parser.parse, parser)
        if tree_ok and tree and tree[1] then
            local root = tree[1]:root()
            if root and root:has_error() then
                vim.api.nvim_echo({ { "[Formatter] Skipped formatting due to syntax errors", "WarningMsg" } }, false, {})
                return
            end
        end
    end

    vim.lsp.buf.format(opts)
end

return M

