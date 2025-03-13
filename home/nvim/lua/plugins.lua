return require('packer').startup(function(use)
   use 'wakatime/vim-wakatime'
   use 'Olical/conjure'
   use 'Exafunction/codeium.vim'
   use {
  "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    }
  }
  use {
      'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate'
  }
  use {
       "williamboman/mason.nvim",
       "williamboman/mason-lspconfig.nvim",
       "neovim/nvim-lspconfig",
  }
  use {
       'mrcjkb/rustaceanvim',
       version = '^3', -- Recommended
       ft = { 'rust' },
  }
	
end)

