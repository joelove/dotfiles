-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "ghostty",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- M.nvdash = { load_on_startup = true }
M.ui = {
	statusline = {
		theme = "default",
		-- sharp arrow on the left, slanted angle on the right (matches p10k)
		separator_style = {
			left = "\u{E0B2}",
			right = "\u{E0BC}",
		},
	},
}

return M
