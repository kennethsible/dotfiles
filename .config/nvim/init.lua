-- NVIM CONFIG --

require('options')

-- KEY MAPPING --

vim.g.mapleader = ' '

local nnoremap = require('keymaps').nnoremap
nnoremap('<leader>pv', '<cmd>Ex<CR>')

local inoremap = require('keymaps').inoremap
inoremap('pv', '<Esc>')

-- NVIM THEME --

vim.opt.background = 'dark'

vim.g.everforest_background = 'soft'
vim.g.everforest_ui_contrast = 'high'
vim.g.everforest_transparent_background = 1
vim.g.everforest_better_performance = 1

vim.cmd('colorscheme everforest')
