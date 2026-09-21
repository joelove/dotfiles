-- Ghostty (Monokai) theme for NvChad / base46
-- Matches the palette defined in ~/.config/ghostty/config:
--
--   background #000000   foreground #f8f8f2   cursor #ffa827
--   0  #222222   1  #f92a72   2  #a6e22e   3  #ffa827
--   4  #ae81ff   5  #f92a72   6  #66d9ef   7  #cfcfc2
--   8  #75715e   9  #f92a72   10 #a6e22e   11 #e6db74
--   12 #ae81ff   13 #f92a72   14 #66d9ef   15 #f8f8f2

local M = {}

M.base_30 = {
  white = "#f8f8f2",

  -- grayscale ramp built around the pure-black background
  darker_black = "#000000",
  black = "#000000", -- nvim bg
  black2 = "#0d0d0d",
  one_bg = "#121212", -- real bg
  one_bg2 = "#1c1c1c",
  one_bg3 = "#222222",
  grey = "#2b2b2b",
  grey_fg = "#4d4d4d",
  grey_fg2 = "#5c5c5c",
  light_grey = "#75715e",
  line = "#2b2b2b", -- for lines like vertsplit

  -- Monokai accents (exact Ghostty ANSI values)
  red = "#f92a72",
  baby_pink = "#ff6e9c",
  pink = "#f92a72",
  green = "#a6e22e",
  vibrant_green = "#a6e22e",
  nord_blue = "#ae81ff",
  blue = "#ae81ff",
  yellow = "#ffa827",
  sun = "#e6db74",
  purple = "#ae81ff",
  dark_purple = "#8a63d2",
  teal = "#66d9ef",
  orange = "#ffa827",
  cyan = "#66d9ef",

  statusline_bg = "#121212",
  lightbg = "#1c1c1c",
  pmenu_bg = "#ae81ff",
  folder_bg = "#ffa827",
}

M.base_16 = {
  base00 = "#000000",
  base01 = "#121212",
  base02 = "#222222",
  base03 = "#75715e", -- comments
  base04 = "#a59f85",
  base05 = "#f8f8f2",
  base06 = "#f8f8f2",
  base07 = "#ffffff",
  base08 = "#f92a72", -- red
  base09 = "#ffa827", -- orange
  base0A = "#e6db74", -- yellow
  base0B = "#a6e22e", -- green
  base0C = "#66d9ef", -- cyan
  base0D = "#ae81ff", -- blue
  base0E = "#f92a72", -- magenta
  base0F = "#cc6633", -- brown
}

M.polish_hl = {
  treesitter = {
    ["@string"] = { fg = M.base_30.sun },
    ["@operator"] = { fg = M.base_30.red },
  },

  syntax = {
    Operator = { fg = M.base_30.red },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "ghostty")

return M
