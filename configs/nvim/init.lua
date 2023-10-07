vim.opt.guicursor = "i:ver100,a:blinkon1"
vim.api.nvim_set_hl(0, "SignColumn", { bg = none })
vim.api.nvim_set_hl(0, "Pmenu", { ctermbg = 4, ctermfg = 15 })
vim.wo.number = true
require("core.plugins")
require("core.configs.lsp_config")
