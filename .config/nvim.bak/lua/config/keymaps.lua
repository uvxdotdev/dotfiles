local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", opts)
vim.keymap.set("n", "<Tab>", "<Plug>(cokeline-focus-next)", opts)
vim.keymap.set("n", "<leader>x", ":bdelete!<CR>", opts) -- close buffer

vim.keymap.del("i", "<CR>") -- Insert mode
vim.keymap.del("i", "<Tab>") -- Insert mode

vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>cc", ":CodeCompanionToggle<CR>", opts)
