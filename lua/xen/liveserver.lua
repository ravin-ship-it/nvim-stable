local uv = vim.loop
local utils = require("core.utils")
local servers = {}
vim.g.live_server_status = ""

local function echo(msg, hl)
    vim.schedule(function()
        vim.api.nvim_echo({ { msg, hl or "None" } }, true, {})
    end)
end

local function update_statusline()
    vim.schedule(function()
        local icons = {}
        for port, _ in pairs(servers) do
            table.insert(icons, "Port:" .. port)
        end
        vim.g.live_server_status = table.concat(icons, " ")
    end)
end

local function get_actual_port(output)
    for line in output:gmatch("[^\r\n]+") do
        local port = line:match("http://[%d%.]+:(%d+)")
        if port then return tonumber(port) end
        
        port = line:match("port (%d+)")
        if port then return tonumber(port) end
    end
    return nil
end

local function start_server(preferred_port)
    if servers[preferred_port] then
        echo("Live server already running at port " .. preferred_port, "DiagnosticWarn")
        return
    end

    local cmd = utils.is_windows and "npx.cmd" or "npx"
    if vim.fn.executable(cmd) == 0 then
        echo("Command '" .. cmd .. "' not found. Please install Node.js/npm. 🥲", "ErrorMsg")
        return
    end

    local stdout = uv.new_pipe(false)
    local stderr = uv.new_pipe(false)
    local actual_port = nil
    local handle

    handle = uv.spawn(cmd, {
        args = { "live-server", "--port=" .. preferred_port },
        stdio = { nil, stdout, stderr },
    }, function()
        stdout:close()
        stderr:close()
        local port = actual_port or preferred_port
        if servers[port] then
            servers[port] = nil
        end
        -- echo("Live server stopped at port " .. port, "DiagnosticWarn")
        update_statusline()
        handle:close()
    end)

    local output = ""

    stdout:read_start(function(err, data)
        assert(not err, err)
        if data then
            output = output .. data
            local parsed_port = get_actual_port(output)
            if parsed_port and not actual_port then
                actual_port = parsed_port
                servers[parsed_port] = handle
                echo("Live server started at port " .. parsed_port .. " 🌱👀🌿 ", "DiagnosticOk")
                update_statusline()
            end
        end
    end)

    stderr:read_start(function(err, data)
        assert(not err, err)
        if data then
            echo(data, "ErrorMsg")
        end
    end)
end

local function stop_server(port)
    local proc = servers[port]
    if proc then
        proc:kill("sigterm")
        servers[port] = nil
        echo("Live server stopped at port " .. port .. " 💦 ", "DiagnosticVisualInfo")
    else
        echo("No live server found on port " .. port .. " 🥲 ", "DiagnosticWarn")
    end
    update_statusline()
end

local function restart_server(port)
    stop_server(port)
    vim.defer_fn(function()
        start_server(port)
    end, 500)
    echo("Restarting port " .. port .. " 😗 ", "number")
end

local function stop_all_servers()
    for p, proc in pairs(servers) do
        proc:kill("sigterm")
        servers[p] = nil
    end
    echo("All Live server ports killed! 👌👀", "string")
    update_statusline()
end

local function list_active_servers()
    local list = {}
    for port, _ in pairs(servers) do
        table.insert(list, tostring(port))
    end
    if #list > 0 then
        echo("Active live servers ⭐ : " .. table.concat(list, ", "), "DiagnosticInfo")
    else
        echo("No live servers currently running.", "Comment")
    end
end

local function smart_port_from_filename()
    local filename = vim.fn.expand("%:p")
    local hash = 0
    for i = 1, #filename do
        hash = (hash + filename:byte(i)) % 1000
    end
    return 5500 + hash
end

-- Register an autocmd to kill all servers on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
    desc = "Kill all live servers when Neovim exits",
    callback = function()
        local count = 0
        for p, proc in pairs(servers) do
            proc:kill("sigterm")
            count = count + 1
        end
        if count > 0 then
            print("Closed " .. count .. " live server" .. (count > 1 and "s" or "") .. " on exit")
        end
    end,
})

vim.api.nvim_create_user_command("LSO", function(opts)
    local port = tonumber(opts.args) or smart_port_from_filename()
    start_server(port)
end, { nargs = "?", desc = "Start Live Server on given or smart port" })

vim.api.nvim_create_user_command("LSC", function(opts)
    local port = tonumber(opts.args) or smart_port_from_filename()
    stop_server(port)
end, { nargs = "?", desc = "Stop Live Server on given or smart port" })

vim.api.nvim_create_user_command("LSR", function(opts)
    local port = tonumber(opts.args) or smart_port_from_filename()
    restart_server(port)
end, { nargs = "?", desc = "Restart Live Server on given or smart port" })

vim.api.nvim_create_user_command("LSW", function()
    stop_all_servers()
end, { desc = "Stopped all Live Servers" })

vim.api.nvim_create_user_command("LSAL", function()
    list_active_servers()
end, { desc = "List all Active Live Servers" })
