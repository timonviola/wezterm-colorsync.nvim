local M = {}

function M.table_to_lines(t)
    local s = vim.inspect(t)
    return vim.split(s, "\n", { plain = true })
end

function M.open_float_buf(lines, title)
    local buf = vim.api.nvim_create_buf(false, true) -- scratch
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "modifiable", true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = "lua"

    local width = math.min(100, vim.o.columns - 4)
    local height = math.min(30, vim.o.lines - 4)
    local row = math.floor((vim.o.lines - height) / 2 - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "single",
        title = title or "Debug",
    })

    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
end

return M
