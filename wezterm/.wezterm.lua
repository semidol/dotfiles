local wezterm = require("wezterm")
local config = {}

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.enable_tab_bar = false

config.term = "wezterm"

-- Match bindings by physical key so they keep working in the Russian layout
config.key_map_preference = "Physical"

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

local HYPER_MODS = "CTRL|OPT|CMD"

-- Hyper keys used by tmux for window (q..p) and pane (z..v) switching
local hyper_tmux_keys = { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "z", "x", "c", "v" }

local LATIN_LETTERS = "abcdefghijklmnopqrstuvwxyz"
local TMUX_PREFIX_KEY = "b"

-- Physical keys that type punctuation in the US layout but Cyrillic in the Russian one
local PUNCTUATION_KEYS = {
	{ phys = "LeftBracket", plain = "[", shifted = "{" },
	{ phys = "RightBracket", plain = "]", shifted = "}" },
	{ phys = "Semicolon", plain = ";", shifted = ":" },
	{ phys = "Quote", plain = "'", shifted = '"' },
	{ phys = "Comma", plain = ",", shifted = "<" },
	{ phys = "Period", plain = ".", shifted = ">" },
	{ phys = "Slash", plain = "/", shifted = "?" },
	{ phys = "Grave", plain = "`", shifted = "~" },
}

local function each_letter(callback)
	for letter in LATIN_LETTERS:gmatch(".") do
		callback(letter)
	end
end

-- Ctrl+letter is sent as Latin regardless of the active layout
local function ctrl_letter_keys()
	local keys = {}

	each_letter(function(letter)
		if letter ~= TMUX_PREFIX_KEY then
			table.insert(keys, {
				key = "phys:" .. letter:upper(),
				mods = "CTRL",
				action = wezterm.action.SendKey({ key = letter, mods = "CTRL" }),
			})
		end
	end)

	return keys
end

-- The key after the tmux prefix always types Latin, so tmux bindings
-- work in the Russian layout without Cyrillic duplicates
local function tmux_prefix_table()
	local keys = {}

	each_letter(function(letter)
		table.insert(keys, { key = "phys:" .. letter:upper(), action = wezterm.action.SendString(letter) })
		table.insert(keys, {
			key = "phys:" .. letter:upper(),
			mods = "SHIFT",
			action = wezterm.action.SendString(letter:upper()),
		})
	end)

	for _, punctuation in ipairs(PUNCTUATION_KEYS) do
		table.insert(keys, { key = "phys:" .. punctuation.phys, action = wezterm.action.SendString(punctuation.plain) })
		table.insert(keys, {
			key = "phys:" .. punctuation.phys,
			mods = "SHIFT",
			action = wezterm.action.SendString(punctuation.shifted),
		})
	end

	return keys
end

local tmux_prefix_action = wezterm.action.Multiple({
	wezterm.action.SendKey({ key = TMUX_PREFIX_KEY, mods = "CTRL" }),
	wezterm.action.ActivateKeyTable({ name = "tmux_prefix", one_shot = true }),
})

config.key_tables = {
	tmux_prefix = tmux_prefix_table(),
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
		if char == TMUX_PREFIX_KEY then
			table.insert(keys, { key = "phys:" .. char:upper(), mods = "CMD", action = tmux_prefix_action })
		elseif not reserved[char] then
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

	-- Forward Hyper + key to tmux as custom sequences (see user-keys in tmux.conf)
	for _, key in ipairs(hyper_tmux_keys) do
		table.insert(keys, {
			key = key,
			mods = HYPER_MODS,
			action = wezterm.action.SendString("\x1b[hyper-" .. key .. "~"),
		})
	end

	for _, key in ipairs(ctrl_letter_keys()) do
		table.insert(keys, key)
	end

	table.insert(keys, {
		key = "phys:" .. TMUX_PREFIX_KEY:upper(),
		mods = "CTRL",
		action = tmux_prefix_action,
	})

	return keys
end

config.keys = map_cmd_to_ctrl()

return config
