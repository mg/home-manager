-- https://github.com/folke/sidekick.nvim

return {
  src = "https://github.com/folke/sidekick.nvim",
  config = function()
    local function send_file_context(ctx)
      local loc = require("sidekick.cli.context.location")
      local ok, source_path = pcall(vim.api.nvim_buf_get_var, ctx.buf, "pi_session_path")

      if ok and type(source_path) == "string" and vim.fn.filereadable(source_path) == 1 then
        return loc.get(vim.tbl_extend("force", ctx, { name = source_path }), { kind = "file" })
      end

      return loc.is_file(ctx.buf) and loc.get(ctx, { kind = "file" })
    end

    require("sidekick").setup({
      cli = {
        context = {
          file = send_file_context,
        },
        mux = {
          enabled = true,
          create = "split",
          split = {
            vertical = true,
            size = 0.4,
          },
          backend = "tmux",
        },
      },
    })
  end,
  keys = {
    {
      "<leader>aa",
      function() require("sidekick.cli").toggle() end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>ad",
      function() require("sidekick.cli").close() end,
      desc = "Sidekick Detach CLI",
    },
    {
      "<leader>af",
      function() require("sidekick.cli").send({ msg = "{file}" }) end,
      desc = "Sidekick Send File",
    },
    {
      "<leader>an",
      function() require("sidekick").nes_jump_or_apply() end,
      desc = "Sidekick Next Edit",
    },
    {
      "<leader>aN",
      function() require("sidekick.nes").update() end,
      desc = "Sidekick Request Next Edit",
    },
    {
      "<leader>ap",
      function() require("sidekick.cli").prompt() end,
      mode = { "n", "x" },
      desc = "Sidekick Prompt",
    },
    {
      "<leader>as",
      function() require("sidekick.cli").select() end,
      desc = "Sidekick Select CLI",
    },
    {
      "<leader>at",
      function() require("sidekick.cli").send({ msg = "{this}" }) end,
      mode = { "n", "x" },
      desc = "Sidekick Send This",
    },
    {
      "<leader>av",
      function() require("sidekick.cli").send({ msg = "{selection}" }) end,
      mode = { "x" },
      desc = "Sidekick Send Selection",
    },
  },
}
