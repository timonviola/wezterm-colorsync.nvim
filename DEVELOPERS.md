# local set up 
- clone repo
- using lazy.nvim: 
```lua
{
    dir = vim.fn.expand("/local/path/to/repo/wezterm-colorsync.nvim"),
    dependencies = {
      { "rcarriga/nvim-notify" },
    },
    name = "colorsync", -- recommended if the dir name isn't unique
    config = function()
      require("colorsync").setup()
    end,
  },
```
