-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'Ayu Mirage' -- https://gogh-co.github.io/Gogh/
config.color_scheme = "carbonfox"
config.font = wezterm.font("Monaspace Neon")
config.font_size = 14.0
config.colors = {
	selection_bg = "rgba(50% 50% 50% 50%)",
}
config.enable_kitty_keyboard = true
config.default_prog = { "/run/current-system/sw/bin/fish", "-l" }

-- config.debug_key_events = true
config.leader = { key = " ", mods = "CTRL", timeout_milliseconds = 1000 }
config.max_fps = 144
config.animation_fps = 60

local act = wezterm.action
config.keys = {
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "LEADER|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},
	{ key = "[", mods = "LEADER", action = act.MoveTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = act.MoveTabRelative(1) },
}

-- and finally, return the configuration to wezterm
return config
