require("nvim-tree").setup({
  -- Disable netrw at the very start of your init.lua (strongly advised)
  disable_netrw = true,
  hijack_netrw = true,

  -- Open nvim-tree when starting nvim with a directory
  hijack_directories = {
    enable = true,
    auto_open = true,
  },

  view = {
    width = 35,
    side = "left",
    -- Auto resize when terminal size changes
    adaptive_size = false,
  },

  renderer = {
    group_empty = true,
    highlight_git = true,
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },

  filters = {
    dotfiles = false,
    custom = { ".git", "node_modules", ".cache" },
  },

  -- Git integration
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },

  -- Actions
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
    },
  },

  -- Auto open nvim-tree when starting nvim
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- Custom mappings
    vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent,        opts('Up'))
    vim.keymap.set('n', '?',     api.tree.toggle_help,                  opts('Help'))
  end,
})
