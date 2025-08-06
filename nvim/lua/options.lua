vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Set leader key to space bar (must be set before any leader keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Mouse and scroll configuration
vim.opt.mouse = "a"                    -- Enable mouse support in all modes
vim.opt.mousemodel = "popup"           -- Right-click shows popup menu
vim.opt.scrolloff = 8                  -- Keep 8 lines visible when scrolling
vim.opt.sidescrolloff = 8              -- Keep 8 columns visible when side-scrolling
vim.opt.scroll = 10                    -- Number of lines to scroll with Ctrl+U/D

-- Smooth scrolling behavior
vim.opt.lazyredraw = false             -- Don't redraw during macros (but keep responsive)

-- Clipboard integration with macOS
vim.opt.clipboard = "unnamedplus"      -- Use system clipboard for all operations
vim.g.clipboard = {
  name = 'macOS-clipboard',
  copy = {
    ['+'] = 'pbcopy',
    ['*'] = 'pbcopy',
  },
  paste = {
    ['+'] = 'pbpaste',
    ['*'] = 'pbpaste',
  },
  cache_enabled = 1,
}
