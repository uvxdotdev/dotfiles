return {
  '7sedam7/perec.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'folke/which-key.nvim', -- optional
  },
  init = function()
    require('perec').setup {}
  end,
}
