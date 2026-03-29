local wezterm = require("wezterm")
local config = {}

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.enable_tab_bar = false

config.font_size = 17.0

-- Disable font ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- config.disable_default_key_bindings = true

-- Color scheme
config.color_scheme = "Dark+"

-- Remove window title bar decorations
config.window_decorations = "RESIZE"

-- WezTerm-specific shortcuts that should stay as Cmd
local reserved_keys = {
	"f", -- Cmd+F for search
	"q", -- Cmd+Q for quit
	"v", -- Cmd+V for paste
}

-- Map all other Cmd keys to Ctrl
local function map_cmd_to_ctrl()
	local keys = {}
	local reserved = {}
	for _, key in ipairs(reserved_keys) do
		reserved[key:lower()] = true
		reserved[key:upper()] = true
	end

	-- Map Cmd to Ctrl (without Shift)
	for i = 32, 126 do
		local char = string.char(i)
		if not reserved[char] then
			table.insert(keys, {
				key = char,
				mods = "CMD",
				action = wezterm.action.SendKey({ key = char, mods = "CTRL" }),
			})
		end
	end

	-- Map Cmd+Shift to Ctrl+Shift
	for i = 32, 126 do
		local char = string.char(i)
		if not reserved[char] then
			table.insert(keys, {
				key = char,
				mods = "CMD|SHIFT",
				action = wezterm.action.SendKey({ key = char, mods = "CTRL|SHIFT" }),
			})
		end
	end

	-- Add reload on Ctrl+Shift+R (won't conflict with neovim)
	table.insert(keys, {
		key = "R",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	})

	-- Explicit mappings for Ctrl+Shift+numbers (they don't work by default)
	local number_keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
	for _, num in ipairs(number_keys) do
		table.insert(keys, {
			key = num,
			mods = "CTRL|SHIFT",
			action = wezterm.action.SendKey({ key = num, mods = "CTRL|SHIFT" }),
		})
	end

	-- Add Option + Left/Right arrow for word navigation
	table.insert(keys, {
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1b[1;3D"),
	})
	table.insert(keys, {
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1b[1;3C"),
	})

	-- Add Option + Delete/Backspace for word deletion
	table.insert(keys, {
		key = "Backspace",
		mods = "OPT",
		action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }),
	})

	-- Add Cmd+Shift+N to run tmux-pick (sends F12 which tmux will catch)
	table.insert(keys, {
		key = "N",
		mods = "CMD|SHIFT",
		action = wezterm.action.SendString("\x1b[24~"), -- F12 key sequence
	})

	return keys
end

config.keys = map_cmd_to_ctrl()

return config
