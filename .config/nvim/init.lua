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
  require 'plugins.rocks',
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
  require 'plugins.image',
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

require('image').setup {
  backend = 'kitty',
  processor = 'magick_cli', -- or "magick_cli"
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      floating_windows = false, -- if true, images will be rendered in floating markdown windows
      filetypes = { 'markdown', 'vimwiki' }, -- markdown extensions (ie. quarto) can go here
    },
    neorg = {
      enabled = true,
      filetypes = { 'norg' },
    },
    typst = {
      enabled = true,
      filetypes = { 'typst' },
    },
    html = {
      enabled = false,
    },
    css = {
      enabled = false,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
  window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'snacks_notif', 'scrollview', 'scrollview_sign' },
  editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
  tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
  hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' }, -- render image files as images when opened
}
