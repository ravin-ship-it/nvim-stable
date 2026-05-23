local utils = require("core.utils")

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
    vim.cmd(string.format('term cd "%s" && javac "%s" && java -cp "%s" %s && %s "%s.class"', filepath, filename,
        filepath, class_name, utils.shell_rm, class_name))
end, {})


-- Custom command to run C++ files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunCpp', function()
    local filepath = vim.fn.expand('%:p:h')         -- Get file directory
    local filename = vim.fn.expand('%:t')           -- Get current file name
    local output_name = filename:gsub("%.cpp$", "") -- Remove .cpp extension for output file
    if utils.is_windows then output_name = output_name .. ".exe" end

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && g++ "%s" -o "%s" && %s"%s" && %s "%s"', filepath, filename, output_name,
        utils.shell_exec_prefix, output_name, utils.shell_rm, output_name))
end, {})


-- Custom command to run C files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunC', function()
    local filepath = vim.fn.expand('%:p:h')         -- Get file directory
    local filename = vim.fn.expand('%:t')           -- Get current file name
    local output_name = filename:gsub("%.c$", "")   -- Remove .c extension for output file
    if utils.is_windows then output_name = output_name .. ".exe" end

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && gcc "%s" -o "%s" && %s"%s" && %s "%s"', filepath, filename, output_name,
        utils.shell_exec_prefix, output_name, utils.shell_rm, output_name))
end, {})


-- Assembly Code
vim.api.nvim_create_user_command('RunAsm', function()
    local filepath = vim.fn.expand('%:p:h')                          -- Get file directory
    local filename = vim.fn.expand('%:t')                            -- Get current file name
    local output_name = filename:gsub("%.asm$", ""):gsub("%.s$", "") -- Remove .asm/.s extension
    if utils.is_windows then output_name = output_name .. ".exe" end

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    
    if utils.is_windows then
        -- Assuming Windows users might be using something else for ASM, but following the pattern
        vim.cmd(string.format('term cd "%s" && as -o "%s.o" "%s" && ld -o "%s" "%s.o" && %s"%s" && %s "%s.o" && %s "%s"',
            filepath, output_name, filename, output_name, output_name, utils.shell_exec_prefix, output_name, utils.shell_rm, output_name, utils.shell_rm, output_name))
    else
        vim.cmd(string.format('term cd "%s" && as -o "%s.o" "%s" && ld -o "%s" "%s.o" && ./"%s" && rm -f "%s.o" "%s"',
            filepath, output_name, filename, output_name, output_name, output_name, output_name, output_name))
    end
end, {})


-- Custom command to run Python files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunPython', function()
    local filepath = vim.fn.expand('%:p:h') -- Get file directory
    local filename = vim.fn.expand('%:t')   -- Get current file name
    local python_cmd = utils.is_windows and "python" or "python3"

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Open vertical split and run the Python program
    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split
    vim.cmd(string.format('term cd "%s" && %s "%s"', filepath, python_cmd, filename))
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

-- Custom command to run Rust files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunRust', function()
    local filepath = vim.fn.expand('%:p:h')          -- Get file directory
    local filename = vim.fn.expand('%:t')            -- Get current file name
    local output_name = filename:gsub("%.rs$", "")   -- Remove .rs extension for output file
    if utils.is_windows then output_name = output_name .. ".exe" end

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Check for Cargo.toml to decide between cargo run or rustc
    local cargo_toml = vim.fn.findfile('Cargo.toml', filepath .. ';')

    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split

    if cargo_toml ~= "" then
        -- It's a Cargo project
        local cargo_dir = vim.fn.fnamemodify(cargo_toml, ':h')
        vim.cmd(string.format('term cd "%s" && cargo run', cargo_dir))
    else
        -- It's a standalone Rust file
        vim.cmd(string.format('term cd "%s" && rustc "%s" -o "%s" && %s"%s" && %s "%s"', filepath, filename,
            output_name, utils.shell_exec_prefix, output_name, utils.shell_rm, output_name))
    end
end, {})

-- Custom command to run Zig files with terminal interaction in a split window
vim.api.nvim_create_user_command('RunZig', function()
    local filepath = vim.fn.expand('%:p:h')          -- Get file directory
    local filename = vim.fn.expand('%:t')            -- Get current file name

    -- Close any existing terminal buffer
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.getbufvar(buf, '&buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    -- Check for build.zig to decide between zig build run or zig run
    local build_zig = vim.fn.findfile('build.zig', filepath .. ';')

    vim.cmd('vsplit')   -- Open vertical split
    vim.cmd('wincmd l') -- Move to the right-side split

    if build_zig ~= "" then
        -- It's a Zig project
        local project_dir = vim.fn.fnamemodify(build_zig, ':h')
        vim.cmd(string.format('term cd "%s" && zig build run', project_dir))
    else
        -- It's a standalone Zig file
        vim.cmd(string.format('term cd "%s" && zig run "%s"', filepath, filename))
    end
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

-- Command to clear Neovim and Lazy cache manually
vim.api.nvim_create_user_command('ClearCache', function()
    local cache_dir = vim.fn.stdpath("cache") .. "/luac"
    local lazy_state = vim.fn.stdpath("state") .. "/lazy/state.json"
    
    if vim.fn.isdirectory(cache_dir) == 1 then
        vim.fn.delete(cache_dir, "rf")
    end
    if vim.fn.filereadable(lazy_state) == 1 then
        vim.fn.delete(lazy_state)
    end
    
    vim.notify("Neovim bytecode and Lazy cache cleared! Please restart Neovim.", vim.log.levels.INFO)
end, { desc = "Clear Neovim bytecode and Lazy cache" })
