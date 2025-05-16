return {
    { 'echasnovski/mini.pairs', version = '*', opts = {} },{
  'echasnovski/mini.surround',
  version = '*',
  config = function()
    require('mini.surround').setup()
  end,
},{
  'echasnovski/mini.ai',
  version = '*',
  config = function()
    require('mini.ai').setup()
  end,
}
}
