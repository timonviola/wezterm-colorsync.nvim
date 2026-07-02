# wezterm-colorsync.nvim

This plugin allows you to syncronize your colorscheme with your terminal emulator.

# Installation
- add the package to your package manager (e.g. [like this](https://github.com/timonviola/config/commit/0afdce48222cf7fdc6c623486a8cde74d030c3ca#diff-9a770dc5857fcb7de97fca512935d9202e1d76cf09ffc1cbf13c2cf803f921a0R212-R217))

```diff
+    {
+        "timonviola/wezterm-colorsync.nvim",
+        config = function()
+            require("colorsync").setup()
+        end
+    },
```

  
- update your wezterm config, so wezterm reads the colorscheme from a file:

```lua
local file = io.open(wezterm.config_dir .. "/colorscheme", "r")

if file then
    config.color_scheme = file:read("*a")
    file:close()
else
    config.color_scheme = "Tokyo Night Day"
end
```

# Configuration

you can provide how you want to map your colorschemes as a lua table:

```lua
config = function()
  require("colorsync").setup(
    {
      scheme_map = {
        -- <nvim name> = <wezterm name>
        ["rose-pine"] = "rose-pine",
        ["rose-pine-main"] = "rose-pine",
        ["rose-pine-dawn"] = "rose-pine-dawn",
        ["rose-pine-moon"] = "rose-pine-moon",
      }
    }
  )
end
```

# Commands
- `Colorsync ShowSchemeMap`
    ```terminal
    ┌Colorscheme map─────────────────────────────────────────────────┐
    │{                                                               │
    │  ["catppuccin-frappe"] = "Catppuccin Frappe",                  │
    │  ["catppuccin-latte"] = "Catppuccin Latte",                    │
    │  ["catppuccin-macchiato"] = "Catppuccin Macchiato",            │
    │  ["catppuccin-mocha"] = "Catppuccin Mocha",                    │
    │  default = "NvimDark",                                         │
    │  gruvbox = "GruvboxDark",                                      │
    │  kanagawa = "Kanagawa (Gogh)",                                 │
    │  ["rose-pine"] = "rose-pine",                                  │
    │  ["rose-pine-dawn"] = "rose-pine-dawn",                        │
    │  ["rose-pine-main"] = "rose-pine",                             │
    │  ["rose-pine-moon"] = "rose-pine-moon",                        │
    │  ["tokyonight-day"] = "Tokyo Night Day",                       │
    │  ["tokyonight-night"] = "Tokyo Night",                         │
    │  ["tokyonight-storm"] = "Tokyo Night Storm"                    │
    │}                                                               │
    │                                                                │
    └────────────────────────────────────────────────────────────────┘
    ```

## Troubleshooting
- if `checkhealth colorsync` does not look like the one below, something is wrong
```terminal
colorsync:                         ✅

colorsync.statefile
- ✅ OK statefile

colorsync.wezterm_file
- ✅ OK wezterm_file

colorsync.autocmd
- ✅ OK autocmd

```

# How does it work?
It is a bit sketchcy that you have to add lua code to your wezterm config to make this work,
however, there is no other way to achieve persistence (between restarts), than writting
the information to disk.

The colorscheme information persistes in two files:
- Wezterm: `$WEZTERM_CONFIG_DIR/colorscheme`
- NeoVim: `stdpath("state")/colorscheme`

# Attribution
There are bunch of blog posts on how to achive something like this, I took quite some *inspiration* from here and there, but forgot where, anyway, thanks and try out this plugin!
