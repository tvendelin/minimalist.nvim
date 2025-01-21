local M = {}

local a = vim.api
---@type integer
local orig_win = nil
---@type integer
local orig_buf = nil
---@type integer
local float_win = nil

local stripped_win = {
	number = false,
	relativenumber = false,
	signcolumn = "no",
	fillchars = "eob: ",
}

local stripped_globals = {
	laststatus = 0,
	cmdheight = 0,
}

local backup_globals = {}
local buf_bk = {}

M.config = {
	width = 0.8,
	height = 1,
	col = nil,
	row = nil,
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
	local ui = vim.api.nvim_list_uis()[1]
	-- > 1 means absolute numbers, othewise a proportion of original UI
	M.config.width = M.config.width > 1 and M.config.width or math.floor(ui.width * M.config.width)
	M.config.height = M.config.height > 1 and M.config.height or math.floor(ui.height * M.config.height)

	if M.config.col == nil or M.config.col <= 0 then
		M.config.col = math.floor((ui.width - M.config.width) / 2)
	end
	if M.config.row == nil or M.config.row <= 0 then
		M.config.row = math.floor((ui.height - M.config.height) / 2)
	end

	M.config.width = math.min(M.config.width, ui.width - M.config.col)
	M.config.height = math.min(M.config.height, ui.height - M.config.row)
	M.config.relative = "editor"
	M.config.style = "minimal"
end

function M.pop_floating_window()
	float_win = vim.api.nvim_open_win(orig_buf, true, M.config)
	vim.api.nvim_create_augroup("BufferRodeo", {})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = "BufferRodeo",
		buffer = orig_buf,
		callback = function(args)
			M.unfloat()
			if not a.nvim_buf_get_option(orig_buf, "modified") then
				a.nvim_command("q")
				a.nvim_buf_delete(orig_buf, { force = true })
			end
		end,
	})
end

function M.minimalist_toggle()
	if float_win == nil then
		M.float()
	else
		M.unfloat()
	end
end

function M.float()
	orig_win = vim.api.nvim_get_current_win()
	orig_buf = vim.api.nvim_win_get_buf(orig_win)
	M.hide()
	M.pop_floating_window()
	vim.api.nvim_win_set_option(float_win, "winblend", 0)

	-- Set highlights to match original window
	vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
	vim.api.nvim_set_hl(0, "FloatBorder", { link = "Normal" })

	M.configure_floating_window()
	M.set_globals(stripped_globals, backup_globals)
end

function M.hide()
	local dummy = M.get_dummy_buffer()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_is_valid(win) then
			local buf = vim.api.nvim_win_get_buf(win)
			buf_bk[buf] = win
			vim.api.nvim_win_set_buf(win, dummy)
		end
	end
end

function M.unhide()
	for buf, win in pairs(buf_bk) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_buf(win, buf)
		end
	end
end

function M.configure_floating_window()
	for k, v in pairs(stripped_win) do
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			vim.api.nvim_win_set_option(win, k, v)
		end
	end
end

function M.set_globals(opts, backup)
	for k, v in pairs(opts) do
		if backup ~= nil then
			backup[k] = vim.o[k]
		end
		vim.o[k] = v
	end
end

function M.unfloat()
	if float_win ~= nil and vim.api.nvim_win_is_valid(float_win) then
		vim.api.nvim_win_set_buf(float_win, M.get_dummy_buffer()) -- or won't close cleanly
		vim.api.nvim_win_close(float_win, true)
	end
	M.set_globals(backup_globals, nil)
	M.unhide()
	---@type integer
	float_win = nil
	---@type integer
	orig_win = nil
end

function M.get_dummy_buffer()
	return vim.api.nvim_create_buf(false, true)
end

return M
