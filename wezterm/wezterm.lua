-- Import the wezterm module
local wezterm = require 'wezterm'
-- Creates a config object which we will be adding our config to
local config = wezterm.config_builder()

-- (This is where our config will go)
-- config.color_scheme = 'Tokyo Night'
-- config.color_scheme = 'catppuccin-mocha'
-- config.color_scheme = 'Bim (Gogh)'
-- config.color_scheme = 'Blazer (Gogh)'
config.color_scheme = 'Catppuccin Macchiato'

-- Slightly transparent and blurred background
config.window_background_opacity = 0.95
config.macos_window_background_blur = 30
-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- On macOS, 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = 'RESIZE|INTEGRATED_BUTTONS'
-- Sets the font for the window frame (tab bar)
config.window_frame = {
  -- Berkeley Mono for me again, though an idea could be to try a
  -- serif font here instead of monospace for a nicer look?
  font = wezterm.font({ family = 'Berkeley Mono', weight = 'Bold' }),
  font_size = 9,
}

config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.window_close_confirmation = 'NeverPrompt'

return config
