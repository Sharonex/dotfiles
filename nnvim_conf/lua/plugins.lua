-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
    -- NOTE: First, some plugins that don't require any configuration

    -- Git related plugins
    'tpope/vim-rhubarb',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    {
        'williamboman/mason.nvim',
        dependencies = { 'williamboman/mason-lspconfig.nvim' },
        config = function()
            require('mason').setup()
            require('mason-lspconfig').setup()
        end
    },

    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',

            -- Useful status updates for LSP
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            { 'j-hui/fidget.nvim', opts = {} },

            -- Additional lua configuration, makes nvim stuff amazing!
            'folke/neodev.nvim',
        },
        config = function()
            require("configs.lspconfig")
        end,
    },
    {
        'folke/neodev.nvim',
        config = function()
            require('neodev').setup()
        end
    },
    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',

            -- Adds a number of user-friendly snippets
            'rafamadriz/friendly-snippets',
            'onsails/lspkind.nvim',
            'mlaursen/vim-react-snippets',
        },
        config = require('configs.cmp_config'),
    },

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim',  opts = {} },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                -- don't override the built-in and fugitive keymaps
                local gs = package.loaded.gitsigns
                vim.keymap.set({ 'n', 'v' }, ']c', function()
                    if vim.wo.diff then
                        return ']c'
                    end
                    vim.schedule(function()
                        gs.next_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
                vim.keymap.set({ 'n', 'v' }, '[c', function()
                    if vim.wo.diff then
                        return '[c'
                    end
                    vim.schedule(function()
                        gs.prev_hunk()
                    end)
                    return '<Ignore>'
                end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
            end,
        },
    },
    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        config = function()
            require('lualine').setup({
                sections = {
                    lualine_c = { { 'filename', path = 1 } }
                },
            })
        end,
    },
    {
        -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help ibl`
        main = 'ibl',
        opts = {},
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
        },
        config = function()
            -- Enable telescope fzf native, if installed
            pcall(require('telescope').load_extension, 'fzf')
        end
    },
    {
        'nvim-tree/nvim-tree.lua',
        lazy = false,
        config = function()
            require("nvim-tree").setup()
        end
    },
    {
        -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup {
                -- Add languages to be installed here that you want installed for treesitter
                ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

                -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
                auto_install = false,

                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<s-space>',
                        scope_incremental = '<CR>',
                        node_incremental = '<TAB>',
                        node_decremental = '<S-TAB>',
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ['aa'] = '@parameter.outer',
                            ['ia'] = '@parameter.inner',
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = '@class.inner',
                            ['a/'] = '@comment.outer',
                            ['i/'] = '@comment.inner',
                            ['al'] = '@statement.outer',
                            ['il'] = '@statement.outer',
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            [']m'] = '@function.outer',
                            [']]'] = '@class.outer',
                        },
                        goto_next_end = {
                            [']M'] = '@function.outer',
                            [']['] = '@class.outer',
                        },
                        goto_previous_start = {
                            ['[m'] = '@function.outer',
                            ['[['] = '@class.outer',
                        },
                        goto_previous_end = {
                            ['[M'] = '@function.outer',
                            ['[]'] = '@class.outer',
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ['<leader>a'] = '@parameter.inner',
                        },
                        swap_previous = {
                            ['<leader>A'] = '@parameter.inner',
                        },
                    },
                },
            }
        end
    },

    -- sharon configs
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },
    {
        "kdheepak/lazygit.nvim",
        lazy = false,
    },
    {
        'tpope/vim-fugitive',
        lazy = false,
        config = function()
            -- doesn't work :(
            -- TODO: This is meant to be a fugitive mapping region. But it doesn't work.
            -- I think ThePrimeagen's config has a working example of this.
            local fugitiveMappings = vim.api.nvim_create_augroup('FugitiveMappings', { clear = true })
            -- Create an autocommand within that group
            vim.api.nvim_create_autocmd('FileType', {
                group = fugitiveMappings,
                pattern = 'fugitive',
                callback = function()
                    -- Your mappings or commands go here
                    vim.api.nvim_buf_set_keymap(0, 'n', 'o', '<CR>:Gedit', { noremap = true, silent = true })
                end,
            })
        end
    },
    {
        "rmagatti/auto-session",
        lazy = false,
        config = function()
            require("auto-session").setup({
                log_level = "error",
                auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
            })
        end,
    },
    {
        "mbbill/undotree",
        lazy = false,
    },
    -- {
    --     'mrcjkb/rustaceanvim',
    --     version = '^3', -- Recommended
    --     ft = { 'rust' },
    --     {
    --         "lvimuser/lsp-inlayhints.nvim",
    --         opts = {}
    --     },
    --     config = function()
    --         vim.g.rust_recommended_style = false
    --         -- vim.cmd.RustLsp { 'flyCheck', 'cancel' }
    --         vim.g.rustaceanvim = {
    --             inlay_hints = {
    --                 highlight = "NonText",
    --             },
    --             tools = {
    --                 hover_actions = {
    --                     auto_focus = true,
    --                 },
    --             },
    --             server = {
    --                 on_attach = function(client, bufnr)
    --                     print("Attaching inlay hints")
    --                     require("lsp-inlayhints").on_attach(client, bufnr)
    --                 end
    --             },
    --             settings = {
    --                 -- rust-analyzer language server configuration
    --                 -- ['rust-analyzer'] = {
    --                 --     checkOnSave = false,
    --                 -- },
    --             }
    --         }
    --     end
    -- },
    {
        'mrjones2014/smart-splits.nvim',
        config = function()
            require('smart-splits').setup()
        end,
    },
    {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        dependencies = "neovim/nvim-lspconfig",
        opts = function()
            return require("configs.rust-tools")
        end,
        config = function(_, opts)
            require("rust-tools").setup(opts)
        end,
    },
    {
        "gbprod/yanky.nvim",
        dependencies = {
            { "kkharji/sqlite.lua" }
        },
        opts = {
            ring = { storage = "sqlite" },
        },
        lazy = false,
    },
    {
        'ThePrimeagen/harpoon',
        branch = "master",
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        -- config = function()
        --     require("harpoon"):setup({})
        -- end
    },
    {
        dir = "/Users/sharonavni/personal/git-mediate.nvim",
        dependencies = { "skywind3000/asyncrun.vim", "kevinhwang91/nvim-bqf" },
        config = function()
            require("git-mediate").setup()
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
        end
    },
    {
        "ggandor/leap.nvim",
        lazy = false,
        config = function()
            require("leap").add_default_mappings()
            -- require('leap').add_repeat_mappings(';', ',', {
            --     relative_directions = true,
            -- })
        end
    },
    {
        "folke/trouble.nvim",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    {
        "windwp/nvim-autopairs",
        opts = {
            fast_wrap = {},
            disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
            require("nvim-autopairs").setup(opts)

            -- setup cmp for autopairs
            local cmp_autopairs = require "nvim-autopairs.completion.cmp"
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = false,
    },
    {
        'lewis6991/spaceless.nvim',
        config = function()
            require 'spaceless'.setup()
        end,
        lazy = false
    },
    {
        "gbprod/substitute.nvim",
        config = function()
            require("substitute").setup({
                range = {
                    prefix = "g",
                }
            })
        end
    },
    {
        "tpope/vim-rsi",
        lazy = false,
    },
    {
        "fdschmidt93/telescope-egrepify.nvim",
        lazy = false,
        config = function()
            local egrep_actions = require "telescope._extensions.egrepify.actions"
            require("telescope").setup {
                extensions = {
                    egrepify = {
                        attach_mappings = false,
                        -- default mappings
                        mappings = {
                            i = {
                                -- toggle prefixes, prefixes is default
                                ["<C-z>"] = egrep_actions.toggle_prefixes,
                                -- toggle AND, AND is default, AND matches tokens and any chars in between
                                ["<C-&>"] = egrep_actions.toggle_and,
                                -- toggle permutations, permutations of tokens is opt-in
                                ["<C-r>"] = egrep_actions.toggle_permutations,
                            },
                        },
                    },
                },
            }

            require "telescope".load_extension("egrepify")
        end
    },
    {
        "rouge8/neotest-rust",
        ft = "rust",
        dependencies = {
            "nvim-neotest/neotest",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-rust") {
                        args = { "--failure-output=immediate",
                            -- "--nocapture",
                        }
                    }
                }
            })
        end,
    },
    {
        'aznhe21/actions-preview.nvim',
        lazy = false,
    },
    {
        'unblevable/quick-scope',
        config = function()
            vim.cmd [[
              highlight QuickScopePrimary guifg='#af0f5f' gui=underline ctermfg=155 cterm=underline
              highlight QuickScopeSecondary guifg='#5000ff' gui=underline ctermfg=81 cterm=underline
              ]]
        end,
    },
    {
        "kevinhwang91/nvim-bqf",
        lazy = false,
    },
    {
        'terryma/vim-expand-region',
        lazy = false,
    },
    {
        "mg979/vim-visual-multi",
        branch = "master",
        config = function()
            vim.cmd [[
                VMTheme codedark
            ]]
        end,
    },
    {
        "nvim-pack/nvim-spectre",
        lazy = false,
    },
    {
        'nvimtools/none-ls.nvim',
        event = "VeryLazy",
        opts = function()
            return require("configs.null-ls")
        end,
    },
    -- {
    --     "pmizio/typescript-tools.nvim",
    --     dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    --     opts = {},
    -- },
    {
        'windwp/nvim-ts-autotag',
        ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte", "vue" },
        config = function()
            require('nvim-ts-autotag').setup()
        end
    },
    {
        "ErichDonGubler/lsp_lines.nvim",
        config = function()
            require("lsp_lines").setup()
        end,

    },
    {
        "stevearc/oil.nvim",
        lazy = false,
        config = function()
            require("oil").setup()
        end,
    },
    {
        'sindrets/diffview.nvim',
        event = "VeryLazy",
    },
    -- {
    --     "catppuccin/nvim",
    --     lazy = false,
    --     config = function()
    --         vim.cmd("colorscheme catppuccin-mocha")
    --     end
    -- },
    {
        'navarasu/onedark.nvim',
        lazy = false,
        config = function()
            require('onedark').setup {
                -- Main options --
                style = 'deep',               -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
                transparent = false,          -- Show/hide background
                term_colors = true,           -- Change terminal color as per the selected theme style
                ending_tildes = false,        -- Show the end-of-buffer tildes. By default they are hidden
                cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

                -- toggle theme style ---
                toggle_style_key = "<leader>tx",
            }
            vim.cmd("colorscheme onedark")
        end
    },
    {
        'pwntester/octo.nvim',
        lazy = false,
        config = function()
            require "octo".setup({
                colors = { -- used for highlight groups (see Colors section below)
                    white = "#ffffff",
                    grey = "#2A354C",
                    black = "#000000",
                    red = "#fdb8c0",
                    dark_red = "#da3633",
                    green = "#acf2bd",
                    dark_green = "#238636",
                    yellow = "#d3c846",
                    dark_yellow = "#735c0f",
                    blue = "#58A6FF",
                    dark_blue = "#0366d6",
                    purple = "#6f42c1",
                },

            })
        end
    },
    {
        "kevinhwang91/nvim-ufo",
        event = "BufRead",
        dependencies = { 'kevinhwang91/promise-async' },
        config = function()
            vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
            require("ufo").setup({
                provider_selector = function(_, _, _)
                    return { 'lsp', 'indent' }
                end,
            })
        end,
    },
})
