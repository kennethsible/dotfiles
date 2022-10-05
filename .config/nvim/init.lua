-- NVIM CONFIG --

vim.opt.backup = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.showmode = false
vim.opt.smartcase = true
vim.opt.autoindent = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.cursorline = true
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.showmatch = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- KEY MAPPING --

vim.g.mapleader = " "

local nnoremap = require("keymap").nnoremap

nnoremap("<leader>ex", "<cmd>Ex<CR>")

-- NVIM THEME --

vim.opt.background = "dark"

vim.g.everforest_background = 'soft'
vim.g.everforest_ui_contrast = 'high'
vim.g.everforest_transparent_background = 1
vim.g.everforest_better_performance = 1

vim.cmd("colorscheme everforest")
