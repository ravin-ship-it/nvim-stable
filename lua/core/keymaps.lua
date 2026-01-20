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
    .. 'elseif vim.bo.filetype == "c" then vim.cmd("RunC") '
    .. 'elseif vim.bo.filetype == "cpp" then vim.cmd("RunCpp") '
    .. 'elseif vim.bo.filetype == "asm" or vim.bo.filetype == "s" then vim.cmd("RunAsm") '
    .. 'elseif vim.bo.filetype == "python" then vim.cmd("RunPython") '
    .. 'elseif vim.bo.filetype == "go" then vim.cmd("RunGo") '
    .. 'else print("Not a supported file type") end<CR>',
    { noremap = true, silent = true })

-- Tab Navigation Shortcuts
for i = 1, 9 do
    vim.keymap.set('n', '<leader>' .. i, i .. 'gt', { noremap = true, silent = true, desc = 'Go to tab ' .. i })
end
vim.keymap.set('n', '<leader>0', ':tablast<CR>', { noremap = true, silent = true, desc = 'Go to last tab' })

-- Go to specific tab (useful for > 9 tabs)
vim.keymap.set('n', '<leader>t', function()
    local tab_num = tonumber(vim.fn.input("Tab Number: "))
    local total_tabs = vim.fn.tabpagenr('$')

    if tab_num then
        if tab_num > 0 and tab_num <= total_tabs then
            vim.cmd(tab_num .. "tabnext")
        else
            print("\nInvalid tab number! (Max: " .. total_tabs .. ")")
        end
    else
        print("\nInvalid input!")
    end
end, { noremap = true, silent = true, desc = "Go to specific tab number" })

-- Move Lines (VS Code style)
vim.keymap.set("n", "<C-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<C-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
