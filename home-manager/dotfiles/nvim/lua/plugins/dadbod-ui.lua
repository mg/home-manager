local function add_elixir_project_dbs(mix_env)
	local root = vim.fs.root(0, "mix.exs") or vim.fs.root(vim.fn.getcwd(), "mix.exs")

	if not root then
		vim.notify("DBUIElixir: not inside an Elixir project", vim.log.levels.ERROR)
		return
	end

	local code = [[
marker = "__DADBOD_ELIXIR_DB__"
app = Mix.Project.config()[:app]
repos = Application.get_env(app, :ecto_repos, [])

if repos == [] do
  raise "No Ecto repos configured for #{inspect(app)}"
end

encode = fn value -> URI.encode_www_form(to_string(value)) end

for repo <- repos do
  config = Application.get_env(app, repo, [])
  url = config[:url]

  url =
    if url do
      url
    else
      username = Keyword.get(config, :username, System.get_env("USER") || "postgres")
      password = Keyword.get(config, :password, "")
      hostname = Keyword.get(config, :hostname, "localhost")
      port = Keyword.get(config, :port, 5432)
      database = Keyword.fetch!(config, :database)

      userinfo =
        if password in [nil, ""] do
          encode.(username)
        else
          encode.(username) <> ":" <> encode.(password)
        end

      "postgresql://" <> userinfo <> "@" <> to_string(hostname) <> ":" <> to_string(port) <> "/" <> encode.(database)
    end

  name = Atom.to_string(app) <> ":" <> List.last(Module.split(repo)) <> ":" <> System.get_env("MIX_ENV", "dev")
  IO.puts(Enum.join([marker, name, url], "\t"))
end
]]

	vim.notify("DBUIElixir: reading " .. mix_env .. " database config...", vim.log.levels.INFO)

	-- Elixir/mix live in the dev container, not on the host. When direnv has
	-- started one (DEVC_NAME set), run `mix eval` inside it via `container
	-- exec`, forwarding MIX_ENV + the project-local mix state and the postgres
	-- vars the Repo config reads. Running host mix instead recompiles the
	-- whole project (host vs container Elixir differ) and blows the timeout.
	-- Fall back to bare `mix` for non-container Elixir projects.
	local mix_cmd
	if vim.env.DEVC_NAME and vim.env.DEVC_NAME ~= "" then
		mix_cmd = {
			"container", "exec",
			"-w", root,
			"-e", "MIX_ENV=" .. mix_env,
			"-e", "MIX_HOME", "-e", "HEX_HOME",
			"-e", "PGHOST", "-e", "PGPORT", "-e", "PGUSER", "-e", "PGPASSWORD",
			"-e", "PGDATABASE", "-e", "DATABASE_URL",
			"-i", vim.env.DEVC_NAME,
			"mix", "eval", code,
		}
	else
		mix_cmd = { "mix", "eval", code }
	end

	vim.system(mix_cmd, {
		cwd = root,
		env = { MIX_ENV = mix_env },
		text = true,
		timeout = 10000,
	}, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				local stderr = result.stderr or ""
				local stdout = result.stdout or ""
				local message = stderr ~= "" and stderr or stdout
				if message == "" and result.code == 124 then
					message = "mix eval timed out after 10 seconds"
				end
				vim.notify("DBUIElixir failed:\n" .. message, vim.log.levels.ERROR)
				return
			end

			local dbs = vim.g.dbs or {}
			local added = {}

			for line in (result.stdout or ""):gmatch("[^\n]+") do
				local name, url = line:match("^__DADBOD_ELIXIR_DB__\t([^\t]+)\t(.+)$")
				if name and url then
					dbs[name] = url
					table.insert(added, name)
				end
			end

			if #added == 0 then
				vim.notify("DBUIElixir: no database config found", vim.log.levels.ERROR)
				return
			end

			vim.g.dbs = dbs
			vim.notify("DBUIElixir: added " .. table.concat(added, ", "), vim.log.levels.INFO)
			vim.cmd("DBUI")
		end)
	end)
end

return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_use_nerd_fonts = 1

		vim.api.nvim_create_user_command("DBUIElixir", function(opts)
			local mix_env = opts.args ~= "" and opts.args or vim.env.MIX_ENV or "dev"
			add_elixir_project_dbs(mix_env)
		end, {
			nargs = "?",
			complete = function()
				return { "dev", "test", "prod" }
			end,
		})
	end,
}
