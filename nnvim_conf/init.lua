-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.path:append '/opt/homebrew/bin/'
vim.cmd [[
    let g:neovide_input_macos_alt_is_meta = v:true
    " Allow copy paste in neovim
    let g:neovide_input_use_logo = 1
    map <D-v> "+p<CR>
    map! <D-v> <C-R>+
    tmap <D-v> <C-R>+
    vmap <D-c> "+y<CR>
]]
require("plugins")

-- Disable automatic commenting on newline
vim.cmd("autocmd BufEnter * set formatoptions-=cro")
vim.cmd("autocmd BufEnter * setlocal formatoptions-=cro")

-- Setup rust ctags support
-- vim.cmd("autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/")
-- vim.cmd(
--     'autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand("%:p:h") . "&" | redraw!')

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.tabstop = 4      -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4  -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4   -- Number of spaces inserted when indenting

vim.opt.swapfile = false

vim.wo.relativenumber = true

-- [[ Basic Keymaps ]]
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- Enable format on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

vim.cmd [[
  hi QuickScopePrimary guifg='#af0f5f' gui=underline ctermfg=155 cterm=underline
  hi QuickScopeSecondary guifg='#5000ff' gui=underline ctermfg=81 cterm=underline
  " hi DiffAdd    ctermfg=NONE ctermbg=Green guifg=NONE guibg=#003800
  " hi DiffChange ctermfg=NONE ctermbg=Blue guifg=NONE guibg=#0000ff
  " hi DiffDelete ctermfg=NONE ctermbg=Red guifg=NONE guibg=#3f0000
  " hi DiffText   ctermfg=NONE ctermbg=Yellow guifg=NONE guibg=#474700
  " hi DiagnosticSignError guifg=#EF5350
  " hi DiagnosticError guifg=#EF5350
]]

vim.g.rust_recommended_style = false

require('mappings')
require('configs/abbrev')

vim.opt.fillchars:append { diff = "╱" }
vim.o.foldmethod = 'manual'
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
