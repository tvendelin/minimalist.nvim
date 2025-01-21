local function setup(opts)
	local m = require("minimalist.minimalist")
	m.setup(opts)
	vim.api.nvim_create_user_command("MinimalistToggle", function()
		m.minimalist_toggle()
	end, {})
	--[[
	local group = vim.api.nvim_create_augroup("WindowBufferEvents", { clear = true })

	local function notify_event(event, description)
		local message = string.format(
			"[%s] Event: %s | %s",
			os.date("%Y-%m-%d %H:%M:%S"),
			event,
			description or "No additional info"
		)
		vim.notify(message, vim.log.levels.INFO)
	end

	-- Buffer-related events
	vim.api.nvim_create_autocmd({
		"BufEnter",
		"BufLeave",
		"BufNew",
		"BufRead",
		"BufWrite",
		"BufWritePost",
		"BufDelete",
		"BufWinEnter",
		"BufWinLeave",
	}, {
		group = group,
		callback = function(args)
			notify_event(args.event, "Buffer: " .. vim.fn.fnameescape(args.file or "<none>"))
		end,
	})

	-- Window-related events
	vim.api.nvim_create_autocmd({
		"WinEnter",
		"WinLeave",
		"WinClosed",
		"WinNew",
	}, {
		group = group,
		callback = function(args)
			notify_event(args.event, "Window ID: " .. vim.api.nvim_get_current_win())
		end,
	})

	--]]
end

return { setup = setup }
