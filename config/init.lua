-- Shoutout ChatGPT for this one. Seems valid
-- Move current line or visual selection by relative amount
local function move_relative(direction, offset_in)
  local mode = vim.fn.mode()
  local start_line, end_line

  if mode == "v" or mode == "V" then
    -- Visual mode range
    vim.cmd("normal! gv") -- reselect to get range
    start_line = vim.fn.line("'<")
    end_line = vim.fn.line("'>")
  else
    -- Normal mode, single line
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  -- Ask for number (relative offset) if not given as argument
  local offset
  if offset_in == nil then
      local ok, offset_str = pcall(vim.fn.input, "Move lines by (relative): ")
      if not ok or offset_str == "" then return end
      offset = tonumber(offset_str)
      if not offset then
        print("Invalid number")
        return
      end
  else
      offset = offset_in
  end

  if direction == "up" then
      offset = offset * -1
  end

  -- Calculate new line
  local target_line = offset > 0 and end_line + offset or start_line + offset - 1

  -- Edge handling
  local max_line = vim.fn.line("$")
  if target_line < 1 then target_line = 1 end
  if target_line > max_line then target_line = max_line end

  -- Execute move command
  vim.cmd(start_line .. "," .. end_line .. "move " .. target_line)
end

vim.keymap.set({ "n", "v" }, "<leader>m<Up>",
    function() move_relative("up", 1) end,
    { desc = "Move lines up by one" })

vim.keymap.set({ "n", "v" }, "<leader>m<Down>",
    function() move_relative("down", 1) end,
    { desc = "Move lines down by one" })

vim.keymap.set({ "n", "v" }, "<leader>mu",
    function() move_relative("up") end,
    { desc = "Move lines upward by a relative amount" })

vim.keymap.set({ "n", "v" }, "<leader>md",
    function() move_relative("down") end,
    { desc = "Move lines downward by a relative amount" })

vim.o.number         = true
vim.o.relativenumber = true
vim.o.signcolumn     = "yes"

vim.o.expandtab      = true -- convert tabs to spaces
vim.o.tabstop        = 4    -- TAB = 4 SPACE actually
vim.o.shiftwidth     = 4    -- "indent" commands use 4 spaces
vim.o.softtabstop    = 4    -- TAB = 4 SPACE visually

vim.o.swapfile       = false

vim.g.mapleader      = " "

local opts           = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, opts)

-- navigation between splits
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- copy to system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', opts)

-- diagnostics popup trigger
vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, opts)

-- netrw shortcut
vim.keymap.set("n", "<leader>e", ":Explore<CR>", opts)

-- make exiting the terminal not so impossible
-- autocomplete trigger
--vim.keymap.set("n", "<leader>cc", function()
--    vim.fn.feedkeys(
--        vim.api.nvim_replace_termcodes("<c-x><c-o>", true, true, true),
--        ""
--    )
--end, opts)

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', opts)

-- automatically assign tidal filetype to .tidal files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.tidal",
    command = "set filetype=tidal",
})

-- automatically assign filteype to KConfig and KConfig.projbuild files
vim.api.nvim_create_autocmd( { "BufRead", "BufNewFile" }, {
    pattern = { "KConfig", "KConfig.projbuild" },
    command = "set filetype=kconfig",
} )

-- lazy loading of tidal.nvim plugin when editing tidal files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tidal",
    callback = function()
        vim.cmd("packadd tidal.nvim")
        require("tidal").setup({
            -- remapping the keys because <S-CR> does not seem to be
            -- working in the terminal version or whatever
            mappings = {
                send_line   = { mode = { "n" }, key = "<leader>s" },
                send_visual = { mode = { "x" }, key = "<leader>s" },
                send_block  = { mode = { "n" }, key = "<leader>ss" },
            }
        })
    end,
})

require("kanagawa").setup({
    background = {
        dark = "dragon"
    },
    overrides = function(colors)
        local theme = colors.theme
        return {
            -- Popup menu background
            Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
            PmenuSel = { fg = theme.ui.special, bg = theme.ui.bg_p2, bold = true },
            PmenuSbar = { bg = theme.ui.bg_m1 },
            PmenuThumb = { bg = theme.ui.bg_p2 },
        }
    end,
})

-- LSP SETUP YEAH
vim.lsp.enable(
    {
        "lua_ls",
        "clangd",
        "ruff",
    }
)

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true)
            }
        }
    }
})

vim.cmd.colorscheme("kanagawa")
