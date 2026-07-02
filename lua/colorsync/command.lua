--- Neovim commands
local M = {}

function M.setup(commands)
    commands = commands or {}

    vim.api.nvim_create_user_command("Colorsync", function(params)
        local sub = params.args
        if sub == "ShowSchemeMap" then
            commands.ShowSchemeMap()
        else
            vim.notify(("colorsync: unknown subcommand %q"):format(sub), vim.log.levels.ERROR)
        end
    end, {
        nargs = "?",
        complete = function()
            return { "ShowSchemeMap" }
        end,
    })
end

return M
