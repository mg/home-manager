return {
	"ThePrimeagen/harpoon",
	enabled = true,
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },

	keys = function()
		local harpoon = require("harpoon")
		local conf = require("telescope.config").values

		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		return {
			-- Harpoon marked files 1 to 4
			{
				"<C-1>",
				function()
					harpoon:list():select(1)
				end,
				desc = "Harpoon buffer 1",
			},
			{
				"<C-2>",
				function()
					harpoon:list():select(2)
				end,
				desc = "Harpoon buffer 2",
			},
			{
				"<C-3>",
				function()
					harpoon:list():select(3)
				end,
				desc = "Harpoon buffer 3",
			},
			{
				"<C-4>",
				function()
					harpoon:list():select(4)
				end,
				desc = "Harpoon buffer 4",
			},

			-- Harpoon next and previous
			{
				"<C-S-N>",
				function()
					harpoon:list():next()
				end,
				desc = "Harpoon next buffer",
			},
			{
				"<C-S-P>",
				function()
					harpoon:list():prev()
				end,
				desc = "Harpoon prev buffer",
			},

			-- Harpoon user interface
			{
				"<C-e>",
				function()
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon list files",
			},
			{
				"<leader>ha",
				function()
					harpoon:list():add()
				end,
				desc = "Harpoon add file",
			},

			{
				"<leader>hr",
				function()
					harpoon:list():remove()
				end,
				desc = "Harpoon remove file",
			},

			-- Use Telescope as Harpoon user interface
			{
				"<leader>so",
				function()
					toggle_telescope(harpoon:list())
				end,
				desc = "Open Harpoon inside Telescope",
			},
		}
	end,
}
