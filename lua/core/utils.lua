local M = {}

M.is_android = vim.fn.has("android") == 1
M.is_windows = vim.fn.has("win32") == 1

M.shell_rm = M.is_windows and "del /f" or "rm -f"
M.shell_exec_prefix = M.is_windows and ".\\" or "./"
M.shell_sep = M.is_windows and "\\" or "/"

return M
