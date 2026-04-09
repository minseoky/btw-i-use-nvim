-- 에디터 기능 플러그인
return {
    -- 파일 탐색기 (IntelliJ의 Project 패널과 유사)
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        keys = {
            { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "파일 탐색기 토글" },
        },
        opts = {
            filesystem = {
                follow_current_file = { enabled = true },
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            },
            window = {
                width = 35,
                mappings = {
                    ["<space>"] = "none",
                },
            },
        },
    },

    -- Fuzzy Finder (IntelliJ의 Ctrl+Shift+N / Ctrl+Shift+F와 유사)
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "파일 찾기" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "텍스트 검색 (grep)" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "열린 버퍼 목록" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "최근 파일" },
            { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "심볼 검색" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "진단 메시지" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    file_ignore_patterns = { "node_modules", ".git/", "vendor/", "build/", "target/" },
                },
                pickers = {
                    find_files = { hidden = true },
                },
            })
            telescope.load_extension("fzf")
        end,
    },

    -- Treesitter (고급 구문 강조)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            ensure_installed = {
                "java", "go", "gomod", "gosum", "python",
                "lua", "vim", "vimdoc", "query",
                "json", "yaml", "toml", "xml",
                "bash", "dockerfile", "sql",
                "markdown", "markdown_inline",
                "gitcommit", "diff",
            },
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        },
        main = "nvim-treesitter",
    },

    -- 자동 괄호 닫기
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },

    -- 주석 토글 (gcc / gc)
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {},
    },

    -- 서라운드 (ys, cs, ds로 괄호/따옴표 조작)
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },

    -- Git 사이드바 표시 (IntelliJ의 Gutter와 유사)
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "│" },
                change       = { text = "│" },
                delete       = { text = "_" },
                topdelete    = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local map = function(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end
                map("n", "]c", gs.next_hunk, "다음 Git 변경")
                map("n", "[c", gs.prev_hunk, "이전 Git 변경")
                map("n", "<leader>gp", gs.preview_hunk, "Git 변경 미리보기")
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Git Blame")
                map("n", "<leader>gr", gs.reset_hunk, "Git 변경 되돌리기")
            end,
        },
    },

    -- 터미널 토글 (IntelliJ 하단 터미널과 유사)
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys = {
            { "<C-\\>", "<cmd>ToggleTerm direction=horizontal size=15<cr>", desc = "터미널 토글" },
            { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "플로팅 터미널" },
        },
        opts = {
            open_mapping = false,
            direction = "horizontal",
            size = 15,
            shade_terminals = true,
        },
    },
}
