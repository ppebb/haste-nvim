local uv = vim.loop

local _config = {}

local M = {}

local defaults = {
    url = "https://paste.ppeb.me",
    setclip = false,
}

function M.setup(conf)
    _config = vim.tbl_deep_extend("force", defaults, conf or {})

    vim.api.nvim_create_user_command("Haste", function() M.upload() end, { nil })
end

local function notifywrap(message)
    vim.schedule(function()
        vim.notify(message)
    end)
end

function M.upload()
    local stdout = uv.new_pipe()
    local stderr = uv.new_pipe()
    local buftext = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    local handle, pid
    handle, pid = uv.spawn(
        "curl", {
            args = {
                "-XPOST",
                _config.url .. "/documents",
                "-d",
                buftext,
            },
            stdio = { nil, stdout, stderr },
        },
        vim.schedule_wrap(function()
            stdout:read_stop()
            stderr:read_stop()
            stdout:close()
            stderr:close()
            handle:close()
        end)
    )

    if not handle then
        notifywrap(string.format(" Haste: Failed to spawn curl (%s)", pid))
    end

    local function onstdout(err, data)
        if err then
            notifywrap(string.format(" Haste: stdout - err: %s", err))
        elseif data then
            local index = string.find(data, "key")
            local url = _config.url .. "/" .. string.sub(data, index + 6, -3)
            if index ~= nil then
                notifywrap(string.format(" Haste: Your document is %s", url))
                if _config.setclip then
                    vim.schedule(function() vim.fn.setreg("+", url) end)
                end
            -- else
                -- notifywrap(string.format(" Haste: stdout - data: %s", data))
            end
        end
    end

    local function onstderr(err, data)
        if err then
            notifywrap(string.format(" Haste: stderr - err: %s", err))
        -- elseif data then
            -- notifywrap(string.format(" Haste: stderr - data: %s", data))
        end
    end

    uv.read_start(stdout, onstdout)

    uv.read_start(stderr, onstderr)
end

return M
