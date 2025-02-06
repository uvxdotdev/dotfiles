require 'core.options' -- Load general options
require 'core.keymaps' -- Load general keymaps
require 'core.snippets' -- Custom code snippets

-- Set up the Lazy plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins
require('lazy').setup {
  require 'plugins.neotree',
  require 'plugins.colortheme',
  require 'plugins.bufferline',
  require 'plugins.lualine',
  require 'plugins.treesitter',
  require 'plugins.telescope',
  require 'plugins.lsp',
  require 'plugins.autocompletion',
  require 'plugins.none-ls',
  require 'plugins.gitsigns',
  -- require 'plugins.indent-blankline',
  require 'plugins.misc',
  require 'plugins.comment',
  require 'plugins.obsidian',
  require 'plugins.markdown',
  -- require 'plugins.markview',
  require 'plugins.better-esc',
  require 'plugins.waka',
  require 'plugins.supermaven',
  require 'plugins.typr',
  require 'plugins.snacks',
  require 'plugins.mini-surround',
  require 'plugins.mini-ai',
}

vim.cmd.colorscheme 'catppuccin'
-- vim.cmd.colorscheme 'nord'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
-- Function to process markdown files using nushell script
-- vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
--   pattern = { '*.md', '*.markdown' },
--   callback = function()
--     -- Get the full path of the current file
--     local file_path = vim.fn.expand '%:p'
--
--     -- Create the command that sources the script file and runs the function
--     local cmd = string.format('nu -c \'source ~/.config/nushell/scripts/nu-task.nu; process-markdown "%s"\'', file_path)
--
--     -- Execute the command asynchronously
--     vim.fn.jobstart(cmd, {
--       on_exit = function(_, exit_code)
--         if exit_code == 0 then
--           print 'Markdown processing completed successfully'
--         else
--           vim.api.nvim_err_writeln 'Error processing markdown file'
--         end
--       end,
--     })
--   end,
-- })

require 'scripts.dynamo'
require 'snippets.keymaps'
require 'snippets.go'
