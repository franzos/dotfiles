local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath

local packer_bootstrap = ensure_packer()

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

--[[ init.lua ]]

-- LEADER
-- These keybindings need to be defined before the first /
-- is called; otherwise, it will default to "\"
vim.g.mapleader = ","
vim.g.localleader = "\\"

vim.g.codeium_enabled = false

-- IMPORTS
-- require('vars')      -- Variables
-- require('opts')      -- Options
-- require('keys')      -- Keymaps

require('plugins')  -- Plugins
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "eslint" }
})

require("mason-lspconfig").setup_handlers {
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
        	require("lspconfig")[server_name].setup {}
	    	if server_name == 'eslint' then
			require('lspconfig').eslint.setup({
				capabilities = lsp_capabilities,
				root_dir = function(fname)
					return require('lspconfig').util.find_git_ancestor(fname)
				end,
				cmd = { 'vscode-eslint-language-server', '--stdio' --[[ '--stdin', '--stdin-filename', '%filepath' ]] },
				-- cmd = { 'eslint', '--stdin', '--stdin-filename', '%filepath' },
				filetypes = { 'javascript', 'javascriptreact' },
				settings = {
					debug = true,
					rootMarkers = { '.git/' },
					languages = {
						javascript = { eslint_config },
						javascriptreact = { eslint_config },
					},
					workingDirectory = { mode = 'auto' },
					-- nodePath = homeDir .. '/.nvm/versions/node/' .. latestNodeVersion .. '/lib/node_modules/'
				},
				-- libs = { homeDir .. '/.nvm/versions/node/' .. latestNodeVersion .. '/lib/node_modules/' },
			})
			return
		elseif server_name == 'rust_analyzer' then
			-- do nothing
		else
			require('lspconfig')[server_name].setup({
				capabilities = lsp_capabilities,
				root_dir = function(fname)
					return require('lspconfig').util.find_git_ancestor(fname)
				end,
			})
		end
	end,
        -- Next, you can provide a dedicated handler for specific servers.
        -- For example, a handler override for the `rust_analyzer`:
	--["rust_analyzer"] = function ()
        --    require("rust-tools").setup {}
        --end
    }
