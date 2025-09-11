-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- vim.keymap.set("n", "<leader>hw", "/")
require("hop").setup()
-- 搜索并跳转到单词
vim.keymap.set("n", "<leader>hw", "<cmd>HopWord<CR>")
-- 搜索并跳转到行
vim.keymap.set("n", "<leader>hs", "<cmd>HopLineStart<CR>")
-- 搜索并跳转到行

vim.keymap.set("n", "<leader>hv", "<cmd>HopVertical<CR>")
-- 搜索并跳转到字符
vim.keymap.set("n", "<leader>hc", "<cmd>HopChar1<CR>")
-- 搜索并跳转到字符
vim.keymap.set("n", "<leader>ht", "<cmd>HopChar2<CR>")
-- 搜索parttern并跳转到
vim.keymap.set("n", "<leader>hp", "<cmd>HopPattern<CR>")

-- place this in one of your configuration file(s)
local hop = require("hop")
local directions = require("hop.hint").HintDirection
vim.keymap.set("", "f", function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, { remap = true })
vim.keymap.set("", "F", function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, { remap = true })
vim.keymap.set("", "t", function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, { remap = true })
vim.keymap.set("", "T", function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, { remap = true })

local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "<leader>nd", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "<leader>md", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "<leader>ne", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "<leader>me", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "<leader>nw", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "<leader>mw", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
-- map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
-- map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
-- map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
-- map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
-- map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
-- map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- TODO Comment
vim.keymap.set("n", "<leader>nt", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "<leader>mt", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })
