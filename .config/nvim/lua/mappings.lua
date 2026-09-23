require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- nvim-tree (file explorer). NvChad already maps <C-n> to toggle and
-- <leader>e to focus; we make <leader>e toggle (more convenient) and add
-- a couple of extras.
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "filetree toggle" })
map("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "filetree find current file" })
map("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "filetree refresh" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- GUI-editor bridges. Ghostty sends Alt+<key> for these cmd shortcuts
-- (macOS/Ghostty swallow cmd); tmux forwards the Alt sequence to the pane.
map({ "n", "i", "v" }, "<A-p>", "<cmd>Telescope find_files<CR>", { desc = "find files (cmd+p)" })
map({ "n", "i", "v" }, "<A-P>", "<cmd>Telescope commands<CR>", { desc = "command palette (cmd+shift+p)" })
map({ "n", "i", "v" }, "<A-s>", "<cmd>w<CR>", { desc = "save file (cmd+s)" })
map(
  { "n", "i", "v" },
  "<A-f>",
  "<cmd>Telescope current_buffer_fuzzy_find<CR>",
  { desc = "find in buffer (cmd+f)" }
)
map({ "n", "i", "v" }, "<A-F>", "<cmd>Telescope live_grep<CR>", { desc = "project grep (cmd+shift+f)" })
map("n", "<A-/>", "gcc", { desc = "toggle comment (cmd+/)", remap = true })
map("v", "<A-/>", "gc", { desc = "toggle comment (cmd+/)", remap = true })
map({ "n", "i", "v" }, "<A-w>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "close buffer (cmd+w)" })

-- octo.nvim (GitHub PR review). octo lives in this nvim pane; gh-dash stays the
-- triage dashboard. The pane opens ~/Projects/candela (not a git repo), so use
-- explicit repo/URL commands for anything octo cannot infer from cwd.
map("n", "<leader>op", "<cmd>Octo pr list<CR>", { desc = "octo PR list (current repo)" })
map("n", "<leader>os", "<cmd>Octo search is:pr org:Candela-Ed<CR>", { desc = "octo search Candela PRs" })
map("n", "<leader>or", "<cmd>Octo review<CR>", { desc = "octo review current branch PR" })
map("n", "<leader>oc", "<cmd>Octo review comments<CR>", { desc = "octo pending review comments" })
