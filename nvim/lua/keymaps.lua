-- ~/.config/nvim/lua/keymaps.lua
-- Keymaps to make Neovim behave like IntelliJ IDEA Ultimate
-- Documentation: https://www.jetbrains.com/help/idea/mastering-keyboard-shortcuts.html

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ========================================
-- NAVIGATION & SEARCH (IntelliJ-style)
-- ========================================
map('n', '<C-p>', ":Telescope find_files<CR>", opts)           -- IntelliJ: Ctrl+Shift+N (Go to File)
map('n', '<C-Shift-f>', ":Telescope live_grep<CR>", opts)       -- IntelliJ: Ctrl+Shift+F (Find in Path)
map('n', '<C-f>', "/", opts)                                    -- IntelliJ: Ctrl+F (Find in File)
map('n', '<C-r>', ":%s/", opts)                                 -- IntelliJ: Ctrl+R (Replace in File)
map('n', '<C-e>', ":Telescope buffers<CR>", opts)               -- IntelliJ: Ctrl+E (Recent Files)
map('n', '<C-Shift-a>', ":Telescope commands<CR>", opts)        -- IntelliJ: Ctrl+Shift+A (Find Action)

-- ========================================
-- CODE NAVIGATION (IntelliJ-style)
-- ========================================
map('n', '<C-b>', vim.lsp.buf.definition, opts)                 -- IntelliJ: Ctrl+B (Go to Declaration)
map('n', '<C-Shift-b>', vim.lsp.buf.implementation, opts)       -- IntelliJ: Ctrl+Shift+B (Go to Implementation)
map('n', '<C-]>', vim.lsp.buf.definition, opts)                 -- Alternative: Go to Definition
map('n', '<C-u>', vim.lsp.buf.references, opts)                 -- IntelliJ: Ctrl+U (Find Usages)
map('n', '<C-h>', vim.lsp.buf.signature_help, opts)             -- IntelliJ: Ctrl+P (Parameter Info)
map('n', '<C-o>', '<C-o>', opts)                                -- IntelliJ: Ctrl+Alt+Left (Navigate Back)
map('n', '<C-i>', '<C-i>', opts)                                -- IntelliJ: Ctrl+Alt+Right (Navigate Forward)

-- ========================================
-- CODE EDITING & REFACTORING
-- ========================================
map('n', '<F2>', vim.lsp.buf.rename, opts)                      -- IntelliJ: Shift+F6 (Rename)
map('n', '<leader>r', vim.lsp.buf.rename, opts)                 -- Alternative: Rename
map('n', '<A-Enter>', vim.lsp.buf.code_action, opts)            -- IntelliJ: Alt+Enter (Show Intention Actions)
map('n', '<C-Alt-l>', function() vim.lsp.buf.format { async = true } end, opts) -- IntelliJ: Ctrl+Alt+L (Reformat Code)
map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts) -- Alternative: Format

-- ========================================
-- DOCUMENTATION & DIAGNOSTICS
-- ========================================
map('n', 'K', vim.lsp.buf.hover, opts)                          -- IntelliJ: Ctrl+Q (Quick Documentation)
map('n', '<C-q>', vim.lsp.buf.hover, opts)                      -- IntelliJ: Ctrl+Q (Quick Documentation)
map('n', '<leader>d', vim.diagnostic.open_float, opts)          -- Show Error/Warning Details
map('n', '<F8>', vim.diagnostic.goto_next, opts)                -- IntelliJ: F2 (Next Error)
map('n', '<S-F8>', vim.diagnostic.goto_prev, opts)              -- IntelliJ: Shift+F2 (Previous Error)

