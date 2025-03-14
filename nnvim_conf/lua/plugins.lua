-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require("lazy").setup({
	-- NOTE: First, some plugins that don't require any configuration

	-- Detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	{
		"williamboman/mason.nvim",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		opts = {
			ensure_installed = {
				"typescript-language-server",
				"tailwindcss-language-server",
				"eslint-lsp",
				"prettierd",
			},
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup()
			-- Never format with tsserver
			vim.lsp.buf.format({
				filter = function(client)
					print(client.name)
					return client.name ~= "tsserver" or client.name ~= "ts_ls"
				end,
			})
		end,
	},

	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		-- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			-- 'saghen/blink.cmp',

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			-- { 'j-hui/fidget.nvim', opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			"folke/neodev.nvim",
		},
		config = function()
			require("configs.lspconfig")
		end,
	},
	-- Useful plugin to show you pending keybinds.
	{
		"folke/which-key.nvim",
		opts_extend = { "spec" },
		opts = {
			preset = "helix",
			defaults = {},
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader><tab>", group = "tabs" },
					{ "<leader>c", group = "code" },
					{ "<leader>d", group = "debug" },
					{ "<leader>dp", group = "profiler" },
					{ "<leader>f", group = "file/find" },
					{ "<leader>g", group = "git" },
					{ "<leader>gh", group = "hunks" },
					{ "<leader>q", group = "quit/session" },
					{ "<leader>s", group = "search" },
					{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
					{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
					{ "[", group = "prev" },
					{ "]", group = "next" },
					{ "g", group = "goto" },
					{ "gs", group = "surround" },
					{ "z", group = "fold" },
					{
						"<leader>b",
						group = "buffer",
						expand = function()
							return require("which-key.extras").expand.buf()
						end,
					},
					{
						"<leader>w",
						group = "windows",
						proxy = "<c-w>",
						expand = function()
							return require("which-key.extras").expand.win()
						end,
					},
					-- better descriptions
					{ "gx", desc = "Open with system app" },
				},
			},
		},
	},
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			-- signs = {
			--     add = { text = '+' },
			--     change = { text = '~' },
			--     delete = { text = '_' },
			--     topdelete = { text = '‾' },
			--     changedelete = { text = '~' },
			-- },
			sign_priority = 100,
			on_attach = function(bufnr)
				-- don't override the built-in and fugitive keymaps
				local gs = package.loaded.gitsigns
				vim.keymap.set({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })

				vim.keymap.set({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "[G]it [S]tage hunk" })
				vim.keymap.set({ "n", "v" }, "<leader>gu", ":Gitsigns reset_hunk<CR>", { desc = "[G]it [U]ndo hunk" })
				vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "[G]it [p]op hunk diff" })
				vim.keymap.set("n", "]g", ": Gitsigns next_hunk<CR>", { desc = "next git hunk" })
				vim.keymap.set("n", "[g", ": Gitsigns prev_hunk<CR>", { desc = "prev git hunk" })
				vim.keymap.set("n", "<leader>gd", function()
					require("gitsigns").diffthis("~")
				end, { desc = "prev git hunk" })
			end,
		},
	},
	-- Fuzzy Finder (files, lsp, etc)
	-- {
	--     'nvim-tree/nvim-tree.lua',
	--     -- lazy = false,
	--     event = "VeryLazy",
	--     config = function()
	--         require("nvim-tree").setup({
	--             view = {
	--                 width = 50,
	--             },
	--         })
	--
	--         vim.keymap.set("n", "<C-q>", ":NvimTreeFindFileToggle<CR>", { desc = "Toggle nvim tree" })
	--     end
	-- },
	{
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		opts = {}, -- required, even if empty
		config = function()
			require("lsp-endhints").setup()
		end,
	},
	{
		-- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- Add languages to be installed here that you want installed for treesitter
				ensure_installed = {
					"c",
					"cpp",
					"go",
					"lua",
					"python",
					"rust",
					"tsx",
					"javascript",
					"typescript",
					"vimdoc",
					"vim",
					"bash",
				},

				-- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
				auto_install = false,

				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = false,
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["al"] = "@statement.outer",
							["il"] = "@statement.outer",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
							["]l"] = "@statement.outer",
						},
						goto_next_end = {
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_previous_start = {
							["[m"] = "@function.outer",
							["[l"] = "@statement.outer",
							["[["] = "@class.outer",
						},
						goto_previous_end = {
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
					swap = {
						enable = true,
						swap_next = {
							["<leader>a"] = "@parameter.inner",
						},
						swap_previous = {
							["<leader>A"] = "@parameter.inner",
						},
					},
				},
			})
		end,
	},

	-- sharon configs
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			local build_common_surround = function(object_name, opener, closer)
				return {
					add = function()
						return { { object_name .. opener }, { closer } }
					end,
					find = function()
						local config = require("nvim-surround.config")
						return config.get_selection({ node = "generic_type" })
					end,
					delete = "^(" .. object_name .. opener .. ")().-(" .. closer .. ")()$",
					change = {
						target = "^(" .. object_name .. opener .. ")().-(" .. closer .. ")()$",
						-- replacement = function()
						--     local config = require("nvim-surround.config")
						--     local result = config.get_input("Enter the new type: ")
						--     if result then
						--         return { { result .. opener }, { closer } }
						--     end
						-- end,
					},
				}
			end
			require("nvim-surround").setup({
				move_cursor = "sticky",
				surrounds = {
					["R"] = build_common_surround("anyhow::Result", "<", ">"),
					["V"] = build_common_surround("Vec", "<", ">"),
					["O"] = build_common_surround("Option", "<", ">"),
					["S"] = build_common_surround("Some", "(", ")"),
					["D"] = build_common_surround("dbg!", "(", ")"),
					-- ["S"] = {
					--     add = function()
					--         return { { "Some(" }, { ")" } }
					--     end,
					-- },
					["K"] = {
						add = function()
							return { { "Ok(" }, { ")" } }
						end,
					},
					-- "generic"
					["g"] = {
						add = function()
							local config = require("nvim-surround.config")
							local result = config.get_input("Enter the generic name: ")
							if result then
								return { { result .. "<" }, { ">" } }
							end
						end,
						find = function()
							local config = require("nvim-surround.config")
							return config.get_selection({ node = "generic_type" })
						end,
						delete = "^(.-<)().-(>)()$",
						change = {
							target = "^(.-<)().-(>)()$",
							replacement = function()
								local config = require("nvim-surround.config")
								local result = config.get_input("Enter the generic name: ")
								if result then
									return { { result .. "<" }, { ">" } }
								end
							end,
						},
					},
				},
			})
		end,
	},
	{
		"tpope/vim-fugitive",
		lazy = false,
		config = function()
			vim.keymap.set("n", "<leader>gB", "<cmd> Git blame<CR>", { desc = "Run [G]it [B]lame on file" })
			vim.keymap.set("n", "<leader>gf", ":Git<CR>/taged<CR>:noh<CR>j", { desc = "[G]it [F]ugitive" })
			vim.keymap.set("n", "<leader>gl", ":Git log<CR>", { desc = "[G]it [L]og" })
			vim.keymap.set("n", "<leader>ga", ":Git commit --amend<CR>", { desc = "[G]it [A]mend" })
			vim.keymap.set("n", "<leader>gc", ':Git commit -m "', { desc = "[G]it [C]ommit" })
			vim.keymap.set("n", "<leader>grm", ":Git pull origin main --rebase<CR>", { desc = "[G]it [R]ebase [M]ain" })
			vim.keymap.set("n", "<leader>grc", ":Git rebase --continue<CR>", { desc = "[G]it [R]ebase [C]ontinue" })
			vim.keymap.set("n", "<leader>gra", ":Git rebase --abort<CR>", { desc = "[G]it [R]ebase [A]bort" })
		end,
	},
	-- {
	--     "folke/persistence.nvim",
	--     event = "BufReadPre",
	--     opts = {},
	--     -- stylua: ignore
	--     keys = {
	--         { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
	--         { "<leader>qS", function() require("persistence").select() end,              desc = "Select Session" },
	--         { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
	--         { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
	--     },
	-- },
	{
		"rmagatti/auto-session",
		lazy = false,
		config = function()
			require("auto-session").setup({
				log_level = "error",
				auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			})
			vim.keymap.set("n", "<leader>ds", "<cmd> SessionDelete<CR>", { desc = "[G]it [R]ebase [A]bort" })
		end,
	},
	{
		"mrjones2014/smart-splits.nvim",
		config = function()
			require("smart-splits").setup()
			-- Tmux window navigation
			vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
			vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
			vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
			vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
			-- moving between splits
			vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
			vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
			vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
			vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
			vim.keymap.set("t", "<C-h>", require("smart-splits").move_cursor_left)
			vim.keymap.set("t", "<C-j>", require("smart-splits").move_cursor_down)
			vim.keymap.set("t", "<C-k>", require("smart-splits").move_cursor_up)
			vim.keymap.set("t", "<C-l>", require("smart-splits").move_cursor_right)
			-- swapping buffers between windows
			vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
			vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
			vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
			vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)
		end,
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		lazy = false,
		opts = {
			menu = {
				width = vim.api.nvim_win_get_width(0) - 4,
			},
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
			},
		},
		config = function(_) -- Add the opts parameter here
			local harpoon = require("harpoon")

			function Harpoon_files()
				-- define visual settings for harpoon tabline
				local yellow = "#DCDCAA"
				local yellow_orange = "#D7BA7D"
				local background_color = "#282829"
				local grey = "#797C91"
				local light_blue = "#9CDCFE"

				vim.api.nvim_set_hl(0, "HarpoonInactive", { fg = grey, bg = background_color })
				vim.api.nvim_set_hl(0, "HarpoonActive", { fg = light_blue, bg = background_color })
				vim.api.nvim_set_hl(0, "HarpoonNumberActive", { fg = yellow, bg = background_color })
				vim.api.nvim_set_hl(0, "HarpoonNumberInactive", { fg = yellow_orange, bg = background_color })
				vim.api.nvim_set_hl(0, "TabLineFill", { fg = "white", bg = background_color })

				local contents = {}
				local marks_length = harpoon:list():length()
				local current_file_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
				for index = 1, marks_length do
					local harpoon_file_path = harpoon:list():get(index).value
					local file_name = harpoon_file_path == "" and "(empty)"
						or vim.fn.fnamemodify(harpoon_file_path, ":t")

					if current_file_path == harpoon_file_path then
						contents[index] =
							string.format("%%#HarpoonNumberActive# %s. %%#HarpoonActive#%s ", index, file_name)
					else
						contents[index] =
							string.format("%%#HarpoonNumberInactive# %s. %%#HarpoonInactive#%s ", index, file_name)
					end
				end

				return table.concat(contents)
			end

			vim.opt.showtabline = 2
			vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "User" }, {
				callback = function(ev)
					vim.o.tabline = Harpoon_files()
				end,
			})
		end,
		keys = function()
			local keys = {
				{
					"<leader>h",
					function()
						require("harpoon"):list():add()
					end,
					desc = "Harpoon File",
				},
				{
					"<leader>H",
					function()
						local harpoon = require("harpoon")
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "Harpoon Quick Menu",
				},
			}

			for i = 1, 6 do
				table.insert(keys, {
					"<leader>" .. i,
					function()
						require("harpoon"):list():select(i)
					end,
					desc = "Harpoon to File " .. i,
				})
			end
			return keys
		end,
	},
	-- {
	-- 	"ThePrimeagen/harpoon",
	-- 	branch = "master",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 	},
	-- 	config = function()
	-- 		-- Harpoon 2
	-- 		-- local harpoon = require("harpoon")
	-- 		-- vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end)
	-- 		-- vim.keymap.set("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
	-- 		--
	-- 		-- vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
	-- 		-- vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
	-- 		-- vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
	-- 		-- vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
	--
	-- 		vim.keymap.set("n", "<leader>ha", function()
	-- 			require("harpoon.mark").add_file()
	-- 		end)
	-- 		vim.keymap.set("n", "<leader>hm", function()
	-- 			require("harpoon.ui").toggle_quick_menu()
	-- 		end)
	--
	-- 		vim.keymap.set("n", "<leader>1", function()
	-- 			require("harpoon.ui").nav_file(1)
	-- 		end)
	-- 		vim.keymap.set("n", "<leader>2", function()
	-- 			require("harpoon.ui").nav_file(2)
	-- 		end)
	-- 		vim.keymap.set("n", "<leader>3", function()
	-- 			require("harpoon.ui").nav_file(3)
	-- 		end)
	-- 		vim.keymap.set("n", "<leader>4", function()
	-- 			require("harpoon.ui").nav_file(4)
	-- 		end)
	-- 		vim.keymap.set("n", "<leader>5", function()
	-- 			require("harpoon.ui").nav_file(5)
	-- 		end)
	-- 		vim.keymap.set("n", "<leader>6", function()
	-- 			require("harpoon.ui").nav_file(6)
	-- 		end)
	-- 	end,
	-- },
	{
		dir = "/Users/sharonavni/personal/git-mediate.nvim",
		dependencies = { "skywind3000/asyncrun.vim" },
		event = "VeryLazy",
		config = function()
			require("git-mediate").setup()
			vim.keymap.set("n", "<leader>g[", ":GitMediate<CR>", { desc = "Run git mediate conflict resolver" })
		end,
		lazy = false,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				panel = {
					enabled = true,
					auto_refresh = true,
				},
				suggestion = {
					enabled = true,
					auto_trigger = true,
					accept = false, -- disable built-in keymapping
				},
			})
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "S",     mode = { "n", "o" },      function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},
	-- {
	-- 	"ggandor/leap.nvim",
	-- 	lazy = false,
	-- 	config = function()
	-- 		require("leap").add_default_mappings()
	-- 		-- require('leap').add_repeat_mappings(';', ',', {
	-- 		--     relative_directions = true,
	-- 		-- })
	-- 	end,
	-- },
	{
		"folke/trouble.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
		},
		keys = {
			{
				"<leader>ld",
				"<cmd>Trouble diagnostics toggle pinned=false filter.buf=0<cr>",
				desc = "Document diagnostics",
			},
			{
				"<leader>lw",
				"<cmd>Trouble diagnostics toggle pinned=false<cr>",
				desc = "Workspace diagnostics",
			},
			{
				"<leader>ls",
				"<cmd>Trouble symbols toggle<cr>",
				desc = "Document [S]ymbols",
			},
			{
				"<leader>qf",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Open [Q]uick[f]ix",
			},
		},
	},
	{
		"windwp/nvim-autopairs",
		opts = {
			fast_wrap = {},
			disable_filetype = { "vim" },
		},
		config = function(_, opts)
			require("nvim-autopairs").setup(opts)
			--
			-- -- setup cmp for autopairs
			-- local cmp_autopairs = require "nvim-autopairs.completion.cmp"
			-- require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"lewis6991/spaceless.nvim",
		config = function()
			require("spaceless").setup()
		end,
		lazy = false,
	},
	{
		"gbprod/substitute.nvim",
		config = function()
			require("substitute").setup({
				range = {
					prefix = "g",
				},
			})
			-- Exchange
			vim.keymap.set("n", "gx", "<cmd>lua require('substitute.exchange').operator()<cr>", { desc = "" })
			vim.keymap.set("v", "gx", "<cmd>lua require('substitute.exchange').visual()<cr>", { desc = "" })
			vim.keymap.set("n", "gp", "<cmd>lua require('substitute').operator()<cr>", { desc = "" })
			vim.keymap.set("n", "gP", "<cmd>lua require('substitute').eol()<cr>", { desc = "" })
		end,
	},
	{
		"tpope/vim-rsi",
		lazy = false,
	},
	{
		"stevearc/oil.nvim",
		event = "VeryLazy",
		config = function()
			require("oil").setup()
			vim.keymap.set("n", "|", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end,
	},
	{
		"j-hui/fidget.nvim",
		opts = {
			-- options
		},
	},
	-- {
	--
	-- 	"echasnovski/mini.diff",
	-- 	event = "VeryLazy",
	-- 	keys = {
	-- 		{
	-- 			"<leader>gp",
	-- 			function()
	-- 				require("mini.diff").toggle_overlay(0)
	-- 			end,
	-- 			desc = "Toggle mini.diff overlay",
	-- 		},
	-- 		{
	-- 			"[c",
	-- 			function()
	-- 				require("mini.diff").goto_hunk("prev")
	-- 			end,
	-- 			desc = "Previous hunk",
	-- 		},
	-- 		{
	-- 			"]c",
	-- 			function()
	-- 				require("mini.diff").goto_hunk("next")
	-- 			end,
	-- 			desc = "Next hunk",
	-- 		},
	-- 	},
	-- 	opts = function()
	-- 		Snacks.toggle({
	-- 			name = "Mini Diff Signs",
	-- 			get = function()
	-- 				return vim.g.minidiff_disable ~= true
	-- 			end,
	-- 			set = function(state)
	-- 				vim.g.minidiff_disable = not state
	-- 				if state then
	-- 					require("mini.diff").enable(0)
	-- 				else
	-- 					require("mini.diff").disable(0)
	-- 				end
	-- 				-- HACK: redraw to update the signs
	-- 				vim.defer_fn(function()
	-- 					vim.cmd([[redraw!]])
	-- 				end, 200)
	-- 			end,
	-- 		}):map("<leader>gu")
	-- 	end,
	-- 	-- opts = {
	-- 	-- 	view = {
	-- 	-- 		style = "sign",
	-- 	-- 		signs = {
	-- 	-- 			add = "▎",
	-- 	-- 			change = "▎",
	-- 	-- 			delete = "",
	-- 	-- 		},
	-- 	-- 	},
	-- 	-- },
	-- },
	-- {
	-- 	"akinsho/bufferline.nvim",
	-- 	event = "VeryLazy",
	-- 	keys = {
	-- 		{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Toggle Pin" },
	-- 		{ "<leader>bd", "<Cmd>bd<CR>",                             desc = "Close Current Buffer" },
	-- 		{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
	-- 		{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>",           desc = "Delete Buffers to the Right" },
	-- 		{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",            desc = "Delete Buffers to the Left" },
	-- 		{ "<leader>br", "<Cmd>bd<CR>",                             desc = "Delete Current buffer" },
	-- 		{ "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
	-- 		{ "<S-l>",      "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
	-- 		{ "[b",         "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
	-- 		{ "]b",         "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
	-- 		{ "[B",         "<cmd>BufferLineMovePrev<cr>",             desc = "Move buffer prev" },
	-- 		{ "]B",         "<cmd>BufferLineMoveNext<cr>",             desc = "Move buffer next" },
	-- 	},
	-- 	opts = {
	-- 		options = {
	-- 			diagnostics = "nvim_lsp",
	-- 			always_show_bufferline = false,
	-- 			diagnostics_indicator = function(_, _, diag)
	-- 				local ret = (diag.error and "" .. diag.error .. " " or "")
	-- 					.. (diag.warning and "" .. diag.warning or "")
	-- 				return vim.trim(ret)
	-- 			end,
	-- 			offsets = {
	-- 				{
	-- 					filetype = "neo-tree",
	-- 					text = "Neo-tree",
	-- 					highlight = "Directory",
	-- 					text_align = "left",
	-- 				},
	-- 				{
	-- 					filetype = "snacks_layout_box",
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("bufferline").setup(opts)
	-- 		-- Fix bufferline when restoring a session
	-- 		vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
	-- 			callback = function()
	-- 				vim.schedule(function()
	-- 					pcall(nvim_bufferline)
	-- 				end)
	-- 			end,
	-- 		})
	-- 	end,
	-- },
	{
		"navarasu/onedark.nvim",
		lazy = false,
		config = function()
			require("onedark").setup({
				-- Main options --
				style = "deep",   -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
				transparent = false, -- Show/hide background
				term_colors = true, -- Change terminal color as per the selected theme style
				ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
				cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
			})
			vim.cmd("colorscheme onedark")
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = require("configs.snacks"),
		keys = {
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>,",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>u",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo",
			},
			{
				"<leader>op",
				function()
					Snacks.picker.projects()
				end,
				desc = "Open Projects",
			},
			-- find
			{
				"<leader>sc",
				function()
					Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>f",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Git Files",
			},
			{
				"<leader>sr",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent",
			},
			-- Grep
			{
				"<leader>/",
				function()
					Snacks.picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sp",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>sP",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Visual selection or word",
				mode = { "n", "x", "v" },
			},
			-- search
			{
				"<leader>sg",
				function()
					Snacks.picker.git_diff()
				end,
				desc = "Command History",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>sC",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "Search Branches",
			},
			-- LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"<leader>D",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			-- Git
			{
				"<leader>go",
				function()
					Snacks.gitbrowse.open()
				end,
				desc = "Git open in browser",
			},
		},
	},
	{
		"mg979/vim-visual-multi",
		event = "VeryLazy",
		branch = "master",
		config = function()
			vim.cmd([[
                VMTheme codedark
            ]])
		end,
	},
	{
		"kevinhwang91/nvim-bqf",
		lazy = false,
	},
	{
		"johmsalas/text-case.nvim",
		event = "VeryLazy",
		-- lazy = false,
		config = function()
			require("textcase").setup({})
		end,
	},

	-- {
	--     "ggandor/flit.nvim",
	--     lazy = false,
	--     config = function()
	--         require('flit').setup {
	--             keys = { f = 'f', F = 'F', t = 't', T = 'T' },
	--             -- A string like "nv", "nvo", "o", etc.
	--             labeled_modes = "v",
	--             -- Repeat with the trigger key itself.
	--             clever_repeat = true,
	--             multiline = true,
	--             -- Like `leap`s similar argument (call-specific overrides).
	--             -- E.g.: opts = { equivalence_classes = {} }
	--             opts = {}
	--         }
	--     end
	-- },
	-- {
	--     -- Set lualine as statusline
	--     'nvim-lualine/lualine.nvim',
	--     -- See `:help lualine.txt`
	--     config = function()
	--         require('lualine').setup({
	--             sections = {
	--                 lualine_c = { { 'filename', path = 1 } }
	--             },
	--         })
	--     end,
	-- },
	-- {
	--     'rcarriga/nvim-dap-ui',
	--     lazy = false,
	--     dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
	--     config = function()
	--         require('dapui').setup()
	--         local dap, dapui = require("dap"), require("dapui")
	--         dap.listeners.before.attach.dapui_config = function()
	--             dapui.open()
	--         end
	--         dap.listeners.before.launch.dapui_config = function()
	--             dapui.open()
	--         end
	--         dap.listeners.before.event_terminated.dapui_config = function()
	--             dapui.close()
	--         end
	--         dap.listeners.before.event_exited.dapui_config = function()
	--             dapui.close()
	--         end
	--
	--         vim.keymap.set("n", "<leader>dt", "<cmd>DapToggleBreakpoint<CR>", { desc = "[D]ebug [T]oggle Breakpoint" })
	--         vim.keymap.set("n", "<leader>do", "<cmd>DapStepOver<CR>", { desc = "[D]ebug [O]ver" })
	--         vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<CR>", { desc = "[D]ebug [I]nto" })
	--         vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "[D]ebug [C]ontinue" })
	--         vim.keymap.set("n", "<leader>dx", "<cmd>DapTerminate<CR>", { desc = "[D]ebug [X]it" })
	--         vim.keymap.set("n", "<leader>dx", "<cmd>DapTerminate<CR>", { desc = "[D]ebug [X]it" })
	--     end
	-- },
	-- {
	--     'unblevable/quick-scope',
	--     config = function()
	--         vim.cmd [[
	--           highlight QuickScopePrimary guifg='#af0f5f' gui=underline ctermfg=155 cterm=underline
	--           highlight QuickScopeSecondary guifg='#5000ff' gui=underline ctermfg=81 cterm=underline
	--           ]]
	--     end,
	-- },
	-- {
	--     "ggandor/leap-spooky.nvim",
	--     lazy = false,
	--     config = function()
	--         require('leap-spooky').setup {
	--         }
	--     end
	-- },
	-- Rustacenvim config from appelgriebsch/Nv
	-- {
	--     "mrcjkb/rustaceanvim",
	--     ft = { "rust" },
	--     config = function()
	--         local codelldb = require('mason-registry').get_package('codelldb')
	--         local extension_path = codelldb:get_install_path() .. '/extension/'
	--         local codelldb_path = extension_path .. 'adapter/codelldb'
	--         local liblldb_path = extension_path .. 'lldb/lib/liblldb.dylib'
	--
	--         local cfg = require('rustaceanvim.config')
	--         vim.g.rustaceanvim = {
	--             server = {
	--                 on_attach = function(_, _)
	--                     vim.lsp.inlay_hint.enable()
	--                 end,
	--                 default_settings = {
	--                     -- rust-analyzer language server configuration
	--                     ['rust-analyzer'] = {
	--                         checkOnSave = {
	--                             enable = true,
	--                             command = "check",
	--                             -- Disable running tests automatically
	--                             allTargets = false,
	--
	--                             -- extraArgs = { "--no-deps" },
	--                         },
	--                         check = {
	--                             workspace = false
	--                         },
	--                         -- Disable automatic running of tests
	--                         cargo = {
	--                             autoreload = false,
	--                             runBuildScripts = false,
	--                         },
	--                     },
	--                 },
	--             },
	--             dap = {
	--                 adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
	--             },
	--         }
	--         vim.keymap.set("n", "<leader>re", "<cmd>RustLsp expandMacro<CR>", { desc = "[R]ust expand macro" })
	--         vim.keymap.set("n", "<leader>rc", "<cmd>RustLsp openCargo<CR>", { desc = "[R]ust open cargo" })
	--         vim.keymap.set("n", "<leader>rp", "<cmd>RustLsp parentModule<CR>", { desc = "[R]ust open parent module" })
	--         vim.keymap.set("n", "<leader>rr", "<cmd>RustLsp reloadWorkspace<CR>", { desc = "[R]ust [R]estart" })
	--         vim.keymap.set("n", "<leader>rd", "<cmd>RustLsp renderDiagnostic <CR>", { desc = "[R]ust [D]iagnostics" })
	--     end
	-- },
	-- {
	--     'ibhagwan/fzf-lua',
	--     lazy = false,
	--     config = function()
	--         -- require 'fzf-lua'.setup {
	--         --     winopts = {
	--         --         split = "belowright new",
	--         --         height = 0.4
	--         --     }
	--         -- }
	--     end
	--
	-- },

	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			require("conform").setup({
				-- event = { "BufReadPre", "BufNewFile" },
				log_level = vim.log.levels.DEBUG,
				-- format_after_save = {},
				-- vim.api.nvim_create_autocmd("BufWritePre", {
				--     pattern = "*",
				--     callback = function(args)
				--         require("conform").format({ bufnr = args.buf })
				--         -- Wait for the format to complete and reload the buffer
				--     end,
				-- }),
				-- formatters = {
				--     -- Override the default rustfmt config
				--     rustfmt = {
				--         command = "cargo",
				--         args = {
				--             "+nightly-2024-07-01",
				--             "fmt",
				--             "--",
				--         },
				--     },
				-- },
				formatters_by_ft = {
					lua = { "stylua" },
					rust = { "rustfmt" },
					typescript = { "prettierd", "prettier", stop_after_first = true },
					typescriptreact = { "prettierd", "prettier", stop_after_first = true },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					javascriptreact = { "prettierd", "prettier", stop_after_first = true },

					-- ["*"] = { "codespell", "trim_whitespace" },
					-- Use the "_" filetype to run formatters on filetypes that don't
					-- have other formatters configured.
					-- ["_"] = { "trim_whitespace" },
				},
			})
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					require("conform").format({ bufnr = args.buf })
				end,
			})

			-- vim.api.nvim_create_autocmd('FileType', {
			--     pattern = vim.tbl_keys(require('conform').formatters_by_ft),
			--     group = vim.api.nvim_create_augroup('conform_formatexpr', { clear = true }),
			--     callback = function() vim.opt_local.formatexpr = 'v:lua.require("conform").formatexpr()' end,
			-- })
			-- vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			-- vim.g.auto_conform_on_save = true
			-- vim.api.nvim_create_autocmd('BufWritePre', {
			--     pattern = '*',
			--     callback = function(args)
			--         if vim.g.auto_conform_on_save then require('conform').format({ bufnr = args.buf, timeout_ms = nil }) end
			--     end,
			-- })
			-- vim.api.nvim_create_user_command('ConformToggleOnSave', function()
			--     vim.g.auto_conform_on_save = not vim.g.auto_conform_on_save
			--     vim.notify('Auto-Conform on save: ' .. (vim.g.auto_conform_on_save and 'Enabled' or 'Disabled'))
			-- end, {})
		end,
	},
	{
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			-- Adds LSP completion capabilities
			"hrsh7th/cmp-nvim-lsp",

			-- Adds a number of user-friendly snippets
			"onsails/lspkind.nvim",
		},
		config = require("configs.cmp_config"),
	},
})
