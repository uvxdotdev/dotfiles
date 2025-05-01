return {
  'stevearc/oil.nvim',
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
  config = function()
	  require('oil').setup {
		  columns = {"icons"},
		  keymaps = {
			  ["<C-h>"] = false,
		  },
		  view_options = {
			  show_hidden = true,
		  }
	  }
	  vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end
}
