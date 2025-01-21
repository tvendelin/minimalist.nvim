Toggle between a view with centered text and no decorations whatsoever, and the normal
view, as per your configuration.

# Work in Progress

This is my first Neovim plugin, and it certainly needs quite a bit of polishing. Use at
your own risk.

# Install 

### With Lazy.nvim

```lua
{
	'tvendelin/minimalist,
	config = function()
		require("minimalist").setup()
	end,
}
```

# Command

```
:MinimalistToggle
```

That's it.