-- ========================================
-- AUTO-COMPLETION & COPILOT
-- ========================================
-- Note: These are configured in insert mode within the copilot plugin setup
-- Tab - Accept Copilot suggestion
-- Ctrl+J - Alternative accept
-- Ctrl+] - Next suggestion
-- Ctrl+[ - Previous suggestion
-- Ctrl+\ - Manually trigger suggestion

-- ========================================
-- COMMENTING (requires Comment.nvim plugin)
-- ========================================
-- map('n', '<C-/>', 'gcc', opts)                               -- IntelliJ: Ctrl+/ (Comment line)
-- map('v', '<C-/>', 'gc', opts)                                -- IntelliJ: Ctrl+/ (Comment selection)
-- map('n', '<C-Shift-/>', 'gbc', opts)                         -- IntelliJ: Ctrl+Shift+/ (Block comment)

-- ========================================
-- FILE EXPLORER (Project Tool Window)
-- ========================================
map('n', '<C-1>', ":NvimTreeToggle<CR>", opts)                  -- IntelliJ: Alt+1 (Project tool window)
map('n', '<leader>e', ":NvimTreeToggle<CR>", opts)              -- Alternative: Toggle explorer
map('n', '<leader>o', ":NvimTreeFocus<CR>", opts)               -- Focus on file explorer
map('n', '<leader>ff', ":NvimTreeFindFile<CR>", opts)           -- Find current file in explorer

-- ========================================
-- TAB NAVIGATION (Editor Tabs)
-- ========================================
map('n', '<C-Tab>', ":BufferLineCycleNext<CR>", opts)           -- IntelliJ: Ctrl+Tab (Next tab)
map('n', '<C-S-Tab>', ":BufferLineCyclePrev<CR>", opts)         -- IntelliJ: Ctrl+Shift+Tab (Previous tab)
map('n', '<A-Right>', ":BufferLineCycleNext<CR>", opts)         -- IntelliJ: Alt+Right (Next tab)
map('n', '<A-Left>', ":BufferLineCyclePrev<CR>", opts)          -- IntelliJ: Alt+Left (Previous tab)
map('n', '<leader>1', ":BufferLineGoToBuffer 1<CR>", opts)      -- Go to tab 1
map('n', '<leader>2', ":BufferLineGoToBuffer 2<CR>", opts)      -- Go to tab 2
map('n', '<leader>3', ":BufferLineGoToBuffer 3<CR>", opts)      -- Go to tab 3
map('n', '<leader>4', ":BufferLineGoToBuffer 4<CR>", opts)      -- Go to tab 4
map('n', '<leader>5', ":BufferLineGoToBuffer 5<CR>", opts)      -- Go to tab 5
map('n', '<C-w>', ":BufferLineCloseOthers<CR>", opts)           -- Close other tabs
map('n', '<C-F4>', ":bdelete<CR>", opts)                        -- IntelliJ: Ctrl+F4 (Close current tab)
map('n', '<leader>bc', ":BufferLinePickClose<CR>", opts)        -- Pick tab to close
map('n', '<leader>bp', ":BufferLinePick<CR>", opts)             -- Pick tab to go to

-- ========================================
-- SAVE & EXIT OPERATIONS
-- ========================================
map('n', '<C-s>', ":w<CR>", opts)                               -- IntelliJ: Ctrl+S (Save)
map('i', '<C-s>', "<Esc>:w<CR>a", opts)                         -- Save in insert mode
map('n', '<C-Shift-s>', ":wa<CR>", opts)                        -- IntelliJ: Ctrl+Shift+S (Save All)
map('n', '<leader>w', ":w<CR>", opts)                           -- Alternative: Save
map('n', '<leader>x', ":wq<CR>", opts)                          -- Save and quit current buffer
map('n', '<C-Alt-q>', ":qa<CR>", opts)                          -- IntelliJ: Ctrl+Q (Exit application)
map('n', '<leader>q', ":qa<CR>", opts)                          -- Alternative: Quit all
map('n', '<leader>Q', ":qa!<CR>", opts)                         -- Force quit all (no save)

-- ========================================
-- SCROLLING & MOVEMENT
-- ========================================
map('n', '<ScrollWheelUp>', '3<C-y>', opts)                     -- Scroll up 3 lines
map('n', '<ScrollWheelDown>', '3<C-e>', opts)                   -- Scroll down 3 lines
map('i', '<ScrollWheelUp>', '<C-o>3<C-y>', opts)                -- Scroll up in insert mode
map('i', '<ScrollWheelDown>', '<C-o>3<C-e>', opts)              -- Scroll down in insert mode
map('n', '<C-j>', '5j', opts)                                   -- Fast scroll down
map('n', '<C-k>', '5k', opts)                                   -- Fast scroll up
map('n', '<Page_Up>', '<C-u>', opts)                            -- Page up
map('n', '<Page_Down>', '<C-d>', opts)                          -- Page down

-- ========================================
-- LINE OPERATIONS (IntelliJ-style)
-- ========================================
map('n', '<C-d>', 'yyp', opts)                                  -- IntelliJ: Ctrl+D (Duplicate line)
map('v', '<C-d>', 'y`>p', opts)                                 -- Duplicate selection
map('n', '<C-y>', 'dd', opts)                                   -- IntelliJ: Ctrl+Y (Delete line)
map('n', '<A-Up>', ':m .-2<CR>==', opts)                        -- IntelliJ: Alt+Shift+Up (Move line up)
map('n', '<A-Down>', ':m .+1<CR>==', opts)                      -- IntelliJ: Alt+Shift+Down (Move line down)
map('v', '<A-Up>', ":m '<-2<CR>gv=gv", opts)                    -- Move selection up
map('v', '<A-Down>', ":m '>+1<CR>gv=gv", opts)                  -- Move selection down

-- ========================================
-- SELECTION & CLIPBOARD
-- ========================================
map('n', '<C-a>', 'ggVG', opts)                                 -- IntelliJ: Ctrl+A (Select All)
map('v', '<C-c>', '"+y', opts)                                  -- IntelliJ: Ctrl+C (Copy)
map('n', '<C-v>', '"+p', opts)                                  -- IntelliJ: Ctrl+V (Paste)
map('i', '<C-v>', '<C-o>"+p', opts)                             -- Paste in insert mode
map('v', '<C-x>', '"+x', opts)                                  -- IntelliJ: Ctrl+X (Cut)

-- ========================================
-- QUICK ACTIONS & TOOLS
-- ========================================
map('n', '<F12>', ":terminal<CR>", opts)                        -- IntelliJ: Alt+F12 (Terminal)
map('n', '<C-`>', ":terminal<CR>", opts)                        -- Alternative: Terminal
map('n', '<F5>', ":source %<CR>", opts)                         -- Reload current file
map('n', '<leader>z', ":set wrap!<CR>", opts)                   -- Toggle word wrap

-- ========================================
-- KEYMAP LEGEND (for reference)
-- ========================================
--[[
MOST IMPORTANT INTELLIJ-STYLE SHORTCUTS:

FILE OPERATIONS:
- Ctrl+S              Save file
- Ctrl+Shift+S        Save all files
- Ctrl+Q              Exit application

NAVIGATION:
- Ctrl+P              Find files (Go to File)
- Ctrl+Shift+F        Find in project (Find in Path)
- Ctrl+E              Recent files
- Ctrl+Shift+A        Find action

CODE NAVIGATION:
- Ctrl+B              Go to declaration
- Ctrl+Shift+B        Go to implementation
- Ctrl+U              Find usages
- F2                  Rename symbol
- Alt+Enter           Show code actions

TABS:
- Ctrl+Tab            Next tab
- Ctrl+Shift+Tab      Previous tab
- Ctrl+F4             Close current tab
- Alt+1               Toggle file explorer

EDITING:
- Ctrl+D              Duplicate line
- Ctrl+Y              Delete line
- Alt+Up/Down         Move line up/down
- Ctrl+Alt+L          Format code
- Ctrl+/              Comment line

COPILOT (Insert mode):
- Tab                 Accept suggestion
- Ctrl+]              Next suggestion
- Ctrl+[              Previous suggestion
--]]
