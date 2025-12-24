-- Custom command to run JavaScript and TypeScript files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunJS', function()
    local filepath = vim.fn.expand('%:p:h') -- Get file directory
    local filename = vim.fn.expand('%:t')   -- Get current file name

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Use quotes to handle directory paths with spaces or special characters
    vim.cmd('vsplit')
    vim.cmd('wincmd l')
    vim.cmd(string.format('term cd "%s" && node "%s"', filepath, filename))
end, {})


-- Custom command to run Java files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunJava', function()
    local filepath = vim.fn.expand('%:p:h')           -- Get file directory
    local filename = vim.fn.expand('%:t')             -- Get current file name
    local class_name = filename:match('^(.*)%.java$') -- Extract class name

    if not class_name then
        print('Error: Not a Java file')
        return
    end

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Use quotes to handle directory paths with spaces or special characters
    vim.cmd('vsplit')
    vim.cmd('wincmd l')
    vim.cmd(string.format('term cd "%s" && javac "%s" && java -cp "%s" %s; rm -f "%s.class"', filepath, filename,
        filepath, class_name, class_name))
end, {})


-- Custom command to run C++ files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunCpp', function()
    local filepath = vim.fn.expand('%:p:h')         -- Get file directory
    local filename = vim.fn.expand('%:t')           -- Get current file name
    local output_name = filename:gsub("%.cpp$", "") -- Remove .cpp extension for output file

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && g++ "%s" -o "%s" && ./"%s"; rm -f "%s"', filepath, filename, output_name,
        output_name, output_name))
end, {})


-- Assembly Code
vim.api.nvim_create_user_command('RunAsm', function()
    local filepath = vim.fn.expand('%:p:h')                          -- Get file directory
    local filename = vim.fn.expand('%:t')                            -- Get current file name
    local output_name = filename:gsub("%.asm$", ""):gsub("%.s$", "") -- Remove .asm/.s extension

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && as -o "%s.o" "%s" && ld -o "%s" "%s.o" && ./"%s"; rm -f "%s.o" "%s"',
        filepath, output_name, filename, output_name, output_name, output_name, output_name, output_name))
end, {})


-- Custom command to run Python files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunPython', function()
    local filepath = vim.fn.expand('%:p:h') -- Get file directory
    local filename = vim.fn.expand('%:t')   -- Get current file name

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the Python program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && python3 "%s"', filepath, filename))
end, {})

-- Custom command to run Go files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunGo', function()
    local filepath = vim.fn.expand('%:p:h') -- Get file directory
    local filename = vim.fn.expand('%:t')   -- Get current file name

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the Go program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && go run "%s"', filepath, filename))
end, {})

-- HTML Linter Switching Commands
vim.api.nvim_create_user_command('HTML5', function()
    vim.g.htmlhint_config = vim.fn.stdpath("config") .. "/linter_configs/html5.json"
    vim.cmd('edit!') -- Reload buffer to refresh diagnostics
    print("Switched to Strict HTML5 Validation")
end, {})

vim.api.nvim_create_user_command('HTMLL', function()
    vim.g.htmlhint_config = vim.fn.stdpath("config") .. "/linter_configs/legacy.json"
    vim.cmd('edit!') -- Reload buffer to refresh diagnostics
    print("Switched to Legacy/Loose HTML Validation")
end, {})
