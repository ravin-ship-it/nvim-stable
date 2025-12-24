-- General Keymaps

-- Keybindings for NvimTreeToggle
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Keybindings for Telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", { noremap = true, silent = true })

-- Keybinding for checking Diagnostic
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show Diagnostics" })

-- Color Picker Keymaps
vim.keymap.set("n", "<leader>cp", ":CccPick<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ch", ":CccHighlighterToggle<CR>", { noremap = true, silent = true })

-- Run Command Keybinding
vim.api.nvim_set_keymap('n', '<leader>r', ':lua '
    .. 'if vim.bo.filetype == "java" then vim.cmd("RunJava") '
    .. 'elseif vim.bo.filetype == "javascript" or vim.bo.filetype == "typescript" then vim.cmd("RunJS") '
    .. 'elseif vim.bo.filetype == "cpp" then vim.cmd("RunCpp") '
    .. 'elseif vim.bo.filetype == "asm" or vim.bo.filetype == "s" then vim.cmd("RunAsm") '
    .. 'elseif vim.bo.filetype == "python" then vim.cmd("RunPython") '
    .. 'elseif vim.bo.filetype == "go" then vim.cmd("RunGo") '
    .. 'else print("Not a supported file type") end<CR>',
    { noremap = true, silent = true })
