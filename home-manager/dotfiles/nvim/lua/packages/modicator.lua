-- https://github.com/mawkler/modicator.nvim

return {
  src = "https://github.com/mawkler/modicator.nvim",
  config = function()
    local modicator = require("modicator")

    local function use_lualine_colors()
      -- Modicator only copies Lualine colors into groups that do not already
      -- exist, but colorschemes commonly define these groups themselves.
      for _, mode in ipairs(modicator.modes) do
        vim.api.nvim_set_hl(0, mode .. "Mode", {})
      end
      require("modicator.integration.lualine").use_lualine_mode_highlights("a")
      modicator.set_cursor_line_highlight("NormalMode")
    end

    use_lualine_colors()
    modicator.setup({
      integration = {
        lualine = {
          enabled = true,
          mode_section = "a",
        },
      },
    })

    -- Colorscheme packages load after this file alphabetically, so reapply
    -- Lualine's mode colors after every colorscheme change.
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("modicator_lualine_colors", { clear = true }),
      callback = use_lualine_colors,
    })
  end,
}
