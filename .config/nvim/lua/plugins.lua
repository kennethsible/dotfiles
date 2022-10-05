vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'tpope/vim-surround'
  use 'tpope/vim-commentary'
  use 'airblade/vim-gitgutter'
  use 'vim-airline/vim-airline'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use 'sainnhe/everforest'
end)
