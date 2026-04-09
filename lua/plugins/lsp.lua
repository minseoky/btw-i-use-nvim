-- LSP 설정 (Java, Go, Python 지원)
-- Neovim 0.11+ 네이티브 vim.lsp.config API 사용
return {
    -- Mason: LSP 서버 자동 설치 관리자
    {
        "mason-org/mason.nvim",
        opts = {},
    },

    -- Mason + LSPConfig 연동
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
        },
        opts = {
            ensure_installed = {
                "gopls",        -- Go
                "pyright",      -- Python
                "jdtls",        -- Java
                "lua_ls",       -- Lua (Neovim 설정용)
            },
            automatic_enable = false, -- 수동으로 vim.lsp.enable 호출
        },
    },

    -- 자동완성 capabilities 제공용
    {
        "hrsh7th/cmp-nvim-lsp",
        lazy = true,
    },

    -- LSP 핵심 설정 (네이티브 API)
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- LSP 연결 시 키맵 설정
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(ev)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
                    end

                    -- 코드 네비게이션 (IntelliJ: Ctrl+B, Ctrl+Alt+B 등과 유사)
                    map("n", "gd", vim.lsp.buf.definition, "정의로 이동 (Go to Definition)")
                    map("n", "gD", vim.lsp.buf.declaration, "선언으로 이동")
                    map("n", "gr", vim.lsp.buf.references, "참조 찾기 (Find Usages)")
                    map("n", "gi", vim.lsp.buf.implementation, "구현으로 이동")
                    map("n", "gt", vim.lsp.buf.type_definition, "타입 정의로 이동")
                    map("n", "K", vim.lsp.buf.hover, "문서 보기 (Quick Documentation)")

                    -- 리팩토링 (IntelliJ: Shift+F6, Alt+Enter 등과 유사)
                    map("n", "<leader>lr", vim.lsp.buf.rename, "이름 변경 (Rename)")
                    map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "코드 액션 (Quick Fix)")
                    map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "포맷팅")
                    map("n", "<leader>ls", vim.lsp.buf.signature_help, "시그니처 도움말")

                    -- 진단 (Diagnostics)
                    map("n", "<leader>xd", vim.diagnostic.open_float, "진단 상세 보기")
                    map("n", "]d", vim.diagnostic.goto_next, "다음 진단")
                    map("n", "[d", vim.diagnostic.goto_prev, "이전 진단")
                    map("n", "<leader>xl", vim.diagnostic.setloclist, "진단 목록")
                end,
            })

            -- 진단 표시 설정
            vim.diagnostic.config({
                virtual_text = { spacing = 4, prefix = "●" },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { border = "rounded", source = true },
            })

            -- 모든 LSP 서버에 공통 capabilities 적용
            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- Go (gopls)
            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true,
                            shadow = true,
                        },
                        staticcheck = true,
                        gofumpt = true,
                    },
                },
            })

            -- Python (pyright)
            vim.lsp.config("pyright", {
                settings = {
                    python = {
                        analysis = {
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
            })

            -- Java (jdtls) - SDKMAN의 Java 21로 실행 (환경 자동 감지)
            local function find_sdkman_java(version_prefix)
                local candidates = vim.fn.expand("~/.sdkman/candidates/java")
                local dirs = vim.fn.glob(candidates .. "/" .. version_prefix .. "*", true, true)
                if #dirs > 0 then return dirs[1] end
                -- SDKMAN 없으면 current로 fallback
                local current = candidates .. "/current"
                if vim.fn.isdirectory(current) == 1 then return current end
                return nil
            end

            local java21_home = find_sdkman_java("21")
            local java8_home = find_sdkman_java("8")

            -- OS에 따라 jdtls config 디렉토리 결정
            local jdtls_config = vim.fn.stdpath("data") .. "/mason/packages/jdtls/"
                .. (vim.fn.has("mac") == 1 and "config_mac" or "config_linux")

            if java21_home then
                local runtimes = {}
                if java8_home then
                    table.insert(runtimes, { name = "JavaSE-1.8", path = java8_home })
                end
                table.insert(runtimes, { name = "JavaSE-21", path = java21_home, default = true })

                vim.lsp.config("jdtls", {
                    cmd = {
                        java21_home .. "/bin/java",
                        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                        "-Dosgi.bundles.defaultStartLevel=4",
                        "-Declipse.product=org.eclipse.jdt.ls.core.product",
                        "-Dlog.protocol=true",
                        "-Dlog.level=ALL",
                        "-Xmx1g",
                        "--add-modules=ALL-SYSTEM",
                        "--add-opens", "java.base/java.util=ALL-UNNAMED",
                        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                        "-jar", vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
                        "-configuration", jdtls_config,
                        "-data", vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
                    },
                    settings = {
                        java = {
                            configuration = { runtimes = runtimes },
                        },
                    },
                })
            end

            -- Lua (Neovim 설정 편집용)
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            -- 서버 활성화
            vim.lsp.enable({ "gopls", "pyright", "jdtls", "lua_ls" })
        end,
    },

    -- 포매터/린터 관리 (mason으로 설치, 자동 실행)
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        keys = {
            { "<leader>lf", function() require("conform").format({ async = true }) end, desc = "포맷팅" },
        },
        opts = {
            formatters_by_ft = {
                go = { "gofumpt", "goimports" },
                python = { "black" },
                java = { "google-java-format" },
                lua = { "stylua" },
                json = { "prettier" },
                yaml = { "prettier" },
            },
            format_on_save = {
                timeout_ms = 3000,
                lsp_fallback = true,
            },
        },
    },
}
