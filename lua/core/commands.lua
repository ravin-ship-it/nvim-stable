local utils = require("core.utils")

-- Helper: close all open terminal buffers before running a new command
local function close_terminal_buffers()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end

-- Helper: run a shell command in a vertical split terminal
local function run_in_split(cmd_string)
    close_terminal_buffers()
    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("term " .. cmd_string)
end

-- Custom command to run JavaScript and TypeScript files
vim.api.nvim_create_user_command("RunJS", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    run_in_split(string.format('cd "%s" && node "%s"', filepath, filename))
end, {})

-- Custom command to run Java files
vim.api.nvim_create_user_command("RunJava", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    local class_name = filename:match("^(.*)%.java$")

    if not class_name then
        vim.notify("Error: Not a Java file", vim.log.levels.ERROR)
        return
    end

    run_in_split(string.format(
        'cd "%s" && javac "%s" && java -cp "%s" %s && %s "%s.class"',
        filepath, filename, filepath, class_name, utils.shell_rm, class_name
    ))
end, {})

-- Custom command to run C++ files
vim.api.nvim_create_user_command("RunCpp", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    local output_name = filename:gsub("%.cpp$", "")
    if utils.is_windows then output_name = output_name .. ".exe" end

    run_in_split(string.format(
        'cd "%s" && g++ "%s" -o "%s" && %s"%s" && %s "%s"',
        filepath, filename, output_name,
        utils.shell_exec_prefix, output_name, utils.shell_rm, output_name
    ))
end, {})

-- Custom command to run C files
vim.api.nvim_create_user_command("RunC", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    local output_name = filename:gsub("%.c$", "")
    if utils.is_windows then output_name = output_name .. ".exe" end

    run_in_split(string.format(
        'cd "%s" && gcc "%s" -o "%s" && %s"%s" && %s "%s"',
        filepath, filename, output_name,
        utils.shell_exec_prefix, output_name, utils.shell_rm, output_name
    ))
end, {})

-- Custom command to run Assembly files
vim.api.nvim_create_user_command("RunAsm", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    local output_name = filename:gsub("%.asm$", ""):gsub("%.s$", "")
    if utils.is_windows then output_name = output_name .. ".exe" end

    if utils.is_windows then
        run_in_split(string.format(
            'cd "%s" && as -o "%s.o" "%s" && ld -o "%s" "%s.o" && %s"%s" && %s "%s.o" && %s "%s"',
            filepath, output_name, filename, output_name, output_name,
            utils.shell_exec_prefix, output_name, utils.shell_rm, output_name, utils.shell_rm, output_name
        ))
    else
        run_in_split(string.format(
            'cd "%s" && as -o "%s.o" "%s" && ld -o "%s" "%s.o" && ./"%s" && rm -f "%s.o" "%s"',
            filepath, output_name, filename, output_name, output_name, output_name, output_name, output_name
        ))
    end
end, {})

-- Custom command to run Python files
vim.api.nvim_create_user_command("RunPython", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    local python_cmd = utils.is_windows and "python" or "python3"
    run_in_split(string.format('cd "%s" && %s "%s"', filepath, python_cmd, filename))
end, {})

-- Custom command to run Go files
vim.api.nvim_create_user_command("RunGo", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    run_in_split(string.format('cd "%s" && go run "%s"', filepath, filename))
end, {})

-- Custom command to run Rust files
vim.api.nvim_create_user_command("RunRust", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")
    local output_name = filename:gsub("%.rs$", "")
    if utils.is_windows then output_name = output_name .. ".exe" end

    local cargo_toml = vim.fn.findfile("Cargo.toml", filepath .. ";")

    if cargo_toml ~= "" then
        local cargo_dir = vim.fn.fnamemodify(cargo_toml, ":h")
        run_in_split(string.format('cd "%s" && cargo run', cargo_dir))
    else
        run_in_split(string.format(
            'cd "%s" && rustc "%s" -o "%s" && %s"%s" && %s "%s"',
            filepath, filename, output_name,
            utils.shell_exec_prefix, output_name, utils.shell_rm, output_name
        ))
    end
end, {})

-- Custom command to run Zig files
vim.api.nvim_create_user_command("RunZig", function()
    local filepath = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")

    local build_zig = vim.fn.findfile("build.zig", filepath .. ";")

    if build_zig ~= "" then
        local project_dir = vim.fn.fnamemodify(build_zig, ":h")
        run_in_split(string.format('cd "%s" && zig build run', project_dir))
    else
        run_in_split(string.format('cd "%s" && zig run "%s"', filepath, filename))
    end
end, {})

-- HTML Linter Switching Commands
vim.api.nvim_create_user_command("HTML5", function()
    vim.g.htmlhint_config = vim.fn.stdpath("config") .. "/linter_configs/html5.json"
    vim.cmd("edit!")
    vim.notify("Switched to Strict HTML5 Validation", vim.log.levels.INFO)
end, {})

vim.api.nvim_create_user_command("HTMLL", function()
    vim.g.htmlhint_config = vim.fn.stdpath("config") .. "/linter_configs/legacy.json"
    vim.cmd("edit!")
    vim.notify("Switched to Legacy/Loose HTML Validation", vim.log.levels.INFO)
end, {})

-- Command to clear Neovim and Lazy cache manually
vim.api.nvim_create_user_command("ClearCache", function()
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
