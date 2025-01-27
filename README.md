# minimalist.nvim

As monitors increase in size, it also becomes increasingly awkward to edit text flush to
the left edge of one's monitor. This plugin allows to toggle between a single centered
window with the current buffer, hiding everything else. When toggled again,
everything is restored back to originally configured state.

A fair warning: this is the first Neovim plugin I've ever written, and the first
substantial code I've written in Lua.

# The Command

```
:MinimalistToggle <profile>
```

If you didn't configure any profile (see "Configuration" below), then just

```
:MinimalistToggle
```

 which assumes `default` profile.

# Install

Requires Neovim version 0.5+.

### With Lazy.nvim

The minimalist Minimalist setup:

```lua
{
    'tvendelin/minimalist.nvim',
    opts = {},
}
```

# Configuration

The plugin, when toggled, creates a floating window with the currently selected buffer, and hides
everything else by default. The behavior can be customized using the `profiles` table.

For instance, you might want to keep the line numbers in one case, and disable them in
another. Or, you might want to have a couple of different profiles if you switch between
monitors of different sizes often.

The default configuration is:

```lua
opts = {
    -- The floating window parameters
    win_opts = {

        -- width/height < 1 are treated as multiplier to UI dimensions,
        -- width/height > 1 are treated as actual dimensions
        width = 0.8,
        height = 0.8,

        -- Position of the upper left corner of the floating window
        -- If left to nil, the window will be centered
        col = nil,
        row = nil,

        relative = "editor",
        style = "minimal",
    },
    profiles = {
        default = {
            -- vim.wo.* options
            wo = {
                number = false,
                relativenumber = false,
                signcolumn = "no",
                fillchars = "eob: ",
                statusline = " ",
            },
            -- vim.o.* options
            o = {
                ruler = false,
                laststatus = 0,
                cmdheight = 0,
            },
        },
    },
}
```

# Caveat

Some status line plugins might cause some parts of the status line to remain when you
toggle from a horizontal split. This plugin disables the Lualine if present, and works, of
course, with the original status line. Should you have an idea how to tackle this better,
send me a pull request.

# Maintenance and Collaboration

I wrote this plugin in my free time, essentially to learn how to write a Neovim plugin.
I'm going to maintain it as my time permits. Constructive suggestions in the form of pull
requests are welcome.
