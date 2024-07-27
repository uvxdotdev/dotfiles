return {
  'akinsho/bufferline.nvim',
  version = '*',
  opts = {
    transparent = true,
  },
  config = function()
    require('bufferline').setup {}
  end,
  dependencies = 'nvim-tree/nvim-web-devicons',
}
