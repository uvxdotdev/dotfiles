local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", opts)
vim.keymap.set("n", "<Tab>", "<Plug>(cokeline-focus-next)", opts)
vim.keymap.set("n", "<leader>x", ":bdelete!<CR>", opts) -- close buffer

vim.keymap.del("i", "<CR>") -- Insert mode
vim.keymap.del("i", "<Tab>") -- Insert mode
