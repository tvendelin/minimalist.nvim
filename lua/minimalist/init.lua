local function setup(opts)
    vim.api.nvim_create_user_command("MinimalistToggle", function(args)
        local m = require("minimalist.minimalist")
        m.setup(opts)
        m.minimalist_toggle(args.args ~= "" and args.args or nil)
    end, { nargs = "?" })
end

return { setup = setup }
