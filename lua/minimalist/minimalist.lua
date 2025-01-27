local M = {}

---@type integer
local orig_win = nil
---@type integer
local orig_buf = nil
---@type integer
local float_win = nil

local backup_globals = {}
local buf_bk = {}
local original_winseparator, original_statuslinenc, dummy_buffer

M.config = {
    win_opts = {
        width = 0.8,
        height = 0.8,
        col = nil,
        row = nil,
        relative = "editor",
        style = "minimal",
    },
    profiles = {
        default = {
            wo = {
                number = false,
                relativenumber = false,
                signcolumn = "no",
                fillchars = "eob: ",
                statusline = " ",
            },
            o = {
                ruler = false,
                laststatus = 0,
                cmdheight = 0,
            },
        },
    },
}

function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

    local ui = vim.api.nvim_list_uis()[1]
    -- > 1 means absolute numbers, othewise a proportion of original UI
    M.config.win_opts.width = M.config.win_opts.width > 1 and M.config.win_opts.width
        or math.floor(ui.width * M.config.win_opts.width)
    M.config.win_opts.height = M.config.win_opts.height > 1 and M.config.win_opts.height
        or math.floor(ui.height * M.config.win_opts.height)

    if M.config.win_opts.col == nil or M.config.win_opts.col <= 0 then
        M.config.win_opts.col = math.floor((ui.width - M.config.win_opts.width) / 2)
    end
    if M.config.win_opts.row == nil or M.config.win_opts.row <= 0 then
        M.config.win_opts.row = math.floor((ui.height - M.config.win_opts.height) / 2)
    end

    M.config.win_opts.width = math.min(M.config.win_opts.width, ui.width - M.config.win_opts.col)
    M.config.win_opts.height = math.min(M.config.win_opts.height, ui.height - M.config.win_opts.row)

    dummy_buffer = M.get_dummy_buffer()
end

function M.minimalist_toggle(profile)
    if float_win == nil then
        profile = profile or "default"
        if M.config.profiles[profile] == nil then
            local err_message = "No such profile " .. profile .. ". Setting to default"
            vim.schedule(function()
                vim.api.nvim_err_writeln(err_message)
            end)
            profile = "default"
        end
        M.float(profile)
    else
        M.unfloat()
    end
end

function M.float(profile)
    orig_win = vim.api.nvim_get_current_win()
    orig_buf = vim.api.nvim_win_get_buf(orig_win)
    M.hide()

    M.pop_floating_window()
    vim.api.nvim_win_set_option(float_win, "winblend", 0)

    -- Set highlights to match original window
    vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
    vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })
    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    original_winseparator = vim.api.nvim_get_hl(0, { name = "WinSeparator" })
    original_statuslinenc = vim.api.nvim_get_hl(0, { name = "StatusLineNC" })

    -- Set WinSeparator's foreground to match Normal's background
    vim.api.nvim_set_hl(0, "WinSeparator", {
        fg = normal_hl.bg or "NONE", -- Fallback if bg isn't defined
    })
    vim.api.nvim_set_hl(0, "StatusLineNC", {
        fg = normal_hl.bg or "NONE", -- Fallback if bg isn't defined
    })

    M.configure_floating_window(profile)
    M.set_globals(M.config.profiles[profile].o, backup_globals)
end

function M.pop_floating_window()
    float_win = vim.api.nvim_open_win(orig_buf, true, M.config.win_opts)
    vim.api.nvim_create_augroup("BufferRodeo", {})
    vim.api.nvim_create_autocmd("WinClosed", {
        group = "BufferRodeo",
        buffer = orig_buf,
        callback = function()
            M.unfloat()
            if not vim.api.nvim_buf_get_option(orig_buf, "modified") then
                vim.api.nvim_command("q")
                vim.api.nvim_buf_delete(orig_buf, { force = true })
            end
        end,
    })
end

function M.configure_floating_window(profile)
    for k, v in pairs(M.config.profiles[profile].wo) do
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            vim.api.nvim_win_set_option(win, k, v)
        end
    end
end

function M.set_globals(opts, backup)
    opts = opts or M.config.profiles.default.o
    for k, v in pairs(opts) do
        if backup ~= nil then
            backup[k] = vim.o[k]
        end
        vim.o[k] = v
    end
end

function M.hide()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            buf_bk[buf] = win
            vim.api.nvim_win_set_buf(win, dummy_buffer)
        end
    end
    local ok, lualine = pcall(require, "lualine")
    if ok then
        lualine.hide()
    end
end

function M.unhide()
    for buf, win in pairs(buf_bk) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_win_set_buf(win, buf)
        end
    end
    local ok, lualine = pcall(require, "lualine")
    if ok then
        lualine.hide({ unhide = true })
    end
    buf_bk = {}
end

function M.unfloat()
    if float_win ~= nil and vim.api.nvim_win_is_valid(float_win) then
        vim.api.nvim_win_set_buf(float_win, dummy_buffer) -- or won't close cleanly
        vim.api.nvim_win_close(float_win, true)
    end
    M.set_globals(backup_globals, nil)
    M.unhide()

    -- restore color scheme
    vim.api.nvim_set_hl(0, "WinSeparator", original_winseparator)
    vim.api.nvim_set_hl(0, "StatusLineNC", original_statuslinenc)

    ---@type integer
    float_win = nil
    ---@type integer
    orig_win = nil
end

function M.get_dummy_buffer()
    return vim.api.nvim_create_buf(false, true)
end

return M
